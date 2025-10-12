-- hud.lua - Game HUD interface
-- Display coordinates, minimap, etc.

local MapRenderer = require("src.ui.map_renderer")

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
function HUD:draw(playerX, playerY, map)
    -- Draw minimap with coordinates below
    self:drawMinimap(playerX, playerY, map)
end

-- Draw minimap
function HUD:drawMinimap(playerX, playerY, map)
    local mm = self.minimap

    -- Background
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", mm.x, mm.y, mm.size, mm.size, 5, 5)

    -- Border
    love.graphics.setColor(0.4, 0.7, 1.0, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", mm.x, mm.y, mm.size, mm.size, 5, 5)
    love.graphics.setLineWidth(1)

    -- Use unified map renderer
    MapRenderer.render(map, mm.x, mm.y, mm.size, mm.size, playerX, playerY, {
        showPlayer = true,
        showBuildings = true,
        showEncounters = false,
        showNPCs = false,
        playerRadius = 5
    })

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

