local Remake = require('remake')
local function snapshot()
    return { present = true, supplied = false, ready = true, preparation = 20,
        queue = { 10, 30 }, patience_enabled = true, remaining = 101 }
end
local s = snapshot()
local action, _, budget = Remake.decision(s)
assert(action == 'order' and budget == 100)
s.remaining = 100
assert(select(2, Remake.decision(s)) == 'insufficient-patience')
s.remaining = 21 -- enough to cook, insufficient for backlog and delivery
assert(Remake.decision(s) == 'cancel')
s.remaining = nil
assert(select(2, Remake.decision(s)) == 'patience-unavailable')
s.patience_enabled = false
assert(Remake.decision(s) == 'order')
s.present = false
assert(Remake.decision(s) == 'cancel')
s = snapshot(); s.supplied = true
assert(select(2, Remake.decision(s)) == 'replacement-already-covered')
s = snapshot(); s.queue = { 0/0 }
assert(select(2, Remake.decision(s)) == 'timing-unavailable')
s = snapshot(); s.preparation = math.huge
assert(Remake.decision(s) == 'cancel')
s = snapshot(); s.ready = false
assert(Remake.decision(s) == 'wait')

local now, session_id, available, paused = 0, 'world-a', true, false
local orders, discards, rejected = 0, 0, true
local game = {
    session = function() return available and { id = session_id, now = now, paused = paused } or nil end,
    candidates = function() return discards == 0 and { { id = 'plate' } } or {} end,
    ticket = function() return { key = 'order', created_at = now } end,
    discard = function() discards = discards + 1; return true end,
    snapshot = function() return snapshot() end,
    request = function() orders = orders + 1; return not rejected, 'rejected' end,
}
local engine = Remake.new(game, function() end)
engine:tick({}); assert(discards == 1 and orders == 1)
for i = 1, 9 do now = i; engine:tick({}) end
assert(orders == 1)
now = 10; engine:tick({}); assert(orders == 2)
now = 20; rejected = false; engine:tick({}); assert(orders == 3 and not next(engine.pending))
now = 30; engine:tick({}); assert(orders == 3)
discards, rejected, orders = 0, true, 0
engine:tick({}); now = 40; engine:tick({}); now = 50; engine:tick({})
assert(orders == 3 and not next(engine.pending))
discards = 0; paused = true; engine:tick({}); assert(discards == 0)
paused = false; engine:tick({}); assert(next(engine.pending))
session_id = 'world-b'; engine:tick({}); assert(not next(engine.pending))
engine.pending.any = {}; available = false; engine:tick({}); assert(not next(engine.pending))
print('remake_spec: patience, backlog, duplicates, retry bounds, pause and travel passed')
