-- Original pickup sequencing. State contains scalar identities, never UObjects.
local Pickup = {}
Pickup.__index = Pickup

function Pickup.new()
    return setmetatable({}, Pickup)
end

function Pickup:reset()
    self.session, self.scope, self.pending, self.next_at, self.stopped = nil, nil, nil, nil, nil
    self.last_time = nil
end

function Pickup:begin(session, scope, now)
    self:reset()
    self.session, self.scope, self.next_at = session, scope, now
end

function Pickup:step(snapshot, send)
    if not snapshot or snapshot.session ~= self.session or snapshot.scope ~= self.scope then
        self:reset()
        return
    end
    if self.stopped then return end
    local now = snapshot.now
    if self.last_time and now < self.last_time then self:reset(); return end
    self.last_time = now
    if self.pending then
        if snapshot.carried[self.pending.id] or not snapshot.present[self.pending.id] then
            self.pending = nil
        elseif now - self.pending.at >= 2 then
            self.stopped = true
            return 'timeout'
        else
            return
        end
    end
    if snapshot.has_space == false then self.stopped = true; return 'full' end
    if now < self.next_at then return end
    local candidate = snapshot.oldest
    if not candidate then return end
    -- Set pending before dispatch: a synchronous native call can invoke hooks.
    self.pending = { id = candidate, at = now }
    self.next_at = now + 0.30
    if not send(candidate) then
        self.pending = nil
        self.stopped = true
        return 'changed'
    end
    return 'requested'
end

return Pickup
