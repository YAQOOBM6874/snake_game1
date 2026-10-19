# Lua Game Programming Assignment: Snake Game

A modular, robust implementation of the classic Snake Game built with Lua and LÖVE2D, demonstrating modern Lua design patterns, entity-component architecture, and Lua 5.4 features.

---

## 📁 Required Project Structure

```text
snake_game/
├── main.lua          -- Entry point (LÖVE2D lifecycle & CLI test runner)
├── gamestate.lua     -- State manager (Menu & Playing states)
├── entity.lua        -- Entity Component System (Position, Movement, Renderer)
├── vector2.lua       -- 2D Vector math with metamethods (__add, __eq, __tostring)
├── highscore.lua     -- Save/Load system using Lua 5.4 to-be-closed variables
├── input.lua         -- Command pattern input management
├── events.lua        -- Bonus: Observer pattern event system
├── states/
│   ├── menu_state.lua  -- Start menu state
│   └── game_state.lua  -- Active gameplay state
└── snake_game.lua    -- Core snake mechanics, collision & food logic
```

---

## 🚀 How to Run

### Method 1: Running with LÖVE2D (GUI)
Make sure [LÖVE](https://love2d.org/) is installed:
```bash
# From inside snake_game/ or the project root:
love .
```
or
```bash
love snake_game
```

### Method 2: Running with standard Lua CLI
```bash
lua main.lua
```
When run via `lua main.lua`, an automated test suite executes and validates all modules (Vector2 math, Entity-Component, HighScore save/load, Event emission, GameState switching, and collision detection).

---

## 💡 Modern Lua Feature Used

**Feature:** **To-Be-Closed Variables (`<close>`)** in Lua 5.4 (`highscore.lua`).

**Explanation:**
In `highscore.lua`, the high score persistence functions utilize Lua 5.4's `<close>` variable attribute:
```lua
local file <close> = io.open("highscore.txt", "w")
```
When a local variable is declared with `<close>`, Lua guarantees that the object's `__close` metamethod is automatically invoked when the variable leaves scope. For file handles, this deterministic resource management (RAII) ensures files are immediately and safely closed and flushed, even if a runtime error occurs or the function returns early. A fallback is included for LuaJIT / older runtimes to ensure universal compatibility.

---

## 🌟 Implemented Tasks & Checklist

- [x] **Task 1.1: Game State Manager (`gamestate.lua`)**
  - Modular state machine switching between `menu` and `playing`.
  - Proper module structure with `update(dt)` and `draw()` lifecycle methods.
- [x] **Task 1.2: Entity Component Pattern (`entity.lua`)**
  - Entity container with `addComponent`, `getComponent`, and `hasComponent`.
  - Concrete components: `Position`, `Movement`, and `Renderer`.
- [x] **Task 2.1: Resource Management with to-be-closed (`highscore.lua`)**
  - File-based save/load using Lua 5.4 `<close>`.
- [x] **Task 2.2: Custom Metamethods (`vector2.lua`)**
  - `Vector2:__add` (vector addition)
  - `Vector2:__eq` (vector equality)
  - `Vector2:__tostring` (formatted string representation)
- [x] **Task 3.1: Core Game Logic (`snake_game.lua`)**
  - Continuous movement with timer step interval.
  - Random food generation avoiding the snake body.
  - Score tracking and persistent high score updating.
  - Accurate wall collision and self-collision detection.
  - Visual hierarchy (brighter head, distinct food, dark aesthetic).
- [x] **Task 3.2: Input Handling (`input.lua`)**
  - Command pattern binding key actions to functions.
- [x] **Bonus (2 Points): Event System (`events.lua`)**
  - Observer pattern with `subscribe` and `emit`.
  - Integrated into game loop for `food_eaten` and `game_over` events.

---

## 🎮 Controls

| Key | Action |
| --- | --- |
| **Arrow Up / W** | Move Up |
| **Arrow Down / S** | Move Down |
| **Arrow Left / A** | Move Left |
| **Arrow Right / D** | Move Right |
| **Space / Enter** | Start Game / Restart after Game Over |
| **Escape** | Exit Game |
