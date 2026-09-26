local Settings = {}
Settings.modes = { 'free', 'budget', 'premium' }

function Settings.valid(value)
    return value == 'free' or value == 'budget' or value == 'premium'
end

function Settings.load(path)
    local file = io.open(path, 'r') or io.open(path .. '.bak', 'r')
    if not file then return 'premium' end
    local value = file:read('*a'); file:close()
    value = value:match('^%s*(%a+)%s*$')
    assert(Settings.valid(value), 'Invalid delivery preference; expected free, budget or premium')
    return value
end

function Settings.save(path, value)
    assert(Settings.valid(value), 'Invalid delivery preference')
    -- Store data only. Never execute a preference file as Lua code.
    local temporary, backup = path .. '.tmp', path .. '.bak'
    local file = assert(io.open(temporary, 'w'))
    local ok, err = file:write(value .. '\n')
    local closed, close_error = file:close()
    assert(ok and closed, tostring(err or close_error))
    local previous = io.open(path, 'r')
    if previous then
        previous:close()
        local stale = io.open(backup, 'r')
        if stale then stale:close(); assert(os.remove(backup)) end
        assert(os.rename(path, backup))
    end
    local replaced, replace_error = os.rename(temporary, path)
    if not replaced then
        if previous then assert(os.rename(backup, path), 'Cannot restore delivery preference') end
        error(replace_error)
    end
    if previous then assert(os.remove(backup)) end
end

return Settings
