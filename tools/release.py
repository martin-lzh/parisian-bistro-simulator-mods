"""Publish authorized Mod versions from verified CI artifacts without replacing releases."""

import argparse
from hashlib import sha256
import json
import os
from pathlib import Path
import re
import subprocess
import urllib.error
import urllib.parse
import urllib.request

import ci


ROOT = ci.ROOT
VERSION = r"(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)"
COMMIT = r"[0-9a-f]{40}"


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def clean_checkout(commit: str) -> None:
    if not re.fullmatch(COMMIT, commit) or git("rev-parse", "HEAD") != commit:
        raise ValueError("Release checks require the exact checked-out commit")
    if git("status", "--porcelain"):
        raise ValueError("Commit source changes before checking or publishing releases")


def notes(mod: dict) -> str:
    text = (mod["source"] / "CHANGELOG.md").read_text(encoding="utf-8")
    headings = list(re.finditer(r"^## (.+)$", text, re.M))
    numbered = []
    for index, heading in enumerate(headings):
        end = headings[index + 1].start() if index + 1 < len(headings) else len(text)
        content = re.sub(r"<!--.*?-->", "", text[heading.end():end], flags=re.S).strip()
        if heading[1] in {"Unreleased", "未发布"} and content:
            raise ValueError(f"{mod['slug']}: release still contains Unreleased changes")
        match = re.fullmatch(rf"({VERSION})(?: - \d{{4}}-\d{{2}}-\d{{2}})?", heading[1])
        if match:
            numbered.append((match[1], content))
    versions = [version for version, _ in numbered]
    if (not versions or versions[0] != mod["version"]
            or len(versions) != len(set(versions)) or not numbered[0][1]):
        raise ValueError(f"{mod['slug']}: current version needs one nonempty top numbered CHANGELOG entry")
    return numbered[0][1]


def release_inputs(mod: dict, commit: str) -> str:
    if not re.fullmatch(COMMIT, commit):
        raise ValueError("Release inputs require an exact commit")
    paths = [f"{mod['slug']}-mod/", "tools/", ".github/workflows/", ".gitattributes"]
    tree = subprocess.check_output(["git", "ls-tree", "-r", "-z", commit, "--", *paths], cwd=ROOT)
    if not tree:
        raise ValueError("No tracked release inputs")
    return sha256(tree).hexdigest()


def approval_path(mod: dict) -> Path:
    return ROOT / "releases/approvals" / f"{mod['slug']}-v{mod['version']}.json"


def record_approval(slug: str, authorization: str, prerelease: bool = False) -> None:
    if slug not in ci.MODS or not authorization or not authorization.strip():
        raise ValueError("Provide a known Mod and an explicit maintainer authorization summary")
    commit = git("rev-parse", "HEAD")
    clean_checkout(commit)
    mod = ci.config(slug)
    ci.validate_config(mod)
    if not re.fullmatch(VERSION, mod["version"]):
        raise ValueError("Development packages cannot be approved; first assign a numbered version")
    notes(mod)
    record = {"schema": 1, "mod": slug, "version": mod["version"], "prerelease": prerelease,
              "sourceCommit": commit, "inputsSha256": release_inputs(mod, commit),
              "authorization": authorization.strip()}
    path = approval_path(mod)
    path.parent.mkdir(parents=True, exist_ok=True)
    # Exclusive creation preserves an existing approval for review/history.
    with path.open("x", encoding="utf-8", newline="\n") as stream:
        stream.write(json.dumps(record, ensure_ascii=False, indent=2) + "\n")
    print(f"Review and commit {path.relative_to(ROOT)}. Recording does not grant authorization or publish.")


def authorized(mod: dict, commit: str) -> dict | None:
    path = approval_path(mod)
    if not path.exists():
        return None
    record = json.loads(path.read_text(encoding="utf-8"))
    fields = {"schema", "mod", "version", "prerelease", "sourceCommit", "inputsSha256", "authorization"}
    if (not isinstance(record, dict) or set(record) != fields
            or type(record["schema"]) is not int or record["schema"] != 1
            or record["mod"] != mod["slug"] or record["version"] != mod["version"]
            or type(record["prerelease"]) is not bool
            or not isinstance(record["authorization"], str) or not record["authorization"].strip()
            or not isinstance(record["sourceCommit"], str) or not re.fullmatch(COMMIT, record["sourceCommit"])
            or not isinstance(record["inputsSha256"], str) or not re.fullmatch(r"[0-9a-f]{64}", record["inputsSha256"])):
        raise ValueError(f"{mod['slug']}: invalid release approval record")
    notes(mod)
    if record["inputsSha256"] != release_inputs(mod, commit):
        raise ValueError(f"{mod['slug']}: release inputs changed after approval")
    return record


