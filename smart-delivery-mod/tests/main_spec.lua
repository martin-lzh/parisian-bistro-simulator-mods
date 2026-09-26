local F = require('fakes')
local UI, Settings = require('ui'), require('settings')
local owner, hooks, current, writes, calls = F.owner(), {}, 'premium', 0, {}
local timer
Settings.load = function() return current end
Settings.save = function(_, value) current = value; writes = writes + 1 end
local fail = false
package.loaded.bridge = { new = function()
    return { calls = { disable = function() calls[#calls + 1] = 'disable' end },
        suspend = function() calls[#calls + 1] = 'suspend' end, call = function(_, name)
        calls[#calls + 1] = name
        if fail then error('Bridge failure') end
    end }
end }
RegisterHook = function(path, pre, post) hooks[path] = { pre = pre, post = post }; return 1, 2 end
UnregisterHook = function(path) hooks[path] = nil end
LoopInGameThreadWithDelay = function(_, fn) timer = fn end
FindAllOf = function(kind)
    if kind == 'WBP_MenuApp_C' then return { owner } end
    local found = {}
    for _, object in ipairs(F.objects) do
        if object.class == '/Script/UMG.' .. kind then found[#found + 1] = object end
    end
    return found
end
dofile(MOD_ROOT .. '/Scripts/main.lua')
assert(timer() == false and table.concat(calls, ',') == 'initialize,premium')
local combo = owner.panel.children[2].children[2]
local save = hooks['/Script/BrasserieSimulator.MenuAppWidget:SaveAutomaticSmartOrderSettings'].pre
local reset = hooks['/Script/BrasserieSimulator.MenuAppWidget:ResetAutomaticSmartOrderSettings'].post
local context = { get = function() return owner end }
-- A language API exception must never disable delivery or terminate its callbacks.
local find_object, previous_calls = StaticFindObject, #calls
StaticFindObject = function(path)
    local object = find_object(path)
    if path:find('KismetInternationalizationLibrary', 1, true) then
        object.GetCurrentLanguage = function() error('Language reader unavailable') end
    end
    return object
end
combo:SetSelectedIndex(0)
assert(timer() == false and #calls == previous_calls and next(hooks) ~= nil)
assert(owner.panel.children[2].children[1].text == 'Delivery method' and combo:GetSelectedIndex() == 0)
StaticFindObject, F.language = find_object, 'fr'
assert(timer() == false and #calls == previous_calls)
assert(owner.panel.children[2].children[1].text == 'Mode de livraison' and combo:GetSelectedIndex() == 0)
print('Runtime locale recovery: reader errors keep the bridge, hooks, timer and draft selection active')
combo:SetSelectedIndex(0); timer()
assert(current == 'premium' and writes == 0)
reset(context); assert(combo:GetSelectedIndex() == 2)
combo:SetSelectedIndex(1); save(context)
assert(current == 'budget' and writes == 1 and calls[#calls] == 'budget')
save(context); assert(writes == 1) -- repeated Save is idempotent
combo:SetSelectedIndex(0); owner.controller.authority = false; save(context)
assert(current == 'budget' and writes == 1)
owner.controller.authority = true; owner.locked = true; save(context)
assert(current == 'budget')
owner.locked = false; fail = true; save(context)
assert(current == 'budget' and calls[#calls] == 'disable' and #owner.panel.children == 2)
assert(timer() == true and next(hooks) == nil) -- failure stops future callbacks

-- Reload from an active selector while it contains an unsaved change.
fail = false
dofile(MOD_ROOT .. '/Scripts/main.lua')
timer()
combo = owner.panel.children[2].children[2]
combo:SetSelectedIndex(0)
local old_row = owner.panel.children[2]
local old_timer = timer
local old_save = hooks['/Script/BrasserieSimulator.MenuAppWidget:SaveAutomaticSmartOrderSettings'].pre
local old_reset = hooks['/Script/BrasserieSimulator.MenuAppWidget:ResetAutomaticSmartOrderSettings'].post
local before_unload = #calls
ModRef.OnUnload()
assert(#owner.panel.children == 3, 'Unload must leave widget operations to the game thread')
assert(calls[#calls] == 'suspend' and #calls == before_unload + 1)
assert(old_timer() == true)
old_save(context); old_reset(context)
assert(current == 'budget' and #calls == before_unload + 1)
dofile(MOD_ROOT .. '/Scripts/main.lua')
timer()
assert(#owner.panel.children == 3, 'Reload must replace rather than duplicate the selector')
assert(old_row:GetParent() == nil)
combo = owner.panel.children[2].children[2]
assert(combo:GetSelectedIndex() == 1 and calls[#calls] == 'budget')
assert(owner.panel.children[3] == owner.footer)
