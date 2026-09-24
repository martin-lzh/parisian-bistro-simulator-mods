local function traceback(message)
    return debug and debug.traceback and debug.traceback(tostring(message), 2) or tostring(message)
end

local function start()
    local Game, Pickup, Hint = require('game'), require('pickup'), require('hint')
    local pickup, hint = Pickup.new(), Hint.new()
    local api, ready, failed, queued = nil, false, false, false
    local idle_ticks = 0
    local source_lock, triggered = nil, false
    local wheel_path = '/Game/Blueprints/Player/BP_PlayerCharacter.BP_PlayerCharacter_C:CanInteractionWheelBeOpened'
    local input_path = '/Script/BrasserieSimulator.PlayerCharacter:InteractionTriggered'
    local hooks = {}

    local function reset(released)
        source_lock = nil
        pickup:reset()
        if released then triggered = false end
    end

    local function stop(err)
        failed, ready = true, false
        reset()
        pcall(function() hint:clear() end)
        print('[FirstToServe] ERROR version=0.1.3-dev ' .. tostring(err) .. '\n')
    end

    local function guarded(callback)
        return function(...)
            if failed then return end
            local ok, result = xpcall(callback, traceback, ...)
            if not ok then stop(result); return end
            return result
        end
    end

    local function register(path, callback)
        local pre, post = RegisterHook(path, callback)
        assert(type(pre) == 'number' and type(post) == 'number', 'Hook registration failed: ' .. path)
        hooks[#hooks + 1] = { path, pre, post }
    end

    local function install()
        if ready then return true end
        if not Game.valid(StaticFindObject(wheel_path)) then return false end
        api = Game.contract()
        local ok, err = xpcall(function()
            -- Blueprint hook runs after the native-style wheel eligibility
            -- function. Return nil everywhere except this active hold gesture.
            register(wheel_path, guarded(function(context)
                if not ready or not pickup.session then return end
                local session = Game.session(api, context:get())
                if session and session.id == pickup.session and Game.held(api, session) then
                    local scope = Game.scope(api, session, source_lock)
                    if scope and scope.id == pickup.scope then return false end
                end
            end))
            register(input_path, guarded(function(context, value)
                if not ready then return end
                local session = Game.session(api, context:get())
                if not session then return end
                if not api.input:Conv_InputActionValueToBool(value:get()) then reset(true); return end
                if not Game.held(api, session) then reset(true); return end
                -- Repeated trigger events must not replace or clear the
                -- active source when the first item is already moving.
                if triggered then return end
                local scope = Game.scope(api, session)
                if not scope then return end
                triggered = true
                -- IA_Interaction is the game's hold action. Tap uses a separate
                -- action and is untouched. Arm here; dispatch only in the loop.
                if pickup.session ~= session.id or pickup.scope ~= scope.id then
                    pickup:begin(session.id, scope.id, session.now)
                    source_lock = Game.lock(session, scope)
                end
            end))
        end, traceback)
        if not ok then
            for _, hook in ipairs(hooks) do pcall(UnregisterHook, table.unpack(hook)) end
            error(err, 0)
        end
        ready = true
        print('[FirstToServe] START version=0.1.3-dev native-hold=true native-hint=true\n')
        return true
    end

    local function tick()
        if not install() then return end
        -- Check active pickups every 25 ms, but keep idle/full/stopped scans
        -- at 100 ms. A native hold bypasses the idle countdown immediately.
        if not pickup.session or pickup.stopped then
            if idle_ticks > 0 then idle_ticks = idle_ticks - 1; return end
            idle_ticks = 3
        else
            idle_ticks = 0
        end
        local session = Game.session(api)
        local aimed = session and Game.scope(api, session)
        local scope = aimed
        if session and pickup.session then scope = Game.scope(api, session, source_lock) end
        local snapshot = scope and Game.snapshot(api, session, scope)
        hint:update(session, aimed ~= nil and snapshot ~= nil and snapshot.oldest ~= nil)
        if not session then reset(); return end
        if not Game.held(api, session) then reset(true); return end
        if not snapshot then reset(); return end
        if source_lock and aimed and aimed.id == source_lock.id then
            source_lock = Game.lock(session, aimed)
        end
        local result = pickup:step(snapshot, function(candidate)
            return Game.request(api, session.id, scope.id, candidate, source_lock)
        end)
        if result == 'timeout' then print('[FirstToServe] STOP reason=pickup-unconfirmed release-to-retry\n') end
    end

    if ModRef then
        ModRef.OnUnload = function()
            failed, ready = true, false
            reset()
            -- Some loader unload paths run off the game thread. Do not queue
            -- a callback into a Lua state about to die; startup also prunes
            -- orphaned rows on the next game-thread tick.
            if type(IsInGameThread) == 'function' and IsInGameThread() then
                pcall(function() hint:clear() end)
            end
        end
    end

    local run = guarded(tick)
    if type(LoopInGameThreadWithDelay) == 'function' then
        LoopInGameThreadWithDelay(25, function() run(); return failed end)
    else
        LoopAsync(25, function()
            if queued or failed then return false end
            queued = true
            local ok, err = pcall(ExecuteInGameThread, function() run(); queued = false end)
            if not ok then queued = false; stop(err) end
            return false
        end)
    end
end

local ok, err = xpcall(start, traceback)
if not ok then print('[FirstToServe] ERROR startup ' .. tostring(err) .. '\n') end
