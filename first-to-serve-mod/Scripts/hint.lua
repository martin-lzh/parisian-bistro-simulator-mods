-- Use the game's actual interaction-key widget, including its device/remap
-- handling, font, icon and layout. No copied game assets are packaged.
local Hint = {}
Hint.__index = Hint
local Localization = require('localization')
local CLASS = '/Game/UI/HUD/WBP_InteractionKey.WBP_InteractionKey_C'
local KEY, CLICK = 'OpenInteractionWheel', 'Click'
local CENTER, COLLAPSED, HIT_TEST_INVISIBLE = 2, 1, 3
local RESTORE = 'FirstToServe.HiddenWheelRows'

local function valid(object) return object ~= nil and object:IsValid() end
local function same(a, b) return valid(a) and valid(b) and a:GetAddress() == b:GetAddress() end
local function identity(widget) return widget:GetFullName() .. '@' .. tostring(widget:GetAddress()) end

local function current_language()
    -- A temporary language failure must not stop pickup or retain a stale locale.
    local ok, value = pcall(function()
        local library = StaticFindObject('/Script/Engine.Default__KismetInternationalizationLibrary')
        if not valid(library) then return 'en' end
        local language = library:GetCurrentLanguage()
        return type(language) == 'string' and language or language:ToString()
    end)
    return ok and type(value) == 'string' and value or 'en'
end

local function visible(widget)
    -- A row's own visibility can stay unchanged while its parent is hidden.
    while valid(widget) do
        local visibility = widget:GetVisibility()
        if visibility == 1 or visibility == 2 then return false end
        widget = widget:GetParent()
    end
    return true
end

local function pickup_row(owner, key_class)
    -- Only the native contextual pickup panel owns this hint. In particular,
    -- persistent sidebar Click rows must never serve as a fallback anchor.
    local panel = owner.CenterInteractionsKeys
    if not valid(panel) or not visible(panel) or not visible(owner) then return nil end
    local found
    for index = 0, panel:GetChildrenCount() - 1 do
        local child = panel:GetChildAt(index)
        if valid(child) and child:IsA(key_class) and child.KeyName:ToString() == CLICK and visible(child) then
            if found then return nil end
            found = child
        end
    end
    return found, panel
end

local function place_below(panel, anchor, wrapper)
    if same(panel:GetChildAt(panel:GetChildIndex(anchor) + 1), wrapper) then return end
    wrapper:RemoveFromParent()
    -- This build exposes no runtime insert function. Reattach only the rows
    -- after the click hint, preserving their order and vertical slot settings.
    -- Keep the native click row a direct child so native removal still works.
    local tail = {}
    for index = panel:GetChildIndex(anchor) + 1, panel:GetChildrenCount() - 1 do
        local child = panel:GetChildAt(index)
        local slot = child.Slot
        assert(valid(slot), 'Native hint slot unavailable')
        tail[#tail + 1] = { widget = child,
            padding = { Left = slot.Padding.Left, Top = slot.Padding.Top,
                Right = slot.Padding.Right, Bottom = slot.Padding.Bottom },
            size = { Value = slot.Size.Value, SizeRule = slot.Size.SizeRule },
            horizontal = slot.HorizontalAlignment, vertical = slot.VerticalAlignment }
    end
    local ok, err = pcall(function()
        for _, row in ipairs(tail) do row.widget:RemoveFromParent() end
        assert(valid(panel:AddChild(wrapper)), 'Could not attach hold hint')
    end)
    -- Even a failed insertion must put detached native rows back.
    for _, row in ipairs(tail) do
        if not same(row.widget:GetParent(), panel) then
            local restored, restore_err = pcall(function()
                local slot = panel:AddChildToVerticalBox(row.widget)
                slot:SetPadding(row.padding)
                slot:SetSize(row.size)
                slot:SetHorizontalAlignment(row.horizontal)
                slot:SetVerticalAlignment(row.vertical)
            end)
            if not restored then ok, err = false, restore_err end
        end
    end
    if not ok then error(err, 0) end
end

function Hint.new()
    local restores = {}
    -- Shared scalars survive loader reload; transient UObjects must not.
    local saved = ModRef and ModRef:GetSharedVariable(RESTORE)
    if type(saved) == 'string' then
        for id, visibility in saved:gmatch('([^\t\n]+)\t([0-4])\n') do restores[id] = tonumber(visibility) end
    end
    return setmetatable({ hidden = {}, restores = restores }, Hint)
end

