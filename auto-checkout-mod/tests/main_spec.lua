local original_game = package.loaded.game
local function test_mode(modern)
    local loops, queue, logs = {}, {}, {}
    local reads, calls, stopped = 0, 0, false
    local session = { id = 'world-a', now = 0, blocked = false }
    local snapshot = { id = 'register', payment_id = 'payment', has_bill = true, method = 'cash' }
    package.loaded.game = {
        contract = function() return {} end,
        session = function()
            reads = reads + 1
            if stopped then error('reflected API mismatch') end
            return session
        end,
        registers = function() return { {} } end,
        snapshot = function() return snapshot end,
        request = function() calls = calls + 1 end,
    }
    LoopInGameThreadWithDelay = modern and function(_, fn) loops[1] = fn end or nil
    LoopAsync = function(_, fn) loops[1] = fn end
    ExecuteInGameThread = function(fn) queue[#queue + 1] = fn end
    local saved_print = print
    print = function(text) logs[#logs + 1] = text end
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    local function flush()
        local pending = queue
        queue = {}
        for _, fn in ipairs(pending) do fn() end
    end
    loops[1]()
    if not modern then
        loops[1]()
        assert(#queue == 1 and reads == 0, 'asynchronous callbacks must coalesce')
    end
    flush()
    assert(reads == 1 and calls == 1)
    session.blocked = true
    session.now = 1
    loops[1](); flush()
    assert(calls == 1)
    session.blocked = false
    loops[1](); flush()
    assert(calls == 1, 'waiting for the player must not reset transaction history')
    session = nil
    loops[1](); flush()
    session = { id = 'world-b', now = 0, blocked = false }
    loops[1](); flush()
    assert(calls == 2, 'new world must not inherit old transaction history')
    stopped = true
    loops[1](); flush()
    local previous = reads
    for _ = 1, 4 do loops[1](); flush() end
    assert(reads == previous, 'unexpected errors must stop future requests')
    assert(logs[#logs]:find('Stopped after an error', 1, true))
    print = saved_print
end
test_mode(true)
test_mode(false)
package.loaded.game = original_game
print('Runtime: 2 scheduler and lifecycle tests passed')
