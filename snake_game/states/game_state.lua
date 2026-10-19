-- states/game_state.lua
-- Playing State for GameState manager (Task 1.1)

local SnakeGame = require("snake_game")
local Input = require("input")

local GamePlayState = {}
GamePlayState.__index = function(tbl, key)
    if GamePlayState[key] ~= nil then
        return GamePlayState[key]
    end
    -- Delegate to underlying SnakeGame instance
    if tbl.game and tbl.game[key] ~= nil then
        if type(tbl.game[key]) == "function" then
            return function(_, ...)
                return tbl.game[key](tbl.game, ...)
            end
        else
            return tbl.game[key]
        end
    end
    return nil
end

function GamePlayState:new(stateManager)
    local state = {
        manager = stateManager,
        game = SnakeGame:new(),
        input = Input:new()
    }
    setmetatable(state, GamePlayState)

    -- Bind commands using Input (Command Pattern - Task 3.2)
    state.input:bind("up", function() state.game:changeDirection(0, -1) end)
    state.input:bind("w", function() state.game:changeDirection(0, -1) end)

    state.input:bind("down", function() state.game:changeDirection(0, 1) end)
    state.input:bind("s", function() state.game:changeDirection(0, 1) end)

    state.input:bind("left", function() state.game:changeDirection(-1, 0) end)
    state.input:bind("a", function() state.game:changeDirection(-1, 0) end)

    state.input:bind("right", function() state.game:changeDirection(1, 0) end)
    state.input:bind("d", function() state.game:changeDirection(1, 0) end)

    state.input:bind("space", function()
        if state.game.gameOver then
            state.game:reset()
        end
    end)

    state.input:bind("return", function()
        if state.game.gameOver then
            state.game:reset()
        end
    end)

    return state
end

function GamePlayState:enter()
    if self.game.gameOver then
        self.game:reset()
    end
end

function GamePlayState:update(dt)
    self.game:update(dt)
end

function GamePlayState:draw()
    self.game:draw()
end

function GamePlayState:changeDirection(dx, dy)
    self.game:changeDirection(dx, dy)
end

function GamePlayState:handleKey(key)
    self.input:handleKey(key)
end

function GamePlayState:reset()
    self.game:reset()
end

return GamePlayState
