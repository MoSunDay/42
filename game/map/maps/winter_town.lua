-- winter_town.lua - Winter themed town map
-- Snow covered, icy, cozy atmosphere

local WinterTown = {}

WinterTown.name = "Winter Town"
WinterTown.width = 2000
WinterTown.height = 2000
WinterTown.season = "winter"
WinterTown.bgmTheme = "winter"

-- Color palette for winter
WinterTown.colors = {
    grass = {0.9, 0.9, 0.95},  -- Snow
    path = {0.85, 0.85, 0.9},
    building = {0.8, 0.8, 0.85},
    roof = {0.7, 0.7, 0.75},
    water = {0.7, 0.8, 0.9},  -- Frozen
    tree = {0.3, 0.5, 0.4},  -- Evergreen
    snow = {1.0, 1.0, 1.0}
}

WinterTown.buildings = {
    {x = 400, y = 400, width = 150, height = 120, type = "inn", name = "Cozy Hearth Inn"},
    {x = 700, y = 400, width = 120, height = 100, type = "shop", name = "Winter Market"},
    {x = 1000, y = 400, width = 140, height = 110, type = "chapel", name = "Snow Chapel"},
    {x = 400, y = 800, width = 130, height = 100, type = "house", name = "Woodcutter's Cabin"},
    {x = 700, y = 800, width = 130, height = 100, type = "house", name = "Hot Cocoa Shop"},
    {x = 1000, y = 800, width = 160, height = 130, type = "guild", name = "Frost Guild"},
    {x = 600, y = 1200, width = 200, height = 150, type = "plaza", name = "Ice Rink Plaza"}
}

WinterTown.paths = {
    {x = 300, y = 450, width = 800, height = 40},
    {x = 300, y = 850, width = 800, height = 40},
    {x = 450, y = 300, width = 40, height = 700},
    {x = 750, y = 300, width = 40, height = 700},
    {x = 1050, y = 300, width = 40, height = 700}
}

WinterTown.decorations = {
    -- Evergreen trees
    {x = 350, y = 350, type = "pine", size = 40},
    {x = 600, y = 350, type = "pine", size = 35},
    {x = 900, y = 350, type = "pine", size = 40},
    {x = 1150, y = 350, type = "pine", size = 35},
    
    -- Snowmen
    {x = 500, y = 600, type = "snowman", size = 20},
    {x = 800, y = 600, type = "snowman", size = 25},
    
    -- Ice sculptures
    {x = 500, y = 1100, type = "ice_sculpture", size = 20},
    {x = 900, y = 1100, type = "ice_sculpture", size = 20}
}

WinterTown.npcs = {
    {x = 420, y = 430, type = "innkeeper", name = "Frost"},
    {x = 730, y = 430, type = "merchant", name = "Winter Trader"},
    {x = 1030, y = 430, type = "priest", name = "Snow Priest"},
    {x = 430, y = 830, type = "woodcutter", name = "Timber"},
    {x = 730, y = 830, type = "vendor", name = "Cocoa Master"},
    {x = 1030, y = 860, type = "guild_master", name = "Ice Captain"},
    {x = 700, y = 1250, type = "skater", name = "Glide"},
    {x = 550, y = 1250, type = "child", name = "Snowflake"},
    {x = 850, y = 1250, type = "elder", name = "Wise Winter"}
}

WinterTown.water = {
    {x = 1300, y = 400, width = 200, height = 200, type = "frozen_pond"}
}

return WinterTown

