-- generated_03_snow.lua - Frozen Peaks
-- 冰封山脉 - 雪山区域

local MapGenerator = require("map.map_generator")

math.randomseed(44)

local config = {
    id = "generated_03_snow",
    name = "Frozen Peaks",
    theme = "snow",
    level = 10,
    minTiles = 45,
    maxTiles = 55,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "Treacherous mountain passes covered in eternal snow."
map.recommendedLevel = {min = 10, max = 15}

table.insert(map.npcs, {
    id = "mountain_guide",
    type = "friendly",
    name = "Frost Guide Elara",
    x = map.width * 0.3,
    y = map.height * 0.4,
    dialogue = "The cold here can freeze even the bravest warrior."
})

table.insert(map.npcs, {
    id = "ice_merchant",
    type = "merchant",
    name = "Ice Crystal Seller",
    x = map.width * 0.7,
    y = map.height * 0.3,
    dialogue = "Crystals from the frozen depths. Very rare!"
})

for i = 1, 5 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "ice_formation",
        x = x,
        y = y,
        size = math.random() * 0.4 + 0.6
    })
end

return map
