-- Original mod-only wording. Game drink names and category labels stay native.
local Localization = {}
local phrases = {
    en = { drink = 'Drink %d', more = '... + %d more' },
    fr = { drink = 'Boisson %d', more = '... encore %d' },
    ['zh-Hans'] = { drink = '饮料 %d', more = '... 另有%d种' },
    ['zh-Hant'] = { drink = '飲料 %d', more = '... 另有%d種' },
    it = { drink = 'Bevanda %d', more = '... %d in più' },
    es = { drink = 'Bebida %d', more = '... + %d más' },
    de = { drink = 'Getränk %d', more = '... + %d weitere' },
    ru = { drink = 'Напиток %d', more = '... ещё %d' },
    ja = { drink = '飲み物 %d', more = '... ほか%d種類' },
    ko = { drink = '음료 %d', more = '... 외 %d종' },
    tr = { drink = 'İçecek %d', more = '... %d çeşit daha' },
    pl = { drink = 'Napój %d', more = '... + %d więcej' },
    pt = { drink = 'Bebida %d', more = '... + mais %d' },
    ['pt-BR'] = { drink = 'Bebida %d', more = '... + mais %d' },
}

function Localization.resolve(language)
    if type(language) ~= 'string' then return 'en' end
    local code = language:lower():gsub('_', '-'):match('^%s*(.-)%s*$')
    if not code:match('^[a-z][a-z0-9%-]*$') or code:find('--', 1, true)
        or code:sub(-1) == '-' then return 'en' end
    local base = code:match('^([a-z]+)%-') or code:match('^([a-z]+)$')
    if base == 'zh' then
        -- An explicit script takes precedence over the region, as in zh-Hans-TW.
        for part in code:gmatch('[^-]+') do
            if part == 'hans' then return 'zh-Hans' end
            if part == 'hant' then return 'zh-Hant' end
        end
        for part in code:gmatch('[^-]+') do
            if part == 'tw' or part == 'hk' or part == 'mo' then return 'zh-Hant' end
        end
        return 'zh-Hans'
    end
    if code == 'pt-br' or code:sub(1, 6) == 'pt-br-' then return 'pt-BR' end
    return phrases[base] and base or 'en'
end

function Localization.drink(drink, language, native_category)
    if type(native_category) == 'string' then
        native_category = native_category:gsub('%s+', ' '):match('^%s*(.-)%s*$')
        if native_category ~= '' then return native_category .. ' #' .. string.format('%.0f', drink) end
    end
    return string.format(phrases[Localization.resolve(language)].drink, drink)
end

function Localization.more(count, language)
    return string.format(phrases[Localization.resolve(language)].more, count)
end

return Localization
