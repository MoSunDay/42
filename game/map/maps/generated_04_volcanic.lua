-- generated_04_volcanic.lua - Ember Caldera
-- 余烬火山口 - 火山区域

local MapGenerator = require("map.map_generator")

math.randomseed(45)

local config = {
    id = "generated_04_volcanic",
    name = "Ember Caldera",
    theme = "volcanic",
    level = 15,
    minTiles = 40,
    maxTiles = 50,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "A volcanic region where fire and ash rule supreme."
map.recommendedLevel = {min = 15, max = 20}

table.insert(map.npcs, {
    id = "forge_master",
    type = "merchant",
    name = "Forge Master Ignis",
    x = map.width * 0.4,
    y = map.height * 0.3,
    dialogue = "The fire here perfects my craft. Need weapons?"
})

table.insert(map.npcs, {
    id = "lava_explorer",
    type = "friendly",
    name = "Volcanologist Pyra",
    x = map.width * 0.6,
    y = map.height * 0.7,
    dialogue = "The lava flows hold secrets of the earth's core."
})

for i = 1, 4 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "lava_pool",
        x = x,
        y = y,
        size = math.random() * 0.5 + 0.5
    })
end

return map
