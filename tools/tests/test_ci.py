"""Exercise release-package rejection paths without game files."""

from hashlib import sha256
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
from zipfile import ZipFile, ZipInfo

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import ci


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
                   "CHANGELOG.md": "## Unreleased\n\n## 1.0.0 - 2026-09-24\n\n- Release\n"}
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
        tracked = "\0".join(f"example-mod/{name}" for name in self.mod["files"]).encode()
        with patch.object(ci, "ROOT", self.root), patch.object(ci.subprocess, "check_output", return_value=tracked):
            ci.validate_config(self.mod)

    def test_original_package_and_version_pass(self):
        self.validate()
        self.write_package()
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


if __name__ == "__main__":
    unittest.main()
