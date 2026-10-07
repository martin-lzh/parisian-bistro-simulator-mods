local function traceback(err)
    return debug and debug.traceback and debug.traceback(tostring(err), 2) or tostring(err)
end

local function start()
    local Game = require('game')
    local Remake = require('remake')
    local Reload = require('reload')
    local mod = ModRef
    local function log(event, detail)
        print('[FreshToServe] ' .. event .. ' ' .. detail .. '\n')
    end
    local remake = Remake.new(Game, log)
    local restored, restore_error = Reload.read(mod)
    remake.pending, remake.session = restored.pending, restored.session
    local api, failed, queued, unloaded, handle = nil, restored.failed, false, false, nil
    local function checkpoint(stopped)
        Reload.write(mod, remake, stopped)
    end
    local function stop(err)
        failed = true
        -- The pre-tick stop marker remains if this save itself fails.
        pcall(checkpoint, true)
        log('ERROR', 'automation-stopped ' .. tostring(err))
    end
    local function tick()
        if unloaded then return true end
        local ok, err = xpcall(function()
            api = api or Game.contract()
            local session = Game.session(api)
            if not session then return end
            if session.id ~= remake.session then
                if remake.session ~= nil then
                    remake.pending, failed = {}, false
                end
                remake.session = session.id
                checkpoint(failed)
            end
            if failed or session.paused then return end
            -- An interrupted or uncertain mutation must not be replayed after
            -- reload, even if writing the successful checkpoint later fails.
            checkpoint(true)
            remake:tick(api, session)
            checkpoint(false)
        end, traceback)
        if not ok then stop(err) end
        return false
    end
    if mod then
        mod.OnUnload = function()
            unloaded = true
            -- Loader timer cancellation and scalar serialization are safe from
            -- an unload thread. Do not access UObjects or queue Lua callbacks.
            if handle and type(CancelDelayedAction) == 'function' then pcall(CancelDelayedAction, handle) end
            local ok, err = pcall(checkpoint, failed)
            if not ok then log('ERROR', 'reload-state-save-failed ' .. tostring(err)) end
        end
    end
    -- Check shared storage before allowing the first mutation.
    checkpoint(failed)
    if type(LoopInGameThreadWithDelay) == 'function' then
        handle = LoopInGameThreadWithDelay(1000, tick)
    else
        LoopAsync(1000, function()
            if unloaded then return true end
            if queued then return false end
            queued = true
            local ok, err = pcall(ExecuteInGameThread, function()
                tick()
                queued = false
            end)
            if not ok then queued = false; stop(err) end
            return false
        end)
    end
    log('START', 'version=0.1.3 host-only=true interval=1s reload-state=true stopped=' .. tostring(failed))
    if restore_error then log('ERROR', 'reload-state-invalid ' .. restore_error) end
end

local ok, err = xpcall(start, traceback)
if not ok then print('[FreshToServe] ERROR startup ' .. tostring(err) .. '\n') end
