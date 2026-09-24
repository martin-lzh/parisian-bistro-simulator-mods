-- Original drink-specific adapter, using the shared game-thread guards.
return function(common)
    local D = {}
    local valid, same, actor = common.valid, common.same, common.actor
    local values, number, boolean, guid = common.values, common.number, common.boolean, common.guid

    function D.contract(api, required, enum)
        for _, path in ipairs({
            '/Script/BrasserieSimulator.DrinkManager:TryOrderDrink',
            '/Script/BrasserieSimulator.Drink:IsFull',
            '/Script/BrasserieSimulator.DrinkOutputArea:HasSpace',
            '/Script/BrasserieSimulator.DishGameInstanceSubsystem:IsCocktailDish',
            '/Script/BrasserieSimulator.WorldGameInstanceSubsystem:GetEmployeeManager',
            '/Script/SmartObjectsModule.SmartObjectComponent:GetDefinition',
        }) do required(path) end
        api.drink = required('/Script/BrasserieSimulator.Drink')
        api.cocktail = required('/Script/BrasserieSimulator.CocktailDrink')
        api.interaction = required('/Script/BrasserieSimulator.SmartObjectInteractionDefinition')
        api.prepare_drink = required('/Script/BrasserieSimulator.PrepareDrinkEvaluator')
        api.prepare_cocktail = required('/Script/BrasserieSimulator.PrepareCocktailEvaluator')
        api.drink_pending = enum('EDrinkOrderState', 'Pending')
        api.drink_preparing = enum('EDrinkOrderState', 'Preparing')
        api.drink_prepared = enum('EDrinkOrderState', 'Prepared')
        api.barman = enum('EEmployeeRole', 'Barman')
        api.working = enum('EEmployeeState', 'Working')
    end

    function D.eligible(api, session, candidate)
        local drink, holder, manager = candidate.object, candidate.holder, candidate.producer
        if not actor(manager, session.world) or not actor(holder, session.world)
            or not actor(drink, session.world) or not drink:IsA(api.drink) then return false end
        if boolean(drink.bIsDirty) or boolean(drink.bIsBeingConsumed) or boolean(drink.bBeingPicked)
            or boolean(drink.bFillTransitionActive) or not boolean(drink:IsFull())
            or drink.Dish == api.none or valid(drink.table) then return false end
        if drink:IsA(api.cocktail) and boolean(drink.bIsPourInProgress) then return false end
        local parent, linked = drink:GetAttachParentActor(), drink:GetOrderedForTable()
        if valid(parent) and not same(parent, holder) then return false end
        if actor(linked, session.world) and boolean(linked.bTableHandledByPlayer) then return false end
        local found = false
        if candidate.slot then
            local slot = holder.ElevatorSlots[candidate.slot]
            found = boolean(slot.bReservedForDrinkOnly) and same(slot.Dish, drink)
        else
            for _, entry in ipairs(values(holder.OutputSlots.Items)) do
                if same(entry.Drink, drink) then found = true end
            end
        end
        if not found then return false end
        -- Never destroy a glass that is still part of unfinished production.
        local order = guid(drink.DrinkOrderId)
        for _, entry in ipairs(values(manager.DrinksPrepareQueue.Items)) do
            if guid(entry.DrinkId) == order and entry.State ~= api.drink_prepared then return false end
        end
        return common.poor(api, drink)
    end

    function D.candidates(api, session)
        local manager
        for _, object in ipairs(FindAllOf('DrinkManager') or {}) do
            if actor(object, session.world) then
                assert(not manager, 'Multiple authoritative drink managers')
                manager = object
            end
        end
        if not manager then return {} end
        local result, seen = {}, {}
        local function add(drink, holder, slot)
            if not actor(drink, session.world) then return end
            local id = common.identity(drink)
            local candidate = { id = id, kind = 'drink', object = drink, producer = manager,
                holder = holder, slot = slot }
            if not seen[id] and D.eligible(api, session, candidate) then
                seen[id] = true; result[#result + 1] = candidate
            end
        end
        for _, elevator in ipairs(FindAllOf('DishElevator') or {}) do
            if actor(elevator, session.world) then
                for index = 1, elevator.ElevatorSlots:GetArrayNum() do
                    add(elevator.ElevatorSlots[index].Dish, elevator, index)
                end
            end
        end
        for _, area in ipairs(FindAllOf('DrinkOutputArea') or {}) do
            if actor(area, session.world) then
                for _, entry in ipairs(values(area.OutputSlots.Items)) do add(entry.Drink, area) end
            end
        end
        return result
    end

    function D.discard(api, session, candidate)
        if not D.eligible(api, session, candidate) then return false end
        local drink = candidate.object
        local address, order = drink:GetAddress(), guid(drink.DrinkOrderId)
        -- Drink EndPlay removes its exact queue GUID and notifies the manager.
        -- Output areas natively reuse slots whose drink has been destroyed.
        -- Do not mutate either replicated FastArray or cancel player claims.
        drink:K2_DestroyActor()
        assert(not valid(drink) or drink:IsActorBeingDestroyed(), 'Drink destruction not confirmed')
        for _, entry in ipairs(values(candidate.producer.DrinksPrepareQueue.Items)) do
            assert(order == '0:0:0:0' or guid(entry.DrinkId) ~= order, 'Destroyed drink order still present')
        end
        if candidate.slot then
            local slot = candidate.holder.ElevatorSlots[candidate.slot]
            if slot.Dish ~= nil and slot.Dish:GetAddress() == address then slot.Dish = nil end
        else
            assert(boolean(candidate.holder:HasSpace()), 'Drink output space was not released')
        end
        candidate.holder:ForceNetUpdate()
        candidate.producer:ForceNetUpdate()
        return true
    end

    local function use_time(api, device)
        local component = device.SmartObjectComponent
        if not valid(component) then return nil end
        local definition = component:GetDefinition()
        if not valid(definition) then return nil end
        local longest
        local function scan(array)
            for _, behavior in ipairs(values(array)) do
                if valid(behavior) and behavior:IsA(api.interaction) then
                    local duration = number(behavior.UseTime)
                    if duration >= 0 then longest = math.max(longest or 0, duration) end
                end
            end
        end
        scan(definition.DefaultBehaviorDefinitions)
        for _, slot in ipairs(values(definition.Slots)) do scan(slot.BehaviorDefinitions) end
        return longest
    end

    local function preparation(api, session, catalog, key, floor)
        -- DishData.PrepareTime is commonly zero for drinks. Read live equipment
        -- fill/use durations instead of treating that zero as instant service.
        local cocktail = boolean(catalog:IsCocktailDish(key))
        local data = catalog:GetDish(key)
        local base, ingredients = number(data.PrepareTime), {}
        if base < 0 then return nil end
        for _, ingredient in ipairs(values(data.Ingredients)) do ingredients[ingredient.Ingredient] = true end
        local longest
        for _, class in ipairs(cocktail and { 'CocktailStation' } or { 'DrinkDispenser', 'BottleDispenser' }) do
            for _, device in ipairs(FindAllOf(class) or {}) do
                if actor(device, session.world) and device:GetAssignedFloor() == floor
                    and (cocktail or (class == 'BottleDispenser' and device.Dish == key)
                        or (class == 'DrinkDispenser' and ingredients[device.LinkedIngredient])) then
                    local use = use_time(api, device)
                    local fill = cocktail and 0 or number(device.FillDuration)
                    if use == nil or fill < 0 or use + fill <= 0 then return nil end
                    longest = math.max(longest or 0, base + fill + use)
                end
            end
        end
        -- Include glass/ingredient handling as well as the shared service margin.
        return longest and longest + 10 or nil
    end

    local function staffed(api, session, manager, floor, cocktail)
        local employees = manager.WorldGameInstanceSubsystem:GetEmployeeManager()
        if not actor(employees, session.world) then return false end
        local task = cocktail and api.prepare_cocktail or api.prepare_drink
        for _, employee in ipairs(values(employees.RecruitedEmployees)) do
            if employee.Role == api.barman and employee.State == api.working and employee.AssignedFloor == floor then
                local excluded = false
                for _, class in ipairs(values(employee.ExcludedTaskTypes)) do
                    if same(class, task) then excluded = true end
                end
                if not excluded then return true end
            end
        end
        return false
    end

    function D.inspect(api, session, manager, linked, key, demand, snapshot)
        local catalog = manager.DishGameInstanceSubsystem
        local floor = number(linked:GetAssignedFloor())
        local supplied, covered, work, manual = 0, {}, {}, false
        snapshot.preparation = preparation(api, session, catalog, key, floor)
        for _, entry in ipairs(values(manager.DrinksPrepareQueue.Items)) do
            -- Copy primitives before calling equipment/catalog functions.
            local state, drink_key, order = entry.State, entry.Drink, guid(entry.DrinkId)
            local table_actor, queue_floor = entry.LinkedTable, entry.PlayerFloor
            local claimed = boolean(entry.bClaimedByPlayer)
            if state == api.drink_pending or state == api.drink_preparing then
                if same(table_actor, linked) and drink_key == key then
                    if not covered[order] then supplied = supplied + 1; covered[order] = true end
                end
                manual = manual or claimed
                if actor(table_actor, session.world) then queue_floor = table_actor:GetAssignedFloor() end
                work[#work + 1] = preparation(api, session, catalog, drink_key, queue_floor) or -1
            elseif state ~= api.drink_prepared then
                work[#work + 1] = -1
            end
        end
        for _, drink in ipairs(FindAllOf('Drink') or {}) do
            if actor(drink, session.world) and drink.Dish == key and same(drink:GetOrderedForTable(), linked)
                and not boolean(drink.bIsDirty) and not boolean(drink.bIsBeingConsumed)
                and not valid(drink.table) and boolean(drink:IsFull()) then
                local order = guid(drink.DrinkOrderId)
                if order == '0:0:0:0' or not covered[order] then
                    supplied = supplied + 1
                    if order ~= '0:0:0:0' then covered[order] = true end
                end
            end
        end
        snapshot.supplied, snapshot.queue = supplied >= demand, work
        local restaurant = manager.WorldGameInstanceSubsystem:GetBrasserieManager()
        snapshot.ready = not manual and staffed(api, session, manager, floor, catalog:IsCocktailDish(key))
            and boolean(restaurant:AreDishRequirementsMet(key))
    end

    return D
end
