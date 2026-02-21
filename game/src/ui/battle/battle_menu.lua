-- battle_menu.lua - Battle action menu rendering and interaction
-- Handles menu display, mouse clicks, and timer display

local Theme = require("src.ui.theme")

local BattleMenu = {}

function BattleMenu.draw(battleUI, battleSystem, x, y)
    local state = battleSystem:getState()
    
    if state ~= "player" then
        return
    end
    
    battleUI.menuX = x
    battleUI.menuY = y
    battleUI.menuHeight = 40 + #battleUI.actions * 30
    
    love.graphics.setColor(battleUI.colors.panel)
    love.graphics.rectangle("fill", x, y, battleUI.menuWidth, battleUI.menuHeight, 5, 5)
    
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

-- Draw turn timer
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
    
    love.graphics.setColor(Theme.colors.panelDark[1], Theme.colors.panelDark[2], Theme.colors.panelDark[3], 0.9)
    love.graphics.rectangle("fill", x, y, 200, 40, 5, 5)
    
    local timeRatio = turnTimer / maxTime
    local barWidth = 180 * timeRatio
    
    local timerColor
    if timeRatio > 0.5 then
        timerColor = Theme.colors.hp.high
    elseif timeRatio > 0.25 then
        timerColor = Theme.colors.hp.medium
    else
        timerColor = Theme.colors.hp.low
    end
    
    love.graphics.setColor(timerColor)
    love.graphics.rectangle("fill", x + 10, y + 10, barWidth, 20, 3, 3)
    
    love.graphics.setColor(Theme.colors.text)
    love.graphics.printf(string.format("%.1fs", turnTimer), x, y + 12, 200, "center")
end

return BattleMenu

