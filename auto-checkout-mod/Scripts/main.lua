local Game = require('game')
local Checkout = require('checkout')
local checkout = Checkout.new()
local api, session_id
local enabled = true
local failed = false
local queued = false

local function log(message)
    print('[AutoCheckout] ' .. message .. '\n')
end

local function tick()
    if not enabled or failed then return end
    if not api then api = Game.contract() end
    local session = Game.session(api)
    if not session then
        checkout:reset()
        session_id = nil
        return
    end
    if session.id ~= session_id then
        checkout:reset()
        session_id = session.id
        log('Host checkout active.')
    end
    if session.blocked then return end
    local present = {}
    for _, register in ipairs(Game.registers(session)) do
        local snapshot = Game.snapshot(api, session, register)
        if snapshot then
            present[snapshot.id] = true
            checkout:step(snapshot, session.now, function(action)
                Game.request(api, session, register, snapshot, action)
            end, log)
        end
    end
    checkout:prune(present)
end

local function run()
    local ok, err = pcall(tick)
    if not ok then
        failed = true
        log('Stopped after an error; manual checkout remains available. ' .. tostring(err))
    end
end

-- Keep object discovery and all reflected calls on the game thread, including
-- on older UE 5.4-compatible experimental builds without the newer timer API.
if type(LoopInGameThreadWithDelay) == 'function' then
    LoopInGameThreadWithDelay(1000, run)
else
    LoopAsync(1000, function()
        if queued or not enabled or failed then return false end
        queued = true
        local ok, err = pcall(function()
            ExecuteInGameThread(function()
                run()
                queued = false
            end)
        end)
        if not ok then
            queued = false
            failed = true
            log('Game-thread scheduling failed: ' .. tostring(err))
        end
        return false
    end)
end

RegisterKeyBind(Key.F8, { ModifierKey.CONTROL }, function()
    ExecuteInGameThread(function()
        if failed then
            log('Stopped due to an error. Check the log and reload the mod after correcting it.')
            return
        end
        enabled = not enabled
        -- Preserve request history across toggles so an unfinished transaction
        -- cannot be submitted again just by disabling and enabling the mod.
        log(enabled and 'Enabled.' or 'Disabled.')
    end)
end)

log('Loaded. Automatic checkout enabled; Ctrl+F8 toggles it. Host only.')
