-- gamestate.lua
-- Task 1.1: Game State Manager
-- Simple state manager with two states: Menu and Playing

local GameState = {}
GameState.__index = GameState

function GameState:new()
    -- Robust require that supports both root package path and nested states/ directory
    local menuModule
    local gameModule

    local ok1, m = pcall(require, "states.menu_state")
    if ok1 then menuModule = m else menuModule = require("menu_state") end

    local ok2, g = pcall(require, "states.game_state")
    if ok2 then gameModule = g else gameModule = require("game_state") end

    local state = {
        current = "menu",
        states = {}
    }
    setmetatable(state, GameState)

    -- Instantiate states if they have constructors, or use modules directly
    if type(menuModule.new) == "function" then
        state.states.menu = menuModule:new(state)
    else
        state.states.menu = menuModule
    end

    if type(gameModule.new) == "function" then
        state.states.playing = gameModule:new(state)
    else
        state.states.playing = gameModule
    end

    return state
end

-- Switch between states
function GameState:switch(newState)
    if self.states[newState] then
        self.current = newState
        if self.states[newState].enter then
            self.states[newState]:enter()
        end
    end
end

-- Update current state
function GameState:update(dt)
    local state = self.states[self.current]
    if state and state.update then
        state:update(dt)
    end
end

-- Draw current state
function GameState:draw()
    local state = self.states[self.current]
    if state and state.draw then
        state:draw()
    end
end

return GameState