def version_key(version: str) -> tuple[int, ...]:
    return tuple(map(int, version.split(".")))


def changed_since_release(mod: dict, commit: str, published: list[dict]) -> bool:
    prefix = f"{mod['slug']}-v"
    tags = [item["tag_name"] for item in published if not item["draft"]
            and item["tag_name"].startswith(prefix) and re.fullmatch(VERSION, item["tag_name"][len(prefix):])]
    directory = f"{mod['slug']}-mod/"
    if not tags:
        return bool(git("ls-tree", "-r", "--name-only", commit, "--", directory))
    latest = max(tags, key=lambda tag: version_key(tag[len(prefix):]))
    if version_key(latest[len(prefix):]) > version_key(mod["version"]):
        raise ValueError(f"Refusing version rollback below {latest}")
    try:
        baseline = git("rev-parse", "--verify", f"refs/tags/{latest}^{{commit}}")
    except subprocess.CalledProcessError as error:
        raise ValueError(f"Missing published tag {latest}; fetch complete history and tags") from error
    result = subprocess.run(["git", "diff", "--quiet", "--no-ext-diff", "--no-textconv",
                             baseline, commit, "--", directory], cwd=ROOT)
    if result.returncode not in (0, 1):
        raise ValueError("Failed to compare Mod directory with published version")
    return result.returncode == 1


def candidates(commit: str, published: list[dict]) -> list[tuple[dict, dict, dict | None]]:
    result = []
    by_tag = {item["tag_name"]: item for item in published}
    for slug in ci.MODS:
        mod = ci.config(slug)
        tag = f"{slug}-v{mod['version']}"
        existing = by_tag.get(tag)
        if existing and not existing["draft"]:
            print(f"Skip published {tag}; preserve tag and assets.")
            continue
        if not re.fullmatch(VERSION, mod["version"]):
            print(f"Skip development package {tag}.")
            continue
        approval = authorized(mod, commit)
        if approval is None:
            print(f"Skip {tag}; no release approval record.")
            continue
        ci.validate_config(mod)
        if not changed_since_release(mod, commit, published):
            print(f"Skip {tag}; Mod directory is unchanged since its last release.")
            continue
        result.append((mod, approval, existing))
    return result


def verify_artifacts(commit: str) -> dict:
    directory = ROOT / "outputs/ci"
    mods = [ci.config(slug) for slug in ci.MODS]
    names = {name for mod in mods for name in (ci.package_path(mod).name, ci.package_path(mod).name + ".sha256")}
    if {path.name for path in directory.iterdir()} != names | {"build-info.json"}:
        raise ValueError("Unexpected or missing CI artifacts")
    for name in names | {"build-info.json"}:
        if (directory / name).is_symlink() or not (directory / name).is_file():
            raise ValueError(f"Non-regular CI artifact: {name}")
    evidence = json.loads((directory / "build-info.json").read_text(encoding="utf-8"))
    generated_mods = {mod["slug"] for mod in mods if mod.get("generated")}
    keys = {"sourceCommit", "mods", "assets"} | ({"generated"} if generated_mods else set())
    if (set(evidence) != keys or evidence["sourceCommit"] != commit
            or evidence["mods"] != {mod["slug"]: mod["version"] for mod in mods}
            or set(evidence["assets"]) != names):
        raise ValueError("CI build evidence does not match release source/versions/assets")
    if set(evidence.get("generated", {})) != generated_mods:
        raise ValueError("CI generated file evidence does not match release source")
    for name in names:
        if sha256((directory / name).read_bytes()).hexdigest() != evidence["assets"][name]:
            raise ValueError(f"CI artifact checksum mismatch: {name}")
    for mod in mods:
        ci.validate_config(mod)
        ci.verify_package(mod, directory / ci.package_path(mod).name,
                          evidence.get("generated", {}).get(mod["slug"]))
    return evidence


