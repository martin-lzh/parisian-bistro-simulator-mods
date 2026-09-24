local Hint, Fakes, Localization = require('hint'), require('fakes'), require('localization')
local obj = Fakes.object
FName = function(text) return { ToString = function() return text end } end
FText = function(text) return text end
local key_class = obj('key-class')
local controller, owner, panel = obj('controller'), obj('hud'), obj('panel')
owner.RightInteractionsKeys, owner.WidgetTree = panel, obj('tree')
function owner:GetOwningPlayer() return controller end
function owner:IsInViewport() return not self.removed end
function panel:GetChildrenCount() return #self.children end
function panel:GetChildAt(index) return self.children[index + 1] end
function panel:AddChild(widget) self.children[#self.children + 1] = widget; widget.parent = self end
panel.children = {}
local native = obj('native-wheel', key_class)
native.KeyName, native.visibility = FName('OpenInteractionWheel'), 3
function native:GetVisibility() return self.visibility end
function native:SetVisibility(v) self.visibility = v end
panel:AddChild(native)
local click = obj('native-click', key_class)
click.KeyName = FName('Click')
function click:SetVisibility() error('Do not hide short-click hint') end
panel:AddChild(click)
local creations, actions = 0, {}
local function widget()
    local result = obj('hint-' .. creations, key_class)
    function result:SetAction(key, text, position)
        assert(key:ToString() == 'OpenInteractionWheel' and position == 1)
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
    local result = obj('wrapper-' .. creations)
    function result:SetBrushColor(color) assert(color.A == 0) end
    function result:SetPadding(padding) assert(padding.Bottom == 8) end
    function result:SetVisibility(v) assert(v == 3) end
    function result:SetContent(child) self.child = child end
    function result:GetParent() return self.parent end
    function result:RemoveFromParent()
        for i, child in ipairs(panel.children) do if child == self then table.remove(panel.children, i); break end end
        self.parent = nil
    end
    return result
end
FindAllOf = function() return { owner } end
local hint, session = Hint.new(), { controller = controller }
hint:update(session, true)
assert(creations == 1 and actions[1] == '长按：优先拿取最早制作的餐品')
assert(native.visibility == 1 and #panel.children == 3)
hint:update(session, true)
assert(creations == 1 and #actions == 1, 'No widget recreation or repeated text assignment')
language = 'fr-FR'; hint:update(session, true)
assert(#actions == 2 and actions[2] == Localization.hint('fr'))
hint:update(nil, false)
assert(native.visibility == 3 and #panel.children == 2, 'Restore native wheel and remove only owned row')
hint:update(session, true)
assert(creations == 2)
owner.removed = true; hint:update(session, true)
assert(not hint.wrapper and native.visibility == 3)
local languages = { 'en', 'fr', 'zh-Hans', 'zh-Hant', 'it', 'es', 'de', 'ru', 'ja', 'ko', 'tr', 'pl', 'pt', 'pt-BR' }
for _, code in ipairs(languages) do assert(#Localization.hint(code) > 0) end
assert(Localization.hint('zh-Hans-TW') == Localization.hint('zh-CN'))
assert(Localization.hint('zh-TW') == Localization.hint('zh-Hant'))
assert(Localization.hint(nil) == Localization.hint('en'))
