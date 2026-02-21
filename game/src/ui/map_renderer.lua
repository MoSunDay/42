-- map_renderer.lua - Unified map rendering for minimap, fullscreen map, etc.
-- 统一的地图渲染器，支持多层渲染和美化效果

local MapRenderer = {}

MapRenderer.animationTime = 0

function MapRenderer.update(dt)
    MapRenderer.animationTime = MapRenderer.animationTime + dt
end

function MapRenderer.render(map, renderX, renderY, renderWidth, renderHeight, playerX, playerY, options)
    options = options or {}
    local showPlayer = options.showPlayer ~= false
    local showBuildings = options.showBuildings ~= false
    local showEncounters = options.showEncounters or false
    local showNPCs = options.showNPCs or false
    local showObjects = options.showObjects or false
    local showTeleports = options.showTeleports or false
    local playerColor = options.playerColor or {1, 0.2, 0.2}
    local playerRadius = options.playerRadius or 5
    
    local scaleX = renderWidth / map.width
    local scaleY = renderHeight / map.height
    
    local function worldToRender(wx, wy)
        return renderX + wx * scaleX, renderY + wy * scaleY
    end
    
    MapRenderer.renderTiles(map, renderX, renderY, renderWidth, renderHeight, scaleX, scaleY)
    
    if showObjects and map.objects then
        MapRenderer.renderObjects(map, renderX, renderY, scaleX, scaleY)
    end
    
    if showBuildings and map.buildings then
        for _, building in ipairs(map.buildings) do
            local bx, by = worldToRender(building.x, building.y)
            local bw = building.width * scaleX
            local bh = building.height * scaleY

            love.graphics.setColor(building.color or {0.7, 0.5, 0.3})
            love.graphics.rectangle("fill", bx, by, bw, bh)
            
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.rectangle("line", bx, by, bw, bh)
        end
    end
    
    if showTeleports and map.teleports then
        for _, teleport in ipairs(map.teleports) do
            local tx, ty = worldToRender(teleport.x, teleport.y)
            local tw = teleport.width * scaleX
            local th = teleport.height * scaleY
            
            love.graphics.setColor(0.3, 0.8, 1.0, 0.5)
            love.graphics.rectangle("fill", tx, ty, tw, th)
            love.graphics.setColor(0.3, 0.8, 1.0, 0.8)
            love.graphics.rectangle("line", tx, ty, tw, th)
        end
    end
    
    if showEncounters and map.encounterZones then
        for _, zone in ipairs(map.encounterZones) do
            local zx, zy = worldToRender(zone.x, zone.y)
            local zr = zone.radius * scaleX
            
            love.graphics.setColor(0.8, 0.2, 0.2, 0.3)
            love.graphics.circle("fill", zx, zy, zr)
            love.graphics.setColor(0.8, 0.2, 0.2, 0.6)
            love.graphics.circle("line", zx, zy, zr)
        end
    end
    
    if showNPCs and map.npcs then
        for _, npc in ipairs(map.npcs) do
            local nx, ny = worldToRender(npc.x, npc.y)
            
            love.graphics.setColor(0.3, 0.7, 0.9)
            love.graphics.circle("fill", nx, ny, 3)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", nx, ny, 3)
        end
    end
    
    if showPlayer then
        MapRenderer.drawPlayerMarker(playerX, playerY, renderX, renderY, scaleX, scaleY, playerColor, playerRadius)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function MapRenderer.drawPlayerMarker(playerX, playerY, renderX, renderY, scaleX, scaleY, playerColor, playerRadius)
    local px = renderX + playerX * scaleX
    local py = renderY + playerY * scaleY
    
    local pulse = 0.8 + 0.2 * math.sin(MapRenderer.animationTime * 4)
    local outerPulse = 0.6 + 0.4 * math.sin(MapRenderer.animationTime * 3)
    
    love.graphics.setColor(1, 1, 0.3, 0.1 * outerPulse)
    love.graphics.circle("fill", px, py, playerRadius * 6)
    
    love.graphics.setColor(1, 1, 0.4, 0.15 * pulse)
    love.graphics.circle("fill", px, py, playerRadius * 4.5)
    
    love.graphics.setColor(1, 1, 0.5, 0.25)
    love.graphics.circle("fill", px, py, playerRadius * 3)
    
    love.graphics.setColor(1, 1, 0.6, 0.4)
    love.graphics.circle("line", px, py, playerRadius * 3.5)
    
    love.graphics.setColor(playerColor[1], playerColor[2], playerColor[3], 0.8)
    love.graphics.circle("fill", px, py, playerRadius * 1.5)
    
    love.graphics.setColor(playerColor)
    love.graphics.circle("fill", px, py, playerRadius)
    
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("line", px, py, playerRadius)
    
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.circle("fill", px - playerRadius * 0.3, py - playerRadius * 0.3, playerRadius * 0.3)
end

