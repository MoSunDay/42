-- summer_town.lua - Summer themed town map
-- Bright sun, vibrant colors, beach atmosphere

local SummerTown = {}

SummerTown.name = "Summer Town"
SummerTown.width = 2000
SummerTown.height = 2000
SummerTown.season = "summer"
SummerTown.bgmTheme = "summer"

-- Color palette for summer
SummerTown.colors = {
    grass = {0.5, 0.9, 0.3},
    path = {0.95, 0.9, 0.6},
    building = {0.95, 0.95, 0.9},
    roof = {0.3, 0.6, 0.9},
    water = {0.2, 0.6, 0.95},
    tree = {0.2, 0.7, 0.3},
    sand = {0.95, 0.9, 0.7}
}

SpringTown.buildings = {
    {x = 400, y = 400, width = 150, height = 120, type = "inn", name = "Sunny Beach Inn"},
    {x = 700, y = 400, width = 120, height = 100, type = "shop", name = "Summer Bazaar"},
    {x = 1000, y = 400, width = 140, height = 110, type = "lighthouse", name = "Lighthouse"},
    {x = 400, y = 800, width = 130, height = 100, type = "house", name = "Fisherman's Hut"},
    {x = 700, y = 800, width = 130, height = 100, type = "house", name = "Ice Cream Shop"},
    {x = 1000, y = 800, width = 160, height = 130, type = "guild", name = "Sailor's Guild"},
    {x = 600, y = 1200, width = 200, height = 150, type = "beach", name = "Beach Plaza"}
}

SummerTown.paths = {
    {x = 300, y = 450, width = 800, height = 40},
    {x = 300, y = 850, width = 800, height = 40},
    {x = 450, y = 300, width = 40, height = 700},
    {x = 750, y = 300, width = 40, height = 700},
    {x = 1050, y = 300, width = 40, height = 700}
}

SummerTown.decorations = {
    -- Palm trees
    {x = 350, y = 350, type = "palm", size = 40},
    {x = 600, y = 350, type = "palm", size = 35},
    {x = 900, y = 350, type = "palm", size = 40},
    {x = 1150, y = 350, type = "palm", size = 35},
    
    -- Beach umbrellas
    {x = 500, y = 1100, type = "umbrella", size = 25},
    {x = 700, y = 1100, type = "umbrella", size = 25},
    {x = 900, y = 1100, type = "umbrella", size = 25}
}

SummerTown.npcs = {
    {x = 420, y = 430, type = "innkeeper", name = "Sunny"},
    {x = 730, y = 430, type = "merchant", name = "Beach Vendor"},
    {x = 1030, y = 430, type = "lighthouse_keeper", name = "Beacon"},
    {x = 430, y = 830, type = "fisherman", name = "Old Salt"},
    {x = 730, y = 830, type = "vendor", name = "Ice Cream Joe"},
    {x = 1030, y = 860, type = "guild_master", name = "Captain Wave"},
    {x = 700, y = 1250, type = "surfer", name = "Tide Rider"},
    {x = 550, y = 1250, type = "child", name = "Sandy"},
    {x = 850, y = 1250, type = "lifeguard", name = "Coral"}
}

SummerTown.water = {
    {x = 1300, y = 400, width = 300, height = 400, type = "ocean"}
}

return SummerTown

