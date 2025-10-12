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
    local messages = battleSystem:getLog()
    
    -- Panel background
    love.graphics.setColor(colors.panel)
    love.graphics.rectangle("fill", x, y, 400, 120, 5, 5)
    
    -- Title
    love.graphics.setColor(colors.text)
    love.graphics.print("Battle Log", x + 10, y + 10)
    
    -- Messages (show last 4)
    for i = 1, math.min(4, #messages) do
        local msg = messages[i]
        love.graphics.print(msg, x + 10, y + 30 + (i - 1) * 20)
    end
end

return BattlePanels

