-- battle_ui.lua - Battle UI rendering
-- Displays battle scene, HP bars, action menu, and battle log

local BattleBackground = require("src.ui.battle.battle_background")
local BattleMenu = require("src.ui.battle.battle_menu")
local BattlePanels = require("src.ui.battle.battle_panels")
local Theme = require("src.ui.theme")

local BattleUI = {}
BattleUI.__index = BattleUI

function BattleUI.new(assetManager)
    local self = setmetatable({}, BattleUI)

    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    self.assetManager = assetManager

    self.actions = {
        {name = "Attack", key = "attack"},
        {name = "Skill", key = "skill"},
        {name = "Defend", key = "defend"},
        {name = "Item", key = "item"},
        {name = "Escape", key = "escape"},
        {name = "Auto", key = "auto"}
    }
    self.selectedAction = 1
    self.selectedEnemy = 1
    
    self.skillSelectMode = false
    self.selectedSkillIndex = 1
    self.availableSkills = {}

    self.menuX = 0
    self.menuY = 0
    self.menuWidth = 200
    self.menuHeight = 0
    
    self.colors = {
        background = Theme.colors.battle.background,
        panel = Theme.colors.battle.playerPanel,
        text = Theme.colors.text,
        hpGreen = Theme.colors.hp.high,
        hpYellow = Theme.colors.hp.medium,
        hpRed = Theme.colors.hp.low,
        selected = Theme.colors.battle.enemySelected
    }
    
    return self
end

function BattleUI:draw(battleSystem, player, map)
    local w = self.screenWidth
    local h = self.screenHeight
    
    local mapType = BattleBackground.getMapType(map)
    local bgImage = self.assetManager:getBattleBackground(mapType)
    
    if bgImage then
        local scaleX = w / bgImage:getWidth()
        local scaleY = h / bgImage:getHeight()
        love.graphics.draw(bgImage, 0, 0, 0, scaleX, scaleY)
    else
        BattleBackground.draw(w, h, mapType)
    end

    self:drawPlayer(player, w * 0.75, h * 0.7, battleSystem:getAnimationManager())

    -- Draw enemies (left top area)
    local enemies = battleSystem:getEnemies()
    local enemyCount = #enemies

    -- Auto-adjust selected enemy if current one is dead
    if enemies[self.selectedEnemy] and not enemies[self.selectedEnemy]:isAlive() then
        -- Find next alive enemy
        for i, enemy in ipairs(enemies) do
            if enemy:isAlive() then
                self.selectedEnemy = i
                break
            end
        end
    end

    -- Draw enemies diagonally from bottom-left to top-right
    for i, enemy in ipairs(enemies) do
        -- Diagonal positioning: left-bottom to right-top
        local baseX = w * 0.2
        local baseY = h * 0.6
        local x = baseX + (i - 1) * 100  -- Move right
        local y = baseY - (i - 1) * 80   -- Move up
        self:drawEnemy(enemy, x, y, i == self.selectedEnemy)
    end
    
    BattlePanels.drawPlayerPanel(self.colors, player, 20, h - 180, self.assetManager)

    local menuHeight = 40 + #self.actions * 30
    local menuY = (h - menuHeight) / 2
    BattleMenu.draw(self, battleSystem, w - 220, menuY)

    BattlePanels.drawBattleLog(self.colors, battleSystem, 20, 20, self.assetManager)

    BattleMenu.drawTimer(battleSystem, w / 2 - 100, 20, self.assetManager)
    
    -- Draw turn indicator
    local state = battleSystem:getState()
    self:drawTurnIndicator(state, w / 2, 30)

    -- Draw animations
    local animation = battleSystem:getAnimation()
    if animation then
        animation:draw()
    end
    
    -- Draw skill selection panel if in skill mode
    if self.skillSelectMode then
        self:drawSkillSelectPanel(battleSystem, w, h)
    end
end

