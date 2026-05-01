-- battle_executor.lua - Battle action execution
-- Handles execution of player and enemy actions with new damage formula

local SkillSystem = require("src.systems.skill_system")
local SkillDatabase = require("src.data.skill_database")

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

function BattleExecutor.executePlayerSkill(battleSystem, skillId, targets, targetIndices)
    local player = battleSystem.player
    local canUse, result = SkillSystem.canUseSkill(player, skillId)
    
    if not canUse then
        battleSystem:addLog(result)
        return false
    end
    
    local success, skillResult = SkillSystem.useSkill(player, skillId)
    if not success then
        battleSystem:addLog(skillResult)
        return false
    end
    
    local skillData = skillResult.skillData
    local skillLevel = skillResult.level
    
    if battleSystem.audioSystem then
        battleSystem.audioSystem:playSFX("skill")
    end
    
    if skillData.type == SkillDatabase.TYPES.HEAL then
        return BattleExecutor.executeHealSkill(battleSystem, skillData, skillLevel)
    elseif skillData.type == SkillDatabase.TYPES.SEAL then
        return BattleExecutor.executeSealSkill(battleSystem, skillData, skillLevel, targets, targetIndices)
    else
        return BattleExecutor.executeDamageSkill(battleSystem, skillData, skillLevel, targets, targetIndices)
    end
end

function BattleExecutor.executeDamageSkill(battleSystem, skillData, skillLevel, targets, targetIndices)
    local w, h = love.graphics.getDimensions()
    local playerX, playerY = w * 0.75, h * 0.7
    
    local baseX = w * 0.2
    local baseY = h * 0.6
    
    local player = battleSystem.player
    local damageMultiplier = SkillDatabase.getEffectiveDamage(skillData, skillLevel)
    
    local useMagic = skillData.useClass == "magic"
    local attackStat = useMagic and player.magicAttack or player.attack
    
    local totalDamage = 0
    local targetCount = #targets
    
    battleSystem:addLog(string.format("%s Lv.%d!", skillData.name, skillLevel))
    
    for i, target in ipairs(targets) do
        local targetIndex = targetIndices[i]
        local targetX = baseX + (targetIndex - 1) * 100
        local targetY = baseY - (targetIndex - 1) * 80
        
        battleSystem.animation:addAttackAnimation(playerX, playerY, targetX, targetY, function()
            if target:checkEvade() then
                battleSystem.animation:addDamageNumber(targetX, targetY - 30, 0, false, "miss")
                battleSystem:addLog(target.name .. " evaded!")
                return
            end
            
            local baseDamage = attackStat * damageMultiplier * (0.9 + math.random() * 0.2)
            
            local isCrit = false
            local critChance = (player.critBonus or 0) + (skillData.critBonus or 0)
            if critChance > 0 and math.random() < critChance then
                baseDamage = baseDamage * 1.5
                isCrit = true
            end
            
            local actualDamage = target:takeDamage(baseDamage)
            totalDamage = totalDamage + actualDamage
            
            local hitType = isCrit and "crit" or "normal"
            battleSystem.animation:addDamageNumber(targetX, targetY - 30, actualDamage, false, hitType)
            battleSystem.animation:addHitFlash(targetX, targetY)
            
            if battleSystem.audioSystem then
                battleSystem.audioSystem:playSFX("hit")
            end
            
            local critText = isCrit and " CRITICAL!" or ""
            battleSystem:addLog(string.format("%s takes %d damage!%s", target.name, actualDamage, critText))
            
            if skillData.defBreak then
                target.defense = target.defense * (1 - skillData.defBreak)
                battleSystem:addLog(target.name .. "'s defense reduced!")
            end
            
            if skillData.debuff then
                target.skillDebuff = target.skillDebuff or {}
                table.insert(target.skillDebuff, {
                    type = skillData.debuff.type or "slow",
                    value = skillData.debuff.speedPercent or 0,
                    duration = skillData.debuff.duration or 2
                })
                battleSystem:addLog(target.name .. " is slowed!")
            end
            
            if skillData.stunChance and math.random() < skillData.stunChance then
                target.stunned = true
                battleSystem:addLog(target.name .. " is stunned!")
            end
            
            if skillData.dot then
                target.skillDot = {
                    type = skillData.dot.type,
                    damage = skillData.dot.damage,
                    duration = skillData.dot.duration
                }
                battleSystem:addLog(target.name .. " is burning!")
            end
            
            if not target:isAlive() then
                battleSystem:addLog(target.name .. " defeated!")
            end
        end)
    end
    
    if skillData.selfBuff then
        local buff = skillData.selfBuff
        player.skillBuffs = player.skillBuffs or {}
        table.insert(player.skillBuffs, {
            speedPercent = buff.speedPercent or 0,
            defensePercent = buff.defensePercent or 0,
            duration = buff.duration or 1
        })
        
        if buff.speedPercent and buff.speedPercent > 0 then
            battleSystem:addLog(string.format("Your speed increased by %d%%!", buff.speedPercent * 100))
        end
        if buff.defensePercent and buff.defensePercent > 0 then
            battleSystem:addLog(string.format("Your defense increased by %d%%!", buff.defensePercent * 100))
        end
    end
    
    return true
