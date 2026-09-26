local Reload = require('reload')
local old_game, old_print = package.loaded.game, print
local globals = { 'ModRef', 'RegisterHook', 'LoopInGameThreadWithDelay', 'LoopAsync',
    'ExecuteInGameThread', 'ExecuteInGameThreadWithDelay' }
local saved, count = {}, 0
for _, key in ipairs(globals) do saved[key] = _G[key] end
local function test(name, fn)
    fn()
    package.loaded.game, print = old_game, old_print
    for _, key in ipairs(globals) do _G[key] = saved[key] end
    count = count + 1
    print('PASS ' .. name)
end

local function array(values, before_write)
    local data = { table.unpack(values) }
    return setmetatable({
        GetArrayNum = function() return #data end,
        Empty = function() before_write(); data = {} end,
    }, {
        __index = function(_, key) return data[key] end,
        __newindex = function(_, key, value) data[key] = value end,
    })
end

local function fixture(modern)
    local f = { shared = {}, logs = {}, queue = {}, reads = 0, calls = 0, writes = 0,
        on_game_thread = true, modern = modern ~= false }
    f.session = { id = 'world-a/player-a', now = 0 }
    f.snapshot = { id = 'register-a', payment_id = 'cash-a', has_bill = true, method = 'cash' }
    local billing = { id = 'billing-a', IsA = function(_, class) return class == 'billing' end }
    local drink = { id = 'drink-a', IsA = function() return false end }
    local serving = { id = 'serve-a', IsA = function() return false end }
    f.ref = NewTestModRef(f.shared)
    local function guard()
        assert(f.on_game_thread, 'Unload attempted to access an engine object')
        f.reads = f.reads + 1
    end
    f.container = { id = 'container-a', Evaluators = array({ drink, billing, serving }, function()
        guard()
        local record = Reload.new(f.ref).state.removed['container-a']
        assert(record and record.recovery, 'Every array mutation must have a saved recovery plan')
        f.writes = f.writes + 1
        if f.fail_array then error('injected engine array failure') end
    end) }
    f.context = { id = 'job-a', containers = { f.container }, evaluators = array({ drink, billing, serving }, function() end) }
    local game = {
        valid = function(value) guard(); return value ~= nil end,
        identity = function(value) guard(); return value.id end,
        contract = function() guard(); return { billing_task = 'billing', action = 58 } end,
        session = function() guard(); return f.session, 'no-local-controller' end,
        ai_contexts = function() guard(); return f.missing_context and {} or { f.context } end,
        registers = function() guard(); return { { id = 'register-a' } }, 1 end,
        snapshot = function() guard(); return f.snapshot end,
        request = function(_, _, _, _, action, on_dispatch)
            guard()
            local record = Reload.new(f.ref).state.registers['register-a'].attempts[action]
            assert(record.count >= 1 and record.next_at == f.session.now + 3,
                'Attempt budget must be saved before dispatch')
            f.calls = f.calls + 1
            on_dispatch(f.snapshot.payment_id or 'register-a', 58)
            if f.fail_request then error('injected native request failure') end
            return true
        end,
    }
    function f.start()
        package.loaded.game = game
        f.ref = NewTestModRef(f.shared)
        local set = f.ref.SetSharedVariable
        f.ref.SetSharedVariable = function(self, key, value)
            if f.fail_storage then error('injected shared storage failure') end
            set(self, key, value)
        end
        ModRef = f.ref
        RegisterHook = function(_, _, post) f.notify = post; return 1, 2 end
        local function queue(fn) f.queue[#f.queue + 1] = fn end
        ExecuteInGameThread = queue
        ExecuteInGameThreadWithDelay = f.modern and function(_, fn) queue(fn) end or nil
        LoopInGameThreadWithDelay = f.modern and function(_, fn) f.timer = fn end or nil
        LoopAsync = function(_, fn) f.timer = fn end
        print = function(message) f.logs[#f.logs + 1] = message end
        dofile(MOD_ROOT .. '/Scripts/main.lua')
    end
    function f.flush()
        local pending = f.queue
        f.queue = {}
        for _, fn in ipairs(pending) do fn() end
    end
    function f.poll() f.timer(); f.flush() end
    function f.unload()
        local reads, queued = f.reads, #f.queue
        f.on_game_thread = false
        f.ref.OnUnload()
        f.on_game_thread = true
        assert(f.reads == reads and #f.queue == queued, 'Unload must neither read objects nor enqueue callbacks')
    end
    function f.reload() f.unload(); f.start() end
    function f.state() return Reload.new(f.ref).state end
    f.start()
    return f
end

test('handoff safely round-trips escaped identities and rejects executable or malformed strings', function()
    local shared, ref = {}, nil
    ref = NewTestModRef(shared)
    local journal = Reload.new(ref)
    local identity = 'register\n\"\\:t123;汉字'
    local state = { session = 'world', registers = { [identity] = {
        payment_id = 'payment', attempts = { take = { count = 3, next_at = 12.125, warned = true } },
    } }, removed = {} }
    journal:save(state)
    assert(Reload.new(ref).state.registers[identity].attempts.take.next_at == 12.125)
    local key, payload = next(shared)
    for _, bad in ipairs({ 'error("executed")', 'ACR2\nt0:', payload:sub(1, -2), payload .. 'junk',
        'ACR1\nt2:s7:removedt0:s9:registerst1:s1:rt1:s8:attemptst1:s4:taket1:s5:countn3:nan' }) do
        shared[key] = bad
        assert(not pcall(Reload.new, ref))
        assert(shared[key] == bad, 'Unreadable handoff must never be overwritten')
    end
    shared[key] = payload
    state.registers[identity].attempts.take.count = 4
    assert(not pcall(function() journal:save(state) end) and shared[key] == payload)
end)

for _, modern in ipairs({ true, false }) do
    test((modern and 'modern' or 'legacy') .. ' reload preserves AI ownership and payment cooldown without duplicate callbacks', function()
        local f = fixture(modern)
        f.poll()
        assert(f.calls == 1 and f.container.Evaluators:GetArrayNum() == 2)
        local timer, notify = f.timer, f.notify
        f.notify({ get = function() return { id = 'register-a' } end })
        f.unload()
        local reads = f.reads
        timer()
        notify({ get = function() error('retired hook used context') end })
        f.flush()
        assert(f.reads == reads and f.calls == 1, 'Retired callbacks must be inert')
        f.start()
        f.session.now = 0.5
        f.poll()
        assert(f.calls == 1 and f.writes == 3, 'New instance restores then reapplies AI once')
        assert(f.container.Evaluators:GetArrayNum() == 2)
        assert(f.state().registers['register-a'].attempts.take.count == 1)
        f.session.now = 3
        f.poll()
        assert(f.calls == 2)
    end)
end

test('repeated reloads cannot reset an exhausted transaction retry budget', function()
    local f = fixture()
    for index = 1, 3 do
        f.session.now = (index - 1) * 3
        f.poll()
        f.reload()
    end
    f.session.now = 20
    f.poll()
    assert(f.calls == 3 and f.state().registers['register-a'].attempts.take.warned)
    f.reload(); f.poll()
    assert(f.calls == 3)
    f.snapshot.payment_id = 'cash-next-customer'
    f.poll()
    assert(f.calls == 4, 'A new customer still receives a fresh budget')
end)

test('finish-stage retries are retained independently across reload', function()
    local f = fixture()
    f.snapshot.payment_id, f.snapshot.drawer_open = nil, true
    f.snapshot.method, f.snapshot.successful = 'card', true
    f.poll(); f.reload()
    f.session.now = 1
    f.poll()
    assert(f.calls == 1 and f.state().registers['register-a'].attempts.finish.count == 1)
end)

test('a temporary missing controller after reload does not erase inherited attempts', function()
    local f = fixture()
    f.poll(); f.reload()
    local session = f.session
    f.session = nil
    f.poll()
    assert(f.state().session == session.id and f.state().registers['register-a'])
    f.session, session.now = session, 1
    f.poll()
    assert(f.calls == 1)
    session.id, session.now = 'new-world/player', 0
    f.poll()
    assert(f.calls == 2, 'Different sessions must reset old transaction state')
end)

test('failed AI recovery remains available to another reload and blocks payment', function()
    local f = fixture()
    f.poll(); f.reload()
    f.fail_array = true
    f.poll()
    assert(f.calls == 1 and f.state().removed['container-a'].recovery)
    f.reload()
    f.fail_array, f.session.now = false, 1
    f.poll()
    assert(f.calls == 1 and f.container.Evaluators:GetArrayNum() == 2)
    assert(f.state().removed['container-a'].recovery == nil)
end)

test('missing recovery containers are retained instead of silently forgetting suppressed AI', function()
    local f = fixture()
    f.poll(); f.reload()
    f.missing_context = true
    f.poll()
    assert(f.calls == 1 and f.state().removed['container-a'])
    f.reload()
    f.missing_context, f.session.now = false, 1
    f.poll()
    assert(f.calls == 1 and f.writes == 3)
end)

test('reload during travel waits for a controller then discards destroyed prior-world records', function()
    local f = fixture()
    f.poll(); f.reload()
    f.session, f.missing_context = nil, true
    f.poll()
    assert(f.calls == 1 and f.state().removed['container-a'] and f.state().registers['register-a'])
    f.session = { id = 'new-world/player', now = 0 }
    f.poll()
    assert(f.calls == 2 and next(f.state().removed) == nil,
        'A confirmed new session must not stay blocked by destroyed old containers')
    assert(f.state().registers['register-a'].attempts.take.count == 1)
end)

test('failed request dispatch retains its attempt even when the error restores AI', function()
    local f = fixture()
    f.fail_request = true
    f.poll()
    assert(f.calls == 1 and f.container.Evaluators:GetArrayNum() == 3)
    f.reload()
    f.fail_request, f.session.now = false, 1
    f.poll()
    assert(f.calls == 1 and f.state().registers['register-a'].attempts.take.count == 1)
end)

test('a broken handoff cannot enable an untracked AI mutation or native request', function()
    local f = fixture()
    f.fail_storage = true
    f.poll()
    assert(f.calls == 0 and f.writes == 0 and f.container.Evaluators:GetArrayNum() == 3)
    f.unload() -- Failing shared storage still must not access UObject or enqueue cleanup.
    f.fail_storage = false
    f.start(); f.poll()
    assert(f.calls == 1 and f.container.Evaluators:GetArrayNum() == 2)
end)

test('notification delivery immediately after reload first performs AI recovery', function()
    local f = fixture()
    f.poll(); f.reload()
    f.session.now = 0.25
    f.notify({ get = function() return { id = 'register-a' } end })
    f.flush()
    assert(f.calls == 1 and f.writes == 3)
    assert(f.state().registers['register-a'].attempts.take.next_at == 3)
end)

print(string.format('Reload lifecycle: %d tests passed', count))
