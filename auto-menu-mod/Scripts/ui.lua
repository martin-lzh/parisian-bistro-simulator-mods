local UI = {}
local Game = require('game')
local localize = require('localization')

function UI.destroy(view)
    if Game.valid(view.button) then view.button:RemoveFromParent() end
    if view.token then view.lifetime:forget(view.token); view.token = nil end
end

function UI.create(owner, lifetime)
    local parent = owner.PrintMenuButton:GetParent()
    assert(Game.valid(parent) and parent:IsA('/Script/UMG.HorizontalBox'), 'Daily menu footer changed')
    local library = StaticFindObject('/Script/UMG.Default__WidgetBlueprintLibrary')
    assert(Game.valid(library), 'Widget creation library unavailable')
    local view = { owner = owner, lifetime = lifetime }
    local ok, err = pcall(function()
        -- Create the native button class at runtime; no game assets are bundled.
        view.button = library:Create(owner, owner.PrintMenuButton:GetClass(), owner:GetOwningPlayer())
        assert(Game.valid(view.button), 'Cannot create menu button')
        view.token = lifetime:remember('WBP_ComputerClassicButton_C', view.button)
        view.button:SetIsSelectable(false)
        view.button:SetIsToggleable(false)
        view.button:SetIsFocusable(true)
        view.button:SetShouldUseFallbackDefaultInputAction(false)
        view.button.TextBlock:SetAutoWrapText(false)
        local slot = parent:AddChildToHorizontalBox(view.button)
        slot:SetPadding({ Left = 12, Top = 0, Right = 0, Bottom = 0 })
        -- Reserve the full single-line label width, including localized text.
        slot:SetSize({ SizeRule = 0, Value = 1 })
        UI.update(view)
    end)
    if not ok then UI.destroy(view); error(err) end
    return view
end

function UI.update(view)
    assert(Game.valid(view.button), 'Menu button was destroyed')
    local words = localize(Game.language())
    local text = words.button
    if text ~= view.text then view.button:UpdateText(FText(text)); view.text = text end
    if words.tooltip ~= view.tooltip then
        view.button:SetToolTipText(FText(words.tooltip)); view.tooltip = words.tooltip
    end
    local enabled = Game.available(view.owner)
    if enabled ~= view.enabled then
        view.button:SetIsInteractionEnabled(enabled); view.enabled = enabled
    end
end

return UI
