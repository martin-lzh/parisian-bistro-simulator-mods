local Game, Fakes = require('game'), require('fakes')
local obj, array = Fakes.object, Fakes.array
-- Resolve actions by name across the game update; the new area is optional.
local area_available, default_action = true, 58
StaticFindObject = function(path)
    if path == '/Script/BrasserieSimulator.DishOutputArea' and not area_available then return nil end
    local object = obj(path)
    function object:ForEachName(callback)
        callback({ ToString = function() return 'EInteractionActions::EIA_PutDrinks' end }, 57)
        callback({ ToString = function() return 'EInteractionActions::EIA_DefaultAction' end }, default_action)
    end
    return object
end
local contract = Game.contract()
assert(contract.action == 58 and Game.valid(contract.dish_output))
area_available, default_action = false, 57
contract = Game.contract()
assert(contract.action == 57 and not Game.valid(contract.dish_output), 'Old builds retain direct item targeting')
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
    assert(context.Action == 58 and context.bIsPlayer and context.HitComponentName == 'None')
    sent[#sent + 1] = target
end
function player:IsPlayerFrozen() return self.frozen or false end
function player:IsPlayerLocallyFrozen() return self.local_frozen or false end
function player:IsInPlacingMode() return self.placing or false end
function player:IsInteractionWheelOpen() return self.wheel or false end
function player:IsCarryingTray() return self.carrying ~= false end
function player:GetCurrentFloor() return 0 end
local kitchen, area = obj('kitchen', 'kitchen', world), obj('bar', 'area', world)
local output_class = obj('dish-output-class')
local pass = obj('pass', output_class, world)
pass.PickupInteractionBox = obj('pickup-box')
function pass.PickupInteractionBox:GetOwner() return pass end
local world_subsystem = obj('world-subsystem')
function world_subsystem:GetKitchenManager() return self.kitchen end
world_subsystem.kitchen = kitchen
local lists = { NetPlayerController = { controller }, KitchenManager = { kitchen }, DrinkOutputArea = { area } }
FindAllOf = function(name) return lists[name] end
local input = obj('input')
function input:QueryKeysMappedToAction(action)
    assert(action == player.InteractionAction)
    return { Fakes.param('remapped-key') }
end
local clock = 0
local api = { player = 'player', dish = 'food', drink = 'drink', enhanced = 'enhanced', action = 58,
    dish_output = output_class, kitchen = 'kitchen', world_subsystem = 'world-subsystem',
    input = { Conv_InputActionValueToBool = function(_, value) return value end },
    subsystems = { GetLocalPlayerSubSystemFromPlayerController = function(_, owner, class)
        assert(owner == controller and class == 'enhanced'); return input
    end, GetWorldSubsystem = function(_, context, class)
        assert(context == pass and class == 'world-subsystem'); return world_subsystem
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
local function aim(target, component)
    local hit_component = component or obj('hit-' .. target.name)
    if not component then function hit_component:GetOwner() return target end end
    player.CurrentHit = { bBlockingHit = true, Component = Fakes.param(hit_component) }
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

-- The real native pass identifies the current world's kitchen, not the first
-- manager found globally. All requests still target one sorted, eligible dish.
aim(pass, pass.PickupInteractionBox)
scope = assert(Game.scope(api, session))
assert(scope.source == kitchen and Game.snapshot(api, session, scope).oldest == 'oldest@oldest')
assert(Game.request(api, session.id, scope.id, 'oldest@oldest') and sent[2] == oldest)
local foreign_kitchen = obj('foreign-kitchen', 'kitchen', other_world)
foreign_kitchen.DishesSpawnQueue = array({ dish('foreign-item', 'food', 1) })
lists.KitchenManager = { foreign_kitchen, kitchen }
assert(Game.scope(api, session).source == kitchen)
world_subsystem.kitchen = foreign_kitchen
assert(Game.scope(api, session) == nil, 'Never use a manager from another world')
assert(not Game.request(api, session.id, scope.id, 'oldest@oldest'), 'Revalidate manager at dispatch')
world_subsystem.kitchen = nil
assert(Game.scope(api, session) == nil)
world_subsystem.kitchen = kitchen
lists.KitchenManager = { kitchen }
for _, object in ipairs({ pass, kitchen }) do
    for _, key in ipairs({ 'destroyed', 'template', 'invalid' }) do
        object[key] = true
        assert(Game.scope(api, session) == nil, key)
        object[key] = nil
    end
end
world_subsystem.invalid = true
assert(Game.scope(api, session) == nil)
world_subsystem.invalid = nil
pass.world = other_world
assert(Game.scope(api, session) == nil)
pass.world = world
aim(pass)
assert(Game.scope(api, session) == nil, 'Non-pickup component hits must not activate the pass')
aim(pass, pass.PickupInteractionBox)
player.CurrentHit.bBlockingHit = false
assert(Game.scope(api, session) == nil)
player.CurrentHit.bBlockingHit = true
api.dish_output = nil
assert(Game.scope(api, session) == nil)
aim(newer)
assert(Game.scope(api, session), 'Direct items still work without the new area class')
api.dish_output = output_class
aim(pass, pass.PickupInteractionBox)
kitchen.DishesSpawnQueue = array({ oldest })
for _, entry in ipairs(exclusions) do
    local key, value = entry[1], entry[2]
    local old = oldest[key]; oldest[key] = value
    assert(Game.scope(api, session) == nil, 'Area respects item exclusion: ' .. key)
    oldest[key] = old
end
oldest.CreationTime.year = 1
assert(Game.scope(api, session) == nil, 'An uninitialized date cannot activate the pass')
oldest.CreationTime.year = 2026
tray.Slots.values[1].Dish = middle
assert(Game.scope(api, session) == nil, 'A drink-only free slot cannot activate food pickup')
tray.Slots.values[1].Dish = oldest
assert(Game.scope(api, session) == nil, 'A carried item in a stale queue cannot activate the pass')
tray.Slots.values[1].Dish = nil
kitchen.DishesSpawnQueue = array({})
assert(Game.scope(api, session) == nil, 'Empty pass must not start or show a hold hint')
kitchen.DishesSpawnQueue = array({ newer, oldest, middle })
assert(#sent == 2, 'Rejected area targets never send interactions')

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

-- Run actual input -> adapter -> sequencer -> RPC flow for direct food,
-- drinks and the native pass. Each hold collects all three in age order.
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
for _, mode in ipairs({ 'food', 'drink', 'pass' }) do
    local kind = mode == 'pass' and 'food' or mode
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
    if mode == 'pass' then aim(pass, pass.PickupInteractionBox) else aim(a) end
    dofile(MOD_ROOT .. '/Scripts/main.lua'); loop()
    assert(shown and #sent == 0)
    callbacks[input_path](Fakes.param(player), Fakes.param(true))
    loop(); assert(#sent == 1 and sent[1] == a)
    a.bBeingPicked, clock = true, 10.025
    callbacks[input_path](Fakes.param(player), Fakes.param(true))
    loop(); assert(#sent == 1, 'Repeated input during pickup must wait for acknowledgement')
    assert(callbacks[wheel_path](Fakes.param(player)) == false, 'Keep the wheel suppressed during pickup')
    if mode == 'pass' then
        -- The player can pan across the pass without targeting any one plate.
        rotation.Yaw = 45
    else aim(source) end
    tray.Slots.values[1].Dish, a.parent, clock = a, tray, 10.06
    set_members({ c, b })
    loop(); assert(#sent == 2 and sent[2] == b, kind .. ': continue after aimed item is removed')
    assert(shown == (mode == 'pass'), 'The native pass retains its hint while dishes remain')
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
    if mode == 'pass' then
        -- Turning away still cancels an area-started hold before dispatch.
        tray.Slots.values[1].Dish, a.parent, a.bBeingPicked = nil, nil, false
        set_members({ a }); aim(pass, pass.PickupInteractionBox)
        callbacks[input_path](Fakes.param(player), Fakes.param(true))
        player.CurrentHit.bBlockingHit, rotation.Yaw = false, 90
        loop(); assert(#sent == 3)
        assert(callbacks[wheel_path](Fakes.param(player)) == nil)
        aim(pass, pass.PickupInteractionBox)
        callbacks[input_path](Fakes.param(player), Fakes.param(true))
        for _ = 1, 4 do loop() end
        assert(#sent == 3, 'Returning to the pass cannot restart a canceled hold before release')
        controller.down = false; loop()
    end
end
