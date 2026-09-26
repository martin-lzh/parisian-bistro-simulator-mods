local F, Game, Planner = require('fakes'), require('game'), require('planner')
local state = F.setup()
local original = Planner.copy(state.manager.LunchDailyMenu)
state.on_save = function()
    for key, value in pairs(original) do assert(state.manager.LunchDailyMenu[key] == value) end
end
local result = Game.compose(state.owner)
assert(result.evaluations == 243 and result.rate == 0.8 and result.menu.MainDish == 21)
assert(state.saves == 1 and state.manager.LunchDailyMenu.MainDish == 21 and state.refreshes == 1)
assert(state.manager.DinnerDailyMenu.MainDish == 0 and state.manager.LunchDailyMenu.bIsActive)
state.owner.SelectedDailyMenuPeriod = 2; state.on_save = nil
result = Game.compose(state.owner)
assert(state.saves == 2 and state.manager.DinnerDailyMenu.MainDish == 20 and state.manager.LunchDailyMenu.MainDish == 21)

-- Never add locked, inactive, unstaffed, wrong-category or duplicate selector entries.
state = F.setup()
state.manager.AvailableDishes = F.array({10, 11, 20, 21})
state.manager.UnlockedDailyDishes = F.array({30})
state.manager.DisabledDishes = F.array({11})
state.manager.EmployeeRequirementDisabledDishes = F.array({21})
local selectors = state.owner.WBP_DailyMenu_Starter.WBP_DailyMenu_DishSelector.DishOptions.entries
selectors[#selectors + 1] = selectors[1]
state.oracle = function(menu)
    assert((menu.Starter == 0 or menu.Starter == 10) and (menu.MainDish == 0 or menu.MainDish == 20))
    assert(menu.Dessert == 0 and menu.Aperitif == 0 and menu.EndDrink == 0)
    return 0.3
end
result = Game.compose(state.owner); assert(result.evaluations == 4)
state = F.setup()
state.owner.WBP_DailyMenu_Starter.WBP_DailyMenu_DishSelector.DishOptions.entries[1].bEnabled = false
state.owner.WBP_DailyMenu_MainDish.WBP_DailyMenu_DishSelector.DishOptions.entries[1].DishType = 3
result = Game.compose(state.owner); assert(result.evaluations == 108)

state = F.setup(); state.manager.AvailableDishes = F.array({})
state.manager.LunchDailyMenu.MainDish = 20
result = Game.compose(state.owner)
assert(result.evaluations == 1 and result.rate == 0 and state.saves == 1)
assert(state.manager.LunchDailyMenu.MainDish == 0 and not state.manager.LunchDailyMenu.bIsActive)
state = F.setup(); state.manager.LunchDailyMenu.MainDish = 21
state.oracle = function() return 0.4 end
result = Game.compose(state.owner)
assert(result.menu.MainDish == 21 and result.menu.Starter == 0, 'Keep an eligible current menu on ties')

for _, change in ipairs({
    function(s) s.client = true end, function(s) s.remote = true end,
    function(s) s.hidden = true end, function(s) s.other_page = true end,
    function(s) s.destroying = true end, function(s) s.owner.SelectedDailyMenuPeriod = 0 end,
}) do
    state = F.setup(); change(state)
    assert(not pcall(Game.compose, state.owner) and state.saves == 0)
end

-- A later projection error restores the original menu without saving trials.
state = F.setup(); state.manager.LunchDailyMenu.MainDish = 20
original = Planner.copy(state.manager.LunchDailyMenu)
local calls = 0
state.oracle = function()
    calls = calls + 1
    if calls == 3 then error('Synthetic native failure') end
    return 0.4
end
assert(not pcall(Game.compose, state.owner) and state.saves == 0 and calls == 3)
for key, value in pairs(original) do assert(state.manager.LunchDailyMenu[key] == value) end

-- Reuse the inline struct and write only changed courses, then restore the
-- original definition before saving once. Even partially failed writes restore.
state = F.setup()
local fields, last, writes = state.manager.LunchDailyMenu, {}, 0
for key, value in pairs(fields) do last[key] = value end
state.manager.LunchDailyMenu = setmetatable({}, {
    __index = fields,
    __newindex = function(_, key, value)
        if key ~= 'Period' then assert(last[key] ~= value, 'Do not rewrite unchanged courses'); writes = writes + 1 end
        last[key], fields[key] = value, value
    end,
})
result = Game.compose(state.owner)
assert(writes < result.evaluations * 2 and writes > 0 and state.saves == 1)
state = F.setup(); fields = state.manager.LunchDailyMenu
state.manager.LunchDailyMenu = setmetatable({}, {
    __index = fields,
    __newindex = function(_, key, value)
        fields[key] = value
        if key == 'MainDish' and value == 20 then error('Synthetic partial field write') end
    end,
})
assert(not pcall(Game.compose, state.owner) and state.saves == 0 and state.manager.LunchDailyMenu.MainDish == 0)
state = F.setup(); state.reject = true
assert(not pcall(Game.compose, state.owner) and state.saves == 1, 'No repeated saves after a native refusal')
print('Adapter: active choices, native calls, empty menu, one save, field reuse and failure restoration passed')
