-- battle_panels.lua - Battle UI panels (player info, battle log)
-- Handles rendering of information panels

local BattlePanels = {}

-- Draw HP bar
function BattlePanels.drawHPBar(colors, entity, x, y, width, height)
    local hpPercent = entity:getHPPercent()
    
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- HP fill
    local color = colors.hpGreen
    if hpPercent < 0.3 then
        color = colors.hpRed
    elseif hpPercent < 0.6 then
        color = colors.hpYellow
    end
    
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, width * hpPercent, height)
    
    -- Border
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
end

-- Draw player panel
function BattlePanels.drawPlayerPanel(colors, player, x, y)
    -- Panel background
    love.graphics.setColor(colors.panel)
    love.graphics.rectangle("fill", x, y, 300, 160, 5, 5)
    
    -- Player name
    love.graphics.setColor(colors.text)
    love.graphics.print("Player", x + 10, y + 10)
    
    -- HP
    love.graphics.print("HP: " .. player.hp .. " / " .. player.maxHp, x + 10, y + 35)
    
    -- HP bar
    BattlePanels.drawHPBar(colors, player, x + 10, y + 55, 280, 15)
    
    -- Stats
    love.graphics.print("ATK: " .. player.attack, x + 10, y + 80)
    love.graphics.print("DEF: " .. player.defense, x + 120, y + 80)
    love.graphics.print("SPD: " .. player.speed, x + 230, y + 80)

    -- Gold
    love.graphics.print("Gold: " .. (player.gold or 0), x + 10, y + 105)
    
    -- Equipment info
    if player.equipment then
        local equipCount = 0
        for _, item in pairs(player.equipment) do
            if item then equipCount = equipCount + 1 end
        end
        love.graphics.print("Equipment: " .. equipCount .. "/3", x + 10, y + 130)
    end
    
    -- Pet info
    if player.pet then
        love.graphics.print("Pet: " .. player.pet.name, x + 150, y + 130)
    end
end

-- Draw battle log
function BattlePanels.drawBattleLog(colors, battleSystem, x, y)
    local battleLog = battleSystem.battleLog
    local messages = battleLog:getMessages()

    -- Panel background
    love.graphics.setColor(colors.panel)
    love.graphics.rectangle("fill", x, y, 400, 120, 5, 5)

    -- Title
    love.graphics.setColor(colors.text)
    love.graphics.print("Battle Log", x + 10, y + 10)

    -- Calculate scroll parameters
    local lineHeight = 20
    local viewHeight = 80  -- Height of visible area
    local contentHeight = #messages * lineHeight

    -- Clamp scroll offset
    local scrollOffset = battleLog:getScrollOffset()
    local maxScroll = math.max(0, contentHeight - viewHeight)
    scrollOffset = math.max(0, math.min(scrollOffset, maxScroll))
    battleLog:setScrollOffset(scrollOffset)

    -- Enable scissor to clip messages
    love.graphics.setScissor(x + 10, y + 30, 380, viewHeight)

    -- Draw messages with scroll offset
    local messageY = y + 30 + scrollOffset
    for i = 1, #messages do
        local msg = messages[i]

        -- Only draw if in visible area
        if messageY >= y + 30 - lineHeight and messageY <= y + 30 + viewHeight then
            love.graphics.setColor(colors.text)
            love.graphics.print(msg, x + 10, messageY)
        end

        messageY = messageY + lineHeight
    end

    -- Disable scissor
    love.graphics.setScissor()

    -- Draw scrollbar if needed
    if contentHeight > viewHeight then
        BattlePanels.drawScrollbar(colors, x + 385, y + 30, viewHeight, contentHeight, scrollOffset)
    end
end

-- Draw scrollbar
function BattlePanels.drawScrollbar(colors, x, y, viewHeight, contentHeight, scrollOffset)
    local scrollbarWidth = 5

    -- Scrollbar background
    love.graphics.setColor(0.2, 0.2, 0.25, 0.5)
    love.graphics.rectangle("fill", x, y, scrollbarWidth, viewHeight)

    -- Scrollbar thumb
    local thumbHeight = math.max(20, (viewHeight / contentHeight) * viewHeight)
    local maxScroll = contentHeight - viewHeight
    local thumbY = y + (scrollOffset / maxScroll) * (viewHeight - thumbHeight)

    love.graphics.setColor(0.4, 0.6, 1.0, 0.8)
    love.graphics.rectangle("fill", x, thumbY, scrollbarWidth, thumbHeight, 2, 2)
end

return BattlePanels

