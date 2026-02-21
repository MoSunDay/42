-- generated_07_swamp.lua - Murkmire Marsh
-- 暗沼湿地 - 沼泽区域

local MapGenerator = require("map.map_generator")

math.randomseed(48)

local config = {
    id = "generated_07_swamp",
    name = "Murkmire Marsh",
    theme = "swamp",
    level = 30,
    minTiles = 45,
    maxTiles = 55,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "A foggy swamp where danger lurks beneath murky waters."
map.recommendedLevel = {min = 30, max = 35}

table.insert(map.npcs, {
    id = "swamp_witch",
    type = "merchant",
    name = "Swamp Witch Morana",
    x = map.width * 0.25,
    y = map.height * 0.4,
    dialogue = "I brew potions from the swamp's dark ingredients."
})

table.insert(map.npcs, {
    id = "marsh_guide",
    type = "friendly",
    name = "Marsh Walker Fen",
    x = map.width * 0.7,
    y = map.height * 0.6,
    dialogue = "Follow my path if you wish to survive the mire."
})

for i = 1, 6 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "murky_pool",
        x = x,
        y = y,
        size = math.random() * 0.5 + 0.5
    })
end

return map
