local Settings = require('settings')
local path = TEST_DIR .. '/preference.txt'
assert(Settings.load(path) == 'premium')
for _, choice in ipairs(Settings.modes) do
    Settings.save(path, choice)
    assert(Settings.load(path) == choice)
end
assert(not pcall(Settings.save, path, 'other'))
assert(not pcall(Settings.save, TEST_DIR .. '/missing/path.txt', 'free'))
local f = assert(io.open(path, 'w')); f:write('os.execute("no")'); f:close()
assert(not pcall(Settings.load, path))
f = assert(io.open(path, 'w')); f:write('  budget\n'); f:close()
assert(Settings.load(path) == 'budget')
assert(os.rename(path, path .. '.bak'))
assert(Settings.load(path) == 'budget') -- interrupted replacement recovery
Settings.save(path, 'free')
assert(Settings.load(path) == 'free')
local label = require('localization')
for _, language in ipairs({ 'en', 'fr', 'zh-Hans', 'it', 'es', 'de', 'ru', 'ja', 'ko', 'zh-Hant', 'tr', 'pl', 'pt', 'pt-BR' }) do
    assert(type(label(language)) == 'string' and #label(language) > 0)
end
assert(label('zh_TW') == '配送方式' and label('zh-CN') == '配送方式')
assert(label('unknown') == label('en'))
