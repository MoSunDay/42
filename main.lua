-- main.lua - Root bootstrap for LÖVE
-- Allows running `love .` from project root instead of `love game/`

local gamePrefix = "game/"
local paths = {
    "", "src", "src/core", "src/entities", "src/systems",
    "src/ui", "src/animations", "src/network", "account",
    "map", "map/maps", "map/minimap", "npcs", "lib",
    "src/tools", "src/data", "src/systems/battle",
    "src/systems/battle_simulator", "src/ui/battle",
}
for _, p in ipairs(paths) do
    package.path = package.path .. ";" .. gamePrefix .. p .. "/?.lua"
end

local content = love.filesystem.read("game/main.lua")
if not content then
    error("Cannot read game/main.lua. Run 'love .' from project root.")
end

local chunk, err = load(content, "game/main.lua")
if not chunk then
    error("Failed to load game/main.lua: " .. err)
end

chunk()
