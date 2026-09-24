local F = require('fakes')
local UI, Settings = require('ui'), require('settings')
local owner, hooks, current, writes, calls = F.owner(), {}, 'premium', 0, {}
local timer
Settings.load = function() return current end
Settings.save = function(_, value) current = value; writes = writes + 1 end
local fail = false
package.loaded.bridge = { new = function()
    return { calls = { disable = function() calls[#calls + 1] = 'disable' end }, call = function(_, name)
        calls[#calls + 1] = name
        if fail then error('Bridge failure') end
    end }
end }
RegisterHook = function(path, pre, post) hooks[path] = { pre = pre, post = post }; return 1, 2 end
UnregisterHook = function(path) hooks[path] = nil end
LoopInGameThreadWithDelay = function(_, fn) timer = fn end
FindAllOf = function() return { owner } end
dofile(MOD_ROOT .. '/Scripts/main.lua')
assert(timer() == false and table.concat(calls, ',') == 'initialize,premium')
local combo = owner.panel.children[2].children[2]
local save = hooks['/Script/BrasserieSimulator.MenuAppWidget:SaveAutomaticSmartOrderSettings'].pre
local reset = hooks['/Script/BrasserieSimulator.MenuAppWidget:ResetAutomaticSmartOrderSettings'].post
local context = { get = function() return owner end }
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
