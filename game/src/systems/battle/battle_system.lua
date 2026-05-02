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
        isActive = false,
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

function BattleSystem.getPartySize(state)
    local size = 1
    if state.companionSystem then
        size = size + state.companionSystem:getPartySize()
    end
    return size
end

function BattleSystem.startBattle(state, enemyCount)
    enemyCount = enemyCount or 1

    local partySize = BattleSystem.getPartySize(state)

    state.enemies = {}
    for i = 1, math.min(enemyCount, 3) do
        local enemyType = Enemy.getRandomType()
        local enemy = Enemy.create(enemyType, state.assetManager)

        Enemy.scaleForPartySize(enemy, partySize)

        if state.animationManager then
            Enemy.setAnimationManager(enemy, state.animationManager, "enemy_" .. i)
        end

        table.insert(state.enemies, enemy)
    end

    state.state = BATTLE_STATE.INTRO
    state.turn = 1
    BattleLog.clear(state.battleLog)
    state.introTimer = 1.5
    state.isActive = true

    BattleSystem.addLog(state, "Battle started!")
    BattleSystem.addLog(state, "Encountered " .. #state.enemies .. " enemy(ies)!")

    return true
end

function BattleSystem.endBattle(state, result)
    state.isActive = false
    state.state = result

    if result == BATTLE_STATE.VICTORY then
        local allCrystals = {}

        for _, enemy in ipairs(state.enemies) do
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

        BattleSystem.addLog(state, "Victory!")
        if #allCrystals > 0 then
            BattleSystem.addLog(state, "Obtained " .. #allCrystals .. " Spirit Crystal(s)!")
        end

        return {crystals = allCrystals}
    elseif result == BATTLE_STATE.DEFEAT then
        BattleSystem.addLog(state, "Defeat...")
    elseif result == BATTLE_STATE.ESCAPED then
        BattleSystem.addLog(state, "Escaped successfully!")
    end

    return nil
end

function BattleSystem.update(state, dt)
    if not state.isActive then
        return
    end

    BattleAnimation.update(state.animation, dt)

    if state.animationManager then
        for i, enemy in ipairs(state.enemies) do
            if Enemy.isAlive(enemy) and enemy.animationId then
                AnimationManager.updateEntity(state.animationManager, enemy.animationId, dt, false)
            end
        end
    end

    if state.state == BATTLE_STATE.INTRO then
        state.introTimer = state.introTimer - dt
        if state.introTimer <= 0 then
            state.state = BATTLE_STATE.PLAYER_TURN
            BattleTimer.reset(state.timer)
            if state.autoBattle then
                BattleSystem.autoExecutePlayerAction(state)
            end
        end
    elseif state.state == BATTLE_STATE.PLAYER_TURN then
        if not state.autoBattle then
            local timeUp = BattleTimer.update(state.timer, dt)
            if timeUp then
                BattleSystem.addLog(state, "Time's up! Defending automatically...")
                BattleSystem.selectAction(state, "defend", nil)
            end
        end
    elseif state.state == BATTLE_STATE.EXECUTING then
        if not BattleAnimation.isPlaying(state.animation) then
            state.actionTimer = state.actionTimer - dt
            if state.actionTimer <= 0 then
                BattleSystem.nextTurn(state)
            end
        end
    elseif state.state == BATTLE_STATE.ENEMY_TURN then
        if not BattleAnimation.isPlaying(state.animation) then
            state.actionTimer = state.actionTimer - dt
            if state.actionTimer <= 0 then
                if state.currentEnemyIndex and state.currentEnemyIndex < #state.enemies then
                    BattleSystem.executeNextEnemyAttack(state)
                else
                    BattleSystem.nextTurn(state)
                end
            end
        end
    end
end

function BattleSystem.selectAction(state, action, targetIndex)
    if state.state ~= BATTLE_STATE.PLAYER_TURN then
        return false
    end

    state.selectedAction = action
    state.selectedTarget = targetIndex

    BattleSystem.executePlayerAction(state)

    return true
end

function BattleSystem.executePlayerAction(state)
    state.state = BATTLE_STATE.EXECUTING
    state.actionTimer = 1.0

    local action = state.selectedAction

    local targetIndex = state.selectedTarget or 1
    local target = state.enemies[targetIndex]

    if target and not Enemy.isAlive(target) then
        target = nil
        for i, enemy in ipairs(state.enemies) do
            if Enemy.isAlive(enemy) then
                target = enemy
                targetIndex = i
                state.selectedTarget = i
                break
            end
        end
    end

    if action == "attack" then
        if target and Enemy.isAlive(target) then
            BattleExecutor.executePlayerAttack(state, target, targetIndex)
        end
    elseif action == "skill" then
        if state.selectedSkill then
            local targets, indices = BattleExecutor.selectSkillTargets(state, state.selectedSkill)
            if #targets > 0 then
                BattleExecutor.executePlayerSkill(state, state.selectedSkill, targets, indices)
            else
                local skillData = require("src.data.skill_database").getSkill(state.selectedSkill)
                if skillData and (skillData.targets == "self" or skillData.targets == "all_allies") then
                    BattleExecutor.executePlayerSkill(state, state.selectedSkill, {}, {})
                else
                    BattleSystem.addLog(state, "No valid target for skill!")
                    state.state = BATTLE_STATE.PLAYER_TURN
                end
            end
        end
    elseif action == "defend" then
        BattleExecutor.executePlayerDefend(state)
    elseif action == "escape" then
        if BattleExecutor.executePlayerEscape(state, BATTLE_STATE) then
            return
        end
    end

    if BattleSystem.checkVictory(state) then
        BattleSystem.endBattle(state, BATTLE_STATE.VICTORY)
        return
    end
end

function BattleSystem.executeEnemyTurn(state)
    state.state = BATTLE_STATE.ENEMY_TURN
    state.currentEnemyIndex = 0
    BattleSystem.executeNextEnemyAttack(state)
end

function BattleSystem.executeNextEnemyAttack(state)
    state.currentEnemyIndex = state.currentEnemyIndex + 1

    while state.currentEnemyIndex <= #state.enemies do
        local enemy = state.enemies[state.currentEnemyIndex]

        if Enemy.isAlive(enemy) then
            state.actionTimer = 0.8
            local action = BattleAI.enemyAction(enemy, state.player)

            if action == "attack" then
                BattleExecutor.executeEnemyAttack(state, enemy, state.currentEnemyIndex)
            elseif action == "defend" then
                BattleExecutor.executeEnemyDefend(state, enemy)
            end

            return
        end

        state.currentEnemyIndex = state.currentEnemyIndex + 1
    end

    state.actionTimer = 0.5
end

function BattleSystem.nextTurn(state)
    state.player.isDefending = false
    for _, enemy in ipairs(state.enemies) do
        enemy.isDefending = false
    end

    if state.state == BATTLE_STATE.EXECUTING then
        if BattleSystem.checkVictory(state) then
            BattleSystem.endBattle(state, BATTLE_STATE.VICTORY)
            return
        end

        BattleSystem.executeEnemyTurn(state)
    elseif state.state == BATTLE_STATE.ENEMY_TURN then
        state.turn = state.turn + 1
        state.state = BATTLE_STATE.PLAYER_TURN

        BattleTimer.reset(state.timer)

        if state.autoBattle then
            BattleSystem.autoExecutePlayerAction(state)
        end

        if not Player.isAlive(state.player) then
            BattleSystem.endBattle(state, BATTLE_STATE.DEFEAT)
            return
        end
    end
end

function BattleSystem.checkVictory(state)
    return BattleUtils.checkVictory(state.enemies)
end

function BattleSystem.addLog(state, message)
    BattleLog.add(state.battleLog, message)
end

function BattleSystem.getState(state)
    return state.state
end

function BattleSystem.getLog(state)
    return BattleLog.getMessages(state.battleLog)
end

function BattleSystem.getEnemies(state)
    return state.enemies
end

function BattleSystem.getAliveEnemies(state)
    return BattleUtils.getAliveEnemies(state.enemies)
end

function BattleSystem.getAnimation(state)
    return state.animation
end

function BattleSystem.toggleAutoBattle(state)
    state.autoBattle = not state.autoBattle
    if state.autoBattle then
        BattleSystem.addLog(state, "Auto battle enabled!")
        if state.state == BATTLE_STATE.PLAYER_TURN then
            BattleSystem.autoExecutePlayerAction(state)
        end
    else
        BattleSystem.addLog(state, "Auto battle disabled!")
    end
    return state.autoBattle
end

function BattleSystem.isAutoBattle(state)
    return state.autoBattle
end

function BattleSystem.autoExecutePlayerAction(state)
    if state.state ~= BATTLE_STATE.PLAYER_TURN then
        return
    end

    local action, target = BattleAI.autoPlayerAction(state)
    if action and target then
        state.selectedAction = action
        state.selectedTarget = target
        BattleSystem.executePlayerAction(state)
    end
end

function BattleSystem.getAnimationManager(state)
    return state.animationManager
end

function BattleSystem.getTurnTimer(state)
    return BattleTimer.getTime(state.timer)
end

function BattleSystem.getMaxTurnTime(state)
    return BattleTimer.getMaxTime(state.timer)
end

function BattleSystem.isAutoTriggeredByTimeout(state)
    return BattleTimer.isAutoTriggered(state.timer)
end

function BattleSystem.getAvailableSkills(state)
    if not state.player or not state.player.skills then
        return {}
    end
    return SkillSystem.getAvailableSkills(state.player)
end

function BattleSystem.selectSkill(state, skillId)
    state.selectedSkill = skillId
    state.skillMode = true
end

function BattleSystem.clearSkillSelection(state)
    state.selectedSkill = nil
    state.skillMode = false
end

function BattleSystem.isSkillMode(state)
    return state.skillMode
end

function BattleSystem.getSelectedSkill(state)
    return state.selectedSkill
end

BattleSystem.STATE = BATTLE_STATE

return BattleSystem
