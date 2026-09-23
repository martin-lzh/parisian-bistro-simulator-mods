-- Run with Lua 5.4; these mocks verify layout/lifecycle contracts, not rendering.
local source = debug.getinfo(1, 'S').source:sub(2)
local directory = source:match('^(.*[/\\])') or './'
local Hud = dofile(directory .. '../Scripts/hud.lua')
local passed, made, missing = 0, {}, nil
local Methods = {}
local function equal(actual, expected)
    assert(actual == expected, 'expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
end
local function near(actual, expected)
    assert(math.abs(actual - expected) < 0.00001, tostring(actual) .. ' differs from ' .. tostring(expected))
end
local function object(kind, fields)
    fields = fields or {}
    fields.kind = kind
    fields.valid = true
    return setmetatable(fields, { __index = Methods })
end
function Methods:IsValid() return self.valid end
function Methods:IsA(name) return name == '/Script/UMG.' .. self.kind end
function Methods:GetParent() return self.parent end
function Methods:GetVisibility() return self.Visibility or 0 end
function Methods:GetRenderOpacity() return self.RenderOpacity or 1 end
function Methods:GetDesiredSize() return self.desired or { X = 320, Y = 40 } end
function Methods:GetAnchors() return self.Anchors end
function Methods:GetOffsets() return self.Offsets end
function Methods:GetAlignment() return self.Alignment end
function Methods:GetAutoSize() return self.AutoSize or false end
function Methods:GetZOrder() return 7 end
function Methods:RemoveFromParent()
    self.removals = (self.removals or 0) + 1
    if self.parent then
        for i, child in ipairs(self.parent.children or {}) do
            if child == self then table.remove(self.parent.children, i); break end
        end
    end
    self.parent = nil
end
function Methods:SetContent(child)
    self.content = child
    child.parent = self
    return object(self.kind .. 'Slot')
end
function Methods:AddChildToCanvas(child)
    child.parent = self
    self.children[#self.children + 1] = child
    child.Slot = object('CanvasPanelSlot')
    return child.Slot
end
function Methods:SetText(text)
    self.Text = text
    self.text_writes = (self.text_writes or 0) + 1
end
for _, property in ipairs({ 'Visibility', 'RenderOpacity', 'Brush', 'BrushColor', 'ContentColorAndOpacity',
    'Padding', 'HeightOverride', 'Stretch', 'StretchDirection', 'Font', 'ColorAndOpacity', 'AutoWrapText',
    'HorizontalAlignment', 'VerticalAlignment', 'Anchors', 'Offsets', 'Alignment', 'AutoSize', 'ZOrder' }) do
    Methods['Set' .. property] = function(self, value) self[property] = value end
end
function StaticFindObject(path)
    local kind = path:match('%.([^%.]+)$')
    if kind == missing then return object(kind, { valid = false, IsValid = function() return false end }) end
    return object(kind)
end
function StaticConstructObject(class, tree)
    local widget = object(class.kind, { outer = tree })
    made[#made + 1] = widget
    return widget
end
function FText(text) return text end
-- Synthetic fixture preserves the negative-alignment layout case without shipping game data.
local function fixture()
    made, missing = {}, nil
    local canvas = object('CanvasPanel', { children = {} })
    local title = object('Border', {
        parent = canvas,
        Background = { ResourceObject = 'live title brush' },
        BrushColor = { R = 1, G = 1, B = 1, A = 1 },
        ContentColorAndOpacity = { R = 1, G = 1, B = 1, A = 1 },
        Slot = object('CanvasPanelSlot', {
            Anchors = { Minimum = { X = 0.5, Y = 0 }, Maximum = { X = 0.5, Y = 0 } },
            Offsets = { Left = 0, Top = 120, Right = 320, Bottom = 40 },
            Alignment = { X = 0.5, Y = -1 },
        }),
        RenderTransform = { Angle = 0, Scale = { X = 1, Y = 1 }, Translation = { X = 0, Y = -30 } },
    })
    canvas.children[1] = title
    local owner = object('HUD', {
        BrasserieNameBorder = title,
        BrasserieNameTextBlock = object('CommonTextBlock', {
            Font = { FontObject = 'live localized UI font', Size = 18 },
            ColorAndOpacity = { SpecifiedColor = { R = 0.1, G = 0.2, B = 0.1, A = 1 } },
        }),
        WidgetTree = object('WidgetTree'),
    })
    return owner, title, canvas
end
local function test(name, fn)
    local ok, message = pcall(fn)
    assert(ok, name .. ': ' .. tostring(message))
    passed = passed + 1
end

test('native title alignment and translation determine row position', function()
    local owner, title, canvas = fixture()
    local view = Hud.create(owner)
    near(view.slot.Offsets.Top, 177)
    equal(view.slot.Anchors.Minimum.X, 0.25)
    equal(view.slot.Anchors.Maximum.X, 0.75)
    equal(view.root.parent, canvas)
    equal(canvas.children[1], title)
    equal(#canvas.children, 2)
    title.Slot.Offsets.Top = 200
    title.Slot.Alignment.X = 0
    title.RenderTransform.Translation.X = 8
    Hud.update(view, 'Coffee x 2')
    near(view.slot.Offsets.Top, 257)
    near(view.slot.Offsets.Left, 168)
    near(view.slot.Offsets.Right, -168)
end)

test('empty rows stay collapsed and title visibility governs populated rows', function()
    local owner, title = fixture()
    local view = Hud.create(owner)
    equal(view.root.Visibility, 1)
    Hud.update(view, '')
    equal(view.root.Visibility, 1)
    Hud.update(view, 'Tea x 1')
    equal(view.root.Visibility, 3) -- No hit testing for this widget or children.
    title.Visibility = 1
    Hud.update(view, 'Tea x 1')
    equal(view.root.Visibility, 1)
    title.Visibility = 2
    Hud.update(view, 'Tea x 1')
    equal(view.root.Visibility, 1)
    title.Visibility, title.RenderOpacity = 4, 0.35
    Hud.update(view, 'Tea x 1')
    equal(view.root.Visibility, 3)
    equal(view.root.RenderOpacity, 0.35)
    Hud.update(view, nil)
    equal(view.root.Visibility, 1)
end)

test('unchanged reconciliation avoids text resets but refreshes localized font', function()
    local owner = fixture()
    local view = Hud.create(owner)
    Hud.update(view, 'Coffee x 2')
    local replacement_font = { FontObject = 'new locale', Size = 18 }
    owner.BrasserieNameTextBlock.Font = replacement_font
    Hud.update(view, 'Coffee x 2')
    equal(view.text.text_writes, 1)
    equal(view.text.Font, replacement_font)
    Hud.update(view, '')
    Hud.update(view, 'Coffee x 2')
    equal(view.text.text_writes, 1)
    equal(view.root.Visibility, 3)
    Hud.update(view, 'Coffee x 3')
    equal(view.text.text_writes, 2)
end)

test('long localized row remains single-line and can only scale down', function()
    local owner = fixture()
    local view = Hud.create(owner)
    local text = string.rep('Long localized drink x 99   ', 12)
    Hud.update(view, text)
    equal(view.text.Text, text)
    equal(view.text.AutoWrapText, false)
    local scale = view.text.parent
    equal(scale.kind, 'ScaleBox')
    equal(scale.Stretch, 2)
    equal(scale.StretchDirection, 1)
    equal(view.root.Brush, owner.BrasserieNameBorder.Background)
    equal(view.root.BrushColor, owner.BrasserieNameBorder.BrushColor)
    equal(view.root.ContentColorAndOpacity, owner.BrasserieNameBorder.ContentColorAndOpacity)
    equal(view.text.ColorAndOpacity, owner.BrasserieNameTextBlock.ColorAndOpacity)
    for _, widget in ipairs(made) do equal(widget.outer, owner.WidgetTree) end
end)

test('unsupported layout cleans attached root and preserves native widgets', function()
    local owner, title, canvas = fixture()
    title.RenderTransform.Scale.Y = 2
    local ok = pcall(Hud.create, owner)
    equal(ok, false)
    equal(#canvas.children, 1)
    equal(canvas.children[1], title)
    equal(made[1].removals, 1)
end)

test('construction failure cleans partial root without touching native children', function()
    local owner, title, canvas = fixture()
    missing = 'TextBlock'
    local ok = pcall(Hud.create, owner)
    equal(ok, false)
    equal(#canvas.children, 1)
    equal(canvas.children[1], title)
    equal(made[1].removals, 1)
end)

test('destroy is idempotent and makes detached views invalid', function()
    local owner, title, canvas = fixture()
    local view = Hud.create(owner)
    equal(Hud.valid(view), true)
    Hud.destroy(view)
    equal(Hud.valid(view), false)
    equal(#canvas.children, 1)
    equal(canvas.children[1], title)
    Hud.destroy(view)
    equal(view.root.removals, 1)
    equal(pcall(Hud.update, view, 'Coffee x 1'), false)
end)

test('stale source text or slot rejects further use', function()
    local owner = fixture()
    local view = Hud.create(owner)
    owner.BrasserieNameTextBlock.valid = false
    equal(Hud.valid(view), false)
    owner.BrasserieNameTextBlock.valid = true
    view.slot.valid = false
    equal(Hud.valid(view), false)
end)
print('HUD: ' .. passed .. ' tests passed')
