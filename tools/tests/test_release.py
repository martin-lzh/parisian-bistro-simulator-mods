"""Check publication, retries and authorization with real Git trees and a fake GitHub."""

import copy
from hashlib import sha256
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
import urllib.parse
import urllib.request
from zipfile import ZipFile, ZipInfo

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import ci
import release


MIT_LICENSE = (Path(__file__).resolve().parents[2] / "LICENSE").read_text(encoding="utf-8")


class FakeGitHub:
    def __init__(self):
        self.records = []
        self.tags = {}
        self.tag_objects = {}
        self.assets = {}
        self.writes = []
        self.downloaded = []
        self.corrupt_upload = False
        self.fail_upload = None
        self.private = True
        self.full_name = "example/mods"

    def pages(self, path):
        if path == "/releases":
            return copy.deepcopy(self.records)
        return copy.deepcopy(next(r["assets"] for r in self.records if str(r["id"]) == path.split("/")[2]))

    def request(self, path, method="GET", payload=None, raw=False, missing_ok=False):
        if method != "GET":
            self.writes.append((path, method, payload))
        if path == "":
            return {"private": self.private, "full_name": self.full_name}
        if path.startswith("/git/ref/tags/"):
            obj = self.tags.get(path.removeprefix("/git/ref/tags/"))
            return {"object": obj} if obj else None
        if path.startswith("/git/tags/"):
            return {"object": self.tag_objects[path.split("/")[-1]]}
        if path.startswith("/releases/assets/"):
            assert raw
            asset_id = int(path.split("/")[-1])
            self.downloaded.append(asset_id)
            return self.assets[asset_id]
        if path == "/releases" and method == "POST":
            record = dict(payload, id=len(self.records) + 1, assets=[])
            record["upload_url"] = f"https://uploads.github.com/repos/example/mods/releases/{record['id']}/assets{{?name,label}}"
            self.records.append(record)
            return copy.deepcopy(record)
        if path.startswith("https://uploads.github.com/") and method == "POST":
            url = urllib.parse.urlparse(path)
            name = urllib.parse.parse_qs(url.query)["name"][0]
            if self.fail_upload == name:
                raise RuntimeError("Simulated upload interruption")
            record = next(r for r in self.records if str(r["id"]) == url.path.split("/")[-2])
            asset = {"id": len(self.assets) + 1, "name": name}
            self.assets[asset["id"]] = payload + (b"corrupt" if self.corrupt_upload else b"")
            record["assets"].append(asset)
            return asset
        if path.startswith("/releases/"):
            record = next(r for r in self.records if str(r["id"]) == path.split("/")[2])
            if method == "PATCH":
                record.update(payload)
                self.tags[record["tag_name"]] = {"type": "commit", "sha": record["target_commitish"]}
            return copy.deepcopy(record)
        raise AssertionError((path, method))


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.mod = {"slug": "sample", "name": "Sample", "version": "1.1.0",
                    "source": self.root / "sample-mod", "output": self.root / "outputs/sample",
                    "files": ("Scripts/main.lua", "README.md", "DEVELOPMENT.md", "CHANGELOG.md", "LICENSE")}
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
        self.write("LICENSE", MIT_LICENSE)
        self.write("sample-mod/LICENSE", MIT_LICENSE)
        self.write("sample-mod/Scripts/main.lua", "return {}\n")
        self.write("sample-mod/README.md", "Sample 1.1.0\n")
        self.write("sample-mod/DEVELOPMENT.md", "Original development notes\n")
        self.write("sample-mod/CHANGELOG.md", "# Changes\n\n## Unreleased\n\n## 1.1.0 - 2026-09-24\n\n- Current fix.\n\n## 1.0.0\n\n- Old release.\n")
        self.write("tools/ci.py", "# build implementation\n")
        self.write(".github/workflows/mods.yml", "# workflow\n")
        self.source = self.commit()
        self.api = FakeGitHub()

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

    def approve(self, prerelease=False):
        release.record_approval("sample", "Fixture maintainer explicitly requests Sample 1.1.0", prerelease)
        self.head = self.commit()
        return self.head

    def artifacts(self):
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
        evidence = {"sourceCommit": self.head, "mods": {"sample": "1.1.0"},
                    "assets": {path.name: sha256(path.read_bytes()).hexdigest() for path in (archive, checksum)}}
        self.write("outputs/ci/build-info.json", json.dumps(evidence))

    def ready(self, prerelease=False):
        self.approve(prerelease)
        self.artifacts()

    def publish(self):
        release.publish("example/mods", self.head, self.api)

    def interrupted_draft(self):
        self.ready()
        self.api.fail_upload = "build-info.json"
        with self.assertRaisesRegex(RuntimeError, "interruption"):
            self.publish()
        self.api.fail_upload = None
        self.api.writes.clear()

    def test_create_download_verify_and_publish(self):
        self.ready()
        self.publish()
        record = self.api.records[0]
        self.assertFalse(record["draft"])
        self.assertFalse(record["prerelease"])
        self.assertEqual(self.api.tags["sample-v1.1.0"]["sha"], self.head)
        self.assertEqual({a["name"] for a in record["assets"]}, {"Sample-1.1.0.zip", "build-info.json", "SHA256SUMS.txt"})
        self.assertEqual(len(self.api.downloaded), 3)
        self.assertIn("Current fix", record["body"])
        self.assertNotIn("Old release", record["body"])
        assets = {a["name"]: self.api.assets[a["id"]] for a in record["assets"]}
        for line in assets["SHA256SUMS.txt"].decode().splitlines():
            digest, name = line.split("  ")
            self.assertEqual(digest, sha256(assets[name]).hexdigest())
        self.assertEqual(json.loads(assets["build-info.json"])["sourceCommit"], self.head)

    def test_prerelease_flag_is_preserved(self):
        self.ready(prerelease=True)
        self.publish()
        self.assertTrue(self.api.records[0]["prerelease"])

    def test_existing_publication_is_not_overwritten(self):
        self.ready()
        self.publish()
        original = copy.deepcopy(self.api.records)
        self.api.writes.clear()
        self.publish()
        self.assertEqual(self.api.records, original)
        self.assertEqual(self.api.writes, [])

    def test_no_approval_skips_without_reading_artifacts(self):
        self.head = self.source
        self.publish()
        self.assertEqual(self.api.writes, [])

    def test_development_version_is_not_published(self):
        self.mod["version"] = "1.1.0-dev"
        self.head = self.source
        self.publish()
        self.assertEqual(self.api.writes, [])

    def test_dirty_checkout_is_rejected(self):
        self.ready()
        self.write("sample-mod/Scripts/main.lua", "return false\n")
        with self.assertRaisesRegex(ValueError, "Commit source"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_different_checkout_is_rejected(self):
        self.ready()
        with self.assertRaisesRegex(ValueError, "exact checked-out"):
            release.publish("example/mods", self.source, self.api)

    def test_approval_survives_its_own_commit_and_root_document_changes(self):
        self.approve()
        self.assertNotEqual(self.head, self.source)
        self.write("README.md", "Index changes\n")
        self.assertIsNotNone(release.authorized(self.mod, self.commit()))

    def assert_stale(self, name):
        self.approve()
        self.write(name, "changed\n")
        with self.assertRaisesRegex(ValueError, "inputs changed"):
            release.authorized(self.mod, self.commit())

    def test_mod_change_invalidates_approval(self):
        self.assert_stale("sample-mod/Scripts/main.lua")

    def test_build_tool_change_invalidates_approval(self):
        self.assert_stale("tools/ci.py")

    def test_workflow_change_invalidates_approval(self):
        self.assert_stale(".github/workflows/mods.yml")

    def test_unreleased_content_blocks_approval(self):
        path = self.mod["source"] / "CHANGELOG.md"
        self.write("sample-mod/CHANGELOG.md", path.read_text().replace("## Unreleased\n", "## Unreleased\n- Pending work\n"))
        self.commit()
        with self.assertRaisesRegex(ValueError, "Unreleased"):
            self.approve()

    def test_duplicate_numbered_entry_blocks_approval(self):
        path = self.mod["source"] / "CHANGELOG.md"
        self.write("sample-mod/CHANGELOG.md", path.read_text() + "\n## 1.1.0\n- Duplicate\n")
        self.commit()
        with self.assertRaisesRegex(ValueError, "numbered CHANGELOG"):
            self.approve()

    def test_archived_record_does_not_authorize(self):
        self.approve()
        path = release.approval_path(self.mod)
        history = path.parent / "history" / path.name
        history.parent.mkdir()
        path.rename(history)
        self.assertIsNone(release.authorized(self.mod, self.commit()))

    def test_invalid_approval_fields_fail(self):
        self.approve()
        path = release.approval_path(self.mod)
        record = json.loads(path.read_text())
        record["prerelease"] = "false"
        path.write_text(json.dumps(record), encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "invalid release approval"):
            release.authorized(self.mod, self.commit())

    def test_unchanged_mod_directory_skips(self):
        self.approve()
        self.git("tag", "sample-v1.0.0", self.source)
        self.api.records = [{"tag_name": "sample-v1.0.0", "draft": False}]
        self.publish()
        self.assertEqual(self.api.writes, [])

    def test_version_rollback_is_rejected(self):
        self.approve()
        self.api.records = [{"tag_name": "sample-v1.2.0", "draft": False}]
        with self.assertRaisesRegex(ValueError, "rollback"):
            self.publish()

    def test_missing_published_tag_fails_closed(self):
        self.approve()
        self.api.records = [{"tag_name": "sample-v1.0.0", "draft": False}]
        with self.assertRaisesRegex(ValueError, "Missing published tag"):
            self.publish()

    def test_artifact_commit_mismatch_fails_before_writes(self):
        self.ready()
        path = self.root / "outputs/ci/build-info.json"
        evidence = json.loads(path.read_text())
        evidence["sourceCommit"] = self.source
        path.write_text(json.dumps(evidence), encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "CI build evidence"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_corrupt_artifact_fails_before_writes(self):
        self.ready()
        self.write("outputs/ci/Sample-1.1.0.zip", "corrupted")
        with self.assertRaisesRegex(ValueError, "checksum mismatch"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_extra_artifact_fails_before_writes(self):
        self.ready()
        self.write("outputs/ci/extra.txt", "extra")
        with self.assertRaisesRegex(ValueError, "Unexpected or missing CI artifacts"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_existing_tag_without_draft_is_rejected(self):
        self.ready()
        self.api.tags["sample-v1.1.0"] = {"type": "commit", "sha": self.head}
        with self.assertRaisesRegex(ValueError, "Tag exists"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_interrupted_upload_resumes_without_replacing_assets(self):
        self.interrupted_draft()
        first_asset = self.api.records[0]["assets"][0]
        self.publish()
        self.assertFalse(self.api.records[0]["draft"])
        self.assertEqual(len(self.api.records), 1)
        self.assertEqual(self.api.records[0]["assets"][0], first_asset)
        uploads = [path for path, method, _ in self.api.writes if method == "POST"]
        self.assertEqual(len(uploads), 2)

    def test_other_source_draft_is_not_modified(self):
        self.interrupted_draft()
        self.api.records[0]["target_commitish"] = self.source
        with self.assertRaisesRegex(ValueError, "different source/metadata"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_corrupt_existing_draft_asset_is_not_replaced(self):
        self.interrupted_draft()
        self.api.assets[1] = b"different"
        with self.assertRaisesRegex(ValueError, "Existing draft asset differs"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_unexpected_draft_asset_is_not_deleted(self):
        self.interrupted_draft()
        self.api.records[0]["assets"].append({"id": 2, "name": "extra.txt"})
        self.api.assets[2] = b"extra"
        with self.assertRaisesRegex(ValueError, "Unexpected assets"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_corrupt_uploaded_asset_keeps_release_draft(self):
        self.ready()
        self.api.corrupt_upload = True
        with self.assertRaisesRegex(ValueError, "Uploaded asset differs"):
            self.publish()
        self.assertTrue(self.api.records[0]["draft"])
        self.assertFalse(any(method == "PATCH" for _, method, _ in self.api.writes))

    def test_conflicting_annotated_draft_tag_is_rejected(self):
        self.interrupted_draft()
        self.api.tags["sample-v1.1.0"] = {"type": "tag", "sha": "a" * 40}
        self.api.tag_objects["a" * 40] = {"type": "commit", "sha": self.source}
        with self.assertRaisesRegex(ValueError, "different source/metadata"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_public_repository_publishes_verified_authorized_assets(self):
        self.ready()
        self.api.private = False
        self.publish()
        record = self.api.records[0]
        self.assertFalse(record["draft"])
        self.assertEqual(self.api.tags["sample-v1.1.0"]["sha"], self.head)
        self.assertEqual({a["name"] for a in record["assets"]},
                         {"Sample-1.1.0.zip", "build-info.json", "SHA256SUMS.txt"})
        self.assertEqual(len(self.api.downloaded), 3)

    def test_repository_identity_mismatch_stops_before_writes(self):
        self.ready()
        self.api.private = False
        for target in ("other/mods", "example/other", None):
            with self.subTest(target=target):
                self.api.full_name = target
                with self.assertRaisesRegex(ValueError, "repository identity"):
                    self.publish()
                self.assertEqual(self.api.writes, [])

    def test_repository_identity_is_case_insensitive(self):
        self.ready()
        self.api.private = False
        self.api.full_name = "Example/Mods"
        self.publish()
        self.assertFalse(self.api.records[0]["draft"])

    def test_public_repository_rejects_invalid_build_evidence(self):
        self.ready()
        self.api.private = False
        self.write("outputs/ci/build-info.json", "{}")
        with self.assertRaisesRegex(ValueError, "CI build evidence"):
            self.publish()
        self.assertEqual(self.api.writes, [])

    def test_public_repository_with_published_versions_is_a_noop(self):
        self.ready()
        self.api.private = False
        self.publish()
        original = copy.deepcopy(self.api.records)
        self.api.writes.clear()
        self.publish()
        self.assertEqual(self.api.records, original)
        self.assertEqual(self.api.writes, [])

    def test_public_repository_without_approval_is_a_noop(self):
        self.head = self.source
        self.api.private = False
        self.publish()
        self.assertEqual(self.api.writes, [])


class GitHubTransportTests(unittest.TestCase):
    def test_cross_host_asset_redirect_strips_token(self):
        request = urllib.request.Request("https://api.github.com/repos/example/mods/releases/assets/1",
                                         headers={"Authorization": "Bearer fixture-token"})
        redirected = release.AssetRedirect().redirect_request(
            request, None, 302, "Found", {}, "https://release-assets.githubusercontent.com/asset")
        self.assertIsNone(redirected.get_header("Authorization"))

    def test_asset_redirect_cannot_downgrade_to_http(self):
        request = urllib.request.Request("https://api.github.com/asset")
        with self.assertRaisesRegex(ValueError, "non-HTTPS"):
            release.AssetRedirect().redirect_request(request, None, 302, "Found", {}, "http://example.invalid/asset")

    def test_pagination_reads_every_page(self):
        api = release.GitHub.__new__(release.GitHub)
        with patch.object(api, "request", side_effect=[[{}] * 100, [{"id": 101}]]) as request:
            self.assertEqual(len(api.pages("/releases")), 101)
        self.assertEqual(request.call_args_list[1].args[0], "/releases?per_page=100&page=2")


if __name__ == "__main__":
    unittest.main()
