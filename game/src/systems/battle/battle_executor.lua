-- battle_executor.lua - Battle action execution
-- Handles execution of player and enemy actions with new damage formula

local BattleExecutor = {}

function BattleExecutor.executePlayerAttack(battleSystem, target, targetIndex)
    local w, h = love.graphics.getDimensions()
    local playerX, playerY = w * 0.75, h * 0.7

    local baseX = w * 0.2
    local baseY = h * 0.6
    local targetX = baseX + (targetIndex - 1) * 100
    local targetY = baseY - (targetIndex - 1) * 80
    
    if battleSystem.audioSystem then
        battleSystem.audioSystem:playSFX("attack")
    end
    
    battleSystem.animation:addAttackAnimation(playerX, playerY, targetX, targetY, function()
        if target:checkEvade() then
            battleSystem.animation:addDamageNumber(targetX, targetY - 30, 0, false, "miss")
            battleSystem:addLog(target.name .. " evaded your attack!")
            return
        end
        
        local damage, isCrit = battleSystem.player:calculateDamage()
        local actualDamage = target:takeDamage(damage)
        
        local hitType = isCrit and "crit" or "normal"
        battleSystem.animation:addDamageNumber(targetX, targetY - 30, actualDamage, false, hitType)
        battleSystem.animation:addHitFlash(targetX, targetY)
        
        if battleSystem.audioSystem then
            battleSystem.audioSystem:playSFX("hit")
        end
        
        local critText = isCrit and " CRITICAL!" or ""
        battleSystem:addLog("You attack " .. target.name .. " for " .. actualDamage .. " damage!" .. critText)
        
        if not target:isAlive() then
            battleSystem:addLog(target.name .. " defeated!")
        end
    end)
end

function BattleExecutor.executePlayerDefend(battleSystem)
    battleSystem.player.isDefending = true
    battleSystem:addLog("You take a defensive stance! (+25% DEF)")
end

function BattleExecutor.executePlayerEscape(battleSystem, battleState)
    local escapeChance = 0.5 + (battleSystem.player.battleSpeed or 6) * 0.02
    escapeChance = math.min(0.8, escapeChance)
    
    if math.random() < escapeChance then
        battleSystem:addLog("You escaped successfully!")
        battleSystem:endBattle(battleState.ESCAPED)
        return true
    else
        battleSystem:addLog("Failed to escape!")
        return false
    end
end

function BattleExecutor.executeEnemyAttack(battleSystem, enemy, enemyIndex)
    local w, h = love.graphics.getDimensions()
    local playerX, playerY = w * 0.75, h * 0.7
    
    local baseX = w * 0.2
    local baseY = h * 0.6
    local enemyX = baseX + (enemyIndex - 1) * 100
    local enemyY = baseY - (enemyIndex - 1) * 80
    
    if battleSystem.audioSystem then
        battleSystem.audioSystem:playSFX("attack")
    end
    
    battleSystem.animation:addAttackAnimation(enemyX, enemyY, playerX, playerY, function()
        if battleSystem.player:checkEvade() then
            battleSystem.animation:addDamageNumber(playerX, playerY - 30, 0, true, "miss")
            battleSystem:addLog("You evaded " .. enemy.name .. "'s attack!")
            return
        end
        
        local damage, isCrit = enemy:calculateDamage()
        local actualDamage = battleSystem.player:takeDamage(damage)
        
        local hitType = isCrit and "crit" or "normal"
        battleSystem.animation:addDamageNumber(playerX, playerY - 30, actualDamage, true, hitType)
        battleSystem.animation:addHitFlash(playerX, playerY)
        
        if battleSystem.audioSystem then
            battleSystem.audioSystem:playSFX("hit")
        end
        
        local critText = isCrit and " CRITICAL!" or ""
        battleSystem:addLog(enemy.name .. " attacks you for " .. actualDamage .. " damage!" .. critText)
        
        if not battleSystem.player:isAlive() then
            battleSystem:addLog("You have been defeated!")
        end
    end)
end

function BattleExecutor.executeEnemyDefend(battleSystem, enemy)
    enemy.isDefending = true
    battleSystem:addLog(enemy.name .. " takes a defensive stance!")
end

return BattleExecutor
