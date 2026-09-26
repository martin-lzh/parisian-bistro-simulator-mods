local calls = 0
local directory = TEST_DIR
local path = directory .. '/bridge-status.txt'
local failure = false
package.loadlib = function(_, symbol)
    return function()
        calls = calls + 1
        if symbol == 'delivery_suspend' then return end
        if failure then return end
        local f = assert(io.open(path, 'w'))
        f:write(symbol == 'delivery_disable' and 'disabled\n' or 'ready\n'); f:close()
    end
end
local bridge = require('bridge').new(directory)
bridge:call('initialize'); bridge:call('free'); bridge:call('budget'); bridge:call('premium')
assert(calls == 4)
failure = true
assert(not pcall(function() bridge:call('free') end)) -- stale ready cannot count as success
failure = false; bridge:call('disable')
local before = assert(io.open(path, 'r')); local previous = before:read('*a'); before:close()
bridge:suspend()
local file = assert(io.open(path, 'r')); assert(file:read('*a') == previous); file:close()
assert(not pcall(function() bridge:call('suspend') end))
assert(not pcall(function() bridge:call('unknown') end))
