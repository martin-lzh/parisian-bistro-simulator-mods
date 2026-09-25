local F, Game, Planner = require('fakes'), require('game'), require('planner')
local function solve(state)
    local snapshot = Game.snapshot(state.owner)
    local job = assert(Planner.new(snapshot))
    while not job:step(function(menu) return Game.evaluate(state.owner, snapshot, menu) end, 100) do
        assert(Game.unchanged(state.owner, snapshot), 'Every query must restore the original menu')
    end
    return snapshot, job
end
local state = F.setup()
local snapshot, job = solve(state)
assert(state.saves == 0 and state.manager.LunchDailyMenu.MainDish == 0 and state.projections == 242)
assert(job.best.MainDish == 21 and job.best.Starter == 11, 'Use the native oracle, not old profile tag weights')
Game.apply(state.owner, snapshot, job.best, job.rate)
assert(state.saves == 1 and state.manager.LunchDailyMenu.MainDish == 21)
assert(state.manager.DinnerDailyMenu.MainDish == 0 and state.manager.LunchDailyMenu.bIsActive)

local function rejected(change)
    state = F.setup(); snapshot, job = solve(state)
    change(state)
    assert(not pcall(Game.apply, state.owner, snapshot, job.best, job.rate))
    assert(state.saves == 0, 'Changed projection inputs must prevent saving')
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
rejected(function(s) s.manager.DailyCustomerContext.LunchForecast.ProfileProbabilities.entries[1].Probability = 0.5 end)
rejected(function(s) s.manager.LunchDailyMenu.MainDish = 99 end)
rejected(function(s) s.manager.GetWorld = function() return s.object('World') end end)
rejected(function(s) s.prices[20] = 15 end)
rejected(function(s) s.missing = 20 end)
rejected(function(s) s.influence = 0.2 end)
rejected(function(s) s.tier = 1 end)
rejected(function(s) s.satisfaction = 0.5 end)
rejected(function(s) s.manager.DisabledDishes = F.array({20}) end)
rejected(function(s) s.oracle = function() return 0.7 end end)

state = F.setup(); state.owner.SelectedDailyMenuPeriod = 2
snapshot, job = solve(state)
Game.apply(state.owner, snapshot, job.best, job.rate)
assert(state.manager.DinnerDailyMenu.MainDish == 20 and state.manager.LunchDailyMenu.MainDish == 0)
state = F.setup(); snapshot, job = solve(state); state.reject = true
assert(not pcall(Game.apply, state.owner, snapshot, job.best, job.rate), 'Native refusal must be detected')
assert(state.saves == 1)
state = F.setup(); snapshot = Game.snapshot(state.owner)
local candidate = { Period = 1, bIsActive = true, Starter = 10, MainDish = 20, Dessert = 30, Aperitif = 40, EndDrink = 50 }
for _, fault in ipairs({ 'throw', 'nan', 'wrong_binding', 'unconfigured' }) do
    local original_projection, original_get = state.owner.GetDailyMenuProjection, state.owner.GetDailyMenu
    if fault == 'throw' then state.projection_error = true
    elseif fault == 'nan' then state.oracle = function() return 0/0 end
    elseif fault == 'wrong_binding' then state.owner.GetDailyMenu = function() return snapshot.current end
    else state.owner.GetDailyMenuProjection = function() return { Period = 1, bConfigured = false } end end
    assert(not pcall(Game.evaluate, state.owner, snapshot, candidate))
    assert(Game.unchanged(state.owner, snapshot) and state.saves == 0, 'Failed projections must restore all fields')
    state.projection_error, state.oracle = nil, nil
    state.owner.GetDailyMenuProjection, state.owner.GetDailyMenu = original_projection, original_get
end
-- Model a reflected setter that partially writes and then raises; rollback must still run.
local storage, manager = state.manager.LunchDailyMenu, state.manager
manager.LunchDailyMenu = nil
setmetatable(manager, { __index = function(_, key) if key == 'LunchDailyMenu' then return storage end end,
    __newindex = function(self, key, value)
        if key ~= 'LunchDailyMenu' then rawset(self, key, value); return end
        storage.MainDish = value.MainDish
        if value.MainDish == 20 then error('Synthetic partial assignment') end
        for k, v in pairs(value) do storage[k] = v end
    end })
assert(not pcall(Game.evaluate, state.owner, snapshot, candidate))
assert(Game.unchanged(state.owner, snapshot) and state.saves == 0)
setmetatable(manager, { __index = function(_, key) if key == 'LunchDailyMenu' then return storage end end,
    __newindex = function(self, key, value)
        if key ~= 'LunchDailyMenu' then rawset(self, key, value); return end
        storage.MainDish = value.MainDish
        if value.MainDish == 0 then error('Synthetic table restoration failure') end
        for k, v in pairs(value) do storage[k] = v end
    end })
assert(Game.evaluate(state.owner, snapshot, candidate) == 0.1)
assert(Game.unchanged(state.owner, snapshot) and state.saves == 0, 'Field restoration fallback must restore every field')
state = F.setup(); state.manager.DailyCustomerContext.LunchForecast.ProfileProbabilities = F.array({})
assert(not pcall(Game.snapshot, state.owner))
print('Adapter: native rates, transactional rollback, one save, changed inputs, service isolation and native refusal passed')
