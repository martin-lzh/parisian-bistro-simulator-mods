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
        local o = { kind = kind, world = world, address = serial, valid = true, authority = true }
        function o:IsValid() return self.valid end
        function o:HasAnyFlags() return self.template or false end
        function o:IsActorBeingDestroyed() return self.destroying or false end
        function o:GetWorld() return self.world end
        function o:GetAddress() return self.address end
        function o:GetFullName() return self.kind .. tostring(self.address) end
        function o:IsA(class) return self.kind == class end
        function o:HasAuthority() return self.authority end
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
        cash_method = 1, card_method = 2, gameplay = {} }
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
    Game.request(f.api, s, f.register, snap, 'take')
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

test('menu, pause, chat, carried items and active player interactions suspend checkout', function()
    for _, field in ipairs({ 'bIsInWidgetMode', 'frozen', 'locally_frozen', 'interacting', 'placing', 'wheel' }) do
        local f = fixture()
        f.player[field] = true
        assert(Game.session(f.api).blocked, field)
    end
    local f = fixture()
    f.player.CarriedObject = f.cash
    assert(Game.session(f.api).blocked)
    f.player.CarriedObject, f.controller.chat = nil, true
    assert(Game.session(f.api).blocked)
    f.controller.chat, f.api.gameplay.paused = false, true
    assert(Game.session(f.api).blocked)
    f.api.gameplay.paused, f.controller.bIsLocalPauseRequested = false, true
    assert(Game.session(f.api).blocked)
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

print(string.format('Game adapter: %d tests passed', count))
