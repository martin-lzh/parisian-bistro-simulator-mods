-- Keep diagnostics independent of Unreal objects and suppress unchanged polls.
local Diagnostics = {}
Diagnostics.__index = Diagnostics
Diagnostics.VERSION = '0.1.2'

function Diagnostics.new(write)
    return setmetatable({ write = write, observed = {} }, Diagnostics)
end

function Diagnostics:log(event, message)
    self.write('[AutoCheckout] ' .. event .. ' ' .. message)
end

function Diagnostics:observe(key, message, tick)
    local previous = self.observed[key]
    if not previous or previous.message ~= message or tick - previous.tick >= 30 then
        self.observed[key] = { message = message, tick = tick }
        self:log('STATE', key .. ' ' .. message)
    end
end

function Diagnostics:prune(present)
    for key in pairs(self.observed) do
        if not present[key] then self.observed[key] = nil end
    end
end

function Diagnostics.snapshot(s)
    return string.format(
        'register=%s dishes=%s method=%s raw_method=%s payment=%s bill=%s drawer=%s moving=%s handled=%s card_in_machine=%s paid=%s blocked=%s',
        s.id, tostring(s.dish_count), tostring(s.method), tostring(s.raw_method), s.payment_id or 'none',
        tostring(s.has_bill), tostring(s.drawer_open), tostring(s.moving), tostring(s.being_handled),
        tostring(s.card_in_machine), tostring(s.successful), s.block_reason or 'none')
end

return Diagnostics
