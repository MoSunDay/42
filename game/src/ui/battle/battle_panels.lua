local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local CombatUtils = require("src.systems.combat_utils")
local BattleLog = require("src.systems.battle.battle_log")

local BattlePanels = {}

function BattlePanels.draw_hp_bar(colors, entity, x, y, width, height, assetManager)
    local hpPercent = CombatUtils.get_hp_percent(entity)
    Components.drawOrnateHPBar(x, y, width, height, hpPercent, nil, assetManager)
end

function BattlePanels.draw_player_panel(colors, player, x, y, assetManager)
    Components.drawOrnatePanel(x, y, 300, 160, assetManager, {
        title = "Player",
        corners = true,
        glow = true,
        shimmer = false,
        font = assetManager:get_font("default")
    })

    local font = assetManager:get_font("default")
    love.graphics.setFont(font)

    love.graphics.print("HP: " .. player.hp .. " / " .. player.maxHp, x + 10, y + 35)
    
    BattlePanels.draw_hp_bar(colors, player, x + 10, y + 55, 280, 15, assetManager)
    
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print("ATK: " .. player.attack, x + 10, y + 80)
    love.graphics.print("DEF: " .. player.defense, x + 120, y + 80)
    love.graphics.print("SPD: " .. player.speed, x + 230, y + 80)
    
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

function BattlePanels.draw_battle_log(colors, battleSystem, x, y, assetManager)
    local battleLog = battleSystem.battleLog
    local messages = BattleLog.get_messages(battleLog)

    Components.drawOrnatePanel(x, y, 400, 120, assetManager, {
        title = "Battle Log",
        corners = true,
        glow = false,
        font = assetManager:get_font("default")
    })

    local lineHeight = 20
    local viewHeight = 80
    local contentHeight = #messages * lineHeight

    local scrollOffset = BattleLog.get_scroll_offset(battleLog)
    local maxScroll = math.max(0, contentHeight - viewHeight)
    scrollOffset = math.max(0, math.min(scrollOffset, maxScroll))
    BattleLog.set_scroll_offset(battleLog, scrollOffset)

    love.graphics.setScissor(x + 10, y + 30, 380, viewHeight)

    local messageY = y + 30 + scrollOffset
    for i = 1, #messages do
        local msg = messages[i]
        if messageY >= y + 30 - lineHeight and messageY <= y + 30 + viewHeight then
            love.graphics.setColor(Theme.colors.text)
            love.graphics.print(msg, x + 10, messageY)
        end
        messageY = messageY + lineHeight
    end

    love.graphics.setScissor()

    if contentHeight > viewHeight then
        Components.drawScrollbar(x + 385, y + 30, 5, viewHeight, contentHeight, scrollOffset)
    end
end

return BattlePanels
