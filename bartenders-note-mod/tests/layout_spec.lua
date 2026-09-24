-- Run with Lua 5.4: lua path/to/layout_spec.lua
local source = debug.getinfo(1, "S").source:sub(2)
local directory = source:match("^(.*[/\\])") or "./"
local Layout = dofile(directory .. "../Scripts/layout.lua")
local passed = 0
local function equal(actual, expected)
    assert(actual == expected, "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function test(name, fn)
    local ok, message = pcall(fn)
    assert(ok, name .. ": " .. tostring(message))
    passed = passed + 1
end
local function chars(text) return utf8.len(text) end
local function groups(count)
    local result = {}
    for i = 1, count do result[i] = { id = i, name = "A", count = 1 } end
    return result
end
local function bounded(result, width, measure)
    assert(#result.lines <= 2)
    for _, line in ipairs(result.lines) do assert(measure(line) <= width) end
    equal(result.text, table.concat(result.lines, "\n"))
end

test("empty summary and unusable widths", function()
    equal(Layout.format({}, 20, chars).text, "")
    for _, width in ipairs({ 0, -1, math.huge, 0 / 0, "20" }) do
        local result = Layout.format(groups(3), width, chars)
        equal(result.text, "")
        equal(result.hidden, 3)
        equal(result.shown, 0)
    end
end)

test("one line exact fit and one unit below", function()
    local result = Layout.format(groups(2), 15, chars)
    equal(result.text, "A x 1  ·  A x 1")
    equal(result.hidden, 0)
    equal(Layout.format(groups(2), 14, chars).text, "A x 1\nA x 1")
end)

test("two lines exact fit preserve all groups", function()
    local result = Layout.format(groups(4), 15, chars)
    equal(result.text, "A x 1  ·  A x 1\nA x 1  ·  A x 1")
    equal(result.shown, 4)
    equal(result.hidden, 0)
    bounded(result, 15, chars)
end)

test("overflow reserves its own last line when necessary", function()
    local result = Layout.format(groups(5), 15, chars)
    equal(result.text, "A x 1  ·  A x 1\n... + 3 more")
    equal(result.shown, 2)
    equal(result.hidden, 3)
    bounded(result, 15, chars)
end)

test("evict the final group to fit a marker alongside a last-line group", function()
    local result = Layout.format(groups(6), 22, chars)
    equal(result.text, "A x 1  ·  A x 1\nA x 1  ·  ... + 3 more")
    equal(result.shown, 3)
    equal(result.hidden, 3)
    bounded(result, 22, chars)
end)

test("marker is remeasured when hidden types cross nine to ten", function()
    local seen = {}
    local function measure(text)
        seen[text] = true
        return chars(text)
    end
    local result = Layout.format(groups(13), 21, measure)
    -- Nine hidden would mean showing four, which has no room for the marker.
    -- Ten hidden makes the marker one unit too wide beside a fifth-width label.
    equal(result.shown, 2)
    equal(result.hidden, 11)
    equal(result.text, "A x 1  ·  A x 1\n... + 11 more")
    assert(seen["A x 1  ·  A x 1  ·  ... + 9 more"])
    assert(seen["A x 1  ·  ... + 10 more"])
    bounded(result, 21, chars)
end)

test("hidden count is distinct types rather than cup quantities", function()
    local input = groups(5)
    input[3].count, input[4].count, input[5].count = 900, 800, 700
    local result = Layout.format(input, 15, chars)
    equal(result.hidden, 3)
    equal(result.text, "A x 1  ·  A x 1\n... + 3 more")
end)

test("oversized group keeps stable prefix order without splitting its label", function()
    local input = { { name = "A", count = 1 }, { name = "A very long label", count = 2 },
        { name = "B", count = 3 } }
    local result = Layout.format(input, 15, chars)
    equal(result.text, "A x 1\n... + 2 more")
    equal(result.shown, 1)
    equal(result.hidden, 2)
end)

test("oversized first group uses only the overflow marker", function()
    local result = Layout.format({ { name = "An oversized label", count = 1 } }, 12, chars)
    equal(result.text, "... + 1 more")
    equal(result.shown, 0)
    equal(result.hidden, 1)
end)

test("insufficient width for marker safely hides everything", function()
    local result = Layout.format(groups(3), 5, chars)
    equal(result.text, "")
    equal(#result.lines, 0)
    equal(result.shown, 0)
    equal(result.hidden, 3)
end)

test("multibyte labels use supplied variable font widths intact", function()
    local input = { { name = "茶", count = 2 }, { name = "é", count = 3 } }
    local function measure(text)
        local width = 0
        for _, code in utf8.codes(text) do width = width + (code == 0x8336 and 4 or 1) end
        return width
    end
    local result = Layout.format(input, 18, measure)
    equal(result.text, "茶 x 2  ·  é x 3")
    equal(result.shown, 2)
    bounded(result, 18, measure)
    equal(Layout.format(input, 17, measure).text, "茶 x 2\né x 3")
end)

test("layout is deterministic and does not mutate its input", function()
    local input = groups(6)
    local result = Layout.format(input, 22, chars)
    equal(result.text, Layout.format(input, 22, chars).text)
    result.lines[1] = "changed"
    equal(Layout.format(input, 22, chars).text, "A x 1  ·  A x 1\nA x 1  ·  ... + 3 more")
    equal(#input, 6)
    for index, group in ipairs(input) do
        equal(group.id, index)
        equal(group.name, "A")
        equal(group.count, 1)
        local keys = 0
        for _ in pairs(group) do keys = keys + 1 end
        equal(keys, 3)
    end
end)

print("layout_spec: " .. passed .. " tests passed")
