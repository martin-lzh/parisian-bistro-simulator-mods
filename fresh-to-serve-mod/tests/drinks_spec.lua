local Game, Remake, fixture = require('game'), require('remake'), require('drink_fixture')
local function run(f)
    local engine = Remake.new(Game, function() end)
    engine:tick(f.api)
    return engine
end

local f = fixture(); local slots = f.area.OutputSlots.Items
local engine = run(f)
assert(f.drink.destroyed and f.drinks_ordered == 1 and f.ordered == 0)
assert(f.endplays == 1 and f.notice.DrinkOrderId.A == 201 and f.notice.DishOrderId.A == 1)
assert(f.area.OutputSlots.Items == slots and #slots == 1 and slots[1].SlotIndex == 2)
engine:tick(f.api); assert(f.drinks_ordered == 1)

for _, mutate in ipairs({
    function(v) v.elapsed = 150 end, -- 50 remaining, full device/handling/service budget is 50
    function(v) v.inactive_timer = true end,
    function(v) v.table.NumberOfCustomersSit = 0 end,
    function(v) v.table.CustomerOrderTime = 12 end,
    function(v) v.behavior.bIsDrinkServed = true end,
    function(v) v.behavior.GroupId = 6 end,
    function(v) v.notice.DrinkOrderId = v.guid(99) end,
    function(v) v.use.UseTime = -1 end,
    function(v) v.objects.DrinkDispenser = {} end,
    function(v) v.device_floor = 1 end,
}) do
    f = fixture(); mutate(f); run(f)
    assert(f.drink.destroyed and f.drinks_ordered == 0)
end
f = fixture(); f.elapsed = 149; run(f); assert(f.drinks_ordered == 1)
f = fixture(); f.no_patience = true; f.inactive_timer = true
run(f); assert(f.drinks_ordered == 1)

for _, mutate in ipairs({
    function(v) v.drink.quality = 0 end,
    function(v) v.drink.partial = true end,
    function(v) v.drink.bFillTransitionActive = true end,
    function(v) v.drink.bBeingPicked = true end,
    function(v) v.drink.bIsDirty = true end,
    function(v) v.drink.bIsBeingConsumed = true end,
    function(v) v.drink.parent = v.player end,
    function(v) v.drink.table = v.table end,
    function(v) v.drink.authority = false end,
    function(v) v.drink.world = v.object('other-world') end,
    function(v) v.table.bTableHandledByPlayer = true end,
    function(v) v.prepared.State = 1 end,
    function(v) v.controller.authority = false end,
    function(v) v.paused = true end,
}) do
    f = fixture(); mutate(f); run(f)
    assert(not f.drink.destroyed and f.drinks_ordered == 0)
end

-- Cocktails follow drink cleanup; unfinished pours are protected.
f = fixture(true); run(f); assert(f.drinks_ordered == 1)
f = fixture(true); f.drink.bIsPourInProgress = true
run(f); assert(not f.drink.destroyed and f.drinks_ordered == 0)
f = fixture(); f.objects.DrinkDispenser = {}; f.objects.BottleDispenser = {f.device}
run(f); assert(f.drinks_ordered == 1)

local function pending(f, id, key, linked)
    return { DrinkId = f.guid(id), Drink = key or 17, LinkedTable = linked or f.table,
        State = 0, PlayerFloor = 0, bClaimedByPlayer = false }
end
-- Pending work covers a replacement; orphan Prepared rows do not.
f = fixture(); f.manager.DrinksPrepareQueue.Items[2] = pending(f, 7)
run(f); assert(f.drinks_ordered == 0 and #f.manager.DrinksPrepareQueue.Items == 1)
f = fixture(); f.manager.DrinksPrepareQueue.Items[2] = pending(f, 7)
f.manager.DrinksPrepareQueue.Items[2].State = 2
run(f); assert(f.drinks_ordered == 1) -- orphan Prepared row is not a physical replacement

-- Manual claims defer estimation without changing or cancelling the claim.
f = fixture(); local claim = pending(f, 7, 18, f.object('other-table'))
function claim.LinkedTable:GetAssignedFloor() return 0 end
claim.bClaimedByPlayer = true; f.manager.DrinksPrepareQueue.Items[2] = claim
engine = run(f); assert(f.drinks_ordered == 0 and next(engine.pending) and claim.bClaimedByPlayer)
claim.bClaimedByPlayer = false; f.now = 31; engine:tick(f.api)
assert(f.drinks_ordered == 1)
f = fixture(); f.manager.DrinksPrepareQueue.Items[2] = pending(f, 7, 18, f.object('other-table'))
local other_table = f.manager.DrinksPrepareQueue.Items[2].LinkedTable
function other_table:GetAssignedFloor() return 0 end
f.elapsed = 125; run(f); assert(f.drinks_ordered == 0) -- 75 = new drink 50 + backlog 25

-- No assigned working bartender, or excluded preparation task: wait, then expire.
for _, mutate in ipairs({
    function(v) v.employee.State = 1 end,
    function(v) v.employee.AssignedFloor = 1 end,
    function(v) v.employee.ExcludedTaskTypes[1] = v.api.prepare_drink end,
}) do
    f = fixture(); mutate(f); engine = run(f)
    assert(f.drinks_ordered == 0 and next(engine.pending))
    f.now = 140; engine:tick(f.api); assert(not next(engine.pending))
end

-- Simultaneous food and drink with identical GUIDs must remain independent.
f = fixture(); f.dish.quality = 3; engine = run(f)
assert(f.ordered == 1 and f.drinks_ordered == 1)
assert(f.notice.DishOrderId.A == 101 and f.notice.DrinkOrderId.A == 201)
engine:tick(f.api); assert(f.ordered == 1 and f.drinks_ordered == 1)

-- Exact drink GUID, not row order, chooses among customers ordering the same drink.
f = fixture(); local customer2, behavior2 = f.object('second-customer'), f.object('second-behavior')
behavior2.GroupId, behavior2.WantedDrink, behavior2.bIsDrinkServed = 5, 17, false
function customer2:GetCustomerBehaviorComponent() return behavior2 end
local notice2 = {Customer = customer2, Drink = 17, DrinkOrderId = f.guid(2), bDrinkOrdered = true}
f.table.OrderNotifications = f.array({notice2, f.notice}); f.table.RepCustomerActors[2] = customer2
f.table.NumberOfCustomersSit = 2
run(f); assert(f.notice.DrinkOrderId.A == 201 and notice2.DrinkOrderId.A == 2)

-- A prepared physical drink and its queue row cover only one of two customers.
for _, state in ipairs({0, 1, 2}) do
    f = fixture()
    customer2 = f.object('second-customer')
    function customer2:GetCustomerBehaviorComponent() return f.behavior end
    f.table.RepCustomerActors[2] = customer2; f.table.NumberOfCustomersSit = 2
    f.table.OrderNotifications[2] = {Customer = customer2, Drink = 17,
        DrinkOrderId = f.guid(7), bDrinkOrdered = true}
    local healthy = f.object('healthy-drink')
    for key, value in pairs(f.drink) do if healthy[key] == nil then healthy[key] = value end end
    healthy.quality, healthy.DrinkOrderId = 0, f.guid(7)
    f.objects.Drink[2] = healthy
    local entry = pending(f, 7); entry.State = state
    f.manager.DrinksPrepareQueue.Items[2] = entry
    engine = run(f)
    assert(f.drinks_ordered == 1 and not healthy.destroyed)
    engine:tick(f.api); assert(f.drinks_ordered == 1)
end

-- Native first-unordered-row assignment must not steal another customer's order.
f = fixture(); customer2 = f.object('second-customer')
function customer2:GetCustomerBehaviorComponent() return f.behavior end
f.table.RepCustomerActors[2] = customer2; f.table.NumberOfCustomersSit = 2
notice2 = {Customer = customer2, Drink = 17, DrinkOrderId = f.guid(0), bDrinkOrdered = false}
f.table.OrderNotifications[2] = notice2
run(f)
assert(f.notice.DrinkOrderId.A == 201 and f.notice.bDrinkOrdered)
assert(not notice2.bDrinkOrdered and notice2.DrinkOrderId.A == 0)
assert(f.manager.DrinksPrepareQueue.Items[1].DrinkId.A == 201)

-- Elevator serving slots are cleared; no output FastArray write is needed.
f = fixture(); local elevator = f.object('elevator')
elevator.ElevatorSlots = f.array({{Dish = f.drink, bReservedForDrinkOnly = true}})
f.drink.parent = elevator; f.objects.DishElevator = {elevator}
run(f); assert(elevator.ElevatorSlots[1].Dish == nil and f.drinks_ordered == 1)

for _, flag in ipairs({'keep_destroyed_order', 'stuck_output', 'throw_after_drink'}) do
    f = fixture(); f[flag] = true
    assert(not pcall(run, f))
    assert(f.drinks_ordered == (flag == 'throw_after_drink' and 1 or 0))
end
f = fixture(); f.reject_drink = true; engine = run(f)
assert(f.drinks_ordered == 1 and f.notice.DrinkOrderId.A == 1)
f.elapsed = 180; f.now = 31; engine:tick(f.api)
assert(f.drinks_ordered == 1 and not next(engine.pending))
f = fixture(); f.drink.refuse_destroy = true
assert(not pcall(run, f) and not f.drink.destroyed and f.drinks_ordered == 0)
print('drinks_spec: output cleanup, native queue lifecycle, exact orders, timing, claims and food coexistence passed')
