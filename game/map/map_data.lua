-- map_data.lua - Map data structure with layered rendering
-- 地图数据结构，支持多层渲染和视口裁剪

local MapData = {}
MapData.__index = MapData

MapData.LAYER_GROUND = 1
MapData.LAYER_OBJECTS = 2
MapData.LAYER_OVERLAY = 3

function MapData.new(config)
    local self = setmetatable({}, MapData)
    
    self.id = config.id or "unknown"
    self.name = config.name or "Unnamed Map"
    self.width = config.width or 2000
    self.height = config.height or 2000
    self.season = config.season or "spring"
    self.seasonZones = config.seasonZones or {}
    self.tileSize = config.tileSize or 32
    self.tiles = config.tiles or {}
    self.collisionMap = config.collisionMap or {}
    self.spawnPoints = config.spawnPoints or {{x = 1000, y = 1000}}
    self.encounterZones = config.encounterZones or {}
    self.npcs = config.npcs or {}
    self.buildings = config.buildings or {}
    self.backgroundColor = config.backgroundColor or {0.2, 0.6, 0.3}
    
    self.layers = config.layers or {
        ground = {},
        objects = {},
        overlay = {}
    }
    
    self.objects = config.objects or {}
    self.overlays = config.overlays or {}
    
    self.themeCache = {}
    self.cachedSeason = nil
    self.debugMode = false
    
    return self
end

function MapData:getSpawnPoint(index)
    index = index or 1
    return self.spawnPoints[index] or self.spawnPoints[1]
end

function MapData:isCollision(x, y)
    local tileX = math.floor(x / self.tileSize)
    local tileY = math.floor(y / self.tileSize)

    if self.collisionMap[tileY] then
        return self.collisionMap[tileY][tileX] == 1
    end

    return false
end

function MapData:getSeasonTheme(season)
    if self.cachedSeason == season and self.themeCache[season] then
        return self.themeCache[season]
    end
    
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
            tree = {0.2, 0.5, 0.2},
            treeTrunk = {0.4, 0.25, 0.15},
            water = {0.3, 0.5, 0.8},
            rock = {0.5, 0.5, 0.5}
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
            tree = {0.15, 0.45, 0.15},
            treeTrunk = {0.35, 0.22, 0.12},
            water = {0.2, 0.4, 0.7},
            rock = {0.45, 0.45, 0.45}
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
            tree = {0.6, 0.3, 0.1},
            treeTrunk = {0.4, 0.25, 0.15},
            water = {0.4, 0.5, 0.6},
            rock = {0.55, 0.5, 0.45}
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
            tree = {0.3, 0.35, 0.4},
            treeTrunk = {0.35, 0.25, 0.2},
            water = {0.5, 0.6, 0.7},
            rock = {0.6, 0.65, 0.7}
        },
        desert = {
            grass1 = {0.85, 0.75, 0.50},
            grass2 = {0.80, 0.70, 0.45},
            grass3 = {0.90, 0.80, 0.55},
            grass4 = {0.75, 0.65, 0.40},
            road1 = {0.65, 0.55, 0.40},
            road2 = {0.60, 0.50, 0.35},
            roadLine = {0.85, 0.75, 0.55},
            flower1 = {0.3, 0.6, 0.3},
            flower2 = {0.6, 0.8, 0.2},
            flower3 = {0.2, 0.5, 0.7},
            tree = {0.4, 0.6, 0.3},
            treeTrunk = {0.55, 0.40, 0.25},
            water = {0.3, 0.5, 0.7},
            rock = {0.7, 0.6, 0.45}
        },
        volcanic = {
            grass1 = {0.25, 0.15, 0.12},
            grass2 = {0.30, 0.18, 0.10},
            grass3 = {0.20, 0.12, 0.08},
            grass4 = {0.35, 0.20, 0.15},
            road1 = {0.45, 0.40, 0.35},
            road2 = {0.50, 0.45, 0.38},
            roadLine = {0.70, 0.65, 0.55},
            flower1 = {0.9, 0.3, 0.1},
            flower2 = {1.0, 0.5, 0.0},
            flower3 = {0.8, 0.2, 0.0},
            tree = {0.15, 0.1, 0.08},
            treeTrunk = {0.2, 0.15, 0.1},
            water = {0.9, 0.4, 0.1},
            rock = {0.3, 0.25, 0.2}
        },
        underwater = {
            grass1 = {0.15, 0.35, 0.55},
            grass2 = {0.12, 0.30, 0.50},
            grass3 = {0.18, 0.40, 0.60},
            grass4 = {0.10, 0.28, 0.48},
            road1 = {0.40, 0.45, 0.50},
            road2 = {0.35, 0.40, 0.45},
            roadLine = {0.60, 0.65, 0.70},
            flower1 = {0.9, 0.5, 0.6},
            flower2 = {0.5, 0.8, 0.7},
            flower3 = {0.7, 0.6, 0.9},
            tree = {0.2, 0.5, 0.4},
            treeTrunk = {0.3, 0.25, 0.2},
            water = {0.1, 0.3, 0.5},
            rock = {0.4, 0.45, 0.5}
        },
        sky = {
            grass1 = {0.90, 0.92, 0.98},
            grass2 = {0.85, 0.88, 0.95},
            grass3 = {0.92, 0.94, 0.99},
            grass4 = {0.82, 0.85, 0.92},
            road1 = {0.75, 0.78, 0.85},
            road2 = {0.70, 0.73, 0.80},
            roadLine = {0.90, 0.92, 0.97},
            flower1 = {1.0, 0.9, 0.5},
            flower2 = {0.9, 0.7, 1.0},
            flower3 = {0.7, 0.9, 1.0},
            tree = {0.6, 0.7, 0.8},
            treeTrunk = {0.8, 0.8, 0.85},
            water = {0.6, 0.7, 0.9},
            rock = {0.65, 0.68, 0.75}
        }
    }
    
    self.themeCache[season] = themes[season] or themes.spring
    self.cachedSeason = season
    
    return self.themeCache[season]
