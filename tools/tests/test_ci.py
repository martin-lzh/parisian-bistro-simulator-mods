"""Exercise release-package rejection paths without game files."""

from hashlib import sha256
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
from zipfile import ZipFile, ZipInfo

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import ci


REPOSITORY_LICENSE = (Path(__file__).resolve().parents[2] / "LICENSE").read_text(encoding="utf-8")


class PackageChecks(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        source = self.root / "example-mod"
        (source / "Scripts").mkdir(parents=True)
        content = {"Scripts/main.lua": "return {}\n",
                   "README.md": "Example 1.0.0\n",
                   "DEVELOPMENT.md": "Development\n",
                   "CHANGELOG.md": "## Unreleased\n\n## 1.0.0 - 2026-09-24\n\n- Release\n",
                   "LICENSE": REPOSITORY_LICENSE}
        (self.root / "LICENSE").write_text(REPOSITORY_LICENSE, encoding="utf-8")
        for name, text in content.items():
            (source / name).write_text(text, encoding="utf-8")
        self.mod = {"slug": "example", "name": "Example", "version": "1.0.0",
                    "source": source, "output": self.root, "files": tuple(content)}
        self.payload = {f"Example/{name}": text.encode() for name, text in content.items()}
        self.payload["Example/enabled.txt"] = b""
        self.archive = self.root / "Example-1.0.0.zip"

    def write_package(self, payload=None):
        with ZipFile(self.archive, "w") as package:
            for name, data in (self.payload if payload is None else payload).items():
                info = ZipInfo(name)
                info.external_attr = 0o100644 << 16
                package.writestr(info, data)
        self.write_checksum()

    def write_checksum(self):
        self.archive.with_suffix(".zip.sha256").write_text(
            f"{sha256(self.archive.read_bytes()).hexdigest()}  {self.archive.name}\n",
            encoding="utf-8")

    def validate(self):
        tracked = "\0".join(["LICENSE"] + [f"example-mod/{name}" for name in self.mod["files"]]).encode()
        with patch.object(ci, "ROOT", self.root), patch.object(ci.subprocess, "check_output", return_value=tracked):
            ci.validate_config(self.mod)

    def test_original_package_and_version_pass(self):
        self.validate()
        self.write_package()
        ci.verify_package(self.mod, self.archive)

    def test_package_allowlist_must_include_license(self):
        self.mod["files"] = tuple(name for name in self.mod["files"] if name != "LICENSE")
        with self.assertRaisesRegex(ValueError, "allowlist.*LICENSE"):
            self.validate()

    def test_missing_source_license_is_rejected(self):
        (self.mod["source"] / "LICENSE").unlink()
        with self.assertRaisesRegex(ValueError, "Missing.*LICENSE"):
            self.validate()

    def test_source_license_must_match_repository_license(self):
        for text in ("Other License\n", REPOSITORY_LICENSE.replace("Zhaohan Liu", "Unrelated Author")):
            with self.subTest(license=text):
                (self.mod["source"] / "LICENSE").write_text(text, encoding="utf-8")
                with self.assertRaisesRegex(ValueError, "LICENSE must match"):
                    self.validate()

    def test_missing_repository_license_is_rejected(self):
        (self.root / "LICENSE").unlink()
        with self.assertRaisesRegex(ValueError, "Repository LICENSE"):
            self.validate()

    def test_license_line_endings_are_normalized(self):
        (self.mod["source"] / "LICENSE").write_bytes(REPOSITORY_LICENSE.replace("\n", "\r\n").encode())
        self.validate()
        self.write_package()
        ci.verify_package(self.mod, self.archive)

    def test_missing_packaged_license_is_rejected(self):
        self.write_package({name: data for name, data in self.payload.items() if name != "Example/LICENSE"})
        with self.assertRaisesRegex(ValueError, "package entries"):
            ci.verify_package(self.mod, self.archive)

    def test_changed_packaged_license_is_rejected_even_with_matching_checksum(self):
        self.write_package(self.payload | {"Example/LICENSE": b"Other License\n"})
        with self.assertRaisesRegex(ValueError, "differs from source.*LICENSE"):
            ci.verify_package(self.mod, self.archive)

    def test_unlisted_files_and_path_traversal_are_rejected(self):
        for name in ("Example/game.dll", "../outside.lua", "Example/tests/spec.lua"):
            with self.subTest(name=name):
                self.write_package(self.payload | {name: b"unexpected"})
                with self.assertRaisesRegex(ValueError, "package entries"):
                    ci.verify_package(self.mod, self.archive)

    def test_missing_activation_marker_is_rejected(self):
        self.write_package({name: data for name, data in self.payload.items() if not name.endswith("enabled.txt")})
        with self.assertRaisesRegex(ValueError, "package entries"):
            ci.verify_package(self.mod, self.archive)

    def test_changed_content_is_rejected_even_with_matching_checksum(self):
        self.write_package(self.payload | {"Example/Scripts/main.lua": b"return false\n"})
        with self.assertRaisesRegex(ValueError, "differs from source"):
            ci.verify_package(self.mod, self.archive)

    def test_checksum_mismatch_is_rejected(self):
        self.write_package()
        self.archive.with_suffix(".zip.sha256").write_text("0" * 64, encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "SHA-256"):
            ci.verify_package(self.mod, self.archive)

    def test_generated_binary_is_checked_without_text_normalization(self):
        binary = b"MZ\x00\r\n\xfforiginal-helper"
        helper = self.root / "delivery_bridge.dll"
        helper.write_bytes(binary)
        self.mod["generated"] = {"Scripts/delivery_bridge.dll": helper}
        self.write_package(self.payload | {"Example/Scripts/delivery_bridge.dll": binary})
        ci.verify_package(self.mod, self.archive)
        evidence = {"Scripts/delivery_bridge.dll": sha256(binary).hexdigest()}
        helper.unlink()
        ci.verify_package(self.mod, self.archive, evidence)
        with self.assertRaisesRegex(ValueError, "evidence"):
            ci.verify_package(self.mod, self.archive, {})
        self.write_package(self.payload | {"Example/Scripts/delivery_bridge.dll": binary + b"tampered"})
        with self.assertRaisesRegex(ValueError, "Generated package content"):
            ci.verify_package(self.mod, self.archive, evidence)

    def test_unapproved_generated_binary_is_rejected(self):
        self.mod["generated"] = {"Scripts/unrelated.dll": self.root / "unrelated.dll"}
        with self.assertRaisesRegex(ValueError, "Disallowed generated"):
            self.validate()

    def test_auto_menu_native_allowlist_and_output_boundary(self):
        self.mod["slug"] = "auto-menu"
        name, inputs = ci.NATIVE["auto-menu"]
        source = self.mod["source"]
        for path in inputs:
            file = source / path
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text("original test fixture\n", encoding="utf-8")
        tracked = "\0".join(["LICENSE"] + [f"example-mod/{path}" for path in set(self.mod["files"]) | inputs]).encode()
        helper = self.root / "outputs/auto-menu/native/auto_menu_bridge.dll"
        with patch.object(ci, "ROOT", self.root), patch.object(ci.subprocess, "check_output", return_value=tracked):
            self.mod["generated"] = {name: helper}
            ci.validate_config(self.mod)
            self.mod["generated"] = {name: self.root / "outside.dll"}
            with self.assertRaisesRegex(ValueError, "native build output"):
                ci.validate_config(self.mod)
            self.mod["generated"] = {"Scripts/delivery_bridge.dll": helper}
            with self.assertRaisesRegex(ValueError, "Disallowed generated"):
                ci.validate_config(self.mod)
            self.mod["generated"] = {}
            with self.assertRaisesRegex(ValueError, "Native helper"):
                ci.validate_config(self.mod)

    def test_symbolic_link_entry_is_rejected(self):
        with ZipFile(self.archive, "w") as package:
            for name, data in self.payload.items():
                info = ZipInfo(name)
                info.external_attr = (0o120777 if name.endswith("main.lua") else 0o100644) << 16
                package.writestr(info, data)
        self.write_checksum()
        with self.assertRaisesRegex(ValueError, "Non-regular"):
            ci.verify_package(self.mod, self.archive)

    def test_stable_version_needs_changelog(self):
        self.mod["version"] = "1.0.1"
        with self.assertRaisesRegex(ValueError, "CHANGELOG"):
            self.validate()

    def test_diagnostic_version_must_match(self):
        (self.mod["source"] / "Scripts/diagnostics.lua").write_text(
            "Diagnostics.VERSION = '1.0.0-dev'\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "versions disagree"):
            self.validate()

    def test_new_lua_module_must_be_packaged(self):
        (self.mod["source"] / "Scripts/new.lua").write_text("return {}\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "allowlist"):
            self.validate()

    def test_build_allowlist_cannot_include_local_reference(self):
        self.mod["files"] += ("../work/reference.lua",)
        with self.assertRaisesRegex(ValueError, "Disallowed"):
            self.validate()


class ChangeTests(unittest.TestCase):
    """CI skips build and test only for files that never reach a package, validation or tests."""

    def test_examples(self):
        mod = "smart-delivery-mod"
        core = [f"{mod}/Scripts/main.lua", f"{mod}/README.md", f"{mod}/DEVELOPMENT.md", f"{mod}/CHANGELOG.md",
                f"{mod}/LICENSE", f"{mod}/release.json", f"{mod}/build.py", f"{mod}/native_build.py",
                f"{mod}/Native/bridge.cpp", f"{mod}/tests/run.py", "vortex-extension/README.md",
                "vortex-extension/gameart.png", "vortex-extension/index.js", "tools/ci.py",
                "tools/enable_hot_reload.ps1", "tools/tests/test_ci.py", ".github/workflows/mods.yml",
                ".github/main-ruleset.json", ".editorconfig", ".gitattributes", ".gitignore", "LICENSE",
                "new-mod/Scripts/main.lua"]
        non_core = ["README.md", "AGENTS.md", "DEVELOPMENT.md", "CODE_OF_CONDUCT.md", "CONTRIBUTING.md",
                    "SECURITY.md", "SUPPORT.md", "docs/hot-reload.md", "assets/cover.png", "assets/cover-prompt.txt",
                    "releases/README.md", "releases/approvals/smart-delivery-v0.1.5.json", f"{mod}/assets/cover.png",
                    f"{mod}/assets/README.md", "bartenders-note-mod/assets/claimed-drinks-gameplay.gif"]
        for path in core:
            with self.subTest(core=path):
                self.assertTrue(ci.changes.is_core(path, ci.NON_CORE))
        for path in non_core:
            with self.subTest(non_core=path):
                self.assertFalse(ci.changes.is_core(path, ci.NON_CORE))

    def test_package_inputs_and_build_files_are_core(self):
        for slug in ci.MODS:
            mod = ci.config(slug)
            native = ci.NATIVE.get(slug, ("", set()))[1]
            for name in (*mod["files"], *native, "build.py", "release.json"):
                path = (mod["source"] / name).relative_to(ci.ROOT).as_posix()
                with self.subTest(path=path):
                    self.assertTrue(ci.changes.is_core(path, ci.NON_CORE))
        names = subprocess.check_output(["git", "ls-files", "-z"], cwd=ci.ROOT).decode("utf-8").split("\0")
        for name in filter(None, names):
            path = PurePosixPath(name)
            if (path.parts[0] in {"vortex-extension", "tools", ".github"}
                    or (path.parts[0].endswith("-mod") and path.parts[1] != "assets")):
                with self.subTest(name=name):
                    self.assertTrue(ci.changes.is_core(name, ci.NON_CORE))


if __name__ == "__main__":
    unittest.main()
