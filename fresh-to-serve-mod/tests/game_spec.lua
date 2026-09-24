local Game, Remake, fixture = require('game'), require('remake'), require('fixture')
local function run(f)
    local engine = Remake.new(Game, function() end)
    engine:tick(f.api)
    return engine
end
local f = fixture(); local engine = run(f)
assert(f.dish.destroyed and #f.kitchen.DishesSpawnQueue == 1 and f.kitchen.DishesSpawnQueue[1] == nil and f.ordered == 1)
assert(f.notice.DishOrderId.A == 101 and f.notice.bDishOrdered and f.table.refreshed)
engine:tick(f.api); assert(f.ordered == 1)

for _, mutate in ipairs({
    function(v) v.elapsed = 151 end, -- 49s left; cooking + service requires 50
    function(v) v.inactive_timer = true end,
    function(v) v.table.NumberOfCustomersSit = 0 end,
    function(v) v.behavior.bIsDishServed = true end,
    function(v) v.behavior.GroupId = 6 end,
    function(v) v.table.CustomerOrderTime = 12 end, -- dish from previous seating
    function(v) v.notice.DishOrderId = v.guid(0) end,
}) do
    f = fixture(); mutate(f); run(f)
    assert(f.dish.destroyed and f.ordered == 0)
end
for _, mutate in ipairs({
    function(v) v.dish.quality = 0 end,
    function(v) v.dish.bIsDirty = true end,
    function(v) v.dish.bIsBeingConsumed = true end,
    function(v) v.dish.bBeingPicked = true end,
    function(v) v.dish.parent = v.player end,
    function(v) v.dish.table = v.table end,
    function(v) v.dish.authority = false end,
    function(v) v.dish.template = true end,
    function(v) v.dish.world = v.object('other-world') end,
    function(v) v.table.bTableHandledByPlayer = true end,
    function(v) v.controller.authority = false end,
    function(v) v.paused = true end,
}) do
    f = fixture(); mutate(f); run(f)
    assert(not f.dish.destroyed and f.ordered == 0)
end
f = fixture(); f.dish.quality = 4; f.no_patience = true; f.inactive_timer = true
run(f); assert(f.ordered == 1)
f = fixture(); f.dish.refuse_destroy = true
assert(not pcall(run, f) and f.ordered == 0 and #f.kitchen.DishesSpawnQueue == 1)
f = fixture(); f.reject_release = true
assert(not pcall(run, f) and f.ordered == 0 and not f.dish.destroyed)
assert(f.kitchen.DishesSpawnQueue[1] == f.dish)
f = fixture(); f.reject = true; engine = run(f)
assert(f.ordered == 1 and f.notice.DishOrderId.A == 1)
f.elapsed = 180; f.now = 31; engine:tick(f.api)
assert(f.ordered == 1 and not next(engine.pending)) -- patience rechecked before retry
f = fixture(); f.reject = true; engine = run(f)
f.table.AssignedCustomerGroupId = 6; f.now = 31; engine:tick(f.api)
assert(f.ordered == 1 and not next(engine.pending))
f = fixture(); f.throw_after_accept = true
assert(not pcall(run, f) and f.ordered == 1)

-- An existing replacement and a plate carried by another player both cover demand.
f = fixture()
f.kitchen.DishesPrepareQueue.Items[1] = { DishId = f.guid(7), Dish = 12,
    LinkedTable = f.table, State = 1, PreparationDuration = 20 }
run(f); assert(f.dish.destroyed and f.ordered == 0)
f = fixture(); local carried = f.object('carried'); carried.Dish = 12; carried.bIsDirty = false
carried.bIsBeingConsumed = false; carried.parent = f.player
function carried:GetOrderedForTable() return f.table end
f.objects.GenericDish[2] = carried
run(f); assert(f.ordered == 0)

-- Include backlog even when it is for a different table.
f = fixture()
f.kitchen.DishesPrepareQueue.Items[1] = { DishId = f.guid(7), Dish = 17,
    LinkedTable = f.object('other-table'), State = 1, PreparationDuration = 150 }
run(f); assert(f.ordered == 0)
f = fixture(); f.kitchen.ChefCharacters:Empty(); engine = run(f)
assert(f.ordered == 0 and next(engine.pending))
f.now = 140; f.kitchen.ChefCharacters[1] = {}
engine:tick(f.api); assert(not next(engine.pending) and f.ordered == 0)

-- Two customers with the same dish receive exactly two replacement GUIDs.
f = fixture()
local customer2, dish2 = f.object('customer2'), f.object('dish2')
function customer2:GetCustomerBehaviorComponent() return f.behavior end
for key, value in pairs(f.dish) do if dish2[key] == nil then dish2[key] = value end end
f.table.NumberOfCustomersSit = 2
f.table.RepCustomerActors[2] = customer2
f.table.OrderNotifications[2] = { Customer = customer2, Dish = 12, bDishOrdered = true, DishOrderId = f.guid(2) }
f.objects.GenericDish[2] = dish2; f.kitchen.DishesSpawnQueue[2] = dish2
engine = run(f)
assert(f.ordered == 2 and f.dish.destroyed and dish2.destroyed)
assert(f.notice.DishOrderId.A ~= f.table.OrderNotifications[2].DishOrderId.A)
engine:tick(f.api); assert(f.ordered == 2)

-- Elevator cleanup frees the serving slot without consuming other reservations.
f = fixture(); local elevator = f.object('elevator')
elevator.ElevatorSlots = f.array({{ Dish = f.dish, bDishesOnly = true }})
f.dish.parent = elevator
-- Keep the kitchen reference too: it must not hide the elevator ownership.
f.kitchen.DishElevators = f.map({{1, elevator}})
local taken = f.array({12, 12, 19})
f.kitchen.TakenOutDishes = f.map({{f.table, { Dishes = taken }}})
run(f)
assert(f.ordered == 1 and elevator.ElevatorSlots[1].Dish == nil and f.kitchen.DishesSpawnQueue[1] == nil)
assert(#taken == 3 and taken[1] == 12 and taken[2] == 12 and taken[3] == 19)

-- A partial array write restores prior reservations and stops before reordering.
f = fixture(); taken = f.array({12, 19})
f.kitchen.TakenOutDishes = f.map({{f.table, { Dishes = taken }}})
local mt, failed = getmetatable(taken), false
local write = mt.__newindex
mt.__newindex = function(object, key, value)
    write(object, key, value)
    if key == 2 and not failed then failed = true; error('array write failed') end
end
assert(not pcall(run, f) and f.ordered == 0 and not f.dish.destroyed)
assert(#taken == 2 and taken[1] == 12 and taken[2] == 19)

-- Empty slots do not hide later food, change pass capacity or move healthy meals.
f = fixture(); local healthy = f.object('healthy')
for key, value in pairs(f.dish) do if healthy[key] == nil then healthy[key] = value end end
healthy.quality = 0
f.kitchen.DishesSpawnQueue = f.array({healthy, f.dish, healthy})
f.kitchen.DishesSpawnQueue[1] = nil
run(f)
assert(f.dish.destroyed and not healthy.destroyed and f.ordered == 1)
assert(#f.kitchen.DishesSpawnQueue == 3 and f.kitchen.DishesSpawnQueue[2] == nil)
assert(f.kitchen.DishesSpawnQueue[3] == healthy)

-- Revalidation inside dispatch prevents a departed customer or depleted patience.
f = fixture(); local session = Game.session(f.api)
local candidate = Game.candidates(f.api, session)[1]
local ticket = Game.ticket(f.api, session, candidate, {})
assert(Game.discard(f.api, session, candidate))
f.elapsed = 195
assert(not Game.request(f.api, session, ticket) and f.ordered == 0)
print('game_spec: discard, customer identity, live patience, supply, duplicates, authority and elevator checks passed')
