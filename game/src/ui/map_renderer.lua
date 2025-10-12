-- map_renderer.lua - Unified map rendering for minimap, fullscreen map, etc.
-- 统一的地图渲染器，确保所有地图显示一致

local MapRenderer = {}

-- Render map at any scale
-- Parameters:
--   map: MapData object
--   renderX, renderY: Top-left corner of render area
--   renderWidth, renderHeight: Size of render area
--   playerX, playerY: Player position in world coordinates
--   options: {
--     showPlayer: boolean (default true)
--     showBuildings: boolean (default true)
--     showEncounters: boolean (default false)
--     showNPCs: boolean (default false)
--     playerColor: {r, g, b} (default {1, 0.2, 0.2})
--     playerRadius: number (default 5)
--   }
function MapRenderer.render(map, renderX, renderY, renderWidth, renderHeight, playerX, playerY, options)
    options = options or {}
    local showPlayer = options.showPlayer ~= false
    local showBuildings = options.showBuildings ~= false
    local showEncounters = options.showEncounters or false
    local showNPCs = options.showNPCs or false
    local playerColor = options.playerColor or {1, 0.2, 0.2}
    local playerRadius = options.playerRadius or 5
    
    -- Calculate scale
    local scaleX = renderWidth / map.width
    local scaleY = renderHeight / map.height
    
    -- Helper function to convert world coordinates to render coordinates
    local function worldToRender(wx, wy)
        return renderX + wx * scaleX, renderY + wy * scaleY
    end
    
    -- Draw map tiles
    MapRenderer.renderTiles(map, renderX, renderY, renderWidth, renderHeight, scaleX, scaleY)
    
    -- Draw buildings
    if showBuildings and map.buildings then
        for _, building in ipairs(map.buildings) do
            local bx, by = worldToRender(building.x, building.y)
            local bw = building.width * scaleX
            local bh = building.height * scaleY
            
            -- Building shadow
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.rectangle("fill", bx + 2, by + 2, bw, bh, 2, 2)
            
            -- Building body
            love.graphics.setColor(building.color or {0.7, 0.5, 0.3})
            love.graphics.rectangle("fill", bx, by, bw, bh, 2, 2)
            
            -- Building outline
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", bx, by, bw, bh, 2, 2)
        end
    end
    
    -- Draw encounter zones
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
    
    -- Draw NPCs
    if showNPCs and map.npcs then
        for _, npc in ipairs(map.npcs) do
            local nx, ny = worldToRender(npc.x, npc.y)
            
            love.graphics.setColor(0.3, 0.7, 0.9)
            love.graphics.circle("fill", nx, ny, 3)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("line", nx, ny, 3)
        end
    end
    
    -- Draw player
    if showPlayer then
        local px, py = worldToRender(playerX, playerY)
        
        -- Player view range
        love.graphics.setColor(1, 1, 0, 0.2)
        love.graphics.circle("fill", px, py, playerRadius * 4)
        
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.circle("line", px, py, playerRadius * 4)
        
        -- Player dot
        love.graphics.setColor(playerColor)
        love.graphics.circle("fill", px, py, playerRadius)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", px, py, playerRadius)
    end
    
    love.graphics.setColor(1, 1, 1)
end

-- Render map tiles (grass, roads, seasonal decorations)
function MapRenderer.renderTiles(map, renderX, renderY, renderWidth, renderHeight, scaleX, scaleY)
    -- Calculate how many tiles to render
    local tilesX = math.floor(map.width / map.tileSize)
    local tilesY = math.floor(map.height / map.tileSize)
    
    -- Render tile size in screen space
    local tileSizeX = map.tileSize * scaleX
    local tileSizeY = map.tileSize * scaleY
    
    -- Get season theme
    local season = map.season or "spring"
    local theme = map.getSeasonTheme and map:getSeasonTheme(season) or MapRenderer.getDefaultTheme(season)
    
    -- Draw all tiles
    for y = 0, tilesY - 1 do
        for x = 0, tilesX - 1 do
            local px = renderX + x * tileSizeX
            local py = renderY + y * tileSizeY
            local worldX = x * map.tileSize
            local worldY = y * map.tileSize
            
            -- Determine season for this tile (check season zones)
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
            
            -- Get theme for this tile's season
            local tileTheme = map.getSeasonTheme and map:getSeasonTheme(tileSeason) or MapRenderer.getDefaultTheme(tileSeason)
            
            -- Create road pattern (every 5 tiles)
            local isRoad = (x % 5 == 0 or y % 5 == 0)
            
            if isRoad then
                -- Draw road
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(tileTheme.road1 or {0.5, 0.5, 0.5})
                else
                    love.graphics.setColor(tileTheme.road2 or {0.48, 0.48, 0.48})
                end
                love.graphics.rectangle("fill", px, py, tileSizeX, tileSizeY)
            else
                -- Draw grass
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
                love.graphics.rectangle("fill", px, py, tileSizeX, tileSizeY)
                
                -- Add seasonal decorations (only if tile is large enough)
                if tileSizeX > 2 and tileSizeY > 2 then
                    if tileSeason == "spring" and (x * 7 + y * 11) % 15 == 0 then
                        -- Spring flowers
                        local flowerColors = tileTheme.flower1 and {tileTheme.flower1, tileTheme.flower2, tileTheme.flower3} or {{1, 0.4, 0.6}, {0.9, 0.7, 0.3}, {0.6, 0.4, 0.9}}
                        local flowerColor = flowerColors[((x + y) % 3) + 1]
                        love.graphics.setColor(flowerColor[1], flowerColor[2], flowerColor[3], 0.8)
                        local dotSize = math.max(1, tileSizeX * 0.1)
                        love.graphics.circle("fill", px + tileSizeX * 0.3, py + tileSizeY * 0.4, dotSize)
                    elseif tileSeason == "winter" and (x * 3 + y * 13) % 10 == 0 then
                        -- Winter snow
                        love.graphics.setColor(1, 1, 1, 0.3)
                        local dotSize = math.max(1, tileSizeX * 0.15)
                        love.graphics.circle("fill", px + tileSizeX * 0.3, py + tileSizeY * 0.3, dotSize)
                    end
                end
            end
        end
    end
end

-- Get default theme if map doesn't have getSeasonTheme method
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

return MapRenderer

