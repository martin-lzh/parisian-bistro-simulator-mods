"""Run original Lua behavior tests without loading the game or UE4SS."""

from pathlib import Path
from lupa.lua54 import LuaRuntime


root = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().MOD_ROOT = root.as_posix()
lua.execute("package.path = MOD_ROOT .. '/Scripts/?.lua;' .. package.path")
for name in ("checkout_spec.lua", "game_spec.lua", "ai_spec.lua", "diagnostics_spec.lua", "main_spec.lua",
             "notification_spec.lua", "runtime_ai_spec.lua"):
    lua.execute((root / "tests" / name).read_text(encoding="utf-8"))
