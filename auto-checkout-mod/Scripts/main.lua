local function traceback(err)
    if debug and type(debug.traceback) == 'function' then return debug.traceback(tostring(err), 2) end
    return tostring(err)
end

local function start()
    local Diagnostics = require('diagnostics')
    local Game = require('game')
    local Checkout = require('checkout')
    local diagnostics = Diagnostics.new(function(message) print(message .. '\n') end)
    local checkout = Checkout.new()
    local api, session_id
    local failed, queued = false, false
    local ticks, dispatched = 0, 0
    local stage, detail = 'startup', ''

    local function stop(err)
        failed = true
        diagnostics:log('ERROR', 'Stopped after an error; manual checkout remains available. stage='
            .. stage .. ' ' .. detail .. '\n' .. tostring(err))
    end

    local function tick()
        ticks = ticks + 1
        stage, detail = 'contract', ''
        if not api then
            api = Game.contract()
            diagnostics:log('API', string.format('default_action=%s cash_method=%s card_method=%s',
                tostring(api.action), tostring(api.cash_method), tostring(api.card_method)))
        end
        stage = 'session'
        local session, reason = Game.session(api)
        if not session then
            checkout:reset()
            session_id = nil
            diagnostics:prune({ session = true })
            diagnostics:observe('session', 'waiting=' .. tostring(reason) .. ' dispatched=' .. dispatched, ticks)
            return
        end
        if session.id ~= session_id then
            checkout:reset()
            diagnostics:prune({})
            session_id = session.id
            diagnostics:log('HOST', 'Host checkout active. session=' .. session_id)
        end
        stage = 'register-discovery'
        local registers, discovered = Game.registers(session)
        diagnostics:observe('session', string.format('host=true blocked=%s registers=%d discovered=%s dispatched=%d',
            session.block_reason or 'none', #registers, tostring(discovered), dispatched), ticks)
        local present, observed = {}, { session = true }
        for _, register in ipairs(registers) do
            stage, detail = 'snapshot', ''
            local id = Game.identity(register)
            detail = 'register=' .. id
            present[id], observed[id] = true, true
            local snapshot, unavailable = Game.snapshot(api, session, register)
            if snapshot then
                local state_text = Diagnostics.snapshot(snapshot)
                diagnostics:observe(id, 'phase=' .. Checkout.phase(snapshot) .. ' ' .. state_text, ticks)
                stage, detail = 'checkout', state_text
                checkout:step(snapshot, session.now, function(action, attempt)
                    stage, detail = 'request-' .. action, state_text
                    local sent, skipped = Game.request(api, session, register, snapshot, action, function(target, action_key)
                        diagnostics:log('REQUEST', string.format(
                            'phase=%s attempt=%d target=%s action=%s before={%s}',
                            action, attempt, target, tostring(action_key), state_text))
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
                end, function(message)
                    diagnostics:log('WARN', message .. ' ' .. state_text)
                end)
            else
                diagnostics:observe(id, 'unavailable=' .. tostring(unavailable), ticks)
            end
        end
        checkout:prune(present)
        diagnostics:prune(observed)
    end

    local function run()
        if not failed then
            local ok, err = xpcall(tick, traceback)
            if not ok then stop(err) end
        end
        return false
    end

    -- Discovery, diagnostics, and reflected calls all run on the game thread.
    if type(LoopInGameThreadWithDelay) == 'function' then
        LoopInGameThreadWithDelay(1000, run)
        diagnostics:log('START', 'version=' .. Diagnostics.VERSION .. ' scheduler=game-thread-loop host-only=true')
    else
        LoopAsync(1000, function()
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
        diagnostics:log('START', 'version=' .. Diagnostics.VERSION .. ' scheduler=async-to-game-thread host-only=true')
    end
end

local ok, err = xpcall(start, traceback)
if not ok then print('[AutoCheckout] ERROR stage=startup automatic checkout unavailable.\n' .. tostring(err) .. '\n') end
