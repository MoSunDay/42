-- generated_08_crystal.lua - Prism Cavern
-- 棱镜洞穴 - 水晶区域

local MapGenerator = require("map.map_generator")

math.randomseed(49)

local config = {
    id = "generated_08_crystal",
    name = "Prism Cavern",
    theme = "crystal",
    level = 35,
    minTiles = 35,
    maxTiles = 45,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "A cavern of prismatic crystals and refracted light."
map.recommendedLevel = {min = 35, max = 40}

table.insert(map.npcs, {
    id = "crystal_keeper",
    type = "friendly",
    name = "Crystal Sage Prism",
    x = map.width * 0.4,
    y = map.height * 0.4,
    dialogue = "The crystals sing with ancient power."
})

table.insert(map.npcs, {
    id = "gem_collector",
    type = "merchant",
    name = "Gem Collector Shard",
    x = map.width * 0.65,
    y = map.height * 0.7,
    dialogue = "Each crystal tells a story. Want to hear them?"
})

for i = 1, 7 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    local colors = {{1,0.2,0.8}, {0.2,1,0.8}, {0.8,0.8,0.2}, {0.2,0.8,1}}
    table.insert(map.objects, {
        type = "prism_crystal",
        x = x,
        y = y,
        size = math.random() * 0.4 + 0.6,
        color = colors[math.random(#colors)]
    })
end

return map
