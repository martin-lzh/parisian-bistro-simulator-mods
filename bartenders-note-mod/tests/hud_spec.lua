-- Synthetic font metrics exercise layout/lifecycle behavior, not Slate rendering.
local source = debug.getinfo(1, 'S').source:sub(2)
local directory = source:match('^(.*[/\\])') or './'
package.path = directory .. '../Scripts/?.lua;' .. package.path
local Hud = dofile(directory .. '../Scripts/hud.lua')
local Localization = require('localization')
local passed, made, missing, metrics = 0, {}, nil, {}
local Methods = {}
local function equal(actual, expected)
    assert(actual == expected, 'expected ' .. tostring(expected) .. ', got ' .. tostring(actual))
end
local function near(actual, expected)
    assert(math.abs(actual - expected) < 0.00001, tostring(actual) .. ' differs from ' .. tostring(expected))
end
local function object(kind, fields)
    fields = fields or {}; fields.kind = kind; fields.valid = true
    return setmetatable(fields, { __index = Methods })
end
local function measured(text, font)
    local width, maximum, lines = 0, 0, 1
    for _, code in utf8.codes(text) do
        if code == 10 then maximum = math.max(maximum, width); width = 0; lines = lines + 1
        else width = width + font.Size * (code > 255 and 1 or 0.5) * metrics.width end
    end
    return { X = math.max(maximum, width), Y = lines * (font.Size * 1.3 + metrics.leading) }
end
function Methods:IsValid() return self.valid end
function Methods:IsA(name) return name == '/Script/UMG.' .. self.kind end
function Methods:GetParent() return self.parent end
function Methods:GetVisibility() return self.Visibility or 0 end
function Methods:GetRenderOpacity() return self.RenderOpacity or 1 end
function Methods:ForceLayoutPrepass()
    self.prepasses = (self.prepasses or 0) + 1
    self.measured_text = self.Text
end
function Methods:GetDesiredSize()
    if self.kind == 'TextBlock' then
        assert(self.prepasses and self.measured_text == self.Text, 'text measured before a layout prepass')
        assert(self.parent and self.parent.prepasses, 'probe canvas was never laid out')
        assert(self.Visibility ~= 1, 'collapsed text cannot be measured')
        if metrics.zero then return { X = 0, Y = 0 } end
        return measured(self.Text, self.Font)
    end
    return self.desired or { X = 320, Y = 40 }
end
function Methods:GetViewportSize(owner) return { X = owner.viewport, Y = 1080 } end
function Methods:GetViewportScale(owner) return owner.dpi end
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
    self.content = child; child.parent = self
    return object(self.kind .. 'Slot')
