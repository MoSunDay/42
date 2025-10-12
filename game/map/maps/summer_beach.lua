-- summer_beach.lua - Summer Beach Map
-- 夏日海滩

return {
    id = "summer_beach",
    name = "Summer Beach",
    width = 2400,
    height = 2400,
    tileSize = 64,
    
    -- Season
    season = "summer",
    
    -- Background color
    backgroundColor = {0.25, 0.60, 0.25},
    
    -- Spawn points
    spawnPoints = {
        {x = 1200, y = 1200, name = "Beach Center"},
        {x = 600, y = 600, name = "North Shore"},
        {x = 1800, y = 1800, name = "South Cove"},
    },
    
    -- Buildings
    buildings = {
        -- Beach House
        {
            type = "beach_house",
            x = 1100,
            y = 1100,
            width = 200,
            height = 200,
            color = {0.9, 0.8, 0.5},
            name = "Beach House"
        },
        -- Surf Shop
        {
            type = "shop",
            x = 400,
            y = 400,
            width = 150,
            height = 150,
            color = {0.8, 0.7, 0.4},
            name = "Surf Shop"
        },
        -- Lighthouse
        {
            type = "lighthouse",
            x = 1600,
            y = 400,
            width = 150,
            height = 150,
            color = {0.9, 0.9, 0.7},
            name = "Lighthouse"
        },
    },
    
    -- NPCs
    npcs = {
        {
            id = "beach_guard",
            name = "Beach Guard",
            x = 1200,
            y = 1200,
            type = "guard",
            dialogue = "Enjoy the summer sun!"
        },
    },
    
    -- Encounter zones
    encounterZones = {
        {x = 800, y = 800, radius = 120, type = "beach"},
        {x = 1600, y = 1600, radius = 120, type = "beach"},
        {x = 400, y = 1600, radius = 120, type = "beach"},
    },
}

