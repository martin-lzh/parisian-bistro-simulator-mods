local UI = {}
local Game = require('game')
local localize = require('localization')

function UI.destroy(view)
    view.job, view.snapshot, view.busy = nil, nil, false
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
        view.button.TextBlock:SetAutoWrapText(true)
        local slot = parent:AddChildToHorizontalBox(view.button)
        slot:SetPadding({ Left = 12, Top = 0, Right = 0, Bottom = 0 })
        slot:SetSize({ SizeRule = 1, Value = 1 })
        UI.update(view)
    end)
    if not ok then UI.destroy(view); error(err) end
    return view
end

function UI.update(view)
    assert(Game.valid(view.button), 'Menu button was destroyed')
    local words = localize(Game.language())
    local period = view.owner.SelectedDailyMenuPeriod
    if period ~= view.period then view.result, view.remaining = nil, nil end
    view.period = period
    local text = view.busy and string.format(words.searching,
        math.floor(100 * view.job.checked / view.job.total)) or words[view.result or 'button']
    if text ~= view.text then view.button:UpdateText(FText(text)); view.text = text end
    if words.tooltip ~= view.tooltip then
        view.button:SetToolTipText(FText(words.tooltip)); view.tooltip = words.tooltip
    end
    view.button:SetIsInteractionEnabled(Game.available(view.owner))
    if view.remaining and not view.busy then
        view.remaining = view.remaining - 1
        if view.remaining <= 0 then view.result, view.remaining = nil, nil end
    end
end

function UI.result(view, status)
    view.result, view.remaining = status, 6
    UI.update(view)
end

return UI
