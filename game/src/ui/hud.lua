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

    -- Minimap click hint
    self.minimapHintAlpha = 0
    self.minimapHintTimer = 0

    return self
end

-- Update HUD (for animations)
function HUD:update(dt)
    -- Update minimap hint animation
    if self.minimapHintTimer > 0 then
        self.minimapHintTimer = self.minimapHintTimer - dt
        self.minimapHintAlpha = math.max(0, self.minimapHintTimer / 2.0)
    end
end

-- Draw HUD
function HUD:draw(playerX, playerY, mapWidth, mapHeight)
    -- Draw minimap with coordinates below
    self:drawMinimap(playerX, playerY, mapWidth, mapHeight)
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

    -- Draw "Click to open" hint
    if self.minimapHintAlpha > 0 then
        love.graphics.setColor(1, 1, 1, self.minimapHintAlpha)
        love.graphics.printf("Click or TAB", mm.x, mm.y - 20, mm.size, "center")
    end

    love.graphics.setColor(1, 1, 1)
end

-- Check if mouse is over minimap
function HUD:isMouseOverMinimap(x, y)
    local mm = self.minimap
    return x >= mm.x and x <= mm.x + mm.size and
           y >= mm.y and y <= mm.y + mm.size
end

-- Show minimap hint
function HUD:showMinimapHint()
    self.minimapHintTimer = 2.0
    self.minimapHintAlpha = 1.0
end

return HUD

