-- map_data.lua - Map data structure with layered rendering
-- 地图数据结构，支持多层渲染和视口裁剪

local MapThemes = require("map.map_themes")
local MapObjectRenderer = require("map.map_object_renderer")

local MapData = {}

MapData.LAYER_GROUND = 1
MapData.LAYER_OBJECTS = 2
MapData.LAYER_OVERLAY = 3

function MapData.create(config)
    local state = {}

    state.id = config.id or "unknown"
    state.name = config.name or "Unnamed Map"
    state.width = config.width or 2000
    state.height = config.height or 2000
    state.season = config.season or "spring"
    state.seasonZones = config.seasonZones or {}
    state.tileSize = config.tileSize or 32
    state.tiles = config.tiles or {}
    state.collisionMap = config.collisionMap or {}
    state.spawnPoints = config.spawnPoints or {{x = 1000, y = 1000}}
    state.encounterZones = config.encounterZones or {}
    state.npcs = config.npcs or {}
    state.buildings = config.buildings or {}
    state.backgroundColor = config.backgroundColor or {0.2, 0.6, 0.3}

    state.layers = config.layers or {
        ground = {},
        objects = {},
        overlay = {}
    }

    state.objects = config.objects or {}
    state.overlays = config.overlays or {}

    state.themeCache = {}
    state.cachedSeason = nil
    state.debugMode = false

    return state
end

function MapData.getSpawnPoint(state, index)
    index = index or 1
    return state.spawnPoints[index] or state.spawnPoints[1]
end

function MapData.isCollision(state, x, y)
    local tileX = math.floor(x / state.tileSize)
    local tileY = math.floor(y / state.tileSize)

    if state.collisionMap[tileY] then
        return state.collisionMap[tileY][tileX] == 1
    end

    return false
end

function MapData.getSeasonTheme(state, season)
    if state.cachedSeason == season and state.themeCache[season] then
        return state.themeCache[season]
    end

    state.themeCache[season] = MapThemes.getSeasonTheme(season)
    state.cachedSeason = season

    return state.themeCache[season]
end

function MapData.getVisibleTileRange(state, camera)
    if not camera then
        local tilesX = math.floor(state.width / state.tileSize)
        local tilesY = math.floor(state.height / state.tileSize)
        return 0, 0, tilesX - 1, tilesY - 1
    end

    local camX, camY, camX2, camY2 = camera:getVisibleBounds()

    local startX = math.max(0, math.floor(camX / state.tileSize) - 1)
    local startY = math.max(0, math.floor(camY / state.tileSize) - 1)
    local endX = math.min(math.floor(state.width / state.tileSize) - 1, math.ceil(camX2 / state.tileSize) + 1)
    local endY = math.min(math.floor(state.height / state.tileSize) - 1, math.ceil(camY2 / state.tileSize) + 1)

    return startX, startY, endX, endY
end

function MapData.draw(state, camera)
    local season = state.season or "spring"
    local theme = MapData.getSeasonTheme(state, season)

    love.graphics.setColor(state.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, state.width, state.height)

    MapData.drawGroundLayer(state, camera, theme)
end

function MapData.drawGroundLayer(state, camera, theme)
    local startX, startY, endX, endY = MapData.getVisibleTileRange(state, camera)
    local season = state.season or "spring"

    if not theme then
        theme = MapData.getSeasonTheme(state, season)
    end

    for y = startY, endY do
        for x = startX, endX do
            local px = x * state.tileSize
            local py = y * state.tileSize

            local tileSeason = season
            if #state.seasonZones > 0 then
                for _, zone in ipairs(state.seasonZones) do
                    if px >= zone.x and px < zone.x + zone.width and
                       py >= zone.y and py < zone.y + zone.height then
                        tileSeason = zone.season
                        break
                    end
                end
            end

            local tileTheme = MapData.getSeasonTheme(state, tileSeason)

            MapData.drawTile(state, x, y, px, py, tileTheme, tileSeason)
        end
    end

    MapData.drawBuildings(state)
end

function MapData.drawTile(state, x, y, px, py, theme, season)
    local isRoad = (x % 5 == 0 or y % 5 == 0)

    if isRoad then
        MapData.drawRoadTile(state, x, y, px, py, theme)
    else
        MapData.drawGrassTile(state, x, y, px, py, theme, season)
    end
end

function MapData.drawRoadTile(state, x, y, px, py, theme)
    local colorIndex = (x + y) % 2
    if colorIndex == 0 then
        love.graphics.setColor(theme.road1)
    else
        love.graphics.setColor(theme.road2)
    end
    love.graphics.rectangle("fill", px, py, state.tileSize, state.tileSize)

    love.graphics.setColor(theme.roadLine)
    if x % 5 == 0 then
        for dy = 0, state.tileSize, 20 do
            if math.floor((py + dy) / 20) % 2 == 0 then
                love.graphics.rectangle("fill", px + state.tileSize * 0.47, py + dy, state.tileSize * 0.06, 10)
            end
        end
    else
        for dx = 0, state.tileSize, 20 do
            if math.floor((px + dx) / 20) % 2 == 0 then
                love.graphics.rectangle("fill", px + dx, py + state.tileSize * 0.47, 10, state.tileSize * 0.06)
            end
        end
    end
end

function MapData.drawGrassTile(state, x, y, px, py, theme, season)
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
    love.graphics.rectangle("fill", px, py, state.tileSize, state.tileSize)

    MapData.drawSeasonalDecoration(state, x, y, px, py, theme, season)
end

