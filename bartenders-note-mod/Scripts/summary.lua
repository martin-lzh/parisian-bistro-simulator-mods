-- Pure order aggregation; no engine objects or shared mutable state.
local Summary = {}
local Localization = require('localization')

local function nonnegative_integer(value)
    return type(value) == "number"
        and value >= 0
        and value < math.huge
        and value == math.floor(value)
end

local function label_for(drink, translate, language, native_category)
    if type(translate) == "function" then
        local ok, name = pcall(translate, drink)
        if ok and type(name) == "string" then
            -- A translated display name must not introduce another HUD line.
            name = name:gsub("%s+", " "):match("^%s*(.-)%s*$")
            if name ~= "" then
                return name
            end
        end
    end
    -- Keep the remaining count useful even when a localized label is unavailable.
    return Localization.drink(drink, language, native_category)
end

function Summary.collect(entries, playerId, translate, language, native_category)
    local result = { groups = {}, total = 0 }
    if type(entries) ~= "table" or not nonnegative_integer(playerId) then
        return result
    end

    local seen, by_drink = {}, {}
    for _, entry in ipairs(entries) do
        if type(entry) == "table"
            and type(entry.id) == "string"
            and entry.id:find("%S")
            and nonnegative_integer(entry.drink)
            and entry.claimed == true
            and entry.player_id == playerId
            and (entry.state == 0 or entry.state == 1)
            and not seen[entry.id]
        then
            seen[entry.id] = true
            by_drink[entry.drink] = (by_drink[entry.drink] or 0) + 1
            result.total = result.total + 1
        end
    end

    for drink, count in pairs(by_drink) do
        result.groups[#result.groups + 1] = { id = drink, count = count }
    end
    table.sort(result.groups, function(a, b)
        return a.id < b.id
    end)

    for _, group in ipairs(result.groups) do
        group.name = label_for(group.id, translate, language, native_category)
    end
    return result
end

return Summary
