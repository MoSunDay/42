-- battle_executor.lua - Battle action execution
-- Handles execution of player and enemy actions with new damage formula

local SkillSystem = require("src.systems.skill_system")
local SkillDatabase = require("src.data.skill_database")
local CombatUtils = require("src.systems.combat_utils")
local AudioSystem = require("src.systems.audio_system")
local BattleAnimation = require("src.systems.battle.battle_animation")
local BattleLog = require("src.systems.battle.battle_log")
local Enemy = require("src.entities.enemy")
local Player = require("src.entities.player")

local BattleSystem = nil
local function get_battle_system()
    if not BattleSystem then
        BattleSystem = require("src.systems.battle.battle_system")
    end
    return BattleSystem
end

local BattleExecutor = {}

function BattleExecutor.execute_player_attack(battleSystem, target, targetIndex)
    local w, h = love.graphics.getDimensions()
    local playerX, playerY = w * 0.75, h * 0.7

    local baseX = w * 0.2
    local baseY = h * 0.6
    local targetX = baseX + (targetIndex - 1) * 100
    local targetY = baseY - (targetIndex - 1) * 80
    
    if battleSystem.audioSystem then
        AudioSystem.play_sfx(battleSystem.audioSystem, "attack")
    end
    
    BattleAnimation.add_attack_animation(battleSystem.animation, playerX, playerY, targetX, targetY, function()
        if CombatUtils.check_evade(target) then
            BattleAnimation.add_damage_number(battleSystem.animation, targetX, targetY - 30, 0, false, "miss")
            get_battle_system().add_log(battleSystem, target.name .. " evaded your attack!")
            return
        end
        
        local damage, isCrit = Player.calculate_damage(battleSystem.player)
        local actualDamage = CombatUtils.take_damageMutating(target, damage)
        
        local hitType = isCrit and "crit" or "normal"
        BattleAnimation.add_damage_number(battleSystem.animation, targetX, targetY - 30, actualDamage, false, hitType)
        BattleAnimation.add_hit_flash(battleSystem.animation, targetX, targetY)
        
        if battleSystem.audioSystem then
            AudioSystem.play_sfx(battleSystem.audioSystem, "hit")
        end
        
        local critText = isCrit and " CRITICAL!" or ""
        get_battle_system().add_log(battleSystem, "You attack " .. target.name .. " for " .. actualDamage .. " damage!" .. critText)
        
        if not CombatUtils.is_alive(target) then
            get_battle_system().add_log(battleSystem, target.name .. " defeated!")
        end
    end)
end

function BattleExecutor.execute_player_defend(battleSystem)
    battleSystem.player.isDefending = true
    get_battle_system().add_log(battleSystem, "You take a defensive stance! (+25% DEF)")
end

function BattleExecutor.execute_player_escape(battleSystem, battleState)
    local escapeChance = 0.5 + (battleSystem.player.battleSpeed or 6) * 0.02
    escapeChance = math.min(0.8, escapeChance)
    
    if math.random() < escapeChance then
        get_battle_system().add_log(battleSystem, "You escaped successfully!")
        get_battle_system().end_battle(battleSystem, battleState.ESCAPED)
        return true
    else
        get_battle_system().add_log(battleSystem, "Failed to escape!")
        return false
    end
end

