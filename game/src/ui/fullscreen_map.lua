-- fullscreen_map.lua - Fullscreen map UI
-- Display full map with navigation support

local FullscreenMap = {}
FullscreenMap.__index = FullscreenMap

function FullscreenMap.new(assetManager)
    local self = setmetatable({}, FullscreenMap)
    
    self.assetManager = assetManager
    self.isOpen = false
    
    -- Screen dimensions
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    -- Map panel dimensions (80% of screen)
    self.panelWidth = self.screenWidth * 0.8
    self.panelHeight = self.screenHeight * 0.8
    self.panelX = (self.screenWidth - self.panelWidth) / 2
    self.panelY = (self.screenHeight - self.panelHeight) / 2
    
    -- Map rendering area (inside panel with padding)
    self.padding = 40
    self.mapRenderWidth = self.panelWidth - self.padding * 2
    self.mapRenderHeight = self.panelHeight - self.padding * 2
    self.mapRenderX = self.panelX + self.padding
    self.mapRenderY = self.panelY + self.padding
    
    -- Colors
    self.colors = {
        overlay = {0, 0, 0, 0.7},
        panel = {0.1, 0.1, 0.15, 0.95},
        border = {0.4, 0.7, 1.0, 0.9},
        text = {1, 1, 1},
        road = {0.55, 0.55, 0.60},
        grass = {0.35, 0.65, 0.35},
        player = {1, 0.2, 0.2},
        playerView = {1, 1, 0, 0.3},
        navigationTarget = {0.2, 1, 0.2, 0.8}
    }
    
    -- Navigation target
    self.navigationTarget = nil
    
    -- Fonts
    self.font = assetManager:getFont("default")
    self.fontLarge = assetManager:getFont("large")
    
    return self
end

-- Toggle map open/close
function FullscreenMap:toggle()
    self.isOpen = not self.isOpen
    if not self.isOpen then
        -- Clear navigation target when closing
        self.navigationTarget = nil
    end
end

-- Open map
function FullscreenMap:open()
    self.isOpen = true
end

-- Close map
function FullscreenMap:close()
    self.isOpen = false
    self.navigationTarget = nil
end

-- Check if map is open
function FullscreenMap:isMapOpen()
    return self.isOpen
end

-- Handle mouse click on map
function FullscreenMap:mousepressed(x, y, button, mapWidth, mapHeight)
    if not self.isOpen then
        return nil
    end
    
    -- Check if click is inside map render area
    if x >= self.mapRenderX and x <= self.mapRenderX + self.mapRenderWidth and
       y >= self.mapRenderY and y <= self.mapRenderY + self.mapRenderHeight then
        
        if button == 1 then -- Left click
            -- Convert screen coordinates to world coordinates
            local worldX = ((x - self.mapRenderX) / self.mapRenderWidth) * mapWidth
            local worldY = ((y - self.mapRenderY) / self.mapRenderHeight) * mapHeight
            
            -- Set navigation target
            self.navigationTarget = {x = worldX, y = worldY}
            
            -- Close map and return target position
            self.isOpen = false
            return worldX, worldY
        end
    end
    
    -- Check if click is outside panel (close map)
    if x < self.panelX or x > self.panelX + self.panelWidth or
       y < self.panelY or y > self.panelY + self.panelHeight then
        self:close()
    end
    
    return nil
end

-- Draw fullscreen map
function FullscreenMap:draw(playerX, playerY, mapWidth, mapHeight, minimapData)
    if not self.isOpen then
        return
    end
    
    -- Draw overlay
    love.graphics.setColor(self.colors.overlay)
    love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)
    
    -- Draw panel background
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", self.panelX, self.panelY, self.panelWidth, self.panelHeight, 10, 10)
    
    -- Draw panel border
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.panelX, self.panelY, self.panelWidth, self.panelHeight, 10, 10)
    love.graphics.setLineWidth(1)
    
    -- Draw title
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("World Map", self.panelX, self.panelY + 10, self.panelWidth, "center")
    love.graphics.setFont(self.font)
    
    -- Draw map content
    self:drawMapContent(playerX, playerY, mapWidth, mapHeight, minimapData)
    
    -- Draw instructions
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Click on map to navigate | Press TAB or ESC to close", 
                        self.panelX, self.panelY + self.panelHeight - 25, 
                        self.panelWidth, "center")