end

function MapData:getVisibleTileRange(camera)
    if not camera then
        local tilesX = math.floor(self.width / self.tileSize)
        local tilesY = math.floor(self.height / self.tileSize)
        return 0, 0, tilesX - 1, tilesY - 1
    end
    
    local camX, camY, camX2, camY2 = camera:getVisibleBounds()
    
    local startX = math.max(0, math.floor(camX / self.tileSize) - 1)
    local startY = math.max(0, math.floor(camY / self.tileSize) - 1)
    local endX = math.min(math.floor(self.width / self.tileSize) - 1, math.ceil(camX2 / self.tileSize) + 1)
    local endY = math.min(math.floor(self.height / self.tileSize) - 1, math.ceil(camY2 / self.tileSize) + 1)
    
    return startX, startY, endX, endY
end

function MapData:draw(camera)
    local season = self.season or "spring"
    local theme = self:getSeasonTheme(season)

    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    self:drawGroundLayer(camera, theme)
end

function MapData:drawGroundLayer(camera, theme)
    local startX, startY, endX, endY = self:getVisibleTileRange(camera)
    local season = self.season or "spring"
    
    if not theme then
        theme = self:getSeasonTheme(season)
    end
    
    for y = startY, endY do
        for x = startX, endX do
            local px = x * self.tileSize
            local py = y * self.tileSize
            
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

            local tileTheme = self:getSeasonTheme(tileSeason)
            
            self:drawTile(x, y, px, py, tileTheme, tileSeason)
        end
    end
    
    self:drawBuildings()
end

function MapData:drawTile(x, y, px, py, theme, season)
    local isRoad = (x % 5 == 0 or y % 5 == 0)

    if isRoad then
        self:drawRoadTile(x, y, px, py, theme)
    else
        self:drawGrassTile(x, y, px, py, theme, season)
    end
end

function MapData:drawRoadTile(x, y, px, py, theme)
    local colorIndex = (x + y) % 2
    if colorIndex == 0 then
        love.graphics.setColor(theme.road1)
    else
        love.graphics.setColor(theme.road2)
    end
    love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)

    love.graphics.setColor(theme.roadLine)
    if x % 5 == 0 then
        for dy = 0, self.tileSize, 20 do
            if math.floor((py + dy) / 20) % 2 == 0 then
                love.graphics.rectangle("fill", px + self.tileSize * 0.47, py + dy, self.tileSize * 0.06, 10)
            end
        end
    else
        for dx = 0, self.tileSize, 20 do
            if math.floor((px + dx) / 20) % 2 == 0 then
                love.graphics.rectangle("fill", px + dx, py + self.tileSize * 0.47, 10, self.tileSize * 0.06)
            end
        end
    end