-- Draw player character
function BattleUI:drawPlayer(player, x, y, animationManager)
    -- Get character avatar color
    local AccountManager = require("account.account_manager")
    local character = AccountManager.getCurrentCharacter()
    local avatarColor = character and character.avatarColor or {0.2, 0.6, 1.0}

    -- Get animation transform
    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if animationManager and player.animationId then
        offsetX, offsetY, rotation, scaleX, scaleY = animationManager:getTransform(player.animationId)
    end

    -- Apply transform
    love.graphics.push()
    love.graphics.translate(x + offsetX, y + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)

    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", 0, 40, 25, 10)

    -- Draw player (use avatar color)
    love.graphics.setColor(avatarColor)
    love.graphics.circle("fill", 0, 0, 20)

    -- Draw direction indicator
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", 0, -10, 4)

    -- Draw border
    love.graphics.setColor(avatarColor[1] * 0.5, avatarColor[2] * 0.5, avatarColor[3] * 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", 0, 0, 20)
    love.graphics.setLineWidth(1)

    love.graphics.pop()
end

-- Draw enemy
function BattleUI:drawEnemy(enemy, x, y, isSelected)
    if not enemy:isAlive() then
        if enemy:hasSprite() and self.assetManager then
            local sprite = enemy:getSprite("south")
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
        offsetX, offsetY, rotation, scaleX, scaleY = enemy.animationManager:getTransform(enemy.animationId)
    end

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", x + offsetX, y + offsetY + 35, 20 * scaleX, 8)

    love.graphics.push()
    love.graphics.translate(x + offsetX, y + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)

    if enemy:hasSprite() and self.assetManager then
        local sprite = enemy:getSprite("south")
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
        love.graphics.setColor(self.colors.selected)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", x + offsetX, y + offsetY, 25)
        love.graphics.setLineWidth(1)
    end

    BattlePanels.drawHPBar(self.colors, enemy, x + offsetX - 30, y + offsetY - 35, 60, 6)
    
    if enemy:hasSprite() then
        love.graphics.setColor(1, 1, 1)
        local font = love.graphics.getFont()
        local name = enemy.name
        local nameWidth = font:getWidth(name)
        love.graphics.print(name, x + offsetX - nameWidth/2, y + offsetY + 30)
    end
end

-- (drawHPBar, drawPlayerPanel, drawActionMenu, drawBattleLog moved to BattlePanels and BattleMenu modules)

-- (Methods moved to BattlePanels and BattleMenu modules)

-- Draw turn indicator
function BattleUI:drawTurnIndicator(state, x, y)
    local text = ""
    local color = self.colors.text
    
    if state == "intro" then
        text = "Battle Start!"
        color = self.colors.selected
    elseif state == "player" then
        text = "Your Turn"
        color = {0.2, 0.8, 1.0}
    elseif state == "enemy" or state == "executing" then
        text = "Enemy Turn"
        color = {1.0, 0.3, 0.3}
    elseif state == "victory" then
        text = "Victory!"
        color = {0.2, 1.0, 0.3}
    elseif state == "defeat" then
        text = "Defeat..."
        color = {0.8, 0.2, 0.2}
    elseif state == "escaped" then
        text = "Escaped!"
        color = {0.9, 0.9, 0.2}
    end
    
    love.graphics.setColor(color)
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    love.graphics.print(text, x - textWidth / 2, y)
end

-- Select action
function BattleUI:selectAction(index)
    self.selectedAction = index
end

-- Select enemy
function BattleUI:selectEnemy(index)
    self.selectedEnemy = index
end

-- Get selected action
function BattleUI:getSelectedAction()
    return self.actions[self.selectedAction].key
end

-- Get selected enemy
function BattleUI:getSelectedEnemy()
    return self.selectedEnemy
end

-- Navigate menu
function BattleUI:navigateUp()
    self.selectedAction = math.max(1, self.selectedAction - 1)
end

function BattleUI:navigateDown()
    self.selectedAction = math.min(#self.actions, self.selectedAction + 1)
end

function BattleUI:navigateLeft()
    if self.selectedEnemy > 1 then
        self.selectedEnemy = self.selectedEnemy - 1
    end
end

function BattleUI:navigateRight(maxEnemies)
    if self.selectedEnemy < maxEnemies then
        self.selectedEnemy = self.selectedEnemy + 1
    end
end

-- Set selected enemy (for mouse click)
function BattleUI:setSelectedEnemy(index)
    self.selectedEnemy = index
end

-- Handle mouse click on action menu (delegated to BattleMenu)
function BattleUI:mousepressed(x, y, button, battleSystem)
    return BattleMenu.mousepressed(self, x, y, button, battleSystem)
end

-- Draw skill selection panel
function BattleUI:drawSkillSelectPanel(battleSystem, w, h)
    local panelW, panelH = 400, 300
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2
    
    love.graphics.setColor(0.1, 0.1, 0.15, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 10, 10)
    love.graphics.setColor(0.4, 0.5, 0.7)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 10, 10)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Select Skill", panelX, panelY + 10, panelW, "center")
    
    local skills = self.availableSkills
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
            
            local isSelected = (i == self.selectedSkillIndex)
            local skill = skillInfo.data
            
            if isSelected then
                love.graphics.setColor(0.3, 0.4, 0.6, 0.8)
                love.graphics.rectangle("fill", panelX + 10, itemY, panelW - 20, itemH - 5, 5, 5)
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
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("↑↓ Select  Enter Confirm  ESC Cancel", panelX, panelY + panelH - 25, panelW, "center")
end

-- Enter skill select mode
function BattleUI:enterSkillMode(battleSystem)
    self.skillSelectMode = true
    self.selectedSkillIndex = 1
    self.availableSkills = battleSystem:getAvailableSkills()
end

-- Exit skill select mode
function BattleUI:exitSkillMode()
    self.skillSelectMode = false
    self.selectedSkillIndex = 1
end

-- Check if in skill mode
function BattleUI:isSkillMode()
    return self.skillSelectMode
end

-- Navigate skill list
function BattleUI:navigateSkillUp()
    self.selectedSkillIndex = math.max(1, self.selectedSkillIndex - 1)
end

function BattleUI:navigateSkillDown()
    self.selectedSkillIndex = math.min(#self.availableSkills, self.selectedSkillIndex + 1)
end

-- Get selected skill
function BattleUI:getSelectedSkill()
    if #self.availableSkills == 0 then return nil end
    local skillInfo = self.availableSkills[self.selectedSkillIndex]
    return skillInfo and skillInfo.id
end

return BattleUI

