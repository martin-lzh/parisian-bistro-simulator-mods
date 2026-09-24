local Localization = require('localization')
local Game = require('game')
local count = 0
local function test(name, fn)
    fn()
    count = count + 1
    print('PASS ' .. name)
end

test('all fourteen supported languages provide every original message', function()
    local keys = { 'host_active', 'ai_restore_failed', 'ai_schedule_failed',
        'stopped', 'notification_unavailable', 'no_progress' }
    local locale, english = Localization.new(), Localization.new()
    for _, language in ipairs({ 'en', 'fr', 'zh-Hans', 'it', 'es', 'de', 'ru',
        'ja', 'ko', 'zh-Hant', 'tr', 'pl', 'pt', 'pt-BR' }) do
        locale:refresh(function() return language end)
        assert(locale.language == language, language)
        for _, key in ipairs(keys) do
            local value = locale:text(key)
            assert(type(value) == 'string' and value ~= '' and value ~= key, language .. '/' .. key)
            if language ~= 'en' then
                assert(value ~= english:text(key), 'unexpected English fallback: ' .. language .. '/' .. key)
            end
        end
    end
end)

test('culture aliases preserve scripts and distinguish Portuguese variants', function()
    local cases = {
        ['EN_us'] = 'en', [' fr-FR '] = 'fr', ['de-AT'] = 'de', ['es-MX'] = 'es',
        ['zh'] = 'zh-Hans', ['zh-CN'] = 'zh-Hans', ['zh-SG'] = 'zh-Hans',
        ['zh_TW'] = 'zh-Hant', ['zh-HK'] = 'zh-Hant', ['zh-MO'] = 'zh-Hant',
        ['zh-Hans-TW'] = 'zh-Hans', ['zh-Hant-CN'] = 'zh-Hant',
        ['pt'] = 'pt', ['pt-PT'] = 'pt', ['PT_br'] = 'pt-BR', ['pt-BR-extra'] = 'pt-BR',
        ['nl-NL'] = 'en', [''] = 'en', ['fr???'] = 'en', ['zh$garbage'] = 'en',
        ['fr--FR'] = 'en', ['fr-'] = 'en', ['fr_fr!'] = 'en',
    }
    for input, expected in pairs(cases) do assert(Localization.normalize(input) == expected, input) end
    assert(Localization.normalize(nil) == 'en' and Localization.normalize({}) == 'en')
end)

test('language reader is independent of the world and handles both FString representations', function()
    local saved_find, saved_all = StaticFindObject, FindAllOf
    local current, valid, calls = 'zh-Hant', true, 0
    FindAllOf = function() error('language lookup must not discover a world') end
    StaticFindObject = function(path)
        assert(path == '/Script/Engine.Default__KismetInternationalizationLibrary')
        calls = calls + 1
        return {
            IsValid = function() return valid end,
            GetCurrentLanguage = function() return current end,
        }
    end
    assert(Game.language() == 'zh-Hant')
    current = { ToString = function() return 'pt-BR' end }
    assert(Game.language() == 'pt-BR' and calls == 2, 'the library must be resolved anew')
    valid = false
    assert(Game.language() == nil)
    valid, current = true, nil
    assert(Game.language() == nil)
    current = { ToString = function() error('FString bridge unavailable') end }
    assert(Game.language() == nil)
    StaticFindObject = function() error('reflection unavailable') end
    assert(Game.language() == nil)
    StaticFindObject = nil
    assert(Game.language() == nil)
    StaticFindObject, FindAllOf = saved_find, saved_all
end)

test('failed or unsupported language reads fall back and recover on the next refresh', function()
    local locale = Localization.new()
    locale:refresh(function() return 'ja-JP' end)
    assert(locale.language == 'ja')
    locale:refresh(function() error('language API failed') end)
    assert(locale.language == 'en')
    locale:refresh(function() return 'unknown' end)
    assert(locale.language == 'en')
    locale:refresh(nil)
    assert(locale.language == 'en')
    locale:refresh(function() return 'ko-KR' end)
    assert(locale.language == 'ko')
end)

test('runtime language switching preserves checkout, diagnostic fields and exception details', function()
    local saved_game, saved_print = package.loaded.game, print
    local saved_loop, saved_hook = LoopInGameThreadWithDelay, RegisterHook
    local logs, callback, requests, language_reads = {}, nil, 0, 0
    local language, broken_language, broken_checkout = 'zh-Hans', false, false
    local session = { id = 'world-one', now = 0 }
    local snapshot = { id = 'register', payment_id = 'cash', has_bill = true, method = 'cash' }
    package.loaded.game = {
        language = function()
            language_reads = language_reads + 1
            if broken_language then error('injected language failure') end
            return language
        end,
        contract = function() return {} end,
        session = function()
            if broken_checkout then error('original raw checkout failure') end
            return session
        end,
        ai_contexts = function() return {} end,
        registers = function() return { {} }, 1 end,
        identity = function() return 'register' end,
        snapshot = function() return snapshot end,
        request = function(_, _, _, _, _, on_dispatch)
            requests = requests + 1
            on_dispatch('cash', 57)
            return true
        end,
    }
    LoopInGameThreadWithDelay = function(_, fn) callback = fn end
    RegisterHook = function() return 1, 2 end
    print = function(text) logs[#logs + 1] = text end
    dofile(MOD_ROOT .. '/Scripts/main.lua')
    assert(language_reads == 0, 'startup must not invoke reflection outside the game-thread callback')
    callback()
    assert(requests == 1 and language_reads == 1)
    assert(table.concat(logs):find('HOST 房主自动结账已启用。 session=world-one', 1, true))
    language = 'fr-FR'
    for now = 3, 9, 3 do session.now = now; callback() end
    assert(requests == 3)
    local text = table.concat(logs, '\n')
    assert(text:find('WARN Aucune progression après trois requêtes', 1, true))
    assert(text:find('phase=take register=register', 1, true))
    assert(text:find('REQUEST phase=take attempt=1 target=cash action=57', 1, true))
    assert(text:find('acceptance=unconfirmed', 1, true))
    broken_language, session.id, session.now = true, 'world-two', 0
    callback()
    assert(requests == 4, 'a language failure must not stop checkout')
    assert(table.concat(logs):find('HOST Host checkout active. session=world-two', 1, true))
    broken_language, language, session.id = false, 'de-DE', 'world-three'
    callback()
    assert(requests == 5)
    assert(table.concat(logs):find('HOST Automatisches Kassieren für den Host aktiv.', 1, true))
    broken_checkout = true
    callback()
    assert(logs[#logs]:find('ERROR Nach einem Fehler angehalten', 1, true))
    assert(logs[#logs]:find('stage=session', 1, true))
    assert(logs[#logs]:find('original raw checkout failure', 1, true))
    assert(logs[#logs]:find('stack traceback', 1, true))
    callback()
    assert(requests == 5)
    package.loaded.game, print = saved_game, saved_print
    LoopInGameThreadWithDelay, RegisterHook = saved_loop, saved_hook
end)

print(string.format('Localization: %d tests passed', count))