end

function MapData:drawGrassTile(x, y, px, py, theme, season)
    local noise = (math.sin(x * 0.5) + math.cos(y * 0.7)) * 0.5
    local colorIndex = (x + y) % 2

    if noise > 0.3 then
        love.graphics.setColor(theme.grass3)
    elseif noise < -0.3 then
        love.graphics.setColor(theme.grass4)
    elseif colorIndex == 0 then
        love.graphics.setColor(theme.grass1)
    else
        love.graphics.setColor(theme.grass2)
    end
    love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)
    
    self:drawSeasonalDecoration(x, y, px, py, theme, season)
end

function MapData:drawSeasonalDecoration(x, y, px, py, theme, season)
    if season == "spring" then
        if (x * 7 + y * 11) % 15 == 0 then
            local flowerColors = {theme.flower1, theme.flower2, theme.flower3}
            local flowerColor = flowerColors[((x + y) % 3) + 1]
            love.graphics.setColor(flowerColor[1], flowerColor[2], flowerColor[3], 0.8)
            love.graphics.circle("fill", px + self.tileSize * 0.3, py + self.tileSize * 0.4, 3)
            love.graphics.circle("fill", px + self.tileSize * 0.7, py + self.tileSize * 0.6, 3)
        end
    elseif season == "summer" then
        if (x + y * 7) % 4 == 0 then
            love.graphics.setColor(theme.grass4[1], theme.grass4[2], theme.grass4[3], 0.4)
            love.graphics.circle("fill", px + self.tileSize * 0.3, py + self.tileSize * 0.3, 2)
            love.graphics.circle("fill", px + self.tileSize * 0.7, py + self.tileSize * 0.7, 2)
        end
    elseif season == "autumn" then
        if (x * 5 + y * 9) % 12 == 0 then
            local leafColors = {theme.flower1, theme.flower2, theme.flower3}
            local leafColor = leafColors[((x + y) % 3) + 1]
            love.graphics.setColor(leafColor[1], leafColor[2], leafColor[3], 0.7)
            love.graphics.circle("fill", px + self.tileSize * 0.4, py + self.tileSize * 0.5, 2.5)
            love.graphics.circle("fill", px + self.tileSize * 0.6, py + self.tileSize * 0.3, 2.5)
        end
    elseif season == "winter" then
        if (x * 3 + y * 13) % 10 == 0 then
            love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.circle("fill", px + self.tileSize * 0.3, py + self.tileSize * 0.3, 4)
            love.graphics.circle("fill", px + self.tileSize * 0.7, py + self.tileSize * 0.6, 3)
        end
    end
end

function MapData:drawObjectsLayer(camera)
    local startX, startY, endX, endY = self:getVisibleTileRange(camera)
    
    for _, obj in ipairs(self.objects) do
        local tileX = math.floor(obj.x / self.tileSize)
        local tileY = math.floor(obj.y / self.tileSize)
        
        if tileX >= startX and tileX <= endX and tileY >= startY and tileY <= endY then
            self:drawObject(obj)
        end
    end
    
    for _, building in ipairs(self.buildings) do
        local visible = true
        if camera and camera.isVisible then
            visible = camera:isVisible(building.x, building.y, building.width, building.height)
        end
        if visible then
            self:drawBuilding(building)
        end
    end
end

function MapData:drawObject(obj)
    local objType = obj.type or "tree"
    
    if objType == "tree" then
        self:drawTree(obj.x, obj.y, obj.size or 1, obj.theme)
    elseif objType == "rock" then
        self:drawRock(obj.x, obj.y, obj.size or 1, obj.theme)
    elseif objType == "water" then
        self:drawWater(obj.x, obj.y, obj.width or self.tileSize, obj.height or self.tileSize, obj.theme)
    end
end

