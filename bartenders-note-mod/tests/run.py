"""Run the original Lua contracts in an isolated Lua 5.4 VM per spec."""

from pathlib import Path

from lupa.lua54 import LuaRuntime


MOD = Path(__file__).resolve().parents[1]
for source in sorted((MOD / "Scripts").glob("*.lua")):
    LuaRuntime().compile(source.read_text(encoding="utf-8"), name=str(source))
print("All Lua modules compile with Lua 5.4.", flush=True)

for spec in sorted((MOD / "tests").glob("*_spec.lua")):
    runtime = LuaRuntime()
    runtime.globals().spec_path = spec.as_posix()
    runtime.execute("dofile(spec_path)")
print("All offline specs passed; Unreal integration still requires in-game testing.")
