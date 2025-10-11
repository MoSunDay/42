-- battle_ui.lua - Battle UI rendering
-- Displays battle scene, HP bars, action menu, and battle log

local BattleBackground = require("src.ui.battle_background")

local BattleUI = {}
BattleUI.__index = BattleUI

function BattleUI.new()
    local self = setmetatable({}, BattleUI)
    
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    -- Action menu
    self.actions = {
        {name = "Attack", key = "attack"},
        {name = "Defend", key = "defend"},
        {name = "Item", key = "item"},
        {name = "Escape", key = "escape"},
        {name = "Auto", key = "auto"}  -- Auto battle
    }
    self.selectedAction = 1
    self.selectedEnemy = 1
    
    -- UI colors
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
    self:drawPlayerPanel(player, 20, h - 180)
    self:drawActionMenu(battleSystem, w - 220, h - 180)
    self:drawBattleLog(battleSystem, 20, 20)
    
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
        -- Draw defeated enemy (faded)
        love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
        love.graphics.circle("fill", x, y, 18)
        return
    end

    -- Get animation transform
    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if enemy.animationManager and enemy.animationId then
        offsetX, offsetY, rotation, scaleX, scaleY = enemy.animationManager:getTransform(enemy.animationId)
    end

    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", x + offsetX, y + offsetY + 35, 20 * scaleX, 8)

    -- Apply transform for enemy body
    love.graphics.push()
    love.graphics.translate(x + offsetX, y + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)

    -- Draw enemy body
    love.graphics.setColor(enemy.color)
    love.graphics.circle("fill", 0, 0, 18)

    -- Draw eyes
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", -6, -4, 3)
    love.graphics.circle("fill", 6, -4, 3)

    love.graphics.pop()

    -- Draw selection indicator (not affected by breathing)
    if isSelected then
        love.graphics.setColor(self.colors.selected)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", x + offsetX, y + offsetY, 25)
        love.graphics.setLineWidth(1)
    end

    -- Draw HP bar above enemy
    self:drawHPBar(enemy, x + offsetX - 30, y + offsetY - 35, 60, 6)
end

-- Draw HP bar
function BattleUI:drawHPBar(entity, x, y, width, height)
    local hpPercent = entity:getHPPercent()
    
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- HP fill
    local color = self.colors.hpGreen
    if hpPercent < 0.3 then
        color = self.colors.hpRed
    elseif hpPercent < 0.6 then
        color = self.colors.hpYellow
    end
    
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, width * hpPercent, height)
    
    -- Border
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height)
end

-- Draw player panel
function BattleUI:drawPlayerPanel(player, x, y)
    -- Panel background
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", x, y, 300, 160, 5, 5)
    
    -- Player name
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Player", x + 10, y + 10)
    
    -- HP
    love.graphics.print("HP: " .. player.hp .. " / " .. player.maxHp, x + 10, y + 35)
    self:drawHPBar(player, x + 10, y + 55, 280, 15)
    
    -- Stats
    love.graphics.print("ATK: " .. player.attack, x + 10, y + 80)
    love.graphics.print("DEF: " .. player.defense, x + 120, y + 80)
    love.graphics.print("SPD: " .. player.speed, x + 230, y + 80)

    -- Gold
    love.graphics.print("Gold: " .. (player.gold or 0), x + 10, y + 105)
end

-- Draw action menu
function BattleUI:drawActionMenu(battleSystem, x, y)
    local state = battleSystem:getState()
    
    -- Only show during player turn
    if state ~= "player" then
        return
    end
    
    -- Panel background (dynamic height based on action count)
    local menuHeight = 40 + #self.actions * 30
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", x, y, 200, menuHeight, 5, 5)
    
    -- Title
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Actions", x + 10, y + 10)
    
    -- Action buttons
    for i, action in ipairs(self.actions) do
        local btnY = y + 30 + (i - 1) * 30

        -- Highlight selected
        if i == self.selectedAction then
            love.graphics.setColor(self.colors.selected)
            love.graphics.rectangle("fill", x + 5, btnY, 190, 25, 3, 3)
        end

        -- Action text
        love.graphics.setColor(self.colors.text)
        local actionText = action.name

        -- Show auto battle status
        if action.key == "auto" and battleSystem:isAutoBattle() then
            actionText = actionText .. " [ON]"
        end

        love.graphics.print(actionText, x + 15, btnY + 5)
    end
end

-- Draw battle log
function BattleUI:drawBattleLog(battleSystem, x, y)
    -- Panel background
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", x, y, 500, 150, 5, 5)
    
    -- Title
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Battle Log", x + 10, y + 10)
    
    -- Log messages
    local log = battleSystem:getLog()
    for i = math.max(1, #log - 5), #log do
        local msg = log[i]
        if msg then
            local logY = y + 30 + (i - math.max(1, #log - 5)) * 20
            love.graphics.print(msg, x + 10, logY)
        end
    end
end

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

return BattleUI

