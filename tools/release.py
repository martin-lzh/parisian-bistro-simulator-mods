"""Describe this repository's Mods to tools/modrelease.py and check CI packages before upload."""

from hashlib import sha256
import json
import re
import subprocess

import ci
import modrelease


ROOT = ci.ROOT
GAME = "Parisian Bistro Simulator 1.0.2.44eb (Windows) · UE4SS experimental v3.0.1-1140-gf58e8f84"


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def changelog(mod: dict) -> tuple[str | None, bool]:
    """Return the entry for the current version and whether Unreleased has content."""
    text = (mod["source"] / "CHANGELOG.md").read_text(encoding="utf-8")
    headings = list(re.finditer(r"^## (.+)$", text, re.M))
    notes, unreleased = None, False
    for index, heading in enumerate(headings):
        end = headings[index + 1].start() if index + 1 < len(headings) else len(text)
        content = re.sub(r"<!--.*?-->", "", text[heading.end():end], flags=re.S).strip()
        title = heading[1].strip()
        if title in {"Unreleased", "未发布"}:
            unreleased = unreleased or bool(content)
        elif notes is None and re.match(rf"{re.escape(mod['version'])}(?:\s|$)", title):
            notes = f"## {title}\n\n{content}" if content else None
    return notes, unreleased


def release_mods(repository: str) -> list[modrelease.ModRelease]:
    mods = []
    for slug in ci.MODS:
        mod = ci.config(slug)
        notes, unreleased = changelog(mod)
        mods.append(modrelease.ModRelease(
            slug=slug, display_name=mod["display_name"], version=mod["version"], prerelease=mod["prerelease"],
            notes=notes, unreleased=unreleased, assets=(ROOT / "outputs/ci" / ci.package_path(mod).name,),
            summary=GAME, readme_url=f"https://github.com/{repository}/blob/main/{slug}-mod/README.md"))
    return mods


def verify_artifacts(commit: str) -> None:
    """The CI artifact must hold exactly the current packages, built from this commit."""
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


def plan(repository: str) -> list[modrelease.Decision]:
    return modrelease.check(modrelease.GitHub(repository), release_mods(repository))


def publish(repository: str, commit: str, api=None) -> None:
    if git("rev-parse", "HEAD") != commit or git("status", "--porcelain"):
        raise ValueError("Publishing requires a clean checkout of the release commit")
    verify_artifacts(commit)
    modrelease.publish(api or modrelease.GitHub(repository), release_mods(repository), commit)
