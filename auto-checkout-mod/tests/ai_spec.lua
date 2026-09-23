local AI = require('ai')
local count = 0
local function test(name, fn)
    fn()
    count = count + 1
    print('PASS ' .. name)
end

local function object(id, kind)
    return { id = id, IsA = function(_, class) return kind == class end }
end
local game = { valid = function(o) return o and not o.invalid end, identity = function(o) return o.id end }
local function array(values)
    local data = { table.unpack(values) }
    local result = { writes = 0, empties = 0 }
    function result:GetArrayNum() return #data end
    function result:Empty() data = {}; self.empties = self.empties + 1 end
    return setmetatable(result, {
        __index = function(_, index)
            if type(index) ~= 'number' then return nil end
            assert(index <= #data); return data[index]
        end,
        __newindex = function(self, index, value)
            if type(index) ~= 'number' then rawset(self, index, value); return end
            if self.fail_index == index then
                self.fail_count = (self.fail_count or 1) - 1
                if self.fail_count == 0 then self.fail_index = nil end
                error('injected array write failure')
            end
            self.writes = self.writes + 1
            data[index] = value
        end,
    })
end
local function fixture()
    local f = { ai = AI.new(game) }
    f.drink = object('drink', 'Drink')
    f.billing = object('billing', 'CounterBilling')
    f.table_billing = object('table', 'TableBilling')
    f.container = object('bartender')
    f.container.Evaluators = array({ f.drink, f.billing, f.table_billing })
    f.context = { id = 'job-world', containers = { f.container },
        evaluators = array({ f.drink, f.billing, f.table_billing }) }
    f.contexts = { f.context }
    function f.sync() return f.ai:sync(f.contexts, 'CounterBilling') end
    return f
end

test('AI excludes only counter billing and preserves other tasks, order and ownership', function()
    local f = fixture()
    assert(f.sync():find('suppressed=1', 1, true))
    local tasks = f.container.Evaluators
    assert(tasks:GetArrayNum() == 2 and tasks[1] == f.drink and tasks[2] == f.table_billing)
    assert(f.context.evaluators:GetArrayNum() == 3 and f.context.evaluators[2] == f.billing)
    local writes = tasks.writes
    f.sync()
    assert(tasks.writes == writes and tasks.empties == 1, 'unchanged polls must not rewrite arrays')
    assert(f.ai:restore(f.contexts) == 1)
    assert(tasks:GetArrayNum() == 3 and tasks[2] == f.billing and not f.ai:active())
end)

test('AI restore preserves unrelated runtime edits and does not duplicate restored tasks', function()
    local f = fixture()
    f.sync()
    local tasks = f.container.Evaluators
    local other = object('new-task', 'Other')
    tasks[3] = other
    f.ai:restore(f.contexts)
    assert(tasks:GetArrayNum() == 4 and tasks[2] == f.billing and tasks[4] == other)
    assert(f.ai:restore(f.contexts) == 0 and tasks:GetArrayNum() == 4)
end)

test('late task containers and reintroduced counter billing are suppressed on the next scan', function()
    local f = fixture()
    f.sync()
    f.container.Evaluators[3] = f.billing
    local another = object('new-container')
    another.Evaluators = array({ f.billing, f.drink })
    f.context.containers[2] = another
    assert(f.sync():find('suppressed=2', 1, true))
    assert(another.Evaluators:GetArrayNum() == 1 and another.Evaluators[1] == f.drink)
    assert(f.ai:restore(f.contexts) == 2)
    assert(f.container.Evaluators:GetArrayNum() == 3 and another.Evaluators[1] == f.billing)
end)

test('AI policy retains only identities and indexes between scans', function()
    local f = fixture()
    f.sync()
    local function plain(value)
        if type(value) == 'table' then
            for key, item in pairs(value) do plain(key); plain(item) end
        else
            assert(type(value) == 'number' or type(value) == 'string')
        end
    end
    plain(f.ai.removed)
    f.ai:restore({})
    assert(not f.ai:active(), 'destroyed worlds must not leave stale records')
end)

test('AI refuses to remove an evaluator without a native retention reference', function()
    local f = fixture()
    f.context.evaluators = array({ f.drink, f.table_billing })
    assert(not pcall(f.sync))
    assert(f.container.Evaluators:GetArrayNum() == 3 and not f.ai:active())
end)

test('partial array writes roll back all original task entries before stopping', function()
    local f = fixture()
    f.container.Evaluators.fail_index = 2
    local ok, err = pcall(f.sync)
    assert(not ok and tostring(err):find('array rolled back', 1, true))
    local tasks = f.container.Evaluators
    assert(tasks:GetArrayNum() == 3 and tasks[1] == f.drink and tasks[2] == f.billing
        and tasks[3] == f.table_billing)
    assert(f.ai:restore(f.contexts) == 1 and tasks:GetArrayNum() == 3)
end)

test('restore failures remain tracked and can be retried', function()
    local f = fixture()
    f.sync()
    f.context.evaluators = array({ f.drink, f.table_billing })
    assert(not pcall(function() f.ai:restore(f.contexts) end) and f.ai:active())
    f.context.evaluators = array({ f.drink, f.billing, f.table_billing })
    assert(f.ai:restore(f.contexts) == 1 and not f.ai:active())
end)

test('a failed rollback retains enough identities to recover every original task', function()
    local f = fixture()
    local tasks = f.container.Evaluators
    tasks.fail_index, tasks.fail_count = 2, 2
    local ok, err = pcall(f.sync)
    assert(not ok and tostring(err):find('array rollback failed', 1, true))
    assert(tasks:GetArrayNum() == 1)
    assert(f.ai:restore(f.contexts) == 1)
    assert(tasks:GetArrayNum() == 3 and tasks[1] == f.drink and tasks[2] == f.billing
        and tasks[3] == f.table_billing)
end)

test('an interrupted restore preserves non-billing tasks and can complete on retry', function()
    local f = fixture()
    f.sync()
    local tasks = f.container.Evaluators
    tasks.fail_index = 2
    assert(not pcall(function() f.ai:restore(f.contexts) end))
    assert(f.ai:active() and tasks:GetArrayNum() == 2 and tasks[1] == f.drink and tasks[2] == f.table_billing)
    assert(f.ai:restore(f.contexts) == 1 and tasks:GetArrayNum() == 3)
end)

print(string.format('AI policy: %d tests passed', count))
