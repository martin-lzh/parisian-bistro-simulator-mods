local F = { serial = 0, language = 'en' }
function F.text(value) return { ToString = function() return value end } end
function F.object(class)
    F.serial = F.serial + 1
    local o = { class = class, address = F.serial, children = {}, options = {}, selected = -1,
        visible = true, authority = true, local_controller = true, enabled = true }
    function o:IsValid() return not self.destroyed end
    function o:GetAddress() return self.address end
    function o:GetFullName() return self.class .. self.address end
    function o:IsA(name) return self.class == name end
    function o:HasAnyFlags() return self.template == true end
    function o:GetParent() return self.parent end
    function o:GetChildrenCount() return #self.children end
    function o:GetChildAt(index) return self.children[index + 1] end
    function o:IsVisible() return self.visible end
    function o:IsLocalController() return self.local_controller end
    function o:HasAuthority() return self.authority end
    function o:IsActorBeingDestroyed() return self.destroyed == true end
    function o:GetWorld() return self.world end
    function o:GetOwningPlayer() return self.controller end
    function o:AreAutomaticSmartOrderSettingsLocked() return self.locked == true end
    function o:SetFont(value) self.Font = value end
    function o:SetColorAndOpacity(value) self.color = value end
    function o:SetAutoWrapText(value) self.wrap = value end
    function o:SetText(value) self.text = value end
    function o:SetPadding(value) self.Padding = value end
    function o:SetSize(value) self.Size = value end
    function o:SetHorizontalAlignment(value) self.HorizontalAlignment = value end
    function o:SetVerticalAlignment(value) self.VerticalAlignment = value end
    function o:SetIsEnabled(value) self.enabled = value end
    function o:ClearOptions() self.options = {}; self.selected = -1 end
    function o:AddOption(value) self.options[#self.options + 1] = value end
    function o:SetSelectedIndex(value) self.selected = value end
    function o:GetSelectedIndex() return self.selected end
    function o:RemoveFromParent()
        if not self.parent then return end
        for i, child in ipairs(self.parent.children) do if child == self then table.remove(self.parent.children, i); break end end
        self.parent = nil
    end
    function o:AddChildToVerticalBox(child)
        child:RemoveFromParent()
        self.children[#self.children + 1] = child; child.parent = self
        local slot = F.object('slot')
        slot.Padding = { Left = 3, Top = 4, Right = 5, Bottom = 6 }
        slot.Size = { Value = 1, SizeRule = 0 }
        slot.HorizontalAlignment, slot.VerticalAlignment = 0, 2
        child.Slot = slot
        return slot
    end
    return o
end
function F.owner()
    local owner = F.object('/Game/UI/Computer/Apps/Menu/WBP_MenuApp.WBP_MenuApp_C')
    owner.controller, owner.WidgetTree = F.object('controller'), F.object('tree')
    owner.BoundAutomaticSmartOrderBrasserieManager = F.object('manager')
    owner.controller.world = F.object('world')
    owner.BoundAutomaticSmartOrderBrasserieManager.world = owner.controller.world
    owner.MinimumAutomaticSmartOrderAmountInput = { Font = 'font', ForegroundColor = 'color' }
    owner.OrderAutomationOverlay = F.object('overlay')
    owner.FreeServiceDeliveryButton = { DeliveryName = F.text('Free') }
    owner.EconomicalDeliveryButton = { DeliveryName = F.text('Budget') }
    owner.PremiumDeliveryButton = { DeliveryName = F.text('Premium') }
    owner.SaveAutomaticOrderButton = F.object('save')
    owner.footer, owner.panel = F.object('horizontal'), F.object('/Script/UMG.VerticalBox')
    owner.footer:AddChildToVerticalBox(owner.SaveAutomaticOrderButton)
    owner.panel:AddChildToVerticalBox(F.object('existing settings'))
    owner.panel:AddChildToVerticalBox(owner.footer)
    return owner
end
StaticFindObject = function(path)
    if path:find('KismetInternationalizationLibrary', 1, true) then
        local object = F.object('language')
        function object:GetCurrentLanguage() return F.language end
        return object
    end
    return F.object(path)
end
StaticConstructObject = function(class) return F.object(class.class) end
FText = function(value) return value end
return F
