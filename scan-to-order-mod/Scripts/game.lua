-- Original automation over reflected game APIs; call only on the game thread.
local Game = {}
local TEMPLATE_FLAGS = 0x10 | 0x20
local routes = {
    food = { item = 'Dish', ordered = 'bDishOrdered', order = 'DishOrderId',
        wanted = 'WantedDish', served = 'bIsDishServed', instance = 'DishInstance',
        manager = 'KitchenManager', queue = 'DishesPrepareQueue', id = 'DishId' },
    drink = { item = 'Drink', ordered = 'bDrinkOrdered', order = 'DrinkOrderId',
        wanted = 'WantedDrink', served = 'bIsDrinkServed', instance = 'DrinkInstance',
        manager = 'DrinkManager', queue = 'DrinksPrepareQueue', id = 'DrinkId' },
}

function Game.valid(value) return value ~= nil and value:IsValid() end
local function same(a, b)
    return Game.valid(a) and Game.valid(b) and a:GetAddress() == b:GetAddress()
end
local function identity(value) return value:GetFullName() .. '@' .. tostring(value:GetAddress()) end
local function actor(value, world)
    return Game.valid(value) and not value:HasAnyFlags(TEMPLATE_FLAGS)
        and not value:IsActorBeingDestroyed() and value:HasAuthority()
        and (not world or same(value:GetWorld(), world))
end
local function boolean(value)
    assert(type(value) == 'boolean', 'Unsupported order boolean')
    return value
end
local function number(value)
    assert(type(value) == 'number' and value == value and math.abs(value) < math.huge,
        'Unsupported order number')
    return value
end
local function guid(value)
    return table.concat({ number(value.A), number(value.B), number(value.C), number(value.D) }, ':')
end
local function required(path)
    local value = StaticFindObject(path)
    assert(Game.valid(value), 'Missing Scan to Order API: ' .. path)
    return value
