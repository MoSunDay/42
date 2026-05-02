local AnimationManager = require("src.animations.animation_manager")
local BattleBackground = require("src.ui.battle.battle_background")
local BattleMenu = require("src.ui.battle.battle_menu")
local BattlePanels = require("src.ui.battle.battle_panels")
local Components = require("src.ui.components")
local Theme = require("src.ui.theme")
local BattleSystem = require("src.systems.battle.battle_system")
local BattleAnimation = require("src.systems.battle.battle_animation")
local Enemy = require("src.entities.enemy")

local BattleUI = {}

function BattleUI.create(assetManager)
    local state = {}

    state.screenWidth = love.graphics.getWidth()
    state.screenHeight = love.graphics.getHeight()
    
    state.assetManager = assetManager

    state.actions = {
        {name = "Attack", key = "attack"},
        {name = "Skill", key = "skill"},
        {name = "Defend", key = "defend"},
        {name = "Item", key = "item"},
        {name = "Escape", key = "escape"},
        {name = "Auto", key = "auto"}
    }
    state.selectedAction = 1
    state.selectedEnemy = 1
    
    state.skillSelectMode = false
    state.selectedSkillIndex = 1
    state.availableSkills = {}

    state.menuX = 0
    state.menuY = 0
    state.menuWidth = 200
    state.menuHeight = 0
    
    state.colors = {
        background = Theme.colors.battle.background,
        panel = Theme.colors.battle.playerPanel,
        text = Theme.colors.text,
        hpGreen = Theme.colors.hp.high,
        hpYellow = Theme.colors.hp.medium,
        hpRed = Theme.colors.hp.low,
        selected = Theme.colors.battle.enemySelected
    }
    
    return state
end

function BattleUI.draw(state, battleSystem, player, map)
    local w = state.screenWidth
    local h = state.screenHeight
    
    local mapType = BattleBackground.getMapType(map)
    local bgImage = state.assetManager:getBattleBackground(mapType)
    
    if bgImage then
        local scaleX = w / bgImage:getWidth()
        local scaleY = h / bgImage:getHeight()
        love.graphics.draw(bgImage, 0, 0, 0, scaleX, scaleY)
    else
        BattleBackground.draw(w, h, mapType)
    end

    BattleUI.drawPlayer(state, player, w * 0.75, h * 0.7, BattleSystem.getAnimationManager(battleSystem))

    local enemies = BattleSystem.getEnemies(battleSystem)
    local enemyCount = #enemies

    if enemies[state.selectedEnemy] and not Enemy.isAlive(enemies[state.selectedEnemy]) then
        for i, enemy in ipairs(enemies) do
            if Enemy.isAlive(enemy) then
                state.selectedEnemy = i
                break
            end
        end
    end

    for i, enemy in ipairs(enemies) do
        local baseX = w * 0.2
        local baseY = h * 0.6
        local x = baseX + (i - 1) * 100
        local y = baseY - (i - 1) * 80
        BattleUI.drawEnemy(state, enemy, x, y, i == state.selectedEnemy)
    end
    
    BattlePanels.drawPlayerPanel(state.colors, player, 20, h - 180, state.assetManager)

    local menuHeight = 40 + #state.actions * 30
    local menuY = (h - menuHeight) / 2
    BattleMenu.draw(state, battleSystem, w - 220, menuY)

    BattlePanels.drawBattleLog(state.colors, battleSystem, 20, 20, state.assetManager)

    BattleMenu.drawTimer(battleSystem, w / 2 - 100, 20, state.assetManager)
    
    local battleState = BattleSystem.getState(battleSystem)
    BattleUI.drawTurnIndicator(state, battleState, w / 2, 30)

    local animation = BattleSystem.getAnimation(battleSystem)
    if animation then
        BattleAnimation.draw(animation)
    end
    
    if state.skillSelectMode then
        BattleUI.drawSkillSelectPanel(state, battleSystem, w, h)
    end
end

