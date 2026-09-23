-- Original UE4SS adapter. Every method runs on the game thread.
local Game = {}
local TEMPLATE_FLAGS = 0x10 | 0x20

function Game.valid(object)
    return object ~= nil and object:IsValid()
end

local function same(a, b)
    return Game.valid(a) and Game.valid(b) and a:GetAddress() == b:GetAddress()
end

local function actor(object, world)
    return Game.valid(object) and not object:HasAnyFlags(TEMPLATE_FLAGS)
        and not object:IsActorBeingDestroyed()
        and (world == nil or same(object:GetWorld(), world))
end

local function identity(object)
    return object:GetFullName() .. '@' .. tostring(object:GetAddress())
end
Game.identity = identity

local function boolean(value, field)
    assert(type(value) == 'boolean', 'Unsupported checkout field: ' .. field)
    return value
end

local function required(path)
    local object = StaticFindObject(path)
    assert(Game.valid(object), 'Missing checkout API: ' .. path)
    return object
end

local function enum_value(path, suffix)
    local result
    required(path):ForEachName(function(name, value)
        local text = name:ToString()
        if text == suffix or text:sub(-#suffix - 2) == '::' .. suffix then
            result = value
            return true
        end
    end)
    assert(type(result) == 'number', 'Missing checkout enum value: ' .. suffix)
    return result
end

function Game.contract()
    required('/Script/BrasserieSimulator.NetPlayerController:Server_RequestInteraction')
    return {
        player = required('/Script/BrasserieSimulator.PlayerCharacter'),
        cash = required('/Script/BrasserieSimulator.Cash'),
        card = required('/Script/BrasserieSimulator.CreditCard'),
        billing_task = required('/Script/BrasserieSimulator.BillingStartTaskEvaluator'),
        action = enum_value('/Script/BrasserieSimulator.EInteractionActions', 'EIA_DefaultAction'),
        cash_method = enum_value('/Script/BrasserieSimulator.EPaymentMethods', 'EPM_Cash'),
        card_method = enum_value('/Script/BrasserieSimulator.EPaymentMethods', 'EPM_CreditCard'),
        gameplay = required('/Script/Engine.Default__GameplayStatics'),
    }
end

function Game.session(api)
    local result
    local reason = 'no-local-controller'
    for _, controller in ipairs(FindAllOf('NetPlayerController') or {}) do
        if actor(controller) and controller:IsLocalController() then
            reason = controller:HasAuthority() and 'host-pawn-unavailable' or 'client-not-host'
        end
        if actor(controller) and controller:IsLocalController() and controller:HasAuthority() then
            local world = controller:GetWorld()
            local player = controller.Pawn
            if Game.valid(world) and actor(player, world) and player:IsA(api.player)
                and same(player.Controller, controller) and player:HasAuthority() then
                assert(result == nil, 'Multiple local host players; checkout is suspended')
                local blocked = api.gameplay:IsGamePaused(controller) and 'game-paused' or nil
                result = {
                    controller = controller, player = player, world = world,
                    id = identity(world) .. '/' .. identity(player),
                    now = api.gameplay:GetTimeSeconds(controller),
                    blocked = blocked ~= nil, block_reason = blocked,
                }
            end
        end
    end
    return result, result and 'host' or reason
end

function Game.ai_contexts(session)
    local result = {}
    for _, subsystem in ipairs(FindAllOf('JobSubsystem') or {}) do
        if Game.valid(subsystem) and not subsystem:HasAnyFlags(TEMPLATE_FLAGS)
            and (not session or same(subsystem:GetWorld(), session.world)) then
            local containers, seen = {}, {}
            subsystem.EvaluatorsByJob:ForEach(function(_, value)
                local container = value:get()
                if Game.valid(container) then
                    local id = identity(container)
                    if not seen[id] then
                        seen[id] = true
                        containers[#containers + 1] = container
                    end
                end
            end)
            result[#result + 1] = { id = identity(subsystem), containers = containers,
                evaluators = subsystem.AllEvaluators }
        end
    end
    return result
end

function Game.registers(session)
    local result = {}
    local found = FindAllOf('CashRegister') or {}
    for _, register in ipairs(found) do
        if actor(register, session.world) and register:HasAuthority() then
            result[#result + 1] = register
        end
    end
    return result, #found
end

function Game.snapshot(api, session, register)
    if not actor(register, session.world) or not register:HasAuthority() then
        return nil, 'register-unavailable-or-not-authoritative'
    end
    local data = register.RepPaymentData
    local count = data.Dishes:GetArrayNum()
    assert(type(count) == 'number' and count >= 0, 'Invalid checkout bill array')
    local method
    if data.PaymentMethod == api.cash_method then method = 'cash' end
    if data.PaymentMethod == api.card_method then method = 'card' end
    local payment = register.RegisteredPaymentMethod
    local payment_id
    if Game.valid(payment) then
        if not actor(payment, session.world) or not payment:HasAuthority() then
            return nil, 'payment-unavailable-or-not-authoritative'
        end
        if not same(payment.CashRegister, register) then
            return nil, 'payment-register-mismatch payment=' .. identity(payment)
        end
        if (method == 'cash' and payment:IsA(api.cash))
            or (method == 'card' and payment:IsA(api.card)) then
            payment_id = identity(payment)
        else
            return nil, 'payment-type-mismatch raw_method=' .. tostring(data.PaymentMethod)
                .. ' payment=' .. identity(payment)
        end
    end
    return {
        id = identity(register), payment_id = payment_id, method = method,
        dish_count = count, raw_method = data.PaymentMethod,
        has_bill = count > 0 and method ~= nil,
        successful = boolean(data.bPaymentSuccessful, 'bPaymentSuccessful'),
        drawer_open = boolean(register.bIsDrawerOpen, 'bIsDrawerOpen'),
        moving = boolean(register.bIsMoving, 'bIsMoving'),
        being_handled = boolean(register.bBeingHandled, 'bBeingHandled'),
        card_in_machine = Game.valid(register.CreditCardInMachine),
        blocked = session.blocked, block_reason = session.block_reason,
    }
end

function Game.request(api, session, register, expected, action, on_dispatch)
    if not actor(session.controller, session.world) or not session.controller:HasAuthority()
        or not session.controller:IsLocalController()
        or not actor(session.player, session.world) or not session.player:HasAuthority()
        or not same(session.player.Controller, session.controller)
        or not same(session.controller.Pawn, session.player) then return false, 'host-changed' end
    if api.gameplay:IsGamePaused(session.controller) then return false, 'game-paused' end
    local current, reason = Game.snapshot(api, session, register)
    if not current then return false, reason end
    if current.id ~= expected.id then return false, 'register-changed' end
    if not current.has_bill then return false, 'bill-unavailable' end
    if current.moving then return false, 'drawer-moving' end
    if current.being_handled then return false, 'register-being-handled' end
    if current.card_in_machine then return false, 'card-processing' end
    local target
    if action == 'take' then
        if current.drawer_open or current.successful or not current.payment_id
            or current.payment_id ~= expected.payment_id then return false, 'payment-stage-changed' end
        target = register.RegisteredPaymentMethod
    elseif action == 'finish' then
        if not current.drawer_open or current.payment_id
            or (current.method == 'card' and not current.successful) then return false, 'drawer-stage-changed' end
        target = register
    else
        error('Unknown checkout action')
    end
    -- This RPC rebuilds the interactor from the controller's possessed pawn.
    -- Only request the normal default action; never construct a Mass entity,
    -- call FinishPayment directly, or write the game's payment state.
    if on_dispatch then on_dispatch(identity(target), api.action) end
    session.controller:Server_RequestInteraction(target, {
        bIsPlayer = true,
        Action = api.action,
        HitComponentName = FName('None'),
    })
    -- A void RPC returning only confirms dispatch, not acceptance or payment.
    return true
end

return Game
