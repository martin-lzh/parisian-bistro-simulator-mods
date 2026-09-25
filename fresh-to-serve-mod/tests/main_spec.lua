-- Exercise real adapters and remake state across replacement runtime closures.
local Game, Reload = require('game'), require('reload')
local fixture, drinks = require('fixture'), require('drink_fixture')
local f, shared, writes, fail_from, scans, contracts, off_thread
local queued, logs, handles, cancelled = {}, {}, {}, {}
local old_print = print
print = function(message) logs[#logs + 1] = message end
local game_session, game_candidates = Game.session, Game.candidates
Game.contract = function() assert(not off_thread); contracts = contracts + 1; return f.api end
Game.session = function(api) assert(not off_thread); return game_session(api) end
Game.candidates = function(...)
    assert(not off_thread); scans = scans + 1; return game_candidates(...)
end

local function reset(factory)
    f, shared, writes, fail_from = (factory or fixture)(), {}, 0, nil
    queued, logs, handles, cancelled = {}, {}, {}, {}
    scans, contracts, off_thread = 0, 0, false
end

local function boot(direct)
    local mod = {}
    function mod:GetSharedVariable(key) return shared[key] end
    function mod:SetSharedVariable(key, value)
        assert(key == 'FreshToServe.ReloadState' and type(value) == 'string')
        writes = writes + 1
        if fail_from and writes >= fail_from then error('shared storage unavailable') end
        shared[key] = value
    end
    ModRef = mod
    local runtime = { mod = mod }
    LoopInGameThreadWithDelay = direct and function(delay, callback)
        assert(delay == 1000)
        local handle = #handles + 1
        handles[handle], runtime.tick, runtime.handle = callback, callback, handle
        return handle
    end or nil
    CancelDelayedAction = function(handle)
        assert(type(handle) == 'number' and handles[handle])
        cancelled[handle] = true
        return true
    end
    LoopAsync = function(delay, callback) assert(delay == 1000); runtime.loop = callback end
    ExecuteInGameThread = function(callback) queued[#queued + 1] = callback end
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    assert(type(mod.OnUnload) == 'function')
    return runtime
end

local function unload(runtime)
    off_thread = true
    runtime.mod.OnUnload()
    off_thread = false
end

local function state(runtime) return Reload.read(runtime.mod) end
local function only_ticket(runtime)
    local _, ticket = next(state(runtime).pending)
    assert(ticket)
    return ticket
end

-- A discarded plate and its rejected request survive reload without resetting
-- the retry count, initial age, or ten-second cooldown.
reset(); f.reject = true
local first = boot(true); first.tick()
assert(f.dish.destroyed and f.ordered == 1 and scans == 1)
local before = only_ticket(first)
assert(before.created_at == 20 and before.attempts == 1 and before.next_attempt == 30)
unload(first); assert(cancelled[first.handle])
assert(first.tick() == true and f.ordered == 1 and scans == 1)
local second = boot(true)
local controllers = f.objects.NetPlayerController
f.objects.NetPlayerController = {}; second.tick()
assert(only_ticket(second).created_at == before.created_at)
f.objects.NetPlayerController = controllers
f.now = 29; second.tick(); assert(f.ordered == 1)
assert(only_ticket(second).attempts == 1 and only_ticket(second).next_attempt == 30)
f.now, f.reject = 30, false; second.tick()
assert(f.ordered == 2 and not next(state(second).pending))
unload(second); local third = boot(true); third.tick(); assert(f.ordered == 2)

-- Food and drink tickets retain separate identities and both re-resolve live
-- customer, equipment, queue and staffing data after replacement.
reset(function() return drinks(false) end)
f.dish.quality, f.reject, f.reject_drink = 3, true, true
first = boot(true); first.tick()
local count, kinds = 0, {}
for _, ticket in pairs(state(first).pending) do count = count + 1; kinds[ticket.kind] = true end
assert(count == 2 and kinds.food and kinds.drink and f.ordered == 1 and f.drinks_ordered == 1)
unload(first); second = boot(true)
f.now, f.reject, f.reject_drink = 30, false, false
second.tick(); assert(f.ordered == 2 and f.drinks_ordered == 2 and not next(state(second).pending))

-- Repeated reloads cannot provide extra retries or extend the 120-second age.
reset(); f.reject = true
first = boot(true); first.tick()
for index = 2, 3 do
    unload(first); first = boot(true); f.now = index * 10 + 10; first.tick()
end
assert(f.ordered == 3 and not next(state(first).pending))
unload(first); first = boot(true); f.now = 60; first.tick(); assert(f.ordered == 3)
reset(); f.kitchen.ChefCharacters = f.array()
first = boot(true); first.tick(); assert(f.dish.destroyed and f.ordered == 0)
assert(only_ticket(first).attempts == 0)
unload(first); second = boot(true); f.now = 140; second.tick()
assert(f.ordered == 0 and not next(state(second).pending))

-- Patience/customer checks use current data, not a serialized prior decision.
reset(); f.reject = true
first = boot(true); first.tick(); unload(first)
second = boot(true); f.now, f.elapsed = 30, 180; second.tick()
assert(f.ordered == 1 and not next(state(second).pending))

-- An exception after native acceptance remains stopped across reload and
-- transient missing possession. Only an actual different session clears it.
reset(); f.throw_after_accept = true
first = boot(true); first.tick()
assert(f.ordered == 1 and state(first).failed and next(state(first).pending))
local scans_before = scans
unload(first); second = boot(true); second.tick()
assert(f.ordered == 1 and scans == scans_before and state(second).failed)
controllers = f.objects.NetPlayerController
f.objects.NetPlayerController = {}; second.tick()
f.objects.NetPlayerController = controllers; second.tick()
assert(f.ordered == 1 and state(second).failed)
unload(second)
f = fixture(); f.world.name = 'different-world'
third = boot(true); third.tick()
assert(f.ordered == 1 and not state(third).failed and not next(state(third).pending))

-- If storing the post-mutation checkpoint fails, the saved pre-mutation stop
-- marker still prevents replay, even when unload cannot write either.
reset(); first = boot(true); fail_from = writes + 3
first.tick(); assert(f.ordered == 1 and state(first).failed)
unload(first); fail_from = nil
second = boot(true); second.tick(); assert(f.ordered == 1 and state(second).failed)

-- The fallback coalesces dispatch and ignores callbacks queued by the old
-- runtime before unload; unload itself must not invoke any game API.
reset(); first = boot(false)
first.loop(); first.loop(); assert(#queued == 1 and contracts == 0)
unload(first); assert(first.loop() == true)
second = boot(false); second.loop(); assert(#queued == 2)
queued[1](); assert(contracts == 0 and f.ordered == 0)
queued[2](); assert(contracts == 1 and f.ordered == 1)
unload(second); assert(second.loop() == true)

print = old_print
print('main_spec: reload preserves pending food/drinks, cooldowns, bounds and safety stops; old callbacks are inert')
