-- autumn_harvest.lua - Autumn Harvest Map
-- 秋日丰收

return {
    id = "autumn_harvest",
    name = "Autumn Harvest Fields",
    width = 2400,
    height = 2400,
    tileSize = 64,
    
    -- Season
    season = "autumn",
    
    -- Background color
    backgroundColor = {0.65, 0.55, 0.30},
    
    -- Spawn points
    spawnPoints = {
        {x = 1200, y = 1200, name = "Harvest Square"},
        {x = 600, y = 600, name = "North Farm"},
        {x = 1800, y = 1800, name = "South Orchard"},
    },
    
    -- Buildings
    buildings = {
        -- Harvest Hall
        {
            type = "harvest_hall",
            x = 1100,
            y = 1100,
            width = 200,
            height = 200,
            color = {0.8, 0.5, 0.3},
            name = "Harvest Hall"
        },
        -- Barn
        {
            type = "barn",
            x = 400,
            y = 400,
            width = 150,
            height = 150,
            color = {0.7, 0.4, 0.2},
            name = "Barn"
        },
        -- Market
        {
            type = "market",
            x = 1600,
            y = 400,
            width = 150,
            height = 150,
            color = {0.8, 0.6, 0.3},
            name = "Harvest Market"
        },
    },
    
    -- NPCs
    npcs = {
        {
            id = "harvest_master",
            name = "Harvest Master",
            x = 1200,
            y = 1200,
            type = "master",
            dialogue = "The harvest is bountiful this year!"
        },
    },
    
    -- Encounter zones
    encounterZones = {
        {x = 800, y = 800, radius = 120, type = "farm"},
        {x = 1600, y = 1600, radius = 120, type = "farm"},
        {x = 400, y = 1600, radius = 120, type = "farm"},
    },
}

