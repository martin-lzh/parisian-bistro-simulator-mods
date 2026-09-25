-- Process-local handoff contains primitives only. Never evaluate saved Lua.
local Reload = {}
Reload.__index = Reload
local KEY = 'ParisianBistroMods.AutoCheckout.ReloadState'
local HEADER, MAX_BYTES, MAX_ITEMS = 'ACR1\n', 4 * 1024 * 1024, 100000

local function finite(value)
    return type(value) == 'number' and value == value and math.abs(value) < math.huge
end

local function string_value(value)
    assert(type(value) == 'string' and #value > 0 and #value <= 65536
        and not value:find('\0', 1, true), 'Invalid reload identity')
end

local function fields(value, allowed)
    assert(type(value) == 'table' and getmetatable(value) == nil, 'Invalid reload record')
    for key in pairs(value) do assert(allowed[key], 'Unknown reload field: ' .. tostring(key)) end
end

local function array(value, check)
    assert(type(value) == 'table' and getmetatable(value) == nil, 'Invalid reload array')
    local count = 0
    for key, item in pairs(value) do
        assert(math.type(key) == 'integer' and key >= 1 and key <= #value, 'Invalid reload array index')
        check(item)
        count = count + 1
    end
    assert(count == #value, 'Incomplete reload array')
end

local function validate(state)
    fields(state, { session = true, registers = true, removed = true })
    if state.session ~= nil then string_value(state.session) end
    assert(type(state.registers) == 'table' and type(state.removed) == 'table', 'Missing reload state')
    for id, record in pairs(state.registers) do
        string_value(id)
        fields(record, { payment_id = true, attempts = true })
        if record.payment_id ~= nil then string_value(record.payment_id) end
        fields(record.attempts, { take = true, finish = true })
        for _, attempt in pairs(record.attempts) do
            fields(attempt, { count = true, next_at = true, warned = true })
            assert(math.type(attempt.count) == 'integer' and attempt.count >= 0 and attempt.count <= 3,
                'Invalid reload retry count')
            assert(finite(attempt.next_at) and attempt.next_at >= 0, 'Invalid reload retry time')
            assert(attempt.warned == nil or type(attempt.warned) == 'boolean', 'Invalid reload warning flag')
        end
    end
    for id, record in pairs(state.removed) do
        string_value(id)
        fields(record, { owner = true, tasks = true, recovery = true })
        string_value(record.owner)
        array(record.tasks, function(task)
            fields(task, { id = true, index = true })
            string_value(task.id)
            assert(math.type(task.index) == 'integer' and task.index > 0 and task.index <= MAX_ITEMS,
                'Invalid reload evaluator position')
        end)
        if record.recovery ~= nil then array(record.recovery, string_value) end
    end
    return state
end

local function encode(state)
    validate(state)
    local chunks, seen, count = { HEADER }, {}, 0
    local function write(value, depth)
        count = count + 1
        assert(count <= MAX_ITEMS and depth <= 12, 'Reload state exceeds limits')
        local kind = type(value)
        if kind == 'string' or kind == 'number' then
            if kind == 'number' then assert(finite(value), 'Invalid reload number') end
            local data = kind == 'number' and string.format('%.17g', value) or value
            assert(not data:find('\0', 1, true), 'NUL is not supported in reload state')
            chunks[#chunks + 1] = (kind == 'string' and 's' or 'n') .. #data .. ':' .. data
        elseif kind == 'boolean' then
            chunks[#chunks + 1] = value and 'b1' or 'b0'
        else
            assert(kind == 'table' and not seen[value] and getmetatable(value) == nil,
                'Reload state must contain plain values')
            seen[value] = true
            local keys = {}
            for key in pairs(value) do
                assert(type(key) == 'string' or math.type(key) == 'integer', 'Invalid reload key')
                keys[#keys + 1] = key
            end
            table.sort(keys, function(a, b)
                if type(a) ~= type(b) then return type(a) < type(b) end
                return a < b
            end)
            chunks[#chunks + 1] = 't' .. #keys .. ':'
            for _, key in ipairs(keys) do write(key, depth + 1); write(value[key], depth + 1) end
            seen[value] = nil
        end
    end
    write(state, 0)
    local result = table.concat(chunks)
    assert(#result <= MAX_BYTES, 'Reload state exceeds size limit')
    return result
end

local function decode(text)
    assert(type(text) == 'string' and #text <= MAX_BYTES and text:sub(1, #HEADER) == HEADER,
        'Unsupported or damaged Auto Checkout reload state; reload the world and restart the game')
    local position, count = #HEADER + 1, 0
    local function read(depth)
        count = count + 1
        assert(count <= MAX_ITEMS and depth <= 12 and position <= #text, 'Invalid reload payload')
        local tag = text:sub(position, position)
        position = position + 1
        if tag == 'b' then
            local value = text:sub(position, position)
            position = position + 1
            assert(value == '0' or value == '1', 'Invalid reload boolean')
            return value == '1'
        end
        assert(tag == 's' or tag == 'n' or tag == 't', 'Invalid reload token')
        local ending = assert(text:find(':', position, true), 'Missing reload length')
        local length_text = text:sub(position, ending - 1)
        assert(#length_text <= 8 and length_text:match('^%d+$'), 'Invalid reload length')
        local length = tonumber(length_text)
        position = ending + 1
        if tag == 't' then
            assert(length <= MAX_ITEMS, 'Reload table exceeds limit')
            local result = {}
            for _ = 1, length do
                local key = read(depth + 1)
                assert(type(key) == 'string' or math.type(key) == 'integer', 'Invalid reload key')
                assert(result[key] == nil, 'Duplicate reload key')
                result[key] = read(depth + 1)
            end
            return result
        end
        assert(length <= 65536 and position + length - 1 <= #text, 'Truncated reload value')
        local value = text:sub(position, position + length - 1)
        position = position + length
        assert(not value:find('\0', 1, true), 'Invalid reload string')
        if tag == 's' then return value end
        assert(value:match('^[%d%.eE%+%-]+$') and finite(tonumber(value)), 'Invalid reload number')
        return tonumber(value)
    end
    local state = read(0)
    assert(position == #text + 1, 'Trailing reload data')
    return validate(state)
end

function Reload.new(ref)
    assert(ref ~= nil, 'Auto Checkout requires ModRef reload lifecycle support')
    local previous = ref:GetSharedVariable(KEY)
    local state = previous ~= nil and decode(previous) or { registers = {}, removed = {} }
    return setmetatable({ ref = ref, state = state, last = previous }, Reload)
end

function Reload:save(state)
    local payload = encode(state)
    if payload == self.last then return end
    self.ref:SetSharedVariable(KEY, payload)
    assert(self.ref:GetSharedVariable(KEY) == payload, 'Auto Checkout reload state was not retained')
    self.last = payload
end

return Reload
