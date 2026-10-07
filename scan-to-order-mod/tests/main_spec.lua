local Game, fixture = require('game'), require('fixture')
local f, shared, queued, runtime, off_thread, fail_write
local original_session, original_contract = Game.session, Game.contract
Game.contract = function() assert(not off_thread); return original_contract() end
Game.session = function(...) assert(not off_thread); return original_session(...) end
local function reset()
    f, shared, queued, off_thread, fail_write = fixture(), {}, {}, false, false
end
local function boot(direct)
    local r = {}
    ModRef = {
        GetSharedVariable = function(_, key) return shared[key] end,
        SetSharedVariable = function(_, key, value)
            assert(type(value) == 'string')
            if fail_write then error('shared state unavailable') end
            shared[key] = value
        end,
    }
    r.mod = ModRef
    LoopInGameThreadWithDelay = direct and function(delay, fn)
        assert(delay == 1000); r.tick = fn; return 123
    end or nil
    CancelDelayedAction = function(handle) assert(handle == 123); r.cancelled = true end
    LoopAsync = function(delay, fn) assert(delay == 1000); r.loop = fn end
    ExecuteInGameThread = function(fn) queued[#queued + 1] = fn end
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    return r
end
local function unload(r)
    off_thread = true; r.mod.OnUnload(); off_thread = false
end

-- Missing/ambiguous reflection stops before any order and keeps the safety
-- marker across reload even if reflection becomes available in the meantime.
for _, ambiguous in ipairs({ false, true }) do
    reset()
    if ambiguous then
        local other = f.object('Class /Script/BrasserieSimulator.Table')
        other.short_name, other.is_class = 'Table', true
        f.reflection['/Script/BrasserieSimulator.Table'] = other
    else
        f.reflection['/Script/BrasserieSimulator.table'] = nil
    end
    runtime = boot(true); runtime.tick()
    assert(#f.calls == 0 and shared['ScanToOrder.StopWorld'] == '*')
    unload(runtime)
    f.reflection['/Script/BrasserieSimulator.Table'] = nil
    f.reflection['/Script/BrasserieSimulator.table'] = f.api.table_class
    runtime = boot(true); runtime.tick()
    assert(#f.calls == 0 and shared['ScanToOrder.StopWorld'] == '*')
    unload(runtime)
end

reset(); f.stock[12] = 0
runtime = boot(true); runtime.tick(); assert(#f.calls == 1)
unload(runtime); assert(runtime.cancelled and runtime.tick() == true)
runtime = boot(true); runtime.tick(); assert(#f.calls == 1)
f.stock[12] = 1; runtime.tick(); assert(#f.calls == 2)
unload(runtime); runtime = boot(true); runtime.tick(); assert(#f.calls == 2)

reset(); f.throw_after_accept = true
runtime = boot(true); runtime.tick(); assert(#f.calls == 1)
unload(runtime); runtime = boot(true); runtime.tick(); assert(#f.calls == 1)
f.controller.Pawn = nil; runtime.tick(); f.controller.Pawn = f.player
f.throw_after_accept = false; runtime.tick(); assert(#f.calls == 1)
-- Even changing possession in the same world does not clear a safety stop.
f.player.name = 'respawn'; runtime.tick(); assert(#f.calls == 1)
local player_class = f.api.player
f = fixture(); f.api.player, f.player.class = player_class, player_class
f.world.name = 'new-world'; runtime.tick(); assert(#f.calls == 2)

reset(); fail_write = true
runtime = boot(true); runtime.tick(); assert(#f.calls == 0)
reset(); runtime = boot(true)
local original = f.drinks.TryOrderDrink
function f.drinks:TryOrderDrink(...) original(self, ...); fail_write = true end
runtime.tick(); assert(#f.calls == 2 and shared['ScanToOrder.StopWorld'] ~= '')
unload(runtime); fail_write = false; runtime = boot(true); runtime.tick(); assert(#f.calls == 2)

reset(); runtime = boot(false)
runtime.loop(); runtime.loop(); assert(#queued == 1 and #f.calls == 0)
unload(runtime); assert(runtime.loop() == true)
runtime = boot(false); runtime.loop(); assert(#queued == 2)
queued[1](); assert(#f.calls == 0)
queued[2](); assert(#f.calls == 2)
unload(runtime); assert(runtime.loop() == true)
print('main_spec: reload, replenishment, uncertain outcomes, persistence and callback lifecycle passed')
