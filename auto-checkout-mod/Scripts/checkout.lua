-- Original checkout state machine; contains no Unreal object references.
local Checkout = {}
Checkout.__index = Checkout

function Checkout.new()
    return setmetatable({ registers = {} }, Checkout)
end

function Checkout:reset()
    self.registers = {}
end

function Checkout:prune(present)
    for id in pairs(self.registers) do
        if not present[id] then self.registers[id] = nil end
    end
end

function Checkout:step(s, now, request, warn)
    local state = self.registers[s.id]
    if not state then
        state = { attempts = {} }
        self.registers[s.id] = state
    end
    -- A new payment object identifies a new customer transaction. Never use
    -- prices or the game's wrapping replication counter as an identity.
    if s.payment_id and s.payment_id ~= state.payment_id then
        state.payment_id = s.payment_id
        state.attempts = {}
    end
    if not s.has_bill then
        -- Do not reset while the drawer is closing or a card is processing.
        if not s.moving and not s.drawer_open and not s.card_in_machine
            and not s.payment_id then
            self.registers[s.id] = nil
        end
        return
    end
    if s.blocked or s.moving or s.being_handled or s.card_in_machine then return end

    local action
    if s.drawer_open then
        if s.payment_id then return end
        if s.method == 'card' and not s.successful then return end
        action = 'finish'
    elseif s.payment_id and not s.successful then
        action = 'take'
    else
        return
    end

    local attempt = state.attempts[action]
    if attempt and now < attempt.next_at then return end
    if attempt and attempt.count >= 3 then
        if not attempt.warned then
            attempt.warned = true
            warn('No progress after three ' .. action .. ' requests; leaving this stage to manual checkout.')
        end
        return
    end
    -- Record before dispatch: exceptions must not cause an immediate repeat.
    state.attempts[action] = {
        count = attempt and attempt.count + 1 or 1,
        next_at = now + 3,
    }
    request(action)
end

return Checkout
