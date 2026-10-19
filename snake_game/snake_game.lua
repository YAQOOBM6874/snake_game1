-- snake_game.lua
-- Task 3.1: Core Game Logic
-- Implements snake mechanics, collisions, score, and rendering

local Vector2 = require("vector2")
local Entity = require("entity")
local HighScore = require("highscore")
local Events = require("events")

local SnakeGame = {}
SnakeGame.__index = SnakeGame

-- Constants
local GRID = 20
local CELL = 30
local STEP_TIME = 0.12

function SnakeGame:new()
    local game = {
        gridSize = GRID,
        cellSize = CELL,
        stepTime = STEP_TIME,
        timer = 0,
        score = 0,
        highScore = HighScore:load() or 0,
        gameOver = false,
        -- Initial direction: moving right
        direction = Vector2:new(1, 0),
        nextDirection = Vector2:new(1, 0),
        -- Initial snake segments
        snake = {
            Vector2:new(10, 10), -- Starting position (head)
            Vector2:new(9, 10),
            Vector2:new(8, 10)
        },
        -- Initial food position
        food = Vector2:new(15, 15)
    }

    setmetatable(game, SnakeGame)
    game:initEntities()
    return game
end

-- Initialize / sync Entity instances with components for head, body, and food
function SnakeGame:initEntities()
    self.entities = {}

    -- Snake head entity with Position, Movement, and Renderer components
    local headEntity = Entity:new()
    headEntity:addComponent("Position", self.snake[1])
    headEntity:addComponent("Movement", self.direction)
    headEntity:addComponent("Renderer", Entity.createRenderer({0.5, 1.0, 0.6}, CELL - 2))
    table.insert(self.entities, headEntity)

    -- Snake body entities with Position and Renderer components
    for i = 2, #self.snake do
        local bodyEntity = Entity:new()
        bodyEntity:addComponent("Position", self.snake[i])
        bodyEntity:addComponent("Renderer", Entity.createRenderer({0.3, 0.8, 0.4}, CELL - 2))
        table.insert(self.entities, bodyEntity)
    end

    -- Food entity with Position and Renderer components
    self.foodEntity = Entity:new()
    self.foodEntity:addComponent("Position", self.food)
    self.foodEntity:addComponent("Renderer", Entity.createRenderer({1.0, 0.3, 0.3}, CELL - 2))
end

-- Randomly spawn food on an empty grid position
function SnakeGame:spawnFood()
    local occupied = {}
    for _, seg in ipairs(self.snake) do
        occupied[seg.x .. "," .. seg.y] = true
    end

    local emptyCells = {}
    for x = 0, self.gridSize - 1 do
        for y = 0, self.gridSize - 1 do
            if not occupied[x .. "," .. y] then
                table.insert(emptyCells, {x = x, y = y})
            end
        end
    end

    if #emptyCells > 0 then
        local choice
        if love and love.math and love.math.random then
            choice = emptyCells[love.math.random(1, #emptyCells)]
        else
            choice = emptyCells[math.random(1, #emptyCells)]
        end
        self.food = Vector2:new(choice.x, choice.y)
        if self.foodEntity then
            self.foodEntity:addComponent("Position", self.food)
        end
    end
end

-- Change snake direction (prevents reversing into itself)
function SnakeGame:changeDirection(dx, dy)
    local requested = Vector2:new(dx, dy)

    -- Prevent 180-degree immediate reversal
    if self.direction.x + requested.x == 0 and self.direction.y + requested.y == 0 then
        return
    end

    self.nextDirection = requested
end

-- Update game state
function SnakeGame:update(dt)
    if self.gameOver then
        return
    end

    self.timer = self.timer + (dt or 0)
    if self.timer >= self.stepTime then
        self.timer = self.timer - self.stepTime
        self:step()
    end
end

-- Single movement step
function SnakeGame:step()
    self.direction = self.nextDirection
    local head = self.snake[1]

    -- Vector2 addition metamethod (__add)
    local newHead = head + self.direction

    -- 1. Check wall collisions
    if newHead.x < 0 or newHead.x >= self.gridSize or newHead.y < 0 or newHead.y >= self.gridSize then
        self:triggerGameOver()
        return
    end

    -- 2. Check self collisions using Vector2 equality (__eq)
    for _, seg in ipairs(self.snake) do
        if newHead == seg then
            self:triggerGameOver()
            return
        end
    end

    -- Add new head
    table.insert(self.snake, 1, newHead)

    -- 3. Check food collision using Vector2 equality (__eq)
    if newHead == self.food then
        self.score = self.score + 1
        if self.score > self.highScore then
            self.highScore = self.score
            HighScore:save(self.highScore)
        end

        -- Bonus: Emit observer pattern event
        Events:emit("food_eaten", {
            score = self.score,
            food = self.food
        })

        self:spawnFood()
    else
        -- Remove tail when not eating
        table.remove(self.snake)
    end

    -- Keep entity components in sync
    self:initEntities()
end

function SnakeGame:triggerGameOver()
    self.gameOver = true
    if self.score > self.highScore then
        self.highScore = self.score
    end
    HighScore:save(self.highScore)

    -- Bonus: Emit game_over event
    Events:emit("game_over", {
        score = self.score,
        highScore = self.highScore
    })
end

-- Reset game
function SnakeGame:reset()
    self.score = 0
    self.gameOver = false
    self.timer = 0
    self.direction = Vector2:new(1, 0)
    self.nextDirection = Vector2:new(1, 0)
    self.snake = {
        Vector2:new(10, 10),
        Vector2:new(9, 10),
        Vector2:new(8, 10)
    }
    self.highScore = HighScore:load() or 0
    self:spawnFood()
    self:initEntities()
end

-- Draw snake, food, score, and game over screen
function SnakeGame:draw()
    if not (love and love.graphics) then
        return
    end

    -- Background
    love.graphics.setBackgroundColor(0.1, 0.1, 0.12)

    -- Draw Food
    love.graphics.setColor(1.0, 0.3, 0.3)
    love.graphics.rectangle("fill", self.food.x * CELL, self.food.y * CELL, CELL - 2, CELL - 2, 4, 4)

    -- Draw Snake (Head brighter than body)
    for i, seg in ipairs(self.snake) do
        if i == 1 then
            love.graphics.setColor(0.5, 1.0, 0.6) -- Brighter head
        else
            love.graphics.setColor(0.3, 0.8, 0.4) -- Body segment
        end
        love.graphics.rectangle("fill", seg.x * CELL, seg.y * CELL, CELL - 2, CELL - 2, 3, 3)
    end

    -- Draw Score and High Score HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. tostring(self.score), 15, 12)
    love.graphics.print("High Score: " .. tostring(self.highScore), 15, 30)

    -- Draw Game Over Overlay
    if self.gameOver then
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 0, 0, self.gridSize * CELL, self.gridSize * CELL)

        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("GAME OVER", 0, (self.gridSize * CELL) / 2 - 60, self.gridSize * CELL, "center")

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Final Score: " .. self.score .. "\nHigh Score: " .. self.highScore .. "\n\nPress SPACE to Restart",
            0, (self.gridSize * CELL) / 2 - 20, self.gridSize * CELL, "center")
    end
end

return SnakeGame
