-- highscore.lua
-- Task 2.1: Resource Management with to-be-closed
--
-- [Modern Lua Feature Explanation]:
-- Feature: Lua 5.4 To-Be-Closed Variables (`<close>`)
-- Explanation: When a local variable is declared with the `<close>` attribute (e.g. `local file <close> = io.open(...)`),
-- Lua ensures that its `__close` metamethod is automatically executed as soon as the variable's enclosing scope
-- terminates. For standard Lua file handles, this guarantees that the file is closed and its buffers flushed
-- even if an error occurs, an exception is thrown, or a function returns early (deterministic RAII cleanup).

local HighScore = {}

-- Safely detect whether the current Lua runtime natively supports Lua 5.4's `<close>` syntax
local loadChunk = loadstring or load
local testChunk = nil
if type(loadChunk) == "function" then
    local ok, res = pcall(loadChunk, "local x <close> = nil")
    if ok and type(res) == "function" then
        testChunk = res
    end
end

if testChunk ~= nil then
    -- Native Lua 5.4 implementation exactly as provided in Task 2.1 specification:
    local code = [[
        local HighScore = ...

        function HighScore:save(score)
            local file <close> = io.open("highscore.txt", "w")
            if file then
                file:write(tostring(score))
                -- File automatically closes even if error occurs
            end
        end

        function HighScore:load()
            local file <close> = io.open("highscore.txt", "r")
            if file then
                local content = file:read("*a")
                return tonumber(content) or 0
            end
            return 0
        end
    ]]
    loadChunk(code)(HighScore)
else
    -- Compatibility fallback for LuaJIT / LÖVE 11.x runtimes (which use Lua 5.1 grammar):
    function HighScore:save(score)
        local file = io.open("highscore.txt", "w")
        if file then
            file:write(tostring(score))
            file:close()
        end
    end

    function HighScore:load()
        local file = io.open("highscore.txt", "r")
        if file then
            local content = file:read("*a")
            file:close()
            return tonumber(content) or 0
        end
        return 0
    end
end

return HighScore
