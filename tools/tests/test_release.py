"""Check how this repository describes its Mods to tools/modrelease.py and verifies CI packages."""

from hashlib import sha256
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
from zipfile import ZipFile, ZipInfo

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import ci
import release


REPOSITORY_LICENSE = (Path(__file__).resolve().parents[2] / "LICENSE").read_text(encoding="utf-8")


class ReleaseAdapterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.mod = {"slug": "sample", "name": "Sample", "version": "1.1.0", "display_name": "Sample Mod",
                    "prerelease": True, "source": self.root / "sample-mod", "output": self.root / "outputs/sample",
                    "files": ("Scripts/main.lua", "README.md", "DEVELOPMENT.md", "CHANGELOG.md", "LICENSE"),
                    "generated": {}}
        for target, attribute, value in ((release, "ROOT", self.root), (ci, "ROOT", self.root),
                                         (ci, "MODS", {"sample": "Sample"})):
            mock = patch.object(target, attribute, value)
            mock.start()
            self.addCleanup(mock.stop)
        mock = patch.object(ci, "config", return_value=self.mod)
        mock.start()
        self.addCleanup(mock.stop)
        self.git("init", "--quiet")
        self.write(".gitignore", "/outputs/\n")
        self.write("LICENSE", REPOSITORY_LICENSE)
        self.write("sample-mod/LICENSE", REPOSITORY_LICENSE)
        self.write("sample-mod/Scripts/main.lua", "return {}\n")
        self.write("sample-mod/README.md", "Sample 1.1.0\n")
        self.write("sample-mod/DEVELOPMENT.md", "Original development notes\n")
        self.write("sample-mod/CHANGELOG.md", "# Changes\n\n## Unreleased\n\n## 1.1.0 - 2026-10-18\n\n- Current fix.\n\n## 1.0.0\n\n- Old release.\n")
        self.head = self.commit()

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.root, text=True, stderr=subprocess.PIPE).strip()

    def write(self, name, content):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")

    def commit(self):
        self.git("add", ".")
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "--quiet", "-m", "Fixture")
        return self.git("rev-parse", "HEAD")

    def artifacts(self, commit=None, extra=False):
        directory = self.root / "outputs/ci"
        directory.mkdir(parents=True, exist_ok=True)
        archive = directory / ci.package_path(self.mod).name
        with ZipFile(archive, "w") as package:
            for name in self.mod["files"] + ("enabled.txt",):
                info = ZipInfo(f"Sample/{name}")
                info.external_attr = 0o100644 << 16
                package.writestr(info, b"" if name == "enabled.txt" else (self.mod["source"] / name).read_bytes())
        checksum = archive.with_suffix(".zip.sha256")
        checksum.write_text(f"{sha256(archive.read_bytes()).hexdigest()}  {archive.name}\n", encoding="utf-8", newline="\n")
        evidence = {"sourceCommit": commit or self.head, "mods": {"sample": "1.1.0"},
                    "assets": {path.name: sha256(path.read_bytes()).hexdigest() for path in (archive, checksum)}}
        self.write("outputs/ci/build-info.json", json.dumps(evidence))
        if extra:
            self.write("outputs/ci/old-package.zip", "stale")

    def test_release_mods_use_display_name_notes_and_package(self):
        mod = release.release_mods("example/mods")[0]
        self.assertEqual((mod.display_name, mod.version, mod.prerelease, mod.unreleased),
                         ("Sample Mod", "1.1.0", True, False))
        self.assertIn("- Current fix.", mod.notes)
        self.assertNotIn("Old release", mod.notes)
        self.assertEqual([p.name for p in mod.assets], ["Sample-1.1.0.zip"])

    def test_unreleased_entries_are_detected(self):
        self.write("sample-mod/CHANGELOG.md", "## Unreleased\n\n- Pending.\n\n## 1.1.0 - 2026-10-18\n\n- Fix.\n")
        mod = release.release_mods("example/mods")[0]
        self.assertTrue(mod.unreleased)

    def test_missing_entry_gives_no_notes(self):
        self.write("sample-mod/CHANGELOG.md", "## Unreleased\n\n## 1.0.0\n\n- Old.\n")
        self.assertIsNone(release.release_mods("example/mods")[0].notes)

    def test_verified_artifacts_pass(self):
        self.artifacts()
        release.verify_artifacts(self.head)

    def test_artifacts_from_other_commit_fail(self):
        self.artifacts(commit="b" * 40)
        with self.assertRaises(ValueError):
            release.verify_artifacts(self.head)

    def test_extra_artifact_fails(self):
        self.artifacts(extra=True)
        with self.assertRaises(ValueError):
            release.verify_artifacts(self.head)

    def test_publish_refuses_other_or_dirty_checkout(self):
        with self.assertRaises(ValueError):
            release.publish("example/mods", "b" * 40, api=object())
        self.write("sample-mod/README.md", "edited\n")
        with self.assertRaises(ValueError):
            release.publish("example/mods", self.head, api=object())


if __name__ == "__main__":
    unittest.main()
