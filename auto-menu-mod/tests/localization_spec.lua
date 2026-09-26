local text = require('localization')
for _, code in ipairs({ 'en', 'fr', 'zh-Hans', 'it', 'es', 'de', 'ru', 'ja', 'ko', 'zh-Hant', 'tr', 'pl', 'pt', 'pt-BR' }) do
    for _, key in ipairs({ 'button', 'tooltip' }) do
        assert(type(text(code)[key]) == 'string' and #text(code)[key] > 0)
    end
    assert(text(code).searching == nil and text(code).changed == nil)
end
assert(text('zh_Hans_TW').button == text('zh-Hans').button)
assert(text('ZH_hant_CN').button == text('zh-Hant').button)
assert(text('pt_br').button == text('pt-BR').button)
assert(text('de-DE').button == text('de').button)
assert(text('unsupported').button == text('en').button)
print('Localization: 14 cultures, scripts, regional aliases and fallback passed')
