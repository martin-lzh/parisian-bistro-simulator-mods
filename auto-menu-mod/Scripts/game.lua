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

local function difference(a, b, path)
    if type(a) ~= type(b) then return path end
    if type(a) ~= 'table' then return a ~= b and path or nil end
    for key, value in pairs(a) do
        local changed = difference(value, b[key], path .. '.' .. tostring(key))
        if changed then return changed end
    end
    for key in pairs(b) do if a[key] == nil then return path .. '.' .. tostring(key) end end
end
local function equal(a, b) return difference(a, b, 'inputs') == nil end

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
    table.sort(result, function(a, b) return a.id < b.id end)
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
        bonus = manager.DailyMenuMaxAdoptionChanceBonus,
        tier = manager:GetTier(), difficulty = manager:GetDifficulty() }
    result.sample = { influence = manager:GetDailyMenuInfluence(), satisfaction = manager:GetSatisfaction() }
    assert(Planner.finite(result.sample.influence) and result.sample.influence >= 0 and result.sample.influence <= 1
        and Planner.finite(result.sample.satisfaction) and Planner.finite(result.inputs.bonus),
        'Native adoption inputs unavailable')
    for _, name in ipairs({ 'AvailableDishes', 'UnlockedDailyDishes', 'DisabledDishes', 'EmployeeRequirementDisabledDishes' }) do
        result.inputs[name] = array(manager[name], function(value) return value end)
        table.sort(result.inputs[name])
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
        table.sort(options, function(a, b) return a.id < b.id end)
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
    if not Game.available(owner) then return false, 'view_or_authority' end
    if owner.SelectedDailyMenuPeriod ~= snapshot.period then return false, 'period' end
    local now = capture(owner)
    -- Influence decay and satisfaction updates are normal simulation progress.
    -- Every trial uses the same sampled values; live values are checked at apply.
    now.sample = snapshot.sample
    local reason = difference(snapshot, now, 'inputs')
    return reason == nil, reason
end

local function nonempty(menu)
    for _, course in ipairs(Planner.courses) do if menu[course.field] ~= 0 then return true end end
    return false
end

function Game.evaluate(owner, snapshot, menu, live)
    local manager, name = owner.BoundDailyMenuBrasserieManager, property(snapshot.period)
    local original = current(owner, snapshot.period)
    assert(equal(original, snapshot.current), 'Menu changed before projection')
    assert(menu.Period == snapshot.period and menu.bIsActive == original.bIsActive, 'Invalid candidate menu')
    local restore = { { name = name, value = original, menu = true } }
    if not live then
        for _, field in ipairs({ 'DailyMenuInfluence', 'DailyMenuInfluenceHalfLifeGameHours', 'Satisfaction' }) do
            local value = manager[field]
            assert(Planner.finite(value), 'Native sampled property unavailable: ' .. field)
            restore[#restore + 1] = { name = field, value = value }
        end
    end
    -- The native pure projection accepts a period, not a candidate. Substitute
    -- the seven-field definition only for this synchronous call, without events,
    -- RPCs, saves or yields. Restore even if assignment or projection throws.
    local ok, rate = pcall(function()
        manager[name] = menu
        if not live then
            manager.DailyMenuInfluence = snapshot.sample.influence
            -- The native getter accepts zero half-life as no decay. Use the
            -- already-native sampled influence without changing game time.
            manager.DailyMenuInfluenceHalfLifeGameHours = 0
            manager.Satisfaction = snapshot.sample.satisfaction
            assert(manager:GetDailyMenuInfluence() == snapshot.sample.influence
                and manager:GetSatisfaction() == snapshot.sample.satisfaction, 'Native sampled context mismatch')
        end
        assert(equal(menu, menu_copy(owner:GetDailyMenu(snapshot.period))), 'Native menu binding changed')
        local projection = owner:GetDailyMenuProjection(snapshot.period)
        assert(projection.Period == snapshot.period and projection.bConfigured == nonempty(menu),
            'Native projection unavailable')
        return projection.EstimatedAdoptionRate
    end)
    local restore_error
    -- Each property gets its own cleanup attempt: one setter failure must not
    -- skip restoring the remaining live state, including the original menu.
    for _, entry in ipairs(restore) do
        local restored, err = pcall(function() manager[entry.name] = entry.value end)
        if not restored and entry.menu then
            restored, err = pcall(function()
                local storage = manager[entry.name]
                for key, value in pairs(entry.value) do storage[key] = value end
            end)
        end
        local verified, matches = pcall(function()
            local value = entry.menu and menu_copy(manager[entry.name]) or manager[entry.name]
            return equal(entry.value, value)
        end)
        if not restored or not verified or not matches then restore_error = entry.name .. ': ' .. tostring(err) end
    end
    assert(not restore_error, 'Failed to restore projection state: ' .. tostring(restore_error))
    if not ok then error(rate) end
    assert(Planner.finite(rate) and rate >= 0 and rate <= snapshot.ceiling, 'Invalid native adoption rate')
    return rate
end

function Game.apply(owner, snapshot, menu, expected_rate)
    assert(Game.unchanged(owner, snapshot), 'Projection inputs changed before apply')
    assert(Game.evaluate(owner, snapshot, menu) == expected_rate, 'Native prediction changed before apply')
    local rate = Game.evaluate(owner, snapshot, menu, true)
    local existing = menu_copy(snapshot.current)
    existing.Period = snapshot.period
    local existing_rate = Game.evaluate(owner, snapshot, existing, true)
    if rate < existing_rate then
        -- A changed live ranking must not replace a better existing menu.
        owner:RefreshDailyMenus()
        return existing_rate, false
    end
    -- Only the winning menu enters normal native validation and replication.
    owner:SaveDailyMenu(menu)
    assert(equal(menu, current(owner, snapshot.period)), 'Native menu save did not accept the selection')
    owner:RefreshDailyMenus()
    return rate, true
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
