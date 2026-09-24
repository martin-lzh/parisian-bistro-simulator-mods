-- Original Bartender's Note HUD. All entry points must run on the game thread.
local Hud = {}
local Layout = require('layout')
local HIT_TEST_INVISIBLE, COLLAPSED, HIDDEN = 3, 1, 2
local EDGE_PADDING_FRACTION, MIN_EDGE_PADDING = 0.18, 56
local VERTICAL_PADDING, MIN_LINE_HEIGHT = 5, 24

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
        and alive(view.probe) and alive(view.size)
end

function Hud.destroy(view)
    if view and not view.destroyed then
        if alive(view.root) then view.root:RemoveFromParent() end
        if alive(view.probe) then view.probe:RemoveFromParent() end
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
    view.slot:SetOffsets({ Left = x, Top = bottom + 7, Right = -x,
        Bottom = (view.content_height or MIN_LINE_HEIGHT) + 2 * VERTICAL_PADDING })
    view.slot:SetAutoSize(false)
    view.slot:SetZOrder(title_slot:GetZOrder())
    return half_width * 2
end

local function available_width(view, width_fraction)
    local library = StaticFindObject('/Script/UMG.Default__WidgetLayoutLibrary')
    assert(alive(library), 'WidgetLayoutLibrary is unavailable')
    -- The restaurant title canvas fills the viewport. Use reflected FVector2D
    -- and scalar results; opaque FGeometry cannot round-trip through Lua tables.
    local viewport = library:GetViewportSize(view.owner)
    local scale = library:GetViewportScale(view.owner)
    if not viewport or type(viewport.X) ~= 'number' or not (viewport.X > 0 and viewport.X < math.huge)
        or type(scale) ~= 'number' or not (scale > 0 and scale < math.huge) then return 0 end
    local width = viewport.X / scale * width_fraction
    local padding = math.max(MIN_EDGE_PADDING, width * EDGE_PADDING_FRACTION)
    view.root:SetPadding({ Left = padding, Top = VERTICAL_PADDING,
        Right = padding, Bottom = VERTICAL_PADDING })
    return math.max(0, width - 2 * padding)
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
        view.root:SetHorizontalAlignment(0) -- Fill the padded content area.
        view.size = construct('SizeBox', tree)
        view.size:SetHeightOverride(MIN_LINE_HEIGHT)
        view.size:SetClipping(1) -- ClipToBounds: never paint inside the fade margins.
        view.root:SetContent(view.size)
        view.text = construct('TextBlock', tree)
        view.text:SetFont(source_text.Font)
        view.text:SetColorAndOpacity(source_text.ColorAndOpacity)
        view.text:SetAutoWrapText(false)
        view.text:SetJustification(1) -- ETextJustify::Center
        local text_slot = view.size:SetContent(view.text)
        text_slot:SetHorizontalAlignment(2) -- Center
        text_slot:SetVerticalAlignment(2) -- Center
        view.slot = parent:AddChildToCanvas(view.root)
        -- Hidden participates in Slate layout without painting or hit testing.
        -- Keep the measuring widget outside the collapsible banner so an empty
        -- list cannot prevent measuring the next list's localized text.
        view.probe = construct('TextBlock', tree)
        view.probe:SetVisibility(HIDDEN)
        view.probe:SetAutoWrapText(false)
        local probe_slot = parent:AddChildToCanvas(view.probe)
        probe_slot:SetAutoSize(true)
        parent:ForceLayoutPrepass()
        position(view)
    end)
    if not ok then Hud.destroy(view); error(err) end
    return view
end

-- Empty state is collapsed. Visibility comes from the native restaurant banner;
-- sharing its canvas also inherits HUD and fullscreen-switcher visibility.
function Hud.update(view, groups, language)
    assert(Hud.valid(view), 'HUD was destroyed')
    if groups == nil or #groups == 0 then
        view.root:SetVisibility(COLLAPSED)
        return
    end
    view.text:SetFont(view.source_text.Font)
    view.text:SetColorAndOpacity(view.source_text.ColorAndOpacity)
    view.probe:SetFont(view.source_text.Font)
    local width = available_width(view, position(view))
    if width <= 0 then
        view.root:SetVisibility(COLLAPSED)
        return
    end
    -- Cache measurements only within this refresh: locale, font and viewport
    -- changes must reflow even if the order quantities are unchanged.
    local sizes = {}
    local function measure(text)
        if not sizes[text] then
            view.probe:SetText(FText(text))
            view.probe:ForceLayoutPrepass()
            local size = view.probe:GetDesiredSize()
            assert(size.X > 0 and size.X < math.huge and size.Y > 0 and size.Y < math.huge,
                'Text measurement is not ready')
            sizes[text] = { X = size.X, Y = size.Y }
        end
        return sizes[text].X
    end
    local layout = Layout.format(groups, width, measure, language)
    local text = layout.text
    if text == '' then
        view.root:SetVisibility(COLLAPSED)
        return
    end
    -- Measure the complete multiline result, including the font's line spacing.
    measure(text)
    view.content_height = math.max(MIN_LINE_HEIGHT * #layout.lines, sizes[text].Y)
    view.size:SetHeightOverride(view.content_height)
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
