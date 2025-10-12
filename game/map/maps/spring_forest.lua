-- spring_forest.lua - Spring Forest Map
-- 春之森林

return {
    id = "spring_forest",
    name = "Spring Forest",
    width = 2400,
    height = 2400,
    tileSize = 64,
    
    -- Season
    season = "spring",
    
    -- Background color
    backgroundColor = {0.35, 0.65, 0.35},
    
    -- Spawn points
    spawnPoints = {
        {x = 1200, y = 1200, name = "Forest Entrance"},
        {x = 600, y = 600, name = "North Grove"},
        {x = 1800, y = 1800, name = "South Meadow"},
    },
    
    -- Buildings
    buildings = {
        -- Forest Shrine
        {
            type = "shrine",
            x = 1100,
            y = 1100,
            width = 200,
            height = 200,
            color = {0.9, 0.7, 0.8},
            name = "Spring Shrine"
        },
        -- Ranger's Hut
        {
            type = "hut",
            x = 400,
            y = 400,
            width = 150,
            height = 150,
            color = {0.6, 0.7, 0.5},
            name = "Ranger's Hut"
        },
        -- Flower Shop
        {
            type = "shop",
            x = 1600,
            y = 400,
            width = 150,
            height = 150,
            color = {0.9, 0.6, 0.7},
            name = "Flower Shop"
        },
    },
    
    -- NPCs
    npcs = {
        {
            id = "spring_guardian",
            name = "Spring Guardian",
            x = 1200,
            y = 1200,
            type = "guardian",
            dialogue = "Welcome to the Spring Forest!"
        },
    },
    
    -- Encounter zones
    encounterZones = {
        {x = 800, y = 800, radius = 120, type = "forest"},
        {x = 1600, y = 1600, radius = 120, type = "forest"},
        {x = 400, y = 1600, radius = 120, type = "forest"},
    },
}

