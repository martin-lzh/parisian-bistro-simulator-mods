-- Keep only bounded scalar data across Lua-state replacement. Never retain
-- UObject wrappers or execute a saved string as Lua code.
local Reload = {}
local KEY, MAGIC = 'FreshToServe.ReloadState', 'FreshToServe:1\n'
local MAX_BYTES, MAX_FIELD, MAX_TICKETS = 4 * 1024 * 1024, 65536, 4096
local STRINGS = { 'key', 'kind', 'producer', 'table', 'customer', 'order' }
local NUMBERS = { 'group', 'dish', 'created_at', 'next_attempt', 'attempts' }

local function finite(value)
    return type(value) == 'number' and value == value and value > -math.huge and value < math.huge
end

local function string_value(value)
    assert(type(value) == 'string' and #value <= MAX_FIELD and not value:find('\0', 1, true),
        'Invalid reload string')
    return value
end

local function ticket_valid(ticket)
    assert(type(ticket) == 'table', 'Invalid reload ticket')
    for _, name in ipairs(STRINGS) do assert(#string_value(ticket[name]) > 0, 'Empty reload identity') end
    assert(ticket.kind == 'food' or ticket.kind == 'drink', 'Invalid reload kind')
    for _, name in ipairs(NUMBERS) do
        assert(finite(ticket[name]) and ticket[name] >= 0, 'Invalid reload number')
    end
    assert(ticket.group % 1 == 0 and ticket.dish % 1 == 0 and ticket.attempts % 1 == 0
        and ticket.attempts <= 3, 'Invalid reload counter')
end

function Reload.encode(session, pending, failed)
    assert(type(pending) == 'table' and type(failed) == 'boolean', 'Invalid reload state')
    local parts = { MAGIC }
    local function field(value)
        value = string_value(value)
        parts[#parts + 1] = tostring(#value) .. ':' .. value
    end
    local keys = {}
    for key in pairs(pending) do
        assert(type(key) == 'string', 'Invalid reload key')
        keys[#keys + 1] = key
    end
    assert(#keys <= MAX_TICKETS and (session ~= nil or #keys == 0), 'Invalid reload session')
    if session ~= nil then assert(#string_value(session) > 0, 'Empty reload session') end
    table.sort(keys)
    field(session or '')
    field(failed and '1' or '0')
    field(tostring(#keys))
    for _, key in ipairs(keys) do
        local ticket = pending[key]
        ticket_valid(ticket)
        assert(ticket.key == key, 'Reload key mismatch')
        for _, name in ipairs(STRINGS) do field(ticket[name]) end
        for _, name in ipairs(NUMBERS) do field(string.format('%.17g', ticket[name])) end
    end
    local result = table.concat(parts)
    assert(#result <= MAX_BYTES, 'Reload state too large')
    return result
end

function Reload.decode(value)
    assert(type(value) == 'string' and #value <= MAX_BYTES and value:sub(1, #MAGIC) == MAGIC,
        'Unsupported reload state')
    local cursor = #MAGIC + 1
    local function field()
        local first, last, digits = value:find('(%d+):', cursor)
        assert(first == cursor and #digits <= 8, 'Invalid reload framing')
        local length = tonumber(digits)
        assert(length <= MAX_FIELD and last + length <= #value, 'Truncated reload state')
        local result = string_value(value:sub(last + 1, last + length))
        cursor = last + length + 1
        return result
    end
    local session, flag, count = field(), field(), tonumber(field())
    assert(flag == '0' or flag == '1', 'Invalid reload stop flag')
    assert(finite(count) and count % 1 == 0 and count >= 0 and count <= MAX_TICKETS,
        'Invalid reload ticket count')
    assert(session ~= '' or count == 0, 'Missing reload session')
    local pending = {}
    for _ = 1, count do
        local ticket = {}
        for _, name in ipairs(STRINGS) do ticket[name] = field() end
        for _, name in ipairs(NUMBERS) do ticket[name] = tonumber(field()) end
        ticket_valid(ticket)
        assert(pending[ticket.key] == nil, 'Duplicate reload ticket')
        pending[ticket.key] = ticket
    end
    assert(cursor == #value + 1, 'Trailing reload data')
    return { session = session ~= '' and session or nil, pending = pending, failed = flag == '1' }
end

function Reload.read(mod)
    if not mod then return { pending = {}, failed = false } end
    local value = mod:GetSharedVariable(KEY)
    if value == nil then return { pending = {}, failed = false } end
    local ok, state = pcall(Reload.decode, value)
    if ok then return state end
    -- Bind an unreadable state's safety stop to the first observed session;
    -- never silently resume potentially uncertain work from that session.
    return { pending = {}, failed = true }, tostring(state)
end

function Reload.write(mod, remake, failed)
    if mod then mod:SetSharedVariable(KEY, Reload.encode(remake.session, remake.pending, failed)) end
end

return Reload
