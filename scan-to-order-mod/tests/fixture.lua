-- Synthetic objects and order transitions, without game data or SDK exports.
return function()
    local f, serial = { stock = { [12] = 10, [34] = 10 }, calls = {}, paused = false }, 0
    local function object(name)
        serial = serial + 1
        local o = { name = name, address = serial, valid = true, authority = true }
        function o:IsValid() return self.valid end
        function o:GetAddress() return self.address end
        function o:GetFullName() return self.name end
        function o:GetWorld() return self.world or f.world end
        function o:HasAuthority() return self.authority end
        function o:HasAnyFlags() return self.template == true end
        function o:IsActorBeingDestroyed() return self.destroyed == true end
        function o:IsA(class) return self.class == class end
        return o
    end
    local function array(values)
        values = values or {}
        function values:GetArrayNum() return #self end
        return values
    end
    local function guid(value) return { A = value or 0, B = 0, C = 0, D = 0 } end
    f.object, f.array, f.guid = object, array, guid
    f.world, f.player, f.controller = object('world'), object('player'), object('controller')
    f.api = { player = object('player-class'), dish_data = object('dish-data-type'),
        gameplay = object('gameplay'), none = 0, silent = 0 }
    f.player.class, f.player.Controller, f.controller.Pawn = f.api.player, f.controller, f.player
    function f.controller:IsLocalController() return not self.remote end
    function f.api.gameplay:IsGamePaused() return f.paused end
    f.table = object('table')
    f.table.NumberOfCustomersSit, f.table.AssignedCustomerGroupId = 1, 8
    f.table.bTableHandledByPlayer, f.table.bBeingOrdered, f.table.bGroupCanBeCashedOut = false, false, false
    f.table.RepCustomerActors, f.table.OrderNotifications = array(), array()
    function f.table:IsTableOccupied() return not self.empty end
    function f.table:IsCustomerOrderWaitActive() return true end
    function f.table:GetCustomerWaitElapsedTime() return f.elapsed or 0 end
    function f.table:GetCustomerWaitTime() return 60 end
    f.restaurant, f.storage, f.catalog, f.subsystem = object('restaurant'), object('storage'), object('catalog'), object('services')
    function f.restaurant:GetPatienceState() return f.patience ~= false end
    function f.restaurant:AreDishRequirementsMet(key) return key ~= f.unavailable end
    function f.storage:HasEnoughIngredients(ingredients, policy)
        assert(policy == f.api.silent)
        assert(getmetatable(ingredients) == nil and ingredients.GetArrayNum == nil,
            'Stock check must receive independent Lua records')
        f.checked_ingredients = ingredients
        for _, entry in ipairs(ingredients) do
            assert(getmetatable(entry) == nil and type(entry.Ingredient) == 'number'
                and type(entry.Amount) == 'number', 'No reflected parameter wrappers')
            if (f.stock[entry.Ingredient] or 0) < entry.Amount then return false end
        end
        return true
    end
    function f.catalog:GetDish() error('Full dish return conversion must never run') end
    f.recipes, f.data_rows = {}, {}
    for _, key in ipairs({ 12, 34 }) do
        f.recipes[key] = array({ { Ingredient = key, Amount = 1 } })
        local row = object('dish-' .. key)
        function row:IsMappedToObject() return not rawget(self, 'unmapped') end
        setmetatable(row, { __index = function(_, field)
            if field == 'Key' then return key end
            if field == 'Ingredients' then return f.recipes[key] end
            error('Unnecessary dish field conversion: ' .. field)
        end, __pairs = function() error('Do not expand the whole dish') end })
        f.data_rows[key] = row
    end
    f.catalog.DishesTable = object('dish-table')
    function f.catalog.DishesTable:GetRowStruct() return f.api.dish_data end
    function f.catalog.DishesTable:GetRowMap() return f.data_rows end
    function f.subsystem:GetBrasserieManager() return f.restaurant end
    function f.subsystem:GetStorageManager() return f.storage end
    f.kitchen, f.drinks = object('kitchen'), object('drinks')
    f.kitchen.ChefCharacters = array({ object('chef') })
    f.kitchen.DishesPrepareQueue, f.drinks.DrinksPrepareQueue = { Items = array() }, { Items = array() }
    for _, producer in ipairs({ f.kitchen, f.drinks }) do
        producer.DishGameInstanceSubsystem, producer.WorldGameInstanceSubsystem = f.catalog, f.subsystem
    end
    function f.add_customer(food, drink)
        local customer, behavior = object('customer' .. (#f.table.RepCustomerActors + 1)), object('behavior')
        behavior.GroupId, behavior.WantedDish, behavior.WantedDrink = 8, food or 12, drink or 34
        behavior.bIsDishServed, behavior.bIsDrinkServed = false, false
        function customer:GetCustomerBehaviorComponent() return behavior end
        local row = { Customer = customer, Dish = behavior.WantedDish, Drink = behavior.WantedDrink,
            bDishOrdered = false, bDrinkOrdered = false, DishOrderId = guid(), DrinkOrderId = guid() }
        table.insert(f.table.RepCustomerActors, customer)
        table.insert(f.table.OrderNotifications, row)
        return row, behavior
    end
    f.row, f.behavior = f.add_customer()
    local function order(producer, item, data, linked, player)
        assert(player == nil and linked == f.table, 'Must use the native AI route')
        assert(data == f.data_rows[data.Key], 'Must pass the complete original dish reference')
        f.calls[#f.calls + 1] = { item = item, key = data.Key }
        if f.reject then return end
        for _, entry in ipairs(f.recipes[data.Key]) do
            assert((f.stock[entry.Ingredient] or 0) >= entry.Amount, 'No order may overdraw stock')
            f.stock[entry.Ingredient] = f.stock[entry.Ingredient] - entry.Amount
        end
        local id = guid(#f.calls)
        local queue = item == 'Dish' and producer.DishesPrepareQueue or producer.DrinksPrepareQueue
        queue.Items[#queue.Items + 1] = { [item] = data.Key, [item .. 'Id'] = id, LinkedTable = linked }
        if f.throw_after_accept then error('uncertain bridge outcome') end
        if f.omit_binding then return end
        for _, row in ipairs(linked.OrderNotifications) do
            if row[item] == data.Key and not row['b' .. item .. 'Ordered'] then
                row['b' .. item .. 'Ordered'], row[item .. 'OrderId'] = true, id
                break
            end
        end
    end
    function f.kitchen:TryOrderDish(...) order(self, 'Dish', ...) end
    function f.drinks:TryOrderDrink(...) order(self, 'Drink', ...) end
    f.objects = { NetPlayerController = { f.controller }, ['table'] = { f.table },
        KitchenManager = { f.kitchen }, DrinkManager = { f.drinks } }
    FindAllOf = function(class) return f.objects[class] or {} end
    return f
end
