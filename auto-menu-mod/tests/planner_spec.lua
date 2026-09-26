local Planner = require('planner')
local function input()
    local domains, current = {}, { Period = 1, bIsActive = false }
    for index, course in ipairs(Planner.courses) do
        domains[course.field] = { 0, index * 10, index * 10 + 1 }
        current[course.field] = 0
    end
    return domains, current
end
local domains, current = input()
local seen, trial_table = {}, nil
local result = Planner.solve(domains, current, function(menu)
    trial_table = trial_table or menu
    assert(trial_table == menu, 'Reuse the trial table')
    local key = ''
    for _, course in ipairs(Planner.courses) do key = key .. ':' .. menu[course.field] end
    assert(not seen[key], 'Visit each combination once'); seen[key] = true
    assert(menu.Period == 1 and not menu.bIsActive)
    return key == ':11:21:0:40:0' and 0.73100001 or 0.731
end, 1)
assert(result.evaluations == 243 and seen[':0:0:0:0:0'])
assert(result.rate == 0.73100001 and result.menu.MainDish == 21 and result.menu.Dessert == 0)
assert(result.menu ~= trial_table and result.menu.Starter == 11, 'Retain a copy of the best menu')

-- Order current choices first; a tied current menu remains selected.
current.MainDish = 21; domains.MainDish = {21, 0, 20}
result = Planner.solve(domains, current, function() return 0.4 end, 1)
assert(result.menu.MainDish == 21 and result.menu.Starter == 0 and result.evaluations == 243)
result = Planner.solve(domains, current, function() return 0.8 end, 0.8)
assert(result.evaluations == 1, 'Only reaching the native upper bound stops early')
for _, course in ipairs(Planner.courses) do domains[course.field] = {0} end
result = Planner.solve(domains, current, function() return 0 end, 1)
assert(result.evaluations == 1 and result.menu.MainDish == 0, 'An empty catalogue still has the empty menu')
for _, invalid in ipairs({-1, 1.01, math.huge, 0/0}) do
    assert(not pcall(Planner.solve, domains, current, function() return invalid end, 1))
end
print('Planner: complete enumeration including empty, joint optimum, exact rates, ties and ceiling passed')
