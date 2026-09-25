"""Build Smart Delivery from original Lua and native source without installing."""
from hashlib import sha256
from pathlib import Path
import runpy
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

VERSION = "0.1.4-dev"
SOURCE = Path(__file__).resolve().parent
OUTPUT = SOURCE.parent / "outputs/smart-delivery"
FILES = ("Scripts/main.lua", "Scripts/reload.lua", "Scripts/ui.lua", "Scripts/bridge.lua", "Scripts/settings.lua",
         "Scripts/localization.lua", "README.md", "DEVELOPMENT.md", "CHANGELOG.md")
GENERATED_FILES = {"Scripts/delivery_bridge.dll": OUTPUT / "native/delivery_bridge.dll"}


def build() -> Path:
    runpy.run_path(str(SOURCE / "native_build.py"))["build"]()
    payload = {}
    for name in FILES:
        path = SOURCE / name
        if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(SOURCE):
            raise ValueError(f"Missing or linked input: {name}")
        payload[f"SmartDelivery/{name}"] = path.read_bytes().replace(b"\r\n", b"\n")
    for name, path in GENERATED_FILES.items():
        if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(OUTPUT):
            raise ValueError(f"Missing or linked generated input: {name}")
        payload[f"SmartDelivery/{name}"] = path.read_bytes()
    payload["SmartDelivery/enabled.txt"] = b""
    archive = OUTPUT / f"SmartDelivery-{VERSION}.zip"
    with ZipFile(archive, "w", compression=ZIP_DEFLATED) as package:
        for name, data in sorted(payload.items()):
            info = ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            package.writestr(info, data)
    digest = sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(f"{digest}  {archive.name}\n", encoding="utf-8")
    print(f"{archive}\nSHA-256: {digest}")
    return archive


if __name__ == "__main__":
    build()