end
local function enum(name, suffix)
    local result
    required('/Script/BrasserieSimulator.' .. name):ForEachName(function(key, value)
        local text = key:ToString()
        if text == suffix or text:sub(-#suffix - 2) == '::' .. suffix then
            result = value
            return true
        end
    end)
    return number(result)
end

function Game.contract()
    for _, name in ipairs({ 'KitchenManager:TryOrderDish', 'DrinkManager:TryOrderDrink',
        'StorageManager:HasEnoughIngredients', 'BrasserieManager:AreDishRequirementsMet',
        'DishGameInstanceSubsystem:GetDish', 'CustomerActor:GetCustomerBehaviorComponent',
        'WorldGameInstanceSubsystem:GetBrasserieManager', 'WorldGameInstanceSubsystem:GetStorageManager',
        'table:IsTableOccupied', 'table:IsCustomerOrderWaitActive',
        'table:GetCustomerWaitElapsedTime', 'table:GetCustomerWaitTime',
        'BrasserieManager:GetPatienceState' }) do
        required('/Script/BrasserieSimulator.' .. name)
    end
    return { player = required('/Script/BrasserieSimulator.PlayerCharacter'),
        gameplay = required('/Script/Engine.Default__GameplayStatics'),
        none = enum('EDishes', 'EDH_Unknown'), silent = enum('EMissingNotifyPolicy', 'None') }
end

function Game.session(api)
    local result
    for _, controller in ipairs(FindAllOf('NetPlayerController') or {}) do
        if actor(controller) and controller:IsLocalController() then
            local world, pawn = controller:GetWorld(), controller.Pawn
            if Game.valid(world) and actor(pawn, world) and pawn:IsA(api.player)
                and same(pawn.Controller, controller) then
                assert(not result, 'Multiple local host sessions')
                result = { id = identity(world), world = world,
                    paused = boolean(api.gameplay:IsGamePaused(controller)) }
            end
        end
    end
    return result
end

local function available(session, linked)
    return actor(linked, session.world) and boolean(linked:IsTableOccupied())
        and number(linked.NumberOfCustomersSit) > 0 and not boolean(linked.bGroupCanBeCashedOut)
        and not boolean(linked.bTableHandledByPlayer) and not boolean(linked.bBeingOrdered)
end

local function waiting(api, session, linked, notice, route)
    local key = number(notice[route.item])
    if key == api.none or boolean(notice[route.ordered]) or guid(notice[route.order]) ~= '0:0:0:0' then
        return false
    end
    local customer = notice.Customer
    if not actor(customer, session.world) then return false end
    local seated = false
    for index = 1, linked.RepCustomerActors:GetArrayNum() do
        if same(linked.RepCustomerActors[index], customer) then seated = true; break end
    end
    if not seated then return false end
    local behavior = customer:GetCustomerBehaviorComponent()
    return Game.valid(behavior) and number(behavior.GroupId) == number(linked.AssignedCustomerGroupId)
        and number(behavior[route.wanted]) == key and not boolean(behavior[route.served])
        and not Game.valid(behavior[route.instance])
end

function Game.candidates(api, session)
    local result = {}
    for _, linked in ipairs(FindAllOf('table') or {}) do
        if available(session, linked) then
            for index = 1, linked.OrderNotifications:GetArrayNum() do
                local notice = linked.OrderNotifications[index]
                for _, kind in ipairs({ 'food', 'drink' }) do
                    local route = routes[kind]
                    if waiting(api, session, linked, notice, route) then
                        -- Keep only scalar identities across calls that may resize arrays.
                        result[#result + 1] = { linked = identity(linked), customer = identity(notice.Customer),
                            group = number(linked.AssignedCustomerGroupId), kind = kind,
                            dish = number(notice[route.item]) }
                    end
                end
            end
        end
    end
    return result
end

local function find_actor(class, id, world)
    local result
    for _, value in ipairs(FindAllOf(class) or {}) do
        if actor(value, world) and (not id or identity(value) == id) then
            assert(not result, 'Ambiguous order object: ' .. class)
            result = value
        end
    end
    return result
end

local function first_pending(linked, route, key)
    for index = 1, linked.OrderNotifications:GetArrayNum() do
        local notice = linked.OrderNotifications[index]
        if notice[route.item] == key and not boolean(notice[route.ordered]) then return notice end
    end
end

function Game.request(api, previous, ticket)
    local session = Game.session(api)
    if not session or session.id ~= previous.id or session.paused then return false, 'session-changed' end
    local route = assert(routes[ticket.kind], 'Unknown order kind')
    local linked = find_actor('table', ticket.linked, session.world)
    if not linked or not available(session, linked) or linked.AssignedCustomerGroupId ~= ticket.group then
        return false, 'table-changed'
    end
    -- Native ordering binds the first unplaced row for this item. Do not send
    -- a later customer's request into an earlier, stale or ineligible row.
    local notice = first_pending(linked, route, ticket.dish)
    if not notice or not waiting(api, session, linked, notice, route)
        or identity(notice.Customer) ~= ticket.customer then return false, 'order-changed' end
    local producer = find_actor(route.manager, nil, session.world)
    if not producer then return false, 'producer-unavailable' end
    local catalog, subsystem = producer.DishGameInstanceSubsystem, producer.WorldGameInstanceSubsystem
    if not Game.valid(catalog) or not same(catalog:GetWorld(), session.world)
        or not Game.valid(subsystem) or not same(subsystem:GetWorld(), session.world) then
        return false, 'services-unavailable'
    end
    local restaurant, storage = subsystem:GetBrasserieManager(), subsystem:GetStorageManager()
    if not actor(restaurant, session.world) or not actor(storage, session.world) then
        return false, 'services-unavailable'
    end
    if boolean(restaurant:GetPatienceState()) and boolean(linked:IsCustomerOrderWaitActive()) then
        if number(linked:GetCustomerWaitElapsedTime()) >= number(linked:GetCustomerWaitTime()) then
            return false, 'patience-expired'
        end
    end
    if ticket.kind == 'food' and producer.ChefCharacters:GetArrayNum() == 0 then
        return false, 'no-chef'
    end
    if not boolean(restaurant:AreDishRequirementsMet(ticket.dish)) then return false, 'requirements-unmet' end
    local data = catalog:GetDish(ticket.dish)
    assert(number(data.Key) == ticket.dish, 'Dish lookup mismatch')
    -- A silent check avoids missing-stock notification spam. The native request
    -- checks again and consumes ingredients, so subsequent customers see the
    -- remaining stock instead of a cached availability decision.
    if not boolean(storage:HasEnoughIngredients(data.Ingredients, api.silent)) then
        return false, 'out-of-stock'
    end
    local before = {}
    for index = 1, producer[route.queue].Items:GetArrayNum() do
        before[guid(producer[route.queue].Items[index][route.id])] = true
    end
    -- Null Player is the game's AI ordering route. It retains native staffing,
    -- preparation, notification assignment, queue updates and replication.
    if ticket.kind == 'food' then producer:TryOrderDish(data, linked, nil)
    else producer:TryOrderDrink(data, linked, nil) end
    local accepted
    for index = 1, producer[route.queue].Items:GetArrayNum() do
        local entry = producer[route.queue].Items[index]
        local id = guid(entry[route.id])
        if not before[id] and entry[route.item] == ticket.dish and same(entry.LinkedTable, linked) then
            assert(not accepted, 'Multiple orders appeared for one request')
            accepted = id
        end
    end
    -- Reacquire the row after the synchronous native mutation. An uncertain
    -- result stops this world's automation rather than risking a duplicate.
    for index = 1, linked.OrderNotifications:GetArrayNum() do
        local row = linked.OrderNotifications[index]
        if Game.valid(row.Customer) and identity(row.Customer) == ticket.customer
            and row[route.item] == ticket.dish then
            if accepted then
                assert(boolean(row[route.ordered]) and guid(row[route.order]) == accepted,
                    'Queue and customer order disagree')
                return true, 'accepted'
            end
            assert(not boolean(row[route.ordered]) and guid(row[route.order]) == '0:0:0:0',
                'Order changed without queue confirmation')
            return false, 'native-rejected'
        end
    end
    error('Customer order disappeared during request')
end

return Game
