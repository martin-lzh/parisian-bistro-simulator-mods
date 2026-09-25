local F = require('fakes')
local state = F.setup()
local function boot() dofile(MOD_ROOT .. '/Scripts/main.lua'); state.ticks[#state.ticks]() end
boot()
local button = state.footer.children[2]
assert(button and button.text == 'Auto-compose' and #state.footer.children == 2)
assert(state.saves == 0, 'Opening the UI must not edit menus')
state:click(state.owner.PrintMenuButton); assert(state.saves == 0)
state:click(button)
assert(state.saves == 1 and button.text == 'Menu composed')
state.owner.SelectedDailyMenuPeriod = 2; state.ticks[1]()
assert(button.text == 'Auto-compose')
state.on_save = function() state:click(button) end
state:click(button); state.on_save = nil
assert(state.saves == 2 and state.manager.DinnerDailyMenu.MainDish == 21, 'Reentrant clicks must not recurse')
state.language = 'zh-CN'; state.ticks[1]()
assert(button.text == '菜单已组合')
for _ = 1, 7 do state.ticks[1]() end
assert(button.text == '自动组合')
state.client = true; state:click(button); assert(state.saves == 2)
state.client = false
state.manager.DailyCustomerContext.DinnerForecast.ProfileProbabilities = F.array({})
state:click(button); assert(state.saves == 2 and button.text == '组合失败')
state.manager.DailyCustomerContext.DinnerForecast.ProfileProbabilities = F.array({ { Profile = 1, Probability = 1 } })
for _, course in ipairs(require('planner').courses) do
    state.owner['WBP_DailyMenu_' .. course.field].WBP_DailyMenu_DishSelector.DishOptions = F.array({})
end
state:click(button); assert(state.saves == 2 and button.text == '没有可选菜品')

local old_tick, old_button = state.ticks[1], button
ModRef.OnUnload()
assert(old_tick() == true)
state:click(old_button, 1); assert(state.saves == 2)
boot()
assert(#state.footer.children == 2 and state.footer.children[2] ~= old_button)
state:click(old_button); assert(state.saves == 2, 'Old button identity cannot trigger a save')
state.client = true; state.ticks[2]()
assert(#state.footer.children == 1, 'Losing authority removes the button')
state.client = false; state.ticks[2]()
assert(#state.footer.children == 2)
print('Runtime: UI clicks, foreign buttons, no automatic edits, localization, reload and authority changes passed')
