-- Original decision logic; snapshots contain Lua values only.
local Remake = {}
Remake.__index = Remake

local function finite(n)
    return type(n) == 'number' and n == n and n > -math.huge and n < math.huge
end
Remake.finite = finite

-- Charge all existing work serially, without assuming parallel chefs or bonuses.
-- Allow time for dispatch and service as well as the actual cooking.
function Remake.budget(preparation, queue)
    if not finite(preparation) or preparation <= 0 then return nil end
    local seconds = preparation + 30
    for _, duration in ipairs(queue) do
        if not finite(duration) or duration < 0 then return nil end
        seconds = seconds + duration + 5
    end
    return seconds
end

function Remake.decision(snapshot)
    if not snapshot.present then return 'cancel', 'customer-left-or-order-changed' end
    if snapshot.supplied then return 'cancel', 'replacement-already-covered' end
    if not snapshot.ready then return 'wait', 'kitchen-unavailable' end
    local budget = Remake.budget(snapshot.preparation, snapshot.queue)
    if not budget then return 'cancel', 'timing-unavailable' end
    if snapshot.patience_enabled ~= false then
        if not finite(snapshot.remaining) then return 'cancel', 'patience-unavailable' end
        if snapshot.remaining <= budget then return 'cancel', 'insufficient-patience' end
    end
    return 'order', 'within-budget', budget
end

function Remake.new(game, log)
    return setmetatable({ game = game, log = log, pending = {}, session = nil }, Remake)
end

function Remake:tick(api, current_session)
    local game = self.game
    local session = current_session or game.session(api)
    if not session then
        -- A reload can briefly precede possession/HUD initialization. Keep
        -- scalar tickets until an actual session proves travel occurred.
        return
    end
    if session.id ~= self.session then
        self.pending, self.session = {}, session.id
    end
    if session.paused then return end

    for _, candidate in ipairs(game.candidates(api, session)) do
        -- Capture the customer/order identity before removing the physical dish.
        local ticket = game.ticket(api, session, candidate, self.pending)
        if game.discard(api, session, candidate) then
            self.log('DISCARDED', candidate.id)
            if ticket then
                -- One pending replacement per original customer order, even if
                -- several obsolete plates were left for the same demand.
                local key = ticket.key
                if not self.pending[key] then
                    ticket.next_attempt, ticket.attempts = session.now, 0
                    self.pending[key] = ticket
                end
            else
                self.log('SKIPPED', 'no-current-customer-order')
            end
        end
    end

    -- Stable order makes multiple identical meals deterministic. Every order
    -- re-reads the queue so earlier accepted remakes enter the next budget.
    local keys = {}
    for key in pairs(self.pending) do keys[#keys + 1] = key end
    table.sort(keys)
    for _, key in ipairs(keys) do
        local ticket = self.pending[key]
        local action, reason, budget
        if session.now - ticket.created_at >= 120 then
            action, reason = 'cancel', 'retry-limit'
        else
            local snapshot = game.snapshot(api, session, ticket)
            action, reason, budget = Remake.decision(snapshot)
        end
        if action == 'cancel' then
            self.pending[key] = nil
            self.log('SKIPPED', reason .. ' order=' .. key)
        elseif session.now >= ticket.next_attempt then
            if action == 'order' then
                -- request() validates customer, supply and timing again directly
                -- before dispatch. An exception stops automation, never retries
                -- a request whose acceptance is uncertain.
                local accepted, result = game.request(api, session, ticket)
                if accepted then
                    self.pending[key] = nil
                    self.log('REQUEUED', 'order=' .. key .. ' budget=' .. tostring(budget))
                else
                    ticket.attempts = ticket.attempts + 1
                    self.log('DEFERRED', tostring(result) .. ' order=' .. key)
                end
            end
            ticket.next_attempt = session.now + 10
        end
        if self.pending[key] and ticket.attempts >= 3 then
            self.pending[key] = nil
            self.log('SKIPPED', 'retry-limit order=' .. key)
        end
    end
end

return Remake
