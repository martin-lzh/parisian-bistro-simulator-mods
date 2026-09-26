"""Validate, test and package original mods without game files or UE4SS."""

import argparse
from hashlib import sha256
import json
from pathlib import Path, PurePosixPath
import re
import runpy
import shutil
import subprocess
import sys
from zipfile import ZipFile


ROOT = Path(__file__).resolve().parents[1]
MODS = {"bartenders-note": "BartendersNote", "auto-checkout": "AutoCheckout",
        "fresh-to-serve": "FreshToServe", "first-to-serve": "FirstToServe",
        "smart-delivery": "SmartDelivery", "scan-to-order": "ScanToOrder",
        "auto-menu": "AutoMenu"}
NATIVE = {
    "smart-delivery": ("Scripts/delivery_bridge.dll", {"native_build.py", "Native/bridge.cpp", "Native/dispatch.hpp",
        "Native/pe_image.hpp", "Native/contract.hpp", "Native/tests.cpp", "Native/probe.asm"}),
    "auto-menu": ("Scripts/auto_menu_bridge.dll", {"native_build.py", "Native/bridge.cpp", "Native/search.hpp",
        "Native/pe_image.hpp", "Native/contract.hpp", "Native/tests.cpp"}),
}


def run(*args: str) -> None:
    subprocess.run(args, cwd=ROOT, check=True)


def config(slug: str) -> dict:
    namespace = runpy.run_path(str(ROOT / f"{slug}-mod/build.py"))
    return {"slug": slug, "name": MODS[slug], "version": namespace["VERSION"],
            "source": namespace["SOURCE"], "output": namespace["OUTPUT"],
            "files": namespace["FILES"], "generated": namespace.get("GENERATED_FILES", {})}


def validate_config(mod: dict) -> None:
    version = mod["version"]
    if not re.fullmatch(r"\d+\.\d+\.\d+(?:-dev)?", version):
        raise ValueError(f"Invalid version: {version}")
    source = mod["source"]
    changelog = (source / "CHANGELOG.md").read_text(encoding="utf-8")
    if "-dev" not in version and not re.search(
        rf"^## {re.escape(version)}(?: - \d{{4}}-\d{{2}}-\d{{2}})?$", changelog, re.M
    ):
        raise ValueError(f"{mod['slug']}: missing numbered CHANGELOG entry")
    if version not in (source / "README.md").read_text(encoding="utf-8"):
        raise ValueError(f"{mod['slug']}: README version is missing")
    diagnostics = source / "Scripts/diagnostics.lua"
    if diagnostics.is_file():
        match = re.search(r"Diagnostics\.VERSION = '([^']+)'", diagnostics.read_text(encoding="utf-8"))
        if not match or match[1] != version:
            raise ValueError(f"{mod['slug']}: diagnostic and package versions disagree")
    files = mod["files"]
    if len(files) != len(set(files)):
        raise ValueError("Duplicate package input")
    tracked = set(subprocess.check_output(
        ["git", "ls-files", "-z"], cwd=ROOT
    ).decode("utf-8").split("\0"))
    for name in files:
        path = PurePosixPath(name)
        if (path.is_absolute() or ".." in path.parts or "\\" in name
                or not ((len(path.parts) == 2 and path.parts[0] == "Scripts" and path.suffix == ".lua")
                        or name in {"README.md", "DEVELOPMENT.md", "CHANGELOG.md", "LICENSE"})):
            raise ValueError(f"Disallowed package input: {name}")
        original = source / name
        if (original.is_symlink() or not original.is_file()
                or not original.resolve().is_relative_to(source.resolve())
                or original.relative_to(ROOT).as_posix() not in tracked):
            raise ValueError(f"Missing, linked or untracked package input: {name}")
    required = {p.relative_to(source).as_posix() for p in (source / "Scripts").glob("*.lua")}
    required.update({"README.md", "DEVELOPMENT.md", "CHANGELOG.md", "LICENSE"})
    if set(files) != required:
        raise ValueError(f"{mod['slug']}: package allowlist must cover all Lua modules, user docs and LICENSE")
    license_path = ROOT / "LICENSE"
    if license_path.is_symlink() or not license_path.is_file() or "LICENSE" not in tracked:
        raise ValueError("Repository LICENSE must be a tracked regular file")
    license_text = license_path.read_bytes().replace(b"\r\n", b"\n")
    if (source / "LICENSE").read_bytes().replace(b"\r\n", b"\n") != license_text:
        raise ValueError(f"{mod['slug']}: LICENSE must match the repository MIT license")
    generated = mod.get("generated", {})
    if mod["slug"] in NATIVE and not generated:
        raise ValueError("Native helper must be included in the package")
    if generated:
        native = NATIVE.get(mod["slug"])
        if not native or set(generated) != {native[0]}:
            raise ValueError("Disallowed generated package input")
        for path in generated.values():
            if path.is_symlink() or not path.resolve().is_relative_to((ROOT / "outputs" / mod["slug"] / "native").resolve()):
                raise ValueError("Generated input must stay in the native build output")
        if any((source / name).relative_to(ROOT).as_posix() not in tracked for name in native[1]):
            raise ValueError("Native build sources must be tracked")


