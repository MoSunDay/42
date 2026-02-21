-- generated_05_cave.lua - Crystal Depths
-- 水晶深渊 - 洞穴区域

local MapGenerator = require("map.map_generator")

math.randomseed(46)

local config = {
    id = "generated_05_cave",
    name = "Crystal Depths",
    theme = "cave",
    level = 20,
    minTiles = 30,
    maxTiles = 40,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "Deep underground caverns filled with glowing crystals."
map.recommendedLevel = {min = 20, max = 25}

table.insert(map.npcs, {
    id = "cave_explorer",
    type = "friendly",
    name = "Spelunker Digg",
    x = map.width * 0.35,
    y = map.height * 0.5,
    dialogue = "These caves go deeper than anyone knows."
})

table.insert(map.npcs, {
    id = "crystal_merchant",
    type = "merchant",
    name = "Gem Trader Luma",
    x = map.width * 0.65,
    y = map.height * 0.35,
    dialogue = "Crystals from the depths hold magical properties."
})

for i = 1, 6 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "crystal_formation",
        x = x,
        y = y,
        size = math.random() * 0.4 + 0.6
    })
end

return map
