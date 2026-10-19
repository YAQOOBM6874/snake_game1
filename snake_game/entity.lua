-- entity.lua
-- Task 1.2: Entity Component Pattern
-- Entity system for the snake game

local Entity = {}

-- Metatable setup: allows method lookup and transparent coordinate access
Entity.__index = function(tbl, key)
    -- Check Entity methods first
    if Entity[key] ~= nil then
        return Entity[key]
    end
    -- Allow direct .x and .y access if Position component exists
    local pos = tbl.components and tbl.components["Position"]
    if pos and (key == "x" or key == "y") then
        return pos[key]
    end
    return nil
end

function Entity:new()
    local entity = {
        components = {}
    }
    return setmetatable(entity, Entity)
end

function Entity:addComponent(name, component)
    self.components[name] = component
    return component
end

function Entity:getComponent(name)
    return self.components[name]
end

function Entity:hasComponent(name)
    return self.components[name] ~= nil
end

-- Helper constructors for required components:
-- Position (x, y)
function Entity.createPosition(x, y)
    return {x = x or 0, y = y or 0}
end

-- Movement (dx, dy)
function Entity.createMovement(dx, dy)
    return {dx = dx or 0, dy = dy or 0}
end

-- Renderer (color, size)
function Entity.createRenderer(color, size)
    return {
        color = color or {1, 1, 1},
        size = size or 28
    }
end

return Entity