function MapRenderer.renderTiles(map, renderX, renderY, renderWidth, renderHeight, scaleX, scaleY)
    local season = map.season or "spring"
    local theme = map.getSeasonTheme and map:getSeasonTheme(season) or MapRenderer.getDefaultTheme(season)

    local tileSizeX = map.tileSize * scaleX
    local tileSizeY = map.tileSize * scaleY

    local tilesX = math.floor(map.width / map.tileSize)
    local tilesY = math.floor(map.height / map.tileSize)

    local skipStep = 1
    if tileSizeX < 2 then
        skipStep = math.floor(2 / tileSizeX) + 1
    end

    for y = 0, tilesY - 1, skipStep do
        for x = 0, tilesX - 1, skipStep do
            local px0 = renderX + math.floor(x * tileSizeX + 0.5)
            local py0 = renderY + math.floor(y * tileSizeY + 0.5)
            local px1 = renderX + math.floor((x + skipStep) * tileSizeX + 0.5)
            local py1 = renderY + math.floor((y + skipStep) * tileSizeY + 0.5)
            local px = px0
            local py = py0
            local w = math.max(1, px1 - px0)
            local h = math.max(1, py1 - py0)

            local worldX = x * map.tileSize
            local worldY = y * map.tileSize

            local tileSeason = season
            if map.seasonZones and #map.seasonZones > 0 then
                for _, zone in ipairs(map.seasonZones) do
                    if worldX >= zone.x and worldX < zone.x + zone.width and
                       worldY >= zone.y and worldY < zone.y + zone.height then
                        tileSeason = zone.season
                        break
                    end
                end
            end

            local tileTheme = map.getSeasonTheme and map:getSeasonTheme(tileSeason) or MapRenderer.getDefaultTheme(tileSeason)

            local isRoad = (x % 5 == 0 or y % 5 == 0)

            if isRoad then
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(tileTheme.road1 or {0.5, 0.5, 0.5})
                else
                    love.graphics.setColor(tileTheme.road2 or {0.48, 0.48, 0.48})
                end
                love.graphics.rectangle("fill", px, py, w, h)
            else
                local noise = (math.sin(x * 0.5) + math.cos(y * 0.7)) * 0.5
                local colorIndex = (x + y) % 2

                if noise > 0.3 then
                    love.graphics.setColor(tileTheme.grass3 or {0.4, 0.7, 0.4})
                elseif noise < -0.3 then
                    love.graphics.setColor(tileTheme.grass4 or {0.28, 0.6, 0.28})
                elseif colorIndex == 0 then
                    love.graphics.setColor(tileTheme.grass1 or {0.35, 0.65, 0.35})
                else
                    love.graphics.setColor(tileTheme.grass2 or {0.3, 0.6, 0.3})
                end
                love.graphics.rectangle("fill", px, py, w, h)
            end
        end
    end
end

function MapRenderer.renderObjects(map, renderX, renderY, scaleX, scaleY)
    if not map.objects then return end
    
    for _, obj in ipairs(map.objects) do
        local ox = renderX + obj.x * scaleX
        local oy = renderY + obj.y * scaleY
        local size = (obj.size or 1) * scaleX * 10
        
        if obj.type == "tree" then
            love.graphics.setColor(0.2, 0.5, 0.2, 0.8)
            love.graphics.circle("fill", ox, oy - size * 0.3, size)
        elseif obj.type == "rock" then
            love.graphics.setColor(0.5, 0.5, 0.5, 0.8)
            love.graphics.circle("fill", ox, oy, size * 0.5)
        elseif obj.type == "water" then
            love.graphics.setColor(0.3, 0.5, 0.8, 0.6)
            love.graphics.rectangle("fill", ox, oy, 
                (obj.width or map.tileSize) * scaleX, 
                (obj.height or map.tileSize) * scaleY)
        end
    end
end

