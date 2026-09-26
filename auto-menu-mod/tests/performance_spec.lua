local F, Game, Planner = require('fakes'), require('game'), require('planner')
local state = F.setup()
state.manager.AvailableDishes = F.array({})
for index, course in ipairs(Planner.courses) do
    local entries = {}
    for variant = 1, 8 do
        local id = index * 20 + variant
        entries[#entries + 1] = {Key=id, DishType=course.kind, bEnabled=true}
        table.insert(state.manager.AvailableDishes.entries, id)
    end
    state.owner['WBP_DailyMenu_' .. course.field].WBP_DailyMenu_DishSelector.DishOptions = F.array(entries)
end
-- These extra queries must not be needed at all; the native oracle owns prices,
-- stock, tags, weather, events and adoption calculations.
state.manager.GetDishPrice = function() error('Unexpected price scan') end
state.manager.GetSatisfaction = function() error('Unexpected satisfaction snapshot') end
state.manager.GetDailyMenuInfluence = function() error('Unexpected influence snapshot') end
state.manager.GetTier = function() error('Unexpected tier snapshot') end
state.oracle = function(menu)
    local value = 7
    for _, course in ipairs(Planner.courses) do value = (value * 13 + menu[course.field]) % 251 end
    return value / 300
end
local result = Game.compose(state.owner)
assert(result.evaluations == 59049 and state.projections == 59049 and state.saves == 1)
assert(state.oracle(result.menu) == result.rate)
state.manager.AvailableDishes = F.array({21, 41, 61})
result = Game.compose(state.owner)
assert(result.evaluations == 8, 'Only active choices plus empty should form the product')
print('Synthetic work counts: 40 active dishes -> 59049 native calls; 3 active -> 8; zero extra scoring scans or search timers')
