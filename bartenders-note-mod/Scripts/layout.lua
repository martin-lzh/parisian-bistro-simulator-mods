-- Pure layout of a sorted summary, measured in the renderer's font units.
local Layout = {}
local Localization = require('localization')
local SEPARATOR = "  ·  "

function Layout.format(groups, width, measure, language)
    local total = #groups
    local empty = { lines = {}, text = "", hidden = total, shown = 0 }
    if total == 0 or type(width) ~= "number" or width <= 0
        or width >= math.huge or width ~= width or type(measure) ~= "function" then
        return empty
    end

    local labels, widths = {}, {}
    for index, group in ipairs(groups) do
        labels[index] = group.name .. " x " .. group.count
    end
    local function fits(text)
        local measured = widths[text]
        if measured == nil then
            measured = measure(text)
            assert(type(measured) == "number" and measured >= 0 and measured < math.huge,
                "Text measurement must return a finite nonnegative width")
            widths[text] = measured
        end
        return measured <= width
    end

    local function pack(shown)
        local lines = {}
        local function append(text)
            local line = #lines
            if line > 0 then
                local joined = lines[line] .. SEPARATOR .. text
                if fits(joined) then
                    lines[line] = joined
                    return true
                end
            end
            if line == 2 or not fits(text) then return false end
            lines[line + 1] = text
            return true
        end
        for index = 1, shown do
            if not append(labels[index]) then return nil end
        end
        if shown < total and not append(Localization.more(total - shown, language)) then
            return nil
        end
        return lines
    end

    -- Repack each shorter prefix with its own marker: changing the hidden count
    -- can change its width, and an earlier group may need to leave the last row.
    for shown = total, 0, -1 do
        local lines = pack(shown)
        if lines then
            return { lines = lines, text = table.concat(lines, "\n"),
                hidden = total - shown, shown = shown }
        end
    end
    return empty
end

return Layout
