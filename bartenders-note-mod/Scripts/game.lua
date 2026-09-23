-- Original read-only adapter. Call on the game thread.
local Game = {}
local TEMPLATE_FLAGS = 0x10 | 0x20 -- Class default object, archetype object.

function Game.valid(object)
    if object == nil then return false end
    local ok, valid = pcall(function() return object:IsValid() end)
    return ok and valid == true
end

function Game.same(a, b)
    return Game.valid(a) and Game.valid(b) and a:GetAddress() == b:GetAddress()
end

local function integer(value, field)
    assert(type(value) == 'number' and value == math.floor(value),
        'Unsupported drink queue contract: ' .. field .. ' must be an integer')
    return value
end

function Game.active(hud)
    if not Game.valid(hud) or hud:HasAnyFlags(TEMPLATE_FLAGS)
        or not hud:IsInViewport() or not hud:IsVisible() then return false end
    local owner = hud:GetOwningPlayer()
    if not Game.valid(owner) or not owner:IsLocalController() then return false end
    return Game.same(hud:GetWorld(), owner:GetWorld())
end

function Game.find_hud()
    local candidates = FindAllOf('WBP_HUD_C') or {}
    local found
    for _, candidate in ipairs(candidates) do
        if Game.active(candidate) then
            assert(found == nil or Game.same(found, candidate),
                'Multiple active local HUDs; waiting for HUD transition to finish')
            found = candidate
        end
    end
    return found
end

local function subsystem(library, hud, name)
    local class = StaticFindObject('/Script/BrasserieSimulator.' .. name)
    assert(Game.valid(class), 'Missing game subsystem class: ' .. name)
    local result = library:GetWorldSubsystem(hud, class)
    assert(Game.valid(result), 'Game world subsystem is unavailable: ' .. name)
    return result
end

function Game.snapshot(hud)
    assert(Game.active(hud), 'Local HUD is no longer active')
    local owner = hud:GetOwningPlayer()
    local state = owner.PlayerState
    assert(Game.valid(state), 'Local player state is not ready')
    local player_id = integer(state:GetPlayerId(), 'local player ID')
    local library = StaticFindObject('/Script/Engine.Default__SubsystemBlueprintLibrary')
    assert(Game.valid(library), 'SubsystemBlueprintLibrary is unavailable')
    local world = subsystem(library, hud, 'WorldGameInstanceSubsystem')
    local locale = subsystem(library, hud, 'LocaleGameInstanceSubsystem')
    local manager = world:GetDrinkManager()
    assert(Game.valid(manager), 'Drink manager is not ready')
    assert(Game.same(manager:GetWorld(), hud:GetWorld()), 'Drink manager belongs to an inactive world')

    -- Read the manager-owned storage. Reflected array return values can contain
    -- non-owning struct wrappers into temporary UFunction result storage.
    local queue = manager.DrinksPrepareQueue.Items
    assert(queue ~= nil and queue:IsValid(), 'Drink queue storage is unavailable')
    local count = queue:GetArrayNum()
    local entries = {}
    queue:ForEach(function(index, item)
        -- Copy primitives before leaving this synchronous callback. Do not call
        -- game functions, yield, or retain either of these struct views.
        assert(index == #entries + 1, 'Unsupported drink queue array index')
        local entry = item:get()
        assert(entry ~= nil, 'Drink queue entry is unavailable')
        assert(type(entry.bClaimedByPlayer) == 'boolean',
            'Unsupported drink queue contract: claim flag must be a boolean')
        local guid = entry.DrinkId
        assert(guid ~= nil, 'Drink queue entry has no identity')
        local id = table.concat({
            tostring(integer(guid.A, 'DrinkId.A')), tostring(integer(guid.B, 'DrinkId.B')),
            tostring(integer(guid.C, 'DrinkId.C')), tostring(integer(guid.D, 'DrinkId.D')),
        }, ':')
        entries[index] = {
            id = id,
            drink = integer(entry.Drink, 'Drink'),
            state = integer(entry.State, 'State'),
            claimed = entry.bClaimedByPlayer,
            player_id = integer(entry.ClaimedPlayerId, 'ClaimedPlayerId'),
        }
    end)
    assert(#entries == count, 'Unsupported drink queue: array contains missing entries')
    local function translate(drink)
        assert(Game.valid(locale) and Game.active(hud), 'Localization world is no longer active')
        local text = locale:GetDishTranslation(integer(drink, 'translation drink'))
        assert(text ~= nil, 'Game returned no drink translation')
        local label = text:ToString()
        assert(type(label) == 'string' and label ~= '', 'Game returned an empty drink translation')
        return label
    end
    return entries, player_id, translate
end

return Game
