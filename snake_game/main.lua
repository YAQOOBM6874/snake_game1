-- main.lua
-- Entry point for Snake Game (Part 1, 2, 3 & Bonus)

local GameState = require("gamestate")
local gameState = GameState:new()

-- LÖVE2D Callbacks
if love then
    function love.load()
        love.window.setMode(600, 600)
        love.window.setTitle("Snake Game - Lua & LÖVE2D")
    end

    function love.update(dt)
        gameState:update(dt)
    end

    function love.draw()
        gameState:draw()
    end

    function love.keypressed(key)
        if key == "escape" then
            love.event.quit()
            return
        end

        -- Handle state transitions and input
        if gameState.current == "menu" then
            if key == "space" or key == "return" then
                gameState:switch("playing")
            end
        elseif gameState.current == "playing" then
            local game = gameState.states.playing

            -- Arrow keys & WASD input handling
            if key == "up" or key == "w" then game:changeDirection(0, -1) end
            if key == "down" or key == "s" then game:changeDirection(0, 1) end
            if key == "left" or key == "a" then game:changeDirection(-1, 0) end
            if key == "right" or key == "d" then game:changeDirection(1, 0) end

            -- Command pattern handling via Input
            if game.handleKey then
                game:handleKey(key)
            end

            -- Restart on space or return after Game Over
            if (game.gameOver or (game.game and game.game.gameOver)) and (key == "space" or key == "return") then
                if game.reset then game:reset() end
            end
        end
    end
else
    -- =========================================================================
    -- Command-line mode (run with: lua main.lua)
    -- Verifies all requirements and components when run outside LÖVE2D
    -- =========================================================================
    print("=======================================================")
    print("  Lua Game Programming Assignment - Verification Test  ")
    print("=======================================================\n")

    local Vector2 = require("vector2")
    local Entity = require("entity")
    local HighScore = require("highscore")
    local Events = require("events")
    local SnakeGame = require("snake_game")
    local Input = require("input")

    -- 1. Test Task 2.2: Vector2 Custom Metamethods
    print("[1] Testing Task 2.2: Vector2 Metamethods...")
    local v1 = Vector2:new(10, 5)
    local v2 = Vector2:new(2, 3)
    local vSum = v1 + v2
    assert(vSum.x == 12 and vSum.y == 8, "Vector2 __add failed")
    assert(vSum == Vector2:new(12, 8), "Vector2 __eq failed")
    assert(tostring(vSum) == "Vector2(12, 8)", "Vector2 __tostring failed")
    print("    PASSED: __add, __eq, and __tostring work properly! Result: " .. tostring(vSum))

    -- 2. Test Task 1.2: Entity Component Pattern
    print("\n[2] Testing Task 1.2: Entity Component Pattern...")
    local ent = Entity:new()
    ent:addComponent("Position", Entity.createPosition(15, 20))
    ent:addComponent("Movement", Entity.createMovement(1, 0))
    ent:addComponent("Renderer", Entity.createRenderer({0.5, 1, 0.5}, 28))
    assert(ent:hasComponent("Position"), "Entity hasComponent failed")
    assert(ent:getComponent("Position").x == 15, "Entity getComponent failed")
    assert(ent.x == 15 and ent.y == 20, "Entity transparent coordinate access failed")
    print("    PASSED: Components (Position, Movement, Renderer) registered successfully!")

    -- 3. Test Task 2.1: Resource Management (to-be-closed high score)
    print("\n[3] Testing Task 2.1: HighScore Resource Management...")
    HighScore:save(42)
    local loadedScore = HighScore:load()
    assert(loadedScore == 42, "HighScore save/load failed")
    print("    PASSED: HighScore saved and loaded score 42 successfully!")

    -- 4. Test Bonus: Observer Pattern Event System
    print("\n[4] Testing Bonus Challenge: Events Observer Pattern...")
    local eventFired = false
    Events:subscribe("food_eaten", function(data)
        eventFired = true
        print("    [Event Callback] food_eaten received! Score is now: " .. tostring(data.score))
    end)
    Events:emit("food_eaten", {score = 1, food = Vector2:new(15, 15)})
    assert(eventFired, "Events emit/subscribe failed")
    print("    PASSED: Event system subscribed and emitted data correctly!")

    -- 5. Test Task 1.1 & Task 3.1: GameState Manager and Core Snake Game Logic
    print("\n[5] Testing Task 1.1 & Task 3.1: GameState and SnakeGame...")
    local sm = GameState:new()
    assert(sm.current == "menu", "Initial state must be 'menu'")
    print("    State starts as: " .. sm.current)
    sm:switch("playing")
    assert(sm.current == "playing", "State switch failed")
    print("    Switched state to: " .. sm.current)

    local game = sm.states.playing.game or sm.states.playing
    local initialHead = Vector2:new(game.snake[1].x, game.snake[1].y)
    print("    Initial snake head: " .. tostring(initialHead))

    -- Simulate game tick
    game:update(game.stepTime + 0.01)
    local movedHead = game.snake[1]
    print("    Snake moved to: " .. tostring(movedHead))
    assert(movedHead.x == initialHead.x + 1 and movedHead.y == initialHead.y, "Snake movement step failed")

    -- Test change direction
    game:changeDirection(0, 1) -- turn down
    game:update(game.stepTime + 0.01)
    local turnedHead = game.snake[1]
    print("    Snake turned down to: " .. tostring(turnedHead))
    assert(turnedHead.y == movedHead.y + 1, "Direction change failed")

    -- Test eating food
    game.food = Vector2:new(turnedHead.x + 1, turnedHead.y)
    game:changeDirection(1, 0)
    local oldScore = game.score
    game:update(game.stepTime + 0.01)
    print("    Food eaten! New score: " .. tostring(game.score))
    assert(game.score == oldScore + 1, "Food eating score increment failed")

    -- Test wall collision
    game.snake[1] = Vector2:new(game.gridSize - 1, 5)
    game.direction = Vector2:new(1, 0)
    game.nextDirection = Vector2:new(1, 0)
    game:update(game.stepTime + 0.01)
    assert(game.gameOver == true, "Wall collision game over detection failed")
    print("    PASSED: Wall collision detected, gameOver = true")

    -- 6. Test Task 3.2: Input Handling (Command Pattern)
    print("\n[6] Testing Task 3.2: Input Handling...")
    local testInput = Input:new()
    local cmdTriggered = false
    testInput:bind("space", function() cmdTriggered = true end)
    testInput:handleKey("space")
    assert(cmdTriggered, "Input bind/handleKey failed")
    print("    PASSED: Input command pattern works as expected!")

    print("\n=======================================================")
    print("  ALL TESTS PASSED! Project is complete and ready.     ")
    print("  Run with LÖVE2D: love .                              ")
    print("=======================================================\n")
end
