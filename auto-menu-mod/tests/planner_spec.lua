local Planner = require('planner')
local function snapshot()
    local value = { period = 1, ceiling = 1, current = { Period = 1, bIsActive = false }, options = {} }
    for index, course in ipairs(Planner.courses) do
        value.current[course.field] = 0
        value.options[course.field] = {
            { id = index * 10, kind = course.kind, enabled = true, stock = true },
            { id = index * 10 + 1, kind = course.kind, enabled = true, stock = false },
        }
    end
    return value
end
local function solve(s, oracle)
    local job = assert(Planner.new(s))
    while not job:step(oracle, 7) do end
    return job
end
local s, seen = snapshot(), {}
local winner = { Starter = 11, MainDish = 21, Dessert = 0, Aperitif = 40, EndDrink = 0 }
local function objective(menu)
    assert(menu.Period == 1 and menu.bIsActive == false)
    local key, match = '', true
    for _, course in ipairs(Planner.courses) do
        key = key .. ':' .. menu[course.field]
        match = match and menu[course.field] == winner[course.field]
    end
    assert(not seen[key], 'Each combination is visited once')
    seen[key] = true
    -- Joint improvements defeat independent-course scores, with optional empty courses.
    return match and 0.73100001 or 0.731
end
local job = solve(s, objective)
assert(job.total == 242 and job.checked == 242 and job.evaluations == 242)
assert(job.best.MainDish == 21 and job.best.Starter == 11 and job.best.Dessert == 0 and job.best.EndDrink == 0)
assert(job.rate == 0.73100001, 'Do not round the native objective or prefer stock over a higher rate')
local saved = job.best.MainDish
job:step(function() error('Finished job queried the oracle') end, 10)
assert(job.best.MainDish == saved)

s = snapshot(); s.current.MainDish = 21
job = solve(s, function() return 0.4 end)
assert(job.best.MainDish == 21 and job.best.Starter == 0, 'A tied existing menu is retained')
s = snapshot(); s.ceiling = 0.8
job = solve(s, function() return 0.8 end)
assert(job.evaluations == 1 and job.done, 'Only the native upper bound permits early completion')
s = snapshot(); job = assert(Planner.new(s))
assert(not job:step(function() return 0.5 end, 128, function() return true end))
assert(job.evaluations == 1 and job.checked == 1, 'Time budget must yield without losing the cursor')
while not job:step(function() return 0.5 end, 100) do end
assert(job.checked == 242)

s = snapshot(); s.period = 2; s.current.Period = 2
s.options.MainDish[1].enabled = false
job = solve(s, function(menu) assert(menu.MainDish ~= 20 and menu.Period == 2); return 0 end)
assert(job.total == 161)
s = snapshot()
for _, course in ipairs(Planner.courses) do s.options[course.field] = {} end
local empty, reason = Planner.new(s); assert(not empty and reason == 'no_options')
s.options.Dessert = { { id = 30, kind = 5, enabled = true, stock = true } }
job = solve(s, function(menu) assert(menu.MainDish == 0 and menu.Dessert == 30); return 0.2 end)
assert(job.total == 1)
for _, rate in ipairs({ -1, 1.01, math.huge }) do
    assert(not pcall(solve, snapshot(), function() return rate end))
end
assert(not pcall(solve, snapshot(), function() return 0/0 end))
s = snapshot(); s.options.MainDish[1].kind = 5; assert(not pcall(Planner.new, s))
s = snapshot(); s.options.MainDish[1].id = 10; assert(not pcall(Planner.new, s))
s = snapshot(); s.ceiling = 0/0; assert(not pcall(Planner.new, s))
-- Equivalence removes redundant combinations, not distinct scores. Compare
-- reduced search to a full oracle search over many joint (non-additive) cases.
for trial = 1, 30 do
    s = snapshot()
    for index, course in ipairs(Planner.courses) do
        s.options[course.field][2].equivalence = 'same'
        s.options[course.field][1].equivalence = 'same'
        if (trial + index) % 3 == 0 then s.options[course.field][2].equivalence = nil end
    end
    local function rate(menu)
        local hash = trial
        for index, course in ipairs(Planner.courses) do
            local id = menu[course.field]
            if id ~= 0 and (trial + index) % 3 ~= 0 then id = index * 10 end
            hash = (hash * 113 + id * 17) % 997
        end
        return hash / 1100
    end
    local reduced = solve(s, rate)
    for _, options in pairs(s.options) do for _, dish in ipairs(options) do dish.equivalence = nil end end
    local full = solve(s, rate)
    assert(reduced.rate == full.rate and reduced.total < full.total)
    assert(reduced.evaluations == reduced.total and reduced.checked == reduced.total)
end

s = snapshot(); s.current.MainDish = 21
for _, course in ipairs(Planner.courses) do
    for _, dish in ipairs(s.options[course.field]) do dish.equivalence = 'same' end
end
job = solve(s, function() return 0.4 end)
assert(job.best.MainDish == 21 and job.best.Starter == 0 and job.evaluations == 31,
    'Keep an eligible existing tied menu and never repeat its equivalence class')

-- A useful incumbent reaches the proven ceiling without traversing the product.
s = snapshot(); s.ceiling = 0.9
job = solve(s, function(menu)
    local count = 0
    for index, course in ipairs(Planner.courses) do if menu[course.field] == index * 10 + 1 then count = count + 1 end end
    return count == 5 and 0.9 or count / 10
end)
assert(job.rate == 0.9 and job.evaluations < 30 and job.total == 242)
print('Planner: exhaustive certification, equivalence versus brute force, ceiling warm start, ties and budgets passed')
