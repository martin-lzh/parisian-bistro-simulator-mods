-- Use the game's actual interaction-key widget, including its device/remap
-- handling, font, icon and layout. No copied game assets are packaged.
local Hint = {}
Hint.__index = Hint
local Localization = require('localization')
local CLASS = '/Game/UI/HUD/WBP_InteractionKey.WBP_InteractionKey_C'
local KEY = 'OpenInteractionWheel'
local RIGHT, COLLAPSED, HIT_TEST_INVISIBLE = 1, 1, 3

local function valid(object) return object ~= nil and object:IsValid() end
local function same(a, b) return valid(a) and valid(b) and a:GetAddress() == b:GetAddress() end

function Hint.new() return setmetatable({ hidden = {} }, Hint) end

function Hint:clear()
    if valid(self.wrapper) then self.wrapper:RemoveFromParent() end
    for _, entry in ipairs(self.hidden) do
        if valid(entry.widget) then entry.widget:SetVisibility(entry.visibility) end
    end
    self.owner, self.wrapper, self.widget, self.text, self.hidden = nil, nil, nil, nil, {}
end

function Hint:update(session, show)
    if not session or not show then self:clear(); return end
    local owner
    for _, hud in ipairs(FindAllOf('WBP_HUD_C') or {}) do
        if valid(hud) and not hud:HasAnyFlags(0x10 | 0x20)
            and same(hud:GetOwningPlayer(), session.controller) and hud:IsInViewport() then
            if owner then self:clear(); return end
            owner = hud
        end
    end
    if not valid(owner) or not valid(owner.RightInteractionsKeys) then self:clear(); return end
    local key_class = StaticFindObject(CLASS)
    if not valid(key_class) then self:clear(); return end
    if not same(owner, self.owner) or not valid(self.widget) or not valid(self.wrapper)
        or not same(self.wrapper:GetParent(), owner.RightInteractionsKeys) then
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
        owner.RightInteractionsKeys:AddChild(self.wrapper)
    end
    local library = StaticFindObject('/Script/Engine.Default__KismetInternationalizationLibrary')
    local language = valid(library) and library:GetCurrentLanguage() or 'en'
    if type(language) ~= 'string' then language = language:ToString() end
    local text = Localization.hint(language)
    if self.text ~= text then
        self.widget:SetAction(FName(KEY), FText(text), RIGHT)
        self.text = text
    end
    -- This gesture replaces the wheel only at supported pickup surfaces. Keep
    -- the normal click hint and restore the wheel row on leaving the surface.
    for index = 0, owner.RightInteractionsKeys:GetChildrenCount() - 1 do
        local child = owner.RightInteractionsKeys:GetChildAt(index)
        if valid(child) and child:IsA(key_class) and child.KeyName:ToString() == KEY then
            local known = false
            for _, entry in ipairs(self.hidden) do if same(entry.widget, child) then known = true end end
            if not known then self.hidden[#self.hidden + 1] = { widget = child, visibility = child:GetVisibility() } end
            child:SetVisibility(COLLAPSED)
        end
    end
end

return Hint
