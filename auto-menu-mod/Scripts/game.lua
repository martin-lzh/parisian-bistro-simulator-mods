-- All engine access runs on the game thread. No transient struct-array results
-- are retained, and candidate projections never invoke the menu save path.
local Game = {}
local Planner = require('planner')

function Game.valid(object) return object ~= nil and object:IsValid() end
function Game.same(a, b)
    return Game.valid(a) and Game.valid(b) and a:GetAddress() == b:GetAddress()
end
function Game.identity(object) return object:GetFullName() .. '@' .. tostring(object:GetAddress()) end

function Game.host(owner)
    if not Game.valid(owner) or owner:HasAnyFlags(0x10 | 0x20)
        or not owner:IsA('/Game/UI/Computer/Apps/Menu/WBP_MenuApp.WBP_MenuApp_C') then return false end
    local player, manager = owner:GetOwningPlayer(), owner.BoundDailyMenuBrasserieManager
    return Game.valid(player) and player:IsLocalController() and player:HasAuthority()
        and Game.valid(manager) and manager:HasAuthority() and not manager:IsActorBeingDestroyed()
        and Game.same(owner:GetWorld(), player:GetWorld())
        and Game.same(manager:GetWorld(), player:GetWorld())
end

function Game.available(owner)
    return Game.host(owner) and owner:IsVisible() and owner:IsShowingDailyMenuCategory()
        and (owner.SelectedDailyMenuPeriod == 1 or owner.SelectedDailyMenuPeriod == 2)
end

