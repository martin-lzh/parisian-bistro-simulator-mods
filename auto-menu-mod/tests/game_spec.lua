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
rejected(function(s) s.tier = 1 end)
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

-- Time and satisfaction move between slices, but all candidates use the same native sample.
state = F.setup()
state.manager.DailyMenuInfluence = 0.8
state.decay = 0.1
snapshot = Game.snapshot(state.owner)
state.decay = 0.4
state.manager.Satisfaction = 0.4
state.oracle = function(menu)
    return (menu.MainDish == 21 and 0.1 or 0) + state.manager:GetDailyMenuInfluence() * 0.5
        + state.manager:GetSatisfaction() * 0.1
end
assert(Game.unchanged(state.owner, snapshot), 'Ordinary simulation drift must not cancel the search')
local expected = 0.1 + snapshot.sample.influence * 0.5 + snapshot.sample.satisfaction * 0.1
candidate.MainDish = 21
assert(Game.evaluate(state.owner, snapshot, candidate) == expected)
assert(state.manager.DailyMenuInfluence == 0.8 and state.manager.DailyMenuInfluenceHalfLifeGameHours == 12
    and state.manager.Satisfaction == 0.4, 'Trial must restore the latest live values, not the click-time values')
local live, saved = Game.apply(state.owner, snapshot, candidate, expected)
assert(saved and live == 0.1 + 0.4 * 0.5 + 0.4 * 0.1 and state.saves == 1)

-- If native live rankings reverse, retain the better existing menu without saving.
state = F.setup(); state.manager.LunchDailyMenu.MainDish = 20
state.manager.DailyMenuInfluence = 0.8
snapshot = Game.snapshot(state.owner); candidate.MainDish = 21
state.oracle = function(menu)
    local influence = state.manager:GetDailyMenuInfluence()
    return menu.MainDish == 21 and influence or 1 - influence
end
expected = Game.evaluate(state.owner, snapshot, candidate)
state.decay = 0.6
live, saved = Game.apply(state.owner, snapshot, candidate, expected)
assert(not saved and state.saves == 0 and state.manager.LunchDailyMenu.MainDish == 20 and live > 0.7)

-- Native array reorder alone is not a semantic change.
state = F.setup(); state.manager.AvailableDishes = F.array({ 20, 10 })
local probabilities = state.manager.DailyCustomerContext.LunchForecast.ProfileProbabilities.entries
probabilities[1].Probability = 0.5; probabilities[2] = { Profile = 1, Probability = 0.5 }
snapshot = Game.snapshot(state.owner)
state.manager.AvailableDishes = F.array({ 10, 20 })
probabilities[1], probabilities[2] = probabilities[2], probabilities[1]
local options = state.owner.WBP_DailyMenu_MainDish.WBP_DailyMenu_DishSelector.DishOptions.entries
options[1], options[2] = options[2], options[1]
assert(Game.unchanged(state.owner, snapshot), 'Array ordering must not cancel semantically identical inputs')
state.prices[20] = 15
local unchanged, reason = Game.unchanged(state.owner, snapshot)
assert(not unchanged and reason:find('inputs.options.MainDish.', 1, true), 'Real changes need a specific diagnostic path')

-- Failed projection restores all sampled properties even when their live values drifted.
state = F.setup(); state.manager.DailyMenuInfluence = 0.9
snapshot = Game.snapshot(state.owner)
state.decay = 0.3; state.manager.Satisfaction = 0.25; state.projection_error = true
assert(not pcall(Game.evaluate, state.owner, snapshot, candidate))
assert(state.manager.DailyMenuInfluence == 0.9 and state.manager.DailyMenuInfluenceHalfLifeGameHours == 12
    and state.manager.Satisfaction == 0.25 and state.manager.LunchDailyMenu.MainDish == 0)
state.projection_error = nil
local live_satisfaction = state.manager.Satisfaction
state.manager.Satisfaction = nil
setmetatable(state.manager, {
    __index = function(_, key) if key == 'Satisfaction' then return live_satisfaction end end,
    __newindex = function(self, key, value)
        if key ~= 'Satisfaction' then rawset(self, key, value); return end
        live_satisfaction = value
        if value == snapshot.sample.satisfaction then error('Synthetic sampled-property write failure') end
    end,
})
assert(not pcall(Game.evaluate, state.owner, snapshot, candidate))
assert(state.manager.DailyMenuInfluence == 0.9 and state.manager.DailyMenuInfluenceHalfLifeGameHours == 12
    and state.manager.Satisfaction == 0.25 and state.manager.LunchDailyMenu.MainDish == 0,
    'A partially failed sample write must restore every live property')
