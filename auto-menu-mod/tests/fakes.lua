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
        language = 'en' }
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
    for _, name in ipairs({ 'AvailableDishes', 'DisabledDishes', 'EmployeeRequirementDisabledDishes' }) do
        manager[name] = F.array({})
    end
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
    owner.RefreshDailyMenus = function()
        state.refreshes = (state.refreshes or 0) + 1
    end
    function owner:SaveDailyMenu(menu)
        state.saves = state.saves + 1
        if state.on_save then state.on_save() end
        if state.reject then return end
        local copied, empty = Planner.copy(menu), true
        for _, course in ipairs(Planner.courses) do empty = empty and copied[course.field] == 0 end
        if empty then copied.bIsActive = false end
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
        table.insert(manager.AvailableDishes.entries, index * 10)
        table.insert(manager.AvailableDishes.entries, index * 10 + 1)
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
        assert(ms == 500, 'Only widget discovery needs a timer')
        state.ticks[#state.ticks + 1] = fn; state.loops[ms] = fn
    end
    function state:click(value, index)
        self.hooks[index or #self.hooks]({ get = function() return value end })
    end
    require('bridge').solve = function(_, _, storage, period, original, domains, courses)
        state.request = { domains = domains, original = original, period = period }
        if state.native_override then return state.native_override(storage, original, domains) end
        if state.projection_error then error('Synthetic native failure') end
        local menu, count = Planner.copy(original), 1
        menu.Period = period
        for _, course in ipairs(courses) do
            local ids = domains[course.field]
            count = count * #ids
            local wanted = course.field == 'MainDish' and (period == 1 and 21 or 20) or 0
            menu[course.field] = ids[1]
            for _, id in ipairs(ids) do if id == wanted then menu[course.field] = id; break end end
        end
        return { menu = menu, rate = state.ceiling or 0.8, evaluations = state.ceiling and 1 or count,
            combinations = count, cache = { hits = count, misses = 2, bypasses = 0, checks = count + 1, seconds = 0.01 } }
    end
    return state
end

return F
