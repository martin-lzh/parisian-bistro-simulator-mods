local F, Game = require('fakes'), require('game')
local real_clock, real_print = os.clock, print
local now, logs = 0, {}
os.clock = function() now = now + 0.000001; return now end
print = function(message) logs[#logs + 1] = message end
local state = F.setup()
local bridge = require('bridge'); local solve = bridge.solve
bridge.solve = function(...) now = now + 0.1; return solve(...) end
state.manager.GetDailyMenuMaximumPromotedAdoptionChance = function() now = now + 0.011; return 1 end
state.on_save = function() now = now + 0.005 end
state.owner.RefreshDailyMenus = function() now = now + 0.007 end
local result = Game.compose(state.owner)
local timing = result.timing
local function close(a, b) assert(math.abs(a - b) < 1e-8, tostring(a) .. ' ~= ' .. tostring(b)) end
close(timing.setup, 0.011001); close(timing.search, 0.100001)
close(timing.save, 0.005001); close(timing.refresh, 0.007001)
local sum = 0
for _, phase in ipairs({ 'setup', 'search', 'restore', 'save', 'verify', 'refresh', 'lua_and_timing' }) do
    assert(timing[phase] >= 0); sum = sum + timing[phase]
end
close(sum, timing.total)
assert(#logs == 1, 'No per-trial logging')
os.clock = function() return 0 end
local function click_and_logs()
    logs = {}
    dofile(MOD_ROOT .. '/Scripts/main.lua'); state.loops[500](); logs = {}
    state:click(state.footer.children[2])
    assert(#logs == 4, 'Four summaries per search')
    local joined = table.concat(logs)
    assert(not joined:find('nan') and not joined:find('inf'))
    assert(joined:find('search=0.000ms(0.00%)', 1, true))
    assert(joined:find('cache_hits=', 1, true) and joined:find('checks=', 1, true))
    return joined
end
state = F.setup(); state.manager.AvailableDishes = F.array({})
local joined = click_and_logs()
assert(joined:find('combinations=1', 1, true) and joined:find('stop=exhausted', 1, true))
state = F.setup(); state.ceiling = 1
joined = click_and_logs(); assert(joined:find('stop=native_ceiling', 1, true))
os.clock, print = real_clock, real_print
print('Timing: exclusive totals, native cache metrics, bounded logging and zero-duration clocks passed')
