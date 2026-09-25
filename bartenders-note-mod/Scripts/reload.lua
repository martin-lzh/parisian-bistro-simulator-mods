-- We retain only string identities across Lua restarts. Resolve widgets on the
-- new state's game thread; OnUnload must never touch them from its worker.
local Reload = {}
Reload.__index = Reload

local function identity(widget)
    return widget:GetFullName() .. '@' .. tostring(widget:GetAddress())
end

function Reload.new(key)
    assert(ModRef, 'UE4SS ModRef is unavailable')
    local self = setmetatable({ key = key, widgets = {}, pending = true, stopped = false }, Reload)
    local previous = ModRef:GetSharedVariable(key)
    if type(previous) == 'string' then
        for kind, id in previous:gmatch('([^\t\n]+)\t([^\n]+)\n') do
            self.widgets[kind .. '\t' .. id] = { kind = kind, id = id }
        end
    end
    ModRef.OnUnload = function() self.stopped = true end
    return self
end

function Reload:save()
    local keys = {}
    for key in pairs(self.widgets) do keys[#keys + 1] = key .. '\n' end
    table.sort(keys)
    ModRef:SetSharedVariable(self.key, table.concat(keys))
end

function Reload:remember(kind, widget)
    local id = identity(widget)
    assert(not kind:find('[\t\n]') and not id:find('[\t\n]'), 'Invalid widget identity')
    local token = kind .. '\t' .. id
    self.widgets[token] = { kind = kind, id = id }
    self:save()
    return token
end

function Reload:forget(token)
    self.widgets[token] = nil
    self:save()
end

function Reload:cleanup()
    if not self.pending then return end
    local by_kind = {}
    for _, entry in pairs(self.widgets) do
        by_kind[entry.kind] = by_kind[entry.kind] or {}
        by_kind[entry.kind][entry.id] = true
    end
    for kind, ids in pairs(by_kind) do
        for _, widget in ipairs(FindAllOf(kind) or {}) do
            if widget:IsValid() and ids[identity(widget)] then widget:RemoveFromParent() end
        end
    end
    self.widgets, self.pending = {}, false
    self:save()
end

return Reload
