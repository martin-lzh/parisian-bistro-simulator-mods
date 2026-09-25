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
            return session, session and 'host' or 'no-local-controller'
        end,
        registers = function() return { {} }, 1 end,
        ai_contexts = function() return {} end,
        identity = function() return 'register' end,
        snapshot = function() return snapshot end,
        request = function(_, _, _, _, action, on_dispatch)
            on_dispatch(action == 'take' and 'payment' or 'register', 57, 'scope=target-call distance=5000.0')
            calls = calls + 1
            return true
        end,
    }
    LoopInGameThreadWithDelay = modern and function(_, fn) loops[1] = fn end or nil
    LoopAsync = function(_, fn) loops[1] = fn end
    ExecuteInGameThread = function(fn) queue[#queue + 1] = fn end
    local saved_print = print
    print = function(text) logs[#logs + 1] = text end
    ModRef = NewTestModRef()
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
    session.blocked, session.block_reason, snapshot.blocked = true, 'game-paused', true
    session.now = 1
    loops[1](); flush()
    assert(calls == 1)
    session.blocked, session.block_reason, snapshot.blocked = false, nil, false
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
    assert(logs[#logs]:find('stage=session', 1, true) and logs[#logs]:find('stack traceback', 1, true))
    local text = table.concat(logs, '\n')
    assert(text:find('version=0.1.4-dev ', 1, true))
    assert(text:find('blocked=game-paused', 1, true))
    assert(text:find('player_guard=transaction-only', 1, true))
    assert(text:find('REQUEST phase=take attempt=1 target=payment', 1, true))
    assert(text:find('context={scope=target-call distance=5000.0}', 1, true))
    assert(text:find('DISPATCH_RETURNED', 1, true) and text:find('acceptance=unconfirmed', 1, true))
    assert(text:find('AFTER register=register', 1, true))
    assert(text:find('waiting=no-local-controller', 1, true))
    print = saved_print
end
test_mode(true)
test_mode(false)

local function diagnostic_paths()
    local logs, callback, requests = {}, nil, 0
    local saved_print = print
    print = function(text) logs[#logs + 1] = text end
    local mode = 'no-registers'
    local session = { id = 'world', now = 0, blocked = false }
    local snapshot = { id = 'register', payment_id = 'cash', has_bill = true, method = 'cash' }
    package.loaded.game = {
        contract = function() return { action = 57, cash_method = 1, card_method = 2 } end,
        identity = function() return 'register' end,
        session = function() return session end,
        ai_contexts = function() return {} end,
        registers = function()
            if mode == 'no-registers' then return {}, 0 end
            return { {} }, 1
        end,
        snapshot = function()
            if mode == 'invalid-snapshot' then return nil, 'payment-type-mismatch raw_method=99' end
            return snapshot
        end,
        request = function(_, _, _, _, _, on_dispatch)
            if mode == 'skip' then return false, 'register-being-handled' end
            on_dispatch('cash', 57)
            requests = requests + 1
            if mode == 'rpc-error' then error('injected RPC bridge error') end
            return true
        end,
    }
    LoopInGameThreadWithDelay = function(_, fn) callback = fn end
    ModRef = NewTestModRef()
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    for _ = 1, 60 do callback() end
    local combined = table.concat(logs, '\n')
    assert(combined:find('registers=0 discovered=0 dispatched=0', 1, true))
    assert(#logs < 10, 'no-register diagnostics must be observable without per-second spam')

    mode = 'skip'
    callback()
    assert(requests == 0 and logs[#logs]:find('SKIP phase=take', 1, true))
    mode, session.now = 'unchanged-payment', 3
    callback()
    assert(requests == 1)
    mode, session.now = 'invalid-snapshot', 4
    callback()
    assert(logs[#logs]:find('unavailable=payment-type-mismatch', 1, true))
    mode, session.now = 'unchanged-payment', 5
    callback()
    assert(requests == 1, 'transiently invalid snapshots must not erase the cooldown or retry history')
    for t = 6, 15 do session.now = t; callback() end
    assert(requests == 3)
    assert(table.concat(logs, '\n'):find('WARN No progress after three requests', 1, true))
    assert(table.concat(logs, '\n'):find('phase=take register=register', 1, true))

    session.id, session.now, mode = 'new-world', 0, 'rpc-error'
    callback()
    assert(requests == 4 and logs[#logs]:find('stage=request-take', 1, true))
    assert(logs[#logs]:find('register=register', 1, true))
    assert(logs[#logs]:find('injected RPC bridge error', 1, true))
    callback()
    assert(requests == 4, 'RPC exceptions must stop future automatic requests')

    LoopInGameThreadWithDelay = function() error('injected timer registration error') end
    ModRef = NewTestModRef()
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    assert(logs[#logs]:find('ERROR stage=startup', 1, true))
    assert(logs[#logs]:find('injected timer registration error', 1, true))

    LoopInGameThreadWithDelay = nil
    LoopAsync = function(_, fn) callback = fn end
    ExecuteInGameThread = function() error('injected scheduler error') end
    ModRef = NewTestModRef()
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    callback()
    assert(logs[#logs]:find('stage=game-thread-scheduling', 1, true))
    assert(logs[#logs]:find('injected scheduler error', 1, true))

    local saved_game, saved_loader = package.loaded.game, package.preload.game
    package.loaded.game = nil
    package.preload.game = function() error('injected module load error') end
    ModRef = NewTestModRef()
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    assert(logs[#logs]:find('ERROR stage=startup', 1, true))
    assert(logs[#logs]:find('injected module load error', 1, true))
    package.loaded.game, package.preload.game = saved_game, saved_loader
    print = saved_print
end
diagnostic_paths()
package.loaded.game = original_game
print('Runtime: 3 scheduler, lifecycle and diagnostic-path tests passed')
