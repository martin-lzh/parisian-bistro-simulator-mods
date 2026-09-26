local UI = {}
local label = require('localization')
local Settings = require('settings')

function UI.valid(object) return object ~= nil and object:IsValid() end
local function same(a, b) return UI.valid(a) and UI.valid(b) and a:GetAddress() == b:GetAddress() end

local function current_language()
    -- Language lookup is optional; retry on the next update after an English fallback.
    local ok, value = pcall(function()
        local library = StaticFindObject('/Script/Engine.Default__KismetInternationalizationLibrary')
        if not UI.valid(library) then return 'en' end
        local language = library:GetCurrentLanguage()
        return type(language) == 'string' and language or language:ToString()
    end)
    return ok and type(value) == 'string' and value or 'en'
end

function UI.host(owner)
    if not UI.valid(owner) or owner:HasAnyFlags(0x10 | 0x20)
        or not owner:IsA('/Game/UI/Computer/Apps/Menu/WBP_MenuApp.WBP_MenuApp_C') then return false end
    local controller, manager = owner:GetOwningPlayer(), owner.BoundAutomaticSmartOrderBrasserieManager
    return UI.valid(controller) and controller:IsLocalController() and controller:HasAuthority()
        and UI.valid(manager) and manager:HasAuthority() and not manager:IsActorBeingDestroyed()
        and same(manager:GetWorld(), controller:GetWorld())
end

local function create(kind, owner)
    local class = StaticFindObject('/Script/UMG.' .. kind)
    assert(UI.valid(class), 'Missing UMG class: ' .. kind)
    local object = StaticConstructObject(class, owner.WidgetTree)
    assert(UI.valid(object), 'Cannot create delivery selector: ' .. kind)
    return object
end

-- Palette values are sRGB; Slate's specified colors take linear components.
local function color(rgb, alpha)
    local function linear(byte)
        local value = byte / 255
        return value <= 0.04045 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
    end
    return { SpecifiedColor = { R = linear((rgb >> 16) & 255), G = linear((rgb >> 8) & 255),
        B = linear(rgb & 255), A = alpha or 1 }, ColorUseRule = 0 }
end

local function background(brush, rgb, border, radius, alpha)
    -- Use Slate's rounded fill instead of tinting the default textured brush.
    brush.ResourceObject, brush.ResourceName = nil, FName('None')
    brush.DrawAs, brush.ImageType = 4, 0 -- RoundedBox, NoImage
    brush.TintColor = color(rgb, alpha)
    brush.OutlineSettings = {
        CornerRadii = { X = radius, Y = radius, Z = radius, W = radius },
        Color = color(border or rgb), Width = border and 1 or 0,
        RoundingType = 0, bUseBrushTransparency = false,
    }
end

local function style_dropdown(combo)
    -- Apply to this widget before it enters the Slate tree. Keep the native
    -- arrow, font, sounds and interaction behavior; style both text contexts.
    local text, focus = 0xF2F4F3, 0x91B7A0
    combo.ForegroundColor = color(text)
    local control = combo.WidgetStyle.ComboButtonStyle
    local button = control.ButtonStyle
    background(button.Normal, 0x2B342F, 0x697C70, 4)
    background(button.Hovered, 0x3A4740, focus, 4)
    background(button.Pressed, 0x263B2F, focus, 4)
    background(button.Disabled, 0x262D29, 0x465349, 4)
    button.NormalForeground, button.HoveredForeground = color(text), color(text)
    button.PressedForeground, button.DisabledForeground = color(text), color(0xB0BAB3)
    control.DownArrowImage.TintColor = color(text)
    background(control.MenuBorderBrush, 0x232B27, 0x697C70, 4)

    -- FTableRowStyle controls popup text independently of ForegroundColor.
    local item = combo.ItemStyle
    item.TextColor, item.SelectedTextColor = color(text), color(text)
    for _, name in ipairs({ 'EvenRowBackgroundBrush', 'OddRowBackgroundBrush' }) do
        background(item[name], 0x232B27, nil, 0)
    end
    for _, name in ipairs({ 'EvenRowBackgroundHoveredBrush', 'OddRowBackgroundHoveredBrush' }) do
        background(item[name], 0x34433B, nil, 0)
    end
    for _, name in ipairs({ 'ActiveBrush', 'InactiveBrush', 'ActiveHighlightedBrush', 'InactiveHighlightedBrush' }) do
        background(item[name], 0x315A43, nil, 0)
    end
    for _, name in ipairs({ 'ActiveHoveredBrush', 'InactiveHoveredBrush' }) do
        background(item[name], 0x3D6A50, nil, 0)
    end
    background(item.SelectorFocusedBrush, 0, focus, 3, 0)
