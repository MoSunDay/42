-- map_data.lua - Map data structure
-- 地图数据结构定义

local MapData = {}
MapData.__index = MapData

-- Create new map data
function MapData.new(config)
    local self = setmetatable({}, MapData)
    
    -- Basic info
    self.id = config.id or "unknown"
    self.name = config.name or "Unnamed Map"
    self.width = config.width or 2000
    self.height = config.height or 2000
    
    -- Tile data
    self.tileSize = config.tileSize or 32
    self.tiles = config.tiles or {}
    
    -- Collision data
    self.collisionMap = config.collisionMap or {}
    
    -- Spawn points
    self.spawnPoints = config.spawnPoints or {{x = 1000, y = 1000}}
    
    -- Encounter zones
    self.encounterZones = config.encounterZones or {}
    
    -- NPCs
    self.npcs = config.npcs or {}
    
    -- Buildings/Objects
    self.buildings = config.buildings or {}
    
    -- Background color
    self.backgroundColor = config.backgroundColor or {0.2, 0.6, 0.3}
    
    return self
end

-- Get spawn point
function MapData:getSpawnPoint(index)
    index = index or 1
    return self.spawnPoints[index] or self.spawnPoints[1]
end

-- Check collision at position
function MapData:isCollision(x, y)
    local tileX = math.floor(x / self.tileSize)
    local tileY = math.floor(y / self.tileSize)
    
    if self.collisionMap[tileY] then
        return self.collisionMap[tileY][tileX] == 1
    end
    
    return false
end

return MapData

