-- generated_01_woods.lua - Whispering Woods
-- 低语森林 - 新手区域

local MapGenerator = require("map.map_generator")

math.randomseed(42)

local config = {
    id = "generated_01_woods",
    name = "Whispering Woods",
    theme = "forest",
    level = 1,
    minTiles = 35,
    maxTiles = 45,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "A mystical forest filled with ancient trees and gentle spirits."
map.recommendedLevel = {min = 1, max = 5}

table.insert(map.npcs, {
    id = "forest_ranger",
    type = "friendly",
    name = "Forest Ranger",
    x = map.width * 0.3,
    y = map.height * 0.3,
    dialogue = "Welcome to the Whispering Woods! Watch out for slimes."
})

table.insert(map.npcs, {
    id = "herbalist",
    type = "merchant",
    name = "Herbalist Mira",
    x = map.width * 0.7,
    y = map.height * 0.7,
    dialogue = "I sell potions made from forest herbs. Care to buy some?"
})

for i = 1, 3 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "tree",
        x = x,
        y = y,
        size = math.random() * 0.5 + 0.8
    })
end

return map
