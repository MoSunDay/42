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

-- Draw the map (simple grid-based rendering)
function MapData:draw()
    -- Draw background color
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    -- Draw grid pattern (simple town layout)
    local tilesX = math.floor(self.width / self.tileSize)
    local tilesY = math.floor(self.height / self.tileSize)

    -- Road colors
    local roadColor1 = {0.55, 0.55, 0.60}
    local roadColor2 = {0.50, 0.50, 0.55}
    local grassColor1 = {0.35, 0.65, 0.35}
    local grassColor2 = {0.30, 0.60, 0.30}

    for y = 0, tilesY - 1 do
        for x = 0, tilesX - 1 do
            local px = x * self.tileSize
            local py = y * self.tileSize

            -- Create road pattern (every 5 tiles)
            local isRoad = (x % 5 == 0 or y % 5 == 0)

            if isRoad then
                -- Draw road
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(roadColor1)
                else
                    love.graphics.setColor(roadColor2)
                end
                love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)
            else
                -- Draw grass
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(grassColor1)
                else
                    love.graphics.setColor(grassColor2)
                end
                love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)
            end
        end
    end

    -- Draw buildings
    for _, building in ipairs(self.buildings) do
        love.graphics.setColor(building.color or {0.7, 0.5, 0.3})
        love.graphics.rectangle("fill", building.x, building.y, building.width, building.height, 5, 5)

        -- Building border
        love.graphics.setColor(0.5, 0.3, 0.2)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", building.x, building.y, building.width, building.height, 5, 5)
        love.graphics.setLineWidth(1)
    end

    -- Draw grid lines (subtle)
    love.graphics.setColor(0.4, 0.4, 0.45, 0.2)
    for x = 0, tilesX do
        local px = x * self.tileSize
        love.graphics.line(px, 0, px, self.height)
    end
    for y = 0, tilesY do
        local py = y * self.tileSize
        love.graphics.line(0, py, self.width, py)
    end

    -- Draw map border
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1)
end

return MapData

