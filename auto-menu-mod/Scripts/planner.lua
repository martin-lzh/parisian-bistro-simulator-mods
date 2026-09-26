local Planner = {}
Planner.courses = {
    { field = 'Starter', kind = 3 }, { field = 'MainDish', kind = 4 },
    { field = 'Dessert', kind = 5 }, { field = 'Aperitif', kind = 2 },
    { field = 'EndDrink', kind = 6 },
}

function Planner.copy(menu)
    local result = { Period = menu.Period, bIsActive = menu.bIsActive }
    for _, course in ipairs(Planner.courses) do result[course.field] = menu[course.field] end
    return result
end

-- Enumerate the Cartesian product, including empty courses and an empty menu.
-- Reuse the trial table; only improvements need a copy. Equal scores keep the
-- first combination, so putting current choices first preserves existing ties.
function Planner.solve(domains, current, oracle, ceiling)
    local trial, result = Planner.copy(current), { evaluations = 0 }
    local function visit(index)
        local course = Planner.courses[index]
        if course then
            for _, id in ipairs(domains[course.field]) do
                trial[course.field] = id
                if visit(index + 1) then return true end
            end
        else
            local rate = oracle(trial)
            assert(type(rate) == 'number' and rate >= 0 and rate <= 1, 'Invalid native selection rate')
            result.evaluations = result.evaluations + 1
            if not result.menu or rate > result.rate then result.menu, result.rate = Planner.copy(trial), rate end
            -- The native ceiling is an exact upper bound, not a heuristic.
            return rate == ceiling
        end
    end
    visit(1)
    return result
end

return Planner
