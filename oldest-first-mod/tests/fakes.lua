-- Original engine-shaped doubles. No game data or extracted code.
local Fakes = {}
function Fakes.param(value) return { get = function() return value end } end
function Fakes.array(values)
    local result = { values = values or {} }
    function result:ForEach(fn)
        for i, value in ipairs(self.values) do if fn(i, Fakes.param(value)) then break end end
    end
    return result
end
function Fakes.object(name, class, world)
    local result = { name = name, class = class, world = world }
    function result:IsValid() return not self.invalid end
    function result:GetAddress() return self.name end
    function result:GetFullName() return self.name end
    function result:HasAnyFlags() return self.template or false end
    function result:IsActorBeingDestroyed() return self.destroyed or false end
    function result:GetWorld() return self.world end
    function result:IsA(expected) return self.class == expected end
    return result
end
return Fakes
