local Checkout = require('checkout')
local count = 0
local function test(name, fn)
    fn()
    count = count + 1
    print('PASS ' .. name)
end
local function bill(changes)
    local s = {
        id = 'register-a', payment_id = 'payment-a', method = 'cash', has_bill = true,
        drawer_open = false, moving = false, successful = false,
        being_handled = false, card_in_machine = false, blocked = false,
    }
    for k, v in pairs(changes or {}) do s[k] = v end
    return s
end
local function harness()
    local c, calls, warnings = Checkout.new(), {}, {}
    local function step(s, time)
        c:step(s, time or 0, function(action) calls[#calls + 1] = action; return true end,
            function(text) warnings[#warnings + 1] = text end)
    end
    return c, calls, warnings, step
end

test('cash: receive money, wait for animation, close drawer, then next customer', function()
    local _, calls, _, step = harness()
    local s = bill()
    step(s)
    assert(calls[1] == 'take')
    s.payment_id = nil
    s.moving, s.drawer_open = true, true
    step(s, 1)
    assert(#calls == 1)
    s.moving = false
    step(s, 2)
    assert(calls[2] == 'finish')
    s.has_bill, s.drawer_open = false, false
    step(s, 3)
    s = bill({ payment_id = 'payment-b' })
    step(s, 4)
    assert(calls[3] == 'take')
end)

test('card: never finish while terminal is processing', function()
    local _, calls, _, step = harness()
    local s = bill({ method = 'card' })
    step(s)
    s.card_in_machine = true
    for t = 1, 10 do step(s, t) end
    assert(#calls == 1)
    s.payment_id = nil
    s.drawer_open, s.card_in_machine = true, false
    step(s, 11)
    assert(#calls == 1)
    s.successful = true
    step(s, 12)
    assert(calls[2] == 'finish')
end)

test('employee, player activity and drawer motion each block both actions', function()
    for _, field in ipairs({ 'being_handled', 'blocked', 'moving', 'card_in_machine' }) do
        local _, calls, _, step = harness()
        step(bill({ [field] = true }))
        local s = bill({ [field] = true, drawer_open = true })
        s.payment_id = nil
        step(s, 5)
        assert(#calls == 0, field)
    end
end)

test('empty bill, successful payment and incomplete drawer state never take money', function()
    local _, calls, _, step = harness()
    step(bill({ has_bill = false }))
    step(bill({ successful = true }), 5)
    step(bill({ drawer_open = true }), 10)
    assert(#calls == 0)
end)

test('unchanged take and finish requests have a cooldown and finite retry budget', function()
    for _, action in ipairs({ 'take', 'finish' }) do
        local _, calls, warnings, step = harness()
        local s = bill({ drawer_open = action == 'finish' })
        if action == 'finish' then s.payment_id = nil end
        for i = 0, 80 do step(s, i / 4) end
        assert(#calls == 3 and calls[1] == action)
        assert(#warnings == 1)
    end
end)

test('new payment object resets retry budget even without an observed idle frame', function()
    local _, calls, _, step = harness()
    local s = bill()
    for t = 0, 12, 3 do step(s, t) end
    assert(#calls == 3)
    s.payment_id = 'payment-b'
    step(s, 13)
    assert(#calls == 4)
end)

test('manual first click and a mod loaded with an open drawer can complete checkout', function()
    local _, calls, _, step = harness()
    local s = bill({ drawer_open = true })
    s.payment_id = nil
    step(s)
    assert(calls[1] == 'finish')
end)

test('multiple registers progress independently', function()
    local _, calls, _, step = harness()
    step(bill())
    step(bill({ id = 'rooftop', payment_id = 'payment-b' }))
    assert(#calls == 2)
end)

test('world reset and pruning drop obsolete transactions', function()
    local c, _, _, step = harness()
    step(bill())
    c:prune({})
    assert(next(c.registers) == nil)
    step(bill())
    c:reset()
    assert(next(c.registers) == nil)
end)

test('an exception during dispatch still consumes the attempt', function()
    local c = Checkout.new()
    local ok = pcall(function()
        c:step(bill(), 0, function() error('bridge failed') end, function() end)
    end)
    assert(not ok)
    c:step(bill(), 1, function() error('must not retry yet') end, function() end)
    assert(c.registers['register-a'].attempts.take.count == 1)
end)

test('skipped dispatches wait but do not consume the three-request budget', function()
    local c, sent, warnings = Checkout.new(), 0, 0
    local s = bill()
    local function warn() warnings = warnings + 1 end
    for t = 0, 9, 3 do c:step(s, t, function() return false end, warn) end
    assert(c.registers[s.id].attempts.take.count == 0)
    c:step(s, 10, function() error('skip must retain cooldown') end, warn)
    for t = 12, 24, 3 do
        c:step(s, t, function() sent = sent + 1; return true end, warn)
    end
    assert(sent == 3 and warnings == 1)
end)

test('diagnostic phases identify blocked, missing, and incomplete payment states', function()
    assert(Checkout.phase(bill({ blocked = true, block_reason = 'player-widget' })) == 'wait-player-widget')
    assert(Checkout.phase(bill({ has_bill = false })) == 'wait-bill')
    assert(Checkout.phase(bill({ drawer_open = true })) == 'wait-payment-removal')
    local s = bill({ drawer_open = true, method = 'card' })
    s.payment_id = nil
    assert(Checkout.phase(s) == 'wait-card-success')
    s.drawer_open = false
    assert(Checkout.phase(s) == 'wait-payment-or-drawer')
end)

print(string.format('Checkout: %d tests passed', count))
