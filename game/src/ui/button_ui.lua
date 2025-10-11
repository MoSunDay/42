-- button_ui.lua - Simple button UI for equipment and inventory
-- Displays buttons in bottom-right corner

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
        background = {0.2, 0.2, 0.25, 0.9},
        hover = {0.3, 0.4, 0.6, 0.9},
        text = {1, 1, 1},
        border = {0.4, 0.6, 1.0}
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

-- Draw buttons
function ButtonUI:draw()
    self:updatePositions()
    
    local mx, my = love.mouse.getPosition()
    
    for _, button in ipairs(self.buttons) do
        local isHover = mx >= button.x and mx <= button.x + button.width and
                       my >= button.y and my <= button.y + button.height
        
        -- Background
        if isHover then
            love.graphics.setColor(self.colors.hover)
        else
            love.graphics.setColor(self.colors.background)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 5, 5)
        
        -- Border
        love.graphics.setColor(self.colors.border)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 5, 5)
        love.graphics.setLineWidth(1)
        
        -- Text
        love.graphics.setColor(self.colors.text)
        love.graphics.printf(button.label, button.x, button.y + 8, button.width, "center")
        love.graphics.setColor(0.7, 0.7, 0.7)
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

