-- Enumerate complete menus; the caller supplies the game's native objective.
local Planner = {}
Planner.courses = {
    { field = 'Starter', kind = 3 }, { field = 'MainDish', kind = 4 },
    { field = 'Dessert', kind = 5 }, { field = 'Aperitif', kind = 2 },
    { field = 'EndDrink', kind = 6 },
}

function Planner.finite(value)
    return type(value) == 'number' and value == value and math.abs(value) < math.huge
end

local function copy(menu)
    local result = {}; for key, value in pairs(menu) do result[key] = value end
    return result
end

function Planner.new(snapshot)
    assert(snapshot.period == 1 or snapshot.period == 2, 'Invalid service period')
    assert(type(snapshot.current.bIsActive) == 'boolean', 'Menu activation state unavailable')
    assert(Planner.finite(snapshot.ceiling) and snapshot.ceiling >= 0 and snapshot.ceiling <= 1,
        'Native adoption ceiling unavailable')
    local job = { domains = {}, cursor = {}, checked = 0, total = 1, evaluations = 0,
        ceiling = snapshot.ceiling, template = { Period = snapshot.period, bIsActive = snapshot.current.bIsActive } }
    local any, current_valid, current_nonempty, all_ids = false, true, false, {}
    for index, course in ipairs(Planner.courses) do
        local domain, seen = {}, { [0] = true }
        for _, dish in ipairs(assert(snapshot.options[course.field], 'Course options unavailable')) do
            assert(Planner.finite(dish.id) and dish.id % 1 == 0 and dish.id > 0 and dish.id < 256,
                'Invalid dish identifier')
            assert(dish.kind == course.kind and not all_ids[dish.id], 'Invalid course options')
            assert(type(dish.enabled) == 'boolean' and type(dish.stock) == 'boolean', 'Incomplete dish option')
            all_ids[dish.id] = true
            if dish.enabled then domain[#domain + 1] = dish; seen[dish.id] = true; any = true end
        end
        local existing = snapshot.current[course.field]
        current_valid = current_valid and seen[existing] == true
        current_nonempty = current_nonempty or existing ~= 0
        table.sort(domain, function(a, b)
            if (a.id == existing) ~= (b.id == existing) then return a.id == existing end
            if a.stock ~= b.stock then return a.stock end
            return a.id < b.id
        end)
        local ids = {}; for _, dish in ipairs(domain) do ids[#ids + 1] = dish.id end
        -- Each course is optional in the native model; a wholly empty menu is not a result.
        ids[#ids + 1] = 0
        job.domains[index], job.cursor[index] = ids, 1
        job.total = job.total * #ids
    end
    if not any then return nil, 'no_options' end
    job.total = job.total - 1
    if current_valid and current_nonempty then job.seed = copy(snapshot.current) end

    function job:evaluate(menu, oracle)
        local rate = oracle(menu)
        assert(Planner.finite(rate) and rate >= 0 and rate <= self.ceiling,
            'Invalid native estimated adoption rate')
        self.evaluations = self.evaluations + 1
        -- Compare unrounded rates, including improvements hidden by the UI's rounding.
        -- Equal rates retain the first result (the existing menu, when eligible).
        if not self.best or rate > self.rate then self.best, self.rate = copy(menu), rate end
        if rate == self.ceiling then self.done = true end
    end

    function job:step(oracle, budget, expired)
        assert(budget > 0, 'Positive evaluation budget required')
        for _ = 1, budget do
            if self.done then break end
            if self.seed then
                self:evaluate(self.seed, oracle); self.seed = nil
            else
                local menu, nonempty = copy(self.template), false
                for index, course in ipairs(Planner.courses) do
                    local id = self.domains[index][self.cursor[index]]
                    menu[course.field] = id; nonempty = nonempty or id ~= 0
                end
                if nonempty then self:evaluate(menu, oracle); self.checked = self.checked + 1 end
                for index, domain in ipairs(self.domains) do
                    self.cursor[index] = self.cursor[index] + 1
                    if self.cursor[index] <= #domain then break end
                    self.cursor[index] = 1
                    if index == #self.domains then self.done = true end
                end
            end
            if expired and expired() then break end
        end
        return self.done == true
    end
    return job
end

return Planner
