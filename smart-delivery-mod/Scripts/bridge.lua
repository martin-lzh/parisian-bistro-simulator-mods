local Bridge = {}
Bridge.__index = Bridge

function Bridge.new(directory)
    local self = setmetatable({ directory = directory, calls = {} }, Bridge)
    for _, name in ipairs({ 'initialize', 'free', 'budget', 'premium', 'disable' }) do
        local callback, err = package.loadlib(directory .. '/delivery_bridge.dll', 'delivery_' .. name)
        assert(callback, 'Native helper unavailable: ' .. tostring(err))
        self.calls[name] = callback
    end
    return self
end

function Bridge:call(name)
    assert(self.calls[name], 'Invalid bridge command')
    local path = self.directory .. '/bridge-status.txt'
    local old = io.open(path, 'r')
    if old then old:close(); assert(os.remove(path), 'Cannot clear bridge acknowledgment') end
    self.calls[name]()
    local file = assert(io.open(path, 'r'), 'Native helper did not acknowledge command')
    local result = file:read('*l'); file:close()
    assert(result == (name == 'disable' and 'disabled' or 'ready'), tostring(result))
end

return Bridge
