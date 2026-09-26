local Bridge, Planner = require('bridge'), require('planner')
local original_open, original_remove, original_load = io.open, os.remove, package.loadlib
local files, requests, mode = {}, {}, 'ok'
io.open = function(path, access)
    if access == 'r' and not files[path] then return nil end
    if access == 'w' then files[path] = '' end
    return {
        write = function(self, value) files[path] = files[path] .. value; return self end,
        read = function() return files[path] end,
        close = function() return true end,
    }
end
os.remove = function(path) files[path] = nil; return true end
package.loadlib = function(path, symbol)
    assert(path:match('auto_menu_bridge.dll$') and symbol == 'auto_menu_compose')
    return function()
        local directory = path:match('^(.*)/')
        requests[#requests + 1] = assert(files[directory .. '/auto-menu-request.txt'])
        if mode == 'throw' then error('Synthetic adapter exception') end
        if mode ~= 'missing' then
            files[directory .. '/auto-menu-result.txt'] = mode == 'ok' and 'ok 0.8 32 32 33 200 10 0 0.01 0 7 0 0 0' or mode
        end
    end
end
local owner = { GetAddress = function() return 0xabc end,
    GetDailyMenuProjection = function() return { EstimatedAdoptionRate = .123456789 } end }
local manager = { GetAddress = function() return 0xdef end }
local storage = { GetStructAddress = function() return 0x123 end }
local original = { Period = 2, bIsActive = true }
local domains = {}
for _, course in ipairs(Planner.courses) do original[course.field] = 0; domains[course.field] = {0,7} end
local function run() return Bridge.solve(owner, manager, storage, 2, original, domains, Planner.courses, .95) end
local result = run()
assert(result.menu.MainDish == 7 and result.menu.Period == 2 and result.menu.bIsActive)
assert(result.cache.checks == 33 and result.evaluations == 32 and result.cache.seconds == .01)
assert(requests[1]:find('abc def 123 2', 1, true))
assert(requests[1]:find(string.format('%.17g %.17g', .95, .123456789), 1, true))
for _, failure in ipairs({ 'missing', 'throw', 'error: Unsupported native menu ABI',
    'ok 0.8 32 32 33 200 10 0 0.01 0 99 0 0 0', 'ok 0.8 32 99 33 200 10 0 0.01 0 7 0 0 0' }) do
    mode = failure; assert(not pcall(run), 'Invalid/stale native response accepted')
    for path in pairs(files) do assert(not path:match('auto%-menu%-request.txt$'), 'Pointer request was retained') end
end
io.open, os.remove, package.loadlib = original_open, original_remove, original_load
print('Bridge: address/float serialization, fresh acknowledgments, result validation and request cleanup passed')
