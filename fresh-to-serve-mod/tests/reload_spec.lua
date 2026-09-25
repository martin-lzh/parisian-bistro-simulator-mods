local Reload = require('reload')
local key = 'table:订单\ncustomer\t1'
local ticket = { key = key, kind = 'drink', producer = 'manager@123', table = 'table@2',
    customer = 'customer@3', order = '1:2:3:4', group = 12, dish = 17,
    created_at = 123.1234567890123, next_attempt = 133.1234567890123, attempts = 2 }
local pending = { [key] = ticket }
local encoded = Reload.encode('world@1/player@2', pending, true)
local decoded = Reload.decode(encoded)
assert(decoded.failed and decoded.session == 'world@1/player@2')
assert(decoded.pending[key] ~= ticket)
for name, value in pairs(ticket) do assert(decoded.pending[key][name] == value) end
assert(Reload.encode(decoded.session, decoded.pending, decoded.failed) == encoded)

for _, invalid in ipairs({ encoded:sub(1, -2), encoded .. 'tail', 'return os.execute("never")',
    encoded:gsub('FreshToServe:1', 'FreshToServe:2', 1), false, 123 }) do
    assert(not pcall(Reload.decode, invalid))
end
ticket.attempts = 4; assert(not pcall(Reload.encode, 'world', pending, false)); ticket.attempts = 2
ticket.created_at = 0/0; assert(not pcall(Reload.encode, 'world', pending, false)); ticket.created_at = 123
ticket.customer = {}; assert(not pcall(Reload.encode, 'world', pending, false)); ticket.customer = 'customer'
ticket.key = 'wrong'; assert(not pcall(Reload.encode, 'world', pending, false)); ticket.key = key
assert(not pcall(Reload.encode, nil, pending, false))

local shared, keys = nil, {}
local mod = {
    GetSharedVariable = function(_, name) keys[name] = true; return shared end,
    SetSharedVariable = function(_, name, value) keys[name] = true; assert(type(value) == 'string'); shared = value end,
}
local state = Reload.read(mod); assert(not state.failed and not next(state.pending))
Reload.write(mod, { session = 'world', pending = pending }, false)
state = Reload.read(mod); assert(not state.failed and state.pending[key])
for index = 1, 50 do
    Reload.write(mod, { session = 'world-' .. index, pending = {} }, index % 2 == 0)
end
local count = 0; for _ in pairs(keys) do count = count + 1 end
assert(count == 1, 'Reload must not accumulate keys for worlds or tickets')
shared = 'malformed'
state = Reload.read(mod); assert(state.failed and state.session == nil and not next(state.pending))
print('reload_spec: scalar roundtrip, framing, validation, fail-closed parsing and bounded shared keys passed')