end
function Methods:AddChildToCanvas(child)
    child.parent = self; self.children[#self.children + 1] = child
    child.Slot = object('CanvasPanelSlot')
    return child.Slot
end
function Methods:SetText(text)
    self.Text = text; self.text_writes = (self.text_writes or 0) + 1
end
for _, property in ipairs({ 'Visibility', 'RenderOpacity', 'Brush', 'BrushColor', 'ContentColorAndOpacity',
    'Padding', 'HeightOverride', 'Font', 'ColorAndOpacity', 'AutoWrapText', 'Clipping', 'Justification',
    'HorizontalAlignment', 'VerticalAlignment', 'Anchors', 'Offsets', 'Alignment', 'AutoSize', 'ZOrder' }) do
    Methods['Set' .. property] = function(self, value) self[property] = value end
end
function StaticFindObject(path)
    local kind = path:match('%.([^%.]+)$')
    if kind == missing then return object(kind, { IsValid = function() return false end }) end
    return object(kind)
end
function StaticConstructObject(class, tree)
    local widget = object(class.kind, { outer = tree }); made[#made + 1] = widget
    return widget
end
function FText(text) return text end
local function fixture()
    made, missing, metrics = {}, nil, { width = 1, leading = 0 }
    local canvas = object('CanvasPanel', { children = {} })
    local title = object('Border', {
        parent = canvas, Background = { ResourceObject = 'synthetic live brush' },
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
        viewport = 1920, dpi = 1, BrasserieNameBorder = title,
        BrasserieNameTextBlock = object('CommonTextBlock', {
            Font = { FontObject = 'synthetic localized font', Size = 18 },
            ColorAndOpacity = { SpecifiedColor = { R = 0.1, G = 0.2, B = 0.1, A = 1 } },
        }), WidgetTree = object('WidgetTree'),
    })
    return owner, title, canvas
end
local function group(name, count) return { name = name, count = count or 1 } end
local function bounded(view, owner)
    local width = owner.viewport / owner.dpi * (view.slot.Anchors.Maximum.X - view.slot.Anchors.Minimum.X)
    local available = width - view.root.Padding.Left - view.root.Padding.Right
    local lines = 0
    for line in view.text.Text:gmatch('[^\n]+') do
        lines = lines + 1
        assert(measured(line, view.text.Font).X <= available, 'text extends into fade margins')
    end
    assert(lines >= 1 and lines <= 2, 'banner must contain at most two lines')
    local height = math.max(24 * lines, measured(view.text.Text, view.text.Font).Y)
    near(view.size.HeightOverride, height)
    near(view.slot.Offsets.Bottom, height + 10)
    return lines
end
local function test(name, fn)
    local ok, message = pcall(fn); assert(ok, name .. ': ' .. tostring(message)); passed = passed + 1
end

test('native title position and native children survive attachment', function()
    local owner, title, canvas = fixture(); local view = Hud.create(owner)
    near(view.slot.Offsets.Top, 177); near(view.slot.Anchors.Minimum.X, 0.25)
    near(view.slot.Anchors.Maximum.X, 0.75); equal(#canvas.children, 3)
    equal(canvas.children[1], title); equal(view.root.parent, canvas); equal(view.probe.parent, canvas)
    equal(view.probe.Visibility, 2); assert(canvas.prepasses)
    title.Slot.Offsets.Top = 200; title.Slot.Alignment.X = 0; title.RenderTransform.Translation.X = 8
    Hud.update(view, { group('Coffee', 2) })
    near(view.slot.Offsets.Top, 257); near(view.slot.Offsets.Left, 168); near(view.slot.Offsets.Right, -168)
end)

test('empty and hidden native title suppress the banner', function()
    local owner, title = fixture(); local view = Hud.create(owner)
    equal(view.root.Visibility, 1); Hud.update(view, {}); equal(view.root.Visibility, 1)
    for _, visibility in ipairs({ 0, 1, 2, 4 }) do
        title.Visibility, title.RenderOpacity = visibility, 0.35
        Hud.update(view, { group('Tea') })
        equal(view.root.Visibility, (visibility == 1 or visibility == 2) and 1 or 3)
        equal(view.root.RenderOpacity, 0.35)
    end
    Hud.update(view, nil); equal(view.root.Visibility, 1); equal(view.probe.Visibility, 2)
end)

test('short content keeps native styling and readable unscaled font', function()
    local owner = fixture(); local view = Hud.create(owner)
    Hud.update(view, { group('Coffee', 2), group('茶', 3) })
    equal(bounded(view, owner), 1); equal(view.text.AutoWrapText, false)
    equal(view.text.Font, owner.BrasserieNameTextBlock.Font); equal(view.probe.Font, view.text.Font)
    equal(view.size.Clipping, 1); equal(view.root.Brush, owner.BrasserieNameBorder.Background)
    equal(view.text.ColorAndOpacity, owner.BrasserieNameTextBlock.ColorAndOpacity)
    near(view.root.Padding.Left, 172.8); near(view.root.Padding.Right, 172.8)
    for _, widget in ipairs(made) do assert(widget.kind ~= 'ScaleBox'); equal(widget.outer, owner.WidgetTree) end
end)

test('whole groups move to second line without squeezing', function()
    local owner = fixture(); local view = Hud.create(owner)
    Hud.update(view, { group(string.rep('A', 32)), group(string.rep('B', 32)) })
    equal(bounded(view, owner), 2); assert(not view.text.Text:find('more', 1, true))
    equal(view.text.Font.Size, 18)
end)

test('excess groups yield an accurate bounded overflow marker', function()
    local owner = fixture(); local view = Hud.create(owner); local groups = {}
    for i = 1, 8 do groups[i] = group(string.rep(string.char(64 + i), 32)) end
    Hud.update(view, groups); bounded(view, owner)
    local shown = 0
    for _, item in ipairs(groups) do if view.text.Text:find(item.name .. ' x 1', 1, true) then shown = shown + 1 end end
    assert(shown < #groups); assert(view.text.Text:find('... + ' .. (#groups - shown) .. ' more', 1, true))
end)

test('same groups reflow after viewport and DPI changes', function()
    local owner = fixture(); local view = Hud.create(owner)
    local groups = { group(string.rep('A', 20)), group(string.rep('B', 20)) }
    Hud.update(view, groups); equal(bounded(view, owner), 1)
    owner.viewport = 1200; Hud.update(view, groups); equal(bounded(view, owner), 2)
    owner.viewport, owner.dpi = 2400, 2; Hud.update(view, groups); equal(bounded(view, owner), 2)
    owner.dpi = 1; Hud.update(view, groups); equal(bounded(view, owner), 1)
end)

test('all game languages remeasure overflow in the current native font', function()
    local owner = fixture(); local view = Hud.create(owner); local groups = {}
    for index = 1, 8 do groups[index] = group(string.rep(string.char(64 + index), 32)) end
    for _, language in ipairs({ 'en', 'fr', 'zh-Hans', 'it', 'es', 'de', 'ru',
        'ja', 'ko', 'zh-Hant', 'tr', 'pl', 'pt', 'pt-BR' }) do
        owner.BrasserieNameTextBlock.Font = { FontObject = 'synthetic ' .. language, Size = 18 }
        Hud.update(view, groups, language)
        bounded(view, owner)
        equal(view.text.Font, owner.BrasserieNameTextBlock.Font)
        equal(view.probe.Font, view.text.Font)
        local shown = 0
        for _, item in ipairs(groups) do
            if view.text.Text:find(item.name .. ' x 1', 1, true) then shown = shown + 1 end
        end
        assert(shown < #groups)
        assert(view.text.Text:find(Localization.more(#groups - shown, language), 1, true))
    end
    Hud.update(view, groups, 'en')
    local writes = view.text.text_writes
    Hud.update(view, groups, 'zh-Hans')
    equal(view.text.text_writes, writes + 1)
    Hud.update(view, groups, 'zh-Hans')
    equal(view.text.text_writes, writes + 1)
end)

test('same groups respond to font widths and taller line spacing', function()
    local owner = fixture(); local view = Hud.create(owner)
    local groups = { group(string.rep('A', 20)), group(string.rep('B', 20)) }
    Hud.update(view, groups); equal(bounded(view, owner), 1)
    metrics.width, metrics.leading = 1.5, 18
    Hud.update(view, groups); equal(bounded(view, owner), 2)
    assert(view.size.HeightOverride > 48)
    local font = { FontObject = 'replacement locale', Size = 14 }
    owner.BrasserieNameTextBlock.Font = font; Hud.update(view, groups)
    equal(view.text.Font, font); equal(view.probe.Font, font); equal(bounded(view, owner), 1)
end)

test('unchanged content does not reset visible text, including empty interval', function()
    local owner = fixture(); local view = Hud.create(owner); local groups = { group('Coffee', 2) }
    Hud.update(view, groups); Hud.update(view, groups); equal(view.text.text_writes, 1)
    Hud.update(view, {}); Hud.update(view, groups); equal(view.text.text_writes, 1)
    Hud.update(view, { group('Coffee', 3) }); equal(view.text.text_writes, 2)
end)

test('narrow banners reserve minimum edge space and hide when no marker fits', function()
    local owner = fixture(); local view = Hud.create(owner)
    owner.viewport = 500; Hud.update(view, { group('Tea') })
    near(view.root.Padding.Left, 56); near(view.root.Padding.Right, 56); bounded(view, owner)
    owner.viewport = 240; Hud.update(view, { group('Tea') }); equal(view.root.Visibility, 1)
    owner.viewport = 100; Hud.update(view, { group('Tea') }); equal(view.root.Visibility, 1)
end)

test('zero viewport hides safely and unavailable font measurement fails closed', function()
    local owner = fixture(); local view = Hud.create(owner); local groups = { group('Tea') }
    owner.viewport = 0; Hud.update(view, groups); equal(view.root.Visibility, 1)
    owner.viewport = 1920; metrics.zero = true
    equal(pcall(Hud.update, view, groups), false); equal(view.root.Visibility, 1)
    metrics.zero = false; Hud.update(view, groups); equal(view.root.Visibility, 3)
end)

test('unsupported title layout removes both owned canvas children', function()
    local owner, title, canvas = fixture(); title.RenderTransform.Scale.Y = 2
    equal(pcall(Hud.create, owner), false); equal(#canvas.children, 1); equal(canvas.children[1], title)
    local removed = 0
    for _, widget in ipairs(made) do removed = removed + (widget.removals or 0) end
    equal(removed, 2)
end)

test('construction failure preserves native children', function()
    local owner, title, canvas = fixture(); missing = 'TextBlock'
    equal(pcall(Hud.create, owner), false); equal(#canvas.children, 1); equal(canvas.children[1], title)
    equal(made[1].removals, 1)
end)

test('destroy removes root and probe once and prevents reuse', function()
    local owner, title, canvas = fixture(); local view = Hud.create(owner)
    equal(Hud.valid(view), true); Hud.destroy(view); equal(Hud.valid(view), false)
    equal(#canvas.children, 1); equal(canvas.children[1], title); Hud.destroy(view)
    equal(view.root.removals, 1); equal(view.probe.removals, 1)
    equal(pcall(Hud.update, view, { group('Coffee') }), false)
end)

test('reload records both owned canvas widgets and forgets them after destruction', function()
    local owner = fixture()
    local recorded, forgotten = {}, {}
    local lifetime = {
        remember = function(_, kind, widget) recorded[kind] = widget; return kind end,
        forget = function(_, token) forgotten[token] = true end,
    }
    local view = Hud.create(owner, lifetime)
    equal(recorded.Border, view.root); equal(recorded.TextBlock, view.probe)
    Hud.destroy(view)
    equal(forgotten.Border, true); equal(forgotten.TextBlock, true)
end)

test('stale source, slot or measurement widget rejects further use', function()
    local owner = fixture(); local view = Hud.create(owner)
    for _, widget in ipairs({ owner.BrasserieNameTextBlock, view.slot, view.probe }) do
        widget.valid = false; equal(Hud.valid(view), false); widget.valid = true
    end
end)
print('HUD: ' .. passed .. ' tests passed')
