-- Runtime task selection only; never edit saved employee exclusions or claims.
local AI = {}
AI.__index = AI

function AI.new(game, checkpoint)
    return setmetatable({ game = game, removed = {}, checkpoint = checkpoint or function() end }, AI)
end

function AI:active()
    return next(self.removed) ~= nil
end

local function read(array)
    local result = {}
    for index = 1, array:GetArrayNum() do result[index] = array[index] end
    return result
end

local function replace(array, values, game)
    -- Evaluators are UObject pointers, retained by JobSubsystem.AllEvaluators.
    -- Rebuild on the game thread, preserving the order of every other task.
    array:Empty()
    for index, value in ipairs(values) do array[index] = value end
    assert(array:GetArrayNum() == #values, 'AI evaluator array size mismatch')
    for index, value in ipairs(values) do
        assert(game.valid(array[index]) and game.identity(array[index]) == game.identity(value),
            'AI evaluator array verification failed')
    end
end

local function replace_or_rollback(array, values, original, game)
    local ok, err = pcall(replace, array, values, game)
    if not ok then
        local restored, restore_error = pcall(replace, array, original, game)
        error(tostring(err) .. (restored and '; array rolled back'
            or '; array rollback failed: ' .. tostring(restore_error)))
    end
end

function AI:sync(contexts, billing_class)
    local game, suppressed, containers = self.game, 0, 0
    for _, context in ipairs(contexts) do
        local retained = {}
        for _, evaluator in ipairs(read(context.evaluators)) do
            if game.valid(evaluator) then retained[game.identity(evaluator)] = true end
        end
        for _, container in ipairs(context.containers) do
            containers = containers + 1
            local id = game.identity(container)
            local original, kept, removed = read(container.Evaluators), {}, {}
            for index, evaluator in ipairs(original) do
                assert(game.valid(evaluator), 'Invalid AI evaluator in ' .. id)
                if evaluator:IsA(billing_class) then
                    local evaluator_id = game.identity(evaluator)
                    assert(retained[evaluator_id], 'Billing evaluator is not retained by its job subsystem')
                    removed[#removed + 1] = { id = evaluator_id, index = index }
                else
                    kept[#kept + 1] = evaluator
                end
            end
            if #removed > 0 then
                -- Record identities before mutation so even a partial write can
                -- be recovered; no Unreal wrappers survive this scan.
                local record = self.removed[id] or { owner = context.id, tasks = {} }
                local known = {}
                for _, task in ipairs(record.tasks) do known[task.id] = true end
                for _, task in ipairs(removed) do
                    if not known[task.id] then
                        record.tasks[#record.tasks + 1] = task
                        known[task.id] = true
                    end
                end
                self.removed[id] = record
                record.recovery = {}
                for index, evaluator in ipairs(original) do record.recovery[index] = game.identity(evaluator) end
                self.checkpoint() -- Persist recovery before touching the engine-owned array.
                replace_or_rollback(container.Evaluators, kept, original, game)
                record.recovery = nil
                self.checkpoint()
            end
            if self.removed[id] then suppressed = suppressed + 1 end
        end
    end
    return string.format('policy=exclude-counter-billing subsystems=%d containers=%d suppressed=%d',
        #contexts, containers, suppressed)
end

function AI:restore(contexts, retain_missing)
    local game, present, errors, restored = self.game, {}, {}, 0
    for _, context in ipairs(contexts) do
        for _, container in ipairs(context.containers) do
            local id = game.identity(container)
            local record = self.removed[id]
            if record and record.owner == context.id then
                present[id] = true
                local ok, err = pcall(function()
                    local available = {}
                    for _, evaluator in ipairs(read(context.evaluators)) do
                        if game.valid(evaluator) then available[game.identity(evaluator)] = evaluator end
                    end
                    local original = read(container.Evaluators)
                    local current, existing, added = { table.unpack(original) }, {}, false
                    if record.recovery then
                        current, added = {}, true
                        for index, evaluator_id in ipairs(record.recovery) do
                            current[index] = assert(available[evaluator_id], 'Missing evaluator for array recovery')
                        end
                    end
                    for _, evaluator in ipairs(current) do existing[game.identity(evaluator)] = true end
                    for _, task in ipairs(record.tasks) do
                        if not existing[task.id] then
                            local evaluator = assert(available[task.id], 'Missing retained billing evaluator')
                            table.insert(current, math.min(task.index, #current + 1), evaluator)
                            existing[task.id], added = true, true
                        end
                    end
                    if added then
                        record.recovery = {}
                        for index, evaluator in ipairs(current) do record.recovery[index] = game.identity(evaluator) end
                        self.checkpoint()
                        replace_or_rollback(container.Evaluators, current, original, game)
                    end
                end)
                if ok then
                    self.removed[id] = nil
                    self.checkpoint()
                    restored = restored + 1
                else
                    errors[#errors + 1] = id .. ': ' .. tostring(err)
                end
            end
        end
    end
    for id in pairs(self.removed) do
        if not present[id] then
            if retain_missing then
                errors[#errors + 1] = id .. ': reload recovery container is unavailable'
            else
                self.removed[id] = nil -- destroyed world/container after normal session travel
                self.checkpoint()
            end
        end
    end
    assert(#errors == 0, table.concat(errors, '; '))
    return restored
end

return AI