local function array(values, copy)
    assert(values and values:IsValid(), 'Array storage unavailable')
    local result, count = {}, values:GetArrayNum()
    values:ForEach(function(index, value)
        assert(index == #result + 1, 'Unexpected array indexing')
        result[index] = copy(value:get())
    end)
    assert(#result == count, 'Array changed during snapshot')
    return result
end

local function equal(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= 'table' then return a == b end
    for key, value in pairs(a) do if not equal(value, b[key]) then return false end end
    for key in pairs(b) do if a[key] == nil then return false end end
    return true
end

local function menu_copy(menu)
    local result = { Period = menu.Period, bIsActive = menu.bIsActive }
    for _, course in ipairs(Planner.courses) do result[course.field] = menu[course.field] end
    return result
end

local function property(period) return period == 1 and 'LunchDailyMenu' or 'DinnerDailyMenu' end
local function current(owner, period)
    return menu_copy(owner.BoundDailyMenuBrasserieManager[property(period)])
end

local function distribution(values, field)
    local total, seen = 0, {}
    local result = array(values, function(value)
        local id, probability = value[field], value.Probability
        assert(type(id) == 'number' and not seen[id] and Planner.finite(probability) and probability >= 0,
            'Invalid native forecast')
        seen[id], total = true, total + probability
        return { id = id, probability = probability }
    end)
    assert(Planner.finite(total) and total > 0, 'Native forecast unavailable')
    return result
end

local function capture(owner)
    local manager, period = owner.BoundDailyMenuBrasserieManager, owner.SelectedDailyMenuPeriod
    local data = manager.DailyCustomerContext
    local forecast = period == 1 and data.LunchForecast or data.DinnerForecast
    assert(forecast.Period == period, 'Native forecast period mismatch')
    local result = { period = period, current = current(owner, period), options = {},
        day = data.DayNumber, event = data.LocalEvent, temperature = data.TemperatureBand,
        ceiling = manager:GetDailyMenuMaximumPromotedAdoptionChance() }
    -- These are change guards only. Scores come exclusively from the native projection.
    result.inputs = { manager = Game.identity(manager), world = Game.identity(owner:GetWorld()),
        weekday = data.WeekDay, celsius = data.TemperatureCelsius,
        profiles = distribution(forecast.ProfileProbabilities, 'Profile'),
        intents = distribution(forecast.IntentProbabilities, 'Intent'),
        influence = manager:GetDailyMenuInfluence(), bonus = manager.DailyMenuMaxAdoptionChanceBonus,
        tier = manager:GetTier(), difficulty = manager:GetDifficulty(), satisfaction = manager:GetSatisfaction() }
    assert(Planner.finite(result.inputs.influence) and Planner.finite(result.inputs.bonus),
        'Native adoption inputs unavailable')
    for _, name in ipairs({ 'AvailableDishes', 'UnlockedDailyDishes', 'DisabledDishes', 'EmployeeRequirementDisabledDishes' }) do
        result.inputs[name] = array(manager[name], function(value) return value end)
    end
    for _, course in ipairs(Planner.courses) do
        local row = owner['WBP_DailyMenu_' .. course.field]
        assert(Game.valid(row) and Game.valid(row.WBP_DailyMenu_DishSelector), 'Course selector unavailable')
        local options = array(row.WBP_DailyMenu_DishSelector.DishOptions, function(dish)
            return { id = dish.Key, kind = dish.DishType, enabled = dish.bEnabled }
        end)
        for _, option in ipairs(options) do
            option.stock = not owner:IsDishMissingIngredients(option.id)
            option.price = manager:GetDishPrice(option.id)
            assert(Planner.finite(option.price), 'Dish price unavailable')
        end
        result.options[course.field] = options
    end
    return result
end

function Game.snapshot(owner)
    assert(Game.available(owner), 'Daily menu is not available to this host')
    owner:RefreshDailyMenus()
    return capture(owner)
end

function Game.unchanged(owner, snapshot)
    return Game.available(owner) and owner.SelectedDailyMenuPeriod == snapshot.period
        and equal(snapshot, capture(owner))
end

function Game.evaluate(owner, snapshot, menu)
    local manager, name = owner.BoundDailyMenuBrasserieManager, property(snapshot.period)
    local original = current(owner, snapshot.period)
    assert(equal(original, snapshot.current), 'Menu changed before projection')
    assert(menu.Period == snapshot.period and menu.bIsActive == original.bIsActive, 'Invalid candidate menu')
    -- The native pure projection accepts a period, not a candidate. Substitute
    -- the seven-field definition only for this synchronous call, without events,
    -- RPCs, saves or yields. Restore even if assignment or projection throws.
    local ok, rate = pcall(function()
        manager[name] = menu
        assert(equal(menu, menu_copy(owner:GetDailyMenu(snapshot.period))), 'Native menu binding changed')
        local projection = owner:GetDailyMenuProjection(snapshot.period)
        assert(projection.Period == snapshot.period and projection.bConfigured, 'Native projection unavailable')
        return projection.EstimatedAdoptionRate
    end)
    local restored, restore_error = pcall(function() manager[name] = original end)
    if not restored then
        -- An individual-field fallback also repairs a partially failed table assignment.
        restored, restore_error = pcall(function()
            local storage = manager[name]
            for key, value in pairs(original) do storage[key] = value end
        end)
    end
    assert(restored and equal(original, current(owner, snapshot.period)),
        'Failed to restore menu after projection: ' .. tostring(restore_error))
    if not ok then error(rate) end
    assert(Planner.finite(rate) and rate >= 0 and rate <= snapshot.ceiling, 'Invalid native adoption rate')
    return rate
end

function Game.apply(owner, snapshot, menu, expected_rate)
    assert(Game.unchanged(owner, snapshot), 'Projection inputs changed before apply')
    assert(Game.evaluate(owner, snapshot, menu) == expected_rate, 'Native prediction changed before apply')
    -- Only the winning menu enters normal native validation and replication.
    owner:SaveDailyMenu(menu)
    assert(equal(menu, current(owner, snapshot.period)), 'Native menu save did not accept the selection')
    owner:RefreshDailyMenus()
end

function Game.language()
    local ok, value = pcall(function()
        local library = StaticFindObject('/Script/Engine.Default__KismetInternationalizationLibrary')
        local language = library:GetCurrentLanguage()
        return type(language) == 'string' and language or language:ToString()
    end)
    return ok and value or 'en'
end

return Game
