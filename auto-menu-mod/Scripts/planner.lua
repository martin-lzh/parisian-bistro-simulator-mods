-- Original recommendation policy. These weights are not the game's adoption formula.
local Planner = {}
Planner.courses = {
    { field = 'Starter', kind = 3 }, { field = 'MainDish', kind = 4 },
    { field = 'Dessert', kind = 5 }, { field = 'Aperitif', kind = 2 },
    { field = 'EndDrink', kind = 6 },
}

local tags = { traditional = 0, family = 1, affordable = 2, fast = 3, light = 4,
    filling = 5, premium = 6, trendy = 7, vegetarian = 10, hot = 11, cold = 12,
    sweet = 13, spicy = 14, world = 16, comfort = 17 }
local profiles = {
    [0] = { 'fast', 'premium' },
    { 'family', 'affordable', 'traditional', 'sweet', 'comfort' },
    { 'traditional', 'trendy', 'world' },
    { 'affordable', 'fast', 'filling', 'spicy', 'comfort' },
    { 'traditional', 'affordable', 'comfort' },
    { 'trendy', 'premium', 'light', 'vegetarian', 'world' }, {},
}
local intents = {
    [0] = { 'fast' }, { 'affordable' }, { 'filling', 'traditional', 'comfort' },
    { 'light', 'cold' }, { 'traditional', 'trendy', 'world', 'spicy' },
    { 'family', 'filling', 'sweet', 'comfort' }, { 'premium' },
    { 'premium', 'trendy', 'sweet' }, {},
}

local function finite(value)
    return type(value) == 'number' and value == value and math.abs(value) < math.huge
end

local function distribution(values, known)
    local result, total = {}, 0
    assert(type(values) == 'table', 'Forecast is unavailable')
    for _, entry in ipairs(values) do
        assert(known[entry.id] and finite(entry.probability) and entry.probability >= 0,
            'Unsupported forecast entry')
        assert(result[entry.id] == nil, 'Duplicate forecast entry')
        result[entry.id], total = entry.probability, total + entry.probability
    end
    assert(finite(total) and total > 0, 'Forecast has no probability mass')
    for id, value in pairs(result) do result[id] = value / total end
    return result
end

local function affinity(dish, probabilities, preferences)
    local score = 0
    for id, probability in pairs(probabilities) do
        local preferred, matched = preferences[id], 0
        for _, name in ipairs(preferred) do
            if dish.tags[tags[name]] then matched = matched + 1 end
        end
        if #preferred > 0 then score = score + probability * matched / #preferred end
    end
    return score
end

local function score(dish, forecast, temperature)
    local result = 0.6 * affinity(dish, forecast.profiles, profiles)
        + 0.4 * affinity(dish, forecast.intents, intents)
    if temperature == 0 then
        if dish.tags[tags.hot] then result = result + 0.15 end
        if dish.tags[tags.comfort] then result = result + 0.15 end
    elseif temperature == 3 then
        if dish.tags[tags.light] then result = result + 0.15 end
        if dish.tags[tags.cold] then result = result + 0.15 end
        if dish.tags[tags.hot] then result = result - 0.15 end
        if dish.tags[tags.filling] then result = result - 0.15 end
    end
    return result
end

local function better(a, b, current)
    if not b then return true end
    if math.abs(a.score - b.score) > 1e-9 then return a.score > b.score end
    if a.stock ~= b.stock then return a.stock end
    if (a.id == current) ~= (b.id == current) then return a.id == current end
    return a.id < b.id
end

function Planner.plan(snapshot)
    assert(snapshot.period == 1 or snapshot.period == 2, 'Invalid service period')
    local temperature = snapshot.temperature
    assert(finite(temperature) and temperature % 1 == 0 and temperature >= 0 and temperature <= 3,
        'Unsupported temperature band')
    local forecast = {
        profiles = distribution(snapshot.profiles, profiles),
        intents = distribution(snapshot.intents, intents),
    }
    assert(type(snapshot.current.bIsActive) == 'boolean', 'Menu activation state unavailable')
    local menu, selected = { Period = snapshot.period, bIsActive = snapshot.current.bIsActive }, {}
    for _, course in ipairs(Planner.courses) do
        local best, seen = nil, {}
        for _, dish in ipairs(assert(snapshot.options[course.field], 'Course options unavailable')) do
            assert(finite(dish.id) and dish.id % 1 == 0 and dish.id > 0 and dish.id < 256,
                'Invalid dish identifier')
            assert(dish.kind == course.kind and not seen[dish.id], 'Invalid course options')
            assert(type(dish.enabled) == 'boolean' and type(dish.stock) == 'boolean'
                and type(dish.tags) == 'table', 'Incomplete dish options')
            seen[dish.id] = true
            if dish.enabled then
                local candidate = { id = dish.id, stock = dish.stock,
                    score = score(dish, forecast, temperature) }
                if better(candidate, best, snapshot.current[course.field]) then best = candidate end
            end
        end
        menu[course.field] = best and best.id or 0
        if best then
            assert(not selected[best.id], 'Dish selected for multiple courses')
            selected[best.id] = true
        end
    end
    if next(selected) == nil then return nil, 'no_options' end
    return menu
end

return Planner
