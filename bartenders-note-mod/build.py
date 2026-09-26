"""Package only the original Lua mod and its user documentation."""

from hashlib import sha256
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo


VERSION = "0.1.2-dev"
SOURCE = Path(__file__).resolve().parent
OUTPUT = SOURCE.parent / "outputs" / "bartenders-note"
# An explicit list prevents local game references and development tools from
# entering a package even if they are present next to the sources.
FILES = (
    "Scripts/main.lua",
    "Scripts/reload.lua",
    "Scripts/game.lua",
    "Scripts/hud.lua",
    "Scripts/layout.lua",
    "Scripts/localization.lua",
    "Scripts/summary.lua",
    "README.md",
    "DEVELOPMENT.md",
    "CHANGELOG.md",
    "LICENSE",
)


def build() -> Path:
    payload = {}
    for name in FILES:
        source = SOURCE / name
        if source.is_symlink() or not source.is_file():
            raise ValueError(f"Missing or linked package input: {name}")
        if not source.resolve().is_relative_to(SOURCE):
            raise ValueError(f"Package input escapes mod directory: {name}")
        payload[f"BartendersNote/{name}"] = source.read_bytes().replace(b"\r\n", b"\n")
    # UE4SS recognizes this empty marker without editing the user's mods.txt.
    payload["BartendersNote/enabled.txt"] = b""
    OUTPUT.mkdir(parents=True, exist_ok=True)
    archive = OUTPUT / f"BartendersNote-{VERSION}.zip"
    with ZipFile(archive, "w", compression=ZIP_DEFLATED) as package:
        for name, data in sorted(payload.items()):
            info = ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            package.writestr(info, data)
    checksum = sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(
        f"{checksum}  {archive.name}\n", encoding="utf-8"
    )
    print(archive)
    print(f"SHA-256: {checksum}")
    return archive


if __name__ == "__main__":
    build()
