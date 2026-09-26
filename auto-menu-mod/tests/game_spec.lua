local F, Game, Planner = require('fakes'), require('game'), require('planner')
local state = F.setup()
local original = Planner.copy(state.manager.LunchDailyMenu)
state.on_save = function()
    for key, value in pairs(original) do assert(state.manager.LunchDailyMenu[key] == value) end
end
local result = Game.compose(state.owner)
assert(result.evaluations == 243 and result.menu.MainDish == 21)
assert(state.saves == 1 and state.refreshes == 1 and state.manager.DinnerDailyMenu.MainDish == 0)
state.owner.SelectedDailyMenuPeriod = 2; state.on_save = nil
result = Game.compose(state.owner)
assert(state.saves == 2 and state.manager.DinnerDailyMenu.MainDish == 20 and state.manager.LunchDailyMenu.MainDish == 21)

state = F.setup()
state.manager.AvailableDishes = F.array({10, 11, 20, 21})
state.manager.UnlockedDailyDishes = F.array({30})
state.manager.DisabledDishes = F.array({11})
state.manager.EmployeeRequirementDisabledDishes = F.array({21})
local selectors = state.owner.WBP_DailyMenu_Starter.WBP_DailyMenu_DishSelector.DishOptions.entries
selectors[#selectors + 1] = selectors[1]
result = Game.compose(state.owner)
assert(result.combinations == 4)
local domains = state.request.domains
assert(table.concat(domains.Starter, ',') == '0,10' and table.concat(domains.MainDish, ',') == '0,20')
assert(#domains.Dessert == 1 and #domains.Aperitif == 1 and #domains.EndDrink == 1)
state = F.setup()
state.owner.WBP_DailyMenu_Starter.WBP_DailyMenu_DishSelector.DishOptions.entries[1].bEnabled = false
state.owner.WBP_DailyMenu_MainDish.WBP_DailyMenu_DishSelector.DishOptions.entries[1].DishType = 3
result = Game.compose(state.owner); assert(result.combinations == 108)
state = F.setup(); state.manager.AvailableDishes = F.array({})
state.manager.LunchDailyMenu.MainDish = 20
result = Game.compose(state.owner)
assert(result.evaluations == 1 and state.saves == 1 and state.manager.LunchDailyMenu.MainDish == 0)
assert(not state.manager.LunchDailyMenu.bIsActive)
state = F.setup(); state.manager.LunchDailyMenu.MainDish = 21
Game.compose(state.owner); assert(state.request.domains.MainDish[1] == 21, 'Current choices must lead tie order')

for _, change in ipairs({
    function(s) s.client = true end, function(s) s.remote = true end,
    function(s) s.hidden = true end, function(s) s.other_page = true end,
    function(s) s.destroying = true end, function(s) s.owner.SelectedDailyMenuPeriod = 0 end,
}) do
    state = F.setup(); change(state)
    assert(not pcall(Game.compose, state.owner) and state.saves == 0 and not state.request)
end
state = F.setup(); state.manager.LunchDailyMenu.MainDish = 20
original = Planner.copy(state.manager.LunchDailyMenu)
state.native_override = function(storage)
    storage.MainDish = 21
    error('Synthetic native failure')
end
assert(not pcall(Game.compose, state.owner) and state.saves == 0)
for key, value in pairs(original) do assert(state.manager.LunchDailyMenu[key] == value) end
state = F.setup(); state.reject = true
assert(not pcall(Game.compose, state.owner) and state.saves == 1 and not state.refreshes)
print('Game: eligible domains, current choice ordering, empty/native apply, host checks and failure restoration passed')
