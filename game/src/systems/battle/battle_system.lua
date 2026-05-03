local AnimationManager = require("src.animations.animation_manager")
local Enemy = require("entities.enemy")
local Player = require("entities.player")
local BattleAnimation = require("src.systems.battle.battle_animation")
local BattleLog = require("src.systems.battle.battle_log")
local BattleAI = require("src.systems.battle.battle_ai")
local BattleUtils = require("src.systems.battle.battle_utils")
local BattleState = require("src.systems.battle.battle_state")
local BattleTimer = require("src.systems.battle.battle_timer")
local BattleExecutor = require("src.systems.battle.battle_executor")
local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")
local SkillSystem = require("src.systems.skill_system")

local BattleSystem = {}

local BATTLE_STATE = BattleState

function BattleSystem.create(player, audioSystem, animationManager, assetManager, companionSystem)
    return {
        player = player,
        companionSystem = companionSystem,
        enemies = {},
        state = BATTLE_STATE.INTRO,
        turn = 1,
        selectedAction = nil,
        selectedTarget = nil,
        battleLog = BattleLog.create(),
        introTimer = 0,
        actionTimer = 0,
        is_active = false,
        autoBattle = false,
        skillMode = false,
        selectedSkill = nil,
        availableSkills = {},
        timer = BattleTimer.create(90.0),
        animation = BattleAnimation.create(),
        audioSystem = audioSystem,
        animationManager = animationManager,
        assetManager = assetManager,
    }
end

function BattleSystem.get_party_size(state)
    local size = 1
    if state.companionSystem then
        size = size + state.companionSystem:get_party_size()
    end
    return size
end

