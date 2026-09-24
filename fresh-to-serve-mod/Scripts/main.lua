local function traceback(err)
    return debug and debug.traceback and debug.traceback(tostring(err), 2) or tostring(err)
end

local function start()
    local Game = require('game')
    local Remake = require('remake')
    local function log(event, detail)
        print('[FreshToServe] ' .. event .. ' ' .. detail .. '\n')
    end
    local remake = Remake.new(Game, log)
    local api, failed, queued = nil, false, false
    local function stop(err)
        failed = true
        log('ERROR', 'automation-stopped ' .. tostring(err))
    end
    local function tick()
        if not failed then
            local ok, err = xpcall(function()
                api = api or Game.contract()
                remake:tick(api)
            end, traceback)
            if not ok then stop(err) end
        end
        return false
    end
    if type(LoopInGameThreadWithDelay) == 'function' then
        LoopInGameThreadWithDelay(1000, tick)
    else
        LoopAsync(1000, function()
            if queued or failed then return false end
            queued = true
            local ok, err = pcall(ExecuteInGameThread, function()
                tick()
                queued = false
            end)
            if not ok then queued = false; stop(err) end
            return false
        end)
    end
    log('START', 'version=0.1.1-dev host-only=true interval=1s')
end

local ok, err = xpcall(start, traceback)
if not ok then print('[FreshToServe] ERROR startup ' .. tostring(err) .. '\n') end
