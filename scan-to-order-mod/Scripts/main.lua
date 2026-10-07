local function traceback(err)
    return debug and debug.traceback and debug.traceback(tostring(err), 2) or tostring(err)
end

local function start()
    local Game, mod = require('game'), ModRef
    local key = 'ScanToOrder.StopWorld'
    local stopped = mod and mod:GetSharedVariable(key) or nil
    assert(stopped == nil or type(stopped) == 'string', 'Invalid Scan to Order reload state')
    local api, world, failed, unloaded, queued, handle
    local function checkpoint(value)
        if mod then mod:SetSharedVariable(key, value or '') end
    end
    local function stop(err)
        failed = true
        stopped = world or '*'
        pcall(checkpoint, stopped)
        print('[ScanToOrder] ERROR automation-stopped ' .. tostring(err) .. '\n')
    end
    local function tick()
        if unloaded then return true end
        local ok, err = xpcall(function()
            api = api or Game.contract()
            local session = Game.session(api)
            if not session then return end
            if world ~= session.id then
                world = session.id
                failed = stopped == world or stopped == '*'
                if not failed then stopped = nil end
            end
            if failed or session.paused then return end
            -- Persist before any mutation; if a bridge call or checkpoint fails,
            -- Ctrl+R cannot replay an uncertain order. No UObject is serialized.
            checkpoint(world)
            for _, ticket in ipairs(Game.candidates(api, session)) do
                local accepted = Game.request(api, session, ticket)
                if accepted then
                    print('[ScanToOrder] ORDER kind=' .. ticket.kind .. ' dish=' .. ticket.dish .. '\n')
                end
            end
            checkpoint(nil)
        end, traceback)
        if not ok then stop(err) end
        return false
    end
    if mod then
        mod.OnUnload = function()
            unloaded = true
            if handle and type(CancelDelayedAction) == 'function' then pcall(CancelDelayedAction, handle) end
            -- Shared stop state is already current. Never inspect the world
            -- or enqueue work into a Lua state being destroyed during unload.
        end
    end
    if type(LoopInGameThreadWithDelay) == 'function' then
        handle = LoopInGameThreadWithDelay(1000, tick)
    else
        LoopAsync(1000, function()
            if unloaded then return true end
            if queued then return false end
            queued = true
            local ok, err = pcall(ExecuteInGameThread, function() tick(); queued = false end)
            if not ok then queued = false; stop(err) end
            return false
        end)
    end
    print('[ScanToOrder] START version=0.1.2 host-only=true interval=1s\n')
end

local ok, err = xpcall(start, traceback)
if not ok then print('[ScanToOrder] ERROR startup ' .. tostring(err) .. '\n') end
