-- states/menu_state.lua
-- Menu State for GameState manager (Task 1.1)

local HighScore = require("highscore")

local MenuState = {}
MenuState.__index = MenuState

function MenuState:new(stateManager)
    local state = {
        manager = stateManager,
        pulseTimer = 0,
        highScore = HighScore:load() or 0
    }
    return setmetatable(state, MenuState)
end

function MenuState:enter()
    self.highScore = HighScore:load() or 0
end

function MenuState:update(dt)
    self.pulseTimer = self.pulseTimer + (dt or 0)
end

function MenuState:draw()
    if not (love and love.graphics) then
        return
    end

    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    -- Title
    love.graphics.setColor(0.3, 0.9, 0.5)
    love.graphics.printf("SNAKE GAME", 0, screenH * 0.22, screenW, "center")

    -- High Score
    love.graphics.setColor(0.9, 0.8, 0.3)
    love.graphics.printf("Current High Score: " .. tostring(self.highScore), 0, screenH * 0.38, screenW, "center")

    -- Pulsing Prompt
    local alpha = 0.5 + 0.5 * math.sin(self.pulseTimer * 4)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.printf("Press SPACE or ENTER to Play", 0, screenH * 0.52, screenW, "center")

    -- Instructions
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Controls:\nArrow Keys / W A S D - Move Snake\nESC - Exit Game", 0, screenH * 0.68, screenW, "center")
end

return MenuState
