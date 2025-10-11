-- hud.lua - Game HUD interface
-- Display coordinates, minimap, etc.

local HUD = {}
HUD.__index = HUD

function HUD.new(assetManager)
    local self = setmetatable({}, HUD)

    self.assetManager = assetManager

    -- Screen size
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()

    -- Minimap config
    self.minimap = {
        size = 180,
        x = self.screenWidth - 200,
        y = 20,
        padding = 10
    }

    -- Fonts
    self.font = assetManager:getFont("default")
    self.fontLarge = assetManager:getFont("large")

    return self
end

-- Draw HUD
function HUD:draw(playerX, playerY, mapWidth, mapHeight)
    -- Draw minimap with coordinates below
    self:drawMinimap(playerX, playerY, mapWidth, mapHeight)

    -- Draw FPS
    self:drawFPS()
end

-- Draw minimap
function HUD:drawMinimap(playerX, playerY, mapWidth, mapHeight)
    local mm = self.minimap

    -- Background
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", mm.x, mm.y, mm.size, mm.size, 5, 5)

    -- Border
    love.graphics.setColor(0.4, 0.7, 1.0, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", mm.x, mm.y, mm.size, mm.size, 5, 5)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(self.fontLarge)
    love.graphics.setColor(0.4, 0.7, 1.0)
    love.graphics.print("Minimap", mm.x + 10, mm.y - 25)

    -- Draw map area (simplified grid with town roads)
    local gridSize = mm.size / 10
    for i = 0, 9 do
        for j = 0, 9 do
            -- Show roads on minimap
            if i % 5 == 0 or j % 5 == 0 then
                love.graphics.setColor(0.55, 0.55, 0.60, 0.8)  -- Road color
            else
                love.graphics.setColor(0.35, 0.65, 0.35, 0.6)  -- Grass color
            end

            love.graphics.rectangle("fill",
                mm.x + i * gridSize,
                mm.y + j * gridSize,
                gridSize, gridSize)
        end
    end

    -- Draw player position
    local playerMinimapX = mm.x + (playerX / mapWidth) * mm.size
    local playerMinimapY = mm.y + (playerY / mapHeight) * mm.size

    -- Player view range
    love.graphics.setColor(1, 1, 0, 0.2)
    love.graphics.circle("fill", playerMinimapX, playerMinimapY, 20)

    love.graphics.setColor(1, 1, 0, 0.5)
    love.graphics.circle("line", playerMinimapX, playerMinimapY, 20)

    -- Player position dot
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.circle("fill", playerMinimapX, playerMinimapY, 5)

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", playerMinimapX, playerMinimapY, 5)

    -- Draw coordinates below minimap
    local coordY = mm.y + mm.size + 10

    -- Background for coordinates
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", mm.x, coordY, mm.size, 30, 5, 5)

    -- Border
    love.graphics.setColor(0.4, 0.7, 1.0, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", mm.x, coordY, mm.size, 30, 5, 5)
    love.graphics.setLineWidth(1)

    -- Coordinate text
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("X: %.0f  Y: %.0f", playerX, playerY), mm.x + 10, coordY + 8)

    love.graphics.setColor(1, 1, 1)
end

-- 绘制FPS
function HUD:drawFPS()
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", self.screenWidth - 100, self.screenHeight - 35, 90, 25, 3, 3)
    
    love.graphics.setColor(0.5, 1, 0.5)
    love.graphics.print("FPS: " .. love.timer.getFPS(), self.screenWidth - 90, self.screenHeight - 30)
    
    love.graphics.setColor(1, 1, 1)
end

return HUD

