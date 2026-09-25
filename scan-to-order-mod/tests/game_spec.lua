local Game, fixture = require('game'), require('fixture')
local function tick(f)
    local session = Game.session(f.api)
    if not session or session.paused then return end
    for _, ticket in ipairs(Game.candidates(f.api, session)) do Game.request(f.api, session, ticket) end
end

-- Independent items: a missing meal must not block an available drink; refill
-- resumes the existing customer order and accepted orders cannot repeat.
local f = fixture(); f.stock[12] = 0
tick(f); assert(#f.calls == 1 and f.row.bDrinkOrdered and not f.row.bDishOrdered)
for _ = 1, 5 do tick(f) end
assert(#f.calls == 1)
f.stock[12] = 1; tick(f); tick(f)
assert(#f.calls == 2 and f.row.bDishOrdered and f.stock[12] == 0)

-- Several customers sharing the last unit use live stock after each native
-- acceptance. A new course can be ordered without stale per-item locks.
f = fixture(); local second = f.add_customer(); f.stock[12] = 1
tick(f); assert(f.row.bDishOrdered and not second.bDishOrdered and #f.calls == 3)
f.stock[12] = 1; tick(f); assert(second.bDishOrdered and #f.calls == 4)
f.row.bDishOrdered, f.row.DishOrderId, f.stock[12] = false, f.guid(), 1
tick(f); assert(#f.calls == 5)

-- Native refusal does not falsify the order, consume stock, or prevent a later
-- attempt once the game can accept it.
f = fixture(); f.reject = true; tick(f)
assert(#f.calls == 2 and not f.row.bDishOrdered and f.stock[12] == 10)
f.reject = false; tick(f); assert(#f.calls == 4 and f.row.bDishOrdered)

for _, change in ipairs({
    function(x) x.controller.authority = false end,
    function(x) x.controller.remote = true end,
    function(x) x.player.authority = false end,
    function(x) x.player.Controller = nil end,
    function(x) x.controller.Pawn = nil end,
    function(x) x.paused = true end,
    function(x) x.table.empty = true end,
    function(x) x.table.template = true end,
    function(x) x.table.destroyed = true end,
    function(x) x.table.authority = false end,
    function(x) x.table.world = x.object('other-world') end,
    function(x) x.table.bTableHandledByPlayer = true end,
    function(x) x.table.bBeingOrdered = true end,
    function(x) x.table.bGroupCanBeCashedOut = true end,
    function(x) x.table.NumberOfCustomersSit = 0 end,
    function(x) x.table.RepCustomerActors = x.array() end,
    function(x) x.behavior.GroupId = 9 end,
    function(x) x.row.Customer.destroyed = true end,
    function(x) x.elapsed = 60 end,
    function(x) x.storage.authority = false end,
    function(x) x.subsystem.world = x.object('other-world') end,
}) do
    f = fixture(); change(f); tick(f); assert(#f.calls == 0)
end
f = fixture(); f.elapsed, f.patience = 100, false; tick(f); assert(#f.calls == 2)
f = fixture(); f.table.bOrderHandledByEmployee = true; tick(f); assert(#f.calls == 2)
f = fixture(); f.kitchen.ChefCharacters = f.array(); tick(f)
assert(#f.calls == 1 and not f.row.bDishOrdered)
f = fixture(); f.unavailable = 34; tick(f); assert(#f.calls == 1 and not f.row.bDrinkOrdered)
f = fixture(); f.row.Dish, f.behavior.WantedDish = 0, 0; tick(f); assert(#f.calls == 1)
f = fixture(); f.behavior.WantedDish = 99; tick(f); assert(#f.calls == 1)
f = fixture(); f.behavior.bIsDishServed = true; tick(f); assert(#f.calls == 1)
f = fixture(); f.behavior.DishInstance = f.object('served-meal'); tick(f); assert(#f.calls == 1)
f = fixture(); f.row.DishOrderId = f.guid(77); tick(f); assert(#f.calls == 1)

-- Revalidate stale tickets after player/employee actions, reseating, authority
-- loss and pause; never bind a valid later customer to an invalid first row.
for _, change in ipairs({
    function(x) x.row.bDishOrdered = true; x.row.DishOrderId = x.guid(99) end,
    function(x) x.table.AssignedCustomerGroupId = 9 end,
    function(x) x.controller.authority = false end,
    function(x) x.paused = true end,
    function(x) x.world.name = 'new-world' end,
}) do
    f = fixture(); local session = Game.session(f.api); local ticket = Game.candidates(f.api, session)[1]
    change(f); assert(not Game.request(f.api, session, ticket) and #f.calls == 0)
end
f = fixture(); second = f.add_customer(); f.behavior.bIsDishServed = true; tick(f)
assert(not second.bDishOrdered and #f.calls == 2)
f = fixture(); f.omit_binding = true
assert(not pcall(tick, f) and #f.calls == 1)
f = fixture(); f.throw_after_accept = true
assert(not pcall(tick, f) and #f.calls == 1)
print('game_spec: restocking, native orders, stock contention, customers, authority and uncertainty passed')
