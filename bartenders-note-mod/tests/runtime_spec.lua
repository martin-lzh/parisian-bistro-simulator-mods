local directory = debug.getinfo(1, 'S').source:sub(2):match('^(.*[/\\])')
package.path = directory .. '../Scripts/?.lua;' .. package.path
local passed = 0
local original_print = print
local function test(name, body)
    local ok, err = pcall(body)
    print = original_print
    assert(ok, name .. ': ' .. tostring(err))
    passed = passed + 1
end

local function fixture(supported)
    local f = { pending = {}, hooks = {}, logs = {}, created = 0, removed = 0, entries = {} }
    f.owner = { valid = true, viewport = true, active = true }
    function f.owner:IsInViewport() return self.viewport end
    local game = {}
    function game.valid(object) return object ~= nil and object.valid end
    function game.active(object) return game.valid(object) and object:IsInViewport() and object.active end
    function game.find_hud() return f.candidate end
    function game.snapshot()
        if f.failure then error(f.failure) end
        return f.entries, 7, function()
            if f.translation_missing then return nil end
            return f.label or 'Coffee'
        end, f.language, f.category
    end
    local hud = {}
    function hud.valid(view) return view.valid end
    function hud.create(owner)
        f.created = f.created + 1
        local view = { valid = true, owner = owner }
        f.view = view
        return view
    end
    function hud.destroy(view)
        view.valid = false
        f.removed = f.removed + 1
    end
    function hud.update(view, groups, language)
        assert(type(groups) == 'table', 'Renderer needs groups for measured line layout')
        view.groups = groups
        view.language = language
        local parts = {}
        for _, group in ipairs(groups) do
            parts[#parts + 1] = group.name .. ' x ' .. group.count
        end
        view.text = table.concat(parts, '  ·  ')
    end
    package.loaded.game = game
    package.loaded.hud = hud
    package.loaded.summary = dofile(directory .. '../Scripts/summary.lua')
    local shared = {}
    ModRef = {
        GetSharedVariable = function(_, key) return shared[key] end,
        SetSharedVariable = function(_, key, value)
            assert(type(value) == 'string')
            shared[key] = value
        end,
    }
    print = function(message) f.logs[#f.logs + 1] = message end
    RegisterHook = function(path, pre, post) f.hooks[path] = post end
    NotifyOnNewObject = function(_, callback) f.notify = callback end
    LoopInGameThreadWithDelay = supported and function(interval, callback)
        assert(interval == 750)
        f.tick = callback
    end or nil
    ExecuteInGameThreadWithDelay = supported and function(_, callback)
        f.pending[#f.pending + 1] = callback
    end or nil
    function f.flush()
        local pending = f.pending
        f.pending = {}
        for _, callback in ipairs(pending) do callback() end
    end
    function f.claim()
        f.entries = { { id = 'a', drink = 1, state = 0, claimed = true, player_id = 7 } }
    end
    dofile(directory .. '../Scripts/main.lua')
    return f
end

test('unsupported loader does not register work', function()
    local f = fixture(false)
    assert(f.tick == nil and f.notify == nil and next(f.hooks) == nil)
    assert(f.created == 0 and #f.logs == 1)
end)

test('language events and periodic refresh update mod-only wording and layout language', function()
    local f = fixture(true)
    f.candidate = f.owner
    f.claim()
    f.translation_missing, f.language = true, 'fr'
    f.flush()
    assert(f.view.text == 'Boisson 1 x 1' and f.view.language == 'fr')
    f.language = 'zh-Hant'
    f.hooks['/Script/BrasserieSimulator.LocaleGameInstanceSubsystem:OnLanguageChanged']()
    f.flush()
    assert(f.view.text == '飲料 1 x 1' and f.view.language == 'zh-Hant')
    f.language, f.category = 'de', 'Native category'
    f.tick()
    assert(f.view.text == 'Native category #1 x 1' and f.view.language == 'de')
    assert(f.created == 1)
end)

test('attach after HUD arrives, hide empty claims, reuse existing row', function()
    local f = fixture(true)
    f.flush()
    assert(f.created == 0)
    f.candidate = f.owner
    f.tick()
    assert(f.created == 0)
    f.claim()
    f.tick()
    assert(f.created == 1 and f.view.text == 'Coffee x 1')
    f.entries = {}
    f.tick()
    assert(f.view.text == '')
    f.claim()
    f.tick()
    assert(f.created == 1 and f.view.text == 'Coffee x 1')
end)

test('missed native changes and locale changes reconcile without an event', function()
    local f = fixture(true)
    f.candidate = f.owner
    f.claim()
    f.flush()
    f.entries[1].state = 2
    f.tick()
    assert(f.view.text == '')
    f.entries[1].state = 0
    f.label = '咖啡'
    f.tick()
    assert(f.view.text == '咖啡 x 1')
end)

test('events are coalesced and never override game return values', function()
    local f = fixture(true)
    f.flush()
    for _, callback in pairs(f.hooks) do
        assert(callback() == nil)
        callback()
    end
    f.notify()
    assert(#f.pending == 1)
    f.flush()
    assert(#f.pending == 0)
end)

test('data failure clears stale quantity, suppresses repeated log, then recovers', function()
    local f = fixture(true)
    f.candidate = f.owner
    f.claim()
    f.flush()
    f.failure = 'world is unavailable'
    f.tick()
    assert(f.view.text == '')
    local count = #f.logs
    f.tick()
    assert(#f.logs == count)
    f.failure = nil
    f.tick()
    assert(f.view.text == 'Coffee x 1' and #f.logs == count + 1)
end)

test('travel removes only the old row and attaches to the new HUD', function()
    local f = fixture(true)
    f.candidate = f.owner
    f.claim()
    f.flush()
    local old_view = f.view
    f.owner.viewport = false
    f.candidate = nil
    f.tick()
    assert(f.removed == 1 and not old_view.valid)
    f.owner = { valid = true, active = true, IsInViewport = function() return true end }
    f.candidate = f.owner
    f.entries = {}
    f.tick()
    assert(f.created == 1)
    f.claim()
    f.tick()
    assert(f.created == 2 and f.view.owner == f.owner)
end)

test('inactive HUD still in viewport does not block a visible replacement', function()
    local f = fixture(true)
    f.candidate = f.owner
    f.claim()
    f.flush()
    local old_view = f.view
    f.owner.active = false
    local replacement = { valid = true, active = true, IsInViewport = function() return true end }
    f.candidate = replacement
    f.tick()
    assert(f.removed == 1 and not old_view.valid)
    assert(f.created == 2 and f.view.owner == replacement)
end)

test('unload stops queued refreshes, hooks, notifications and the old timer', function()
    local f = fixture(true)
    f.candidate = f.owner
    f.claim()
    local unload = ModRef.OnUnload
    unload()
    assert(f.removed == 0 and f.created == 0) -- no UObject work on the unload thread
    f.flush()
    assert(f.tick() == true and f.created == 0)
    for _, callback in pairs(f.hooks) do callback() end
    f.notify()
    assert(#f.pending == 0)
end)

original_print('Runtime lifecycle: ' .. passed .. ' tests passed')
