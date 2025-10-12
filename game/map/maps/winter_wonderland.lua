-- winter_wonderland.lua - Winter Wonderland Map
-- 冬日仙境

return {
    id = "winter_wonderland",
    name = "Winter Wonderland",
    width = 2400,
    height = 2400,
    tileSize = 64,
    
    -- Season
    season = "winter",
    
    -- Background color
    backgroundColor = {0.85, 0.90, 0.95},
    
    -- Spawn points
    spawnPoints = {
        {x = 1200, y = 1200, name = "Ice Plaza"},
        {x = 600, y = 600, name = "North Glacier"},
        {x = 1800, y = 1800, name = "South Snowfield"},
    },
    
    -- Buildings
    buildings = {
        -- Ice Palace
        {
            type = "ice_palace",
            x = 1100,
            y = 1100,
            width = 200,
            height = 200,
            color = {0.8, 0.9, 1.0},
            name = "Ice Palace"
        },
        -- Snow Lodge
        {
            type = "lodge",
            x = 400,
            y = 400,
            width = 150,
            height = 150,
            color = {0.7, 0.8, 0.9},
            name = "Snow Lodge"
        },
        -- Ice Rink
        {
            type = "rink",
            x = 1600,
            y = 400,
            width = 150,
            height = 150,
            color = {0.6, 0.8, 1.0},
            name = "Ice Rink"
        },
    },
    
    -- NPCs
    npcs = {
        {
            id = "winter_queen",
            name = "Winter Queen",
            x = 1200,
            y = 1200,
            type = "queen",
            dialogue = "Welcome to the Winter Wonderland!"
        },
    },
    
    -- Encounter zones
    encounterZones = {
        {x = 800, y = 800, radius = 120, type = "snow"},
        {x = 1600, y = 1600, radius = 120, type = "snow"},
        {x = 400, y = 1600, radius = 120, type = "snow"},
    },
}

