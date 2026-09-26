local F, Game, Planner = require('fakes'), require('game'), require('planner')

local state = F.setup()
state.manager.AvailableDishes = F.array({})
for index, course in ipairs(Planner.courses) do
    local entries = {}
    for variant = 1, 8 do
        local id = index * 20 + variant
        entries[#entries + 1] = { Key = id, DishType = course.kind, bEnabled = true,
            RecommendationTags = F.array({variant % 2}), Ingredients = F.array({{Ingredient = id, Amount = 1}}) }
        table.insert(state.manager.AvailableDishes.entries, id)
    end
    state.owner['WBP_DailyMenu_' .. course.field].WBP_DailyMenu_DishSelector.DishOptions = F.array(entries)
end
-- Deliberately non-additive synthetic oracle below the upper bound, with two
-- equivalent choices per course. No lucky ceiling termination in this case.
state.oracle = function(menu)
    local value = 7
    for _, course in ipairs(Planner.courses) do
        local id = menu[course.field]
        value = (value * 13 + (id == 0 and 2 or id % 2)) % 251
    end
    return value / 300
end

local snapshot = Game.snapshot(state.owner)
local getter_calls = 0
local getter = state.manager.GetDailyMenuInfluence
state.manager.GetDailyMenuInfluence = function(self)
    getter_calls = getter_calls + 1
    return getter(self)
end
local job = assert(Planner.new(snapshot))
local batches = 0
repeat
    batches = batches + 1
    Game.with_projection(state.owner, snapshot, function(oracle) return job:step(oracle, 64) end)
    assert(state.manager.LunchDailyMenu.MainDish == 0 and state.saves == 0)
until job.done
local reduced_calls, batch_getters = state.projections, getter_calls
assert(job.raw_total == 59048 and job.total == 242 and job.evaluations == 242)
assert(batch_getters == batches and batches < 10, 'Sampling overhead belongs to batches, not every trial')

for _, options in pairs(snapshot.options) do for _, option in ipairs(options) do option.equivalence = nil end end
local full = assert(Planner.new(snapshot))
while not full:step(state.oracle, 4096) do end
assert(full.evaluations == 59048 and full.rate == job.rate and state.oracle(job.best) == full.rate)

-- Active dishes determine the product, even when selectors contain a catalogue.
state.manager.AvailableDishes = F.array({21, 41, 61})
snapshot = Game.snapshot(state.owner); job = assert(Planner.new(snapshot))
assert(job.candidates == 3 and job.raw_total == 7 and job.total == 7)
print(string.format('Synthetic workload: full=%d reduced=%d (%.1fx fewer native predictions), batches=%d; active-only=7; same global optimum',
    full.evaluations, reduced_calls, full.evaluations / reduced_calls, batches))
