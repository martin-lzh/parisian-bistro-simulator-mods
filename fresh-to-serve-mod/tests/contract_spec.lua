-- Strict synthetic reflection registry: only the selected spelling exists.
local Game, Remake = require('game'), require('remake')
local fixture, drink_fixture = require('fixture'), require('drink_fixture')
local prefix = '/Script/BrasserieSimulator.'
local table_methods = { 'IsTableOccupied', 'GetCustomerWaitElapsedTime',
    'GetCustomerWaitTime', 'IsCustomerOrderWaitActive', 'OnRep_OrderNotifications' }

local function table_class(f, spelling)
    local class = f.object('Class ' .. prefix .. spelling)
    function class:IsClass() return true end
    function class:GetFName() return { ToString = function() return spelling end } end
    return class
end

local function reflection(f, spelling)
    f.api.table_class, f.api.table_name = table_class(f, spelling), spelling
    f.table.class = f.api.table_class
    function f.table:IsA(class) return self.class:GetAddress() == class:GetAddress() end
    f.objects.table = nil
    f.objects[spelling] = { f.table }
    f.lookups, f.scans, f.reflection = {}, {}, {}
    local function bind(path, value)
        value = value or f.object(path)
        if not value.IsValid then function value:IsValid() return true end end
        f.reflection[path] = value
    end
    bind(prefix .. spelling, f.api.table_class)
    for _, method in ipairs(table_methods) do bind(prefix .. spelling .. ':' .. method) end
    for _, path in ipairs({
        '/Script/Engine.Actor:K2_DestroyActor', '/Script/Engine.Actor:ForceNetUpdate',
        prefix .. 'GenericDish:GetDishQuality', prefix .. 'GenericDish:GetOrderedForTable',
        prefix .. 'CustomerSatisfactionSubsystem:GetSatisfactionFromDishQuality',
        prefix .. 'KitchenManager:TryOrderDish',
        prefix .. 'NetPlayerController:Server_RequestRemoveDishFromSpawnQueue',
        prefix .. 'DishGameInstanceSubsystem:GetDish', prefix .. 'DrinkManager:TryOrderDrink',
        prefix .. 'Drink:IsFull', prefix .. 'DrinkOutputArea:HasSpace',
        prefix .. 'DishGameInstanceSubsystem:IsCocktailDish',
        prefix .. 'WorldGameInstanceSubsystem:GetEmployeeManager',
        '/Script/SmartObjectsModule.SmartObjectComponent:GetDefinition',
    }) do bind(path) end
    for path, field in pairs({
        [prefix .. 'PlayerCharacter'] = 'player', [prefix .. 'Dish'] = 'dish',
        ['/Script/Engine.Default__GameplayStatics'] = 'gameplay',
        ['/Script/Engine.Default__KismetMathLibrary'] = 'math',
        [prefix .. 'Default__CustomerSatisfactionSubsystem'] = 'quality',
        [prefix .. 'Drink'] = 'drink', [prefix .. 'CocktailDrink'] = 'cocktail',
        [prefix .. 'SmartObjectInteractionDefinition'] = 'interaction',
        [prefix .. 'PrepareDrinkEvaluator'] = 'prepare_drink',
        [prefix .. 'PrepareCocktailEvaluator'] = 'prepare_cocktail',
    }) do bind(path, f.api[field]) end
    for name, values in pairs({
        ECustomerSatisfaction = { ECS_DishBadQuality = 3, ECS_DishReallyBadQuality = 4 },
        EDishState = { Pending = 0, Preparing = 1 }, EDishes = { EDH_Unknown = 0 },
        EDrinkOrderState = { Pending = 0, Preparing = 1, Prepared = 2 },
        EEmployeeRole = { Barman = 8 }, EEmployeeState = { Working = 0 },
    }) do
        local enumeration = f.object(name)
        function enumeration:ForEachName(callback)
            for key, value in pairs(values) do
                if callback({ ToString = function() return key end }, value) then return end
            end
        end
        bind(prefix .. name, enumeration)
    end
    _G.StaticFindObject = function(path)
        f.lookups[#f.lookups + 1] = path
        return f.reflection[path]
    end
    _G.FindAllOf = function(name)
        assert(name ~= (spelling == 'Table' and 'table' or 'Table'), 'Wrong table scan spelling')
        f.scans[name] = (f.scans[name] or 0) + 1
        return f.objects[name] or {}
    end
end

local function fails(f, message)
    local ok, err = pcall(Game.contract)
    assert(not ok and tostring(err):find(message, 1, true), tostring(err))
    assert(not f.dish.destroyed and f.ordered == 0)
end

for _, spelling in ipairs({ 'Table', 'table' }) do
    for _, factory in ipairs({ fixture, drink_fixture }) do
        local f = factory()
        reflection(f, spelling)
        f.api = Game.contract()
        assert(f.api.table_class == f.table.class and f.api.table_name == spelling)
        for _, path in ipairs(f.lookups) do
            assert(not path:find(prefix .. (spelling == 'Table' and 'table' or 'Table') .. ':', 1, true))
        end
        -- A rejected request leaves a scalar ticket. Its next attempt must find
        -- a fresh wrapper using the resolved spelling and bind its new notice.
        f.reject, f.reject_drink = true, true
        local engine = Remake.new(Game, function() end)
        engine:tick(f.api)
        local is_drink = f.drink ~= nil
        assert((is_drink and f.drink or f.dish).destroyed and next(engine.pending))
        assert((is_drink and f.drinks_ordered or f.ordered) == 1)
        local old_table, old_notice = f.table, f.notice
        local rebound = f.object(old_table.name)
        for key, value in pairs(old_table) do rebound[key] = value end
        f.notice = {}
        for key, value in pairs(old_notice) do f.notice[key] = value end
        rebound.OrderNotifications = f.array({ f.notice })
        old_table.valid = false
        f.table, f.objects[spelling] = rebound, { rebound }
        f.reject, f.reject_drink, f.now = false, false, 30
        engine:tick(f.api)
        assert((is_drink and f.drinks_ordered or f.ordered) == 2 and not next(engine.pending))
        local order_field = is_drink and 'DrinkOrderId' or 'DishOrderId'
        assert(f.notice[order_field].A == (is_drink and 202 or 102))
        assert(old_notice[order_field].A == 1 and rebound.refreshed and f.scans[spelling] >= 2)
        engine:tick(f.api)
        assert((is_drink and f.drinks_ordered or f.ordered) == 2)
    end

    local f = fixture(); reflection(f, spelling)
    local other = spelling == 'Table' and 'table' or 'Table'
    -- A second spelling may be an alias for the same native UClass. Use its
    -- actual name even if the alias was the first successful lookup.
    local alias = table_class(f, spelling)
    alias.address = f.api.table_class.address
    f.reflection[prefix .. other] = alias
    f.api = Game.contract()
    assert(f.api.table_name == spelling and f.api.table_class:GetAddress() == alias:GetAddress())
    Remake.new(Game, function() end):tick(f.api)
    assert(f.ordered == 1 and f.scans[spelling])

    for _, method in ipairs(table_methods) do
        f = fixture(); reflection(f, spelling)
        f.reflection[prefix .. spelling .. ':' .. method] = nil
        f.reflection[prefix .. other .. ':' .. method] = f.object('other-method')
        fails(f, 'Missing Fresh to Serve API: ' .. prefix .. spelling .. ':' .. method)
        local missing = f.object('invalid-method'); missing.valid = false
        f.reflection[prefix .. spelling .. ':' .. method] = missing
        fails(f, 'Missing Fresh to Serve API: ' .. prefix .. spelling .. ':' .. method)
    end
    f = fixture(); reflection(f, spelling)
    f.reflection[prefix .. other] = table_class(f, other)
    fails(f, 'Ambiguous Fresh to Serve table class')
    f = fixture(); reflection(f, spelling)
    function f.api.table_class:IsClass() return false end
    fails(f, 'Invalid Fresh to Serve table class')
    f = fixture(); reflection(f, spelling)
    f.api.table_class.name = 'Class /Script/Other.' .. spelling
    fails(f, 'Unexpected Fresh to Serve table class')

    -- Reacquisition must reject an unrelated type returned by a short-name scan.
    f = fixture(); reflection(f, spelling); f.api = Game.contract()
    f.kitchen.ChefCharacters = f.array()
    local engine = Remake.new(Game, function() end); engine:tick(f.api)
    assert(f.dish.destroyed and next(engine.pending))
    f.table.class = f.object('unrelated-class')
    function f.table:HasAnyFlags() error('Unrelated object reached Actor guards') end
    f.kitchen.ChefCharacters[1] = {}; f.now = 21
    engine:tick(f.api)
    assert(f.ordered == 0 and not next(engine.pending))
end

local f = fixture(); reflection(f, 'Table')
f.reflection[prefix .. 'Table'] = nil
fails(f, 'Missing Fresh to Serve table class')
f.reflection[prefix .. 'Table'] = f.object('invalid-class')
f.reflection[prefix .. 'Table'].valid = false
fails(f, 'Missing Fresh to Serve table class')

-- The actual entry point checkpoints a contract failure and retains the stop
-- through Ctrl+R, even after a replacement script can resolve the API.
local Reload = require('reload')
local shared, tick, logs = {}, nil, {}
local original_print = print
print = function(message) logs[#logs + 1] = message end
ModRef = {
    GetSharedVariable = function(_, key) return shared[key] end,
    SetSharedVariable = function(_, key, value) shared[key] = value end,
}
LoopInGameThreadWithDelay = function(_, callback) tick = callback end
dofile(MOD_ROOT .. '/Scripts/main.lua')
tick()
assert(Reload.read(ModRef).failed and not f.dish.destroyed and f.ordered == 0)
assert(table.concat(logs, '\n'):find('automation-stopped', 1, true))
ModRef.OnUnload()
reflection(f, 'Table')
dofile(MOD_ROOT .. '/Scripts/main.lua')
tick()
assert(Reload.read(ModRef).failed and not f.dish.destroyed and f.ordered == 0)
ModRef.OnUnload()
-- A new process starts without the old loader's shared variables.
shared = {}
dofile(MOD_ROOT .. '/Scripts/main.lua')
tick()
assert(not Reload.read(ModRef).failed and f.dish.destroyed and f.ordered == 1)
print = original_print
print('contract_spec: both table spellings, alias identity, missing/ambiguous contracts and live food/drink rebinding passed')
