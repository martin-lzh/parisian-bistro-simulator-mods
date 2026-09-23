local original_game, original_print = package.loaded.game, print
local globals = { 'RegisterHook', 'LoopInGameThreadWithDelay', 'LoopAsync',
    'ExecuteInGameThread', 'ExecuteInGameThreadWithDelay' }
local saved = {}
for _, key in ipairs(globals) do saved[key] = _G[key] end
local count = 0
local function test(name, fn)
    fn()
    package.loaded.game, print = original_game, original_print
    for _, key in ipairs(globals) do _G[key] = saved[key] end
    count = count + 1
    print('PASS ' .. name)
end

local function fixture(modern, failure)
    local f = { queue = {}, logs = {}, calls = {}, reads = 0, discoveries = 0 }
    f.session = { id = 'world-a', now = 0, blocked = false }
    f.registers = { { id = 'register-a' }, { id = 'register-b' } }
    f.states = {}
    for _, r in ipairs(f.registers) do
        f.states[r.id] = { id = r.id, payment_id = 'payment-' .. r.id,
            has_bill = true, method = 'cash', drawer_open = false }
    end
    package.loaded.game = {
        valid = function(r) return r and not r.invalid end,
        identity = function(r) return r.id end,
        contract = function() return {} end,
        ai_contexts = function() return {} end,
        session = function()
            f.reads = f.reads + 1
            return f.session, f.session and 'host' or 'client-not-host'
        end,
        registers = function()
            f.discoveries = f.discoveries + 1
            return f.registers, #f.registers
        end,
        snapshot = function(_, session, r)
            local state = f.states[r.id]
            if state then
                state.blocked, state.block_reason = session.blocked, session.block_reason
            end
            return state, 'payment-unavailable'
        end,
        request = function(_, _, r, _, action, on_dispatch)
            on_dispatch(r.id, 57)
            f.calls[#f.calls + 1] = { register = r.id, action = action }
            if f.on_request then f.on_request(r) end
            return true
        end,
    }
    RegisterHook = function(path, pre, post)
        assert(path == '/Script/BrasserieSimulator.CashRegister:Multicast_DisplayCustomerAtBillingNotification')
        assert(pre() == nil and type(post) == 'function')
        if failure == 'hook' then error('injected hook registration failure') end
        f.notify = post
        return 1, 2
    end
    local function enqueue(fn) f.queue[#f.queue + 1] = fn end
    ExecuteInGameThread = enqueue
    ExecuteInGameThreadWithDelay = modern and function(delay, fn)
        assert(delay == 50)
        if failure == 'schedule' then error('injected notification scheduling failure') end
        enqueue(fn)
    end or nil
    LoopInGameThreadWithDelay = modern and function(_, fn)
        if failure == 'timer' then error('injected timer failure') end
        f.timer = fn
    end or nil
    LoopAsync = function(_, fn) f.timer = fn end
    print = function(message) f.logs[#f.logs + 1] = message end
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    function f.emit(register)
        local expired = false
        local context = { get = function()
            assert(not expired, 'hook context must not escape into a deferred callback')
            return register
        end }
        assert(f.notify(context) == nil, 'observer must not override the native return value')
        expired = true
    end
    function f.flush()
        local tasks = f.queue
        f.queue = {}
        for _, fn in ipairs(tasks) do fn() end
    end
    function f.poll() f.timer(); f.flush() end
    function f.contains(text) return table.concat(f.logs, '\n'):find(text, 1, true) ~= nil end
    return f
end

for _, modern in ipairs({ true, false }) do
    local mode = modern and 'modern' or 'legacy'
    test(mode .. ': notifications coalesce, defer reads and target only their register', function()
        local f = fixture(modern)
        for _ = 1, 20 do f.emit(f.registers[1]) end
        assert(f.reads == 0 and #f.calls == 0 and #f.queue == 1)
        f.flush()
        assert(#f.calls == 1 and f.calls[1].register == 'register-a')
        assert(f.contains('HOOK installed event=customer-at-billing'))
        assert(f.contains('EVENT customer-at-billing count=20 phase=take'))
        assert(f.contains('source=notification'))
        f.poll()
        assert(#f.calls == 2 and f.calls[2].register == 'register-b', 'poll must retain both histories')
        f.emit(f.registers[1]); f.flush()
        assert(#f.calls == 2, 'notification must not reset the cooldown')
    end)

    test(mode .. ': an early notification waits for payment and polling completes both steps', function()
        local f = fixture(modern)
        f.registers[2] = nil
        local state = f.states['register-a']
        state.has_bill, state.payment_id = false, nil
        f.emit(f.registers[1]); f.flush()
        assert(#f.calls == 0 and f.contains('phase=wait-bill'))
        state.has_bill, state.payment_id = true, 'payment-ready'
        f.poll()
        assert(#f.calls == 1 and f.calls[1].action == 'take')
        state.payment_id, state.drawer_open = nil, true
        f.session.now = 1
        f.poll()
        assert(#f.calls == 2 and f.calls[2].action == 'finish')
    end)
end

test('notification and poll requests share the three-attempt budget', function()
    local f = fixture(true)
    f.registers[2] = nil
    for time = 0, 12 do
        f.session.now = time
        f.emit(f.registers[1]); f.flush(); f.poll()
    end
    assert(#f.calls == 3 and f.contains('WARN No progress after three take requests'))
end)

test('notification callbacks never bypass host, world, or object lifetime filtering', function()
    local f = fixture(true)
    f.session = nil
    f.emit(f.registers[1]); f.flush()
    assert(#f.calls == 0 and f.discoveries == 0 and f.contains('reason=client-not-host'))
    f.session = { id = 'world-a', now = 0 }
    f.emit(f.registers[1])
    f.session.id, f.registers = 'world-b', {}
    f.flush()
    assert(#f.calls == 0 and f.contains('reason=not-current-authoritative-register'))
    f.emit({ id = 'destroyed', invalid = true })
    assert(#f.queue == 0)
end)

test('notifications respect paused games, card processing, and unavailable snapshots', function()
    local f = fixture(true)
    f.registers[2] = nil
    f.session.blocked, f.session.block_reason = true, 'game-paused'
    f.emit(f.registers[1]); f.flush()
    assert(#f.calls == 0 and f.contains('phase=wait-game-paused'))
    f.session.blocked, f.session.block_reason = false, nil
    f.states['register-a'].card_in_machine = true
    f.emit(f.registers[1]); f.flush()
    assert(#f.calls == 0 and f.contains('phase=wait-card-processing'))
    f.states['register-a'] = nil
    f.emit(f.registers[1]); f.flush()
    assert(#f.calls == 0 and f.contains('register=register-a unavailable=payment-unavailable'))
end)

test('a failed hook registration keeps ordinary checkout polling active', function()
    local f = fixture(true, 'hook')
    assert(f.contains('polling remains active') and not f.notify)
    f.poll()
    assert(#f.calls == 2 and not f.contains('ERROR'))
end)

test('notification scheduling failures disable only the listener', function()
    local f = fixture(true, 'schedule')
    f.emit(f.registers[1])
    assert(f.contains('injected notification scheduling failure') and #f.calls == 0)
    f.emit(f.registers[1])
    assert(#f.queue == 0)
    f.poll()
    assert(#f.calls == 2 and not f.contains('ERROR'))
end)

test('an invalid callback context disables only the listener without changing the native return', function()
    local f = fixture(true)
    assert(f.notify({ get = function() error('injected expired hook context') end }) == nil)
    assert(f.contains('injected expired hook context') and f.contains('polling remains active'))
    f.emit(f.registers[1])
    assert(#f.queue == 0)
    f.poll()
    assert(#f.calls == 2 and not f.contains('ERROR'))
end)

test('timer startup failure cannot leave an event listener automating checkout', function()
    local f = fixture(true, 'timer')
    assert(f.timer == nil and f.notify == nil)
    assert(f.contains('ERROR stage=startup') and not f.contains('HOOK installed'))
end)

test('a notification raised during dispatch waits for a separate callback', function()
    local f = fixture(true)
    f.on_request = function(r)
        if r.id == 'register-a' then f.emit(f.registers[2]) end
    end
    f.emit(f.registers[1]); f.flush()
    assert(#f.calls == 1 and #f.queue == 1)
    f.flush()
    assert(#f.calls == 2 and f.calls[2].register == 'register-b')
end)

print(string.format('Notifications: %d tests passed', count))
