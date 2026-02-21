-- desert_oasis.lua - Desert Oasis Map
-- 沙漠绿洲地图 - 中级区域

return {
    id = "desert_oasis",
    name = "Desert Oasis",
    width = 3200,
    height = 3200,
    tileSize = 64,
    
    season = "desert",
    
    backgroundColor = {0.9, 0.8, 0.5},
    
    seasonZones = {
        {
            x = 0,
            y = 0,
            width = 1600,
            height = 1600,
            season = "desert"
        },
        {
            x = 1600,
            y = 0,
            width = 1600,
            height = 1600,
            season = "desert"
        },
        {
            x = 0,
            y = 1600,
            width = 1600,
            height = 1600,
            season = "desert"
        },
        {
            x = 1600,
            y = 1600,
            width = 1600,
            height = 1600,
            season = "desert"
        },
    },
    
    spawnPoints = {
        {x = 1600, y = 1600, name = "Oasis Center"},
        {x = 600, y = 600, name = "North Oasis"},
        {x = 2600, y = 600, name = "East Dunes"},
        {x = 600, y = 2600, name = "West Ruins"},
        {x = 2600, y = 2600, name = "South Camp"},
    },
    
    buildings = {
        {
            type = "oasis_temple",
            x = 1450,
            y = 1450,
            width = 300,
            height = 300,
            color = {0.85, 0.75, 0.55},
            name = "Oasis Temple"
        },
        {
            type = "pyramid",
            x = 500,
            y = 500,
            width = 250,
            height = 250,
            color = {0.9, 0.85, 0.7},
            name = "Ancient Pyramid"
        },
        {
            type = "caravan_post",
            x = 2400,
            y = 500,
            width = 200,
            height = 200,
            color = {0.7, 0.5, 0.35},
            name = "Caravan Post"
        },
        {
            type = "water_well",
            x = 1500,
            y = 600,
            width = 120,
            height = 120,
            color = {0.4, 0.55, 0.65},
            name = "Central Well"
        },
        {type = "tent", x = 300, y = 300, width = 100, height = 100, color = {0.8, 0.6, 0.4}},
        {type = "tent", x = 450, y = 350, width = 100, height = 100, color = {0.75, 0.55, 0.35}},
        {type = "tent", x = 800, y = 400, width = 100, height = 100, color = {0.85, 0.65, 0.45}},
        {type = "tent", x = 400, y = 900, width = 100, height = 100, color = {0.7, 0.5, 0.3}},
        {
            type = "sandstone_fort",
            x = 500,
            y = 2200,
            width = 280,
            height = 280,
            color = {0.75, 0.65, 0.5},
            name = "Sandstone Fort"
        },
        {type = "house", x = 300, y = 1800, width = 120, height = 120, color = {0.8, 0.7, 0.55}},
        {type = "house", x = 450, y = 1800, width = 120, height = 120, color = {0.75, 0.65, 0.5}},
        {type = "house", x = 900, y = 2000, width = 120, height = 120, color = {0.85, 0.75, 0.6}},
        {type = "house", x = 300, y = 2500, width = 120, height = 120, color = {0.7, 0.6, 0.45}},
        {
            type = "market",
            x = 2200,
            y = 2200,
            width = 250,
            height = 250,
            color = {0.65, 0.5, 0.35},
            name = "Desert Market"
        },
        {type = "house", x = 1800, y = 1800, width = 120, height = 120, color = {0.8, 0.7, 0.55}},
        {type = "house", x = 1950, y = 1800, width = 120, height = 120, color = {0.75, 0.65, 0.5}},
        {type = "house", x = 2500, y = 2000, width = 120, height = 120, color = {0.7, 0.6, 0.45}},
        {type = "house", x = 1800, y = 2500, width = 120, height = 120, color = {0.85, 0.75, 0.6}},
        {
            type = "oasis_pool",
            x = 1400,
            y = 2500,
            width = 300,
            height = 200,
            color = {0.3, 0.5, 0.65},
            name = "South Oasis Pool"
        },
    },
    
    npcs = {
        {
            id = "oasis_elder",
            name = "Oasis Elder",
            x = 1600,
            y = 1550,
            type = "elder",
            dialogue = "Welcome to the Desert Oasis, traveler!"
        },
        {
            id = "pyramid_guardian",
            name = "Pyramid Guardian",
            x = 650,
            y = 650,
            type = "guardian",
            dialogue = "The ancient pyramid holds many secrets..."
        },
        {
            id = "caravan_leader",
            name = "Caravan Leader",
            x = 2500,
            y = 600,
            type = "merchant",
            dialogue = "Need supplies for the journey?"
        },
        {
            id = "fort_captain",
            name = "Fort Captain",
            x = 650,
            y = 2350,
            type = "warrior",
            dialogue = "The desert is dangerous. Stay alert!"
        },
        {
            id = "market_merchant",
            name = "Market Merchant",
            x = 2350,
            y = 2350,
            type = "merchant",
            dialogue = "Fresh dates and spices for sale!"
        },
    },
    
    encounterZones = {
        {x = 400, y = 1200, radius = 120, type = "sand"},
        {x = 1200, y = 400, radius = 120, type = "sand"},
        {x = 2000, y = 400, radius = 120, type = "dunes"},
        {x = 2800, y = 1200, radius = 120, type = "dunes"},
        {x = 400, y = 2800, radius = 120, type = "ruins"},
        {x = 1200, y = 2800, radius = 120, type = "oasis"},
        {x = 2000, y = 2800, radius = 120, type = "sand"},
        {x = 2800, y = 2000, radius = 120, type = "dunes"},
    },
    
    waterAreas = {
        {x = 1400, y = 2500, width = 300, height = 200, type = "oasis_pool"},
        {x = 1450, y = 550, width = 200, height = 150, type = "well"},
    },
}
