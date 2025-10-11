-- town_01.lua - First town map
-- 第一个城镇地图：新手村

return {
    id = "town_01",
    name = "Newbie Village",
    width = 3200,
    height = 2400,
    tileSize = 64,
    
    -- Background color (grass green)
    backgroundColor = {0.3, 0.6, 0.35},
    
    -- Spawn points
    spawnPoints = {
        {x = 1600, y = 1200, name = "Main Gate"},
        {x = 800, y = 600, name = "North District"},
        {x = 2400, y = 1800, name = "South District"},
    },
    
    -- Buildings (for rendering and collision)
    buildings = {
        -- Town Hall (center)
        {
            type = "town_hall",
            x = 1400,
            y = 1000,
            width = 400,
            height = 400,
            color = {0.7, 0.5, 0.3},
            name = "Town Hall"
        },
        
        -- Weapon Shop (northwest)
        {
            type = "shop",
            x = 600,
            y = 400,
            width = 200,
            height = 200,
            color = {0.6, 0.4, 0.2},
            name = "Weapon Shop"
        },
        
        -- Item Shop (northeast)
        {
            type = "shop",
            x = 2400,
            y = 400,
            width = 200,
            height = 200,
            color = {0.5, 0.6, 0.4},
            name = "Item Shop"
        },
        
        -- Inn (southwest)
        {
            type = "inn",
            x = 600,
            y = 1600,
            width = 200,
            height = 200,
            color = {0.8, 0.6, 0.4},
            name = "Inn"
        },
        
        -- Temple (southeast)
        {
            type = "temple",
            x = 2400,
            y = 1600,
            width = 200,
            height = 200,
            color = {0.9, 0.9, 0.7},
            name = "Temple"
        },
        
        -- Houses (scattered)
        {type = "house", x = 1000, y = 600, width = 120, height = 120, color = {0.6, 0.5, 0.4}},
        {type = "house", x = 1200, y = 600, width = 120, height = 120, color = {0.6, 0.5, 0.4}},
        {type = "house", x = 2000, y = 800, width = 120, height = 120, color = {0.6, 0.5, 0.4}},
        {type = "house", x = 2200, y = 800, width = 120, height = 120, color = {0.6, 0.5, 0.4}},
        {type = "house", x = 1000, y = 1600, width = 120, height = 120, color = {0.6, 0.5, 0.4}},
        {type = "house", x = 1200, y = 1600, width = 120, height = 120, color = {0.6, 0.5, 0.4}},
        {type = "house", x = 2000, y = 1400, width = 120, height = 120, color = {0.6, 0.5, 0.4}},
        {type = "house", x = 2200, y = 1400, width = 120, height = 120, color = {0.6, 0.5, 0.4}},
    },
    
    -- Roads (for visual reference)
    roads = {
        -- Main horizontal road
        {x1 = 0, y1 = 1200, x2 = 3200, y2 = 1200, width = 100},
        -- Main vertical road
        {x1 = 1600, y1 = 0, x2 = 1600, y2 = 2400, width = 100},
        -- Cross roads
        {x1 = 800, y1 = 400, x2 = 800, y2 = 1800, width = 60},
        {x1 = 2400, y1 = 400, x2 = 2400, y2 = 1800, width = 60},
    },
    
    -- NPCs
    npcs = {
        {
            id = "guard_01",
            name = "Town Guard",
            x = 1600,
            y = 1100,
            type = "guard",
            dialogue = "Welcome to Newbie Village!"
        },
        {
            id = "merchant_01",
            name = "Weapon Merchant",
            x = 700,
            y = 500,
            type = "merchant",
            dialogue = "Looking for weapons?"
        },
        {
            id = "healer_01",
            name = "Healer",
            x = 2500,
            y = 1700,
            type = "healer",
            dialogue = "May the light heal you."
        },
    },
    
    -- Encounter zones (wild areas)
    encounterZones = {
        -- North forest
        {x = 400, y = 200, radius = 150, type = "forest"},
        {x = 800, y = 100, radius = 120, type = "forest"},
        
        -- East plains
        {x = 2800, y = 600, radius = 140, type = "plains"},
        {x = 2900, y = 1000, radius = 130, type = "plains"},
        
        -- South swamp
        {x = 400, y = 2000, radius = 160, type = "swamp"},
        {x = 800, y = 2200, radius = 140, type = "swamp"},
        
        -- West hills
        {x = 200, y = 1200, radius = 150, type = "hills"},
        {x = 400, y = 1400, radius = 120, type = "hills"},
    },
    
    -- Decorations (trees, rocks, etc.)
    decorations = {
        -- Trees around the town
        {type = "tree", x = 300, y = 300, radius = 20},
        {type = "tree", x = 500, y = 250, radius = 20},
        {type = "tree", x = 2700, y = 300, radius = 20},
        {type = "tree", x = 2900, y = 350, radius = 20},
        {type = "tree", x = 300, y = 2100, radius = 20},
        {type = "tree", x = 500, y = 2050, radius = 20},
        
        -- Rocks
        {type = "rock", x = 200, y = 1000, radius = 15},
        {type = "rock", x = 3000, y = 1400, radius = 15},
    },
}