function MapData:drawTree(x, y, size, theme)
    size = size or 1
    theme = theme or self:getSeasonTheme(self.season)
    
    local trunkWidth = 8 * size
    local trunkHeight = 20 * size
    local canopyRadius = 18 * size
    
    love.graphics.setColor(0, 0, 0, 0.15)
    love.graphics.ellipse("fill", x, y + trunkHeight - 2, canopyRadius * 0.9, canopyRadius * 0.3)
    
    love.graphics.setColor(theme.treeTrunk)
    love.graphics.rectangle("fill", x - trunkWidth/2, y, trunkWidth, trunkHeight)
    
    love.graphics.setColor(theme.tree[1] * 1.1, theme.tree[2] * 1.1, theme.tree[3] * 1.1)
    love.graphics.circle("fill", x + canopyRadius * 0.25, y - canopyRadius * 0.5, canopyRadius * 0.7)
    
    love.graphics.setColor(theme.tree)
    love.graphics.circle("fill", x, y - canopyRadius * 0.3, canopyRadius)
    
    love.graphics.setColor(theme.tree[1] * 0.85, theme.tree[2] * 0.85, theme.tree[3] * 0.85)
    love.graphics.circle("fill", x - canopyRadius * 0.35, y - canopyRadius * 0.45, canopyRadius * 0.55)
    
    love.graphics.setColor(theme.tree[1] * 0.7, theme.tree[2] * 0.7, theme.tree[3] * 0.7)
    love.graphics.circle("fill", x + canopyRadius * 0.2, y + canopyRadius * 0.2, canopyRadius * 0.4)
end

function MapData:drawRock(x, y, size, theme)
    size = size or 1
    theme = theme or self:getSeasonTheme(self.season)
    
    love.graphics.setColor(theme.rock)
    love.graphics.polygon("fill",
        x - 12 * size, y + 8 * size,
        x - 8 * size, y - 6 * size,
        x + 4 * size, y - 8 * size,
        x + 12 * size, y + 4 * size,
        x + 6 * size, y + 10 * size
    )
    
    love.graphics.setColor(theme.rock[1] * 1.2, theme.rock[2] * 1.2, theme.rock[3] * 1.2)
    love.graphics.polygon("fill",
        x - 4 * size, y - 2 * size,
        x + 2 * size, y - 4 * size,
        x + 6 * size, y + 2 * size,
        x - 2 * size, y + 4 * size
    )
end

function MapData:drawWater(x, y, width, height, theme)
    theme = theme or self:getSeasonTheme(self.season)
    local time = love.timer.getTime and love.timer.getTime() or 0
    
    love.graphics.setColor(theme.water)
    love.graphics.rectangle("fill", x, y, width, height)
    
    love.graphics.setColor(theme.water[1] * 0.85, theme.water[2] * 0.85, theme.water[3] * 0.9)
    for i = 0, width, 20 do
        for j = 0, height, 20 do
            local waveX = math.sin(time * 1.5 + i * 0.08 + j * 0.05) * 3
            local waveY = math.cos(time * 1.2 + j * 0.06) * 2
            love.graphics.circle("fill", x + i + 10 + waveX, y + j + 10 + waveY, 6)
        end
    end
    
    love.graphics.setColor(1, 1, 1, 0.15)
    for i = 1, math.floor(width / 30) do
        for j = 1, math.floor(height / 25) do
            local sparkleX = x + (i * 30 + math.sin(time * 3 + i) * 10) % width
            local sparkleY = y + (j * 25 + math.cos(time * 2.5 + j) * 8) % height
            local sparkleAlpha = 0.1 + 0.15 * math.sin(time * 5 + i * 2 + j * 3)
            love.graphics.setColor(1, 1, 1, sparkleAlpha)
            love.graphics.circle("fill", sparkleX, sparkleY, 2)
        end
    end
    
    love.graphics.setColor(theme.water[1] + 0.1, theme.water[2] + 0.1, theme.water[3] + 0.15, 0.4)
    for i = 0, width - 8, 12 do
        local waveOffset = math.sin(time * 2 + i * 0.15) * 3
        love.graphics.line(x + i, y + height * 0.3 + waveOffset, x + i + 8, y + height * 0.3 + waveOffset)
        love.graphics.line(x + i + 4, y + height * 0.6 + waveOffset, x + i + 12, y + height * 0.6 + waveOffset)
    end
    
    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.rectangle("fill", x + 2, y + 2, width * 0.3, 3)
end

function MapData:drawBuildings()
    for _, building in ipairs(self.buildings) do
        self:drawBuilding(building)
    end
end