end

-- Draw map content (grid, player, etc.)
function FullscreenMap:drawMapContent(playerX, playerY, mapWidth, mapHeight, minimapData)
    -- Draw simplified map grid
    local gridSize = self.mapRenderWidth / 10
    for i = 0, 9 do
        for j = 0, 9 do
            -- Show roads on map
            if i % 5 == 0 or j % 5 == 0 then
                love.graphics.setColor(self.colors.road)
            else
                love.graphics.setColor(self.colors.grass)
            end
            
            love.graphics.rectangle("fill",
                self.mapRenderX + i * gridSize,
                self.mapRenderY + j * gridSize,
                gridSize, gridSize)
        end
    end
    
    -- Draw buildings if minimap data is available
    if minimapData and minimapData.buildings then
        for _, building in ipairs(minimapData.buildings) do
            -- Scale building position to fullscreen map
            local bx = self.mapRenderX + (building.x / minimapData.width) * self.mapRenderWidth
            local by = self.mapRenderY + (building.y / minimapData.height) * self.mapRenderHeight
            local bw = (building.w / minimapData.width) * self.mapRenderWidth
            local bh = (building.h / minimapData.height) * self.mapRenderHeight
            
            love.graphics.setColor(building.color)
            love.graphics.rectangle("fill", bx, by, bw, bh, 3, 3)
            
            -- Draw building name on hover (simplified - always show)
            if bw > 20 and bh > 20 then
                love.graphics.setColor(1, 1, 1, 0.8)
                love.graphics.printf(building.name, bx - 20, by + bh + 5, bw + 40, "center")
            end
        end
    end
    
    -- Draw player position
    local playerMapX = self.mapRenderX + (playerX / mapWidth) * self.mapRenderWidth
    local playerMapY = self.mapRenderY + (playerY / mapHeight) * self.mapRenderHeight
    
    -- Player view range
    love.graphics.setColor(self.colors.playerView)
    love.graphics.circle("fill", playerMapX, playerMapY, 30)
    
    love.graphics.setColor(1, 1, 0, 0.6)
    love.graphics.circle("line", playerMapX, playerMapY, 30)
    
    -- Player position dot
    love.graphics.setColor(self.colors.player)
    love.graphics.circle("fill", playerMapX, playerMapY, 8)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", playerMapX, playerMapY, 8)
    
    -- Draw player coordinates
    love.graphics.setColor(self.colors.text)
    love.graphics.printf(string.format("Player: (%.0f, %.0f)", playerX, playerY),
                        playerMapX - 50, playerMapY + 40, 100, "center")
    
    -- Draw navigation target if set
    if self.navigationTarget then
        local targetMapX = self.mapRenderX + (self.navigationTarget.x / mapWidth) * self.mapRenderWidth
        local targetMapY = self.mapRenderY + (self.navigationTarget.y / mapHeight) * self.mapRenderHeight
        
        -- Pulsing target marker
        local pulse = 0.5 + 0.5 * math.sin(love.timer.getTime() * 3)
        love.graphics.setColor(self.colors.navigationTarget[1], 
                              self.colors.navigationTarget[2], 
                              self.colors.navigationTarget[3], 
                              pulse)
        love.graphics.circle("fill", targetMapX, targetMapY, 10)
        
        love.graphics.setColor(0.2, 1, 0.2)
        love.graphics.circle("line", targetMapX, targetMapY, 10)
        love.graphics.circle("line", targetMapX, targetMapY, 15)
        
        -- Draw line from player to target
        love.graphics.setColor(0.2, 1, 0.2, 0.5)
        love.graphics.setLineWidth(2)
        love.graphics.line(playerMapX, playerMapY, targetMapX, targetMapY)
        love.graphics.setLineWidth(1)
    end
end

-- Get navigation target
function FullscreenMap:getNavigationTarget()
    return self.navigationTarget
end

-- Clear navigation target
function FullscreenMap:clearNavigationTarget()
    self.navigationTarget = nil
end

return FullscreenMap

