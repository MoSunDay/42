-- battle_system.lua - Turn-based battle system
-- Manages battle flow, turns, and combat logic

local Enemy = require("entities.enemy")
local BattleAnimation = require("systems.battle_animation")
local BattleLog = require("src.systems.battle_log")
local BattleAI = require("src.systems.battle_ai")

local BattleSystem = {}
BattleSystem.__index = BattleSystem

-- Battle states
local BATTLE_STATE = {
    INTRO = "intro",           -- Battle start animation
    PLAYER_TURN = "player",    -- Player choosing action
    ENEMY_TURN = "enemy",      -- Enemy AI choosing
    EXECUTING = "executing",   -- Executing actions
    VICTORY = "victory",       -- Player won
    DEFEAT = "defeat",         -- Player lost
    ESCAPED = "escaped"        -- Player escaped
}

function BattleSystem.new(player, audioSystem, animationManager)
    local self = setmetatable({}, BattleSystem)

    self.player = player
    self.enemies = {}
    self.state = BATTLE_STATE.INTRO
    self.turn = 1
    self.selectedAction = nil
    self.selectedTarget = nil
    self.battleLog = BattleLog.new()
    self.introTimer = 0
    self.actionTimer = 0
    self.isActive = false
    self.autoBattle = false  -- Auto battle mode

    -- Auto battle mode
    self.autoBattle = false

    -- Animation system
    self.animation = BattleAnimation.new()

    -- Audio system
    self.audioSystem = audioSystem

    -- Animation manager for breathing effects
    self.animationManager = animationManager

    return self
end

