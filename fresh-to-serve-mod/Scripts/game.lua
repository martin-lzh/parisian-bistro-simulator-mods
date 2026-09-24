-- Original reflected API adapter. All access and mutations run on the game thread.
local Game = {}
local Remake = require('remake')
local TEMPLATE_FLAGS = 0x10 | 0x20

function Game.valid(object)
    return object ~= nil and object:IsValid()
end

local function same(a, b)
    return Game.valid(a) and Game.valid(b) and a:GetAddress() == b:GetAddress()
end

local function identity(object)
    return object:GetFullName() .. '@' .. tostring(object:GetAddress())
end

local function actor(object, world)
    return Game.valid(object) and not object:HasAnyFlags(TEMPLATE_FLAGS)
        and not object:IsActorBeingDestroyed() and object:HasAuthority()
        and (world == nil or same(object:GetWorld(), world))
end

local function boolean(value)
    assert(type(value) == 'boolean', 'Unsupported boolean field')
    return value
end

local function number(value)
    assert(Remake.finite(value), 'Unsupported numeric field')
    return value
end

local function guid(value)
    return table.concat({ tostring(number(value.A)), tostring(number(value.B)),
        tostring(number(value.C)), tostring(number(value.D)) }, ':')
end

local function required(path)
    local object = StaticFindObject(path)
    assert(Game.valid(object), 'Missing Fresh to Serve API: ' .. path)
    return object
end

