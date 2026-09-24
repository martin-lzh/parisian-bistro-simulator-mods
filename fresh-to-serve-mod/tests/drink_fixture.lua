-- Synthetic drink lifecycle and equipment, without game exports or assets.
return function(cocktail)
    local f = require('fixture')()
    f.dish.quality = 0
    f.api.drink, f.api.cocktail, f.api.interaction = f.object('drink-class'), f.object('cocktail-class'), f.object('interaction-class')
    f.api.prepare_drink, f.api.prepare_cocktail = f.object('prepare-drink'), f.object('prepare-cocktail')
    f.api.drink_pending, f.api.drink_preparing, f.api.drink_prepared = 0, 1, 2
    f.api.barman, f.api.working = 8, 0
    f.notice.Drink, f.notice.DrinkOrderId, f.notice.bDrinkOrdered = 17, f.guid(1), true
    f.behavior.WantedDrink, f.behavior.bIsDrinkServed = 17, false
    function f.table:GetAssignedFloor() return f.floor or 0 end
    f.employees = f.object('employees')
    f.employee = { Role = 8, State = 0, AssignedFloor = 0, ExcludedTaskTypes = f.array() }
    f.employees.RecruitedEmployees = f.array({ f.employee })
    function f.subsystem:GetEmployeeManager() return f.employees end
    function f.catalog:IsCocktailDish() return cocktail == true end
    function f.catalog:GetDish(key)
        return { Key = key, PrepareTime = key == 12 and 20 or 0,
            Ingredients = f.array({{Ingredient = 29}}) }
    end
    f.device = f.object('device'); f.device.FillDuration, f.device.LinkedIngredient, f.device.Dish = 4, 29, 17
    function f.device:GetAssignedFloor() return f.device_floor or 0 end
    local definition, behavior = f.object('definition'), f.object('behavior-definition')
    behavior.class, behavior.UseTime = f.api.interaction, 6
    definition.DefaultBehaviorDefinitions = f.array({behavior}); definition.Slots = f.array()
    f.use = behavior
    f.device.SmartObjectComponent = f.object('smart-object')
    function f.device.SmartObjectComponent:GetDefinition() return definition end
    f.manager = f.object('drink-manager')
    f.manager.DishGameInstanceSubsystem, f.manager.WorldGameInstanceSubsystem = f.catalog, f.subsystem
    f.prepared = { DrinkId = f.guid(1), Drink = 17, State = 2, LinkedTable = f.table,
        PlayerFloor = 0, bClaimedByPlayer = false }
    f.manager.DrinksPrepareQueue = { Items = f.array({f.prepared}) }
    f.drink = f.object('drink'); f.drink.class = f.api.drink
    f.drink.Dish, f.drink.DrinkOrderId, f.drink.CreationTime, f.drink.quality = 17, f.guid(1), 11, 3
    f.drink.bIsDirty, f.drink.bIsBeingConsumed, f.drink.bBeingPicked = false, false, false
    f.drink.bFillTransitionActive, f.drink.bIsPourInProgress = false, false
    function f.drink:IsA(class) return class == f.api.drink or (cocktail and class == f.api.cocktail) end
    function f.drink:IsFull() return self.partial ~= true end
    function f.drink:GetDishQuality() return self.quality end
    function f.drink:GetOrderedForTable() return self.linked or f.table end
    function f.drink:K2_DestroyActor()
        if self.refuse_destroy then return end
        self.destroyed = true
        if f.keep_destroyed_order then return end
        local kept = {}
        for i = 1, #f.manager.DrinksPrepareQueue.Items do
            local entry = f.manager.DrinksPrepareQueue.Items[i]
            if entry.DrinkId.A ~= self.DrinkOrderId.A then kept[#kept+1] = entry end
        end
        f.manager.DrinksPrepareQueue.Items = f.array(kept)
        f.endplays = (f.endplays or 0) + 1
    end
    f.area = f.object('drink-output')
    f.area.OutputSlots = { Items = f.array({{ SlotIndex = 2, Drink = f.drink }}) }
    function f.area:HasSpace() return not f.stuck_output and f.drink.destroyed == true end
    f.drinks_ordered = 0
    function f.manager:TryOrderDrink(data, linked, player)
        assert(data.Key == 17 and linked == f.table and player == nil)
        assert(f.drink.destroyed and f.endplays, 'Must destroy and remove old drink order before remake')
        f.drinks_ordered = f.drinks_ordered + 1
        if f.reject_drink then return end
        local entry = { DrinkId = f.guid(f.drinks_ordered + 200), Drink = data.Key, State = 0,
            LinkedTable = linked, PlayerFloor = 0, bClaimedByPlayer = false }
        self.DrinksPrepareQueue.Items[#self.DrinksPrepareQueue.Items + 1] = entry
        for i = 1, #linked.OrderNotifications do
            local notice = linked.OrderNotifications[i]
            if notice.Drink == data.Key and not notice.bDrinkOrdered then
                notice.bDrinkOrdered, notice.DrinkOrderId = true, f.guid(entry.DrinkId.A)
                break
            end
        end
        if f.throw_after_drink then error('uncertain drink dispatch') end
    end
    f.objects.DrinkManager = {f.manager}
    f.objects.DrinkOutputArea = {f.area}
    f.objects.Drink = {f.drink}
    f.objects.GenericDish[2] = f.drink
    f.objects[cocktail and 'CocktailStation' or 'DrinkDispenser'] = {f.device}
    return f
end
