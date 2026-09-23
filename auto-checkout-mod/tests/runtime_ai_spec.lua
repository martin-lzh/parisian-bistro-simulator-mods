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
local function array(values)
    function values:GetArrayNum() return #self end
    function values:Empty() for index = #self, 1, -1 do self[index] = nil end end
    return values
end
local function fixture()
    local f = { logs = {}, calls = 0 }
    local billing = { id = 'billing', IsA = function(_, class) return class == 'billing-class' end }
    local drink = { id = 'drink', IsA = function() return false end }
    f.contexts = {}
    for _, world in ipairs({ 'a', 'b' }) do
        f.contexts[world] = { id = 'job-' .. world,
            evaluators = array({ billing, drink }),
            containers = { { id = 'role-' .. world, Evaluators = array({ billing, drink }) } } }
    end
    f.session = { id = 'a', now = 0 }
    local snapshot = { id = 'register', payment_id = 'cash', method = 'cash', has_bill = true }
    package.loaded.game = {
        valid = function(o) return o ~= nil end,
        identity = function(o) return o.id end,
        contract = function() return { billing_task = 'billing-class' } end,
        session = function()
            if f.fail_session then error('injected session failure') end
            return f.session, 'client-not-host'
        end,
        ai_contexts = function(session)
            if session then return { f.contexts[session.id] } end
            return { f.contexts.a, f.contexts.b }
        end,
        registers = function() return { { id = 'register' } }, 1 end,
        snapshot = function() return snapshot end,
        request = function(_, session, _, _, _, on_dispatch)
            assert(f.contexts[session.id].containers[1].Evaluators:GetArrayNum() == 1,
                'AI task policy must be applied before any automatic request')
            on_dispatch('cash', 57)
            f.calls = f.calls + 1
            if f.fail_request then error('injected checkout failure') end
            return true
        end,
    }
    RegisterHook = function() return 1, 2 end
    LoopInGameThreadWithDelay = function(_, fn) f.poll = fn end
    print = function(message) f.logs[#f.logs + 1] = message end
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    function f.size(world) return #f.contexts[world].containers[1].Evaluators end
    function f.contains(text) return table.concat(f.logs, '\n'):find(text, 1, true) end
    return f
end

test('runtime applies AI policy only as host, restores on departure and handles a new world', function()
    local f = fixture()
    local host = f.session
    f.session = nil
    f.poll()
    assert(f.size('a') == 2 and f.size('b') == 2 and f.calls == 0)
    f.session = host
    f.poll()
    assert(f.size('a') == 1 and f.size('b') == 2 and f.calls == 1)
    f.session = { id = 'b', now = 0 }
    f.poll()
    assert(f.size('a') == 2 and f.size('b') == 1 and f.calls == 2)
    f.session = nil
    f.poll()
    assert(f.size('a') == 2 and f.size('b') == 2)
    assert(f.contains('policy=exclude-counter-billing') and f.contains('AI restored_containers=1'))
end)

test('checkout exceptions restore AI billing and stop future requests', function()
    local f = fixture()
    f.fail_request = true
    f.poll()
    assert(f.size('a') == 2 and f.calls == 1)
    assert(f.contains('AI restored_containers=1') and f.contains('stage=request-take'))
    f.poll()
    assert(f.size('a') == 2 and f.calls == 1)
end)

test('a later session read error restores a previously suppressed task', function()
    local f = fixture()
    f.poll()
    assert(f.size('a') == 1)
    f.fail_session = true
    f.poll()
    assert(f.size('a') == 2 and f.contains('stage=session'))
end)

print(string.format('Runtime AI lifecycle: %d tests passed', count))
