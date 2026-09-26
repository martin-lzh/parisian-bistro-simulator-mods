"""Run offline Lua behavior tests without loading the native helper or game."""
from pathlib import Path
import tempfile
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1]
output = root.parent / "outputs/smart-delivery/tests"
output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(dir=output) as directory:
    assert Path(directory).resolve().is_relative_to(output.resolve())
    for path in sorted((root / "tests").glob("*_spec.lua")):
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.globals().MOD_ROOT = root.as_posix()
        lua.globals().TEST_DIR = Path(directory).as_posix()
        lua.execute("package.path = MOD_ROOT .. '/Scripts/?.lua;' .. MOD_ROOT .. '/tests/?.lua;' .. package.path")
        lua.execute(path.read_text(encoding="utf-8"))
        print(f"PASS {path.name}")
