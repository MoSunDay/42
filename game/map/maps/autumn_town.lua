-- autumn_town.lua - Autumn themed town map
-- Golden leaves, harvest season, warm colors

local AutumnTown = {}

AutumnTown.name = "Autumn Town"
AutumnTown.width = 2000
AutumnTown.height = 2000
AutumnTown.season = "autumn"
AutumnTown.bgmTheme = "autumn"

-- Color palette for autumn
AutumnTown.colors = {
    grass = {0.7, 0.6, 0.3},
    path = {0.8, 0.7, 0.5},
    building = {0.8, 0.7, 0.6},
    roof = {0.8, 0.4, 0.2},
    water = {0.4, 0.5, 0.6},
    tree = {0.9, 0.6, 0.2},  -- Orange/golden leaves
    leaves = {0.9, 0.5, 0.1}
}

AutumnTown.buildings = {
    {x = 400, y = 400, width = 150, height = 120, type = "inn", name = "Harvest Inn"},
    {x = 700, y = 400, width = 120, height = 100, type = "shop", name = "Autumn Market"},
    {x = 1000, y = 400, width = 140, height = 110, type = "barn", name = "Grand Barn"},
    {x = 400, y = 800, width = 130, height = 100, type = "house", name = "Farmer's Home"},
    {x = 700, y = 800, width = 130, height = 100, type = "house", name = "Baker's Shop"},
    {x = 1000, y = 800, width = 160, height = 130, type = "guild", name = "Harvest Guild"},
    {x = 600, y = 1200, width = 200, height = 150, type = "plaza", name = "Festival Square"}
}

AutumnTown.paths = {
    {x = 300, y = 450, width = 800, height = 40},
    {x = 300, y = 850, width = 800, height = 40},
    {x = 450, y = 300, width = 40, height = 700},
    {x = 750, y = 300, width = 40, height = 700},
    {x = 1050, y = 300, width = 40, height = 700}
}

AutumnTown.decorations = {
    -- Autumn trees
    {x = 350, y = 350, type = "autumn_tree", size = 40},
    {x = 600, y = 350, type = "autumn_tree", size = 35},
    {x = 900, y = 350, type = "autumn_tree", size = 40},
    {x = 1150, y = 350, type = "autumn_tree", size = 35},
    
    -- Pumpkin patches
    {x = 500, y = 600, type = "pumpkins", size = 20},
    {x = 800, y = 600, type = "pumpkins", size = 25},
    {x = 500, y = 1000, type = "hay_bale", size = 20},
    {x = 900, y = 1000, type = "hay_bale", size = 20}
}

AutumnTown.npcs = {
    {x = 420, y = 430, type = "innkeeper", name = "Amber"},
    {x = 730, y = 430, type = "merchant", name = "Harvest Trader"},
    {x = 1030, y = 430, type = "farmer", name = "Grain Master"},
    {x = 430, y = 830, type = "farmer", name = "Crop Keeper"},
    {x = 730, y = 830, type = "baker", name = "Bread Smith"},
    {x = 1030, y = 860, type = "guild_master", name = "Autumn Chief"},
    {x = 700, y = 1250, type = "musician", name = "Fiddle"},
    {x = 550, y = 1250, type = "child", name = "Leaf"},
    {x = 850, y = 1250, type = "elder", name = "Wise Harvest"}
}

AutumnTown.water = {
    {x = 1300, y = 400, width = 200, height = 200, type = "pond"}
}

return AutumnTown

