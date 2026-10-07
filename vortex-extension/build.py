"""Package the original Vortex extension without installing it."""

from hashlib import sha256
import json
from pathlib import Path
import struct
from zipfile import ZIP_DEFLATED, ZipFile


def main() -> None:
    source = Path(__file__).resolve().parent
    info = json.loads((source / "info.json").read_text(encoding="utf-8"))
    artwork = (source / "gameart.png").read_bytes()
    if artwork[:8] != b"\x89PNG\r\n\x1a\n" or struct.unpack(">II", artwork[16:24]) != (640, 360):
        raise ValueError("gameart.png must be a 640x360 PNG")
    if len(artwork) > 1_000_000:
        raise ValueError("gameart.png exceeds the Vortex 1 MB limit")
    output = source.parent / "outputs" / "vortex-extension"
    output.mkdir(parents=True, exist_ok=True)
    archive = output / f"ParisianBistroSimulator-Vortex-{info['version']}.zip"
    allowlist = ("index.js", "installer.js", "info.json", "gameart.png", "README.md", "LICENSE")
    with ZipFile(archive, "w", ZIP_DEFLATED, compresslevel=9) as package:
        for name in allowlist:
            package.write(source / name, name)
    with ZipFile(archive) as package:
        assert set(package.namelist()) == set(allowlist)
        for name in allowlist:
            assert package.read(name) == (source / name).read_bytes()
    digest = sha256(archive.read_bytes()).hexdigest()
    (output / "SHA256SUMS.txt").write_text(f"{digest}  {archive.name}\n", encoding="utf-8")
    print(f"{archive}\nSHA256 {digest}")


if __name__ == "__main__":
    main()
