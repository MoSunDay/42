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

-- Get season theme colors
function MapData:getSeasonTheme(season)
    local themes = {
        spring = {
            grass1 = {0.35, 0.70, 0.35},
            grass2 = {0.30, 0.65, 0.30},
            grass3 = {0.40, 0.75, 0.40},
            grass4 = {0.28, 0.60, 0.28},
            road1 = {0.50, 0.48, 0.45},
            road2 = {0.48, 0.46, 0.43},
            roadLine = {0.90, 0.88, 0.85},
            flower1 = {1.0, 0.4, 0.6},
            flower2 = {0.9, 0.7, 0.3},
            flower3 = {0.6, 0.4, 0.9},
            tree = {0.2, 0.5, 0.2}
        },
        summer = {
            grass1 = {0.25, 0.60, 0.25},
            grass2 = {0.22, 0.55, 0.22},
            grass3 = {0.28, 0.65, 0.28},
            grass4 = {0.20, 0.50, 0.20},
            road1 = {0.55, 0.53, 0.50},
            road2 = {0.52, 0.50, 0.48},
            roadLine = {0.95, 0.93, 0.90},
            flower1 = {1.0, 0.8, 0.2},
            flower2 = {0.9, 0.3, 0.3},
            flower3 = {0.3, 0.6, 0.9},
            tree = {0.15, 0.45, 0.15}
        },
        autumn = {
            grass1 = {0.65, 0.55, 0.30},
            grass2 = {0.60, 0.50, 0.28},
            grass3 = {0.70, 0.60, 0.32},
            grass4 = {0.58, 0.48, 0.26},
            road1 = {0.48, 0.46, 0.44},
            road2 = {0.45, 0.43, 0.41},
            roadLine = {0.88, 0.86, 0.84},
            flower1 = {0.9, 0.5, 0.2},
            flower2 = {0.8, 0.3, 0.1},
            flower3 = {0.7, 0.6, 0.3},
            tree = {0.6, 0.3, 0.1}
        },
        winter = {
            grass1 = {0.85, 0.90, 0.95},
            grass2 = {0.80, 0.85, 0.90},
            grass3 = {0.88, 0.92, 0.96},
            grass4 = {0.78, 0.83, 0.88},
            road1 = {0.60, 0.62, 0.65},
            road2 = {0.58, 0.60, 0.63},
            roadLine = {0.70, 0.72, 0.75},
            flower1 = {0.9, 0.9, 0.95},
            flower2 = {0.85, 0.88, 0.92},
            flower3 = {0.88, 0.90, 0.94},
            tree = {0.3, 0.35, 0.4}
        }
    }
    return themes[season] or themes.spring
end