function BattleExecutor.execute_enemy_attack(battleSystem, enemy, enemyIndex)
    local w, h = love.graphics.getDimensions()
    local playerX, playerY = w * 0.75, h * 0.7
    
    local baseX = w * 0.2
    local baseY = h * 0.6
    local enemyX = baseX + (enemyIndex - 1) * 100
    local enemyY = baseY - (enemyIndex - 1) * 80
    
    if battleSystem.audioSystem then
        AudioSystem.play_sfx(battleSystem.audioSystem, "attack")
    end
    
    BattleAnimation.add_attack_animation(battleSystem.animation, enemyX, enemyY, playerX, playerY, function()
        if Player.check_evade(battleSystem.player) then
            BattleAnimation.add_damage_number(battleSystem.animation, playerX, playerY - 30, 0, true, "miss")
            get_battle_system().add_log(battleSystem, "You evaded " .. enemy.name .. "'s attack!")
            return
        end
        
        local damage, isCrit = Enemy.calculate_damage(enemy)
        local actualDamage = Player.take_damage(battleSystem.player, damage)
        
        local hitType = isCrit and "crit" or "normal"
        BattleAnimation.add_damage_number(battleSystem.animation, playerX, playerY - 30, actualDamage, true, hitType)
        BattleAnimation.add_hit_flash(battleSystem.animation, playerX, playerY)
        
        if battleSystem.audioSystem then
            AudioSystem.play_sfx(battleSystem.audioSystem, "hit")
        end
        
        local critText = isCrit and " CRITICAL!" or ""
        get_battle_system().add_log(battleSystem, enemy.name .. " attacks you for " .. actualDamage .. " damage!" .. critText)
        
        if not Player.is_alive(battleSystem.player) then
            get_battle_system().add_log(battleSystem, "You have been defeated!")
        end
    end)
end

function BattleExecutor.execute_enemy_defend(battleSystem, enemy)
    enemy.isDefending = true
    get_battle_system().add_log(battleSystem, enemy.name .. " takes a defensive stance!")
end

function BattleExecutor.execute_player_skill(battleSystem, skillId, targets, targetIndices)
    local player = battleSystem.player
    local canUse, result = SkillSystem.can_use_skill(player, skillId)
    
    if not canUse then
        get_battle_system().add_log(battleSystem, result)
        return false
    end
    
    local success, skillResult = SkillSystem.use_skill(player, skillId)
    if not success then
        get_battle_system().add_log(battleSystem, skillResult)
        return false
    end
    
    local skillData = skillResult.skillData
    local skillLevel = skillResult.level
    
    if battleSystem.audioSystem then
        AudioSystem.play_sfx(battleSystem.audioSystem, "skill")
    end
    
    if skillData.type == SkillDatabase.TYPES.HEAL then
        return BattleExecutor.execute_heal_skill(battleSystem, skillData, skillLevel)
    elseif skillData.type == SkillDatabase.TYPES.SEAL then
        return BattleExecutor.execute_seal_skill(battleSystem, skillData, skillLevel, targets, targetIndices)
    else
        return BattleExecutor.execute_damage_skill(battleSystem, skillData, skillLevel, targets, targetIndices)
    end
end