def package_path(mod: dict) -> Path:
    return mod["output"] / f"{mod['name']}-{mod['version']}.zip"


def verify_package(mod: dict, archive: Path, generated_hashes: dict | None = None) -> None:
    expected = {f"{mod['name']}/{name}": (mod["source"] / name).read_bytes().replace(b"\r\n", b"\n")
                for name in mod["files"]}
    expected[f"{mod['name']}/enabled.txt"] = b""
    generated = mod.get("generated", {})
    if generated_hashes is not None and set(generated_hashes) != set(generated):
        raise ValueError("Generated file evidence does not match the allowlist")
    if generated_hashes is None:
        generated_hashes = {name: sha256(path.read_bytes()).hexdigest() for name, path in generated.items()}
    for name in generated:
        expected[f"{mod['name']}/{name}"] = None
    with ZipFile(archive) as package:
        if len(package.namelist()) != len(expected) or set(package.namelist()) != set(expected):
            raise ValueError(f"{archive.name}: unexpected, duplicate or missing package entries")
        if package.testzip() is not None:
            raise ValueError(f"{archive.name}: ZIP integrity check failed")
        for entry in package.infolist():
            if entry.external_attr >> 16 & 0o170000 != 0o100000:
                raise ValueError(f"Non-regular package entry: {entry.filename}")
            data = package.read(entry)
            if expected[entry.filename] is None:
                name = entry.filename.split("/", 1)[1]
                if sha256(data).hexdigest() != generated_hashes[name]:
                    raise ValueError(f"Generated package content mismatch: {name}")
            elif data != expected[entry.filename]:
                raise ValueError(f"Package differs from source: {entry.filename}")
    digest = sha256(archive.read_bytes()).hexdigest()
    checksum = archive.with_suffix(".zip.sha256").read_text(encoding="utf-8")
    if checksum != f"{digest}  {archive.name}\n":
        raise ValueError(f"{archive.name}: SHA-256 file mismatch")
    print(f"Verified {archive.name}: {len(expected)} original files, SHA-256 {digest}")


def validate() -> None:
    for slug in MODS:
        validate_config(config(slug))
    print("All mod versions and package inputs validated.")


def build() -> None:
    validate()
    output = ROOT / "outputs/ci"
    output.mkdir(parents=True, exist_ok=True)
    assets = []
    for slug in MODS:
        mod = config(slug)
        run("uv", "run", "--with", "lupa==2.6", "python", f"{slug}-mod/tests/run.py")
        run(sys.executable, f"{slug}-mod/build.py")
        archive = package_path(mod)
        verify_package(mod, archive)
        for source in (archive, archive.with_suffix(".zip.sha256")):
            shutil.copyfile(source, output / source.name)
            assets.append(source.name)
    evidence = {"sourceCommit": subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
        "mods": {slug: config(slug)["version"] for slug in MODS},
        "assets": {name: sha256((output / name).read_bytes()).hexdigest() for name in assets}}
    evidence["generated"] = {slug: {name: sha256(path.read_bytes()).hexdigest()
                                    for name, path in config(slug)["generated"].items()}
                             for slug in MODS if config(slug)["generated"]}
    (output / "build-info.json").write_text(
        json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    # Upload only current named files; old local packages must not enter CI artifacts.
    actual = {path.name for path in output.iterdir()}
    if actual != set(assets) | {"build-info.json"}:
        raise ValueError("outputs/ci contains stale or unexpected files; use an empty CI output directory")
    print(f"CI packages: {output}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["validate", "build"])
    args = parser.parse_args()
    {"validate": validate, "build": build}[args.command]()


if __name__ == "__main__":
    main()
