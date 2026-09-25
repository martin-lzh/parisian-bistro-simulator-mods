"""Run isolated Lua 5.4 behavior tests, without game files or UE4SS."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1]
for name in ("remake_spec.lua", "game_spec.lua", "drinks_spec.lua", "reload_spec.lua", "main_spec.lua"):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().MOD_ROOT = root.as_posix()
    lua.execute("package.path = MOD_ROOT .. '/Scripts/?.lua;' .. MOD_ROOT .. '/tests/?.lua;' .. package.path")
    lua.execute((root / "tests" / name).read_text(encoding="utf-8"))