function BattleExecutor.execute_damage_skill(battleSystem, skillData, skillLevel, targets, targetIndices)
    local w, h = love.graphics.getDimensions()
    local playerX, playerY = w * 0.75, h * 0.7
    
    local baseX = w * 0.2
    local baseY = h * 0.6
    
    local player = battleSystem.player
    local damageMultiplier = SkillDatabase.get_effective_damage(skillData, skillLevel)
    
    local useMagic = skillData.useClass == "magic"
    local attackStat = useMagic and player.magicAttack or player.attack
    
    local totalDamage = 0
    local targetCount = #targets
    
    get_battle_system().add_log(battleSystem, string.format("%s Lv.%d!", skillData.name, skillLevel))
    
    for i, target in ipairs(targets) do
        local targetIndex = targetIndices[i]
        local targetX = baseX + (targetIndex - 1) * 100
        local targetY = baseY - (targetIndex - 1) * 80
        
        BattleAnimation.add_attack_animation(battleSystem.animation, playerX, playerY, targetX, targetY, function()
            if CombatUtils.check_evade(target) then
                BattleAnimation.add_damage_number(battleSystem.animation, targetX, targetY - 30, 0, false, "miss")
                get_battle_system().add_log(battleSystem, target.name .. " evaded!")
                return
            end
            
            local baseDamage = attackStat * damageMultiplier * (0.9 + math.random() * 0.2)
            
            local isCrit = false
            local critChance = (player.critBonus or 0) + (skillData.critBonus or 0)
            if critChance > 0 and math.random() < critChance then
                baseDamage = baseDamage * 1.5
                isCrit = true
            end
            
            local actualDamage = CombatUtils.take_damageMutating(target, baseDamage)
            totalDamage = totalDamage + actualDamage
            
            local hitType = isCrit and "crit" or "normal"
            BattleAnimation.add_damage_number(battleSystem.animation, targetX, targetY - 30, actualDamage, false, hitType)
            BattleAnimation.add_hit_flash(battleSystem.animation, targetX, targetY)
            
            if battleSystem.audioSystem then
                AudioSystem.play_sfx(battleSystem.audioSystem, "hit")
            end
            
            local critText = isCrit and " CRITICAL!" or ""
            get_battle_system().add_log(battleSystem, string.format("%s takes %d damage!%s", target.name, actualDamage, critText))
            
            if skillData.defBreak then
                target.defense = target.defense * (1 - skillData.defBreak)
                get_battle_system().add_log(battleSystem, target.name .. "'s defense reduced!")
            end
            
            if skillData.debuff then
                target.skillDebuff = target.skillDebuff or {}
                table.insert(target.skillDebuff, {
                    type = skillData.debuff.type or "slow",
                    value = skillData.debuff.speedPercent or 0,
                    duration = skillData.debuff.duration or 2
                })
                get_battle_system().add_log(battleSystem, target.name .. " is slowed!")
            end
            
            if skillData.stunChance and math.random() < skillData.stunChance then
                target.stunned = true
                get_battle_system().add_log(battleSystem, target.name .. " is stunned!")
            end
            
            if skillData.dot then
                target.skillDot = {
                    type = skillData.dot.type,
                    damage = skillData.dot.damage,
                    duration = skillData.dot.duration
                }
                get_battle_system().add_log(battleSystem, target.name .. " is burning!")
            end
            
            if not CombatUtils.is_alive(target) then
                get_battle_system().add_log(battleSystem, target.name .. " defeated!")
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
            get_battle_system().add_log(battleSystem, string.format("Your speed increased by %d%%!", buff.speedPercent * 100))
        end
        if buff.defensePercent and buff.defensePercent > 0 then
            get_battle_system().add_log(battleSystem, string.format("Your defense increased by %d%%!", buff.defensePercent * 100))
        end
    end
    
    return true
end

function BattleExecutor.execute_heal_skill(battleSystem, skillData, skillLevel)
    local player = battleSystem.player
    local healPercent = SkillDatabase.get_effective_heal_percent(skillData, skillLevel)
    
    local healAmount = math.floor(player.maxHp * healPercent)
    CombatUtils.healMutating(player, healAmount)
    
    if skillData.cleanse and player.debuffs then
        player.debuffs = {}
        get_battle_system().add_log(battleSystem, "All debuffs cleansed!")
    end
    
    get_battle_system().add_log(battleSystem, string.format("%s Lv.%d! Healed %d HP!", skillData.name, skillLevel, healAmount))
    
    if battleSystem.audioSystem then
        AudioSystem.play_sfx(battleSystem.audioSystem, "skill")
    end
    
    return true
end

function BattleExecutor.execute_seal_skill(battleSystem, skillData, skillLevel, targets, targetIndices)
    if not targets or #targets == 0 then
        get_battle_system().add_log(battleSystem, "No target for seal!")
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
    
    get_battle_system().add_log(battleSystem, string.format("%s Lv.%d! %s is %s for %d turns!", 
        skillData.name, skillLevel, target.name, sealName[sealType] or "sealed", duration))
    
    if battleSystem.audioSystem then
        AudioSystem.play_sfx(battleSystem.audioSystem, "skill")
    end
    
    return true
end

function BattleExecutor.select_skill_targets(battleSystem, skillId)
    local skillData = SkillDatabase.get_skill(skillId)
    if not skillData then return {} end
    
    local enemies = battleSystem.enemies
    local aliveEnemies = {}
    for i, enemy in ipairs(enemies) do
        if Enemy.is_alive(enemy) then
            table.insert(aliveEnemies, {enemy = enemy, index = i})
        end
    end
    
    if #aliveEnemies == 0 then return {}, {} end
    
    if skillData.targets == "self" or skillData.targets == "all_allies" then
        return {}, {}
    end
    
    local minTargets, maxTargets = SkillDatabase.get_target_count(skillData)
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
