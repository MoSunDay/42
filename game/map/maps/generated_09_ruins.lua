-- generated_09_ruins.lua - Ancient Citadel
-- 远古城堡 - 遗迹区域

local MapGenerator = require("map.map_generator")

math.randomseed(50)

local config = {
    id = "generated_09_ruins",
    name = "Ancient Citadel",
    theme = "ruins",
    level = 40,
    minTiles = 50,
    maxTiles = 60,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "Ruins of an ancient civilization, filled with secrets."
map.recommendedLevel = {min = 40, max = 45}

table.insert(map.npcs, {
    id = "ruins_scholar",
    type = "friendly",
    name = "Scholar Archaeon",
    x = map.width * 0.35,
    y = map.height * 0.35,
    dialogue = "These ruins hold the secrets of a lost empire."
})

table.insert(map.npcs, {
    id = "artifact_dealer",
    type = "merchant",
    name = "Artifact Dealer Relic",
    x = map.width * 0.7,
    y = map.height * 0.4,
    dialogue = "Authentic relics from the ancient times!"
})

table.insert(map.npcs, {
    id = "ghost_sentry",
    type = "friendly",
    name = "Spirit Sentry",
    x = map.width * 0.5,
    y = map.height * 0.7,
    dialogue = "I have guarded these halls for eternity..."
})

for i = 1, 5 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "ancient_pillar",
        x = x,
        y = y,
        size = math.random() * 0.3 + 0.7
    })
end

return map
