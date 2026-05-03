-- map_registry.lua - Map Registry and Metadata
-- 地图注册表和元数据管理

local MapRegistry = {}

local MAPS = {
    {
        id = "trial_of_awakening",
        name = "觉醒者试炼",
        theme = "ruins",
        level = {min = 1, max = 3},
        description = "古老的新手试炼场，觉醒者证明自己力量的第一站。",
        sizeRange = {min = 35, max = 40},
        unlocked = true,
        isDungeon = true,
        dungeonType = "tutorial",
        recommendedLevel = 1
    },
    {
        id = "generated_01_woods",
        name = "Whispering Woods",
        theme = "forest",
        level = {min = 1, max = 5},
        description = "A mystical forest filled with ancient trees and gentle spirits.",
        sizeRange = {min = 35, max = 45},
        unlocked = true
    },
    {
        id = "generated_02_desert",
        name = "Scorching Dunes",
        theme = "desert",
        level = {min = 5, max = 10},
        description = "Endless sand dunes hide forgotten treasures and deadly creatures.",
        sizeRange = {min = 40, max = 50},
        unlocked = true
    },
    {
        id = "generated_03_snow",
        name = "Frozen Peaks",
        theme = "snow",
        level = {min = 10, max = 15},
        description = "Treacherous mountain passes covered in eternal snow.",
        sizeRange = {min = 45, max = 55},
        unlocked = true
    },
    {
        id = "generated_04_volcanic",
        name = "Ember Caldera",
        theme = "volcanic",
        level = {min = 15, max = 20},
        description = "A volcanic region where fire and ash rule supreme.",
        sizeRange = {min = 40, max = 50},
        unlocked = true
    },
    {
        id = "generated_05_cave",
        name = "Crystal Depths",
        theme = "cave",
        level = {min = 20, max = 25},
        description = "Deep underground caverns filled with glowing crystals.",
        sizeRange = {min = 30, max = 40},
        unlocked = true
    },
    {
        id = "generated_06_sky",
        name = "Celestial Gardens",
        theme = "sky",
        level = {min = 25, max = 30},
        description = "Floating islands in the sky, home to celestial beings.",
        sizeRange = {min = 50, max = 60},
        unlocked = true
    },
    {
        id = "generated_07_swamp",
        name = "Murkmire Marsh",
        theme = "swamp",
        level = {min = 30, max = 35},
        description = "A foggy swamp where danger lurks beneath murky waters.",
        sizeRange = {min = 45, max = 55},
        unlocked = true
    },
    {
        id = "generated_08_crystal",
        name = "Prism Cavern",
        theme = "crystal",
        level = {min = 35, max = 40},
        description = "A cavern of prismatic crystals and refracted light.",
        sizeRange = {min = 35, max = 45},
        unlocked = true
    },
    {
        id = "generated_09_ruins",
        name = "Ancient Citadel",
        theme = "ruins",
        level = {min = 40, max = 45},
        description = "Ruins of an ancient civilization, filled with secrets.",
        sizeRange = {min = 50, max = 60},
        unlocked = true
    },
    {
        id = "generated_10_realm",
        name = "Dreamweaver's Realm",
        theme = "mystical",
        level = {min = 50, max = 50},
        description = "A realm between dreams and reality, home to the Dreamweaver.",
        sizeRange = {min = 55, max = 65},
        unlocked = true
    }
}

local mapIndex = {}
for i, map in ipairs(MAPS) do
    mapIndex[map.id] = i
end

function MapRegistry.get_all()
    return MAPS
end

function MapRegistry.get_by_id(id)
    local idx = mapIndex[id]
    if idx then
        return MAPS[idx]
    end
    return nil
end

function MapRegistry.get_by_index(idx)
    return MAPS[idx]
end

function MapRegistry.get_by_level(level)
    local result = {}
    for _, map in ipairs(MAPS) do
        if level >= map.level.min and level <= map.level.max then
            table.insert(result, map)
        end
    end
    return result
end

function MapRegistry.get_by_theme(theme)
    local result = {}
    for _, map in ipairs(MAPS) do
        if map.theme == theme then
            table.insert(result, map)
        end
    end
    return result
end

function MapRegistry.get_unlocked()
    local result = {}
    for _, map in ipairs(MAPS) do
        if map.unlocked then
            table.insert(result, map)
        end
    end
    return result
end

function MapRegistry.get_map_count()
    return #MAPS
end

function MapRegistry.get_adjacent_maps(mapId)
    local idx = mapIndex[mapId]
    if not idx then return {} end
    
    local result = {}
    if idx > 1 then
        table.insert(result, MAPS[idx - 1])
    end
    if idx < #MAPS then
        table.insert(result, MAPS[idx + 1])
    end
    return result
end

return MapRegistry
