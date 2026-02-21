-- generated_02_desert.lua - Scorching Dunes
-- 灼热沙丘 - 沙漠区域

local MapGenerator = require("map.map_generator")

math.randomseed(43)

local config = {
    id = "generated_02_desert",
    name = "Scorching Dunes",
    theme = "desert",
    level = 5,
    minTiles = 40,
    maxTiles = 50,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "Endless sand dunes hide forgotten treasures and deadly creatures."
map.recommendedLevel = {min = 5, max = 10}

table.insert(map.npcs, {
    id = "desert_merchant",
    type = "merchant",
    name = "Sand Trader Omar",
    x = map.width * 0.25,
    y = map.height * 0.25,
    dialogue = "Water is precious here. I trade goods for gold."
})

table.insert(map.npcs, {
    id = "nomad_guide",
    type = "friendly",
    name = "Nomad Guide",
    x = map.width * 0.75,
    y = map.height * 0.6,
    dialogue = "The desert holds many secrets. Tread carefully."
})

for i = 1, 4 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "cactus",
        x = x,
        y = y,
        size = math.random() * 0.3 + 0.7
    })
end

return map
