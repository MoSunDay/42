-- generated_06_sky.lua - Celestial Gardens
-- 天界花园 - 天空区域

local MapGenerator = require("map.map_generator")

math.randomseed(47)

local config = {
    id = "generated_06_sky",
    name = "Celestial Gardens",
    theme = "sky",
    level = 25,
    minTiles = 50,
    maxTiles = 60,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "Floating islands in the sky, home to celestial beings."
map.recommendedLevel = {min = 25, max = 30}

table.insert(map.npcs, {
    id = "sky_guardian",
    type = "friendly",
    name = "Cloud Seraph",
    x = map.width * 0.5,
    y = map.height * 0.3,
    dialogue = "Welcome to the realm above the clouds, mortal."
})

table.insert(map.npcs, {
    id = "sky_merchant",
    type = "merchant",
    name = "Star Trader Nova",
    x = map.width * 0.3,
    y = map.height * 0.7,
    dialogue = "Items infused with starlight. Very rare indeed!"
})

table.insert(map.npcs, {
    id = "cloud_keeper",
    type = "healer",
    name = "Cloud Keeper Aria",
    x = map.width * 0.75,
    y = map.height * 0.55,
    dialogue = "Let the celestial light heal your wounds."
})

for i = 1, 5 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "floating_platform",
        x = x,
        y = y,
        size = math.random() * 0.3 + 0.7
    })
end

return map
