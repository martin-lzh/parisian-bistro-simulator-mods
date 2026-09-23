-- Run from any working directory with Lua 5.4: lua path/to/summary_spec.lua
local source = debug.getinfo(1, "S").source:sub(2)
local directory = source:match("^(.*[/\\])") or "./"
local Summary = dofile(directory .. "../Scripts/summary.lua")
local passed = 0

local function equal(actual, expected)
    assert(actual == expected, "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function test(name, fn)
    local ok, message = pcall(fn)
    assert(ok, name .. ": " .. tostring(message))
    passed = passed + 1
end

local function order(id, drink, state, claimed, player)
    return { id = id, drink = drink, state = state, claimed = claimed, player_id = player }
end

local function label(id)
    return "Localized " .. id
end

test("group by drink and sort by numeric ID", function()
    local result = Summary.collect({
        order("a", 10, 0, true, 7),
        order("b", 2, 1, true, 7),
        order("c", 10, 1, true, 7),
    }, 7, label)
    equal(result.total, 3)
    equal(#result.groups, 2)
    equal(result.groups[1].id, 2)
    equal(result.groups[1].count, 1)
    equal(result.groups[2].count, 2)
    equal(result.text, "Localized 2 x 1  ·  Localized 10 x 2")
end)

test("only local claimed pending or preparing orders remain", function()
    local result = Summary.collect({
        order("pending", 1, 0, true, 0),
        order("preparing", 1, 1, true, 0),
        order("prepared", 1, 2, true, 0),
        order("other", 1, 0, true, 1),
        order("unclaimed", 1, 0, false, 0),
        order("truthy", 1, 0, 1, 0),
        order("unknown", 1, 3, true, 0),
    }, 0, label)
    equal(result.total, 2)
end)

test("unclaim, reassignment, preparation and cancellation clear the next snapshot", function()
    local entry = order("a", 1, 0, true, 7)
    equal(Summary.collect({ entry }, 7, label).total, 1)
    entry.claimed = false
    equal(Summary.collect({ entry }, 7, label).text, "")
    entry.claimed, entry.player_id = true, 8
    equal(Summary.collect({ entry }, 7, label).total, 0)
    entry.player_id, entry.state = 7, 2
    equal(Summary.collect({ entry }, 7, label).total, 0)
    local cancelled = Summary.collect({}, 7, label)
    equal(cancelled.total, 0)
    equal(#cancelled.groups, 0)
    equal(cancelled.text, "")
end)

test("deduplicate valid eligible order IDs", function()
    local result = Summary.collect({
        order("a", 2, 0, false, 7),
        order("a", 2, 0, true, 7),
        order("a", 2, 1, true, 7),
        order("b", 2, 0, true, 7),
    }, 7, label)
    equal(result.total, 2)
    equal(result.groups[1].count, 2)
end)

test("translation collisions do not merge different drinks", function()
    local result = Summary.collect({ order("a", 2, 0, true, 7), order("b", 1, 0, true, 7) },
        7, function() return "Same label" end)
    equal(#result.groups, 2)
    equal(result.groups[1].id, 1)
    equal(result.groups[2].id, 2)
end)

test("input order does not change group ordering", function()
    local a, b = order("a", 9, 0, true, 7), order("b", 3, 0, true, 7)
    equal(Summary.collect({ a, b }, 7, label).text, Summary.collect({ b, a }, 7, label).text)
end)

test("invalid local identity never shows orders", function()
    for _, player in ipairs({ -1, 0.5, "7", false, math.huge, 0 / 0 }) do
        equal(Summary.collect({ order("a", 1, 0, true, player) }, player, label).total, 0)
    end
    equal(Summary.collect({ order("a", 1, 0, true, nil) }, nil, label).total, 0)
end)

test("malformed records and inputs are ignored", function()
    local entries = { false, "bad", {}, order("", 1, 0, true, 7), order("  ", 1, 0, true, 7) }
    for i, drink in ipairs({ -1, 1.5, "2", false, math.huge, 0 / 0 }) do
        entries[#entries + 1] = order("bad" .. i, drink, 0, true, 7)
    end
    entries[#entries + 1] = order("string state", 1, "0", true, 7)
    entries[#entries + 1] = order("string owner", 1, 0, true, "7")
    entries[#entries + 1] = order("valid", 0, 0, true, 7)
    equal(Summary.collect(entries, 7, label).total, 1)
    equal(Summary.collect(nil, 7, label).text, "")
    equal(Summary.collect("bad", 7, label).text, "")
end)

test("failed or empty translations preserve quantities with numeric fallback", function()
    local entries = { order("a", 4, 0, true, 7) }
    equal(Summary.collect(entries, 7).text, "Drink 4 x 1")
    for _, translate in ipairs({
        function() error("missing") end,
        function() return nil end,
        function() return false end,
        function() return " \n\t" end,
    }) do
        equal(Summary.collect(entries, 7, translate).text, "Drink 4 x 1")
    end
end)

test("translation runs once per group and keeps a single line", function()
    local calls = 0
    local result = Summary.collect({ order("a", 1, 0, true, 7), order("b", 1, 1, true, 7) },
        7, function()
            calls = calls + 1
            return "  Thé\n\t glacé\r\n "
        end)
    equal(calls, 1)
    equal(result.text, "Thé glacé x 2")
end)

test("collect does not mutate inputs and returns fresh results", function()
    local entry = order("a", 1, 0, true, 7)
    local entries = { entry }
    local result = Summary.collect(entries, 7, label)
    equal(entries[1], entry)
    equal(#entries, 1)
    local expected = order("a", 1, 0, true, 7)
    for key, value in pairs(entry) do equal(value, expected[key]) end
    for key, value in pairs(expected) do equal(entry[key], value) end
    result.groups[1].count = 999
    equal(Summary.collect(entries, 7, label).groups[1].count, 1)
end)

print("summary_spec: " .. passed .. " tests passed")
