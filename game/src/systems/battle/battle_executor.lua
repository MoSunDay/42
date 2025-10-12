-- battle_executor.lua - Battle action execution
-- Handles execution of player and enemy actions

local BattleExecutor = {}

-- Execute player attack action
function BattleExecutor.executePlayerAttack(battleSystem, target, targetIndex)
    local w, h = love.graphics.getDimensions()
    local playerX, playerY = w * 0.75, h * 0.7

    -- Diagonal positioning: left-bottom to right-top
    local baseX = w * 0.2
    local baseY = h * 0.6  -- Fixed: was w * 0.6, should be h * 0.6
    local targetX = baseX + (targetIndex - 1) * 100
    local targetY = baseY - (targetIndex - 1) * 80
    
    -- Play attack sound
    if battleSystem.audioSystem then
        battleSystem.audioSystem:playSFX("attack")
    end
    
    battleSystem.animation:addAttackAnimation(playerX, playerY, targetX, targetY, function()
        local damage = battleSystem.player:calculateDamage()
        local actualDamage = target:takeDamage(damage)
        
        -- Add damage number and flash
        battleSystem.animation:addDamageNumber(targetX, targetY - 30, actualDamage, false)
        battleSystem.animation:addHitFlash(targetX, targetY)
        
        -- Play hit sound
        if battleSystem.audioSystem then
            battleSystem.audioSystem:playSFX("hit")
        end
        
        battleSystem:addLog("You attack " .. target.name .. " for " .. actualDamage .. " damage!")
        
        if not target:isAlive() then
            battleSystem:addLog(target.name .. " defeated!")
        end
    end)
end

-- Execute player defend action
function BattleExecutor.executePlayerDefend(battleSystem)
    battleSystem.player.isDefending = true
    battleSystem:addLog("You take a defensive stance!")
end

-- Execute player escape action
function BattleExecutor.executePlayerEscape(battleSystem, battleState)
    -- 50% chance to escape
    if math.random() < 0.5 then
        battleSystem:addLog("You escaped successfully!")
        battleSystem:endBattle(battleState.ESCAPED)
        return true
    else
        battleSystem:addLog("Failed to escape!")
        return false
    end
end

-- Execute enemy attack
function BattleExecutor.executeEnemyAttack(battleSystem, enemy, enemyIndex)
    local w, h = love.graphics.getDimensions()
    local playerX, playerY = w * 0.75, h * 0.7
    
    -- Diagonal positioning for enemy
    local baseX = w * 0.2
    local baseY = h * 0.6
    local enemyX = baseX + (enemyIndex - 1) * 100
    local enemyY = baseY - (enemyIndex - 1) * 80
    
    -- Play attack sound
    if battleSystem.audioSystem then
        battleSystem.audioSystem:playSFX("attack")
    end
    
    battleSystem.animation:addAttackAnimation(enemyX, enemyY, playerX, playerY, function()
        local damage = enemy:calculateDamage()
        local actualDamage = battleSystem.player:takeDamage(damage)
        
        -- Add damage number and flash
        battleSystem.animation:addDamageNumber(playerX, playerY - 30, actualDamage, true)
        battleSystem.animation:addHitFlash(playerX, playerY)
        
        -- Play hit sound
        if battleSystem.audioSystem then
            battleSystem.audioSystem:playSFX("hit")
        end
        
        battleSystem:addLog(enemy.name .. " attacks you for " .. actualDamage .. " damage!")
        
        if not battleSystem.player:isAlive() then
            battleSystem:addLog("You have been defeated!")
        end
    end)
end

-- Execute enemy defend
function BattleExecutor.executeEnemyDefend(battleSystem, enemy)
    enemy.isDefending = true
    battleSystem:addLog(enemy.name .. " takes a defensive stance!")
end

return BattleExecutor

