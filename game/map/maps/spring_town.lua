-- spring_town.lua - Spring themed town map
-- Cherry blossoms, fresh grass, gentle atmosphere

local SpringTown = {}

SpringTown.name = "Spring Town"
SpringTown.width = 2000
SpringTown.height = 2000
SpringTown.season = "spring"
SpringTown.bgmTheme = "spring"

-- Color palette for spring
SpringTown.colors = {
    grass = {0.4, 0.8, 0.4},
    path = {0.9, 0.85, 0.7},
    building = {0.95, 0.9, 0.85},
    roof = {0.9, 0.5, 0.5},
    water = {0.5, 0.7, 0.9},
    tree = {0.9, 0.6, 0.7},  -- Cherry blossom pink
    flower = {1.0, 0.8, 0.9}
}

-- Buildings (no monsters, only friendly NPCs)
SpringTown.buildings = {
    {x = 400, y = 400, width = 150, height = 120, type = "inn", name = "Cherry Blossom Inn"},
    {x = 700, y = 400, width = 120, height = 100, type = "shop", name = "Spring Market"},
    {x = 1000, y = 400, width = 140, height = 110, type = "temple", name = "Flower Temple"},
    {x = 400, y = 800, width = 130, height = 100, type = "house", name = "Gardener's House"},
    {x = 700, y = 800, width = 130, height = 100, type = "house", name = "Herbalist"},
    {x = 1000, y = 800, width = 160, height = 130, type = "guild", name = "Adventurer's Guild"},
    {x = 600, y = 1200, width = 200, height = 150, type = "plaza", name = "Town Plaza"}
}

-- Paths connecting buildings
SpringTown.paths = {
    {x = 300, y = 450, width = 800, height = 40},
    {x = 300, y = 850, width = 800, height = 40},
    {x = 450, y = 300, width = 40, height = 700},
    {x = 750, y = 300, width = 40, height = 700},
    {x = 1050, y = 300, width = 40, height = 700}
}

-- Decorative elements
SpringTown.decorations = {
    -- Cherry blossom trees
    {x = 350, y = 350, type = "tree", size = 40},
    {x = 600, y = 350, type = "tree", size = 35},
    {x = 900, y = 350, type = "tree", size = 40},
    {x = 1150, y = 350, type = "tree", size = 35},
    {x = 350, y = 750, type = "tree", size = 35},
    {x = 1150, y = 750, type = "tree", size = 40},
    
    -- Flower patches
    {x = 500, y = 600, type = "flowers", size = 20},
    {x = 800, y = 600, type = "flowers", size = 25},
    {x = 500, y = 1000, type = "flowers", size = 20},
    {x = 900, y = 1000, type = "flowers", size = 20},
    
    -- Fountain in plaza
    {x = 700, y = 1275, type = "fountain", size = 30}
}

-- Friendly NPCs (no monsters)
SpringTown.npcs = {
    {x = 420, y = 430, type = "innkeeper", name = "Sakura"},
    {x = 730, y = 430, type = "merchant", name = "Spring Trader"},
    {x = 1030, y = 430, type = "priest", name = "Blossom Priest"},
    {x = 430, y = 830, type = "gardener", name = "Green Thumb"},
    {x = 730, y = 830, type = "herbalist", name = "Petal Healer"},
    {x = 1030, y = 860, type = "guild_master", name = "Spring Captain"},
    {x = 700, y = 1250, type = "musician", name = "Melody"},
    {x = 550, y = 1250, type = "child", name = "Little Bloom"},
    {x = 850, y = 1250, type = "elder", name = "Wise Oak"}
}

-- Water features
SpringTown.water = {
    {x = 1300, y = 400, width = 200, height = 200, type = "pond"}
}

return SpringTown

