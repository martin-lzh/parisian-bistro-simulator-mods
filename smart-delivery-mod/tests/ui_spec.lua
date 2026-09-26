local F, UI = require('fakes'), require('ui')
local owner = F.owner()
assert(UI.host(owner))
local view = UI.create(owner)
UI.update(view, 'premium', true)
assert(#owner.panel.children == 3 and owner.panel.children[3] == owner.footer)
assert(owner.footer.Slot.Padding.Top == 4 and owner.footer.Slot.VerticalAlignment == 2)
assert(view.title.Font == 'font' and view.combo.Font == 'font')
assert(UI.choice(view) == 'premium' and table.concat(view.combo.options, ',') == 'Free,Budget,Premium')
view.combo:SetSelectedIndex(0)
UI.update(view, 'premium')
assert(UI.choice(view) == 'free') -- polling keeps an unsaved choice
F.language = 'zh-Hans'; owner.FreeServiceDeliveryButton.DeliveryName = F.text('免费服务')
UI.update(view, 'premium')
assert(view.title.text == '配送方式' and UI.choice(view) == 'free')
assert(view.combo.options[1] == '免费服务')
-- A failed locale read must keep the native options and the player's unsaved choice.
local find_object = StaticFindObject
local function fallback_then_recover()
    UI.update(view, 'premium')
    assert(view.title.text == 'Delivery method' and UI.choice(view) == 'free')
    assert(view.combo.options[1] == '免费服务' and view.row:GetParent() == owner.panel)
    StaticFindObject, F.language = find_object, F.text('ja')
    UI.update(view, 'premium')
    assert(view.title.text == '配送方法' and UI.choice(view) == 'free')
end
for _, value in ipairs({ false, {}, F.text({}),
    { ToString = function() error('Language conversion unavailable') end } }) do
    F.language = value
    fallback_then_recover()
end
F.language = nil
fallback_then_recover()
for _, invalid in ipairs({ false, true }) do
    StaticFindObject = function(path)
        if path:find('KismetInternationalizationLibrary', 1, true) then
            if not invalid then return nil end
            local library = F.object('language'); library.destroyed = true; return library
        end
        return find_object(path)
    end
    fallback_then_recover()
end
print('UI locale recovery: invalid values and unavailable libraries preserve native options and draft selection')
UI.update(view, 'premium', true)
assert(UI.choice(view) == 'premium') -- native reset discards draft
view.combo:SetSelectedIndex(1)
owner.OrderAutomationOverlay.visible = false; UI.update(view, 'premium')
owner.OrderAutomationOverlay.visible = true; UI.update(view, 'premium')
assert(UI.choice(view) == 'premium')
owner.locked = true; UI.update(view, 'premium'); assert(not view.combo.enabled)
owner.controller.authority = false; assert(not UI.host(owner))
owner.controller.authority = true; owner.controller.local_controller = false; assert(not UI.host(owner))
owner.controller.local_controller = true
owner.BoundAutomaticSmartOrderBrasserieManager.world = F.object('another world'); assert(not UI.host(owner))
UI.destroy(view)
assert(#owner.panel.children == 2 and owner.panel.children[2] == owner.footer)
owner = F.owner(); owner.panel:AddChildToVerticalBox(F.object('new footer'))
assert(not pcall(UI.create, owner)) -- unknown layout is untouched
assert(#owner.panel.children == 3)
