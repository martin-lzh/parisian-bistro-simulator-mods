local Game, fixture = require('game'), require('fixture')
local function tick(f)
    local session = Game.session(f.api)
    if not session or session.paused then return end
    for _, ticket in ipairs(Game.candidates(f.api, session)) do Game.request(f.api, session, ticket) end
end

-- Literal reflection and short-name scans must agree with the actual UClass.
-- Both supported builds must discover a table, reacquire it and bind orders.
local prefix = '/Script/BrasserieSimulator.'
for _, spelling in ipairs({ 'Table', 'table' }) do
    local x = fixture(spelling)
    local other = spelling == 'Table' and 'table' or 'Table'
    x.api = Game.contract()
    assert(x.api.table_name == spelling)
    assert(x.api.table_class == x.reflection[prefix .. spelling])
    local session = Game.session(x.api)
    local tickets = Game.candidates(x.api, session)
    assert(#tickets == 2)
    assert(Game.request(x.api, session, tickets[1]))
    assert(Game.request(x.api, session, tickets[2]))
    tick(x)
    assert(#x.calls == 2 and x.row.bDishOrdered and x.row.bDrinkOrdered)
    local table_scans = 0
    for _, name in ipairs(x.scans) do
        assert(name ~= other, 'Must enumerate the resolved spelling')
        if name == spelling then table_scans = table_scans + 1 end
    end
    assert(table_scans >= 4, 'Discovery and both requests must scan the resolved class')
    for _, path in ipairs(x.lookups) do
        assert(not path:find(prefix .. other .. ':', 1, true), 'Must validate the resolved methods')
    end

    -- Some lookup implementations accept both strings for the same UClass.
    -- The class's actual spelling wins, even if the uppercase query found it.
    x = fixture(spelling)
    local alias = x.object('Class ' .. prefix .. spelling)
    alias.address, alias.short_name, alias.is_class = x.api.table_class.address, spelling, true
    x.reflection[prefix .. other] = alias
    x.api = Game.contract(); tick(x)
    assert(x.api.table_name == spelling and #x.calls == 2)

    for _, method in ipairs({ 'IsTableOccupied', 'IsCustomerOrderWaitActive',
        'GetCustomerWaitElapsedTime', 'GetCustomerWaitTime' }) do
        for _, invalid in ipairs({ false, true }) do
            x = fixture(spelling)
            local path = prefix .. spelling .. ':' .. method
            x.reflection[prefix .. other .. ':' .. method] = x.object('other-method')
            if invalid then x.reflection[path].valid = false else x.reflection[path] = nil end
            local ok, err = pcall(Game.contract)
            assert(not ok and tostring(err):find(path, 1, true) and #x.calls == 0,
                'A missing selected-class method cannot be borrowed from the other spelling')
        end
    end
end

for _, change in ipairs({
    function(x) x.reflection[prefix .. 'table'] = nil end,
    function(x) x.api.table_class.valid = false end,
    function(x) x.api.table_class.is_class = false end,
    function(x) x.api.table_class.name = 'Class /Script/Other.table' end,
    function(x) x.api.table_class.short_name = 'TABLE' end,
    function(x)
        local conflicting = x.object('Class ' .. prefix .. 'Table')
        conflicting.short_name, conflicting.is_class = 'Table', true
        x.reflection[prefix .. 'Table'] = conflicting
    end,
}) do
    local x = fixture(); change(x)
    assert(not pcall(Game.contract) and #x.calls == 0)
end

-- A short-name collision must never reach table methods or native ordering.
local x = fixture('Table'); x.api = Game.contract()
local unrelated = x.object('unrelated'); unrelated.class = x.object('other-class')
function unrelated:IsTableOccupied() error('Unrelated class cannot be read as a table') end
function unrelated:IsActorBeingDestroyed() error('Unrelated class cannot be read as an actor') end
x.objects.Table = { unrelated, x.table }
local session = Game.session(x.api)
local tickets = Game.candidates(x.api, session)
assert(#tickets == 2)
x.table.class = unrelated.class
function x.table:IsActorBeingDestroyed() error('Changed class cannot be read as an actor') end
assert(not Game.request(x.api, session, tickets[1]) and #x.calls == 0)
assert(#Game.candidates(x.api, session) == 0)

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

-- Dish lookup never materializes asset fields. All ingredient quantities go
-- through the stock check while the native request retains the original row.
f = fixture(); f.recipes[12][2] = { Ingredient = 44, Amount = 3 }; f.stock[44] = 2
tick(f); assert(not f.row.bDishOrdered and f.row.bDrinkOrdered and #f.calls == 1)
f.stock[44] = 3; tick(f)
assert(f.row.bDishOrdered and f.stock[44] == 0 and #f.calls == 2)
assert(f.checked_ingredients ~= f.recipes[12] and f.checked_ingredients[1] ~= f.recipes[12][1])
assert(f.checked_ingredients[2].Ingredient == 44 and f.checked_ingredients[2].Amount == 3)
f = fixture(); f.catalog.DishesTable = nil; tick(f); assert(#f.calls == 0)
f = fixture(); f.data_rows[12] = nil; tick(f)
assert(#f.calls == 1 and not f.row.bDishOrdered and f.row.bDrinkOrdered)
for _, change in ipairs({
    function(x) function x.catalog.DishesTable:GetRowStruct() return x.object('other-schema') end end,
    function(x) x.data_rows[12].valid = false end,
    function(x) x.data_rows[12].unmapped = true end,
    function(x) x.data_rows.duplicate = x.data_rows[12] end,
    function(x) x.recipes[12][1].Amount = -1 end,
    function(x) x.recipes[12][1].Ingredient = 'invalid' end,
}) do
    f = fixture(); change(f); assert(not pcall(tick, f) and #f.calls == 0)
end
print('game_spec: class resolution, table discovery, restocking, native orders, authority and uncertainty passed')