function BattleSystem.start_battle(state, enemyCount)
    enemyCount = enemyCount or 1

    local partySize = BattleSystem.get_party_size(state)

    state.enemies = {}
    for i = 1, math.min(enemyCount, 3) do
        local enemyType = Enemy.get_random_type()
        local enemy = Enemy.create(enemyType, state.assetManager)

        Enemy.scale_for_party_size(enemy, partySize)

        if state.animationManager then
            Enemy.set_animation_manager(enemy, state.animationManager, "enemy_" .. i)
        end

        table.insert(state.enemies, enemy)
    end

    state.state = BATTLE_STATE.INTRO
    state.turn = 1
    BattleLog.clear(state.battleLog)
    state.introTimer = 1.5
    state.is_active = true

    BattleSystem.add_log(state, "Battle started!")
    BattleSystem.add_log(state, "Encountered " .. #state.enemies .. " enemy(ies)!")

    return true
end

function BattleSystem.end_battle(state, result)
    state.is_active = false
    state.state = result

    if result == BATTLE_STATE.VICTORY then
        local allCrystals = {}

        for _, enemy in ipairs(state.enemies) do
            local preferredType = SpiritCrystalSystem.get_preferred_crystal_type(enemy)
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

        BattleSystem.add_log(state, "Victory!")
        if #allCrystals > 0 then
            BattleSystem.add_log(state, "Obtained " .. #allCrystals .. " Spirit Crystal(s)!")
        end

        return {crystals = allCrystals}
    elseif result == BATTLE_STATE.DEFEAT then
        BattleSystem.add_log(state, "Defeat...")
    elseif result == BATTLE_STATE.ESCAPED then
        BattleSystem.add_log(state, "Escaped successfully!")
    end

    return nil
end

function BattleSystem.update(state, dt)
    if not state.is_active then
        return
    end

    BattleAnimation.update(state.animation, dt)

    if state.animationManager then
        for i, enemy in ipairs(state.enemies) do
            if Enemy.is_alive(enemy) and enemy.animationId then
                AnimationManager.update_entity(state.animationManager, enemy.animationId, dt, false)
            end
        end
    end

    if state.state == BATTLE_STATE.INTRO then
        state.introTimer = state.introTimer - dt
        if state.introTimer <= 0 then
            state.state = BATTLE_STATE.PLAYER_TURN
            BattleTimer.reset(state.timer)
            if state.autoBattle then
                BattleSystem.auto_execute_player_action(state)
            end
        end
    elseif state.state == BATTLE_STATE.PLAYER_TURN then
        if not state.autoBattle then
            local timeUp = BattleTimer.update(state.timer, dt)
            if timeUp then
                BattleSystem.add_log(state, "Time's up! Defending automatically...")
                BattleSystem.select_action(state, "defend", nil)
            end
        end
    elseif state.state == BATTLE_STATE.EXECUTING then
        if not BattleAnimation.is_playing(state.animation) then
            state.actionTimer = state.actionTimer - dt
            if state.actionTimer <= 0 then
                BattleSystem.next_turn(state)
            end
        end
    elseif state.state == BATTLE_STATE.ENEMY_TURN then
        if not BattleAnimation.is_playing(state.animation) then
            state.actionTimer = state.actionTimer - dt
            if state.actionTimer <= 0 then
                if state.currentEnemyIndex and state.currentEnemyIndex < #state.enemies then
                    BattleSystem.execute_next_enemy_attack(state)
                else
                    BattleSystem.next_turn(state)
                end
            end
        end
    end
end

function BattleSystem.select_action(state, action, targetIndex)
    if state.state ~= BATTLE_STATE.PLAYER_TURN then
        return false
    end

    state.selectedAction = action
    state.selectedTarget = targetIndex

    BattleSystem.execute_player_action(state)

    return true
end

function BattleSystem.execute_player_action(state)
    state.state = BATTLE_STATE.EXECUTING
    state.actionTimer = 1.0

    local action = state.selectedAction

    local targetIndex = state.selectedTarget or 1
    local target = state.enemies[targetIndex]

    if target and not Enemy.is_alive(target) then
        target = nil
        for i, enemy in ipairs(state.enemies) do
            if Enemy.is_alive(enemy) then
                target = enemy
                targetIndex = i
                state.selectedTarget = i
                break
            end
        end
    end

    if action == "attack" then
        if target and Enemy.is_alive(target) then
            BattleExecutor.execute_player_attack(state, target, targetIndex)
        end
    elseif action == "skill" then
        if state.selectedSkill then
            local targets, indices = BattleExecutor.select_skill_targets(state, state.selectedSkill)
            if #targets > 0 then
                BattleExecutor.execute_player_skill(state, state.selectedSkill, targets, indices)
            else
                local skillData = require("src.data.skill_database").get_skill(state.selectedSkill)
                if skillData and (skillData.targets == "self" or skillData.targets == "all_allies") then
                    BattleExecutor.execute_player_skill(state, state.selectedSkill, {}, {})
                else
                    BattleSystem.add_log(state, "No valid target for skill!")
                    state.state = BATTLE_STATE.PLAYER_TURN
                end
            end
        end
    elseif action == "defend" then
        BattleExecutor.execute_player_defend(state)
    elseif action == "escape" then
        if BattleExecutor.execute_player_escape(state, BATTLE_STATE) then
            return
        end
    end

    if BattleSystem.check_victory(state) then
        BattleSystem.end_battle(state, BATTLE_STATE.VICTORY)
        return
    end
end

function BattleSystem.execute_enemy_turn(state)
    state.state = BATTLE_STATE.ENEMY_TURN
    state.currentEnemyIndex = 0
    BattleSystem.execute_next_enemy_attack(state)
end

function BattleSystem.execute_next_enemy_attack(state)
    state.currentEnemyIndex = state.currentEnemyIndex + 1

    while state.currentEnemyIndex <= #state.enemies do
        local enemy = state.enemies[state.currentEnemyIndex]

        if Enemy.is_alive(enemy) then
            state.actionTimer = 0.8
            local action = BattleAI.enemy_action(enemy, state.player)

            if action == "attack" then
                BattleExecutor.execute_enemy_attack(state, enemy, state.currentEnemyIndex)
            elseif action == "defend" then
                BattleExecutor.execute_enemy_defend(state, enemy)
            end

            return
        end

        state.currentEnemyIndex = state.currentEnemyIndex + 1
    end

    state.actionTimer = 0.5
end

function BattleSystem.next_turn(state)
    state.player.isDefending = false
    for _, enemy in ipairs(state.enemies) do
        enemy.isDefending = false
    end

    BattleSystem.process_status_effects(state)

    if state.state == BATTLE_STATE.EXECUTING then
        if BattleSystem.check_victory(state) then
            BattleSystem.end_battle(state, BATTLE_STATE.VICTORY)
            return
        end

        BattleSystem.execute_enemy_turn(state)
    elseif state.state == BATTLE_STATE.ENEMY_TURN then
        state.turn = state.turn + 1
        state.state = BATTLE_STATE.PLAYER_TURN

        BattleTimer.reset(state.timer)

        if state.autoBattle then
            BattleSystem.auto_execute_player_action(state)
        end

        if not Player.is_alive(state.player) then
            BattleSystem.end_battle(state, BATTLE_STATE.DEFEAT)
            return
        end
    end
end

function BattleSystem.process_status_effects(state)
    local player = state.player

    if player.skillDot then
        local dot = player.skillDot
        local dotDamage = math.floor(dot.damage or 0)
        if dotDamage > 0 then
            player.hp = math.max(0, player.hp - dotDamage)
            BattleSystem.add_log(state, string.format("You take %d damage from %s!", dotDamage, dot.type or "dot"))
        end
        dot.duration = dot.duration - 1
        if dot.duration <= 0 then
            player.skillDot = nil
        end
    end

    for _, enemy in ipairs(state.enemies) do
        if Enemy.is_alive(enemy) then
            if enemy.skillDot then
                local dot = enemy.skillDot
                local dotDamage = math.floor(dot.damage or 0)
                if dotDamage > 0 then
                    enemy.hp = math.max(0, enemy.hp - dotDamage)
                    BattleSystem.add_log(state, string.format("%s takes %d damage from %s!", enemy.name, dotDamage, dot.type or "dot"))
                end
                dot.duration = dot.duration - 1
                if dot.duration <= 0 then
                    enemy.skillDot = nil
                end
            end

            if enemy.skillDebuff then
                for i = #enemy.skillDebuff, 1, -1 do
                    local debuff = enemy.skillDebuff[i]
                    debuff.duration = debuff.duration - 1
                    if debuff.duration <= 0 then
                        table.remove(enemy.skillDebuff, i)
                    end
                end
                if #enemy.skillDebuff == 0 then
                    enemy.skillDebuff = nil
                end
            end

            if enemy.stunned then
                enemy.stunned = false
                BattleSystem.add_log(state, enemy.name .. " recovers from stun!")
            end

            if enemy.sealed then
                for sealType, sealData in pairs(enemy.sealed) do
                    sealData.duration = sealData.duration - 1
                    if sealData.duration <= 0 then
                        enemy.sealed[sealType] = nil
                        BattleSystem.add_log(state, enemy.name .. " breaks free from seal!")
                    end
                end
                local hasSeals = false
                for _ in pairs(enemy.sealed) do
                    hasSeals = true
                    break
                end
                if not hasSeals then
                    enemy.sealed = nil
                end
            end
        end
    end

    if player.skillBuffs then
        for i = #player.skillBuffs, 1, -1 do
            local buff = player.skillBuffs[i]
            buff.duration = buff.duration - 1
            if buff.duration <= 0 then
                table.remove(player.skillBuffs, i)
            end
        end
        if #player.skillBuffs == 0 then
            player.skillBuffs = nil
        end
    end
end

function BattleSystem.check_victory(state)
    return BattleUtils.check_victory(state.enemies)
end

function BattleSystem.add_log(state, message)
    BattleLog.add(state.battleLog, message)
end

function BattleSystem.get_state(state)
    return state.state
end

function BattleSystem.get_log(state)
    return BattleLog.get_messages(state.battleLog)
end

function BattleSystem.get_enemies(state)
    return state.enemies
end

function BattleSystem.get_alive_enemies(state)
    return BattleUtils.get_alive_enemies(state.enemies)
end

function BattleSystem.get_animation(state)
    return state.animation
end

function BattleSystem.toggle_auto_battle(state)
    state.autoBattle = not state.autoBattle
    if state.autoBattle then
        BattleSystem.add_log(state, "Auto battle enabled!")
        if state.state == BATTLE_STATE.PLAYER_TURN then
            BattleSystem.auto_execute_player_action(state)
        end
    else
        BattleSystem.add_log(state, "Auto battle disabled!")
    end
    return state.autoBattle
end

function BattleSystem.is_auto_battle(state)
    return state.autoBattle
end

function BattleSystem.auto_execute_player_action(state)
    if state.state ~= BATTLE_STATE.PLAYER_TURN then
        return
    end

    local action, target = BattleAI.auto_player_action(state)
    if action and target then
        state.selectedAction = action
        state.selectedTarget = target
        BattleSystem.execute_player_action(state)
    end
end

function BattleSystem.get_animation_manager(state)
    return state.animationManager
end

function BattleSystem.get_turn_timer(state)
    return BattleTimer.get_time(state.timer)
end

function BattleSystem.get_max_turn_time(state)
    return BattleTimer.get_max_time(state.timer)
end

function BattleSystem.is_auto_triggered_by_timeout(state)
    return BattleTimer.is_auto_triggered(state.timer)
end

function BattleSystem.get_available_skills(state)
    if not state.player or not state.player.skills then
        return {}
    end
    return SkillSystem.get_available_skills(state.player)
end

function BattleSystem.select_skill(state, skillId)
    state.selectedSkill = skillId
    state.skillMode = true
end

function BattleSystem.clear_skill_selection(state)
    state.selectedSkill = nil
    state.skillMode = false
end

function BattleSystem.is_skill_mode(state)
    return state.skillMode
end

function BattleSystem.get_selected_skill(state)
    return state.selectedSkill
end

BattleSystem.STATE = BATTLE_STATE

return BattleSystem
