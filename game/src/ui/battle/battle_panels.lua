-- battle_panels.lua - Battle UI panels (player info, battle log)
-- Handles rendering of information panels

local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local BattlePanels = {}

function BattlePanels.drawHPBar(colors, entity, x, y, width, height)
    local hpPercent = entity:getHPPercent()
    Components.drawHPBar(x, y, width, height, hpPercent, nil)
end

function BattlePanels.drawPlayerPanel(colors, player, x, y)
    Components.drawPanelSimple(x, y, 300, 160, 5)
    
    love.graphics.setColor(colors.text)
    love.graphics.print("Player", x + 10, y + 10)
    
    love.graphics.print("HP: " .. player.hp .. " / " .. player.maxHp, x + 10, y + 35)
    
    BattlePanels.drawHPBar(colors, player, x + 10, y + 55, 280, 15)
    
    love.graphics.print("ATK: " .. player.attack, x + 10, y + 80)
    love.graphics.print("DEF: " .. player.defense, x + 120, y + 80)
    love.graphics.print("SPD: " .. player.speed, x + 230, y + 80)

    love.graphics.print("Gold: " .. (player.gold or 0), x + 10, y + 105)
    
    if player.equipment then
        local equipCount = 0
        for _, item in pairs(player.equipment) do
            if item then equipCount = equipCount + 1 end
        end
        love.graphics.print("Equipment: " .. equipCount .. "/3", x + 10, y + 130)
    end
    
    if player.pet then
        love.graphics.print("Pet: " .. player.pet.name, x + 150, y + 130)
    end
end

function BattlePanels.drawBattleLog(colors, battleSystem, x, y)
    local battleLog = battleSystem.battleLog
    local messages = battleLog:getMessages()

    Components.drawPanelSimple(x, y, 400, 120, 5)

    love.graphics.setColor(colors.text)
    love.graphics.print("Battle Log", x + 10, y + 10)

    local lineHeight = 20
    local viewHeight = 80
    local contentHeight = #messages * lineHeight

    local scrollOffset = battleLog:getScrollOffset()
    local maxScroll = math.max(0, contentHeight - viewHeight)
    scrollOffset = math.max(0, math.min(scrollOffset, maxScroll))
    battleLog:setScrollOffset(scrollOffset)

    love.graphics.setScissor(x + 10, y + 30, 380, viewHeight)

    local messageY = y + 30 + scrollOffset
    for i = 1, #messages do
        local msg = messages[i]

        if messageY >= y + 30 - lineHeight and messageY <= y + 30 + viewHeight then
            love.graphics.setColor(colors.text)
            love.graphics.print(msg, x + 10, messageY)
        end

        messageY = messageY + lineHeight
    end

    love.graphics.setScissor()

    if contentHeight > viewHeight then
        BattlePanels.drawScrollbar(colors, x + 385, y + 30, viewHeight, contentHeight, scrollOffset)
    end
end

-- Draw scrollbar
function BattlePanels.drawScrollbar(colors, x, y, viewHeight, contentHeight, scrollOffset)
    local scrollbarWidth = 5

    love.graphics.setColor(Theme.colors.chat.scrollbarBg)
    love.graphics.rectangle("fill", x, y, scrollbarWidth, viewHeight)

    local thumbHeight = math.max(20, (viewHeight / contentHeight) * viewHeight)
    local maxScroll = contentHeight - viewHeight
    local thumbY = y + (scrollOffset / maxScroll) * (viewHeight - thumbHeight)

    love.graphics.setColor(Theme.colors.chat.scrollbarThumb)
    love.graphics.rectangle("fill", x, thumbY, scrollbarWidth, thumbHeight, 2, 2)
end

return BattlePanels

