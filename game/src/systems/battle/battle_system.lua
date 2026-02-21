-- battle_system.lua - Turn-based battle system
-- Manages battle flow, turns, and combat logic

local Enemy = require("entities.enemy")
local BattleAnimation = require("src.systems.battle.battle_animation")
local BattleLog = require("src.systems.battle.battle_log")
local BattleAI = require("src.systems.battle.battle_ai")
local BattleUtils = require("src.systems.battle.battle_utils")
local BattleState = require("src.systems.battle.battle_state")
local BattleTimer = require("src.systems.battle.battle_timer")
local BattleExecutor = require("src.systems.battle.battle_executor")
local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")

local BattleSystem = {}
BattleSystem.__index = BattleSystem

-- Use imported battle states
local BATTLE_STATE = BattleState

function BattleSystem.new(player, audioSystem, animationManager, assetManager, companionSystem)
    local self = setmetatable({}, BattleSystem)

    self.player = player
    self.companionSystem = companionSystem
    self.enemies = {}
    self.state = BATTLE_STATE.INTRO
    self.turn = 1
    self.selectedAction = nil
    self.selectedTarget = nil
    self.battleLog = BattleLog.new()
    self.introTimer = 0
    self.actionTimer = 0
    self.isActive = false
    self.autoBattle = false

    self.timer = BattleTimer.new(90.0)

    self.animation = BattleAnimation.new()

    self.audioSystem = audioSystem

    self.animationManager = animationManager
    
    self.assetManager = assetManager

    return self
end

function BattleSystem:getPartySize()
    local size = 1
    if self.companionSystem then
        size = size + self.companionSystem:getPartySize()
    end
    return size
end

-- Start a new battle
function BattleSystem:startBattle(enemyCount)
    enemyCount = enemyCount or 1
    
    local partySize = self:getPartySize()

    -- Generate enemies
    self.enemies = {}
    for i = 1, math.min(enemyCount, 3) do
        local enemyType = Enemy.getRandomType()
        local enemy = Enemy.new(enemyType, self.assetManager)
        
        enemy:scaleForPartySize(partySize)

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
        local totalGold = 0
        local allCrystals = {}
        
        for _, enemy in ipairs(self.enemies) do
            totalGold = totalGold + enemy.gold
            
            local preferredType = SpiritCrystalSystem.getPreferredCrystalType(enemy)
            local drops = SpiritCrystalSystem.generateDrop(enemy.tier, preferredType)
            for _, drop in ipairs(drops) do
                table.insert(allCrystals, drop)
            end
            
            local bonusDrops = enemy.crystalBonus or 0
            for i = 1, bonusDrops do
                local bonusDrop = SpiritCrystalSystem.generateDrop(enemy.tier, preferredType)
                if #bonusDrop > 0 then
                    table.insert(allCrystals, bonusDrop[1])
                end
            end
        end
        
        self:addLog("Victory!")
        self:addLog("Gained " .. totalGold .. " Gold!")
        if #allCrystals > 0 then
            self:addLog("Obtained " .. #allCrystals .. " Spirit Crystal(s)!")
        end
        
        return {gold = totalGold, crystals = allCrystals}
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
            self.timer:reset()  -- Reset turn timer
            -- Auto execute if auto battle is on
            if self.autoBattle then
                self:autoExecutePlayerAction()
            end
        end
    elseif self.state == BATTLE_STATE.PLAYER_TURN then
        -- Update turn timer
        if not self.autoBattle then
            local timeUp = self.timer:update(dt)
            if timeUp then
                -- Time's up! Auto-execute defend action
                self:addLog("Time's up! Defending automatically...")
                self:selectAction("defend", nil)
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
            BattleExecutor.executePlayerAttack(self, target, targetIndex)
        end
    elseif action == "defend" then
        BattleExecutor.executePlayerDefend(self)
    elseif action == "escape" then
        if BattleExecutor.executePlayerEscape(self, BATTLE_STATE) then
            return  -- Successfully escaped
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
                BattleExecutor.executeEnemyAttack(self, enemy, self.currentEnemyIndex)
            elseif action == "defend" then
                BattleExecutor.executeEnemyDefend(self, enemy)
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

        -- Reset turn timer for new turn
        self.timer:reset()

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
    return BattleUtils.checkVictory(self.enemies)
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
    return BattleUtils.getAliveEnemies(self.enemies)
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

-- Get turn timer
function BattleSystem:getTurnTimer()
    return self.timer:getTime()
end

-- Get max turn time
function BattleSystem:getMaxTurnTime()
    return self.timer:getMaxTime()
end

-- Check if auto was triggered by timeout
function BattleSystem:isAutoTriggeredByTimeout()
    return self.timer:isAutoTriggered()
end

-- Export battle states
BattleSystem.STATE = BATTLE_STATE

return BattleSystem