end

function UI.destroy(view)
    if view and UI.valid(view.row) then view.row:RemoveFromParent() end
    if view and view.lifetime and view.token then
        view.lifetime:forget(view.token)
        view.token = nil
    end
end

function UI.create(owner, lifetime)
    local footer = owner.SaveAutomaticOrderButton:GetParent()
    local parent = footer:GetParent()
    assert(parent:IsA('/Script/UMG.VerticalBox') and same(parent:GetChildAt(parent:GetChildrenCount() - 1), footer),
        'Automatic order dialog layout changed')
    local view = { owner = owner, visible = false, lifetime = lifetime }
    local ok, err = pcall(function()
        view.row = create('VerticalBox', owner)
        if lifetime then view.token = lifetime:remember('VerticalBox', view.row) end
        view.title = create('TextBlock', owner)
        view.title:SetFont(owner.MinimumAutomaticSmartOrderAmountInput.Font)
        view.title:SetColorAndOpacity(owner.MinimumAutomaticSmartOrderAmountInput.ForegroundColor)
        view.title:SetAutoWrapText(true)
        view.combo = create('ComboBoxString', owner)
        view.combo.Font = owner.MinimumAutomaticSmartOrderAmountInput.Font
        style_dropdown(view.combo)
        view.row:AddChildToVerticalBox(view.title):SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 6 })
        view.row:AddChildToVerticalBox(view.combo)
        -- Preserve the native footer's layout and keep Save/Cancel last.
        local slot = footer.Slot
        local p = slot.Padding
        local padding = { Left = p.Left, Top = p.Top, Right = p.Right, Bottom = p.Bottom }
        local size = { Value = slot.Size.Value, SizeRule = slot.Size.SizeRule }
        local horizontal, vertical = slot.HorizontalAlignment, slot.VerticalAlignment
        footer:RemoveFromParent()
        local added, add_error = pcall(function()
            parent:AddChildToVerticalBox(view.row):SetPadding({ Left = 0, Top = 12, Right = 0, Bottom = 16 })
        end)
        local restored = parent:AddChildToVerticalBox(footer)
        restored:SetPadding(padding); restored:SetSize(size)
        restored:SetHorizontalAlignment(horizontal); restored:SetVerticalAlignment(vertical)
        assert(added, add_error)
    end)
    if not ok then UI.destroy(view); error(err) end
    return view
end

local function index(mode)
    for i, value in ipairs(Settings.modes) do if value == mode then return i - 1 end end
    error('Invalid saved delivery method')
end

function UI.update(view, saved, force_reset)
    local owner = view.owner
    assert(UI.valid(view.combo) and UI.valid(view.row), 'Delivery selector was destroyed')
    local visible = owner.OrderAutomationOverlay:IsVisible()
    local language = current_language()
    local texts = {}
    for _, name in ipairs({ 'FreeServiceDeliveryButton', 'EconomicalDeliveryButton', 'PremiumDeliveryButton' }) do
        texts[#texts + 1] = owner[name].DeliveryName:ToString()
        assert(texts[#texts] ~= '', 'Native delivery label unavailable')
    end
    local identity = language .. '\n' .. table.concat(texts, '\n')
    local selected = view.combo:GetSelectedIndex()
    if identity ~= view.language then
        view.combo:ClearOptions()
        for _, text in ipairs(texts) do view.combo:AddOption(text) end
        view.title:SetText(FText(label(language)))
        view.combo:SetSelectedIndex(selected >= 0 and selected or index(saved))
        view.language = identity
    end
    if force_reset or (visible and not view.visible) then view.combo:SetSelectedIndex(index(saved)) end
    view.combo:SetIsEnabled(not owner:AreAutomaticSmartOrderSettingsLocked())
    view.visible = visible
end

function UI.choice(view)
    local choice = Settings.modes[view.combo:GetSelectedIndex() + 1]
    assert(choice, 'No delivery method selected')
    return choice
end

return UI
