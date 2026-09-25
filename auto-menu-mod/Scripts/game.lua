-- Game-thread adapter. Read persistent manager/widget storage, never temporary
-- struct-array return values from reflected functions.
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
    local result = {}
    local count = values:GetArrayNum()
    values:ForEach(function(index, value)
        assert(index == #result + 1, 'Unexpected array indexing')
        result[index] = copy(value:get())
    end)
    assert(#result == count, 'Array changed during snapshot')
    return result
end

local function menu_copy(menu)
    local result = { Period = menu.Period, bIsActive = menu.bIsActive }
    for _, course in ipairs(Planner.courses) do result[course.field] = menu[course.field] end
    return result
end

local function current(owner, period)
    local manager = owner.BoundDailyMenuBrasserieManager
    return menu_copy(period == 1 and manager.LunchDailyMenu or manager.DinnerDailyMenu)
end

local function context(owner)
    local data = owner.BoundDailyMenuBrasserieManager.DailyCustomerContext
    return { day = data.DayNumber, event = data.LocalEvent, temperature = data.TemperatureBand }
end

local function forecast(list, class, field, id)
    assert(Game.valid(list), 'Forecast list unavailable')
    local result = {}
    for index = 0, list:GetNumItems() - 1 do
        local item = list:GetItemAt(index)
        assert(Game.valid(item) and item:IsA(class), 'Forecast item unavailable')
        local value = item[field]
        result[#result + 1] = { id = value[id], probability = value.Probability }
    end
    return result
end

function Game.snapshot(owner)
    assert(Game.available(owner), 'Daily menu is not available to this host')
    -- Native refresh repopulates each selector using GetDailyMenuDishOptions.
    owner:RefreshDailyMenus()
    local period = owner.SelectedDailyMenuPeriod
    local result = context(owner)
    result.period, result.current, result.options = period, current(owner, period), {}
    -- Read the same main-service forecast displayed by the native page, which
    -- can differ from the manager's unfiltered all-customer forecast.
    local prefix = '/Game/UI/Computer/Apps/Menu/DailyMenus/'
    result.profiles = forecast(owner.ForecastProfileListView,
        prefix .. 'BP_ProfileForecastItemData.BP_ProfileForecastItemData_C', 'CustomerProfile', 'Profile')
    result.intents = forecast(owner.ForecastIntentListView,
        prefix .. 'BP_IntentForecastItemData.BP_IntentForecastItemData_C', 'CustomerIntent', 'Intent')
    for _, course in ipairs(Planner.courses) do
        local row = owner['WBP_DailyMenu_' .. course.field]
        assert(Game.valid(row) and Game.valid(row.WBP_DailyMenu_DishSelector), 'Course selector unavailable')
        result.options[course.field] = array(row.WBP_DailyMenu_DishSelector.DishOptions, function(dish)
            local option = { id = dish.Key, kind = dish.DishType, enabled = dish.bEnabled, tags = {} }
            for _, tag in ipairs(array(dish.RecommendationTags, function(value) return value end)) do
                option.tags[tag] = true
            end
            return option
        end)
        -- No engine calls inside the struct-array copy above.
        for _, option in ipairs(result.options[course.field]) do
            option.stock = not owner:IsDishMissingIngredients(option.id)
        end
    end
    return result
end

local function same_menu(a, b)
    for key, value in pairs(a) do if b[key] ~= value then return false end end
    return true
end

function Game.apply(owner, snapshot, menu)
    assert(Game.available(owner) and owner.SelectedDailyMenuPeriod == snapshot.period,
        'Service changed before apply')
    local now = context(owner)
    assert(now.day == snapshot.day and now.event == snapshot.event and now.temperature == snapshot.temperature,
        'Daily context changed before apply')
    assert(same_menu(snapshot.current, current(owner, snapshot.period)), 'Menu changed before apply')
    assert(menu.Period == snapshot.period and menu.bIsActive == snapshot.current.bIsActive, 'Invalid menu request')
    -- One normal save, matching manual editing. Native save owns validation,
    -- replication and activation state; never write the manager's menu directly.
    owner:SaveDailyMenu(menu)
    assert(same_menu(menu, current(owner, snapshot.period)), 'Native menu save did not accept the selection')
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
