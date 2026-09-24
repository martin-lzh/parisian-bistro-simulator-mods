local Game, Fakes = require('game'), require('fakes')
local obj, array = Fakes.object, Fakes.array
FName = function(value) return value end
local world, other_world = obj('world'), obj('foreign')
local controller, player, tray = obj('controller', 'controller', world), obj('player', 'player', world), obj('tray', 'tray', world)
controller.Pawn, player.Controller, player.Tray = player, controller, tray
player.InteractionAction = obj('hold-action')
player.bIsInWidgetMode = false
function controller:IsLocalController() return not self.remote end
function controller:IsMultiplayerChatOpen() return self.chat or false end
function controller:IsInputKeyDown(key) assert(key == 'remapped-key'); return self.down ~= false end
local rotation, position = { Pitch = 0, Yaw = 0 }, { X = 0, Y = 0, Z = 0 }
function controller:GetControlRotation() return rotation end
function player:K2_GetActorLocation() return position end
local sent = {}
function controller:Server_RequestInteraction(target, context)
    assert(context.Action == 57 and context.bIsPlayer and context.HitComponentName == 'None')
    sent[#sent + 1] = target
end
function player:IsPlayerFrozen() return self.frozen or false end
function player:IsPlayerLocallyFrozen() return self.local_frozen or false end
function player:IsInPlacingMode() return self.placing or false end
function player:IsInteractionWheelOpen() return self.wheel or false end
function player:IsCarryingTray() return self.carrying ~= false end
function player:GetCurrentFloor() return 0 end
local kitchen, area = obj('kitchen', 'kitchen', world), obj('bar', 'area', world)
local lists = { NetPlayerController = { controller }, KitchenManager = { kitchen }, DrinkOutputArea = { area } }
FindAllOf = function(name) return lists[name] end
local input = obj('input')
function input:QueryKeysMappedToAction(action)
    assert(action == player.InteractionAction)
    return { Fakes.param('remapped-key') }
end
local clock = 0
local api = { player = 'player', dish = 'food', drink = 'drink', enhanced = 'enhanced', action = 57,
    input = { Conv_InputActionValueToBool = function(_, value) return value end },
    subsystems = { GetLocalPlayerSubSystemFromPlayerController = function(_, owner, class)
        assert(owner == controller and class == 'enhanced'); return input
    end },
    gameplay = { IsGamePaused = function() return controller.paused or false end, GetTimeSeconds = function() return clock end },
    math = { GetYear = function(_, time) return time.year end,
        Less_DateTimeDateTime = function(_, a, b) return a.age < b.age end } }
local function dish(name, kind, age)
    local d = obj(name, kind, world)
    d.CreationTime = { age = age, year = 2026 }
    d.bIsDirty, d.bIsBeingConsumed, d.bBeingPicked, d.DistanceToInteract = false, false, false, 150
    function d:GetDistanceTo(target) assert(target == player); return self.distance or 100 end
    function d:GetAssignedFloor() return self.floor or 0 end
    function d:GetAttachParentActor() return self.parent end
    function d:IsFull() return self.full ~= false end
    return d
end
local newer, oldest, middle = dish('newer', 'food', 300), dish('oldest', 'food', 100), dish('middle', 'food', 200)
kitchen.DishesSpawnQueue = array({ newer, oldest, middle })
tray.Slots = array({ { bReservedForDrinkOnly = false }, { bReservedForDrinkOnly = true } })
local function aim(target)
    player.CurrentHit = { bBlockingHit = true, Component = Fakes.param({ IsValid = function() return true end,
        GetOwner = function() return target end }) }
end
aim(newer)
local session = assert(Game.session(api))
assert(Game.held(api, session))
local scope = assert(Game.scope(api, session))
local snap = Game.snapshot(api, session, scope)
assert(snap.oldest == 'oldest@oldest', 'Sort by timestamp, not slot or aimed dish')
assert(Game.request(api, session.id, scope.id, snap.oldest) and sent[1] == oldest)
-- Do not mutate ordering, timestamps or distance while dispatching.
assert(kitchen.DishesSpawnQueue.values[1] == newer and oldest.CreationTime.age == 100 and oldest.DistanceToInteract == 150)
local exclusions = { { 'bIsDirty', true }, { 'bIsBeingConsumed', true }, { 'bBeingPicked', true },
    { 'distance', 200 }, { 'floor', 1 }, { 'table', obj('table') }, { 'parent', tray },
    { 'world', other_world }, { 'destroyed', true }, { 'template', true } }
for _, entry in ipairs(exclusions) do
    local key, value = entry[1], entry[2]
    local old = oldest[key]; oldest[key] = value
    assert(Game.snapshot(api, session, scope).oldest == 'middle@middle', 'Exclude ' .. key)
    oldest[key] = old
end
oldest.CreationTime.year = 1
assert(Game.snapshot(api, session, scope).oldest == 'middle@middle')
oldest.CreationTime.year = 2026
oldest.CreationTime.age, middle.CreationTime.age = 200, 200
assert(Game.snapshot(api, session, scope).oldest == 'middle@middle', 'Deterministic equal-time tie')
oldest.CreationTime.age = 100
tray.Slots.values[1].Dish = middle
assert(Game.snapshot(api, session, scope).oldest == nil, 'Drink-only space must not accept food')
tray.Slots.values[1].Dish = nil
local drink1, drink2, unfinished = dish('drink1', 'drink', 100), dish('drink2', 'drink', 200), dish('unfinished', 'drink', 1)
unfinished.full = false
area.OutputSlots = { Items = array({ { Drink = drink2 }, { Drink = unfinished }, { Drink = drink1 } }) }
aim(area)
assert(Game.scope(api, session) == nil, 'The output surface is not a drink target')
aim(obj('pickup-spot', 'spot', world))
assert(Game.scope(api, session) == nil, 'Nearby pass spots are not dish targets')
aim(unfinished)
assert(Game.scope(api, session) == nil, 'An unfinished drink must not activate pickup')
aim(drink2)
scope = assert(Game.scope(api, session))
assert(Game.snapshot(api, session, scope).oldest == 'drink1@drink1')
for _, entry in ipairs(exclusions) do
    local key, value = entry[1], entry[2]
    local old = drink2[key]; drink2[key] = value
    assert(Game.scope(api, session) == nil, 'Reject ineligible aimed drink: ' .. key)
    drink2[key] = old
end
tray.Slots.values[2].Dish = drink2
assert(Game.scope(api, session) == nil, 'A carried target cannot identify an output area')
tray.Slots.values[2].Dish = nil
aim(dish('unlisted-drink', 'drink', 1))
assert(Game.scope(api, session) == nil, 'Drinks outside output slots are not targets')
aim(newer)
for _, entry in ipairs(exclusions) do
    local key, value = entry[1], entry[2]
    local old = newer[key]; newer[key] = value
    assert(Game.scope(api, session) == nil, 'Reject ineligible aimed dish: ' .. key)
    newer[key] = old
end
assert(not Game.request(api, session.id, scope.id, 'drink1@drink1'), 'Revalidate target area')
aim(area)
assert(not Game.request(api, session.id, scope.id, 'drink1@drink1'), 'Looking at the surface cancels dispatch')
aim(drink2)
controller.down = false
assert(not Game.request(api, session.id, scope.id, 'drink1@drink1'))
controller.down = true
drink1.bBeingPicked = true
assert(not Game.request(api, session.id, scope.id, 'drink1@drink1'))
drink1.bBeingPicked = false
-- A newly targeted cup on the same output area keeps the same source scope.
aim(drink1)
assert(Game.scope(api, session).id == scope.id)
area.OutputSlots.Items = array({ { Drink = drink2 } })
assert(Game.scope(api, session) == nil, 'Stop when the aimed cup leaves its output area')
for _, key in ipairs({ 'paused', 'chat', 'remote' }) do
    controller[key] = true; assert(Game.session(api) == nil, key); controller[key] = false
end
for _, key in ipairs({ 'bIsInWidgetMode', 'frozen', 'local_frozen', 'placing', 'wheel' }) do
    player[key] = true; assert(Game.session(api) == nil, key); player[key] = false
end
player.carrying = false; assert(Game.session(api) == nil); player.carrying = true
assert(Game.session(api, obj('remote-pawn')) == nil)
controller.Pawn = nil; assert(Game.session(api) == nil); controller.Pawn = player
assert(#sent == 1, 'Rejected requests must never reach the RPC')

-- Source continuity uses the real adapter, not a scope stub. The aimed cup
-- becomes busy, leaves its source, and exposes the empty output surface.
aim(drink2)
local lock = Game.lock(session, assert(Game.scope(api, session)))
drink2.bBeingPicked = true
assert(Game.scope(api, session) == nil)
assert(Game.scope(api, session, lock).id == lock.id, 'Busy target must not cancel the active source')
drink2.bBeingPicked = false
aim(area)
assert(Game.scope(api, session, lock).id == lock.id, 'Allow the empty surface after pickup')
rotation.Yaw = 11
assert(Game.scope(api, session, lock) == nil, 'Looking away cancels the locked source')
rotation.Yaw = 359
assert(Game.scope(api, session, lock), 'Angle wraparound is a small movement')
rotation.Yaw = 0
position.X = 31
assert(Game.scope(api, session, lock) == nil, 'Walking away cancels')
position.X = 0
aim(newer)
assert(Game.scope(api, session, lock) == nil, 'A nearby different source cancels immediately')
aim(area)
area.destroyed = true
assert(Game.scope(api, session, lock) == nil, 'Do not retain dead source objects')
area.destroyed = false
assert(Game.scope(api, { id = 'new-tray' }, lock) == nil, 'A lock cannot cross sessions')

-- Run actual input -> adapter -> sequencer -> RPC flow for both food and
-- drinks. Holding over the first item must collect all three in age order.
local callbacks, loop, shown = {}, nil, false
local input_path = '/Script/BrasserieSimulator.PlayerCharacter:InteractionTriggered'
local wheel_path = '/Game/Blueprints/Player/BP_PlayerCharacter.BP_PlayerCharacter_C:CanInteractionWheelBeOpened'
StaticFindObject = function() return obj('api') end
Game.contract = function() return api end
package.loaded.hint = { new = function() return {
    clear = function() shown = false end,
    update = function(_, _, show) shown = show end,
} end }
RegisterHook = function(path, callback) callbacks[path] = callback; return 1, 2 end
LoopInGameThreadWithDelay = function(_, callback) loop = callback end
print = function() end
for _, kind in ipairs({ 'food', 'drink' }) do
    local a, b, c = dish(kind .. '-a', kind, 1), dish(kind .. '-b', kind, 2), dish(kind .. '-c', kind, 3)
    local source = kind == 'food' and kitchen or area
    local function set_members(values)
        if kind == 'food' then kitchen.DishesSpawnQueue = array(values)
        else
            local slots = {}
            for _, value in ipairs(values) do slots[#slots + 1] = { Drink = value } end
            area.OutputSlots.Items = array(slots)
        end
    end
    set_members({ c, a, b })
    tray.Slots = array({ { bReservedForDrinkOnly = false }, { bReservedForDrinkOnly = false },
        { bReservedForDrinkOnly = false } })
    sent, clock, controller.down = {}, 10, true
    aim(a)
    dofile(MOD_ROOT .. '/Scripts/main.lua'); loop()
    assert(shown and #sent == 0)
    callbacks[input_path](Fakes.param(player), Fakes.param(true))
    loop(); assert(#sent == 1 and sent[1] == a)
    a.bBeingPicked, clock = true, 10.025
    callbacks[input_path](Fakes.param(player), Fakes.param(true))
    loop(); assert(#sent == 1, 'Repeated input during pickup must wait for acknowledgement')
    assert(callbacks[wheel_path](Fakes.param(player)) == false, 'Keep the wheel suppressed during pickup')
    aim(source)
    tray.Slots.values[1].Dish, a.parent, clock = a, tray, 10.06
    set_members({ c, b })
    loop(); assert(#sent == 2 and sent[2] == b, kind .. ': continue after aimed item is removed')
    assert(not shown, 'An empty surface must not acquire an independent hold hint')
    tray.Slots.values[2].Dish, b.parent, clock = b, tray, 10.12
    player.CurrentHit.bBlockingHit = false
    loop(); assert(#sent == 3 and sent[3] == c, kind .. ': stale queue plus tray acknowledgement must continue')
    tray.Slots.values[3].Dish, clock = c, 10.2
    loop(); assert(#sent == 3, 'Full tray must stop')
    controller.down = false; loop()
    assert(callbacks[wheel_path](Fakes.param(player)) == nil)
    controller.down = true
    for _ = 1, 4 do loop() end
    assert(#sent == 3, 'No restart from physical key state alone')
end
