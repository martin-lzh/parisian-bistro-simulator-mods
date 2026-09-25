local function traceback(message)
    return debug and debug.traceback and debug.traceback(tostring(message), 2) or tostring(message)
end

local function start()
    assert(type(LoopInGameThreadWithDelay) == 'function', 'UE4SS experimental game-thread loop required')
    local Game, Planner, UI = require('game'), require('planner'), require('ui')
    local lifetime = require('reload').new('AutoMenu.widgets.v1')
    local views, last_error = {}, nil
    local hook = '/Script/CommonUI.CommonButtonBase:HandleButtonClicked'

    local function report(err)
        local message = tostring(err)
        if message ~= last_error then print('[AutoMenu] ERROR ' .. message .. '\n'); last_error = message end
    end

    local function clicked(context)
        if lifetime.stopped then return end
        local button = context:get()
        if not Game.valid(button) then return end
        local view = views[Game.identity(button)]
        if not view or view.busy or not Game.available(view.owner)
            or not button:IsInteractionEnabled() then return end
        view.busy = true
        local ok, status = xpcall(function()
            local snapshot = Game.snapshot(view.owner)
            local menu, reason = Planner.plan(snapshot)
            if not menu then return reason end
            Game.apply(view.owner, snapshot, menu)
            print(string.format('[AutoMenu] COMPOSED version=0.1.0-dev day=%s period=%s event=%s temperature=%s\n',
                snapshot.day, snapshot.period, snapshot.event, snapshot.temperature))
            return 'done'
        end, traceback)
        view.busy = false
        if not ok then report(status); status = 'error' end
        UI.result(view, status)
    end

    -- Native UMG click dispatch runs on the game thread. Filter by the new
    -- button's full identity so every existing game button retains its action.
    local pre, post = RegisterHook(hook, function() end, function(context)
        local ok, err = xpcall(clicked, traceback, context)
        if not ok then report(err) end
    end)
    assert(type(pre) == 'number' and type(post) == 'number', 'Menu button hook unavailable')

    LoopInGameThreadWithDelay(500, function()
        if lifetime.stopped then return true end
        local ok, err = xpcall(function()
            lifetime:cleanup()
            local owners = {}
            for key, view in pairs(views) do
                if not Game.host(view.owner) or not Game.valid(view.button) then
                    UI.destroy(view); views[key] = nil
                else
                    owners[Game.identity(view.owner)] = true
                    UI.update(view)
                end
            end
            for _, owner in ipairs(FindAllOf('WBP_MenuApp_C') or {}) do
                if Game.available(owner) and not owners[Game.identity(owner)] then
                    local view = UI.create(owner, lifetime)
                    views[Game.identity(view.button)] = view
                    owners[Game.identity(owner)] = true
                end
            end
        end, traceback)
        if not ok then
            report(err)
            -- A failed cleanup/temporary unavailable UI is retried before any
            -- replacement widget can be created. No menu is saved by this loop.
        else last_error = nil end
        return false
    end)
    print('[AutoMenu] START version=0.1.0-dev\n')
end

local ok, err = xpcall(start, traceback)
if not ok then print('[AutoMenu] ERROR startup ' .. tostring(err) .. '\n') end