-- Draw the map (optimized with camera culling and seasonal themes)
function MapData:draw(camera)
    -- Get season (default to spring)
    local season = self.season or "spring"
    local theme = self:getSeasonTheme(season)

    -- Draw background color
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    -- Get camera viewport for culling
    local camX, camY = 0, 0
    local viewWidth, viewHeight = love.graphics.getDimensions()
    if camera then
        camX, camY = camera.x - viewWidth / 2, camera.y - viewHeight / 2
    end

    -- Calculate visible tile range
    local tilesX = math.floor(self.width / self.tileSize)
    local tilesY = math.floor(self.height / self.tileSize)

    local startX = math.max(0, math.floor(camX / self.tileSize) - 1)
    local endX = math.min(tilesX - 1, math.floor((camX + viewWidth) / self.tileSize) + 1)
    local startY = math.max(0, math.floor(camY / self.tileSize) - 1)
    local endY = math.min(tilesY - 1, math.floor((camY + viewHeight) / self.tileSize) + 1)

    -- Enhanced color palette
    local roadColor1 = {0.45, 0.45, 0.48}
    local roadColor2 = {0.42, 0.42, 0.45}
    local roadLine = {0.35, 0.35, 0.38}
    local grassColor1 = {0.25, 0.55, 0.25}
    local grassColor2 = {0.22, 0.50, 0.22}
    local grassDark = {0.18, 0.45, 0.18}
    local grassLight = {0.28, 0.60, 0.28}

    -- Draw tiles with enhanced visuals
    for y = startY, endY do
        for x = startX, endX do
            local px = x * self.tileSize
            local py = y * self.tileSize

            -- Create road pattern (every 5 tiles)
            local isRoad = (x % 5 == 0 or y % 5 == 0)

            if isRoad then
                -- Draw road with texture effect
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(roadColor1)
                else
                    love.graphics.setColor(roadColor2)
                end
                love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)

                -- Add road markings
                love.graphics.setColor(roadLine)
                if x % 5 == 0 then
                    -- Vertical road
                    love.graphics.rectangle("fill", px + self.tileSize * 0.45, py, self.tileSize * 0.1, self.tileSize)
                else
                    -- Horizontal road
                    love.graphics.rectangle("fill", px, py + self.tileSize * 0.45, self.tileSize, self.tileSize * 0.1)
                end
            else
                -- Draw grass with variation
                local noise = (math.sin(x * 0.5) + math.cos(y * 0.7)) * 0.5
                local colorIndex = (x + y) % 2

                if noise > 0.3 then
                    love.graphics.setColor(grassLight)
                elseif noise < -0.3 then
                    love.graphics.setColor(grassDark)
                elseif colorIndex == 0 then
                    love.graphics.setColor(grassColor1)
                else
                    love.graphics.setColor(grassColor2)
                end
                love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)

                -- Add grass details (small dots)
                if (x + y * 7) % 3 == 0 then
                    love.graphics.setColor(grassDark[1], grassDark[2], grassDark[3], 0.3)
                    love.graphics.circle("fill", px + self.tileSize * 0.3, py + self.tileSize * 0.3, 2)
                    love.graphics.circle("fill", px + self.tileSize * 0.7, py + self.tileSize * 0.6, 2)
                end
            end
        end
    end

    -- Draw buildings with enhanced visuals
    for _, building in ipairs(self.buildings) do
        -- Check if building is in viewport
        if camera then
            if building.x + building.width < camX or building.x > camX + viewWidth or
               building.y + building.height < camY or building.y > camY + viewHeight then
                goto continue
            end
        end

        -- Building shadow
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", building.x + 5, building.y + 5, building.width, building.height, 5, 5)

        -- Building body
        love.graphics.setColor(building.color or {0.7, 0.5, 0.3})
        love.graphics.rectangle("fill", building.x, building.y, building.width, building.height, 5, 5)

        -- Building roof (darker top)
        love.graphics.setColor(0.5, 0.3, 0.2)
        love.graphics.rectangle("fill", building.x, building.y, building.width, 20, 5, 5)

        -- Building windows
        love.graphics.setColor(0.3, 0.4, 0.5, 0.7)
        local windowSize = 15
        local windowSpacing = 30
        for wx = 1, math.floor(building.width / windowSpacing) - 1 do
            for wy = 1, math.floor((building.height - 30) / windowSpacing) do
                love.graphics.rectangle("fill",
                    building.x + wx * windowSpacing,
                    building.y + 25 + wy * windowSpacing,
                    windowSize, windowSize, 2, 2)
            end
        end

        -- Building border
        love.graphics.setColor(0.4, 0.25, 0.15)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", building.x, building.y, building.width, building.height, 5, 5)
        love.graphics.setLineWidth(1)

        ::continue::
    end

    -- Draw subtle grid lines only on roads
    love.graphics.setColor(0.35, 0.35, 0.38, 0.3)
    for x = startX, endX do
        if x % 5 == 0 then
            local px = x * self.tileSize
            love.graphics.line(px, startY * self.tileSize, px, (endY + 1) * self.tileSize)
        end
    end
    for y = startY, endY do
        if y % 5 == 0 then
            local py = y * self.tileSize
            love.graphics.line(startX * self.tileSize, py, (endX + 1) * self.tileSize, py)
        end
    end

    -- Draw map border
    love.graphics.setColor(0.5, 0.4, 0.25)
    love.graphics.setLineWidth(8)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1)
end

return MapData

