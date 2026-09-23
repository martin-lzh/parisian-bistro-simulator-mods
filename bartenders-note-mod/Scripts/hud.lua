-- Original Bartender's Note HUD. All entry points must run on the game thread.
local Hud = {}
local HIT_TEST_INVISIBLE, COLLAPSED, HIDDEN = 3, 1, 2

local function alive(object)
    return object ~= nil and object:IsValid()
end

local function construct(class_name, tree)
    local class = StaticFindObject('/Script/UMG.' .. class_name)
    assert(alive(class), 'Missing UMG class: ' .. class_name)
    local widget = StaticConstructObject(class, tree)
    assert(alive(widget), 'Could not create UMG widget: ' .. class_name)
    widget:SetVisibility(HIT_TEST_INVISIBLE)
    return widget
end

function Hud.valid(view)
    return view ~= nil and not view.destroyed and alive(view.owner) and alive(view.title)
        and alive(view.source_text) and alive(view.root) and alive(view.text) and alive(view.slot)
end

function Hud.destroy(view)
    if view and not view.destroyed then
        if alive(view.root) then view.root:RemoveFromParent() end
        view.destroyed = true
    end
end

-- The native title uses a fixed-height canvas slot, including a negative Y
-- alignment and a render translation. Read those values instead of duplicating
-- a screen coordinate. X stretch anchors keep the row responsive to resizing.
local function position(view)
    local title_slot = view.title.Slot
    local anchors = title_slot:GetAnchors()
    local offset = title_slot:GetOffsets()
    local alignment = title_slot:GetAlignment()
    assert(anchors.Minimum.Y == anchors.Maximum.Y and anchors.Minimum.X == anchors.Maximum.X,
        'Unsupported stretched restaurant title layout')
    local transform = view.title.RenderTransform
    assert(transform.Angle == 0 and transform.Scale.X == 1 and transform.Scale.Y == 1,
        'Unsupported transformed restaurant title layout')
    local center = (anchors.Minimum.X + anchors.Maximum.X) / 2
    local height = title_slot:GetAutoSize() and view.title:GetDesiredSize().Y or offset.Bottom
    local bottom = offset.Top + height * (1 - alignment.Y) + transform.Translation.Y
    local half_width = math.min(0.25, center - 0.025, 0.975 - center)
    assert(half_width > 0, 'Restaurant title is outside the HUD safe area')
    view.slot:SetAnchors({ Minimum = { X = center - half_width, Y = anchors.Minimum.Y },
        Maximum = { X = center + half_width, Y = anchors.Minimum.Y } })
    view.slot:SetAlignment({ X = 0, Y = 0 })
    local width = title_slot:GetAutoSize() and view.title:GetDesiredSize().X or offset.Right
    local x = offset.Left + width * (0.5 - alignment.X) + transform.Translation.X
    view.slot:SetOffsets({ Left = x, Top = bottom + 7, Right = -x, Bottom = 34 })
    view.slot:SetAutoSize(false)
    view.slot:SetZOrder(title_slot:GetZOrder())
end

function Hud.create(owner)
    assert(alive(owner), 'HUD is unavailable')
    local title, source_text, tree = owner.BrasserieNameBorder, owner.BrasserieNameTextBlock, owner.WidgetTree
    assert(alive(title) and alive(source_text) and alive(tree), 'Restaurant title is unavailable')
    local parent = title:GetParent()
    assert(alive(parent) and parent:IsA('/Script/UMG.CanvasPanel'), 'Restaurant title parent changed')
    local view = { owner = owner, title = title, source_text = source_text }
    local ok, err = pcall(function()
        view.root = construct('Border', tree)
        view.root:SetVisibility(COLLAPSED)
        view.root:SetBrush(title.Background)
        view.root:SetBrushColor(title.BrushColor)
        view.root:SetContentColorAndOpacity(title.ContentColorAndOpacity)
        view.root:SetPadding({ Left = 14, Top = 5, Right = 14, Bottom = 5 })
        local size = construct('SizeBox', tree)
        size:SetHeightOverride(24)
        view.root:SetContent(size)
        local scale = construct('ScaleBox', tree)
        scale:SetStretch(2) -- ScaleToFit
        scale:SetStretchDirection(1) -- DownOnly
        size:SetContent(scale)
        view.text = construct('TextBlock', tree)
        view.text:SetFont(source_text.Font)
        view.text:SetColorAndOpacity(source_text.ColorAndOpacity)
        view.text:SetAutoWrapText(false)
        local text_slot = scale:SetContent(view.text)
        text_slot:SetHorizontalAlignment(2) -- Center
        text_slot:SetVerticalAlignment(2) -- Center
        view.slot = parent:AddChildToCanvas(view.root)
        position(view)
    end)
    if not ok then Hud.destroy(view); error(err) end
    return view
end

-- Empty state is collapsed. Visibility comes from the native restaurant banner;
-- sharing its canvas also inherits HUD and fullscreen-switcher visibility.
function Hud.update(view, text)
    assert(Hud.valid(view), 'HUD was destroyed')
    if text == nil or text == '' then
        view.root:SetVisibility(COLLAPSED)
        return
    end
    view.text:SetFont(view.source_text.Font)
    view.text:SetColorAndOpacity(view.source_text.ColorAndOpacity)
    if view.last_text ~= text then
        view.text:SetText(FText(text))
        view.last_text = text
    end
    position(view)
    local visibility = view.title:GetVisibility()
    view.root:SetVisibility((visibility == HIDDEN or visibility == COLLAPSED) and COLLAPSED or HIT_TEST_INVISIBLE)
    view.root:SetRenderOpacity(view.title:GetRenderOpacity())
end

return Hud
