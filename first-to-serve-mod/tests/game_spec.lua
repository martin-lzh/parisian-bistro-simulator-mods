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
local api = { player = 'player', dish = 'food', drink = 'drink', area = 'area', spot = 'spot', enhanced = 'enhanced', action = 57,
    subsystems = { GetLocalPlayerSubSystemFromPlayerController = function(_, owner, class)
        assert(owner == controller and class == 'enhanced'); return input
    end },
    gameplay = { IsGamePaused = function() return controller.paused or false end, GetTimeSeconds = function() return 0 end },
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
scope = assert(Game.scope(api, session))
assert(Game.snapshot(api, session, scope).oldest == 'drink1@drink1')
aim(drink2)
assert(Game.scope(api, session).id == scope.id)
aim(newer)
assert(not Game.request(api, session.id, scope.id, 'drink1@drink1'), 'Revalidate target area')
aim(area)
controller.down = false
assert(not Game.request(api, session.id, scope.id, 'drink1@drink1'))
controller.down = true
drink1.bBeingPicked = true
assert(not Game.request(api, session.id, scope.id, 'drink1@drink1'))
drink1.bBeingPicked = false
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
