-- Original phrase contracts with synthetic labels; no captured game text.
local directory = debug.getinfo(1, 'S').source:sub(2):match('^(.*[/\\])')
package.path = directory .. '../Scripts/?.lua;' .. package.path
local Localization = require('localization')
local Layout = require('layout')
local passed = 0
local function test(name, body)
    local ok, problem = pcall(body)
    assert(ok, name .. ': ' .. tostring(problem))
    passed = passed + 1
end

local languages = {
    'en', 'fr', 'zh-Hans', 'it', 'es', 'de', 'ru', 'ja', 'ko', 'zh-Hant', 'tr', 'pl', 'pt', 'pt-BR',
}

test('all game languages provide intact numbered fallback and hidden-type marker', function()
    for _, language in ipairs(languages) do
        assert(Localization.resolve(language) == language)
        local drink, more = Localization.drink(42, language), Localization.more(12, language)
        assert(utf8.len(drink) and utf8.len(more))
        assert(drink:find('42', 1, true) and more:find('12', 1, true))
        assert(not drink:find('[\r\n]') and not more:find('[\r\n]'))
        if language ~= 'en' then
            assert(drink ~= Localization.drink(42, 'en'))
            assert(more ~= Localization.more(12, 'en'))
        end
        assert(Localization.drink(42, language, 'Runtime label') == 'Runtime label #42')
    end
end)

test('normalize regional culture aliases with explicit script precedence', function()
    local aliases = {
        [' EN_us '] = 'en', ['fr-CA'] = 'fr', ['de-DE'] = 'de', ['es-MX'] = 'es',
        ['it-IT'] = 'it', ['ru-RU'] = 'ru', ['ja-JP'] = 'ja', ['ko-KR'] = 'ko',
        ['tr-TR'] = 'tr', ['pl-PL'] = 'pl', ['pt-PT'] = 'pt', ['PT_br'] = 'pt-BR',
        ['pt-BR-x-test'] = 'pt-BR', ['zh'] = 'zh-Hans', ['zh-CN'] = 'zh-Hans',
        ['zh_SG'] = 'zh-Hans', ['zh-TW'] = 'zh-Hant', ['zh-HK'] = 'zh-Hant',
        ['zh-MO'] = 'zh-Hant', ['zh-Hans-TW'] = 'zh-Hans', ['zh-Hant-CN'] = 'zh-Hant',
        ['zh-Hans-Hant'] = 'zh-Hans', ['zh-Hant-Hans'] = 'zh-Hant',
    }
    for input, expected in pairs(aliases) do assert(Localization.resolve(input) == expected, input) end
    for _, input in ipairs({ '', 'unsupported', 'enough', 'ptbr', 'de@bad', 'fr???', 'zh$garbage',
        'fr--CA', 'zh-', 17, false, {} }) do
        assert(Localization.resolve(input) == 'en')
    end
    assert(Localization.resolve(nil) == 'en')
end)

test('all localized markers are measured while preserving counts and at most two lines', function()
    local groups = {}
    for index = 1, 13 do groups[index] = { name = '字é', count = index * 10 } end
    for _, language in ipairs(languages) do
        for _, width in ipairs({ 1, 12, 20, 31, 55, 180 }) do
            local function measure(text)
                local result = 0
                for _, code in utf8.codes(text) do result = result + (code > 255 and 2 or 1) end
                return result
            end
            local result = Layout.format(groups, width, measure, language)
            assert(#result.lines <= 2 and result.shown + result.hidden == #groups)
            for _, line in ipairs(result.lines) do assert(measure(line) <= width) end
            if result.text ~= '' and result.hidden > 0 then
                assert(result.text:find(Localization.more(result.hidden, language), 1, true))
            end
        end
    end
end)

test('changing only language reflows the same groups with the new marker width', function()
    local groups = {}
    for index = 1, 5 do groups[index] = { name = 'A', count = 1 } end
    local english = Layout.format(groups, 15, utf8.len, 'en')
    local chinese = Layout.format(groups, 15, utf8.len, 'zh-Hans')
    assert(english.text ~= chinese.text)
    assert(chinese.text:find(Localization.more(chinese.hidden, 'zh-Hans'), 1, true))
    local hidden = Layout.format(groups, 1, utf8.len, 'ja')
    assert(hidden.text == '' and hidden.hidden == #groups)
end)

test('singular and multiple hidden types use count-independent grammar', function()
    assert(Localization.more(1, 'fr') == '... encore 1')
    assert(Localization.more(12, 'fr') == '... encore 12')
    assert(Localization.more(1, 'it') == '... 1 in più')
    assert(Localization.more(12, 'it') == '... 12 in più')
end)

print('Localization: ' .. passed .. ' tests passed')