local function enum(path, suffix)
    local result
    required('/Script/BrasserieSimulator.' .. path):ForEachName(function(name, value)
        local text = name:ToString()
        if text == suffix or text:sub(-#suffix - 2) == '::' .. suffix then
            result = value
            return true
        end
    end)
    return number(result)
end

function Game.contract()
    for _, path in ipairs({
        '/Script/Engine.Actor:K2_DestroyActor', '/Script/Engine.Actor:ForceNetUpdate',
        '/Script/BrasserieSimulator.GenericDish:GetDishQuality',
        '/Script/BrasserieSimulator.GenericDish:GetOrderedForTable',
        '/Script/BrasserieSimulator.CustomerSatisfactionSubsystem:GetSatisfactionFromDishQuality',
        '/Script/BrasserieSimulator.KitchenManager:TryOrderDish',
        '/Script/BrasserieSimulator.NetPlayerController:Server_RequestRemoveDishFromSpawnQueue',
        '/Script/BrasserieSimulator.DishGameInstanceSubsystem:GetDish',
        '/Script/BrasserieSimulator.table:GetCustomerWaitElapsedTime',
        '/Script/BrasserieSimulator.table:GetCustomerWaitTime',
        '/Script/BrasserieSimulator.table:IsCustomerOrderWaitActive',
        '/Script/BrasserieSimulator.table:OnRep_OrderNotifications',
    }) do required(path) end
    return {
        player = required('/Script/BrasserieSimulator.PlayerCharacter'),
        dish = required('/Script/BrasserieSimulator.Dish'),
        gameplay = required('/Script/Engine.Default__GameplayStatics'),
        math = required('/Script/Engine.Default__KismetMathLibrary'),
        quality = required('/Script/BrasserieSimulator.Default__CustomerSatisfactionSubsystem'),
        poor = enum('ECustomerSatisfaction', 'ECS_DishBadQuality'),
        awful = enum('ECustomerSatisfaction', 'ECS_DishReallyBadQuality'),
        pending = enum('EDishState', 'Pending'),
        preparing = enum('EDishState', 'Preparing'),
        none = enum('EDishes', 'EDH_Unknown'),
    }
end

function Game.session(api)
    local result
    for _, controller in ipairs(FindAllOf('NetPlayerController') or {}) do
        if actor(controller) and controller:IsLocalController() then
            local world, pawn = controller:GetWorld(), controller.Pawn
            if Game.valid(world) and actor(pawn, world) and pawn:IsA(api.player)
                and same(pawn.Controller, controller) then
                assert(not result, 'Multiple local host sessions')
                result = { world = world, player = pawn, controller = controller,
                    id = identity(world) .. '/' .. identity(pawn),
                    now = number(api.gameplay:GetTimeSeconds(controller)),
                    paused = boolean(api.gameplay:IsGamePaused(controller)) }
            end
        end
    end
    return result
end

local function array_values(array)
    local result = {}
    for index = 1, array:GetArrayNum() do
        local value = array[index]
        if value ~= nil then result[#result + 1] = value end
    end
    return result
end

local function contains(array, target)
    for _, value in ipairs(array_values(array)) do
        if same(value, target) then return true end
    end
    return false
end

local function poor(api, dish)
    local quality = number(dish:GetDishQuality())
    local state = api.quality:GetSatisfactionFromDishQuality(quality)
    return state == api.poor or state == api.awful
end

local function eligible(api, session, candidate)
    local dish, kitchen, holder = candidate.object, candidate.kitchen, candidate.holder
    if not actor(kitchen, session.world) or not actor(holder, session.world)
        or not actor(dish, session.world) or not dish:IsA(api.dish) then return false end
    if boolean(dish.bIsDirty) or boolean(dish.bIsBeingConsumed) or boolean(dish.bBeingPicked)
        or number(dish.Dish) == api.none or Game.valid(dish.table) then return false end
    local parent = dish:GetAttachParentActor()
    if Game.valid(parent) and not same(parent, holder) then return false end
    local linked = dish:GetOrderedForTable()
    if actor(linked, session.world) and boolean(linked.bTableHandledByPlayer) then return false end
    if candidate.slot then
        local slot = holder.ElevatorSlots[candidate.slot]
        if not boolean(slot.bDishesOnly) or not same(slot.Dish, dish) then return false end
    elseif not contains(kitchen.DishesSpawnQueue, dish) then
        return false
    end
    return poor(api, dish)
end

function Game.candidates(api, session)
    local result, seen = {}, {}
    local function add(dish, kitchen, holder, slot)
        if not actor(dish, session.world) then return end
        local id = identity(dish)
        if seen[id] then return end
        local candidate = { id = id, object = dish, kitchen = kitchen, holder = holder, slot = slot }
        if eligible(api, session, candidate) then
            seen[id] = true
            result[#result + 1] = candidate
        end
    end
    for _, kitchen in ipairs(FindAllOf('KitchenManager') or {}) do
        if actor(kitchen, session.world) then
            -- A delivered dish can still appear in the kitchen list. Resolve its
            -- elevator first so discarding also clears the slot and reservation.
            kitchen.DishElevators:ForEach(function(_, value)
                local elevator = value:get()
                if actor(elevator, session.world) then
                    for index = 1, elevator.ElevatorSlots:GetArrayNum() do
                        local slot = elevator.ElevatorSlots[index]
                        add(slot.Dish, kitchen, elevator, index)
                    end
                end
            end)
            for _, dish in ipairs(array_values(kitchen.DishesSpawnQueue)) do add(dish, kitchen, kitchen) end
        end
    end
    return result
end

local function waiting(session, linked, notification, dish_key)
    if not actor(linked, session.world) or not boolean(linked:IsTableOccupied())
        or number(linked.NumberOfCustomersSit) <= 0 or boolean(linked.bGroupCanBeCashedOut)
        or boolean(linked.bTableHandledByPlayer) then return false end
    local customer = notification.Customer
    if not actor(customer, session.world) or not contains(linked.RepCustomerActors, customer)
        or notification.Dish ~= dish_key then return false end
    local behavior = customer:GetCustomerBehaviorComponent()
    return Game.valid(behavior) and behavior.GroupId == linked.AssignedCustomerGroupId
        and behavior.WantedDish == dish_key and not boolean(behavior.bIsDishServed)
        and not Game.valid(behavior.DishInstance)
end

function Game.ticket(api, session, candidate, reserved)
    local dish = candidate.object
    local linked = dish:GetOrderedForTable()
    if not actor(linked, session.world) then return nil end
    -- A dish from a previous seating/course must never feed a new table occupant.
    local age = api.math:GetTotalSeconds(api.math:Subtract_DateTimeDateTime(dish.CreationTime, linked.CustomerOrderTime))
    if not Remake.finite(age) or age < 0 then return nil end
    local dish_key, group = number(dish.Dish), number(linked.AssignedCustomerGroupId)
    for _, notice in ipairs(array_values(linked.OrderNotifications)) do
        if waiting(session, linked, notice, dish_key) and boolean(notice.bDishOrdered) then
            local order = guid(notice.DishOrderId)
            if order ~= '0:0:0:0' then
                local key = identity(linked) .. '/' .. identity(notice.Customer) .. '/' .. order
                if not reserved[key] then
                    return { key = key, kitchen = identity(candidate.kitchen), table = identity(linked),
                        customer = identity(notice.Customer), group = group, order = order,
                        dish = dish_key, created_at = session.now }
                end
            end
        end
    end
end

local function taken_dishes(kitchen, linked)
    local result
    kitchen.TakenOutDishes:ForEach(function(key, value)
        if same(key:get(), linked) then result = value:get().Dishes end
    end)
    return result
end

function Game.discard(api, session, candidate)
    if not eligible(api, session, candidate) then return false end
    local dish = candidate.object
    local address, dish_key, linked = dish:GetAddress(), dish.Dish, dish:GetOrderedForTable()
    local taken_before = Game.valid(linked) and taken_dishes(candidate.kitchen, linked)
    local before = taken_before and array_values(taken_before) or {}
    -- Use normal pickup bookkeeping to release the fixed slot and wake chefs.
    -- This does not put the dish in the player's hands.
    session.controller:Server_RequestRemoveDishFromSpawnQueue(candidate.kitchen, dish)
    if candidate.slot then
        assert(not same(candidate.holder.ElevatorSlots[candidate.slot].Dish, dish),
            'Elevator release not confirmed')
    else
        assert(not contains(candidate.kitchen.DishesSpawnQueue, dish), 'Kitchen release not confirmed')
    end
    -- Pickup adds one temporary taken-out entry. Undo exactly that addition;
    -- never consume a reservation belonging to another identical meal.
    if Game.valid(linked) then
        local after = taken_dishes(candidate.kitchen, linked)
        assert(after and after:GetArrayNum() == #before + 1 and after[#before + 1] == dish_key,
            'Pickup bookkeeping changed unexpectedly')
        for index, value in ipairs(before) do assert(after[index] == value, 'Taken-out entries changed') end
        local function restore()
            after:Empty()
            for index, value in ipairs(before) do after[index] = value end
            assert(after:GetArrayNum() == #before, 'Taken-out entry cleanup failed')
            for index, value in ipairs(before) do assert(after[index] == value, 'Taken-out value mismatch') end
        end
        local ok, err = pcall(restore)
        if not ok then
            local recovered, recovery_error = pcall(restore)
            error('Taken-out write failed: ' .. tostring(err) .. '; restored=' .. tostring(recovered)
                .. (recovered and '' or '; ' .. tostring(recovery_error)))
        end
    end
    dish:K2_DestroyActor()
    assert(not Game.valid(dish) or dish:IsActorBeingDestroyed(), 'Dish destruction not confirmed')
    -- Clear any duplicate stale kitchen reference without shifting physical
    -- slot indices or changing the pass capacity.
    local slots = candidate.kitchen.DishesSpawnQueue
    for index = 1, slots:GetArrayNum() do
        local value = slots[index]
        if value ~= nil and value:GetAddress() == address then slots[index] = nil end
    end
    if candidate.slot then
        candidate.holder:ForceNetUpdate()
    end
    candidate.kitchen:ForceNetUpdate()
    return true
end

local function find_actor(class, id, world)
    for _, object in ipairs(FindAllOf(class) or {}) do
        if actor(object, world) and identity(object) == id then return object end
    end
end

local function inspect(api, session, ticket)
    local linked = find_actor('table', ticket.table, session.world)
    local kitchen = find_actor('KitchenManager', ticket.kitchen, session.world)
    local snapshot = { present = false }
    if not linked or linked.AssignedCustomerGroupId ~= ticket.group then return snapshot end
    local target, demand = nil, 0
    for _, notice in ipairs(array_values(linked.OrderNotifications)) do
        if waiting(session, linked, notice, ticket.dish) then
            demand = demand + 1
            if identity(notice.Customer) == ticket.customer and guid(notice.DishOrderId) == ticket.order then
                target = notice
            end
        end
    end
    if not target then return snapshot end
    snapshot.present = true
    if not kitchen then return snapshot end
    local catalog = kitchen.DishGameInstanceSubsystem
    local subsystem = kitchen.WorldGameInstanceSubsystem
    if not Game.valid(catalog) or not Game.valid(subsystem) then return snapshot end
    local restaurant = subsystem:GetBrasserieManager()
    if not actor(restaurant, session.world) then return snapshot end

    local supplied, work = 0, {}
    local data = catalog:GetDish(ticket.dish)
    snapshot.preparation = number(data.PrepareTime)
    for _, entry in ipairs(array_values(kitchen.DishesPrepareQueue.Items)) do
        if same(entry.LinkedTable, linked) and entry.Dish == ticket.dish then supplied = supplied + 1 end
        local duration
        if entry.State == api.pending then
            duration = number(catalog:GetDish(entry.Dish).PrepareTime)
        elseif entry.State == api.preparing then
            -- Use the full assigned duration, including elapsed cooking time,
            -- to avoid mixing server/game clocks or assuming chef parallelism.
            duration = number(entry.PreparationDuration)
        end
        if not duration or duration <= 0 then
            snapshot.ready, snapshot.queue = true, { -1 }
            return snapshot
        end
        work[#work + 1] = duration
    end
    for _, dish in ipairs(FindAllOf('GenericDish') or {}) do
        if actor(dish, session.world) and dish.Dish == ticket.dish
            and same(dish:GetOrderedForTable(), linked) and not boolean(dish.bIsDirty)
            and not boolean(dish.bIsBeingConsumed) and not Game.valid(dish.table) then
            supplied = supplied + 1
        end
    end
    snapshot.supplied = supplied >= demand
    snapshot.queue = work
    snapshot.ready = kitchen.ChefCharacters:GetArrayNum() > 0
        and boolean(restaurant:AreDishRequirementsMet(ticket.dish))
    snapshot.patience_enabled = boolean(restaurant:GetPatienceState())
    if snapshot.patience_enabled and boolean(linked:IsCustomerOrderWaitActive()) then
        local duration = number(linked:GetCustomerWaitTime())
        local elapsed = number(linked:GetCustomerWaitElapsedTime())
        if duration > 0 and elapsed >= 0 then snapshot.remaining = duration - elapsed end
    end
    return snapshot, { kitchen = kitchen, linked = linked, data = data }
end

function Game.snapshot(api, session, ticket)
    local snapshot = inspect(api, session, ticket)
    return snapshot
end

function Game.request(api, session, ticket)
    local current = Game.session(api)
    if not current or current.id ~= session.id or current.paused then return false, 'session-changed' end
    local snapshot, context = inspect(api, current, ticket)
    local action, reason = Remake.decision(snapshot)
    if action ~= 'order' then return false, reason end
    local before = {}
    for _, entry in ipairs(array_values(context.kitchen.DishesPrepareQueue.Items)) do before[guid(entry.DishId)] = true end
    -- Null Player selects the native employee order path, preserving kitchen
    -- ingredient/chef checks and normal preparation, costs and replication.
    context.kitchen:TryOrderDish(context.data, context.linked, nil)
    local accepted
    for _, entry in ipairs(array_values(context.kitchen.DishesPrepareQueue.Items)) do
        if not before[guid(entry.DishId)] and entry.Dish == ticket.dish and same(entry.LinkedTable, context.linked) then
            assert(not accepted, 'Multiple replacement orders appeared during one request')
            accepted = entry
        end
    end
    if not accepted then return false, 'kitchen-rejected' end
    -- The old notification is already marked ordered, so the native function
    -- does not assign its new GUID. Reacquire the exact row after the call.
    local rebound = false
    for _, notice in ipairs(array_values(context.linked.OrderNotifications)) do
        if Game.valid(notice.Customer) and identity(notice.Customer) == ticket.customer
            and notice.Dish == ticket.dish and guid(notice.DishOrderId) == ticket.order then
            notice.DishOrderId = accepted.DishId
            notice.bDishOrdered = true
            rebound = true
            break
        end
    end
    assert(rebound, 'Accepted order could not be rebound; automatic retries disabled')
    context.linked:OnRep_OrderNotifications()
    context.linked:ForceNetUpdate()
    return true, 'accepted'
end

return Game
