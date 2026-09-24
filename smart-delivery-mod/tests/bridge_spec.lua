local calls = 0
local directory = TEST_DIR
local path = directory .. '/bridge-status.txt'
local failure = false
package.loadlib = function(_, symbol)
    return function()
        calls = calls + 1
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
assert(not pcall(function() bridge:call('unknown') end))
