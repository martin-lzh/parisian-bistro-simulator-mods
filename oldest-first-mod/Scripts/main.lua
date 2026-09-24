local function traceback(message)
    return debug and debug.traceback and debug.traceback(tostring(message), 2) or tostring(message)
end

local function start()
    local Game, Pickup, Hint = require('game'), require('pickup'), require('hint')
    local pickup, hint = Pickup.new(), Hint.new()
    local api, ready, failed, queued = nil, false, false, false
    local wheel_path = '/Game/Blueprints/Player/BP_PlayerCharacter.BP_PlayerCharacter_C:CanInteractionWheelBeOpened'
    local input_path = '/Script/BrasserieSimulator.PlayerCharacter:InteractionTriggered'
    local hooks = {}

    local function stop(err)
        failed, ready = true, false
        pickup:reset()
        pcall(function() hint:clear() end)
        print('[OldestFirst] ERROR version=0.1.0-dev ' .. tostring(err) .. '\n')
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
                    local scope = Game.scope(api, session)
                    if scope and scope.id == pickup.scope then return false end
                end
            end))
            register(input_path, guarded(function(context, value)
                if not ready then return end
                local session = Game.session(api, context:get())
                if not session then return end
                if not api.input:Conv_InputActionValueToBool(value:get()) then pickup:reset(); return end
                local scope = Game.scope(api, session)
                if not scope or not Game.held(api, session) then pickup:reset(); return end
                -- IA_Interaction is the game's hold action. Tap uses a separate
                -- action and is untouched. Arm here; dispatch only in the loop.
                if pickup.session ~= session.id or pickup.scope ~= scope.id then
                    pickup:begin(session.id, scope.id, session.now)
                end
            end))
        end, traceback)
        if not ok then
            for _, hook in ipairs(hooks) do pcall(UnregisterHook, table.unpack(hook)) end
            error(err, 0)
        end
        ready = true
        print('[OldestFirst] START version=0.1.0-dev native-hold=true native-hint=true\n')
        return true
    end

    local function tick()
        if not install() then return end
        local session = Game.session(api)
        local scope = session and Game.scope(api, session)
        local snapshot = scope and Game.snapshot(api, session, scope)
        hint:update(session, snapshot ~= nil and snapshot.oldest ~= nil)
        if not snapshot or not Game.held(api, session) then pickup:reset(); return end
        local result = pickup:step(snapshot, function(candidate)
            return Game.request(api, session.id, scope.id, candidate)
        end)
        if result == 'timeout' then print('[OldestFirst] STOP reason=pickup-unconfirmed release-to-retry\n') end
    end

    local run = guarded(tick)
    if type(LoopInGameThreadWithDelay) == 'function' then
        LoopInGameThreadWithDelay(100, function() run(); return false end)
    else
        LoopAsync(100, function()
            if queued or failed then return false end
            queued = true
            local ok, err = pcall(ExecuteInGameThread, function() run(); queued = false end)
            if not ok then queued = false; stop(err) end
            return false
        end)
    end
end

local ok, err = xpcall(start, traceback)
if not ok then print('[OldestFirst] ERROR startup ' .. tostring(err) .. '\n') end
