local F, Game, Planner = require('fakes'), require('game'), require('planner')
local state = F.setup()
local snapshot = Game.snapshot(state.owner)
assert(snapshot.day == 7 and snapshot.period == 1 and #snapshot.options.MainDish == 2)
local native_tags = state.owner.WBP_DailyMenu_MainDish.WBP_DailyMenu_DishSelector.DishOptions.entries[1].RecommendationTags
native_tags.entries[1] = 17
assert(snapshot.options.MainDish[1].tags[3], 'Snapshot must own plain tag data')
local menu = Planner.plan(snapshot)
Game.apply(state.owner, snapshot, menu)
assert(state.saves == 1 and state.manager.LunchDailyMenu.MainDish == 20)
assert(state.manager.DinnerDailyMenu.MainDish == 0 and state.manager.LunchDailyMenu.bIsActive)

local function rejected(change)
    state = F.setup()
    snapshot = Game.snapshot(state.owner); menu = Planner.plan(snapshot)
    change(state)
    assert(not pcall(Game.apply, state.owner, snapshot, menu))
    assert(state.saves == 0, 'Rejected apply must not save any courses')
end
rejected(function(s) s.client = true end)
rejected(function(s) s.remote = true end)
rejected(function(s) s.hidden = true end)
rejected(function(s) s.other_page = true end)
rejected(function(s) s.destroying = true end)
rejected(function(s) s.owner.SelectedDailyMenuPeriod = 2 end)
rejected(function(s) s.manager.DailyCustomerContext.DayNumber = 8 end)
rejected(function(s) s.manager.DailyCustomerContext.LocalEvent = 4 end)
rejected(function(s) s.manager.DailyCustomerContext.TemperatureBand = 3 end)
rejected(function(s) s.manager.LunchDailyMenu.MainDish = 99 end)
rejected(function(s) s.manager.GetWorld = function() return s.object('World') end end)

state = F.setup(); state.owner.SelectedDailyMenuPeriod = 2
snapshot = Game.snapshot(state.owner)
menu = Planner.plan(snapshot); Game.apply(state.owner, snapshot, menu)
assert(state.manager.DinnerDailyMenu.MainDish == 21 and state.manager.LunchDailyMenu.MainDish == 0)
state = F.setup(); snapshot = Game.snapshot(state.owner); state.reject = true
assert(not pcall(Game.apply, state.owner, snapshot, Planner.plan(snapshot)), 'Native refusal must be detected')
assert(state.saves == 1)
state = F.setup(); state.displayed_forecast = state.manager.DailyCustomerContext.DinnerForecast
assert(Planner.plan(Game.snapshot(state.owner)).MainDish == 21,
    'The displayed main-service forecast takes priority over the raw daily context')
print('Adapter: persistent snapshots, one native save, service/world/authority guards and refusal passed')
