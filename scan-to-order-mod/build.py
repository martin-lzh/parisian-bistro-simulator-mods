"""Build Scan to Order from original sources without installing it."""
from hashlib import sha256
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

VERSION = "0.1.1-dev"
SOURCE = Path(__file__).resolve().parent
OUTPUT = SOURCE.parent / "outputs" / "scan-to-order"
FILES = ("Scripts/main.lua", "Scripts/game.lua", "README.md", "DEVELOPMENT.md", "CHANGELOG.md")


def build() -> Path:
    payload = {}
    for name in FILES:
        source = SOURCE / name
        if source.is_symlink() or not source.is_file() or not source.resolve().is_relative_to(SOURCE):
            raise ValueError(f"Missing, linked or outside package input: {name}")
        payload[f"ScanToOrder/{name}"] = source.read_bytes().replace(b"\r\n", b"\n")
    payload["ScanToOrder/enabled.txt"] = b""
    OUTPUT.mkdir(parents=True, exist_ok=True)
    archive = OUTPUT / f"ScanToOrder-{VERSION}.zip"
    with ZipFile(archive, "w", compression=ZIP_DEFLATED) as package:
        for name, data in sorted(payload.items()):
            info = ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            package.writestr(info, data)
    digest = sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(f"{digest}  {archive.name}\n", encoding="utf-8")
    print(archive)
    print(f"SHA-256: {digest}")
    return archive


if __name__ == "__main__":
    build()
