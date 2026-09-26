-- Synthetic reflected-object fixtures; no captured game data.
local directory = debug.getinfo(1, 'S').source:sub(2):match('^(.*[/\\])')
package.path = directory .. '../Scripts/?.lua;' .. package.path
local Game = dofile(directory .. '../Scripts/game.lua')
local passed, next_address = 0, 0
local function object(fields)
    next_address = next_address + 1
    local address = next_address
    fields = fields or {}
    fields.IsValid = function(self) return self.invalid ~= true end
    fields.GetAddress = function() return address end
    return fields
end
local function fixture()
    local f = { data = {} }
    f.world = object()
    f.state = object({ GetPlayerId = function() return 37 end })
    f.owner = object({ PlayerState = f.state, is_local = true })
    function f.owner:IsLocalController() return self.is_local end
    function f.owner:GetWorld() return f.world end
    f.hud = object({ visible = true, viewport = true, template = false })
    function f.hud:HasAnyFlags() return self.template end
    function f.hud:IsInViewport() return self.viewport end
    function f.hud:IsVisible() return self.visible end
    function f.hud:GetOwningPlayer() return f.owner end
    function f.hud:GetWorld() return f.world end
    f.queue = object()
    function f.queue:GetArrayNum() return #f.data end
    function f.queue:ForEach(callback)
        for index, entry in ipairs(f.data) do
            callback(index, { get = function() return entry end })
        end
    end
    f.manager = object({ DrinksPrepareQueue = { Items = f.queue } })
    function f.manager:GetWorld() return f.manager_world or f.world end
    -- Calling this getter is a failure: returned struct views are not owned.
    function f.manager:GetDrinksPrepareQueue() error('temporary array getter used') end
    f.world_subsystem = object({ GetDrinkManager = function() return f.manager end })
    f.locale = object()
    function f.locale:GetDishTranslation(drink)
        return { ToString = function() return '本地名称 ' .. drink end }
    end
    function f.locale:GetUITranslation(key)
        assert(key == 'Drinks')
        return { ToString = function() return '本地类别' end }
    end
    f.language = 'zh-Hans'
    f.internationalization = object()
    function f.internationalization:GetCurrentLanguage()
        return { ToString = function() return f.language end }
    end
    local library = object()
    function library:GetWorldSubsystem(context, class)
        assert(context == f.hud)
        return class.name == 'WorldGameInstanceSubsystem' and f.world_subsystem or f.locale
    end
    StaticFindObject = function(path)
        if path == '/Script/Engine.Default__SubsystemBlueprintLibrary' then return library end
        if path == '/Script/Engine.Default__KismetInternationalizationLibrary' then
            return f.internationalization
        end
        return object({ name = path:match('%.([^%.]+)$') })
    end
    f.candidates = { f.hud }
    FindAllOf = function() return f.candidates end
    function f.add(id, drink, state, claimed, player)
        f.data[#f.data + 1] = {
            DrinkId = { A = id, B = 2, C = 3, D = 4 }, Drink = drink,
            State = state, bClaimedByPlayer = claimed, ClaimedPlayerId = player,
        }
    end
    return f
end
local function test(name, callback)
    local ok, err = pcall(callback)
    assert(ok, name .. ': ' .. tostring(err))
    passed = passed + 1
end

test('only a visible non-template local HUD is discoverable', function()
    local f = fixture()
    assert(Game.find_hud() == f.hud and Game.active(f.hud))
    f.hud.template = true
    assert(Game.find_hud() == nil)
    f.hud.template, f.owner.is_local = false, false
    assert(Game.find_hud() == nil)
    f.owner.is_local, f.hud.visible = true, false
    assert(Game.find_hud() == nil and not Game.active(f.hud))
    f.hud.visible, f.hud.viewport = true, false
    assert(Game.find_hud() == nil)
end)

test('snapshot copies primitive fields, keeps foreign entries for filtering, and localizes', function()
    local f = fixture()
    f.add(10, 8, 1, true, 37)
    f.add(11, 9, 0, false, -1)
    local entries, player, translate, language, category = Game.snapshot(f.hud)
    assert(player == 37 and #entries == 2)
    assert(entries[1].id == '10:2:3:4' and entries[1].drink == 8)
    assert(entries[1].claimed == true and entries[1].state == 1 and entries[1].player_id == 37)
    assert(entries[2].claimed == false and entries[2].player_id == -1)
    assert(translate(8) == '本地名称 8')
    assert(language == 'zh-Hans' and category == '本地类别')
    f.data[1].Drink, f.data[1].DrinkId.A = 99, 999
    assert(entries[1].drink == 8 and entries[1].id == '10:2:3:4')
    entries[2].state = 2
    assert(f.data[2].State == 0)
end)

test('current language is reread and never retained across read failures', function()
    local f = fixture()
    assert(Game.language() == 'zh-Hans')
    f.language = 'pt_BR'
    assert(Game.language() == 'pt-BR')
    f.internationalization.GetCurrentLanguage = function() return 'de-DE' end
    assert(Game.language() == 'de')
    f.internationalization.GetCurrentLanguage = function() error('not ready') end
    assert(Game.language() == 'en')
    f.internationalization.invalid = true
    assert(Game.language() == 'en')
end)

test('unavailable localization does not lose valid queue quantities', function()
    local f = fixture()
    f.add(10, 8, 1, true, 37)
    f.locale.invalid = true
    local entries, player, translate, language, category = Game.snapshot(f.hud)
    assert(#entries == 1 and player == 37 and language == 'zh-Hans')
    assert(category == nil and not pcall(translate, 8))
    f.locale.invalid = false
    f.locale.GetUITranslation = function() error('missing category') end
    local _, _, restored, _, missing_category = Game.snapshot(f.hud)
    assert(restored(8) == '本地名称 8' and missing_category == nil)
end)

test('reject data from another world and unavailable player state', function()
    local f = fixture()
    f.manager_world = object()
    assert(not pcall(Game.snapshot, f.hud))
    f.manager_world = nil
    f.state.invalid = true
    assert(not pcall(Game.snapshot, f.hud))
end)

test('malformed data fails visibly instead of producing a plausible partial quantity', function()
    local f = fixture()
    f.add(1, 4, 0, true, 37)
    f.add(2, 4, 0, 1, 37)
    assert(not pcall(Game.snapshot, f.hud))
    f.data[2].bClaimedByPlayer = true
    f.queue.GetArrayNum = function() return 3 end
    assert(not pcall(Game.snapshot, f.hud))
end)

test('a localization closure cannot access an inactive world', function()
    local f = fixture()
    local _, _, translate = Game.snapshot(f.hud)
    f.hud.visible = false
    assert(not pcall(translate, 8))
end)

test('ambiguous active HUDs wait rather than choosing a player arbitrarily', function()
    local f = fixture()
    local second = object()
    for key, value in pairs(f.hud) do
        if key ~= 'GetAddress' then second[key] = value end
    end
    f.candidates[2] = second
    assert(not pcall(Game.find_hud))
end)

print('Game adapter: ' .. passed .. ' tests passed')
