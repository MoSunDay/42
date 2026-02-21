-- generated_10_realm.lua - Dreamweaver's Realm
-- 织梦者领域 - 幻境区域

local MapGenerator = require("map.map_generator")

math.randomseed(51)

local config = {
    id = "generated_10_realm",
    name = "Dreamweaver's Realm",
    theme = "mystical",
    level = 50,
    minTiles = 55,
    maxTiles = 65,
    tileSize = 64,
    includeTeleporter = true
}

local map = MapGenerator.generate(config)

map.description = "A realm between dreams and reality, home to the Dreamweaver."
map.recommendedLevel = {min = 50, max = 50}
map.isFinalMap = true

table.insert(map.npcs, {
    id = "dreamweaver",
    type = "boss",
    name = "The Dreamweaver",
    x = map.width * 0.5,
    y = map.height * 0.35,
    dialogue = "You've traveled far to reach my realm. What do you seek?",
    isBoss = true
})

table.insert(map.npcs, {
    id = "reality_keeper",
    type = "healer",
    name = "Reality Keeper",
    x = map.width * 0.3,
    y = map.height * 0.6,
    dialogue = "Between dream and reality, I maintain the balance."
})

table.insert(map.npcs, {
    id = "void_merchant",
    type = "merchant",
    name = "Void Trader",
    x = map.width * 0.7,
    y = map.height * 0.65,
    dialogue = "I trade in things that exist beyond imagination."
})

for i = 1, 8 do
    local x = math.random(200, map.width - 200)
    local y = math.random(200, map.height - 200)
    table.insert(map.objects, {
        type = "dream_rift",
        x = x,
        y = y,
        size = math.random() * 0.5 + 0.5
    })
end

return map
