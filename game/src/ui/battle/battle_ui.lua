-- battle_ui.lua - Battle UI rendering
-- Displays battle scene, HP bars, action menu, and battle log

local BattleBackground = require("src.ui.battle.battle_background")
local BattleMenu = require("src.ui.battle.battle_menu")
local BattlePanels = require("src.ui.battle.battle_panels")

local BattleUI = {}
BattleUI.__index = BattleUI

function BattleUI.new(assetManager)
    local self = setmetatable({}, BattleUI)

    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    self.assetManager = assetManager

    self.actions = {
        {name = "Attack", key = "attack"},
        {name = "Defend", key = "defend"},
        {name = "Item", key = "item"},
        {name = "Escape", key = "escape"},
        {name = "Auto", key = "auto"}
    }
    self.selectedAction = 1
    self.selectedEnemy = 1

    self.menuX = 0
    self.menuY = 0
    self.menuWidth = 200
    self.menuHeight = 0
    
    self.colors = {
        background = {0.1, 0.1, 0.15, 0.95},
        panel = {0.2, 0.2, 0.25, 0.9},
        text = {1, 1, 1},
        hpGreen = {0.2, 0.8, 0.3},
        hpYellow = {0.9, 0.9, 0.2},
        hpRed = {0.9, 0.2, 0.2},
        selected = {1, 0.8, 0.2}
    }
    
    return self
end

-- Draw battle scene
function BattleUI:draw(battleSystem, player)
    local w = self.screenWidth
    local h = self.screenHeight
    
    -- Draw diagonal gradient background (bottom-left to top-right)
    BattleBackground.draw(w, h)

    -- Draw player (right bottom corner)
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
    
    -- Draw UI panels
    BattlePanels.drawPlayerPanel(self.colors, player, 20, h - 180)

    -- Draw action menu centered vertically
    local menuHeight = 40 + #self.actions * 30
    local menuY = (h - menuHeight) / 2
    BattleMenu.draw(self, battleSystem, w - 220, menuY)

    BattlePanels.drawBattleLog(self.colors, battleSystem, 20, 20)

    -- Draw turn timer
    BattleMenu.drawTimer(battleSystem, w / 2 - 100, 20)
    
    -- Draw turn indicator
    local state = battleSystem:getState()
    self:drawTurnIndicator(state, w / 2, 30)

    -- Draw animations
    local animation = battleSystem:getAnimation()
    if animation then
        animation:draw()
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

return BattleUI