function MapData:drawBuilding(building)
    love.graphics.setColor(0, 0, 0, 0.12)
    love.graphics.polygon("fill",
        building.x + 8, building.y + building.height,
        building.x + building.width + 8, building.y + building.height,
        building.x + building.width + 12, building.y + building.height + 6,
        building.x + 12, building.y + building.height + 6
    )
    
    love.graphics.setColor(building.color[1], building.color[2], building.color[3])
    love.graphics.rectangle("fill", building.x, building.y, building.width, building.height)
    
    love.graphics.setColor(building.color[1] * 1.15, building.color[2] * 1.15, building.color[3] * 1.15)
    love.graphics.rectangle("fill", building.x, building.y, building.width, 4)
    love.graphics.rectangle("fill", building.x, building.y, 4, building.height * 0.3)
    
    love.graphics.setColor(building.color[1] * 0.6, building.color[2] * 0.6, building.color[3] * 0.6)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", building.x, building.y, building.width, building.height)
    love.graphics.setLineWidth(1)
    
    local roofColor = {
        math.min(1, building.color[1] * 0.55),
        math.min(1, building.color[2] * 0.35),
        math.min(1, building.color[3] * 0.35)
    }
    love.graphics.setColor(roofColor)
    love.graphics.polygon("fill",
        building.x - 3, building.y,
        building.x + building.width / 2, building.y - 18,
        building.x + building.width + 3, building.y
    )
    
    love.graphics.setColor(roofColor[1] * 1.2, roofColor[2] * 1.2, roofColor[3] * 1.2)
    love.graphics.polygon("fill",
        building.x - 3, building.y,
        building.x + building.width / 2, building.y - 18,
        building.x + building.width * 0.3, building.y
    )
    
    love.graphics.setColor(0.3, 0.25, 0.2)
    local windowSize = 12
    local windowSpacing = 25
    for wx = building.x + 15, building.x + building.width - 20, windowSpacing do
        for wy = building.y + 15, building.y + building.height - 20, windowSpacing do
            love.graphics.rectangle("fill", wx, wy, windowSize, windowSize)
            love.graphics.setColor(0.4, 0.35, 0.3)
            love.graphics.line(wx, wy + windowSize / 2, wx + windowSize, wy + windowSize / 2)
            love.graphics.line(wx + windowSize / 2, wy, wx + windowSize / 2, wy + windowSize)
            love.graphics.setColor(0.3, 0.25, 0.2)
        end
    end
end

function MapData:drawOverlayLayer(camera)
    for _, overlay in ipairs(self.overlays) do
        local isVisible = true
        if camera and camera.isVisible then
            isVisible = camera:isVisible(overlay.x, overlay.y, overlay.width or self.tileSize, overlay.height or self.tileSize)
        end
        
        if isVisible then
            self:drawOverlay(overlay)
        end
    end
end

function MapData:drawOverlay(overlay)
    love.graphics.setColor(overlay.color or {0.5, 0.5, 0.5, 0.8})
    if overlay.shape == "tree_top" then
        love.graphics.circle("fill", overlay.x + (overlay.width or self.tileSize) / 2, 
                            overlay.y + (overlay.height or self.tileSize) / 2, 
                            (overlay.width or self.tileSize) / 2)
    else
        love.graphics.rectangle("fill", overlay.x, overlay.y, 
                               overlay.width or self.tileSize, overlay.height or self.tileSize)
    end
end

function MapData:addObject(obj)
    table.insert(self.objects, obj)
end

function MapData:addOverlay(overlay)
    table.insert(self.overlays, overlay)
end

function MapData:getObjectsInArea(x, y, width, height)
    local result = {}
    for _, obj in ipairs(self.objects) do
        if obj.x >= x and obj.x <= x + width and
           obj.y >= y and obj.y <= y + height then
            table.insert(result, obj)
        end
    end
    return result
end

function MapData:getObjectAt(x, y)
    for _, obj in ipairs(self.objects) do
        local objWidth = obj.width or self.tileSize
        local objHeight = obj.height or self.tileSize
        if x >= obj.x and x <= obj.x + objWidth and
           y >= obj.y and y <= obj.y + objHeight then
            return obj
        end
    end
    return nil
end

function MapData:drawBorder()
    local season = self.season or "spring"
    local borderColor = season == "winter" and {0.6, 0.65, 0.7} or
                       season == "autumn" and {0.6, 0.4, 0.2} or
                       season == "summer" and {0.4, 0.5, 0.3} or
                       {0.5, 0.6, 0.4}

    love.graphics.setColor(borderColor)
    love.graphics.setLineWidth(8)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1)
end

function MapData:drawFull(camera)
    self:draw(camera)
    self:drawObjectsLayer(camera)
    self:drawBorder()
end

return MapData
