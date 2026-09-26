local function traceback(err)
    if debug and type(debug.traceback) == 'function' then return debug.traceback(tostring(err), 2) end
    return tostring(err)
end

local function start()
    local Diagnostics = require('diagnostics')
    local Game = require('game')
    local Checkout = require('checkout')
    local AI = require('ai')
    local Reload = require('reload')
    local Localization = require('localization')
    local locale = Localization.new()
    local diagnostics = Diagnostics.new(function(message) print(message .. '\n') end)
    local handoff = Reload.new(ModRef)
    local checkout, ai, api
    local session_id = handoff.state.session
    local awaiting_session = session_id ~= nil
    local active, recovering = true, next(handoff.state.removed) ~= nil
    local function checkpoint()
        handoff:save({ session = session_id, registers = checkout.registers, removed = ai.removed })
    end
    checkout = Checkout.new(checkpoint)
    ai = AI.new(Game, checkpoint)
    checkout.registers, ai.removed = handoff.state.registers, handoff.state.removed
    -- UE4SS calls this after stopping async work, possibly off the game thread.
    -- Only copy plain state here. The next Lua instance performs engine recovery.
    ModRef.OnUnload = function()
        active = false
        local ok, err = pcall(checkpoint)
        if not ok then
            diagnostics:log('WARN', 'Reload handoff failed; previous recovery state retained. ' .. tostring(err))
        end
    end
    checkpoint()
    local failed, queued = false, false
    local ticks, dispatched = 0, 0
    local stage, detail = 'startup', ''

    local function restore_ai(discard_missing)
        if ai:active() then
            local restored = ai:restore(Game.ai_contexts(), recovering and not discard_missing)
            diagnostics:log('AI', 'restored_containers=' .. restored)
        end
        recovering = false
        checkpoint()
    end

    local function stop(err, on_game_thread)
        failed = true
        if ai:active() then
            local function cleanup()
                if not active then return end
                local ok, cleanup_error = pcall(restore_ai)
                if not ok then
                    diagnostics:log('WARN', locale:text('ai_restore_failed') .. ' ' .. tostring(cleanup_error))
                end
            end
            if on_game_thread then cleanup() else
                local ok, scheduling_error = pcall(ExecuteInGameThread, cleanup)
                if not ok then
                    diagnostics:log('WARN', locale:text('ai_schedule_failed') .. ' ' .. tostring(scheduling_error))
                end
            end
        end
        diagnostics:log('ERROR', locale:text('stopped') .. ' stage='
            .. stage .. ' ' .. detail .. '\n' .. tostring(err))
    end

    local function tick(signals)
        locale:refresh(Game.language)
        -- Notification bursts must not accelerate periodic diagnostic logging.
        if not signals then ticks = ticks + 1 end
        local source = signals and 'notification' or 'poll'
        stage, detail = 'contract', ''
        if not api then
            api = Game.contract()
            diagnostics:log('API', string.format('default_action=%s cash_method=%s card_method=%s',
                tostring(api.action), tostring(api.cash_method), tostring(api.card_method)))
        end
        stage = 'session'
        local session, reason = Game.session(api)
        if recovering then
            -- During travel the old containers may already be gone. Only a
            -- different live session proves their absence is safe to forget.
            -- No controller yet is inconclusive: preserve the handoff and wait.
            if not session then
                diagnostics:observe('session', 'waiting=' .. tostring(reason) .. ' reload-recovery=pending', ticks)
                return
            end
            stage, detail = 'reload-recovery', ''
            restore_ai(session.id ~= session_id)
            diagnostics:log('RELOAD', 'AI recovery completed; transaction history checked against current session')
        end
        if not session then
            restore_ai()
            -- A controller can be temporarily unavailable just after reload.
            -- Keep inherited attempts until a real session proves its identity.
            if not awaiting_session then checkout:reset(); session_id = nil end
            diagnostics:prune({ session = true })
            diagnostics:observe('session', 'waiting=' .. tostring(reason) .. ' dispatched=' .. dispatched, ticks)
            if signals then
                for id, count in pairs(signals) do
                    diagnostics:log('EVENT_IGNORED', 'register=' .. id .. ' count=' .. count .. ' reason=' .. tostring(reason))
                end
            end
            return
        end
        awaiting_session = false
        if session.id ~= session_id then
            restore_ai()
            checkout:reset()
            diagnostics:prune({})
            session_id = session.id
            diagnostics:log('HOST', locale:text('host_active') .. ' session=' .. session_id)
        end
        stage, detail = 'ai-policy', ''
        diagnostics:observe('ai', ai:sync(Game.ai_contexts(session), api.billing_task), ticks)
        stage = 'register-discovery'
        local registers, discovered = Game.registers(session)
        diagnostics:observe('session', string.format('host=true blocked=%s registers=%d discovered=%s dispatched=%d',
            session.block_reason or 'none', #registers, tostring(discovered), dispatched), ticks)
        local present, observed = {}, { session = true, ai = true }
        for _, register in ipairs(registers) do
            stage, detail = 'snapshot', ''
            local id = Game.identity(register)
            detail = 'register=' .. id
            present[id], observed[id] = true, true
            -- A notification only wakes its own register. Other registers keep
            -- their existing history and are handled by the periodic scan.
            if signals and not signals[id] then goto continue end
            local snapshot, unavailable = Game.snapshot(api, session, register)
            if snapshot then
                local state_text = Diagnostics.snapshot(snapshot)
                if signals then
                    diagnostics:log('EVENT', 'customer-at-billing count=' .. signals[id]
                        .. ' phase=' .. Checkout.phase(snapshot) .. ' ' .. state_text)
                end
                diagnostics:observe(id, 'phase=' .. Checkout.phase(snapshot) .. ' ' .. state_text, ticks)
                stage, detail = 'checkout', state_text
                checkout:step(snapshot, session.now, function(action, attempt)
                    stage, detail = 'request-' .. action, state_text
                    local sent, skipped = Game.request(api, session, register, snapshot, action, function(target, action_key, context)
                        diagnostics:log('REQUEST', string.format(
                            'phase=%s attempt=%d target=%s action=%s before={%s} source=%s context={%s}',
                            action, attempt, target, tostring(action_key), state_text, source, context or 'unavailable'))
                        dispatched = dispatched + 1
                    end)
                    if sent then
                        diagnostics:log('DISPATCH_RETURNED', 'phase=' .. action
                            .. ' register=' .. id .. ' acceptance=unconfirmed')
                        stage = 'post-request-snapshot'
                        local after, after_reason = Game.snapshot(api, session, register)
                        diagnostics:log('AFTER', after and Diagnostics.snapshot(after)
                            or 'register=' .. id .. ' unavailable=' .. tostring(after_reason))
                    else
                        diagnostics:log('SKIP', 'phase=' .. action .. ' register=' .. id
                            .. ' reason=' .. tostring(skipped))
                    end
                    return sent
                end, function(action)
                    diagnostics:log('WARN', locale:text('no_progress') .. ' phase=' .. action .. ' ' .. state_text)
                end)
            else
                if signals then
                    diagnostics:log('EVENT', 'customer-at-billing count=' .. signals[id]
                        .. ' register=' .. id .. ' unavailable=' .. tostring(unavailable))
                end
                diagnostics:observe(id, 'unavailable=' .. tostring(unavailable), ticks)
            end
            ::continue::
        end
        if signals then
            for id, count in pairs(signals) do
                if not present[id] then
                    diagnostics:log('EVENT_IGNORED', 'register=' .. id .. ' count=' .. count
                        .. ' reason=not-current-authoritative-register')
                end
            end
        end
        checkout:prune(present)
        diagnostics:prune(observed)
    end

    local function run(signals)
        if not active then return true end
        if not failed then
            local ok, err = xpcall(function() tick(signals); checkpoint() end, traceback)
            if not ok then stop(err, true) end
        end
        return false
    end

    -- Copy only the receiver's identity while the hook context is alive; never
    -- retain Context or a UObject in a deferred callback. Gameplay reads and
    -- interaction requests stay in the game-thread scan above.
    local notification_path = '/Script/BrasserieSimulator.CashRegister:Multicast_DisplayCustomerAtBillingNotification'
    local pending, notification_queued, notifications_enabled = {}, false, true
    local function disable_notifications(err)
        notifications_enabled = false
        pending = {}
        diagnostics:log('WARN', locale:text('notification_unavailable') .. ' ' .. tostring(err))
    end
    local function queue_notifications()
        if notification_queued then return end
        notification_queued = true
        local function drain()
            if not active then return end
            local signals = pending
            pending = {}
            -- Keep the flag set through dispatch to avoid nested requests
            -- if an interaction itself emits another notification.
            if notifications_enabled and next(signals) then run(signals) end
            notification_queued = false
            if not failed and notifications_enabled and next(pending) then
                local ok, err = xpcall(queue_notifications, traceback)
                if not ok then disable_notifications(err) end
            end
        end
        if type(ExecuteInGameThreadWithDelay) == 'function' then
            ExecuteInGameThreadWithDelay(50, drain)
        else
            ExecuteInGameThread(drain)
        end
    end
    local function on_notification(context)
        if not active or failed or not notifications_enabled then return end
        local ok, err = xpcall(function()
            local register = context:get()
            if not Game.valid(register) then return end
            local id = Game.identity(register)
            pending[id] = (pending[id] or 0) + 1
            queue_notifications()
        end, traceback)
        if not ok then disable_notifications(err) end
        -- Never override the game's notification return value or parameters.
    end
    -- Discovery, diagnostics, and reflected calls all run on the game thread.
    if type(LoopInGameThreadWithDelay) == 'function' then
        LoopInGameThreadWithDelay(1000, run)
        diagnostics:log('START', 'version=' .. Diagnostics.VERSION .. ' scheduler=game-thread-loop host-only=true player_guard=transaction-only')
    else
        LoopAsync(1000, function()
            if not active then return true end
            if queued or failed then return false end
            queued = true
            local ok, err = xpcall(function()
                ExecuteInGameThread(function()
                    run()
                    queued = false
                end)
            end, traceback)
            if not ok then
                queued = false
                stage, detail = 'game-thread-scheduling', ''
                stop(err)
            end
            return false
        end)
        diagnostics:log('START', 'version=' .. Diagnostics.VERSION .. ' scheduler=async-to-game-thread host-only=true player_guard=transaction-only')
    end

    -- Install only after polling is scheduled so a startup timer failure
    -- cannot leave an event-only automation running behind an error message.
    local hook_ok, pre_id, post_id = pcall(RegisterHook, notification_path, function() end, on_notification)
    if hook_ok and type(pre_id) == 'number' and type(post_id) == 'number' then
        diagnostics:log('HOOK', 'installed event=customer-at-billing')
    else
        disable_notifications(hook_ok and 'Hook registration did not return callback IDs.' or pre_id)
    end
end

local ok, err = xpcall(start, traceback)
if not ok then print('[AutoCheckout] ERROR stage=startup automatic checkout unavailable.\n' .. tostring(err) .. '\n') end
