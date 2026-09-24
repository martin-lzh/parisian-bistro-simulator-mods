local Pickup = require('pickup')
local pickup, requests = Pickup.new(), {}
local function send(id) requests[#requests + 1] = id; return true end
local function snapshot(now, oldest, present, carried)
    return { session = 'player', scope = 'pass', now = now, oldest = oldest,
        present = present or {}, carried = carried or {} }
end
-- No automation without a native hold event.
pickup:step(snapshot(0, 'a', { a = true }), send)
assert(#requests == 0)
pickup:begin('player', 'pass', 0)
assert(pickup:step(snapshot(0, 'a', { a = true, b = true }), send) == 'requested')
pickup:step(snapshot(0.5, 'b', { a = true, b = true }), send)
assert(#requests == 1, 'Must wait for acknowledgement even if the next candidate changes')
pickup:step(snapshot(0.6, 'b', { a = true, b = true }, { a = true }), send)
assert(#requests == 2 and requests[2] == 'b', 'Tray acknowledgement must allow next item')
pickup:step(snapshot(0.7, 'c', { c = true }), send)
assert(#requests == 2, 'Queue removal acknowledges, but does not skip cooldown')
pickup:step(snapshot(1, 'c', { c = true }), send)
assert(#requests == 3)
assert(pickup:step(snapshot(3.1, 'c', { c = true }), send) == 'timeout')
pickup:step(snapshot(5, 'd', { d = true }), send)
assert(#requests == 3, 'Rejected request must stop for the rest of the hold')
pickup:reset()
pickup:begin('player', 'pass', 0)
pickup:step(snapshot(0, nil), send)
assert(#requests == 3, 'Empty/full source must not dispatch')
local changed = snapshot(1, 'x', { x = true }); changed.scope = 'other'
pickup:step(changed, send)
assert(not pickup.session and #requests == 3)
pickup:begin('player', 'pass', 10)
pickup:step(snapshot(10, nil), send)
pickup:step(snapshot(9, 'x', { x = true }), send)
assert(not pickup.session and #requests == 3, 'Clock rewind resets')
pickup:begin('player', 'pass', 0)
assert(pickup:step(snapshot(0, 'x', { x = true }), function() return false end) == 'changed')
assert(pickup.stopped and not pickup.pending)
pickup:reset()
assert(not pickup.stopped and not pickup.last_time)
pickup:begin('player', 'pass', 0)
local full = snapshot(0, nil); full.has_space = false
assert(pickup:step(full, send) == 'full')
pickup:step(snapshot(1, 'x', { x = true }), send)
assert(#requests == 3, 'Clearing a tray slot must not resume a full-tray stop without another hold')
