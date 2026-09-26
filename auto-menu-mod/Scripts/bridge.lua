local Bridge = {}
local directory = debug.getinfo(1, 'S').source:sub(2):match('^(.*)[/\\]')
local invoke

function Bridge.solve(owner, manager, storage, period, original, domains, courses, ceiling)
    if not invoke then
        local message
        invoke, message = package.loadlib(directory .. '/auto_menu_bridge.dll', 'auto_menu_compose')
        assert(invoke, 'Cannot load Auto Menu native helper: ' .. tostring(message))
    end
    local baseline = owner:GetDailyMenuProjection(period).EstimatedAdoptionRate
    local lines = {
        'AutoMenu1', string.format('%x %x %x %d', owner:GetAddress(), manager:GetAddress(), storage:GetStructAddress(), period),
        string.format('%d %d', original.Period, original.bIsActive and 1 or 0),
    }
    for _, course in ipairs(courses) do lines[#lines + 1] = tostring(original[course.field]) end
    lines[#lines + 1] = string.format('%.17g %.17g', ceiling, baseline)
    local combinations = 1
    for _, course in ipairs(courses) do
        local ids = domains[course.field]
        combinations = combinations * #ids
        lines[#lines + 1] = #ids .. ' ' .. table.concat(ids, ' ')
    end
    local request, response = directory .. '/auto-menu-request.txt', directory .. '/auto-menu-result.txt'
    local old = io.open(response, 'r')
    if old then old:close(); assert(os.remove(response), 'Cannot clear previous native result') end
    local file = assert(io.open(request, 'w'), 'Cannot create native menu request')
    local written, write_error = file:write(table.concat(lines, '\n') .. '\n')
    local closed, close_error = file:close()
    if not written or not closed then os.remove(request) end
    assert(written and closed, tostring(write_error or close_error))
    local ok, err = pcall(invoke)
    os.remove(request)
    if not ok then error(err) end
    file = assert(io.open(response, 'r'), 'Native helper did not return a result')
    local text = file:read('*a'); file:close()
    assert(text:sub(1, 3) == 'ok ', text)
    local values = {}
    for value in text:gmatch('%S+') do values[#values + 1] = value end
    assert(#values == 14, 'Malformed native menu result')
    local rate, evaluations = tonumber(values[2]), tonumber(values[3])
    assert(rate and rate >= 0 and rate <= 1 and evaluations and evaluations >= 1
        and evaluations <= combinations and tonumber(values[4]) == combinations, 'Invalid native search result')
    local menu = { Period = period, bIsActive = original.bIsActive }
    for index, course in ipairs(courses) do
        local id, found = tonumber(values[index + 9]), false
        for _, candidate in ipairs(domains[course.field]) do if id == candidate then found = true; break end end
        assert(found, 'Native result contains an unavailable dish')
        menu[course.field] = id
    end
    local cache = { checks = tonumber(values[5]), hits = tonumber(values[6]), misses = tonumber(values[7]),
        bypasses = tonumber(values[8]), seconds = tonumber(values[9]) }
    for _, value in pairs(cache) do assert(value >= 0 and value < math.huge, 'Invalid native timing result') end
    assert(cache.checks and cache.hits and cache.misses and cache.bypasses and cache.seconds, 'Missing native timing result')
    return { menu = menu, rate = rate, evaluations = evaluations, combinations = combinations, cache = cache }
end

return Bridge
