-- Synthetic behavior fixture; no game data, exports or assets.
return function()
    local f, serial = {}, 0
    local function object(name)
        serial = serial + 1
        local o = { name = name, address = serial, valid = true, authority = true }
        function o:IsValid() return self.valid end
        function o:GetAddress() return self.address end
        function o:GetFullName() return self.name end
        function o:HasAnyFlags() return self.template == true end
        function o:IsActorBeingDestroyed() return self.destroyed == true end
        function o:HasAuthority() return self.authority end
        function o:GetWorld() return self.world or f.world end
        function o:IsA(class) return self.class == class end
        function o:GetAttachParentActor() return self.parent end
        function o:ForceNetUpdate() self.updates = (self.updates or 0) + 1 end
        function o:K2_DestroyActor() if not self.refuse_destroy then self.destroyed = true end end
        return o
    end
    local function array(values)
        local storage, count = values or {}, #(values or {})
        local methods = {
            GetArrayNum = function() return count end,
            Empty = function() storage, count = {}, 0 end,
        }
        return setmetatable({}, {
            __len = function() return count end,
            __index = function(_, key) return methods[key] or storage[key] end,
            __newindex = function(_, key, value)
                assert(type(key) == 'number')
                count = math.max(count, key); storage[key] = value
            end,
        })
    end
    local function map(values)
        return { ForEach = function(_, callback)
            for _, pair in ipairs(values) do
                callback({ get = function() return pair[1] end }, { get = function() return pair[2] end })
            end
        end }
    end
    local function guid(n) return { A = n, B = 0, C = 0, D = 0 } end
    f.object, f.array, f.map, f.guid = object, array, map, guid
    f.world = object('world')
    f.player = object('player'); f.controller = object('controller')
    f.player.Controller = f.controller; f.controller.Pawn = f.player
    function f.controller:IsLocalController() return true end
    f.now = 20
    f.api = { player = {}, dish = {}, none = 0, poor = 3, awful = 4, pending = 0, preparing = 1,
        quality = { GetSatisfactionFromDishQuality = function(_, quality) return quality end },
        math = { Subtract_DateTimeDateTime = function(_, a, b) return a-b end,
            GetTotalSeconds = function(_, value) return value end },
        gameplay = { GetTimeSeconds = function() return f.now end,
            IsGamePaused = function() return f.paused == true end } }
    f.player.class = f.api.player
    f.table = object('table'); f.table.AssignedCustomerGroupId = 5
    f.table.NumberOfCustomersSit = 1; f.table.CustomerOrderTime = 10
    f.table.bGroupCanBeCashedOut = false; f.table.bTableHandledByPlayer = false
    function f.table:IsTableOccupied() return self.NumberOfCustomersSit > 0 end
    function f.table:IsCustomerOrderWaitActive() return not f.inactive_timer end
    function f.table:GetCustomerWaitTime() return 200 end
    function f.table:GetCustomerWaitElapsedTime() return f.elapsed or 10 end
    function f.table:OnRep_OrderNotifications() self.refreshed = true end
    f.customer = object('customer')
    f.behavior = object('behavior'); f.behavior.GroupId = 5; f.behavior.WantedDish = 12
    f.behavior.bIsDishServed = false
    function f.customer:GetCustomerBehaviorComponent() return f.behavior end
    f.notice = { Customer = f.customer, Dish = 12, bDishOrdered = true, DishOrderId = guid(1) }
    f.table.OrderNotifications = array({f.notice}); f.table.RepCustomerActors = array({f.customer})
    f.restaurant = object('restaurant')
    function f.restaurant:GetPatienceState() return not f.no_patience end
    function f.restaurant:AreDishRequirementsMet() return not f.requirements_missing end
    f.catalog = object('catalog')
    function f.catalog:GetDish(key) return { Key = key, PrepareTime = f.prepare_time or 20 } end
    f.subsystem = object('subsystem')
    function f.subsystem:GetBrasserieManager() return f.restaurant end
    f.kitchen = object('kitchen'); f.kitchen.ChefCharacters = array({{}})
    f.kitchen.DishGameInstanceSubsystem = f.catalog; f.kitchen.WorldGameInstanceSubsystem = f.subsystem
    f.kitchen.DishesPrepareQueue = { Items = array() }
    f.kitchen.DishElevators = map({}); f.kitchen.TakenOutDishes = map({})
    function f.controller:Server_RequestRemoveDishFromSpawnQueue(kitchen, dish)
        assert(kitchen == f.kitchen and not dish.destroyed)
        if f.reject_release then return end
        local released = false
        kitchen.DishElevators:ForEach(function(_, value)
            for i = 1, value:get().ElevatorSlots:GetArrayNum() do
                local slot = value:get().ElevatorSlots[i]
                if slot.bDishesOnly and slot.Dish == dish then slot.Dish = nil; released = true end
            end
        end)
        if not released then
            for i = 1, kitchen.DishesSpawnQueue:GetArrayNum() do
                if kitchen.DishesSpawnQueue[i] == dish then
                    kitchen.DishesSpawnQueue[i] = nil; released = true; break
                end
            end
        end
        assert(released, 'No pickup slot found')
        local taken
        kitchen.TakenOutDishes:ForEach(function(key, value)
            if key:get() == dish:GetOrderedForTable() then taken = value:get().Dishes end
        end)
        if not taken then
            taken = array(); kitchen.TakenOutDishes = map({{dish:GetOrderedForTable(), {Dishes=taken}}})
        end
        taken[#taken+1] = dish.Dish
        f.released = (f.released or 0) + 1
    end
    f.ordered = 0
    function f.kitchen:TryOrderDish(data, linked, player)
        assert(data.Key == 12 and linked == f.table and player == nil)
        assert(f.dish.destroyed, 'Must discard before requesting a remake')
        f.ordered = f.ordered + 1
        if f.reject then return end
        table.insert(self.DishesPrepareQueue.Items, { DishId = guid(f.ordered+100), Dish = data.Key,
            LinkedTable = linked, State = 0, PreparationDuration = 0 })
        if f.throw_after_accept then error('uncertain bridge failure') end
    end
    f.dish = object('dish'); f.dish.class = f.api.dish
    f.dish.Dish = 12; f.dish.bIsDirty = false; f.dish.bIsBeingConsumed = false
    f.dish.bBeingPicked = false; f.dish.CreationTime = 11; f.dish.quality = 3
    function f.dish:GetDishQuality() return self.quality end
    function f.dish:GetOrderedForTable() return self.linked or f.table end
    f.kitchen.DishesSpawnQueue = array({f.dish})
    f.objects = { NetPlayerController = {f.controller}, KitchenManager = {f.kitchen},
        table = {f.table}, GenericDish = {f.dish} }
    _G.FindAllOf = function(class) return f.objects[class] or {} end
    return f
end
