local Reload = dofile(MOD_ROOT .. '/Scripts/reload.lua')
local construct, suspensions = Reload.new, 0
Reload.new = function(key)
    return construct(key, function() suspensions = suspensions + 1 end)
end
local shared, game_thread, removals = {}, true, {}
ModRef = {
    GetSharedVariable = function(_, key) return shared[key] end,
    SetSharedVariable = function(_, key, value)
        assert(type(value) == 'string', 'Transient values must not cross Lua states')
        shared[key] = value
    end,
}
local function widget(name, address, valid)
    return {
        GetFullName = function() assert(game_thread); return name end,
        GetAddress = function() assert(game_thread); return address end,
        IsValid = function() assert(game_thread); return valid ~= false end,
        RemoveFromParent = function() assert(game_thread); removals[address] = (removals[address] or 0) + 1 end,
    }
end
local root, probe = widget('Border HUD.Tree.ModRow', 10), widget('TextBlock HUD.Tree.Probe', 20)
local impostor = widget('Border HUD.Tree.ModRow', 99)
FindAllOf = function(kind)
    assert(game_thread)
    return kind == 'Border' and { root, impostor } or { probe }
end
local first = Reload.new('widgets')
first:cleanup()
first:remember('Border', root); first:remember('TextBlock', probe)
local unload = ModRef.OnUnload
game_thread = false
unload()
assert(first.stopped and next(removals) == nil and suspensions == 1)
local second = Reload.new('widgets') -- startup is also allowed off-thread
assert(not second.stopped)
game_thread = true
second:cleanup()
assert(removals[10] == 1 and removals[20] == 1 and removals[99] == nil)
second:cleanup()
assert(removals[10] == 1 and shared.widgets == '')
local token = second:remember('Border', root)
second:forget(token)
ModRef.OnUnload()
Reload.new('widgets'):cleanup()
assert(removals[10] == 1, 'Normal destruction must remove its reload record')

-- A failed removal is retried before new views are allowed to attach.
local failing = true
local failed = widget('Border failing', 30)
failed.RemoveFromParent = function() if failing then error('temporarily unavailable') end; removals[30] = 1 end
local fourth = Reload.new('retry')
fourth:remember('Border', failed)
FindAllOf = function() return { failed } end
local fifth = Reload.new('retry')
assert(not pcall(function() fifth:cleanup() end) and fifth.pending)
failing = false
fifth:cleanup()
assert(removals[30] == 1 and shared.retry == '')
print('Reload lifecycle: primitive handoff, exact widget identity, retry and idempotence passed')
