-- battle_menu.lua - Battle action menu rendering and interaction
-- Handles menu display, mouse clicks, and timer display

local BattleMenu = {}

-- Draw action menu
function BattleMenu.draw(battleUI, battleSystem, x, y)
    local state = battleSystem:getState()
    
    -- Only show during player turn
    if state ~= "player" then
        return
    end
    
    -- Store menu position for mouse detection
    battleUI.menuX = x
    battleUI.menuY = y
    battleUI.menuHeight = 40 + #battleUI.actions * 30
    
    -- Panel background (dynamic height based on action count)
    love.graphics.setColor(battleUI.colors.panel)
    love.graphics.rectangle("fill", x, y, battleUI.menuWidth, battleUI.menuHeight, 5, 5)
    
    -- Title
    love.graphics.setColor(battleUI.colors.text)
    love.graphics.print("Actions", x + 10, y + 10)
    
    -- Action buttons
    for i, action in ipairs(battleUI.actions) do
        local btnY = y + 30 + (i - 1) * 30

        -- Highlight selected
        if i == battleUI.selectedAction then
            love.graphics.setColor(battleUI.colors.selected)
            love.graphics.rectangle("fill", x + 5, btnY, 190, 25, 3, 3)
        end

        -- Action text
        love.graphics.setColor(battleUI.colors.text)
        local actionText = action.name

        -- Show auto battle status
        if action.key == "auto" then
            if battleSystem:isAutoBattle() then
                actionText = "Cancel Auto"
                love.graphics.setColor(0.9, 0.5, 0.2)  -- Orange color for cancel
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
    
    -- Timer background
    love.graphics.setColor(0.2, 0.2, 0.25, 0.9)
    love.graphics.rectangle("fill", x, y, 200, 40, 5, 5)
    
    -- Timer bar
    local timeRatio = turnTimer / maxTime
    local barWidth = 180 * timeRatio
    
    -- Color based on time remaining
    if timeRatio > 0.5 then
        love.graphics.setColor(0.2, 0.8, 0.3)  -- Green
    elseif timeRatio > 0.25 then
        love.graphics.setColor(0.9, 0.9, 0.2)  -- Yellow
    else
        love.graphics.setColor(0.9, 0.2, 0.2)  -- Red
    end
    
    love.graphics.rectangle("fill", x + 10, y + 10, barWidth, 20, 3, 3)
    
    -- Timer text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(string.format("%.1fs", turnTimer), x, y + 12, 200, "center")
end

return BattleMenu

