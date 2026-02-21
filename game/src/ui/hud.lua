-- hud.lua - Game HUD interface
-- Display coordinates, minimap, etc.

local MapRenderer = require("src.ui.map_renderer")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

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

    -- Bottom-right buttons
    self.buttons = {
        {
            name = "Menu",
            key = "menu",
            x = self.screenWidth - 110,
            y = self.screenHeight - 60,
            width = 100,
            height = 50,
            color = Theme.colors.button,
            hoverColor = Theme.colors.buttonHover,
            icon = "M"
        },
        {
            name = "Party",
            key = "party",
            x = self.screenWidth - 220,
            y = self.screenHeight - 60,
            width = 100,
            height = 50,
            color = Theme.colors.accent,
            hoverColor = {Theme.colors.accent[1] * 1.2, Theme.colors.accent[2] * 1.2, Theme.colors.accent[3] * 1.2},
            icon = "P"
        },
        {
            name = "Pet",
            key = "pet",
            x = self.screenWidth - 330,
            y = self.screenHeight - 60,
            width = 100,
            height = 50,
            color = Theme.colors.accentAlt,
            hoverColor = {Theme.colors.accentAlt[1] * 1.2, Theme.colors.accentAlt[2] * 1.2, Theme.colors.accentAlt[3] * 1.2},
            icon = "Pet"
        }
    }

    self.hoveredButton = nil

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
    MapRenderer.update(dt)
    
    if self.minimapHintTimer > 0 then
        self.minimapHintTimer = self.minimapHintTimer - dt
        self.minimapHintAlpha = math.max(0, self.minimapHintTimer / 2.0)
    end
end

-- Draw HUD
function HUD:draw(playerX, playerY, map)
    -- Draw minimap with coordinates below
    self:drawMinimap(playerX, playerY, map)

    -- Draw bottom-right buttons
    self:drawButtons()
end

-- Draw minimap
function HUD:drawMinimap(playerX, playerY, map)
    local mm = self.minimap

    MapRenderer.drawMinimapFrame(mm.x, mm.y, mm.size, mm.size, "modern")

    MapRenderer.render(map, mm.x, mm.y, mm.size, mm.size, playerX, playerY, {
        showPlayer = true,
        showBuildings = true,
        showEncounters = false,
        showNPCs = false,
        playerRadius = 5
    })

    local coordY = mm.y + mm.size + 10

    love.graphics.setColor(Theme.colors.minimap.background[1], Theme.colors.minimap.background[2], Theme.colors.minimap.background[3], 0.7)
    MapRenderer.drawRoundedRect(mm.x, coordY, mm.size, 28, 5)
    
    love.graphics.setColor(Theme.colors.minimap.border[1], Theme.colors.minimap.border[2], Theme.colors.minimap.border[3], 0.7)
    love.graphics.setLineWidth(1.5)
    MapRenderer.drawRoundedRectLine(mm.x, coordY, mm.size, 28, 5)
    love.graphics.setLineWidth(1)

    love.graphics.setFont(self.font)
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print(string.format("X: %.0f  Y: %.0f", playerX, playerY), mm.x + 10, coordY + 7)

    if map and map.name then
        local mapName = map.name
        local nameY = mm.y - 18
        
        love.graphics.setColor(Theme.colors.minimap.background[1], Theme.colors.minimap.background[2], Theme.colors.minimap.background[3], 0.7)
        MapRenderer.drawRoundedRect(mm.x, nameY, mm.size, 16, 3)
        
        love.graphics.setColor(Theme.colors.textBright)
        love.graphics.printf(mapName, mm.x, nameY + 2, mm.size, "center")
    end

    if self.minimapHintAlpha > 0 then
        love.graphics.setColor(Theme.colors.warning[1], Theme.colors.warning[2], Theme.colors.warning[3], self.minimapHintAlpha * 0.8)
        love.graphics.setFont(self.font)
        love.graphics.printf("Click to open map", mm.x, mm.y + mm.size / 2 - 8, mm.size, "center")
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

-- Draw bottom-right buttons
function HUD:drawButtons()
    local mouseX, mouseY = love.mouse.getPosition()

    for _, button in ipairs(self.buttons) do
        -- Check if mouse is over button
        local isHovered = mouseX >= button.x and mouseX <= button.x + button.width and
                         mouseY >= button.y and mouseY <= button.y + button.height

        -- Button background
        if isHovered then
            love.graphics.setColor(button.hoverColor)
        else
            love.graphics.setColor(button.color)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 5, 5)

        -- Button border
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 5, 5)
        love.graphics.setLineWidth(1)

        -- Button text
        love.graphics.setFont(self.font)
        love.graphics.setColor(1, 1, 1)
        local textWidth = self.font:getWidth(button.name)
        love.graphics.print(button.name, button.x + (button.width - textWidth) / 2, button.y + 18)
    end

    love.graphics.setColor(1, 1, 1)
end

-- Check if mouse is over any button
function HUD:isMouseOverButton(x, y)
    for _, button in ipairs(self.buttons) do
        if x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height then
            return button.key
        end
    end
    return nil
end

return HUD