function BattleUI.drawPlayer(state, player, x, y, animationManager)
    local AccountManager = require("account.account_manager")
    local character = AccountManager.getCurrentCharacter()
    local avatarColor = character and character.avatarColor or {0.2, 0.6, 1.0}
    local appearanceId = character and character.appearanceId or "blue_hero"

    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if animationManager and player.animationId then
        offsetX, offsetY, rotation, scaleX, scaleY = AnimationManager.getTransform(animationManager, player.animationId)
    end

    love.graphics.push()
    love.graphics.translate(x + offsetX, y + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", 0, 40, 25, 10)

    local charSprite = state.assetManager and state.assetManager:getCharacterSprite(appearanceId, "south")
    if charSprite then
        love.graphics.setColor(1, 1, 1, 1)
        local sw, sh = charSprite:getDimensions()
        love.graphics.draw(charSprite, -sw / 2, -sh / 2)
    else
        love.graphics.setColor(avatarColor)
        love.graphics.circle("fill", 0, 0, 20)

        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", 0, -10, 4)

        love.graphics.setColor(avatarColor[1] * 0.5, avatarColor[2] * 0.5, avatarColor[3] * 0.5)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", 0, 0, 20)
        love.graphics.setLineWidth(1)
    end

    love.graphics.pop()
end

function BattleUI.drawEnemy(state, enemy, x, y, isSelected)
    if not Enemy.isAlive(enemy) then
        if Enemy.hasSprite(enemy) and state.assetManager then
            local sprite = Enemy.getSprite(enemy, "south")
            if sprite then
                love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
                local sw, sh = sprite:getDimensions()
                love.graphics.draw(sprite, x - sw/2, y - sh/2)
            end
        else
            love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
            love.graphics.circle("fill", x, y, 18)
        end
        return
    end

    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if enemy.animationManager and enemy.animationId then
        offsetX, offsetY, rotation, scaleX, scaleY = AnimationManager.getTransform(enemy.animationManager, enemy.animationId)
    end

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", x + offsetX, y + offsetY + 35, 20 * scaleX, 8)

    love.graphics.push()
    love.graphics.translate(x + offsetX, y + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)

    if Enemy.hasSprite(enemy) and state.assetManager then
        local sprite = Enemy.getSprite(enemy, "south")
        if sprite then
            love.graphics.setColor(1, 1, 1, 1)
            local sw, sh = sprite:getDimensions()
            love.graphics.draw(sprite, -sw/2, -sh/2)
        end
    else
        love.graphics.setColor(enemy.color)
        love.graphics.circle("fill", 0, 0, 18)

        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", -6, -4, 3)
        love.graphics.circle("fill", 6, -4, 3)
    end

    love.graphics.pop()

    if isSelected then
        love.graphics.setColor(state.colors.selected)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", x + offsetX, y + offsetY, 25)
        love.graphics.setLineWidth(1)
    end

    BattlePanels.drawHPBar(state.colors, enemy, x + offsetX - 30, y + offsetY - 35, 60, 6)
    
    if Enemy.hasSprite(enemy) then
        love.graphics.setColor(1, 1, 1)
        local font = love.graphics.getFont()
        local name = enemy.name
        local nameWidth = font:getWidth(name)
        love.graphics.print(name, x + offsetX - nameWidth/2, y + offsetY + 30)
    end
end

function BattleUI.drawTurnIndicator(state, battleState, x, y)
    local text = ""
    local color = state.colors.text
    
    if battleState == "intro" then
        text = "Battle Start!"
        color = state.colors.selected
    elseif battleState == "player" then
        text = "Your Turn"
        color = {0.2, 0.8, 1.0}
    elseif battleState == "enemy" or battleState == "executing" then
        text = "Enemy Turn"
        color = {1.0, 0.3, 0.3}
    elseif battleState == "victory" then
        text = "Victory!"
        color = {0.2, 1.0, 0.3}
    elseif battleState == "defeat" then
        text = "Defeat..."
        color = {0.8, 0.2, 0.2}
    elseif battleState == "escaped" then
        text = "Escaped!"
        color = {0.9, 0.9, 0.2}
    end
    
    love.graphics.setColor(color)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    love.graphics.print(text, x - textWidth / 2, y)
end

function BattleUI.selectAction(state, index)
    state.selectedAction = index
end

function BattleUI.selectEnemy(state, index)
    state.selectedEnemy = index
end

function BattleUI.getSelectedAction(state)
    return state.actions[state.selectedAction].key
end

function BattleUI.getSelectedEnemy(state)
    return state.selectedEnemy
end

function BattleUI.navigateUp(state)
    state.selectedAction = math.max(1, state.selectedAction - 1)
end

function BattleUI.navigateDown(state)
    state.selectedAction = math.min(#state.actions, state.selectedAction + 1)
end

function BattleUI.navigateLeft(state)
    if state.selectedEnemy > 1 then
        state.selectedEnemy = state.selectedEnemy - 1
    end
end

function BattleUI.navigateRight(state, maxEnemies)
    if state.selectedEnemy < maxEnemies then
        state.selectedEnemy = state.selectedEnemy + 1
    end
end

function BattleUI.setSelectedEnemy(state, index)
    state.selectedEnemy = index
end

function BattleUI.mousepressed(state, x, y, button, battleSystem)
    return BattleMenu.mousepressed(state, x, y, button, battleSystem)
end

function BattleUI.drawSkillSelectPanel(state, battleSystem, w, h)
    local panelW, panelH = 400, 300
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2
    
    Components.drawOrnatePanel(panelX, panelY, panelW, panelH, state.assetManager, {title="Select Skill", corners=true, glow=true})
    
    local skills = state.availableSkills
    if #skills == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.printf("No skills available", panelX, panelY + panelH/2, panelW, "center")
    else
        local itemH = 60
        local startY = panelY + 40
        local listH = panelH - 80
        
        for i, skillInfo in ipairs(skills) do
            local itemY = startY + (i - 1) * itemH
            if itemY + itemH > panelY + panelH - 40 then break end
            
            local isSelected = (i == state.selectedSkillIndex)
            local skill = skillInfo.data
            
            if isSelected then
                Components.drawOrnatePanel(panelX + 10, itemY, panelW - 20, itemH - 5, state.assetManager, {
                    corners = false,
                    glow = true,
                    borderColor = Theme.colors.borderBright,
                    glowIntensity = 0.15
                })
            end
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(string.format("%s Lv.%d", skill.name, skillInfo.level), panelX + 20, itemY + 5)
            
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.print(skill.description, panelX + 20, itemY + 22)
            
            local mpColor = (battleSystem.player and battleSystem.player.mp >= skill.mpCost) and {0.4, 0.7, 1.0} or {1.0, 0.4, 0.4}
            love.graphics.setColor(mpColor)
            love.graphics.print(string.format("MP: %d", skill.mpCost), panelX + panelW - 80, itemY + 5)
            
            love.graphics.setColor(0.6, 0.8, 0.6)
            local effectText = ""
            if skill.damageMultiplier then
                effectText = string.format("DMG: %d%%", skillInfo.effectiveDamage * 100)
            elseif skill.healPercent then
                effectText = string.format("HEAL: %d%%HP", skillInfo.effectiveHeal * 100)
            end
            love.graphics.print(effectText, panelX + 20, itemY + 39)
        end
    end
    
    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.printf("↑↓ Select  Enter Confirm  ESC Cancel", panelX, panelY + panelH - 25, panelW, "center")
end

function BattleUI.enterSkillMode(state, battleSystem)
    state.skillSelectMode = true
    state.selectedSkillIndex = 1
    state.availableSkills = BattleSystem.getAvailableSkills(battleSystem)
end

function BattleUI.exitSkillMode(state)
    state.skillSelectMode = false
    state.selectedSkillIndex = 1
end

function BattleUI.isSkillMode(state)
    return state.skillSelectMode
end

function BattleUI.navigateSkillUp(state)
    state.selectedSkillIndex = math.max(1, state.selectedSkillIndex - 1)
end

function BattleUI.navigateSkillDown(state)
    state.selectedSkillIndex = math.min(#state.availableSkills, state.selectedSkillIndex + 1)
end

function BattleUI.getSelectedSkill(state)
    if #state.availableSkills == 0 then return nil end
    local skillInfo = state.availableSkills[state.selectedSkillIndex]
    return skillInfo and skillInfo.id
end

return BattleUI
