local F = require('fakes')
local state = F.setup()
local function boot() dofile(MOD_ROOT .. '/Scripts/main.lua'); state.loops[500]() end
boot()
local button = state.footer.children[2]
assert(button and button.text == 'Auto-compose' and #state.footer.children == 2)
assert(state.saves == 0, 'Opening the UI must not edit menus')
state:click(state.owner.PrintMenuButton); assert(state.saves == 0)
state:click(button)
assert(state.saves == 0 and button.text:find('Searching', 1, true), 'Search is asynchronous')
state.loops[16]()
assert(state.saves == 0 and state.manager.LunchDailyMenu.MainDish == 0, 'No intermediate save or candidate left installed')
state:click(button)
assert(button.text == 'Composition cancelled' and state.saves == 0)
state.loops[16](); assert(state.saves == 0)
state.manager.DailyMenuInfluence = 0.8
state:click(button)
for index = 1, 1000 do
    state.decay = index * 0.0001
    state.manager.Satisfaction = 1 - index * 0.0001
    state.loops[16]()
    if not button.text:find('%d+%%') then break end
end
assert(state.saves == 1 and button.text == 'Menu composed' and state.manager.LunchDailyMenu.MainDish == 21)
state.owner.SelectedDailyMenuPeriod = 2; state.loops[500]()
assert(button.text == 'Auto-compose')
state.on_save = function() state:click(button) end
state:click(button); state:complete(); state.on_save = nil
assert(state.saves == 2 and state.manager.DinnerDailyMenu.MainDish == 20, 'Reentrant clicks must not recurse or cancel a save')
state.language = 'zh-CN'; state.loops[500]()
assert(button.text == '菜单已组合')
for _ = 1, 7 do state.loops[500]() end
assert(button.text == '自动组合')
state.client = true; state:click(button); assert(state.saves == 2)
state.client = false
state:click(button); state.missing = 20; state.loops[16]()
assert(state.saves == 2 and button.text == '条件已变化，请重新组合')
state.missing = nil
state:click(button); state.owner.SelectedDailyMenuPeriod = 1; state.loops[16]()
assert(state.saves == 2, 'Changing services cancels pending work')
state.owner.SelectedDailyMenuPeriod = 2; state.loops[500]()
state:click(button); state.projection_error = true; state.loops[16]()
assert(state.saves == 2 and button.text == '组合失败' and state.manager.DinnerDailyMenu.MainDish == 20)
state.projection_error = nil
state.manager.DailyCustomerContext.DinnerForecast.ProfileProbabilities = F.array({})
state:click(button); assert(state.saves == 2 and button.text == '组合失败')
state.manager.DailyCustomerContext.DinnerForecast.ProfileProbabilities = F.array({ { Profile = 1, Probability = 1 } })

local old_search, old_tick, old_button = state.loops[16], state.loops[500], button
state:click(button)
ModRef.OnUnload()
assert(old_tick() == true and old_search() == true)
state:click(old_button, 1); assert(state.saves == 2)
boot()
assert(#state.footer.children == 2 and state.footer.children[2] ~= old_button)
state:click(old_button); assert(state.saves == 2, 'Old button identity cannot trigger a save')
button = state.footer.children[2]
state:click(button); state.client = true; state.loops[500](); state.loops[16]()
assert(#state.footer.children == 1 and state.saves == 2, 'Losing authority cancels and removes the button')
state.client = false; state.loops[500]()
assert(#state.footer.children == 2)
button = state.footer.children[2]
for _, course in ipairs(require('planner').courses) do
    state.owner['WBP_DailyMenu_' .. course.field].WBP_DailyMenu_DishSelector.DishOptions = F.array({})
end
state:click(button); assert(state.saves == 2 and button.text == '没有可选菜品')
print('Runtime: asynchronous completion, cancellation, input changes, errors, localization, reload and authority passed')
