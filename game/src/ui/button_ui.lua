local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local ButtonUI = {}
ButtonUI.__index = ButtonUI

function ButtonUI.new()
    local self = setmetatable({}, ButtonUI)
    
    self.buttons = {
        {
            id = "equipment",
            label = "Equipment",
            key = "e",
            x = 0,
            y = 0,
            width = 120,
            height = 40
        },
        {
            id = "inventory",
            label = "Inventory",
            key = "i",
            x = 0,
            y = 0,
            width = 120,
            height = 40
        }
    }
    
    self.colors = {
        background = Theme.colors.button,
        hover = Theme.colors.buttonHover,
        text = Theme.colors.text,
        border = Theme.colors.border
    }
    
    return self
end

-- Update button positions
function ButtonUI:updatePositions()
    local w, h = love.graphics.getDimensions()
    local startX = w - 140
    local startY = h - 100
    
    for i, button in ipairs(self.buttons) do
        button.x = startX
        button.y = startY - (i - 1) * 50
    end
end

function ButtonUI:draw()
    self:updatePositions()
    
    local mx, my = love.mouse.getPosition()
    local font = love.graphics.getFont()
    
    for _, button in ipairs(self.buttons) do
        local isHover = mx >= button.x and mx <= button.x + button.width and
                       my >= button.y and my <= button.y + button.height
        
        Components.drawButtonSimple(button.x, button.y, button.width, button.height, 
            button.label, isHover, false, font)
        
        love.graphics.setColor(Theme.colors.textDim)
        love.graphics.printf("[" .. button.key:upper() .. "]", button.x, button.y + 22, button.width, "center")
    end
end

-- Check if mouse clicked on a button
function ButtonUI:checkClick(x, y)
    for _, button in ipairs(self.buttons) do
        if x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height then
            return button.id
        end
    end
    return nil
end

return ButtonUI

