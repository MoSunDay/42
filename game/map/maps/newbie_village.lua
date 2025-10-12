-- newbie_village.lua - Newbie Village with Four Seasons
-- 新手村 - 四季主题

return {
    id = "newbie_village",
    name = "Newbie Village - Four Seasons",
    width = 3200,
    height = 3200,
    tileSize = 64,
    
    -- Default season (will be overridden by zones)
    season = "spring",
    
    -- Background color
    backgroundColor = {0.4, 0.5, 0.4},
    
    -- Season zones (Four Seasons layout)
    seasonZones = {
        -- Spring zone (Northwest)
        {
            x = 0,
            y = 0,
            width = 1600,
            height = 1600,
            season = "spring"
        },
        -- Summer zone (Northeast)
        {
            x = 1600,
            y = 0,
            width = 1600,
            height = 1600,
            season = "summer"
        },
        -- Autumn zone (Southwest)
        {
            x = 0,
            y = 1600,
            width = 1600,
            height = 1600,
            season = "autumn"
        },
        -- Winter zone (Southeast)
        {
            x = 1600,
            y = 1600,
            width = 1600,
            height = 1600,
            season = "winter"
        },
    },
    
    -- Spawn points (safe locations)
    spawnPoints = {
        {x = 1600, y = 1600, name = "Village Center"},
        {x = 800, y = 800, name = "Spring District"},
        {x = 2400, y = 800, name = "Summer District"},
        {x = 800, y = 2400, name = "Autumn District"},
        {x = 2400, y = 2400, name = "Winter District"},
    },
    
    -- Buildings
    buildings = {
        -- ===== CENTER =====
        -- Village Hall (center)
        {
            type = "village_hall",
            x = 1500,
            y = 1500,
            width = 200,
            height = 200,
            color = {0.8, 0.7, 0.5},
            name = "Village Hall"
        },
        
        -- ===== SPRING DISTRICT (Northwest) =====
        -- Spring Temple
        {
            type = "temple",
            x = 600,
            y = 600,
            width = 180,
            height = 180,
            color = {0.9, 0.7, 0.8},
            name = "Spring Temple"
        },
        -- Spring houses
        {type = "house", x = 300, y = 300, width = 120, height = 120, color = {0.7, 0.8, 0.6}},
        {type = "house", x = 450, y = 300, width = 120, height = 120, color = {0.7, 0.8, 0.6}},
        {type = "house", x = 900, y = 400, width = 120, height = 120, color = {0.7, 0.8, 0.6}},
        {type = "house", x = 300, y = 900, width = 120, height = 120, color = {0.7, 0.8, 0.6}},
        
        -- ===== SUMMER DISTRICT (Northeast) =====
        -- Summer Shop
        {
            type = "shop",
            x = 2200,
            y = 600,
            width = 180,
            height = 180,
            color = {0.9, 0.8, 0.5},
            name = "Summer Shop"
        },
        -- Summer houses
        {type = "house", x = 1800, y = 300, width = 120, height = 120, color = {0.9, 0.7, 0.4}},
        {type = "house", x = 1950, y = 300, width = 120, height = 120, color = {0.9, 0.7, 0.4}},
        {type = "house", x = 2500, y = 400, width = 120, height = 120, color = {0.9, 0.7, 0.4}},
        {type = "house", x = 1800, y = 900, width = 120, height = 120, color = {0.9, 0.7, 0.4}},
        
        -- ===== AUTUMN DISTRICT (Southwest) =====
        -- Autumn Inn
        {
            type = "inn",
            x = 600,
            y = 2200,
            width = 180,
            height = 180,
            color = {0.8, 0.5, 0.3},
            name = "Autumn Inn"
        },
        -- Autumn houses
        {type = "house", x = 300, y = 1800, width = 120, height = 120, color = {0.7, 0.5, 0.3}},
        {type = "house", x = 450, y = 1800, width = 120, height = 120, color = {0.7, 0.5, 0.3}},
        {type = "house", x = 900, y = 2000, width = 120, height = 120, color = {0.7, 0.5, 0.3}},
        {type = "house", x = 300, y = 2500, width = 120, height = 120, color = {0.7, 0.5, 0.3}},
        
        -- ===== WINTER DISTRICT (Southeast) =====
        -- Winter Shrine
        {
            type = "shrine",
            x = 2200,
            y = 2200,
            width = 180,
            height = 180,
            color = {0.8, 0.9, 1.0},
            name = "Winter Shrine"
        },
        -- Winter houses
        {type = "house", x = 1800, y = 1800, width = 120, height = 120, color = {0.7, 0.8, 0.9}},
        {type = "house", x = 1950, y = 1800, width = 120, height = 120, color = {0.7, 0.8, 0.9}},
        {type = "house", x = 2500, y = 2000, width = 120, height = 120, color = {0.7, 0.8, 0.9}},
        {type = "house", x = 1800, y = 2500, width = 120, height = 120, color = {0.7, 0.8, 0.9}},
    },
    
    -- NPCs
    npcs = {
        -- Center
        {
            id = "village_chief",
            name = "Village Chief",
            x = 1600,
            y = 1550,
            type = "chief",
            dialogue = "Welcome to Four Seasons Village!"
        },
        -- Spring
        {
            id = "spring_guardian",
            name = "Spring Guardian",
            x = 700,
            y = 700,
            type = "guardian",
            dialogue = "Spring brings new life!"
        },
        -- Summer
        {
            id = "summer_merchant",
            name = "Summer Merchant",
            x = 2300,
            y = 700,
            type = "merchant",
            dialogue = "Hot deals in summer!"
        },
        -- Autumn
        {
            id = "autumn_innkeeper",
            name = "Autumn Innkeeper",
            x = 700,
            y = 2300,
            type = "innkeeper",
            dialogue = "Rest and harvest!"
        },
        -- Winter
        {
            id = "winter_priest",
            name = "Winter Priest",
            x = 2300,
            y = 2300,
            type = "priest",
            dialogue = "May winter bless you!"
        },
    },
    
    -- Encounter zones
    encounterZones = {
        -- Spring encounters
        {x = 400, y = 1200, radius = 100, type = "forest"},
        {x = 1200, y = 400, radius = 100, type = "forest"},
        
        -- Summer encounters
        {x = 2000, y = 400, radius = 100, type = "plains"},
        {x = 2800, y = 1200, radius = 100, type = "plains"},
        
        -- Autumn encounters
        {x = 400, y = 2800, radius = 100, type = "harvest"},
        {x = 1200, y = 2800, radius = 100, type = "harvest"},
        
        -- Winter encounters
        {x = 2000, y = 2800, radius = 100, type = "snow"},
        {x = 2800, y = 2000, radius = 100, type = "snow"},
    },
}