end

function BattleExecutor.executeHealSkill(battleSystem, skillData, skillLevel)
    local player = battleSystem.player
    local healPercent = SkillDatabase.getEffectiveHealPercent(skillData, skillLevel)
    
    local healAmount = math.floor(player.maxHp * healPercent)
    player:heal(healAmount)
    
    if skillData.cleanse and player.debuffs then
        player.debuffs = {}
        battleSystem:addLog("All debuffs cleansed!")
    end
    
    battleSystem:addLog(string.format("%s Lv.%d! Healed %d HP!", skillData.name, skillLevel, healAmount))
    
    if battleSystem.audioSystem then
        battleSystem.audioSystem:playSFX("skill")
    end
    
    return true
end

function BattleExecutor.executeSealSkill(battleSystem, skillData, skillLevel, targets, targetIndices)
    if not targets or #targets == 0 then
        battleSystem:addLog("No target for seal!")
        return false
    end
    
    local target = targets[1]
    local sealType = skillData.sealType
    local duration = skillData.sealDuration
    
    target.sealed = target.sealed or {}
    target.sealed[sealType] = {
        duration = duration,
        source = "player"
    }
    
    local sealName = {
        bind = "bound",
        silence = "silenced",
        confusion = "confused"
    }
    
    battleSystem:addLog(string.format("%s Lv.%d! %s is %s for %d turns!", 
        skillData.name, skillLevel, target.name, sealName[sealType] or "sealed", duration))
    
    if battleSystem.audioSystem then
        battleSystem.audioSystem:playSFX("skill")
    end
    
    return true
end

function BattleExecutor.selectSkillTargets(battleSystem, skillId)
    local skillData = SkillDatabase.getSkill(skillId)
    if not skillData then return {} end
    
    local enemies = battleSystem.enemies
    local aliveEnemies = {}
    for i, enemy in ipairs(enemies) do
        if enemy:isAlive() then
            table.insert(aliveEnemies, {enemy = enemy, index = i})
        end
    end
    
    if #aliveEnemies == 0 then return {}, {} end
    
    if skillData.targets == "self" or skillData.targets == "all_allies" then
        return {}, {}
    end
    
    local minTargets, maxTargets = SkillDatabase.getTargetCount(skillData)
    local numTargets = math.min(maxTargets, #aliveEnemies)
    numTargets = math.max(minTargets, numTargets)
    
    for i = #aliveEnemies, 2, -1 do
        local j = math.random(i)
        aliveEnemies[i], aliveEnemies[j] = aliveEnemies[j], aliveEnemies[i]
    end
    
    local selectedTargets = {}
    local selectedIndices = {}
    for i = 1, numTargets do
        table.insert(selectedTargets, aliveEnemies[i].enemy)
        table.insert(selectedIndices, aliveEnemies[i].index)
    end
    
    return selectedTargets, selectedIndices
end

return BattleExecutor
