"""Build an original-source-only UE4SS package without installing it."""

from hashlib import sha256
from pathlib import Path
import runpy
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


VERSION = "0.5.0"
SOURCE = Path(__file__).resolve().parent
OUTPUT = SOURCE.parent / "outputs" / "auto-menu"
FILES = (
    "Scripts/main.lua",
    "Scripts/game.lua",
    "Scripts/bridge.lua",
    "Scripts/planner.lua",
    "Scripts/ui.lua",
    "Scripts/reload.lua",
    "Scripts/localization.lua",
    "README.md",
    "DEVELOPMENT.md",
    "CHANGELOG.md",
    "LICENSE",
)
GENERATED_FILES = {"Scripts/auto_menu_bridge.dll": OUTPUT / "native/auto_menu_bridge.dll"}


def build() -> Path:
    runpy.run_path(str(SOURCE / "native_build.py"))["build"]()
    payload = {}
    for name in FILES:
        source = SOURCE / name
        if source.is_symlink() or not source.is_file():
            raise ValueError(f"Missing or linked package input: {name}")
        if not source.resolve().is_relative_to(SOURCE):
            raise ValueError(f"Package input escapes mod directory: {name}")
        payload[f"AutoMenu/{name}"] = source.read_bytes().replace(b"\r\n", b"\n")
    for name, path in GENERATED_FILES.items():
        if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(OUTPUT):
            raise ValueError(f"Missing or linked generated input: {name}")
        payload[f"AutoMenu/{name}"] = path.read_bytes()
    payload["AutoMenu/enabled.txt"] = b""
    OUTPUT.mkdir(parents=True, exist_ok=True)
    archive = OUTPUT / f"AutoMenu-{VERSION}.zip"
    with ZipFile(archive, "w", compression=ZIP_DEFLATED) as package:
        for name, data in sorted(payload.items()):
            info = ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            package.writestr(info, data)
    digest = sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(
        f"{digest}  {archive.name}\n", encoding="utf-8"
    )
    print(archive)
    print(f"SHA-256: {digest}")
    return archive


if __name__ == "__main__":
    build()
