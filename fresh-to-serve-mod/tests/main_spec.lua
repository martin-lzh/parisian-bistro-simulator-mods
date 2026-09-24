local ticks, contracts, queued, logs = 0, 0, {}, {}
local old_print = print
print = function(message) logs[#logs+1] = message end
package.loaded.game = { contract = function() contracts = contracts + 1; return {} end }
package.loaded.remake = { new = function()
    return { tick = function() ticks = ticks + 1; if ticks == 2 then error('bridge failed') end end }
end }
LoopAsync = function(delay, callback) assert(delay == 1000); _G.loop = callback end
ExecuteInGameThread = function(callback) queued[#queued+1] = callback end
dofile(MOD_ROOT .. '/Scripts/main.lua')
loop(); loop(); assert(#queued == 1 and ticks == 0)
queued[1](); loop(); assert(#queued == 2 and ticks == 1)
queued[2](); loop(); assert(#queued == 2 and ticks == 2 and contracts == 1)
assert(logs[#logs]:find('automation%-stopped'))
local direct
LoopInGameThreadWithDelay = function(delay, callback) assert(delay == 1000); direct = callback end
package.loaded.remake.new = function() return { tick = function() ticks = ticks + 1 end } end
dofile(MOD_ROOT .. '/Scripts/main.lua'); direct(); assert(ticks == 3)
print = old_print
print('main_spec: scheduling coalesces callbacks and stops after uncertain engine errors')
