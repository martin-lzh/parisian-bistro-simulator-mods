local function traceback(message)
    return debug and debug.traceback and debug.traceback(tostring(message), 2) or tostring(message)
end

local function start()
    local Game, UI = require('game'), require('ui')
    local lifetime = require('reload').new('AutoMenu.widgets.v1')
    local views, last_error = {}, nil
    local function report(err)
        local message = tostring(err)
        if message ~= last_error then print('[AutoMenu] ERROR ' .. message .. '\n'); last_error = message end
    end

    local function clicked(context)
        if lifetime.stopped then return end
        local button = context:get()
        if not Game.valid(button) then return end
        local view = views[Game.identity(button)]
        if not view or view.handling or not Game.available(view.owner)
            or not button:IsInteractionEnabled() then return end
        view.handling = true
        local ok, result = xpcall(Game.compose, traceback, view.owner)
        view.handling = false
        if ok then
            last_error = nil
            local timing = result.timing
            print(string.format('[AutoMenu] COMPOSED version=0.4.1-dev rate=%.9f evaluations=%d elapsed=%.3f\n',
                result.rate, result.evaluations, timing.total))
            print(string.format('[AutoMenu] TIMING total_ms=%.3f search_ms=%.3f projection_avg_ms=%.6f field_writes=%d stop=%s\n',
                timing.total * 1000, timing.search * 1000, timing.projection * 1000 / result.evaluations,
                timing.field_writes, result.evaluations < result.combinations and 'native_ceiling' or 'exhausted'))
            local parts = {}
            for _, phase in ipairs({ 'setup', 'writes', 'projection', 'rate_read', 'restore', 'save', 'verify', 'refresh', 'lua_and_timing' }) do
                local seconds = timing[phase]
                parts[#parts + 1] = string.format('%s=%.3fms(%.2f%%)', phase, seconds * 1000,
                    timing.total > 0 and seconds * 100 / timing.total or 0)
            end
            print('[AutoMenu] TIMING_PARTS ' .. table.concat(parts, ' ') .. '\n')
        else report(result) end
    end

    -- Filter by our button; existing game buttons retain their native actions.
    local pre, post = RegisterHook('/Script/CommonUI.CommonButtonBase:HandleButtonClicked', function() end, function(context)
        local ok, err = xpcall(clicked, traceback, context)
        if not ok then report(err) end
    end)
    assert(type(pre) == 'number' and type(post) == 'number', 'Menu button hook unavailable')

    -- Only widget discovery runs periodically. Search has no timer or progress UI.
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
        if not ok then report(err) end
        return false
    end)
    print('[AutoMenu] START version=0.4.1-dev\n')
end

local ok, err = xpcall(start, traceback)
if not ok then print('[AutoMenu] ERROR startup ' .. tostring(err) .. '\n') end
