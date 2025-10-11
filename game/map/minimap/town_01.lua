-- town_01.lua - Minimap data for town_01
-- 城镇小地图数据

return {
    id = "town_01",
    name = "Newbie Village",
    
    -- Minimap size (pixels)
    width = 200,
    height = 150,
    
    -- Scale factor (world units to minimap pixels)
    scale = 16,  -- 3200 / 200 = 16
    
    -- Simplified building positions for minimap
    buildings = {
        {x = 87, y = 62, w = 25, h = 25, color = {0.7, 0.5, 0.3}, name = "Town Hall"},
        {x = 37, y = 25, w = 12, h = 12, color = {0.6, 0.4, 0.2}, name = "Weapon Shop"},
        {x = 150, y = 25, w = 12, h = 12, color = {0.5, 0.6, 0.4}, name = "Item Shop"},
        {x = 37, y = 100, w = 12, h = 12, color = {0.8, 0.6, 0.4}, name = "Inn"},
        {x = 150, y = 100, w = 12, h = 12, color = {0.9, 0.9, 0.7}, name = "Temple"},
    },
    
    -- Roads
    roads = {
        {x1 = 0, y1 = 75, x2 = 200, y2 = 75, width = 6},  -- Horizontal
        {x1 = 100, y1 = 0, x2 = 100, y2 = 150, width = 6},  -- Vertical
    },
    
    -- Background color
    backgroundColor = {0.3, 0.6, 0.35},
    
    -- Border color
    borderColor = {0.2, 0.2, 0.2},
}

