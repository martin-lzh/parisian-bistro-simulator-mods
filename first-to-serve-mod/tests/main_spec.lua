local Fakes = require('fakes')
local native, blueprint, calls = {}, {}, {}
local wheel_path = '/Game/Blueprints/Player/BP_PlayerCharacter.BP_PlayerCharacter_C:CanInteractionWheelBeOpened'
local input_path = '/Script/BrasserieSimulator.PlayerCharacter:InteractionTriggered'
local world_ready, held, valid_session, source = false, true, true, 'pass'
local now, candidate, present, carried, hints = 0, 'first', { first = true, second = true }, {}, {}
local player = {}
local api = { input = { Conv_InputActionValueToBool = function(_, value) return value end } }
local Game = {
    valid = function(value) return value ~= nil end,
    contract = function() return api end,
    session = function(_, expected)
        if valid_session and (not expected or expected == player) then return { id = 'session', now = now } end
    end,
    scope = function() return source and { id = source } end,
    lock = function(session, scope) return { session = session.id, id = scope.id } end,
    held = function() return held end,
    snapshot = function(_, session, scope)
        return { session = session.id, scope = scope.id, now = now, oldest = candidate, present = present, carried = carried }
    end,
    request = function(_, session, scope, id, lock)
        assert(session == 'session' and scope == 'pass')
        assert(lock and lock.session == session and lock.id == scope, 'Dispatch must retain the source lock')
        calls[#calls + 1] = id; return true
    end,
}
package.loaded.game = Game
package.loaded.hint = { new = function() return {
    clear = function() hints[#hints + 1] = false end,
    update = function(_, session, show) hints[#hints + 1] = session ~= nil and show end,
} end }
StaticFindObject = function() return world_ready and {} or nil end
RegisterHook = function(path, callback)
    if path == wheel_path then blueprint[path] = callback else native[path] = callback end
    return 1, 2
end
local loop
ModRef = {}
IsInGameThread = function() return true end
LoopInGameThreadWithDelay = function(delay, callback) assert(delay == 25); loop = callback end
print = function() end
dofile(MOD_ROOT .. '/Scripts/main.lua')
loop(); assert(not native[input_path], 'Wait for Blueprint load')
world_ready = true; loop(); assert(native[input_path] and blueprint[wheel_path])
assert(#calls == 0 and hints[#hints], 'Show hint before hold without dispatching')
local hint_count = #hints
loop(); loop(); loop()
assert(#hints == hint_count, 'Idle HUD/source scans must keep the 100 ms cadence')
loop(); assert(#hints == hint_count + 1)
source = nil
for _ = 1, 4 do loop() end
assert(not hints[#hints], 'Looking away removes the hint even without an active hold')
source = 'pass'
for _ = 1, 4 do loop() end
assert(hints[#hints])
local context, pressed = Fakes.param(player), Fakes.param(true)
native[input_path](Fakes.param({}), pressed); loop()
assert(#calls == 0, 'Remote input ignored')
native[input_path](context, pressed)
assert(blueprint[wheel_path](context) == false, 'Suppress wheel for claimed hold')
loop(); assert(#calls == 1 and calls[1] == 'first')
now, candidate = 0.025, 'second'; loop(); assert(#calls == 1)
now = 0.05
carried.first = true; loop(); assert(#calls == 2 and calls[2] == 'second')
held = false; loop()
assert(blueprint[wheel_path](context) == nil)
held, now = true, 1; loop(); assert(#calls == 2, 'Physical press alone cannot restart a canceled native hold')
native[input_path](context, pressed)
source = 'different'; loop(); assert(#calls == 2, 'Changing station cancels')
assert(blueprint[wheel_path](context) == nil)
source = 'pass'; native[input_path](context, pressed)
native[input_path](context, Fakes.param(false)); loop(); assert(#calls == 2, 'Release event cancels')
valid_session = false
for _ = 1, 4 do loop() end
assert(not hints[#hints])
valid_session = true
Game.request = function() error('Bridge unavailable') end
native[input_path](context, pressed); loop()
assert(not hints[#hints], 'Failure must remove the hint')
assert(blueprint[wheel_path](context) == nil, 'Failure must restore native wheel eligibility')
Game.request = function() error('Disabled runtime must not dispatch again') end
loop()
-- A partial hook installation is rolled back, and cannot leave input active.
local registered, removed = 0, 0
RegisterHook = function(path)
    registered = registered + 1
    if path == input_path then error('Cannot install input hook') end
    return 11, 12
end
UnregisterHook = function(path, pre, post)
    assert(path == wheel_path and pre == 11 and post == 12); removed = removed + 1
end
dofile(MOD_ROOT .. '/Scripts/main.lua'); loop(); loop()
assert(registered == 2 and removed == 1)

-- The loader unload callback stops old closures and clears UI on the game
-- thread. Off-thread unloading must leave UObject cleanup to the new state.
RegisterHook = function() return 1, 2 end
Game.request = function() calls[#calls + 1] = 'unexpected' end
valid_session, source, held = true, 'pass', true
dofile(MOD_ROOT .. '/Scripts/main.lua'); loop()
assert(hints[#hints])
ModRef.OnUnload()
assert(not hints[#hints] and loop() == true, 'Unload clears hint and terminates the game-thread loop')
dofile(MOD_ROOT .. '/Scripts/main.lua'); loop()
hint_count = #hints
IsInGameThread = function() return false end
ModRef.OnUnload()
assert(#hints == hint_count and loop() == true, 'Never access UI from an off-thread unload callback')

-- A held button spans two distinct Lua runtimes. The new runtime must see a
-- release before accepting repeated Triggered events as a fresh gesture.
local shared, reload_calls = {}, 0
ModRef = {
    GetSharedVariable = function(_, key) return shared[key] end,
    SetSharedVariable = function(_, key, value)
        assert(type(value) == 'boolean'); shared[key] = value
    end,
}
RegisterHook = function(path, callback)
    if path == wheel_path then blueprint[path] = callback else native[path] = callback end
    return 1, 2
end
Game.request = function() reload_calls = reload_calls + 1; return true end
held, candidate, carried = true, 'first', {}
dofile(MOD_ROOT .. '/Scripts/main.lua'); loop()
native[input_path](context, pressed); loop()
assert(reload_calls == 1)
local old_loop, old_input = loop, native[input_path]
ModRef.OnUnload()
dofile(MOD_ROOT .. '/Scripts/main.lua'); loop()
native[input_path](context, pressed)
for _ = 1, 4 do loop() end
assert(reload_calls == 1 and blueprint[wheel_path](context) == nil,
    'Reload cancels the old hold and leaves the native wheel untouched')
old_input(context, pressed); assert(old_loop() == true and reload_calls == 1)
held = false
for _ = 1, 4 do loop() end
held, now = true, now + 1
native[input_path](context, pressed); loop()
assert(reload_calls == 2, 'Release and a fresh native hold can start after reload')

-- A queued fallback callback from an unloaded state must also be inert.
LoopInGameThreadWithDelay = nil
local pending
LoopAsync = function(_, callback) loop = callback end
ExecuteInGameThread = function(callback) pending = callback end
dofile(MOD_ROOT .. '/Scripts/main.lua')
loop(); assert(pending)
ModRef.OnUnload(); pending()
assert(loop() == true and reload_calls == 2)
