local F, Game = require('fakes'), require('game')
local real_clock, real_print = os.clock, print
local now, logs = 0, {}
os.clock = function() now = now + 0.000001; return now end
print = function(message) logs[#logs + 1] = message end
local state = F.setup()
local fields = state.manager.LunchDailyMenu
state.manager.LunchDailyMenu = setmetatable({}, {
    __index = fields,
    __newindex = function(_, key, value)
        if key ~= 'Period' then now = now + 0.002 end
        fields[key] = value
    end,
})
state.manager.GetDailyMenuMaximumPromotedAdoptionChance = function() now = now + 0.011; return 1 end
local project = state.owner.GetDailyMenuProjection
state.owner.GetDailyMenuProjection = function(self, period)
    now = now + 0.003
    local projection = project(self, period)
    return setmetatable({}, { __index = function(_, key)
        assert(key == 'EstimatedAdoptionRate')
        now = now + 0.001
        return projection[key]
    end })
end
state.on_save = function() now = now + 0.005 end
state.owner.RefreshDailyMenus = function() now = now + 0.007 end
local result = Game.compose(state.owner)
local timing = result.timing
local function close(a, b) assert(math.abs(a - b) < 1e-8, tostring(a) .. ' ~= ' .. tostring(b)) end
assert(result.evaluations == 243 and result.combinations == 243 and state.saves == 1)
close(timing.projection, 243 * 0.003001)
close(timing.rate_read, 243 * 0.001001)
close(timing.writes, timing.field_writes * 0.002 + 243 * 0.000001)
close(timing.setup, 0.011001)
close(timing.save, 0.005001)
close(timing.refresh, 0.007001)
local sum = 0
for _, phase in ipairs({ 'setup', 'writes', 'projection', 'rate_read', 'restore', 'save', 'verify', 'refresh', 'lua_and_timing' }) do
    assert(timing[phase] >= 0)
    sum = sum + timing[phase]
end
close(sum, timing.total)
assert(timing.search > timing.projection + timing.writes + timing.rate_read)
assert(#logs == 1 and logs[1]:find('combinations=243', 1, true), 'No per-trial logging')

-- A coarse timer can report zero for an entire run. Logs must stay finite,
-- count empty choices, and distinguish a proven ceiling from full enumeration.
os.clock = function() return 0 end
local function click_and_logs()
    logs = {}
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    state.loops[500]()
    logs = {}
    state:click(state.footer.children[2])
    assert(#logs == 4, 'Only start, result and two timing summaries per search')
    local joined = table.concat(logs)
    assert(not joined:find('nan') and not joined:find('inf'))
    assert(joined:find('projection_avg_ms=0.000000', 1, true))
    assert(joined:find('projection=0.000ms(0.00%)', 1, true))
    return joined
end
state = F.setup(); state.manager.AvailableDishes = F.array({})
local joined = click_and_logs()
assert(joined:find('combinations=1', 1, true) and joined:find('evaluations=1', 1, true))
assert(joined:find('stop=exhausted', 1, true))
state = F.setup(); state.manager.LunchDailyMenu.MainDish = 20
state.oracle = function() return 1 end
joined = click_and_logs()
assert(joined:find('combinations=243', 1, true) and joined:find('evaluations=1', 1, true))
assert(joined:find('stop=native_ceiling', 1, true))
os.clock, print = real_clock, real_print
print('Timing: exclusive phase totals, native/read/write attribution, bounded logs, empty and ceiling cases passed')
