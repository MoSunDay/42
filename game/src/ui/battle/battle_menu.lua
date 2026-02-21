-- battle_menu.lua - Battle action menu rendering and interaction
-- Handles menu display, mouse clicks, and timer display

local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local BattleMenu = {}

function BattleMenu.draw(battleUI, battleSystem, x, y)
    local state = battleSystem:getState()
    
    if state ~= "player" then
        return
    end
    
    battleUI.menuX = x
    battleUI.menuY = y
    battleUI.menuHeight = 40 + #battleUI.actions * 30
    
    Components.drawPanelSimple(x, y, battleUI.menuWidth, battleUI.menuHeight, 5)
    
    love.graphics.setColor(battleUI.colors.text)
    love.graphics.print("Actions", x + 10, y + 10)
    
    for i, action in ipairs(battleUI.actions) do
        local btnY = y + 30 + (i - 1) * 30

        if i == battleUI.selectedAction then
            love.graphics.setColor(battleUI.colors.selected)
            love.graphics.rectangle("fill", x + 5, btnY, 190, 25, 3, 3)
        end

        love.graphics.setColor(battleUI.colors.text)
        local actionText = action.name

        if action.key == "auto" then
            if battleSystem:isAutoBattle() then
                actionText = "Cancel Auto"
                love.graphics.setColor(Theme.colors.warning)
            else
                actionText = "Auto Battle"
            end
        end

        love.graphics.print(actionText, x + 15, btnY + 5)
    end
end

-- Handle mouse click on action menu
function BattleMenu.mousepressed(battleUI, x, y, button, battleSystem)
    if button ~= 1 then  -- Only left click
        return nil
    end
    
    local state = battleSystem:getState()
    if state ~= "player" then
        return nil
    end
    
    -- Check if click is within menu bounds
    if x >= battleUI.menuX and x <= battleUI.menuX + battleUI.menuWidth and
       y >= battleUI.menuY and y <= battleUI.menuY + battleUI.menuHeight then
        
        -- Calculate which action was clicked
        local relativeY = y - (battleUI.menuY + 30)
        if relativeY >= 0 then
            local actionIndex = math.floor(relativeY / 30) + 1
            if actionIndex >= 1 and actionIndex <= #battleUI.actions then
                battleUI.selectedAction = actionIndex
                return battleUI.actions[actionIndex].key
            end
        end
    end
    
    return nil
end

function BattleMenu.drawTimer(battleSystem, x, y)
    local state = battleSystem:getState()
    if state ~= "player" then
        return
    end
    
    local turnTimer = battleSystem:getTurnTimer()
    local maxTime = battleSystem:getMaxTurnTime()
    
    if not turnTimer or not maxTime then
        return
    end
    
    Components.drawPanelSimple(x, y, 200, 40, 5)
    
    local timeRatio = turnTimer / maxTime
    Components.drawHPBar(x + 10, y + 10, 180, 20, timeRatio, nil)
    
    love.graphics.setColor(Theme.colors.text)
    love.graphics.printf(string.format("%.1fs", turnTimer), x, y + 12, 200, "center")
end

return BattleMenu

