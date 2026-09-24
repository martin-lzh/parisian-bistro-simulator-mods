local Localization = {}
local phrases = {
    en = 'Hold: take oldest first',
    fr = "Maintenir : prendre le plus ancien d’abord",
    ['zh-Hans'] = '长按：优先拿取最早制作的餐品',
    ['zh-Hant'] = '長按：優先拿取最早製作的餐點',
    it = 'Tieni premuto: ritira prima il più vecchio',
    es = 'Mantén pulsado: recoge primero el más antiguo',
    de = 'Halten: älteste Speise zuerst nehmen',
    ru = 'Удерживайте: сначала взять приготовленное раньше',
    ja = '長押し：先に作られたものから取る',
    ko = '길게 누르기: 먼저 만든 것부터 집기',
    tr = 'Basılı tut: önce en eski hazırlananı al',
    pl = 'Przytrzymaj: zabierz najpierw najstarsze',
    pt = 'Manter premido: recolher o mais antigo primeiro',
    ['pt-BR'] = 'Segure: pegue o mais antigo primeiro',
}

function Localization.hint(language)
    local code = type(language) == 'string' and language:lower():gsub('_', '-') or 'en'
    local base = code:match('^([a-z]+)')
    if base == 'zh' then
        if code:find('hans', 1, true) then base = 'zh-Hans'
        elseif code:find('hant', 1, true) or code:match('^zh%-[th][wk]') or code:match('^zh%-mo') then
            base = 'zh-Hant'
        else base = 'zh-Hans' end
    elseif code:match('^pt%-br') then base = 'pt-BR' end
    return phrases[base] or phrases.en
end

return Localization
