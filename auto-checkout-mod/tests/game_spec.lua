local Game = require('game')
local count = 0
local function test(name, fn)
    fn()
    count = count + 1
    print('PASS ' .. name)
end

local function fixture()
    local serial = 0
    local function object(kind, world)
        serial = serial + 1
        local o = { kind = kind, world = world, address = serial, valid = true, authority = true,
            DistanceToInteract = 200, DistanceReference = 1, bCanInteractWhilePlacing = false, distance = 5000 }
        function o:IsValid() return self.valid end
        function o:HasAnyFlags() return self.template or false end
        function o:IsActorBeingDestroyed() return self.destroying or false end
        function o:GetWorld() return self.world end
        function o:GetAddress() return self.address end
        function o:GetFullName() return self.kind .. tostring(self.address) end
        function o:IsA(class) return self.kind == class end
        function o:HasAuthority() return self.authority end
        function o:GetDistanceTo(other)
            assert(other.kind == 'Player')
            return self.distance
        end
        return o
    end
    local world = object('World')
    local controller, player = object('Controller', world), object('Player', world)
    local register, cash = object('Register', world), object('Cash', world)
    local card = object('Card', world)
    local calls = {}
    controller.Pawn, player.Controller = player, controller
    controller.local_player = true
    controller.bIsLocalPauseRequested = false
    function controller:IsLocalController() return self.local_player end
    function controller:IsMultiplayerChatOpen() return self.chat or false end
    function controller:Server_RequestInteraction(target, context)
        calls[#calls + 1] = { target = target, context = context }
    end
    player.bIsInWidgetMode = false
    function player:IsPlayerFrozen() return self.frozen or false end
    function player:IsPlayerLocallyFrozen() return self.locally_frozen or false end
    function player:IsInteracting() return self.interacting or false end
    function player:IsInPlacingMode() return self.placing or false end
    function player:IsInteractionWheelOpen() return self.wheel or false end
    cash.CashRegister, card.CashRegister = register, register
    register.RegisteredPaymentMethod = cash
    register.bIsDrawerOpen, register.bIsMoving, register.bBeingHandled = false, false, false
    register.RepPaymentData = {
        Dishes = { GetArrayNum = function() return 1 end },
        PaymentMethod = 1, bPaymentSuccessful = false,
    }
    local api = { player = 'Player', cash = 'Cash', card = 'Card', action = 57,
        cash_method = 1, card_method = 2, actor_distance = 0, gameplay = {} }
    function api.gameplay:GetTimeSeconds() return 10 end
    function api.gameplay:IsGamePaused() return self.paused or false end
    FindAllOf = function(class)
        if class == 'NetPlayerController' then return { controller } end
        if class == 'CashRegister' then return { register } end
        error('Unexpected discovery')
    end
    FName = function(value) return value end
    return { api = api, world = world, controller = controller, player = player,
        register = register, cash = cash, card = card, calls = calls, object = object }
end

test('cash dispatch uses its associated payment object and the standard interaction RPC', function()
    local f = fixture()
    local s = Game.session(f.api)
    local snap = Game.snapshot(f.api, s, f.register)
    local observed = false
    local sent = Game.request(f.api, s, f.register, snap, 'take', function(target, action)
        assert(#f.calls == 0, 'request diagnostics must precede the RPC')
        assert(target == Game.identity(f.cash) and action == 57)
        observed = true
    end)
    assert(sent == true and observed)
    assert(#f.calls == 1 and f.calls[1].target == f.cash)
    assert(f.calls[1].context.Action == 57 and f.calls[1].context.bIsPlayer)
    assert(f.calls[1].context.Interactor == nil and f.calls[1].context.Entity == nil)
    assert(f.register.RegisteredPaymentMethod == f.cash)
end)

test('finished card dispatch targets register without mutating money or state', function()
    local f = fixture()
    f.register.RegisteredPaymentMethod = nil
    f.register.bIsDrawerOpen = true
    f.register.RepPaymentData.PaymentMethod = 2
    f.register.RepPaymentData.bPaymentSuccessful = true
    local s = Game.session(f.api)
    Game.request(f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'finish')
    assert(#f.calls == 1 and f.calls[1].target == f.register)
    assert(f.register.bIsDrawerOpen and f.register.RepPaymentData.bPaymentSuccessful)
end)

test('remote cash and card stages pass target reach checks and restore settings after each call', function()
    for _, method in ipairs({ 1, 2 }) do
        local f = fixture()
        local payment = method == 1 and f.cash or f.card
        f.register.RegisteredPaymentMethod = payment
        f.register.RepPaymentData.PaymentMethod = method
        f.player.placing, f.player.interacting = true, true
        local player_address = f.player.address
        function f.controller:Server_RequestInteraction(target, context)
            assert(self.Pawn == f.player and context.bIsPlayer and context.Action == 57)
            assert(target.DistanceReference == 0, 'distance must use the same actor reference as GetDistanceTo')
            assert(target.DistanceToInteract > target.distance, 'ordinary reach would reject this distant player')
            assert(target.bCanInteractWhilePlacing, 'placement must not silently reject automatic payment')
            f.calls[#f.calls + 1] = target
            if target == payment then
                f.register.RegisteredPaymentMethod = nil
                if method == 2 then f.register.CreditCardInMachine = f.card end
            else
                assert(target == f.register)
                f.register.RepPaymentData.Dishes.GetArrayNum = function() return 0 end
                f.register.bIsMoving = true
            end
        end
        local s = Game.session(f.api)
        assert(Game.request(f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take',
            function(_, _, context)
                assert(context:find('scope=target-call distance=5000.0 range_before=200.0 range_for_call=5100.0', 1, true))
            end))
        assert(payment.DistanceToInteract == 200 and payment.DistanceReference == 1)
        assert(not payment.bCanInteractWhilePlacing)
        if method == 2 then
            local sent, reason = Game.request(f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'finish')
            assert(not sent and reason == 'card-processing')
            f.register.CreditCardInMachine = nil
            f.register.RepPaymentData.bPaymentSuccessful = true
        end
        f.register.bIsDrawerOpen, f.register.distance = true, 30000
        assert(Game.request(f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'finish'))
        assert(#f.calls == 2 and not Game.snapshot(f.api, s, f.register).has_bill)
        assert(f.register.DistanceToInteract == 200 and f.register.DistanceReference == 1)
        assert(not f.register.bCanInteractWhilePlacing)
        assert(f.player.address == player_address and f.player.placing and f.player.interacting)
    end
end)

test('existing interaction allowances are preserved and a nearby target is not narrowed', function()
    local f = fixture()
    f.cash.DistanceToInteract, f.cash.DistanceReference = 1000, 0
    f.cash.distance, f.cash.bCanInteractWhilePlacing = 50, true
    local s = Game.session(f.api)
    assert(Game.request(f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take'))
    assert(f.cash.DistanceToInteract == 1000 and f.cash.DistanceReference == 0 and f.cash.bCanInteractWhilePlacing)
end)

test('RPC and diagnostic exceptions restore every surviving target setting', function()
    for _, source in ipairs({ 'rpc', 'observer' }) do
        local f = fixture()
        if source == 'rpc' then
            f.controller.Server_RequestInteraction = function() error('injected RPC error') end
        end
        local s = Game.session(f.api)
        local ok, err = pcall(Game.request, f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take',
            source == 'observer' and function() error('injected observer error') end or nil)
        assert(not ok and tostring(err):find('injected', 1, true))
        assert(tostring(err):find('stack traceback', 1, true))
        assert(f.cash.DistanceToInteract == 200 and f.cash.DistanceReference == 1)
        assert(not f.cash.bCanInteractWhilePlacing)
    end
end)

test('a preparation write that mutates then throws is rolled back before any RPC', function()
    local f = fixture()
    local range, failed = f.cash.DistanceToInteract, false
    f.cash.DistanceToInteract = nil
    setmetatable(f.cash, {
        __index = function(_, key) if key == 'DistanceToInteract' then return range end end,
        __newindex = function(target, key, value)
            if key ~= 'DistanceToInteract' then rawset(target, key, value); return end
            range = value
            if not failed then failed = true; error('injected preparation failure') end
        end,
    })
    local s = Game.session(f.api)
    local ok = pcall(Game.request, f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take')
    assert(not ok and #f.calls == 0 and range == 200 and f.cash.DistanceReference == 1)
    assert(not f.cash.bCanInteractWhilePlacing)
end)

test('restoration failure reports the affected field and still restores other settings', function()
    local f = fixture()
    local range = f.cash.DistanceToInteract
    f.cash.DistanceToInteract = nil
    setmetatable(f.cash, {
        __index = function(_, key) if key == 'DistanceToInteract' then return range end end,
        __newindex = function(target, key, value)
            if key ~= 'DistanceToInteract' then rawset(target, key, value); return end
            if value == 200 then error('injected restore failure') end
            range = value
        end,
    })
    local s = Game.session(f.api)
    local ok, err = pcall(Game.request, f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take')
    assert(not ok and #f.calls == 1 and tostring(err):find('reload the world', 1, true))
    assert(tostring(err):find('DistanceToInteract', 1, true))
    assert(f.cash.DistanceReference == 1 and not f.cash.bCanInteractWhilePlacing)
end)

test('payment destruction during dispatch never writes back into a disappearing actor', function()
    for _, invalid in ipairs({ true, false }) do
        local f = fixture()
        function f.controller:Server_RequestInteraction(target)
            f.calls[#f.calls + 1] = target
            target.destroying, target.valid = true, not invalid
            target.DistanceToInteract, target.DistanceReference, target.bCanInteractWhilePlacing = nil, nil, nil
            setmetatable(target, { __newindex = function() error('must not restore a destroyed payment') end })
        end
        local s = Game.session(f.api)
        assert(Game.request(f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take') and #f.calls == 1)
    end
end)

test('unusable target distances and field types fail without dispatch or partial mutation', function()
    for _, value in ipairs({ -1, math.huge, 0/0, 'unknown' }) do
        local f = fixture()
        f.cash.distance = value
        local s = Game.session(f.api)
        assert(not pcall(Game.request, f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take'))
        assert(#f.calls == 0 and f.cash.DistanceReference == 1 and f.cash.DistanceToInteract == 200)
    end
    local f = fixture()
    f.cash.bCanInteractWhilePlacing = 0
    local s = Game.session(f.api)
    assert(not pcall(Game.request, f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take'))
    assert(#f.calls == 0 and f.cash.DistanceReference == 1 and f.cash.DistanceToInteract == 200)
end)

test('clients, remote controllers and unpossessed pawns never run checkout', function()
    local f = fixture()
    f.controller.authority = false
    assert(Game.session(f.api) == nil)
    f.controller.authority, f.controller.local_player = true, false
    assert(Game.session(f.api) == nil)
    f.controller.local_player = true
    f.player.Controller = nil
    assert(Game.session(f.api) == nil)
end)

test('other player actions do not block checkout or call the broad interaction getter', function()
    for _, field in ipairs({ 'bIsInWidgetMode', 'frozen', 'locally_frozen', 'interacting', 'placing', 'wheel' }) do
        local f = fixture()
        f.player[field] = true
        f.player.IsInteracting = function() error('must not query broad player interaction state') end
        local s = Game.session(f.api)
        assert(not s.blocked, field)
        assert(Game.request(f.api, s, f.register, Game.snapshot(f.api, s, f.register), 'take'))
        assert(#f.calls == 1, field)
    end
    local f = fixture()
    f.player.CarriedObject = f.cash
    assert(not Game.session(f.api).blocked)
    f.player.CarriedObject, f.controller.chat = nil, true
    assert(not Game.session(f.api).blocked)
    f.controller.chat, f.api.gameplay.paused = false, true
    assert(Game.session(f.api).blocked)
    f.api.gameplay.paused, f.controller.bIsLocalPauseRequested = false, true
    assert(not Game.session(f.api).blocked)
end)

test('stale worlds, templates, clients and destroyed registers are excluded', function()
    for _, field in ipairs({ 'template', 'destroying' }) do
        local f = fixture()
        f.register[field] = true
        assert(#Game.registers(Game.session(f.api)) == 0)
    end
    local f = fixture()
    f.register.world = f.object('OtherWorld')
    assert(#Game.registers(Game.session(f.api)) == 0)
    f.register.world, f.register.authority = f.world, false
    assert(#Game.registers(Game.session(f.api)) == 0)
end)

test('mismatched register and payment kind never form a valid checkout', function()
    local f = fixture()
    local s = Game.session(f.api)
    f.cash.CashRegister = f.object('Register', f.world)
    assert(Game.snapshot(f.api, s, f.register) == nil)
    f.cash.CashRegister = f.register
    f.register.RepPaymentData.PaymentMethod = 2
    assert(Game.snapshot(f.api, s, f.register) == nil)
end)

test('dispatch rechecks employee claims, animation, terminal, and changed payment', function()
    for _, field in ipairs({ 'bBeingHandled', 'bIsMoving', 'bIsDrawerOpen' }) do
        local f = fixture()
        local s = Game.session(f.api)
        local snap = Game.snapshot(f.api, s, f.register)
        f.register[field] = true
        Game.request(f.api, s, f.register, snap, 'take')
        assert(#f.calls == 0, field)
    end
    local f = fixture()
    local s = Game.session(f.api)
    local snap = Game.snapshot(f.api, s, f.register)
    f.register.CreditCardInMachine = f.card
    Game.request(f.api, s, f.register, snap, 'take')
    assert(#f.calls == 0)
    f.register.CreditCardInMachine = nil
    f.cash.address = 100
    Game.request(f.api, s, f.register, snap, 'take')
    assert(#f.calls == 0)
end)

test('dispatch rechecks a paused game and a changed possessed pawn', function()
    local f = fixture()
    local s = Game.session(f.api)
    local snap = Game.snapshot(f.api, s, f.register)
    f.api.gameplay.paused = true
    Game.request(f.api, s, f.register, snap, 'take')
    assert(#f.calls == 0)
    f.api.gameplay.paused = false
    f.controller.Pawn = f.object('Player', f.world)
    Game.request(f.api, s, f.register, snap, 'take')
    assert(#f.calls == 0)
end)

test('unexpected reflected types fail before any action', function()
    local f = fixture()
    f.register.bIsDrawerOpen = 1
    assert(not pcall(function() Game.snapshot(f.api, Game.session(f.api), f.register) end))
    assert(#f.calls == 0)
end)

test('waiting reasons distinguish guest, missing pawn and game pause', function()
    local f = fixture()
    f.controller.authority = false
    local s, reason = Game.session(f.api)
    assert(s == nil and reason == 'client-not-host')
    f.controller.authority, f.controller.Pawn = true, nil
    s, reason = Game.session(f.api)
    assert(s == nil and reason == 'host-pawn-unavailable')
    f.controller.Pawn, f.player.CarriedObject = f.player, f.cash
    s = Game.session(f.api)
    assert(s.block_reason == nil)
    f.api.gameplay.paused = true
    assert(Game.session(f.api).block_reason == 'game-paused')
end)

test('invalid payment diagnostics include the raw method and target identity', function()
    local f = fixture()
    local s = Game.session(f.api)
    f.register.RepPaymentData.PaymentMethod = 99
    local snapshot, reason = Game.snapshot(f.api, s, f.register)
    assert(snapshot == nil and reason:find('raw_method=99', 1, true))
    assert(reason:find(Game.identity(f.cash), 1, true))
    f.register.RegisteredPaymentMethod = nil
    snapshot = Game.snapshot(f.api, s, f.register)
    assert(snapshot.raw_method == 99 and snapshot.dish_count == 1 and not snapshot.has_bill)
end)

test('skipped actions report a reason and never invoke the dispatch observer', function()
    local f = fixture()
    local s = Game.session(f.api)
    local snap = Game.snapshot(f.api, s, f.register)
    f.register.bBeingHandled = true
    local sent, reason = Game.request(f.api, s, f.register, snap, 'take', function()
        error('must not report an unsent request')
    end)
    assert(sent == false and reason == 'register-being-handled' and #f.calls == 0)
end)

test('manual payment invalidates a pending take and the next scan can finish cash or card', function()
    for _, method in ipairs({ 1, 2 }) do
        local f = fixture()
        f.register.RepPaymentData.PaymentMethod = method
        f.register.RegisteredPaymentMethod = method == 1 and f.cash or f.card
        local s = Game.session(f.api)
        local pending = Game.snapshot(f.api, s, f.register)
        f.register.RegisteredPaymentMethod = nil
        f.register.bIsDrawerOpen = true
        f.register.RepPaymentData.bPaymentSuccessful = true
        local sent, reason = Game.request(f.api, s, f.register, pending, 'take')
        assert(not sent and reason == 'payment-stage-changed' and #f.calls == 0)
        local current = Game.snapshot(f.api, s, f.register)
        assert(Game.request(f.api, s, f.register, current, 'finish') and #f.calls == 1)
        assert(f.calls[1].target == f.register)
    end
end)

test('manual drawer completion and destroyed objects abort only the pending request', function()
    local f = fixture()
    f.register.RegisteredPaymentMethod, f.register.bIsDrawerOpen = nil, true
    local s = Game.session(f.api)
    local pending = Game.snapshot(f.api, s, f.register)
    f.register.bIsDrawerOpen = false
    local sent, reason = Game.request(f.api, s, f.register, pending, 'finish')
    assert(not sent and reason == 'drawer-stage-changed')
    f.register.RepPaymentData.Dishes.GetArrayNum = function() return 0 end
    sent, reason = Game.request(f.api, s, f.register, pending, 'finish')
    assert(not sent and reason == 'bill-unavailable')
    f.register.destroying = true
    sent, reason = Game.request(f.api, s, f.register, pending, 'finish')
    assert(not sent and reason == 'register-unavailable-or-not-authoritative' and #f.calls == 0)
end)

test('an invalid payment target skips dispatch without calling the missing actor', function()
    local f = fixture()
    local s = Game.session(f.api)
    local pending = Game.snapshot(f.api, s, f.register)
    f.cash.valid = false
    local sent, reason = Game.request(f.api, s, f.register, pending, 'take')
    assert(not sent and reason == 'payment-stage-changed' and #f.calls == 0)
end)

test('AI discovery selects the current world and deduplicates shared role containers', function()
    local f = fixture()
    local subsystem, old = f.object('JobSubsystem', f.world), f.object('JobSubsystem', f.object('OtherWorld'))
    local template = f.object('JobSubsystem', f.world)
    template.template = true
    local container = f.object('TaskEvaluatorContainer', f.world)
    subsystem.EvaluatorsByJob = { ForEach = function(_, fn)
        fn(nil, { get = function() return container end })
        fn(nil, { get = function() return container end })
    end }
    old.EvaluatorsByJob = { ForEach = function() end }
    local find = FindAllOf
    FindAllOf = function(class)
        if class == 'JobSubsystem' then return { subsystem, old, template } end
        return find(class)
    end
    local contexts = Game.ai_contexts(Game.session(f.api))
    assert(#contexts == 1 and #contexts[1].containers == 1 and contexts[1].containers[1] == container)
    assert(#Game.ai_contexts() == 2, 'restore can rediscover surviving old-world contexts')
end)

print(string.format('Game adapter: %d tests passed', count))