function MapRenderer.getDefaultTheme(season)
    local themes = {
        spring = {
            grass1 = {0.35, 0.70, 0.35},
            grass2 = {0.30, 0.65, 0.30},
            grass3 = {0.40, 0.75, 0.40},
            grass4 = {0.28, 0.60, 0.28},
            road1 = {0.50, 0.48, 0.45},
            road2 = {0.48, 0.46, 0.43},
            flower1 = {1.0, 0.4, 0.6},
            flower2 = {0.9, 0.7, 0.3},
            flower3 = {0.6, 0.4, 0.9},
        },
        summer = {
            grass1 = {0.25, 0.60, 0.25},
            grass2 = {0.22, 0.55, 0.22},
            grass3 = {0.28, 0.65, 0.28},
            grass4 = {0.20, 0.50, 0.20},
            road1 = {0.55, 0.53, 0.50},
            road2 = {0.52, 0.50, 0.48},
        },
        autumn = {
            grass1 = {0.65, 0.55, 0.30},
            grass2 = {0.60, 0.50, 0.28},
            grass3 = {0.70, 0.60, 0.32},
            grass4 = {0.58, 0.48, 0.26},
            road1 = {0.48, 0.46, 0.44},
            road2 = {0.45, 0.43, 0.41},
        },
        winter = {
            grass1 = {0.85, 0.90, 0.95},
            grass2 = {0.80, 0.85, 0.90},
            grass3 = {0.88, 0.92, 0.96},
            grass4 = {0.78, 0.83, 0.88},
            road1 = {0.60, 0.62, 0.65},
            road2 = {0.58, 0.60, 0.63},
        }
    }
    return themes[season] or themes.spring
end

function MapRenderer.drawMinimapFrame(x, y, width, height, style)
    style = style or "modern"
    
    if style == "modern" then
        love.graphics.setColor(0, 0, 0, 0.6)
        MapRenderer.drawRoundedRect(x - 4, y - 4, width + 8, height + 8, 8)
        
        love.graphics.setColor(0.15, 0.15, 0.2, 0.9)
        MapRenderer.drawRoundedRect(x - 2, y - 2, width + 4, height + 4, 6)
        
        local gradient = MapRenderer.animationTime * 0.5
        local glowAlpha = 0.3 + 0.1 * math.sin(gradient)
        love.graphics.setColor(0.4, 0.6, 0.8, glowAlpha)
        love.graphics.setLineWidth(2)
        MapRenderer.drawRoundedRectLine(x - 2, y - 2, width + 4, height + 4, 6)
        love.graphics.setLineWidth(1)
        
        love.graphics.setColor(0.6, 0.7, 0.8, 0.5)
        love.graphics.setLineWidth(1)
        MapRenderer.drawRoundedRectLine(x - 1, y - 1, width + 2, height + 2, 5)
        
    else
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", x - 2, y - 2, width + 4, height + 4)
        
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x - 2, y - 2, width + 4, height + 4)
        love.graphics.setLineWidth(1)
    end
end

function MapRenderer.drawRoundedRect(x, y, width, height, radius)
    radius = math.min(radius, width / 2, height / 2)
    
    love.graphics.rectangle("fill", x + radius, y, width - radius * 2, height)
    love.graphics.rectangle("fill", x, y + radius, width, height - radius * 2)
    love.graphics.arc("fill", x + radius, y + radius, radius, math.pi, math.pi * 1.5)
    love.graphics.arc("fill", x + width - radius, y + radius, radius, math.pi * 1.5, math.pi * 2)
    love.graphics.arc("fill", x + radius, y + height - radius, radius, math.pi * 0.5, math.pi)
    love.graphics.arc("fill", x + width - radius, y + height - radius, radius, 0, math.pi * 0.5)
end

function MapRenderer.drawRoundedRectLine(x, y, width, height, radius)
    radius = math.min(radius, width / 2, height / 2)
    
    love.graphics.line(x + radius, y, x + width - radius, y)
    love.graphics.line(x + radius, y + height, x + width - radius, y + height)
    love.graphics.line(x, y + radius, x, y + height - radius)
    love.graphics.line(x + width, y + radius, x + width, y + height - radius)
    
    love.graphics.arc("line", x + radius, y + radius, radius, math.pi, math.pi * 1.5)
    love.graphics.arc("line", x + width - radius, y + radius, radius, math.pi * 1.5, math.pi * 2)
    love.graphics.arc("line", x + radius, y + height - radius, radius, math.pi * 0.5, math.pi)
    love.graphics.arc("line", x + width - radius, y + height - radius, radius, 0, math.pi * 0.5)
end

function MapRenderer.drawMapLabel(x, y, text, font)
    font = font or love.graphics.getFont()
    
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight()
    
    love.graphics.setColor(0, 0, 0, 0.7)
    MapRenderer.drawRoundedRect(x - textWidth/2 - 6, y - textHeight/2 - 3, textWidth + 12, textHeight + 6, 4)
    
    love.graphics.setColor(0.9, 0.9, 0.95)
    love.graphics.setFont(font)
    love.graphics.printf(text, x - textWidth/2, y - textHeight/2, textWidth, "center")
end

return MapRenderer
