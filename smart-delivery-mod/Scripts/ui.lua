local UI = {}
local label = require('localization')
local Settings = require('settings')

function UI.valid(object) return object ~= nil and object:IsValid() end
local function same(a, b) return UI.valid(a) and UI.valid(b) and a:GetAddress() == b:GetAddress() end

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

function UI.destroy(view)
    if view and UI.valid(view.row) then view.row:RemoveFromParent() end
end

function UI.create(owner)
    local footer = owner.SaveAutomaticOrderButton:GetParent()
    local parent = footer:GetParent()
    assert(parent:IsA('/Script/UMG.VerticalBox') and same(parent:GetChildAt(parent:GetChildrenCount() - 1), footer),
        'Automatic order dialog layout changed')
    local view = { owner = owner, visible = false }
    local ok, err = pcall(function()
        view.row = create('VerticalBox', owner)
        view.title = create('TextBlock', owner)
        view.title:SetFont(owner.MinimumAutomaticSmartOrderAmountInput.Font)
        view.title:SetColorAndOpacity(owner.MinimumAutomaticSmartOrderAmountInput.ForegroundColor)
        view.title:SetAutoWrapText(true)
        view.combo = create('ComboBoxString', owner)
        view.combo.Font = owner.MinimumAutomaticSmartOrderAmountInput.Font
        -- Use an explicit color for the selected value and generated options.
        view.combo.ForegroundColor = {
            SpecifiedColor = { R = 1, G = 1, B = 1, A = 1 }, ColorUseRule = 0,
        }
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
    local library = StaticFindObject('/Script/Engine.Default__KismetInternationalizationLibrary')
    local language = UI.valid(library) and library:GetCurrentLanguage() or 'en'
    if type(language) ~= 'string' then language = language:ToString() end
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
