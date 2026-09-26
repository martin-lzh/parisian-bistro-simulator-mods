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

local function membership(array)
    local set = {}
    array:ForEach(function(_, value) set[value:get()] = true end)
    return set
end

local function choices(owner, current)
    local manager = owner.BoundDailyMenuBrasserieManager
    local available, disabled = membership(manager.AvailableDishes), membership(manager.DisabledDishes)
    local unstaffed, domains = membership(manager.EmployeeRequirementDisabledDishes), {}
    for _, course in ipairs(Planner.courses) do
        local ids, seen = { 0 }, { [0] = true }
        local selector = owner['WBP_DailyMenu_' .. course.field].WBP_DailyMenu_DishSelector
        selector.DishOptions:ForEach(function(_, value)
            local dish = value:get()
            local id = dish.Key
            if dish.DishType == course.kind and dish.bEnabled and available[id]
                and not disabled[id] and not unstaffed[id] and not seen[id] then
                seen[id] = true; ids[#ids + 1] = id
            end
        end)
        table.sort(ids, function(a, b)
            if (a == current[course.field]) ~= (b == current[course.field]) then return a == current[course.field] end
            return a < b
        end)
        domains[course.field] = ids
    end
    return domains
end

function Game.compose(owner)
    assert(Game.available(owner), 'Daily menu is not available to this host')
    local manager, period = owner.BoundDailyMenuBrasserieManager, owner.SelectedDailyMenuPeriod
    local name = period == 1 and 'LunchDailyMenu' or 'DinnerDailyMenu'
    local storage = manager[name] -- Inline property view, retained only during this synchronous call.
    local original = Planner.copy(storage)
    local template, applied = Planner.copy(original), Planner.copy(original)
    template.Period = period
    local domains = choices(owner, original)
    local ceiling = manager:GetDailyMenuMaximumPromotedAdoptionChance()
    -- Everything runs inside the click's game-thread callback. No delays,
    -- sampled simulation writes or repeated condition scans are needed.
    local ok, result = pcall(function()
        storage.Period = period
        return Planner.solve(domains, template, function(menu)
            for _, course in ipairs(Planner.courses) do
                local field = course.field
                if applied[field] ~= menu[field] then
                    storage[field] = menu[field]; applied[field] = menu[field]
                end
            end
            return owner:GetDailyMenuProjection(period).EstimatedAdoptionRate
        end, ceiling)
    end)
    -- Trial writes never use the save path. Restore even if a native call fails.
    manager[name] = original
    if not ok then error(result) end
    owner:SaveDailyMenu(result.menu)
    local saved = manager[name]
    for _, course in ipairs(Planner.courses) do
        assert(saved[course.field] == result.menu[course.field], 'Native menu save did not accept the selection')
    end
    owner:RefreshDailyMenus()
    return result
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
