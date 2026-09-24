"""Build and exercise the original Windows helper; never touch a game install."""
import os
from pathlib import Path
import subprocess

SOURCE = Path(__file__).resolve().parent
OUTPUT = SOURCE.parent / "outputs/smart-delivery/native"
DLL = OUTPUT / "delivery_bridge.dll"


def build() -> Path:
    if os.name != "nt":
        raise RuntimeError("The native helper requires Windows x64 and MSVC Build Tools")
    vswhere = Path(os.environ.get("ProgramFiles(x86)", "C:/Program Files (x86)")) / "Microsoft Visual Studio/Installer/vswhere.exe"
    install = subprocess.check_output([str(vswhere), "-latest", "-products", "*", "-requires",
                                      "Microsoft.VisualStudio.Component.VC.Tools.x86.x64", "-property",
                                      "installationPath"], text=True).strip()
    if not install:
        raise RuntimeError("Install Visual Studio C++ x64 Build Tools and the Windows SDK")
    developer = Path(install) / "Common7/Tools/VsDevCmd.bat"
    OUTPUT.mkdir(parents=True, exist_ok=True)
    # One generated batch file establishes MSVC's environment. All inputs are
    # explicit project paths, quoted for cmd; there are no filesystem removals.
    for path in (SOURCE, OUTPUT, developer):
        if any(c in str(path) for c in ('"', '%', '\n', '\r')):
            raise ValueError("Unsupported build path")
    script = OUTPUT / "compile.cmd"
    native = SOURCE / "Native"
    script.write_text(
        f'@echo off\ncall "{developer}" -arch=x64 -host_arch=x64 >nul\nif errorlevel 1 exit /b 1\n'
        f'cl /nologo /std:c++17 /EHsc /W4 /WX /O2 /MT /LD "{native / "bridge.cpp"}" '
        '/link bcrypt.lib /OUT:delivery_bridge.dll /Brepro\nif errorlevel 1 exit /b 1\n'
        f'ml64 /nologo /c /Foprobe.obj "{native / "probe.asm"}"\nif errorlevel 1 exit /b 1\n'
        f'cl /nologo /std:c++17 /EHsc /W4 /WX /O2 /MT "{native / "tests.cpp"}" probe.obj '
        '/Fe:native_tests.exe /link /Brepro\nif errorlevel 1 exit /b 1\n'
        'native_tests.exe\nexit /b %errorlevel%\n', encoding="utf-8")
    subprocess.run(["cmd.exe", "/d", "/c", str(script)], cwd=OUTPUT, check=True)
    # Running the bridge in Python must refuse this non-game executable without
    # applying any patch. A child process releases the DLL before a later build.
    subprocess.run([os.sys.executable, "-c",
                    "import ctypes,sys; d=ctypes.CDLL(sys.argv[1]); "
                    "assert d.delivery_initialize(None)==0", str(DLL)], check=True)
    result = (OUTPUT / "bridge-status.txt").read_text(encoding="utf-8")
    if not result.startswith("error: Unsupported game"):
        raise RuntimeError(f"Compatibility rejection failed: {result}")
    print("PASS native bridge rejects a non-game executable")
    return DLL


if __name__ == "__main__":
    build()
