local F = {}
local Planner = require('planner')

function F.array(entries)
    return {
        entries = entries, IsValid = function() return true end,
        GetArrayNum = function() return #entries end,
        ForEach = function(_, callback)
            for i, entry in ipairs(entries) do callback(i, { get = function() return entry end }) end
        end,
    }
end

function F.setup()
    local state = { objects = {}, hooks = {}, ticks = {}, loops = {}, shared = {}, saves = 0,
        projections = 0, prices = {}, language = 'en' }
    local function object(kind)
        local value = { address = #state.objects + 1, kind = kind, valid = true }
        state.objects[#state.objects + 1] = value
        function value:IsValid() return self.valid end
        function value:GetAddress() return self.address end
        function value:GetFullName() return self.kind .. ' Object' .. self.address end
        function value:IsA(path) return path:find(self.kind, 1, true) ~= nil end
        function value:HasAnyFlags() return self.template or false end
        function value:GetWorld() return state.world end
        return value
    end
    state.object = object
    state.world = object('World')
    local player = object('PlayerController')
    player.IsLocalController = function() return state.remote ~= true end
    player.HasAuthority = function() return state.client ~= true end
    local manager = object('BrasserieManager')
    manager.HasAuthority = function() return state.client ~= true end
    manager.IsActorBeingDestroyed = function() return state.destroying == true end
    manager.GetDailyMenuMaximumPromotedAdoptionChance = function() return state.ceiling or 1 end
    manager.DailyMenuInfluence, manager.DailyMenuInfluenceHalfLifeGameHours, manager.Satisfaction = 0, 12, 1
    manager.GetDailyMenuInfluence = function(self)
        -- Synthetic clock drift, not an implementation of the game's formula.
        return self.DailyMenuInfluenceHalfLifeGameHours == 0 and self.DailyMenuInfluence
            or math.max(0, self.DailyMenuInfluence - (state.decay or 0))
    end
    manager.GetTier = function() return state.tier or 0 end
    manager.GetDifficulty = function() return 0 end
    manager.GetSatisfaction = function(self) return self.Satisfaction end
    manager.GetDishPrice = function(_, id) return state.prices[id] or 10 end
    manager.DailyMenuMaxAdoptionChanceBonus = 0.2
    for _, name in ipairs({ 'AvailableDishes', 'UnlockedDailyDishes', 'DisabledDishes', 'EmployeeRequirementDisabledDishes' }) do
        manager[name] = F.array({})
    end
    local function forecast(period, profile, intent)
        return { Period = period, ProfileProbabilities = F.array({ { Profile = profile, Probability = 1 } }),
            IntentProbabilities = F.array({ { Intent = intent, Probability = 1 } }) }
    end
    manager.DailyCustomerContext = { DayNumber = 7, WeekDay = 0, TemperatureCelsius = 20, LocalEvent = 0, TemperatureBand = 1,
        LunchForecast = forecast(1, 0, 0), DinnerForecast = forecast(2, 1, 5) }
    for period, name in ipairs({ 'LunchDailyMenu', 'DinnerDailyMenu' }) do
        manager[name] = { Period = period, bIsActive = true }
        for _, course in ipairs(Planner.courses) do manager[name][course.field] = 0 end
    end
    state.manager = manager
    local owner = object('WBP_MenuApp_C')
    state.owner = owner
    owner.BoundDailyMenuBrasserieManager = manager
    owner.SelectedDailyMenuPeriod = 1
    owner.GetOwningPlayer = function() return player end
    owner.IsVisible = function() return state.hidden ~= true end
    owner.IsShowingDailyMenuCategory = function() return state.other_page ~= true end
    owner.IsDishMissingIngredients = function(_, id) return id == state.missing end
    function owner:GetDailyMenu(period)
        return manager[period == 1 and 'LunchDailyMenu' or 'DinnerDailyMenu']
    end
    function owner:GetDailyMenuProjection(period)
        state.projections = state.projections + 1
        local menu = self:GetDailyMenu(period)
        local copied = {}; for key, value in pairs(menu) do copied[key] = value end
        if state.projection_error then error('Synthetic projection failure') end
        local configured = false
        for _, course in ipairs(Planner.courses) do configured = configured or menu[course.field] ~= 0 end
        if not configured then return { Period = period, bConfigured = false, EstimatedAdoptionRate = 0 } end
        if state.oracle then return { Period = period, bConfigured = true, EstimatedAdoptionRate = state.oracle(copied) } end
        -- Invented non-additive objective, deliberately unrelated to dish tags.
        local target = period == 1 and 21 or 20
        local rate = menu.MainDish == target and menu.Starter == 11 and 0.8 or 0.1
        return { Period = period, bConfigured = true, EstimatedAdoptionRate = rate }
    end
    owner.RefreshDailyMenus = function()
        state.refreshes = (state.refreshes or 0) + 1
    end
    function owner:SaveDailyMenu(menu)
        state.saves = state.saves + 1
        if state.on_save then state.on_save() end
        if state.reject then return end
        local copied = {}
        for k, v in pairs(menu) do copied[k] = v end
        manager[menu.Period == 1 and 'LunchDailyMenu' or 'DinnerDailyMenu'] = copied
    end
    for index, course in ipairs(Planner.courses) do
        local row = object('DailyMenu')
        local selector = object('DishSelector')
        selector.DishOptions = F.array({
            { Key = index * 10, DishType = course.kind, bEnabled = true },
            { Key = index * 10 + 1, DishType = course.kind, bEnabled = true },
        })
        row.WBP_DailyMenu_DishSelector = selector
        owner['WBP_DailyMenu_' .. course.field] = row
    end
    local footer = object('HorizontalBox')
    footer.children = {}
    function footer:AddChildToHorizontalBox(button)
        button.parent = self; self.children[#self.children + 1] = button
        return { SetPadding = function() end, SetSize = function() end }
    end
    state.footer = footer
    local function button()
        local value = object('WBP_ComputerClassicButton_C')
        value.TextBlock = { SetAutoWrapText = function() end }
        for _, method in ipairs({ 'SetIsSelectable', 'SetIsToggleable', 'SetIsFocusable',
            'SetShouldUseFallbackDefaultInputAction' }) do value[method] = function() end end
        function value:SetIsInteractionEnabled(enabled) self.enabled = enabled end
        function value:IsInteractionEnabled() return self.enabled end
        function value:UpdateText(text) self.text = text end
        function value:SetToolTipText(text) self.tooltip = text end
        function value:GetClass() return object('Class') end
        function value:GetParent() return self.parent end
        function value:RemoveFromParent()
            if self.parent then
                for i, child in ipairs(self.parent.children) do
                    if child == self then table.remove(self.parent.children, i); break end
                end
            end
            self.parent = nil
        end
        return value
    end
    owner.PrintMenuButton = button()
    footer:AddChildToHorizontalBox(owner.PrintMenuButton)
    local library = object('Library')
    library.Create = function() return button() end
    library.GetCurrentLanguage = function() return state.language end
    StaticFindObject = function() return library end
    FText = function(text) return text end
    FindAllOf = function(kind)
        local result = {}
        for _, value in ipairs(state.objects) do if value.kind == kind then result[#result + 1] = value end end
        return result
    end
    ModRef = {
        GetSharedVariable = function(_, key) return state.shared[key] end,
        SetSharedVariable = function(_, key, value) assert(type(value) == 'string'); state.shared[key] = value end,
    }
    RegisterHook = function(path, pre, post)
        assert(path == '/Script/CommonUI.CommonButtonBase:HandleButtonClicked')
        state.hooks[#state.hooks + 1] = post
        return #state.hooks, #state.hooks
    end
    LoopInGameThreadWithDelay = function(ms, fn)
        assert(ms == 500 or ms == 16)
        state.ticks[#state.ticks + 1] = fn; state.loops[ms] = fn
    end
    function state:complete()
        for _ = 1, 1000 do
            self.loops[16]()
            if self.footer.children[2] and not self.footer.children[2].text:find('%d+%%') then return end
        end
        error('Search did not complete')
    end
    function state:click(value, index)
        self.hooks[index or #self.hooks]({ get = function() return value end })
    end
    return state
end

return F
