local F = require('fakes')
local state = F.setup()
local function boot() dofile(MOD_ROOT .. '/Scripts/main.lua'); state.loops[500]() end
boot()
local button = state.footer.children[2]
assert(button and button.text == 'Auto-compose' and #state.footer.children == 2 and state.saves == 0)
for interval in pairs(state.loops) do assert(interval == 500, 'Only widget discovery needs a timer') end
state:click(state.owner.PrintMenuButton); assert(state.saves == 0)
state:click(button)
assert(state.saves == 1 and state.manager.LunchDailyMenu.MainDish == 21 and button.text == 'Auto-compose')
state.owner.SelectedDailyMenuPeriod = 2; state.loops[500]()
state.on_save = function() state:click(button) end
state:click(button); state.on_save = nil
assert(state.saves == 2 and state.manager.DinnerDailyMenu.MainDish == 20, 'Reentrant clicks must not recurse')
state.language = 'zh-CN'; state.loops[500](); assert(button.text == '自动组合')
state.client = true; state:click(button); assert(state.saves == 2)
state.client = false
state.projection_error = true; state:click(button)
assert(state.saves == 2 and button.text == '自动组合' and state.manager.DinnerDailyMenu.MainDish == 20)
state.projection_error = false; state:click(button); assert(state.saves == 3, 'Failures must release click handling')
local old_tick, old_button = state.loops[500], button
ModRef.OnUnload(); assert(old_tick() == true)
state:click(old_button, 1); assert(state.saves == 3)
boot(); assert(#state.footer.children == 2 and state.footer.children[2] ~= old_button)
state:click(old_button); assert(state.saves == 3)
state.client = true; state.loops[500](); assert(#state.footer.children == 1)
state.client = false; state.loops[500](); assert(#state.footer.children == 2)
print('Runtime: one click applies, no progress or search timer, reentrancy, errors, languages and reload passed')