-- Start a new battle
function BattleSystem:startBattle(enemyCount)
    enemyCount = enemyCount or 1

    -- Generate enemies
    self.enemies = {}
    for i = 1, math.min(enemyCount, 3) do
        local enemyType = Enemy.getRandomType()
        local enemy = Enemy.new(enemyType)

        -- Set animation for enemy
        if self.animationManager then
            enemy:setAnimationManager(self.animationManager, "enemy_" .. i)
        end

        table.insert(self.enemies, enemy)
    end
    
    -- Reset battle state
    self.state = BATTLE_STATE.INTRO
    self.turn = 1
    self.battleLog:clear()
    self.introTimer = 1.5  -- 1.5 second intro
    self.isActive = true
    
    self:addLog("Battle started!")
    self:addLog("Encountered " .. #self.enemies .. " enemy(ies)!")
    
    return true
end

-- End battle
function BattleSystem:endBattle(result)
    self.isActive = false
    self.state = result
    
    if result == BATTLE_STATE.VICTORY then
        -- Calculate rewards
        local totalExp = 0
        local totalGold = 0
        
        for _, enemy in ipairs(self.enemies) do
            totalExp = totalExp + enemy.exp
            totalGold = totalGold + enemy.gold
        end
        
        self:addLog("Victory!")
        self:addLog("Gained " .. totalExp .. " EXP and " .. totalGold .. " Gold!")
        
        return {exp = totalExp, gold = totalGold}
    elseif result == BATTLE_STATE.DEFEAT then
        self:addLog("Defeat...")
    elseif result == BATTLE_STATE.ESCAPED then
        self:addLog("Escaped successfully!")
    end
    
    return nil
end

-- Update battle
function BattleSystem:update(dt)
    if not self.isActive then
        return
    end

    -- Update animations
    self.animation:update(dt)

    -- Update enemy breathing animations
    if self.animationManager then
        for i, enemy in ipairs(self.enemies) do
            if enemy:isAlive() and enemy.animationId then
                self.animationManager:updateEntity(enemy.animationId, dt, false)
            end
        end
    end

    if self.state == BATTLE_STATE.INTRO then
        self.introTimer = self.introTimer - dt
        if self.introTimer <= 0 then
            self.state = BATTLE_STATE.PLAYER_TURN
            -- Auto execute if auto battle is on
            if self.autoBattle then
                self:autoExecutePlayerAction()
            end
        end
    elseif self.state == BATTLE_STATE.EXECUTING then
        -- Wait for animations to finish
        if not self.animation:isPlaying() then
            self.actionTimer = self.actionTimer - dt
            if self.actionTimer <= 0 then
                self:nextTurn()
            end
        end
    elseif self.state == BATTLE_STATE.ENEMY_TURN then
        -- Wait for animations to finish
        if not self.animation:isPlaying() then
            self.actionTimer = self.actionTimer - dt
            if self.actionTimer <= 0 then
                -- Check if there are more enemies to attack
                if self.currentEnemyIndex and self.currentEnemyIndex < #self.enemies then
                    self:executeNextEnemyAttack()
                else
                    -- All enemies finished, go to next turn
                    self:nextTurn()
                end
            end
        end
    end
end

-- Player selects action
function BattleSystem:selectAction(action, targetIndex)
    if self.state ~= BATTLE_STATE.PLAYER_TURN then
        return false
    end
    
    self.selectedAction = action
    self.selectedTarget = targetIndex
    
    -- Execute player action
    self:executePlayerAction()
    
    return true
end

-- Execute player's action
function BattleSystem:executePlayerAction()
    self.state = BATTLE_STATE.EXECUTING
    self.actionTimer = 1.0

    local action = self.selectedAction

    -- Find the target enemy (make sure it's alive)
    local targetIndex = self.selectedTarget or 1
    local target = self.enemies[targetIndex]

    -- If target is dead, find first alive enemy
    if target and not target:isAlive() then
        target = nil
        for i, enemy in ipairs(self.enemies) do
            if enemy:isAlive() then
                target = enemy
                targetIndex = i
                self.selectedTarget = i
                break
            end
        end
    end

    if action == "attack" then
        if target and target:isAlive() then
            -- Add attack animation
            local w, h = love.graphics.getDimensions()
            local playerX, playerY = w * 0.75, h * 0.7
            -- Diagonal positioning: left-bottom to right-top
            local baseX = w * 0.2
            local baseY = h * 0.6
            local targetX = baseX + (targetIndex - 1) * 100
            local targetY = baseY - (targetIndex - 1) * 80

            -- Play attack sound
            if self.audioSystem then
                self.audioSystem:playSFX("attack")
            end

            self.animation:addAttackAnimation(playerX, playerY, targetX, targetY, function()
                local damage = self.player:calculateDamage()
                local actualDamage = target:takeDamage(damage)

                -- Add damage number and flash
                self.animation:addDamageNumber(targetX, targetY - 30, actualDamage, false)
                self.animation:addHitFlash(targetX, targetY)

                -- Play hit sound
                if self.audioSystem then
                    self.audioSystem:playSFX("hit")
                end

                self:addLog("You attack " .. target.name .. " for " .. actualDamage .. " damage!")

                if not target:isAlive() then
                    self:addLog(target.name .. " defeated!")
                end
            end)
        end
    elseif action == "defend" then
        self.player.isDefending = true
        self:addLog("You take a defensive stance!")
    elseif action == "escape" then
        -- 50% chance to escape
        if math.random() < 0.5 then
            self:endBattle(BATTLE_STATE.ESCAPED)
            return
        else
            self:addLog("Failed to escape!")
        end
    end
    
    -- Check if all enemies defeated
    if self:checkVictory() then
        self:endBattle(BATTLE_STATE.VICTORY)
        return
    end
end

-- Execute enemy turn (start with first enemy)
function BattleSystem:executeEnemyTurn()
    self.state = BATTLE_STATE.ENEMY_TURN
    self.currentEnemyIndex = 0
    self:executeNextEnemyAttack()
end

-- Execute next enemy's attack
function BattleSystem:executeNextEnemyAttack()
    -- Find next alive enemy
    self.currentEnemyIndex = self.currentEnemyIndex + 1

    while self.currentEnemyIndex <= #self.enemies do
        local enemy = self.enemies[self.currentEnemyIndex]

        if enemy:isAlive() then
            -- Found an alive enemy, execute their action
            self.actionTimer = 0.8  -- Delay between enemy attacks
            local action = BattleAI.enemyAction(enemy, self.player)

            if action == "attack" then
                -- Add enemy attack animation
                local w, h = love.graphics.getDimensions()
                -- Diagonal positioning: left-bottom to right-top
                local baseX = w * 0.2
                local baseY = h * 0.6
                local enemyX = baseX + (self.currentEnemyIndex - 1) * 100
                local enemyY = baseY - (self.currentEnemyIndex - 1) * 80
                local playerX, playerY = w * 0.75, h * 0.7

                -- Play attack sound
                if self.audioSystem then
                    self.audioSystem:playSFX("attack")
                end

                self.animation:addAttackAnimation(enemyX, enemyY, playerX, playerY, function()
                    local damage = enemy:calculateDamage()
                    local actualDamage = self.player:takeDamage(damage)

                    -- Add damage number and flash
                    self.animation:addDamageNumber(playerX, playerY - 30, actualDamage, false)
                    self.animation:addHitFlash(playerX, playerY)

                    -- Play hit sound
                    if self.audioSystem then
                        self.audioSystem:playSFX("hit")
                    end

                    self:addLog(enemy.name .. " attacks you for " .. actualDamage .. " damage!")

                    -- Check if player defeated
                    if not self.player:isAlive() then
                        self:endBattle(BATTLE_STATE.DEFEAT)
                    end
                end)
            elseif action == "defend" then
                enemy.isDefending = true
                self:addLog(enemy.name .. " takes a defensive stance!")
            end

            return  -- Wait for this enemy's animation to finish
        end

        -- This enemy is dead, try next one
        self.currentEnemyIndex = self.currentEnemyIndex + 1
    end

    -- No more enemies, go to next turn
    self.actionTimer = 0.5
end

-- Next turn
function BattleSystem:nextTurn()
    -- Reset defending status
    self.player.isDefending = false
    for _, enemy in ipairs(self.enemies) do
        enemy.isDefending = false
    end

    -- Switch to enemy turn
    if self.state == BATTLE_STATE.EXECUTING then
        -- Check if all enemies defeated after player action
        if self:checkVictory() then
            self:endBattle(BATTLE_STATE.VICTORY)
            return
        end

        self:executeEnemyTurn()
    elseif self.state == BATTLE_STATE.ENEMY_TURN then
        -- Enemy turn finished, back to player turn
        self.turn = self.turn + 1
        self.state = BATTLE_STATE.PLAYER_TURN

        -- Auto execute if auto battle is on
        if self.autoBattle then
            self:autoExecutePlayerAction()
        end

        -- Check if player defeated
        if not self.player:isAlive() then
            self:endBattle(BATTLE_STATE.DEFEAT)
            return
        end
    end
end

-- Check victory condition
function BattleSystem:checkVictory()
    for _, enemy in ipairs(self.enemies) do
        if enemy:isAlive() then
            return false
        end
    end
    return true
end

-- Add to battle log
function BattleSystem:addLog(message)
    self.battleLog:add(message)
end

-- Get battle state
function BattleSystem:getState()
    return self.state
end

-- Get battle log
function BattleSystem:getLog()
    return self.battleLog:getMessages()
end

-- Get enemies
function BattleSystem:getEnemies()
    return self.enemies
end

-- Get alive enemies
function BattleSystem:getAliveEnemies()
    local alive = {}
    for _, enemy in ipairs(self.enemies) do
        if enemy:isAlive() then
            table.insert(alive, enemy)
        end
    end
    return alive
end

-- Get animation system
function BattleSystem:getAnimation()
    return self.animation
end

-- Toggle auto battle
function BattleSystem:toggleAutoBattle()
    self.autoBattle = not self.autoBattle
    if self.autoBattle then
        self:addLog("Auto battle enabled!")
        -- If currently player's turn, auto execute
        if self.state == BATTLE_STATE.PLAYER_TURN then
            self:autoExecutePlayerAction()
        end
    else
        self:addLog("Auto battle disabled!")
    end
    return self.autoBattle
end

-- Check if auto battle is on
function BattleSystem:isAutoBattle()
    return self.autoBattle
end

-- Auto execute player action (simple AI)
function BattleSystem:autoExecutePlayerAction()
    if self.state ~= BATTLE_STATE.PLAYER_TURN then
        return
    end

    local action, target = BattleAI.autoPlayerAction(self)
    if action and target then
        self.selectedAction = action
        self.selectedTarget = target
        self:executePlayerAction()
    end
end

-- Get animation manager
function BattleSystem:getAnimationManager()
    return self.animationManager
end

-- Export battle states
BattleSystem.STATE = BATTLE_STATE

return BattleSystem

