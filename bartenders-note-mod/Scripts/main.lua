local Game = require('game')
local Hud = require('hud')
local Summary = require('summary')
local Reload = require('reload')

local PREFIX = "[Bartender's Note] "
local function log(message) print(PREFIX .. message .. '\n') end

-- UE 5.4 requires a current UE4SS experimental build. Do not install a legacy
-- timer fallback that would accidentally read UObjects on a worker thread.
if type(LoopInGameThreadWithDelay) ~= 'function'
    or type(ExecuteInGameThreadWithDelay) ~= 'function' then
    log('Disabled: requires UE4SS experimental with game-thread delayed actions. See README.md.')
    return
end

local owner, view, last_error
local queued = false
local lifetime = Reload.new('BartendersNote.widgets.v1')

local function discard()
    if view then pcall(Hud.destroy, view) end
    owner, view = nil, nil
end

local function refresh()
    lifetime:cleanup()
    if not Game.active(owner) then
        discard()
        owner = Game.find_hud()
    end
    if not Game.valid(owner) then return end

    local entries, player_id, translate, language, native_category = Game.snapshot(owner)
    local summary = Summary.collect(entries, player_id, translate, language, native_category)
    if view and not Hud.valid(view) then
        Hud.destroy(view)
        view = nil
    end
    if not view and summary.total > 0 then view = Hud.create(owner, lifetime) end
    if view then Hud.update(view, summary.groups, language) end
end

local function safe_refresh()
    if lifetime.stopped then return true end
    local ok, problem = pcall(refresh)
    if ok then
        if last_error then log('HUD connection restored.') end
        last_error = nil
    else
        -- Never leave an old quantity visible after losing the data source.
        if view then pcall(Hud.update, view, {}) end
        problem = tostring(problem)
        if problem ~= last_error then log('HUD unavailable: ' .. problem) end
        last_error = problem
    end
end

local function request_refresh()
    if lifetime.stopped or queued then return end
    queued = true
    ExecuteInGameThreadWithDelay(50, function()
        queued = false
        safe_refresh()
    end)
end

-- Hooks accelerate reflected changes. Native C++ calls and replicated fast
-- arrays can bypass UFunction hooks, so reconcile periodically as well.
local hook_paths = {
    '/Script/BrasserieSimulator.DrinkManager:UpdateWidgetDrinkQueue',
    '/Script/BrasserieSimulator.DrinkManager:ClaimPendingDrinkForPlayer',
    '/Script/BrasserieSimulator.DrinkManager:UnclaimPendingDrinkForPlayer',
    '/Script/BrasserieSimulator.DrinkManager:CancelDrinkOrder',
    '/Script/BrasserieSimulator.DrinkManager:TryOrderDrink',
    '/Script/BrasserieSimulator.LocaleGameInstanceSubsystem:OnLanguageChanged',
}
for _, path in ipairs(hook_paths) do
    local ok, problem = pcall(RegisterHook, path, function() end, function()
        request_refresh()
    end)
    if not ok then log('Event hook unavailable; reconciliation remains active: ' .. tostring(problem)) end
end

NotifyOnNewObject('/Game/UI/HUD/WBP_HUD.WBP_HUD_C', function()
    -- Widget construction notifications run before the tree is ready. Delay
    -- all inspection until the game thread can finish initializing the HUD.
    request_refresh()
end)

LoopInGameThreadWithDelay(750, safe_refresh)
request_refresh()
log('Loaded version=0.1.2-dev. Waiting for the local player HUD.')