function Hint:save_restores()
    if not ModRef then return end
    local rows = {}
    for id, visibility in pairs(self.restores) do rows[#rows + 1] = id .. '\t' .. visibility .. '\n' end
    ModRef:SetSharedVariable(RESTORE, table.concat(rows))
end

function Hint:clear()
    if valid(self.wrapper) then self.wrapper:RemoveFromParent() end
    for _, entry in ipairs(self.hidden) do
        if valid(entry.widget) then entry.widget:SetVisibility(entry.visibility) end
        self.restores[entry.id] = nil
    end
    if #self.hidden > 0 then self:save_restores() end
    self.owner, self.wrapper, self.widget, self.text, self.hidden = nil, nil, nil, nil, {}
end

local function owned_row(widget, key_class)
    return valid(widget) and widget:IsA(key_class) and widget.KeyName:ToString() == KEY
        and widget.Text ~= nil and Localization.is_hint(widget.Text:ToString())
end

function Hint:prune(owner, key_class)
    local border_class = StaticFindObject('/Script/UMG.Border')
    local restored = false
    -- Reload destroys Lua state, but widgets can outlive it. Recognize only
    -- our exact localized wording + key + widget type, including legacy
    -- sidebar wrappers. Never remove unrelated native interaction rows.
    for _, name in ipairs({ 'CenterInteractionsKeys', 'RightInteractionsKeys', 'LeftInteractionsKeys' }) do
        local panel = owner[name]
        if valid(panel) then
            for index = panel:GetChildrenCount() - 1, 0, -1 do
                local row = panel:GetChildAt(index)
                if valid(row) and not same(row, self.wrapper) then
                    local content = row
                    if valid(border_class) and row:IsA(border_class) then content = row:GetContent() end
                    if owned_row(content, key_class) then row:RemoveFromParent() end
                    if row:IsA(key_class) and row.KeyName:ToString() == KEY then
                        local id = identity(row)
                        local own = false
                        for _, entry in ipairs(self.hidden) do if entry.id == id then own = true end end
                        if not own and self.restores[id] ~= nil then
                            row:SetVisibility(self.restores[id])
                            self.restores[id], restored = nil, true
                        end
                    end
                end
            end
        end
    end
    if restored then self:save_restores() end
end

function Hint:update(session, show)
    local key_class = StaticFindObject(CLASS)
    if not valid(key_class) then self:clear(); return end
    local owner
    for _, hud in ipairs(FindAllOf('WBP_HUD_C') or {}) do
        if valid(hud) and not hud:HasAnyFlags(0x10 | 0x20) then
            local controller = hud:GetOwningPlayer()
            if valid(controller) and controller:IsLocalController() then self:prune(hud, key_class) end
            if session and same(controller, session.controller) and hud:IsInViewport() then
                if owner then self:clear(); return end
                owner = hud
            end
        end
    end
    if not session or not show then self:clear(); return end
    if not valid(owner) then self:clear(); return end
    local anchor, panel = pickup_row(owner, key_class)
    if not valid(anchor) then self:clear(); return end
    if not same(owner, self.owner) or not valid(self.widget) or not valid(self.wrapper) then
        self:clear()
        self.owner = owner
        local library = StaticFindObject('/Script/UMG.Default__WidgetBlueprintLibrary')
        assert(valid(library), 'WidgetBlueprintLibrary unavailable')
        self.widget = library:Create(owner, key_class, session.controller)
        assert(valid(self.widget), 'Native interaction-key widget unavailable')
        -- The wrapper gives the mod ownership of this row. Native key-removal
        -- routines inspect direct children and cannot remove our mapped key.
        self.wrapper = StaticConstructObject(StaticFindObject('/Script/UMG.Border'), owner.WidgetTree)
        assert(valid(self.wrapper), 'Hint container unavailable')
        self.wrapper:SetBrushColor({ R = 0, G = 0, B = 0, A = 0 })
        self.wrapper:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 8 })
        self.wrapper:SetVisibility(HIT_TEST_INVISIBLE)
        self.wrapper:SetContent(self.widget)
    end
    place_below(panel, anchor, self.wrapper)
    local text = Localization.hint(current_language())
    if self.text ~= text then
        self.widget:SetAction(FName(KEY), FText(text), CENTER)
        self.text = text
    end
    -- Preserve the click row and sidebar; restore the contextual wheel row
    -- on leaving the item.
    for index = 0, panel:GetChildrenCount() - 1 do
        local child = panel:GetChildAt(index)
        if valid(child) and child:IsA(key_class) and child.KeyName:ToString() == KEY then
            local known = false
            for _, entry in ipairs(self.hidden) do if same(entry.widget, child) then known = true end end
            if not known then
                local id, visibility = identity(child), child:GetVisibility()
                self.hidden[#self.hidden + 1] = { widget = child, visibility = visibility, id = id }
                self.restores[id] = visibility
                self:save_restores()
            end
            child:SetVisibility(COLLAPSED)
        end
    end
end

return Hint
