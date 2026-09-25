-- Original checkout state machine; contains no Unreal object references.
local Checkout = {}
Checkout.__index = Checkout

function Checkout.new(checkpoint)
    return setmetatable({ registers = {}, checkpoint = checkpoint or function() end }, Checkout)
end

function Checkout:reset()
    self.registers = {}
end

function Checkout:prune(present)
    for id in pairs(self.registers) do
        if not present[id] then self.registers[id] = nil end
    end
end

function Checkout.phase(s)
    if s.blocked then return 'wait-' .. (s.block_reason or 'player') end
    if not s.has_bill then return 'wait-bill' end
    if s.moving then return 'wait-drawer-motion' end
    if s.being_handled then return 'wait-register-handler' end
    if s.card_in_machine then return 'wait-card-processing' end
    if s.drawer_open then
        if s.payment_id then return 'wait-payment-removal' end
        if s.method == 'card' and not s.successful then return 'wait-card-success' end
        return 'finish'
    end
    if s.payment_id and not s.successful then return 'take' end
    return 'wait-payment-or-drawer'
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
    local action = Checkout.phase(s)
    if action ~= 'take' and action ~= 'finish' then return end

    local attempt = state.attempts[action]
    if attempt and now < attempt.next_at then return end
    if attempt and attempt.count >= 3 then
        if not attempt.warned then
            attempt.warned = true
            warn(action)
        end
        return
    end
    -- Record before dispatch: exceptions must not cause an immediate repeat.
    state.attempts[action] = {
        count = attempt and attempt.count + 1 or 1,
        next_at = now + 3,
    }
    self.checkpoint() -- Reload must retain the budget even if dispatch throws.
    if request(action, state.attempts[action].count) ~= true then
        -- A changed precondition is not a request rejected by the game. Keep
        -- the cooldown but do not consume the budget for an unsent action.
        state.attempts[action].count = attempt and attempt.count or 0
        self.checkpoint()
    end
end

return Checkout
