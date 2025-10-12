-- four_seasons_city.lua - Four Seasons City Map
-- 四季城地图：分为春夏秋冬四个区域

return {
    id = "four_seasons_city",
    name = "Four Seasons City",
    width = 4800,  -- 75 tiles * 64
    height = 4800,  -- 75 tiles * 64
    tileSize = 64,
    
    -- Mixed season (will be overridden by zones)
    season = "spring",
    
    -- Background color (neutral)
    backgroundColor = {0.4, 0.5, 0.4},
    
    -- Season zones (define which area uses which season)
    seasonZones = {
        -- Spring zone (Northwest)
        {
            x = 0,
            y = 0,
            width = 2400,
            height = 2400,
            season = "spring"
        },
        -- Summer zone (Northeast)
        {
            x = 2400,
            y = 0,
            width = 2400,
            height = 2400,
            season = "summer"
        },
        -- Autumn zone (Southwest)
        {
            x = 0,
            y = 2400,
            width = 2400,
            height = 2400,
            season = "autumn"
        },
        -- Winter zone (Southeast)
        {
            x = 2400,
            y = 2400,
            width = 2400,
            height = 2400,
            season = "winter"
        },
    },
    
    -- Spawn points (safe locations away from buildings)
    spawnPoints = {
        {x = 2400, y = 2100, name = "City Center"},  -- North of monument
        {x = 1200, y = 1200, name = "Spring District"},
        {x = 3600, y = 1200, name = "Summer District"},
        {x = 1200, y = 3600, name = "Autumn District"},
        {x = 3600, y = 3600, name = "Winter District"},
    },
    
    -- Buildings
    buildings = {
        -- ===== CENTER PLAZA =====
        -- Central fountain/monument
        {
            type = "monument",
            x = 2300,
            y = 2300,
            width = 200,
            height = 200,
            color = {0.8, 0.8, 0.9},
            name = "Four Seasons Monument"
        },
        
        -- ===== SPRING DISTRICT (Northwest) =====
        -- Spring Temple
        {
            type = "temple",
            x = 800,
            y = 800,
            width = 300,
            height = 300,
            color = {0.9, 0.7, 0.8},
            name = "Spring Temple"
        },
        -- Spring houses
        {type = "house", x = 400, y = 400, width = 150, height = 150, color = {0.7, 0.8, 0.6}},
        {type = "house", x = 600, y = 400, width = 150, height = 150, color = {0.7, 0.8, 0.6}},
        {type = "house", x = 400, y = 1200, width = 150, height = 150, color = {0.7, 0.8, 0.6}},
        {type = "house", x = 1400, y = 400, width = 150, height = 150, color = {0.7, 0.8, 0.6}},
        {type = "house", x = 1600, y = 400, width = 150, height = 150, color = {0.7, 0.8, 0.6}},
        {type = "house", x = 1400, y = 1200, width = 150, height = 150, color = {0.7, 0.8, 0.6}},
        -- Spring garden
        {type = "garden", x = 1200, y = 1600, width = 400, height = 300, color = {0.4, 0.7, 0.4}},
        
        -- ===== SUMMER DISTRICT (Northeast) =====
        -- Summer Beach House
        {
            type = "beach_house",
            x = 3200,
            y = 800,
            width = 300,
            height = 300,
            color = {0.9, 0.8, 0.5},
            name = "Summer Beach House"
        },
        -- Summer houses
        {type = "house", x = 2600, y = 400, width = 150, height = 150, color = {0.9, 0.7, 0.4}},
        {type = "house", x = 2800, y = 400, width = 150, height = 150, color = {0.9, 0.7, 0.4}},
        {type = "house", x = 2600, y = 1200, width = 150, height = 150, color = {0.9, 0.7, 0.4}},
        {type = "house", x = 3800, y = 400, width = 150, height = 150, color = {0.9, 0.7, 0.4}},
        {type = "house", x = 4000, y = 400, width = 150, height = 150, color = {0.9, 0.7, 0.4}},
        {type = "house", x = 3800, y = 1200, width = 150, height = 150, color = {0.9, 0.7, 0.4}},
        -- Summer pool
        {type = "pool", x = 3400, y = 1600, width = 400, height = 300, color = {0.3, 0.6, 0.9}},
        
        -- ===== AUTUMN DISTRICT (Southwest) =====
        -- Autumn Harvest Hall
        {
            type = "harvest_hall",
            x = 800,
            y = 3200,
            width = 300,
            height = 300,
            color = {0.8, 0.5, 0.3},
            name = "Harvest Hall"
        },
        -- Autumn houses
        {type = "house", x = 400, y = 2600, width = 150, height = 150, color = {0.7, 0.5, 0.3}},
        {type = "house", x = 600, y = 2600, width = 150, height = 150, color = {0.7, 0.5, 0.3}},
        {type = "house", x = 400, y = 3800, width = 150, height = 150, color = {0.7, 0.5, 0.3}},
        {type = "house", x = 1400, y = 2600, width = 150, height = 150, color = {0.7, 0.5, 0.3}},
        {type = "house", x = 1600, y = 2600, width = 150, height = 150, color = {0.7, 0.5, 0.3}},
        {type = "house", x = 1400, y = 3800, width = 150, height = 150, color = {0.7, 0.5, 0.3}},
        -- Autumn farm
        {type = "farm", x = 1200, y = 2800, width = 400, height = 300, color = {0.6, 0.5, 0.3}},
        
        -- ===== WINTER DISTRICT (Southeast) =====
        -- Winter Ice Palace
        {
            type = "ice_palace",
            x = 3200,
            y = 3200,
            width = 300,
            height = 300,
            color = {0.8, 0.9, 1.0},
            name = "Ice Palace"
        },
        -- Winter houses
        {type = "house", x = 2600, y = 2600, width = 150, height = 150, color = {0.7, 0.8, 0.9}},
        {type = "house", x = 2800, y = 2600, width = 150, height = 150, color = {0.7, 0.8, 0.9}},
        {type = "house", x = 2600, y = 3800, width = 150, height = 150, color = {0.7, 0.8, 0.9}},
        {type = "house", x = 3800, y = 2600, width = 150, height = 150, color = {0.7, 0.8, 0.9}},
        {type = "house", x = 4000, y = 2600, width = 150, height = 150, color = {0.7, 0.8, 0.9}},
        {type = "house", x = 3800, y = 3800, width = 150, height = 150, color = {0.7, 0.8, 0.9}},
        -- Winter ice rink
        {type = "ice_rink", x = 3400, y = 2800, width = 400, height = 300, color = {0.7, 0.8, 0.95}},
    },
    
    -- NPCs
    npcs = {
        -- Spring NPCs
        {
            id = "spring_guardian",
            name = "Spring Guardian",
            x = 1000,
            y = 1000,
            type = "guardian",
            dialogue = "Welcome to the Spring District!"
        },
        -- Summer NPCs
        {
            id = "summer_guardian",
            name = "Summer Guardian",
            x = 3400,
            y = 1000,
            type = "guardian",
            dialogue = "Enjoy the warmth of Summer!"
        },
        -- Autumn NPCs
        {
            id = "autumn_guardian",
            name = "Autumn Guardian",
            x = 1000,
            y = 3400,
            type = "guardian",
            dialogue = "Harvest season is here!"
        },
        -- Winter NPCs
        {
            id = "winter_guardian",
            name = "Winter Guardian",
            x = 3400,
            y = 3400,
            type = "guardian",
            dialogue = "Welcome to the Winter Wonderland!"
        },
    },
    
    -- Encounter zones
    encounterZones = {
        -- Spring encounters
        {x = 600, y = 1800, radius = 120, type = "forest"},
        {x = 1800, y = 600, radius = 120, type = "forest"},
        
        -- Summer encounters
        {x = 3000, y = 600, radius = 120, type = "beach"},
        {x = 4200, y = 1800, radius = 120, type = "beach"},
        
        -- Autumn encounters
        {x = 600, y = 4200, radius = 120, type = "harvest"},
        {x = 1800, y = 4200, radius = 120, type = "harvest"},
        
        -- Winter encounters
        {x = 3000, y = 4200, radius = 120, type = "snow"},
        {x = 4200, y = 3000, radius = 120, type = "snow"},
    },
}

