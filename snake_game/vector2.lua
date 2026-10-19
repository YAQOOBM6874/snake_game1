-- vector2.lua
-- Task 2.2: Custom Metamethods
-- Vector2 class with metamethods for game math

local Vector2 = {}
Vector2.__index = Vector2

function Vector2:new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector2)
end

-- Vector addition metamethod (+)
function Vector2:__add(other)
    return Vector2:new(self.x + other.x, self.y + other.y)
end

-- Vector equality metamethod (==)
function Vector2:__eq(other)
    if type(other) ~= "table" then return false end
    return self.x == other.x and self.y == other.y
end

-- String representation metamethod (tostring)
function Vector2:__tostring()
    return string.format("Vector2(%s, %s)", tostring(self.x), tostring(self.y))
end

return Vector2
