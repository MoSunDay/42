local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local BattleSystem = require("src.systems.battle.battle_system")

local BattleMenu = {}

local ACTION_GEMS = {
    attack = Theme.gem.ruby,
    skill = Theme.gem.amethyst,
    defend = Theme.gem.sapphire,
    item = Theme.gem.emerald,
    escape = Theme.gem.topaz,
    auto = Theme.gem.diamond
}

function BattleMenu.draw(battleUI, battleSystem, x, y)
    local state = BattleSystem.getState(battleSystem)
    if state ~= "player" then return end
    
    battleUI.menuX = x
    battleUI.menuY = y
    battleUI.menuHeight = 40 + #battleUI.actions * 30
    
    Components.drawOrnatePanel(x, y, battleUI.menuWidth, battleUI.menuHeight, battleUI.assetManager, {
        title = "Actions",
        corners = true,
        glow = false,
        shimmer = false,
        font = battleUI.assetManager:getFont("default")
    })
    
    local font = battleUI.assetManager:getFont("default")
    
    for i, action in ipairs(battleUI.actions) do
        local btnY = y + 30 + (i - 1) * 30
        local isSelected = i == battleUI.selectedAction
        local gemColor = ACTION_GEMS[action.key] or Theme.gem.ruby
        
        Components.drawOrnateButton(
            x + 5, btnY, 190, 25,
            action.key == "auto" and (BattleSystem.isAutoBattle(battleSystem) and "Cancel Auto" or "Auto Battle") or action.name,
            isSelected and "pressed" or "normal",
            battleUI.assetManager,
            font,
            { gemColor = gemColor }
        )

        if action.key == "auto" and BattleSystem.isAutoBattle(battleSystem) then
            love.graphics.setFont(font)
            love.graphics.setColor(Theme.colors.warning)
            love.graphics.print("Auto Battle", x + 15, btnY + 5)
        end
    end
end

function BattleMenu.mousepressed(battleUI, x, y, button, battleSystem)
    if button ~= 1 then return nil end
    
    local state = BattleSystem.getState(battleSystem)
    if state ~= "player" then return nil end
    
    if x >= battleUI.menuX and x <= battleUI.menuX + battleUI.menuWidth and
       y >= battleUI.menuY and y <= battleUI.menuY + battleUI.menuHeight then
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

function BattleMenu.drawTimer(battleSystem, x, y, assetManager)
    local state = BattleSystem.getState(battleSystem)
    if state ~= "player" then return end
    
    local turnTimer = BattleSystem.getTurnTimer(battleSystem)
    local maxTime = BattleSystem.getMaxTurnTime(battleSystem)
    if not turnTimer or not maxTime then return end
    
    Components.drawOrnatePanel(x, y, 200, 40, assetManager, { corners = false, glow = false })
    
    local timeRatio = turnTimer / maxTime
    Components.drawOrnateHPBar(x + 10, y + 10, 180, 20, timeRatio, nil, assetManager)
    
    love.graphics.setColor(Theme.colors.text)
    love.graphics.printf(string.format("%.1fs", turnTimer), x, y + 12, 200, "center")
end

return BattleMenu
