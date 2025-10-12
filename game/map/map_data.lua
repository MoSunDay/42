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

    -- Season (spring, summer, autumn, winter)
    self.season = config.season or "spring"

    -- Season zones (for multi-season maps like Four Seasons City)
    self.seasonZones = config.seasonZones or {}

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

    -- Draw tiles with seasonal themes
    for y = startY, endY do
        for x = startX, endX do
            local px = x * self.tileSize
            local py = y * self.tileSize

            -- Determine season for this tile (check season zones)
            local tileSeason = season
            if #self.seasonZones > 0 then
                for _, zone in ipairs(self.seasonZones) do
                    if px >= zone.x and px < zone.x + zone.width and
                       py >= zone.y and py < zone.y + zone.height then
                        tileSeason = zone.season
                        break
                    end
                end
            end

            -- Get theme for this tile's season
            local tileTheme = self:getSeasonTheme(tileSeason)

            -- Create road pattern (every 5 tiles)
            local isRoad = (x % 5 == 0 or y % 5 == 0)

            if isRoad then
                -- Draw road with subtle texture
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(tileTheme.road1)
                else
                    love.graphics.setColor(tileTheme.road2)
                end
                love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)

                -- Add road center line (dashed)
                love.graphics.setColor(tileTheme.roadLine)
                if x % 5 == 0 then
                    -- Vertical road - dashed line
                    for dy = 0, self.tileSize, 20 do
                        if math.floor((py + dy) / 20) % 2 == 0 then
                            love.graphics.rectangle("fill", px + self.tileSize * 0.47, py + dy, self.tileSize * 0.06, 10)
                        end
                    end
                else
                    -- Horizontal road - dashed line
                    for dx = 0, self.tileSize, 20 do
                        if math.floor((px + dx) / 20) % 2 == 0 then
                            love.graphics.rectangle("fill", px + dx, py + self.tileSize * 0.47, 10, self.tileSize * 0.06)
                        end
                    end
                end
            else
                -- Draw grass with natural variation
                local noise = (math.sin(x * 0.5) + math.cos(y * 0.7)) * 0.5
                local colorIndex = (x + y) % 2

                if noise > 0.3 then
                    love.graphics.setColor(tileTheme.grass3)
                elseif noise < -0.3 then
                    love.graphics.setColor(tileTheme.grass4)
                elseif colorIndex == 0 then
                    love.graphics.setColor(tileTheme.grass1)
                else
                    love.graphics.setColor(tileTheme.grass2)
                end
                love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)

                -- Add seasonal decorations
                if tileSeason == "spring" then
                    -- Spring flowers
                    if (x * 7 + y * 11) % 15 == 0 then
                        local flowerColors = {tileTheme.flower1, tileTheme.flower2, tileTheme.flower3}
                        local flowerColor = flowerColors[((x + y) % 3) + 1]
                        love.graphics.setColor(flowerColor[1], flowerColor[2], flowerColor[3], 0.8)
                        love.graphics.circle("fill", px + self.tileSize * 0.3, py + self.tileSize * 0.4, 3)
                        love.graphics.circle("fill", px + self.tileSize * 0.7, py + self.tileSize * 0.6, 3)
                    end
                elseif tileSeason == "summer" then
                    -- Summer grass details
                    if (x + y * 7) % 4 == 0 then
                        love.graphics.setColor(tileTheme.grass4[1], tileTheme.grass4[2], tileTheme.grass4[3], 0.4)
                        love.graphics.circle("fill", px + self.tileSize * 0.3, py + self.tileSize * 0.3, 2)
                        love.graphics.circle("fill", px + self.tileSize * 0.7, py + self.tileSize * 0.7, 2)
                    end
                elseif tileSeason == "autumn" then
                    -- Autumn leaves
                    if (x * 5 + y * 9) % 12 == 0 then
                        local leafColors = {tileTheme.flower1, tileTheme.flower2, tileTheme.flower3}
                        local leafColor = leafColors[((x + y) % 3) + 1]
                        love.graphics.setColor(leafColor[1], leafColor[2], leafColor[3], 0.7)
                        love.graphics.circle("fill", px + self.tileSize * 0.4, py + self.tileSize * 0.5, 2.5)
                        love.graphics.circle("fill", px + self.tileSize * 0.6, py + self.tileSize * 0.3, 2.5)
                    end
                elseif tileSeason == "winter" then
                    -- Winter snow patches
                    if (x * 3 + y * 13) % 10 == 0 then
                        love.graphics.setColor(1, 1, 1, 0.3)
                        love.graphics.circle("fill", px + self.tileSize * 0.3, py + self.tileSize * 0.3, 4)
                        love.graphics.circle("fill", px + self.tileSize * 0.7, py + self.tileSize * 0.6, 3)
                    end
                end
            end
        end
    end

    -- Draw buildings (MUST be after tiles to appear on top)
    for _, building in ipairs(self.buildings) do
        -- Check if building is in viewport
        if camera then
            if building.x + building.width < camX or building.x > camX + viewWidth or
               building.y + building.height < camY or building.y > camY + viewHeight then
                goto continue
            end
        end

        -- Building body (solid, no transparency)
        love.graphics.setColor(building.color[1], building.color[2], building.color[3])
        love.graphics.rectangle("fill", building.x, building.y, building.width, building.height)

        -- Building border
        love.graphics.setColor(0.4, 0.25, 0.15)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", building.x, building.y, building.width, building.height, 5, 5)
        love.graphics.setLineWidth(1)

        ::continue::
    end

    -- Draw map border with seasonal color
    local borderColor = season == "winter" and {0.6, 0.65, 0.7} or
                       season == "autumn" and {0.6, 0.4, 0.2} or
                       season == "summer" and {0.4, 0.5, 0.3} or
                       {0.5, 0.6, 0.4}  -- spring

    love.graphics.setColor(borderColor)
    love.graphics.setLineWidth(8)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1)
end

return MapData

