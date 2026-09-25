-- Original reflected adapter. All access is confined to the game thread.
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

local function required(path)
    local value = StaticFindObject(path)
    assert(Game.valid(value), 'Missing pickup API: ' .. path)
    return value
end

function Game.contract()
    required('/Script/BrasserieSimulator.NetPlayerController:Server_RequestInteraction')
    required('/Script/EnhancedInput.EnhancedInputSubsystemInterface:QueryKeysMappedToAction')
    required('/Script/Engine.KismetMathLibrary:Less_DateTimeDateTime')
    required('/Script/Engine.SubsystemBlueprintLibrary:GetWorldSubsystem')
    required('/Script/BrasserieSimulator.WorldGameInstanceSubsystem:GetKitchenManager')
    local action
    required('/Script/BrasserieSimulator.EInteractionActions'):ForEachName(function(name, value)
        if name:ToString():match('EIA_DefaultAction$') then action = value end
    end)
    assert(type(action) == 'number', 'Missing default interaction action')
    return {
        player = required('/Script/BrasserieSimulator.PlayerCharacter'),
        dish = required('/Script/BrasserieSimulator.Dish'),
        drink = required('/Script/BrasserieSimulator.Drink'),
        -- Older builds have no area actor; direct item targeting still works.
        dish_output = StaticFindObject('/Script/BrasserieSimulator.DishOutputArea'),
        kitchen = required('/Script/BrasserieSimulator.KitchenManager'),
        world_subsystem = required('/Script/BrasserieSimulator.WorldGameInstanceSubsystem'),
        enhanced = required('/Script/EnhancedInput.EnhancedInputLocalPlayerSubsystem'),
        input = required('/Script/EnhancedInput.Default__EnhancedInputLibrary'),
        subsystems = required('/Script/Engine.Default__SubsystemBlueprintLibrary'),
        gameplay = required('/Script/Engine.Default__GameplayStatics'),
        math = required('/Script/Engine.Default__KismetMathLibrary'),
        action = action,
    }
end

function Game.session(api, expected_player)
    local result
    for _, controller in ipairs(FindAllOf('NetPlayerController') or {}) do
        if actor(controller) and controller:IsLocalController() then
            local world, player = controller:GetWorld(), controller.Pawn
            if Game.valid(world) and actor(player, world) and player:IsA(api.player)
                and same(player.Controller, controller)
                and (expected_player == nil or same(player, expected_player)) then
                if result then return nil end -- Ambiguous split-screen ownership.
                if api.gameplay:IsGamePaused(controller) or player.bIsInWidgetMode
                    or player:IsPlayerFrozen() or player:IsPlayerLocallyFrozen()
                    or player:IsInPlacingMode() or player:IsInteractionWheelOpen()
                    or not player:IsCarryingTray() or not actor(player.Tray, world)
                    or controller:IsMultiplayerChatOpen() then return nil end
                result = { controller = controller, player = player, world = world, tray = player.Tray,
                    id = identity(world) .. '/' .. identity(player) .. '/' .. identity(player.Tray),
                    now = api.gameplay:GetTimeSeconds(controller) }
            end
        end
    end
    return result
end

function Game.held(api, session)
    local subsystem = api.subsystems:GetLocalPlayerSubSystemFromPlayerController(
        session.controller, api.enhanced)
    if not Game.valid(subsystem) or not Game.valid(session.player.InteractionAction) then return false end
    -- Query active mappings, including remaps and gamepad bindings. Do not infer
    -- held state from the one-shot Enhanced Input trigger or a remembered event.
    for _, key in ipairs(subsystem:QueryKeysMappedToAction(session.player.InteractionAction)) do
        if session.controller:IsInputKeyDown(key:get()) then return true end
    end
    return false
end

local function members(source, kind, world)
    local result = {}
    local array = kind == 'food' and source.DishesSpawnQueue or source.OutputSlots.Items
    array:ForEach(function(_, value)
        local item = value:get()
        local dish = kind == 'food' and item or item.Drink
        if actor(dish, world) then result[identity(dish)] = dish end
    end)
    return result
end

local function tray_state(session, kind)
    local carried, space = {}, false
    session.tray.Slots:ForEach(function(_, value)
        local slot = value:get()
        if Game.valid(slot.Dish) then carried[identity(slot.Dish)] = true
        elseif kind == 'drink' or slot.bReservedForDrinkOnly == false then space = true end
    end)
    return carried, space
end

local function eligible(api, session, scope, dish, carried)
    if carried[identity(dish)] or dish.bIsDirty ~= false or dish.bIsBeingConsumed ~= false
        or dish.bBeingPicked ~= false or Game.valid(dish.table) then return false end
    local parent = dish:GetAttachParentActor()
    if Game.valid(parent) and not same(parent, scope.source) then return false end
    if scope.kind == 'drink' and (not dish:IsA(api.drink) or not dish:IsFull()) then return false end
    if scope.kind == 'food' and not dish:IsA(api.dish) then return false end
    if dish:GetAssignedFloor() ~= session.player:GetCurrentFloor() then return false end
    local range, distance = dish.DistanceToInteract, dish:GetDistanceTo(session.player)
    if type(range) ~= 'number' or type(distance) ~= 'number'
        or range < 0 or distance < 0 or not (distance <= range) then return false end
    -- A zero/uninitialized native timestamp is not evidence of an old product.
    return api.math:GetYear(dish.CreationTime) > 1