def release_assets(mod: dict, approval: dict, commit: str, repository: str) -> dict[str, bytes]:
    name = ci.package_path(mod).name
    data = (ROOT / "outputs/ci" / name).read_bytes()
    evidence = {"repository": repository, "sourceCommit": commit, "mod": mod["slug"],
                "version": mod["version"], "prerelease": approval["prerelease"],
                "inputsSha256": approval["inputsSha256"], "archiveSha256": sha256(data).hexdigest(),
                "validation": "Lua offline tests and package checks; see the Mod DEVELOPMENT.md for in-game validation."}
    files = {name: data, "build-info.json": (json.dumps(evidence, indent=2) + "\n").encode("utf-8")}
    files["SHA256SUMS.txt"] = "".join(f"{sha256(data).hexdigest()}  {name}\n" for name, data in files.items()).encode()
    return files


class AssetRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if urllib.parse.urlparse(newurl).scheme != "https":
            raise ValueError("Refusing non-HTTPS asset redirect")
        result = super().redirect_request(req, fp, code, msg, headers, newurl)
        if result is not None and urllib.parse.urlparse(req.full_url).hostname != urllib.parse.urlparse(newurl).hostname:
            result.remove_header("Authorization")
        return result


class GitHub:
    def __init__(self, repository: str):
        if not re.fullmatch(r"[\w.-]+/[\w.-]+", repository):
            raise ValueError("Invalid repository")
        self.base = f"https://api.github.com/repos/{repository}"
        self.upload_base = f"https://uploads.github.com/repos/{repository}/releases/"
        self.token = os.environ["GH_TOKEN"]
        self.opener = urllib.request.build_opener(AssetRedirect())

    def request(self, path, method="GET", payload=None, raw=False, missing_ok=False):
        url = path if path.startswith("https://") else self.base + path
        if not (url == self.base or url.startswith(self.base + "/") or url.startswith(self.upload_base)):
            raise ValueError("Unexpected GitHub endpoint")
        data = payload if isinstance(payload, bytes) else None if payload is None else json.dumps(payload).encode()
        headers = {"Authorization": f"Bearer {self.token}",
                   "Accept": "application/octet-stream" if raw else "application/vnd.github+json",
                   "X-GitHub-Api-Version": "2022-11-28"}
        if data is not None:
            headers["Content-Type"] = "application/octet-stream" if isinstance(payload, bytes) else "application/json"
        try:
            with self.opener.open(urllib.request.Request(url, data, headers, method=method), timeout=60) as response:
                content = response.read()
                return content if raw else json.loads(content) if content else None
        except urllib.error.HTTPError as error:
            if error.code == 404 and method == "GET" and missing_ok:
                return None
            raise

    def pages(self, path):
        result = []
        for page in range(1, 101):
            batch = self.request(f"{path}?per_page=100&page={page}")
            if not isinstance(batch, list):
                raise ValueError("Invalid GitHub pagination response")
            result.extend(batch)
            if len(batch) < 100:
                return result
        raise ValueError("GitHub pagination limit exceeded")


def tag_commit(api, tag: str) -> str | None:
    ref = api.request(f"/git/ref/tags/{tag}", missing_ok=True)
    if ref is None:
        return None
    obj = ref["object"]
    for _ in range(8):
        if obj["type"] == "commit":
            return obj["sha"]
        if obj["type"] != "tag":
            break
        obj = api.request(f"/git/tags/{obj['sha']}")["object"]
    raise ValueError(f"Invalid release tag: {tag}")


def release_body(mod: dict, commit: str, repository: str) -> str:
    return (f"Source / 源码: `{commit}`\n\n"
            f"[安装与兼容范围](https://github.com/{repository}/blob/{commit}/{mod['slug']}-mod/README.md)\n\n"
            "CI 已通过 Lua 离线测试和安装包校验；实机验收范围见包内 DEVELOPMENT.md。\n\n" + notes(mod))


