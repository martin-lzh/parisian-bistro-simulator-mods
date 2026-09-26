local function traceback(message)
    return debug and debug.traceback and debug.traceback(tostring(message), 2) or tostring(message)
end

local function start()
    local UI, Settings, Bridge = require('ui'), require('settings'), require('bridge')
    local Reload = require('reload')
    local source = debug.getinfo(1, 'S').source
    assert(source:sub(1, 1) == '@', 'Cannot locate Smart Delivery scripts')
    local directory = assert(source:sub(2):match('^(.*)[/\\]'), 'Cannot locate Mod directory')
    local path = directory .. '/delivery-preference.txt'
    local saved = Settings.load(path)
    local bridge = Bridge.new(directory)
    local lifetime = Reload.new('SmartDelivery.widgets.v1', function() bridge:suspend() end)
    local views, hooks, ready, failed, queued = {}, {}, false, false, false

    local function stop(err)
        if failed then return end
        failed, ready = true, false
        -- Disable even if the acknowledgment file itself became unwritable.
        local restored, restore_error = pcall(bridge.calls.disable)
        for _, view in pairs(views) do pcall(UI.destroy, view) end
        for _, hook in ipairs(hooks) do pcall(UnregisterHook, table.unpack(hook)) end
        print('[SmartDelivery] ERROR version=0.1.5 ' .. tostring(err)
            .. (restored and '' or '; restore=' .. tostring(restore_error)) .. '\n')
    end
    local function guard(fn)
        return function(...)
            if failed or lifetime.stopped then return end
            local ok, err = xpcall(fn, traceback, ...)
            if not ok then stop(err) end
        end
    end
    local function id(owner) return owner:GetFullName() .. '@' .. tostring(owner:GetAddress()) end
    local function view_for(owner)
        local key = id(owner)
        if not views[key] then
            views[key] = UI.create(owner, lifetime)
            UI.update(views[key], saved, true)
            print('[SmartDelivery] UI attached to automatic-order settings\n')
        end
        return views[key]
    end
    local function initialize()
        if ready then return end
        lifetime:cleanup()
        bridge:call('initialize')
        bridge:call(saved)
        local hook = '/Script/BrasserieSimulator.MenuAppWidget:SaveAutomaticSmartOrderSettings'
        local pre, post = RegisterHook(hook, guard(function(context)
            local owner = context:get()
            if not ready or not UI.host(owner) or owner:AreAutomaticSmartOrderSettingsLocked() then return end
            local choice = UI.choice(view_for(owner))
            if choice ~= saved then
                -- Apply before the native Save, which may immediately evaluate
                -- an order through a native delegate rather than a UFunction.
                bridge:call(choice)
                Settings.save(path, choice)
                saved = choice
                print('[SmartDelivery] SAVED method=' .. saved .. '\n')
            end
        end))
        assert(type(pre) == 'number' and type(post) == 'number', 'Save hook unavailable')
        hooks[#hooks + 1] = { hook, pre, post }
        local reset = '/Script/BrasserieSimulator.MenuAppWidget:ResetAutomaticSmartOrderSettings'
        pre, post = RegisterHook(reset, function() end, guard(function(context)
            local owner = context:get()
            if ready and UI.host(owner) then UI.update(view_for(owner), saved, true) end
        end))
        assert(type(pre) == 'number' and type(post) == 'number', 'Reset hook unavailable')
        hooks[#hooks + 1] = { reset, pre, post }
        ready = true
        print('[SmartDelivery] START version=0.1.5 method=' .. saved .. '\n')
    end
    local run = guard(function()
        initialize()
        for key, view in pairs(views) do
            if not UI.host(view.owner) then UI.destroy(view); views[key] = nil end
        end
        for _, owner in ipairs(FindAllOf('WBP_MenuApp_C') or {}) do
            if UI.host(owner) then UI.update(view_for(owner), saved) end
        end
    end)
    if type(LoopInGameThreadWithDelay) == 'function' then
        LoopInGameThreadWithDelay(100, function() run(); return failed or lifetime.stopped end)
    else
        LoopAsync(100, function()
            if failed or lifetime.stopped then return true end
            if not queued then
                queued = true
                local ok, err = pcall(ExecuteInGameThread, function() run(); queued = false end)
                if not ok then queued = false; print('[SmartDelivery] SCHEDULING ERROR ' .. tostring(err) .. '\n') end
            end
            return false
        end)
    end
end

local ok, err = xpcall(start, traceback)
if not ok then print('[SmartDelivery] ERROR startup ' .. tostring(err) .. '\n') end
