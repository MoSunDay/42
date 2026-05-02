local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local ButtonUI = {}

function ButtonUI.create(assetManager)
    local state = {}
    
    state.assetManager = assetManager
    
    state.buttons = {
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
    
    return state
end

function ButtonUI.updatePositions(state)
    local w, h = love.graphics.getDimensions()
    local startX = w - 140
    local startY = h - 100
    
    for i, button in ipairs(state.buttons) do
        button.x = startX
        button.y = startY - (i - 1) * 50
    end
end

function ButtonUI.draw(state)
    ButtonUI.updatePositions(state)
    
    local mx, my = love.mouse.getPosition()
    local font = love.graphics.getFont()
    
    for _, button in ipairs(state.buttons) do
        local isHover = mx >= button.x and mx <= button.x + button.width and
                       my >= button.y and my <= button.y + button.height
        
        Components.drawOrnateButton(button.x, button.y, button.width, button.height,
            button.label, isHover and "hover" or "normal", state.assetManager, font)
        
        love.graphics.setColor(Theme.colors.textDim)
        love.graphics.setFont(font)
        love.graphics.printf("[" .. button.key:upper() .. "]", button.x, button.y + 22, button.width, "center")
    end
end

function ButtonUI.checkClick(state, x, y)
    for _, button in ipairs(state.buttons) do
        if x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height then
            return button.id
        end
    end
    return nil
end

return ButtonUI