end

local function aimed_scope(api, session)
    local hit = session.player.CurrentHit
    if hit.bBlockingHit ~= true then return nil end
    local component = hit.Component:get()
    if not Game.valid(component) then return nil end
    local target = component:GetOwner()
    if not actor(target, session.world) then return nil end
    if Game.valid(api.dish_output) and target:IsA(api.dish_output) then
        -- Only the native pickup box identifies the kitchen pass. Other mesh
        -- hits and nearby furniture must not start the gesture.
        if not same(component, target.PickupInteractionBox) then return nil end
        local subsystem = api.subsystems:GetWorldSubsystem(target, api.world_subsystem)
        if not Game.valid(subsystem) then return nil end
        local source = subsystem:GetKitchenManager()
        if not actor(source, session.world) or not source:IsA(api.kitchen) then return nil end
        local scope = { id = identity(source), source = source, kind = 'food' }
        -- Use the same per-item readiness, reach, floor and capacity checks as
        -- direct aiming. Never send the area-level batch pickup interaction.
        if Game.snapshot(api, session, scope).oldest then return scope end
        return nil
    end
    -- Direct item targeting also identifies its source, including drink areas.
    local kind, sources
    if target:IsA(api.drink) then kind, sources = 'drink', FindAllOf('DrinkOutputArea')
    elseif target:IsA(api.dish) then kind, sources = 'food', FindAllOf('KitchenManager')
    else return nil end
    local found
    for _, source in ipairs(sources or {}) do
        if actor(source, session.world) and members(source, kind, session.world)[identity(target)] then
            if found then return nil end
            found = { id = identity(source), source = source, kind = kind }
        end
    end
    local carried = tray_state(session, kind)
    if found and eligible(api, session, found, target, carried) then return found end
end

function Game.lock(session, scope)
    local rotation = session.controller:GetControlRotation()
    local position = session.player:K2_GetActorLocation()
    -- Persist only scalar values; sources are resolved again every tick.
    return { session = session.id, id = scope.id, kind = scope.kind,
        pitch = rotation.Pitch, yaw = rotation.Yaw,
        x = position.X, y = position.Y, z = position.Z }
end

local function angle(a, b) return math.abs((a - b + 180) % 360 - 180) end

function Game.scope(api, session, lock)
    if not lock then return aimed_scope(api, session) end
    if lock.session ~= session.id then return nil end
    local aimed = aimed_scope(api, session)
    if aimed then
        -- A different eligible station always cancels, even if very close.
        if aimed.id ~= lock.id then return nil end
        return aimed
    end
    -- Taking the aimed item can leave a busy/carried item, the countertop or
    -- no hit under the crosshair. Allow that gap while the view stays near
    -- the last aimed item, without extending reach or following the player.
    local rotation = session.controller:GetControlRotation()
    local position = session.player:K2_GetActorLocation()
    if angle(rotation.Pitch, lock.pitch) > 10 or angle(rotation.Yaw, lock.yaw) > 10
        or (position.X - lock.x)^2 + (position.Y - lock.y)^2 + (position.Z - lock.z)^2 > 30^2 then
        return nil
    end
    local class = lock.kind == 'food' and 'KitchenManager' or 'DrinkOutputArea'
    for _, source in ipairs(FindAllOf(class) or {}) do
        if actor(source, session.world) and identity(source) == lock.id then
            return { id = lock.id, kind = lock.kind, source = source }
        end
    end
end

function Game.snapshot(api, session, scope)
    local present = members(scope.source, scope.kind, session.world)
    local carried, space = tray_state(session, scope.kind)
    local oldest
    if space then
        for _, dish in pairs(present) do
            if eligible(api, session, scope, dish, carried) then
                if oldest == nil or api.math:Less_DateTimeDateTime(dish.CreationTime, oldest.CreationTime)
                    or (not api.math:Less_DateTimeDateTime(oldest.CreationTime, dish.CreationTime)
                        and identity(dish) < identity(oldest)) then oldest = dish end
            end
        end
    end
    return { session = session.id, scope = scope.id, now = session.now,
        present = present, carried = carried, has_space = space, oldest = oldest and identity(oldest) }
end

function Game.request(api, expected, scope_id, candidate, lock)
    -- Re-read possession, input, aim, membership, capacity and age immediately
    -- before dispatch. No range edits, tray writes, queue writes or direct grab.
    local session = Game.session(api)
    if not session or session.id ~= expected or not Game.held(api, session) then return false end
    local scope = Game.scope(api, session, lock)
    if not scope or scope.id ~= scope_id then return false end
    local snapshot = Game.snapshot(api, session, scope)
    if snapshot.oldest ~= candidate then return false end
    session.controller:Server_RequestInteraction(snapshot.present[candidate], {
        bIsPlayer = true, Action = api.action, HitComponentName = FName('None'),
    })
    return true -- Dispatch only; the next snapshot must confirm progress.
end

return Game
