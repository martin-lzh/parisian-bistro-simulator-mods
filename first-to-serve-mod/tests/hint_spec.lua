local Hint, Fakes, Localization = require('hint'), require('fakes'), require('localization')
local obj = Fakes.object
FName = function(text) return { ToString = function() return text end } end
FText = function(text) return text end
local key_class = obj('key-class')
local controller, owner = obj('controller'), obj('hud')
local function parented(result)
    function result:GetParent() return self.parent end
    function result:GetVisibility() return self.visibility or 3 end
    function result:RemoveFromParent()
        if self.parent then
            for i, child in ipairs(self.parent.children) do
                if child == self then table.remove(self.parent.children, i); break end
            end
        end
        self.parent, self.Slot = nil, nil
    end
    return result
end
local function new_panel(name)
    local result = parented(obj(name))
    result.children, result.additions = {}, 0
    function result:GetChildrenCount() return #self.children end
    function result:GetChildAt(index) return self.children[index + 1] end
    function result:GetChildIndex(widget)
        for i, child in ipairs(self.children) do if child == widget then return i - 1 end end
        return -1
    end
    function result:AddChild(widget)
        assert(not widget.parent, 'Detach before attaching')
        if self.fail_add then self.fail_add = false; error('Cannot add row') end
        self.children[#self.children + 1] = widget; widget.parent = self
        self.additions = self.additions + 1
        local slot = obj('slot-' .. self.additions)
        slot.Padding, slot.Size = { Left = 0, Top = 0, Right = 0, Bottom = 0 }, { Value = 1, SizeRule = 0 }
        slot.HorizontalAlignment, slot.VerticalAlignment = 0, 0
        function slot:SetPadding(v) self.Padding = v end
        function slot:SetSize(v) self.Size = v end
        function slot:SetHorizontalAlignment(v) self.HorizontalAlignment = v end
        function slot:SetVerticalAlignment(v) self.VerticalAlignment = v end
        widget.Slot = slot
        return slot
    end
    result.AddChildToVerticalBox = result.AddChild
    return result
end
local panel, right = new_panel('center-panel'), new_panel('right-panel')
parented(owner)
owner.CenterInteractionsKeys, owner.RightInteractionsKeys, owner.WidgetTree = panel, right, obj('tree')
function owner:GetOwningPlayer() return controller end
function owner:IsInViewport() return not self.removed end
local native = parented(obj('native-wheel', key_class))
native.KeyName, native.visibility = FName('OpenInteractionWheel'), 3
function native:GetVisibility() return self.visibility end
function native:SetVisibility(v) self.visibility = v end
panel:AddChild(native)
local click = parented(obj('native-click', key_class))
click.KeyName, click.visibility = FName('Click'), 3
function click:GetVisibility() return self.visibility end
function click:SetVisibility() error('Do not hide short-click hint') end
panel:AddChild(click)
local trailing = parented(obj('native-release', key_class))
trailing.KeyName = FName('Release')
panel:AddChild(trailing)
trailing.Slot:SetPadding({ Left = 1, Top = 2, Right = 3, Bottom = 4 })
trailing.Slot:SetSize({ Value = 2, SizeRule = 1 })
trailing.Slot:SetHorizontalAlignment(2)
trailing.Slot:SetVerticalAlignment(3)
local creations, actions = 0, {}
local function widget()
    local result = obj('hint-' .. creations, key_class)
    function result:SetAction(key, text, position)
        assert(key:ToString() == 'OpenInteractionWheel' and position == 2)
        actions[#actions + 1] = text
    end
    return result
end
local library = obj('library')
function library:Create(hud, class, player)
    assert(hud == owner and class == key_class and player == controller)
    creations = creations + 1; return widget()
end
local language, culture = 'zh-CN', obj('culture')
function culture:GetCurrentLanguage() return language end
StaticFindObject = function(path)
    if path:find('WBP_InteractionKey', 1, true) then return key_class end
    if path:find('WidgetBlueprintLibrary', 1, true) then return library end
    if path:find('KismetInternationalizationLibrary', 1, true) then return culture end
    return obj(path)
end
StaticConstructObject = function(_, tree)
    assert(tree == owner.WidgetTree)
    local result = parented(obj('wrapper-' .. creations))
    function result:SetBrushColor(color) assert(color.A == 0) end
    function result:SetPadding(padding) assert(padding.Bottom == 8) end
    function result:SetVisibility(v) assert(v == 3) end
    function result:SetContent(child) self.child = child end
    return result
end
FindAllOf = function() return { owner } end
-- A permanent Click row in the sidebar must not anchor or duplicate the hint.
local sidebar_click = parented(obj('sidebar-click', key_class))
sidebar_click.KeyName = FName('Click')
function sidebar_click:SetVisibility() error('Do not modify sidebar hints') end
right:AddChild(sidebar_click)
local sidebar_wheel = parented(obj('sidebar-wheel', key_class))
sidebar_wheel.KeyName = FName('OpenInteractionWheel')
function sidebar_wheel:SetVisibility() error('Do not modify sidebar hints') end
right:AddChild(sidebar_wheel)
local sidebar_additions = right.additions
local hint, session = Hint.new(), { controller = controller }
click.visibility = 1
hint:update(session, true)
assert(creations == 0 and native.visibility == 3, 'No hold hint without a visible click hint')
click.visibility = 3
hint:update(session, true)
assert(creations == 1 and actions[1] == '长按：优先拿取最早制作的餐品')
assert(native.visibility == 1 and #panel.children == 4)
assert(panel.children[2] == click and panel.children[3] == hint.wrapper and panel.children[4] == trailing,
    'Place directly below pickup, before other hints')
assert(trailing.Slot.Padding.Bottom == 4 and trailing.Slot.Padding.Left == 1
    and trailing.Slot.Size.Value == 2 and trailing.Slot.Size.SizeRule == 1
    and trailing.Slot.HorizontalAlignment == 2 and trailing.Slot.VerticalAlignment == 3,
    'Keep native row slot layout')
local additions = panel.additions
hint:update(session, true)
assert(creations == 1 and #actions == 1, 'No widget recreation or repeated text assignment')
assert(panel.additions == additions, 'Stable hints must not reattach any rows')
language = 'fr-FR'; hint:update(session, true)
assert(#actions == 2 and actions[2] == Localization.hint('fr'))
-- Native refresh removes and appends the click row; follow its new position.
click:RemoveFromParent(); panel:AddChild(click)
hint:update(session, true)
assert(panel.children[3] == click and panel.children[4] == hint.wrapper and creations == 1)
-- A hidden native panel must clear the hint even when its Click row stays visible.
panel.visibility = 1
hint:update(session, true)
assert(not hint.wrapper and native.visibility == 3 and #panel.children == 3)
panel.visibility = 3; hint:update(session, true)
assert(creations == 2 and hint.wrapper:GetParent() == panel)
local overlay = parented(obj('center-overlay'))
panel.parent, overlay.visibility = overlay, 2
hint:update(session, true)
assert(not hint.wrapper, 'Hidden ancestors cannot leave a persistent hint')
overlay.visibility = 3; hint:update(session, true)
owner.visibility = 1; hint:update(session, true)
assert(not hint.wrapper, 'Hiding the HUD clears the owned row')
owner.visibility = 3; hint:update(session, true)
hint:update(nil, false)
assert(native.visibility == 3 and #panel.children == 3,
    'Restore native wheel and remove only owned row')
hint:update(session, true)
click:RemoveFromParent(); hint:update(session, true)
assert(not hint.wrapper and native.visibility == 3, 'Remove hold hint when native pickup row disappears')
assert(#right.children == 2 and right.additions == sidebar_additions, 'Never fall back to the sidebar')
panel:AddChild(click)
hint:update(session, true)
owner.removed = true; hint:update(session, true)
assert(not hint.wrapper and native.visibility == 3)
owner.removed = false
-- Restore detached native rows if adding the owned row fails.
trailing:RemoveFromParent(); panel:AddChild(trailing)
trailing.Slot:SetPadding({ Left = 1, Top = 2, Right = 3, Bottom = 4 })
panel.fail_add = true
assert(not pcall(function() hint:update(session, true) end))
hint:clear()
assert(panel.children[1] == native and panel.children[2] == click and panel.children[3] == trailing)
assert(trailing.Slot.Padding.Bottom == 4 and native.visibility == 3)
assert(#right.children == 2 and right.additions == sidebar_additions, 'Sidebar remains untouched throughout')
local languages = { 'en', 'fr', 'zh-Hans', 'zh-Hant', 'it', 'es', 'de', 'ru', 'ja', 'ko', 'tr', 'pl', 'pt', 'pt-BR' }
for _, code in ipairs(languages) do assert(#Localization.hint(code) > 0) end
assert(Localization.hint('zh-Hans-TW') == Localization.hint('zh-CN'))
assert(Localization.hint('zh-TW') == Localization.hint('zh-Hant'))
assert(Localization.hint(nil) == Localization.hint('en'))