function MapData.drawSeasonalDecoration(state, x, y, px, py, theme, season)
    if season == "spring" then
        if (x * 7 + y * 11) % 15 == 0 then
            local flowerColors = {theme.flower1, theme.flower2, theme.flower3}
            local flowerColor = flowerColors[((x + y) % 3) + 1]
            love.graphics.setColor(flowerColor[1], flowerColor[2], flowerColor[3], 0.8)
            love.graphics.circle("fill", px + state.tileSize * 0.3, py + state.tileSize * 0.4, 3)
            love.graphics.circle("fill", px + state.tileSize * 0.7, py + state.tileSize * 0.6, 3)
        end
    elseif season == "summer" then
        if (x + y * 7) % 4 == 0 then
            love.graphics.setColor(theme.grass4[1], theme.grass4[2], theme.grass4[3], 0.4)
            love.graphics.circle("fill", px + state.tileSize * 0.3, py + state.tileSize * 0.3, 2)
            love.graphics.circle("fill", px + state.tileSize * 0.7, py + state.tileSize * 0.7, 2)
        end
    elseif season == "autumn" then
        if (x * 5 + y * 9) % 12 == 0 then
            local leafColors = {theme.flower1, theme.flower2, theme.flower3}
            local leafColor = leafColors[((x + y) % 3) + 1]
            love.graphics.setColor(leafColor[1], leafColor[2], leafColor[3], 0.7)
            love.graphics.circle("fill", px + state.tileSize * 0.4, py + state.tileSize * 0.5, 2.5)
            love.graphics.circle("fill", px + state.tileSize * 0.6, py + state.tileSize * 0.3, 2.5)
        end
    elseif season == "winter" then
        if (x * 3 + y * 13) % 10 == 0 then
            love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.circle("fill", px + state.tileSize * 0.3, py + state.tileSize * 0.3, 4)
            love.graphics.circle("fill", px + state.tileSize * 0.7, py + state.tileSize * 0.6, 3)
        end
    end
end

function MapData.drawObjectsLayer(state, camera)
    local startX, startY, endX, endY = MapData.getVisibleTileRange(state, camera)

    for _, obj in ipairs(state.objects) do
        local tileX = math.floor(obj.x / state.tileSize)
        local tileY = math.floor(obj.y / state.tileSize)

        if tileX >= startX and tileX <= endX and tileY >= startY and tileY <= endY then
            MapData.drawObject(state, obj)
        end
    end

    for _, building in ipairs(state.buildings) do
        local visible = true
        if camera and camera.isVisible then
            visible = camera:isVisible(building.x, building.y, building.width, building.height)
        end
        if visible then
            MapData.drawBuilding(state, building)
        end
    end
end

function MapData.drawObject(state, obj)
    local objType = obj.type or "tree"
    local theme = MapData.getSeasonTheme(state, state.season)

    if objType == "tree" then
        MapObjectRenderer.drawTree(obj.x, obj.y, obj.size or 1, obj.theme or theme)
    elseif objType == "rock" then
        MapObjectRenderer.drawRock(obj.x, obj.y, obj.size or 1, obj.theme or theme)
    elseif objType == "water" then
        MapObjectRenderer.drawWater(obj.x, obj.y, obj.width or state.tileSize, obj.height or state.tileSize, obj.theme or theme)
    end
end

function MapData.drawBuildings(state)
    for _, building in ipairs(state.buildings) do
        MapData.drawBuilding(state, building)
    end
end

function MapData.drawBuilding(state, building)
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

function MapData.drawOverlayLayer(state, camera)
    for _, overlay in ipairs(state.overlays) do
        local isVisible = true
        if camera and camera.isVisible then
            isVisible = camera:isVisible(overlay.x, overlay.y, overlay.width or state.tileSize, overlay.height or state.tileSize)
        end

        if isVisible then
            MapData.drawOverlay(state, overlay)
        end
    end
end

function MapData.drawOverlay(state, overlay)
    love.graphics.setColor(overlay.color or {0.5, 0.5, 0.5, 0.8})
    if overlay.shape == "tree_top" then
        love.graphics.circle("fill", overlay.x + (overlay.width or state.tileSize) / 2,
                            overlay.y + (overlay.height or state.tileSize) / 2,
                            (overlay.width or state.tileSize) / 2)
    else
        love.graphics.rectangle("fill", overlay.x, overlay.y,
                               overlay.width or state.tileSize, overlay.height or state.tileSize)
    end
end

function MapData.addObject(state, obj)
    table.insert(state.objects, obj)
end

function MapData.addOverlay(state, overlay)
    table.insert(state.overlays, overlay)
end

function MapData.getObjectsInArea(state, x, y, width, height)
    local result = {}
    for _, obj in ipairs(state.objects) do
        if obj.x >= x and obj.x <= x + width and
           obj.y >= y and obj.y <= y + height then
            table.insert(result, obj)
        end
    end
    return result
end

function MapData.getObjectAt(state, x, y)
    for _, obj in ipairs(state.objects) do
        local objWidth = obj.width or state.tileSize
        local objHeight = obj.height or state.tileSize
        if x >= obj.x and x <= obj.x + objWidth and
           y >= obj.y and y <= obj.y + objHeight then
            return obj
        end
    end
    return nil
end

function MapData.drawBorder(state)
    local season = state.season or "spring"
    local borderColor = season == "winter" and {0.6, 0.65, 0.7} or
                       season == "autumn" and {0.6, 0.4, 0.2} or
                       season == "summer" and {0.4, 0.5, 0.3} or
                       {0.5, 0.6, 0.4}

    love.graphics.setColor(borderColor)
    love.graphics.setLineWidth(8)
    love.graphics.rectangle("line", 0, 0, state.width, state.height)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1)
end

function MapData.drawFull(state, camera)
    MapData.draw(state, camera)
    MapData.drawObjectsLayer(state, camera)
    MapData.drawBorder(state)
end

return MapData