def check(repository: str) -> None:
    commit = git("rev-parse", "HEAD")
    clean_checkout(commit)
    selected = candidates(commit, GitHub(repository).pages("/releases"))
    for mod, _, _ in selected:
        print(f"Eligible: {mod['slug']}-v{mod['version']}")
    print(f"Release preflight passed: {len(selected)} candidate(s); no GitHub writes.")


def publish(repository: str, commit: str, api=None) -> None:
    clean_checkout(commit)
    api = api or GitHub(repository)
    if api.request("")["private"] is not True:
        raise ValueError("This workflow is configured for a private repository")
    selected = candidates(commit, api.pages("/releases"))
    if not selected:
        print("No authorized new versions to publish.")
        return
    # Validate the complete artifact and every candidate before the first write.
    verify_artifacts(commit)
    prepared = []
    for mod, approval, existing in selected:
        tag = f"{mod['slug']}-v{mod['version']}"
        body = release_body(mod, commit, repository)
        files = release_assets(mod, approval, commit, repository)
        target = tag_commit(api, tag)
        if existing:
            if (existing["target_commitish"] != commit or existing["body"] != body
                    or existing["prerelease"] != approval["prerelease"] or target not in (None, commit)):
                raise ValueError(f"Draft belongs to different source/metadata: {tag}")
            assets = api.pages(f"/releases/{existing['id']}/assets")
            if len({asset["name"] for asset in assets}) != len(assets) or {asset["name"] for asset in assets} - set(files):
                raise ValueError(f"Unexpected assets in release draft: {tag}")
            for asset in assets:
                if api.request(f"/releases/assets/{asset['id']}", raw=True) != files[asset["name"]]:
                    raise ValueError(f"Existing draft asset differs: {asset['name']}")
        else:
            if target is not None:
                raise ValueError(f"Tag exists without a matching release draft: {tag}")
            assets = []
        prepared.append((mod, approval, existing, tag, body, files, assets))
    for mod, approval, existing, tag, body, files, assets in prepared:
        if existing is None:
            existing = api.request("/releases", "POST", {
                "tag_name": tag, "target_commitish": commit, "name": f"{mod['name']} {mod['version']}",
                "body": body, "draft": True, "prerelease": approval["prerelease"], "make_latest": "false"})
        by_name = {asset["name"]: asset for asset in assets}
        for name, data in files.items():
            asset = by_name.get(name)
            if asset is None:
                url = existing["upload_url"].split("{")[0] + "?name=" + urllib.parse.quote(name)
                asset = api.request(url, "POST", data)
            if api.request(f"/releases/assets/{asset['id']}", raw=True) != data:
                raise ValueError(f"Uploaded asset differs: {name}. Draft preserved for inspection.")
        # Re-read the draft before exposing it, including all assets and any newly created tag.
        current = api.request(f"/releases/{existing['id']}")
        remote_names = [asset["name"] for asset in api.pages(f"/releases/{existing['id']}/assets")]
        if (not current["draft"] or current["tag_name"] != tag or current["target_commitish"] != commit
                or current["body"] != body or current["prerelease"] != approval["prerelease"]
                or len(remote_names) != len(files) or set(remote_names) != set(files)
                or tag_commit(api, tag) not in (None, commit)):
            raise ValueError(f"Draft changed during publication: {tag}")
        api.request(f"/releases/{existing['id']}", "PATCH", {"draft": False, "make_latest": "false"})
        if tag_commit(api, tag) != commit:
            raise ValueError(f"Published tag does not resolve to the expected source: {tag}")
        print(f"Published {tag} at {commit}.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["check", "publish", "record-approval"])
    parser.add_argument("--repository")
    parser.add_argument("--commit")
    parser.add_argument("--mod", choices=ci.MODS)
    parser.add_argument("--authorization")
    parser.add_argument("--prerelease", action="store_true")
    args = parser.parse_args()
    if args.command == "record-approval":
        if not args.mod or not args.authorization:
            parser.error("record-approval requires --mod and --authorization")
        record_approval(args.mod, args.authorization, args.prerelease)
    else:
        if not args.repository or (args.command == "publish" and not args.commit):
            parser.error("--repository is required; publish also requires --commit")
        if args.command == "check":
            check(args.repository)
        else:
            publish(args.repository, args.commit)


if __name__ == "__main__":
    main()
