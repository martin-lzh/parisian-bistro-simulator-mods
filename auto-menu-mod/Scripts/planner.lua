-- Search the exact quotient space supplied by the native-input adapter.
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
    local job = { domains = {}, cursor = {}, aliases = {}, checked = 0, total = 1, raw_total = 1,
        evaluations = 0, candidates = 0, representatives = 0, warm_seen = {},
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
        job.raw_total = job.raw_total * (#domain + 1)
        job.candidates = job.candidates + #domain
        local ids, groups, aliases = {}, {}, { [0] = 0 }
        for _, dish in ipairs(domain) do
            -- Missing signatures never authorize elimination. The adapter must
            -- establish equivalence for every context, not just a sampled score.
            local key = dish.equivalence
            local representative = key and groups[key]
            if not representative then
                representative = dish.id
                ids[#ids + 1] = representative
                if key then groups[key] = representative end
            end
            aliases[dish.id] = representative
        end
        job.representatives = job.representatives + #ids
        -- Each course is optional in the native model; a wholly empty menu is not a result.
        ids[#ids + 1] = 0
        job.domains[index], job.cursor[index], job.aliases[index] = ids, 1, aliases
        job.total = job.total * #ids
    end
    if not any then return nil, 'no_options' end
    job.total = job.total - 1
    job.raw_total = job.raw_total - 1
    if current_valid and current_nonempty then job.seed = copy(snapshot.current) end
    job.phase = job.seed and 'seed' or (job.total > 128 and 'start' or 'enumerate')

    function job:key(menu)
        local parts, nonempty = {}, false
        for index, course in ipairs(Planner.courses) do
            local id = assert(self.aliases[index][menu[course.field]], 'Candidate outside eligible domains')
            parts[index] = id; nonempty = nonempty or id ~= 0
        end
        return nonempty and table.concat(parts, ':') or nil
    end

    function job:evaluate(menu, oracle, warm)
        local key = self:key(menu)
        if not key or self.warm_seen[key] then return end
        local rate = oracle(menu)
        assert(Planner.finite(rate) and rate >= 0 and rate <= self.ceiling,
            'Invalid native estimated adoption rate')
        self.evaluations = self.evaluations + 1
        self.checked = self.checked + 1
        if warm then self.warm_seen[key] = true end
        -- Compare unrounded rates, including improvements hidden by the UI's rounding.
        -- Equal rates retain the first result (the existing menu, when eligible).
        if not self.best or rate > self.rate then self.best, self.rate = copy(menu), rate end
        if rate == self.ceiling then self.done = true end
    end

    function job:step(oracle, budget, expired)
        assert(budget > 0, 'Positive evaluation budget required')
        for _ = 1, budget do
            if self.done then break end
            if self.phase == 'seed' then
                self.phase = self.total > 128 and 'start' or 'enumerate'
                if self.seed then self:evaluate(self.seed, oracle, true); self.seed = nil end
            elseif self.phase == 'start' then
                local menu = copy(self.template)
                for index, course in ipairs(Planner.courses) do menu[course.field] = self.domains[index][1] end
                self:evaluate(menu, oracle, true)
                self.warm_course, self.warm_option, self.warm_pass = 1, 1, 1
                self.phase = 'warm'
            elseif self.phase == 'warm' then
                -- Two coordinate sweeps find a useful incumbent quickly, but
                -- only the ceiling or complete coverage can certify an optimum.
                local menu = copy(self.best)
                menu[Planner.courses[self.warm_course].field] = self.domains[self.warm_course][self.warm_option]
                self:evaluate(menu, oracle, true)
                self.warm_option = self.warm_option + 1
                if self.warm_option > #self.domains[self.warm_course] then
                    self.warm_option = 1; self.warm_course = self.warm_course + 1
                    if self.warm_course > #self.domains then
                        self.warm_course = 1; self.warm_pass = self.warm_pass + 1
                        if self.warm_pass > 2 then self.phase = 'enumerate' end
                    end
                end
            else
                local menu, nonempty = copy(self.template), false
                for index, course in ipairs(Planner.courses) do
                    local id = self.domains[index][self.cursor[index]]
                    menu[course.field] = id; nonempty = nonempty or id ~= 0
                end
                if nonempty then self:evaluate(menu, oracle, false) end
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
