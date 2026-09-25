local Planner = require('planner')
local function dish(id, kind, tags)
    local set = {}; for _, tag in ipairs(tags) do set[tag] = true end
    return { id = id, kind = kind, tags = set, stock = true, enabled = true }
end
local function snapshot()
    return { period = 1, temperature = 1, current = { bIsActive = true },
        profiles = { { id = 0, probability = 1 } }, intents = { { id = 0, probability = 1 } },
        options = { Starter = {}, Dessert = {}, Aperitif = {}, EndDrink = {},
            MainDish = { dish(12, 4, { 3, 6 }), dish(21, 4, { 1, 13, 17 }) } } }
end
local s = snapshot()
assert(Planner.plan(s).MainDish == 12, 'Business/quick forecast must favor a quick dish')
s.profiles, s.intents = { { id = 1, probability = 1 } }, { { id = 5, probability = 1 } }
assert(Planner.plan(s).MainDish == 21, 'Event-driven family forecast must change the selection')
s.profiles, s.intents = { { id = 6, probability = 1 } }, { { id = 8, probability = 1 } }
s.options.MainDish = { dish(12, 4, { 11, 17, 5 }), dish(21, 4, { 4, 12 }) }
s.temperature = 0; assert(Planner.plan(s).MainDish == 12)
s.temperature = 3; assert(Planner.plan(s).MainDish == 21)
s.temperature = 1; s.current.MainDish = 21
assert(Planner.plan(s).MainDish == 21, 'Ties keep the existing choice')
s.options.MainDish[2].stock = false
assert(Planner.plan(s).MainDish == 12, 'Stock wins ties')
s.options.MainDish[1].stock = false; s.current.MainDish = nil
assert(Planner.plan(s).MainDish == 12, 'Ties have stable identifiers')
s.options.MainDish[1].enabled = false
assert(Planner.plan(s).MainDish == 21, 'Disabled dishes are never selected')
s.options.MainDish = {}
local menu, reason = Planner.plan(s); assert(not menu and reason == 'no_options')
s.options.Dessert = { dish(32, 5, { 13 }) }
menu = Planner.plan(s)
assert(menu.MainDish == 0 and menu.Dessert == 32 and menu.bIsActive, 'Partial native menus remain valid')
s.period = 2; assert(Planner.plan(s).Period == 2)
s.intents = {}; assert(not pcall(Planner.plan, s), 'Unavailable forecasts must fail closed')
s = snapshot(); s.profiles[1].probability = 0/0; assert(not pcall(Planner.plan, s))
s = snapshot(); s.profiles[1].probability = -1; assert(not pcall(Planner.plan, s))
s = snapshot(); s.intents[2] = s.intents[1]; assert(not pcall(Planner.plan, s))
s = snapshot(); s.options.MainDish[1].kind = 5; assert(not pcall(Planner.plan, s))
s = snapshot(); s.options.MainDish[2].id = 12; assert(not pcall(Planner.plan, s))
s = snapshot(); s.temperature = 8; assert(not pcall(Planner.plan, s))
s = snapshot(); s.profiles[1].probability = 100; s.intents[1].probability = 100
assert(Planner.plan(s).MainDish == 12, 'Forecast weights are normalized')
print('Planner: service preferences, event forecast, weather, ties, eligibility and invalid data passed')
