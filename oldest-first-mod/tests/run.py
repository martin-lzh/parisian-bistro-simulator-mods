"""Run original offline Lua tests without the game or UE4SS."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1]
for path in sorted((root / "tests").glob("*_spec.lua")):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().MOD_ROOT = root.as_posix()
    lua.execute("package.path = MOD_ROOT .. '/Scripts/?.lua;' .. MOD_ROOT .. '/tests/?.lua;' .. package.path")
    lua.execute(path.read_text(encoding="utf-8"))
    print(f"PASS {path.name}")