-- Stale selectors must never reintroduce locked, disabled or unstaffed dishes.
state = F.setup()
state.manager.AvailableDishes = F.array({10, 11, 20, 21})
state.manager.UnlockedDailyDishes = F.array({30}) -- Does not activate a dish by itself.
state.manager.DisabledDishes = F.array({11})
state.manager.EmployeeRequirementDisabledDishes = F.array({21})
snapshot = Game.snapshot(state.owner); job = assert(Planner.new(snapshot))
assert(job.raw_total == 3 and job.candidates == 2)
while not job:step(function(menu)
    assert((menu.Starter == 0 or menu.Starter == 10) and (menu.MainDish == 0 or menu.MainDish == 20))
    assert(menu.Dessert == 0 and menu.Aperitif == 0 and menu.EndDrink == 0)
    return 0.1
end, 100) do end
state.manager.AvailableDishes = F.array({})
assert(Planner.new(Game.snapshot(state.owner)) == nil)

-- Native input equivalence preserves tag order, price boundaries and stock.
state = F.setup()
local starters = state.owner.WBP_DailyMenu_Starter.WBP_DailyMenu_DishSelector.DishOptions.entries
starters[1].RecommendationTags = F.array({1, 3})
starters[2].RecommendationTags = F.array({1, 3})
state.prices[10], state.prices[11] = 8, 10 -- Same native food-price band.
snapshot = Game.snapshot(state.owner)
assert(snapshot.options.Starter[1].equivalence == snapshot.options.Starter[2].equivalence)
state.prices[11] = 10.000001
assert(Game.snapshot(state.owner).options.Starter[1].equivalence ~= Game.snapshot(state.owner).options.Starter[2].equivalence)
state.prices[10], state.prices[11] = 15, 15.000001
snapshot = Game.snapshot(state.owner)
assert(snapshot.options.Starter[1].equivalence ~= snapshot.options.Starter[2].equivalence)
state.prices[10], state.prices[11] = 10, 10
state.missing = 11
snapshot = Game.snapshot(state.owner)
assert(snapshot.options.Starter[1].equivalence ~= snapshot.options.Starter[2].equivalence)
state.missing = nil; starters[2].RecommendationTags = F.array({3, 1})
snapshot = Game.snapshot(state.owner)
assert(snapshot.options.Starter[1].equivalence ~= snapshot.options.Starter[2].equivalence)
local drinks = state.owner.WBP_DailyMenu_Aperitif.WBP_DailyMenu_DishSelector.DishOptions.entries
drinks[2].RecommendationTags = F.array({40}); state.prices[41] = 10000
snapshot = Game.snapshot(state.owner)
assert(snapshot.options.Aperitif[1].equivalence == snapshot.options.Aperitif[2].equivalence)

-- One protected batch uses sampled values throughout and restores live state on
-- success, budget yield, or an error after earlier successful projections.
state = F.setup(); snapshot = Game.snapshot(state.owner)
state.manager.Satisfaction = 0.25; state.manager.DailyMenuInfluence = 0.8
local calls = 0
state.oracle = function()
    calls = calls + 1
    assert(state.manager.Satisfaction == snapshot.sample.satisfaction)
    assert(state.manager.DailyMenuInfluence == snapshot.sample.influence)
    if calls == 3 then error('Synthetic later batch failure') end
    return 0.4
end
assert(not pcall(Game.with_projection, state.owner, snapshot, function(oracle)
    oracle(candidate); candidate.Starter = 11; oracle(candidate); oracle(candidate)
end))
assert(calls == 3 and state.saves == 0 and state.manager.LunchDailyMenu.MainDish == 0)
assert(state.manager.Satisfaction == 0.25 and state.manager.DailyMenuInfluence == 0.8
    and state.manager.DailyMenuInfluenceHalfLifeGameHours == 12)
state.oracle = function() return 0.4 end
job = assert(Planner.new(snapshot))
Game.with_projection(state.owner, snapshot, function(oracle)
    job:step(oracle, 128, function() return true end)
end)
assert(job.evaluations == 1 and state.manager.LunchDailyMenu.MainDish == 0 and state.manager.Satisfaction == 0.25)
print('Adapter: eligibility, native input equivalence, protected batches, rollback and native apply passed')
