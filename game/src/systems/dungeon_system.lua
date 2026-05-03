local DungeonSystem = {}

local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")

function DungeonSystem.create(player, spiritCrystalSystem)
    return {
        player = player,
        spiritCrystalSystem = spiritCrystalSystem or SpiritCrystalSystem.create(),
        currentDungeon = nil,
        currentAreaIndex = 0,
        clearedAreas = {},
        areaClearedFlags = {},
        dungeonClearHistory = {},
        currentWave = 0,
        wavesCleared = false,
        bossDefeated = false,
        enemies = {},
        currentBoss = nil,
        pendingDialogue = nil,
        pendingTutorial = nil,
        pendingRewards = nil,
        state = "idle",
        onDialogueCallback = nil,
        onTutorialCallback = nil,
        onRewardsCallback = nil,
        onDungeonCompleteCallback = nil,
        onAreaTransitionCallback = nil,
    }
end

function DungeonSystem.load_dungeon(state, dungeonId)
    local success, dungeonData = pcall(require, "map.maps." .. dungeonId)
    if not success or not dungeonData then
        return false
    end
    
    state.currentDungeon = dungeonData
    state.currentAreaIndex = 0
    state.clearedAreas = {}
    state.areaClearedFlags = {}
    state.currentWave = 0
    state.wavesCleared = false
    state.bossDefeated = false
    state.enemies = {}
    state.currentBoss = nil
    state.state = "loaded"
    
    return true
end

function DungeonSystem.start_dungeon(state)
    if not state.currentDungeon then return false end
    
    state.currentAreaIndex = state.currentDungeon.startArea or 1
    state.state = "active"
    
    local area = state.currentDungeon:getArea(state.currentAreaIndex)
    if area then
        DungeonSystem.setup_area(state, area)
    end
    
    return true
end

function DungeonSystem.setup_area(state, area)
    state.enemies = {}
    state.currentWave = 0
    state.wavesCleared = false
    state.currentBoss = nil
    
    if area.enemies then
        for _, enemyData in ipairs(area.enemies) do
            table.insert(state.enemies, DungeonSystem.create_enemy(state, enemyData))
        end
    end
    
    if area.waves then
        state.currentWave = 1
        local wave = area.waves[1]
        if wave and wave.enemies then
            for _, enemyData in ipairs(wave.enemies) do
                table.insert(state.enemies, DungeonSystem.create_enemy(state, enemyData))
            end
        end
    end
    
    if area.boss then
        state.currentBoss = DungeonSystem.create_boss(state, area.boss)
    end
    
    if area.dialogue and area.dialogue.onEnter then
        state.pendingDialogue = {
            speaker = area.dialogue.onEnter.speaker,
            text = area.dialogue.onEnter.text
        }
    end
    
    if area.tutorial and area.tutorial.triggerOnEnter then
        state.pendingTutorial = {
            tutorialId = area.tutorial.tutorialId,
            canSkip = area.tutorial.canSkip
        }
    end
end

function DungeonSystem.create_enemy(state, enemyData)
    local Enemy = require("src.entities.enemy")
    local enemy = Enemy.create(enemyData.type)
    
    enemy.x = enemyData.x
    enemy.y = enemyData.y
    
    if enemyData.weakened then
        enemy.hp = math.floor(enemy.hp * (enemyData.hpMultiplier or 0.7))
        enemy.maxHp = enemy.hp
        enemy.attack = math.floor(enemy.attack * (enemyData.hpMultiplier or 0.7))
    end
    
    return enemy
end

function DungeonSystem.create_boss(state, bossData)
    local BOSSES = require("npcs.bosses")
    local bossTemplate = BOSSES[bossData.id]
    
    if not bossTemplate then return nil end
    
    local boss = {
        id = bossData.id,
        type = "boss",
        name = bossTemplate.name,
        hp = bossTemplate.hp,
        maxHp = bossTemplate.maxHp,
        attack = bossTemplate.attack,
        defense = bossTemplate.defense,
        speed = bossTemplate.speed,
        crit = bossTemplate.crit or 5,
        eva = bossTemplate.eva or 3,
        tier = bossTemplate.tier or 1,
        color = bossTemplate.color,
        size = bossTemplate.size,
        x = bossData.x,
        y = bossData.y,
        abilities = bossTemplate.abilities,
        dialogue = bossTemplate.dialogue,
        isDefending = false
    }
    
    return boss
end

function DungeonSystem.area_cleared(state)
    if state.currentBoss and state.currentBoss.hp > 0 then
        return false
    end
    
    if #state.enemies > 0 then
        for _, enemy in ipairs(state.enemies) do
            if enemy.hp > 0 then
                return false
            end
        end
    end
    
    local area = state.currentDungeon:getArea(state.currentAreaIndex)
    if area and area.waves then
        if state.currentWave < #area.waves then
            return false
        end
    end
    
    return true
end

function DungeonSystem.check_area_progress(state)
    if not DungeonSystem.area_cleared(state) then return false end
    
    local areaIndex = state.currentAreaIndex
    if state.areaClearedFlags[areaIndex] then return false end
    
    state.areaClearedFlags[areaIndex] = true
    table.insert(state.clearedAreas, areaIndex)
    
    local area = state.currentDungeon:getArea(areaIndex)
    if area and area.rewards and area.rewards.firstClear then
        if not state.dungeonClearHistory[state.currentDungeon.id] then
            state.pendingRewards = area.rewards.firstClear
        end
    end
    
    if area and area.boss and state.currentBoss and state.currentBoss.hp <= 0 then
        state.bossDefeated = true
        if area.dialogue and area.dialogue.onBossDefeat then
            state.pendingDialogue = {
                speaker = area.dialogue.onBossDefeat.speaker,
                text = area.dialogue.onBossDefeat.text,
                isBossDefeat = true
            }
        end
        
        if area.onClear then
            state.state = "completed"
            if state.onDungeonCompleteCallback then
                state.onDungeonCompleteCallback(area.onClear)
            end
        end
    end
    
    return true
end

function DungeonSystem.advance_to_next_area(state)
    local nextAreaIndex = state.currentAreaIndex + 1
    if nextAreaIndex > state.currentDungeon:getAreaCount() then
        return false
    end
    
    state.currentAreaIndex = nextAreaIndex
    local area = state.currentDungeon:getArea(nextAreaIndex)
    if area then
        DungeonSystem.setup_area(state, area)
    end
    
    return true
end

function DungeonSystem.process_wave(state)
    local area = state.currentDungeon:getArea(state.currentAreaIndex)
    if not area or not area.waves then return false end
    
    if state.currentWave < #area.waves then
        state.currentWave = state.currentWave + 1
        state.enemies = {}
        
        local wave = area.waves[state.currentWave]
        if wave and wave.enemies then
            for _, enemyData in ipairs(wave.enemies) do
                table.insert(state.enemies, DungeonSystem.create_enemy(state, enemyData))
            end
        end
        
        if area.dialogue and area.dialogue.onWaveStart and area.dialogue.onWaveStart[state.currentWave] then
            state.pendingDialogue = {
                speaker = area.dialogue.onWaveStart[state.currentWave].speaker,
                text = area.dialogue.onWaveStart[state.currentWave].text
            }
        end
        
        return true
    end
    
    state.wavesCleared = true
    return false
end

function DungeonSystem.claim_rewards(state)
    if not state.pendingRewards then return nil end
    
    local rewards = state.pendingRewards
    state.pendingRewards = nil
    
    for _, reward in ipairs(rewards) do
        if reward.tier and state.spiritCrystalSystem then
            state.spiritCrystalSystem:add_crystal(reward.tier, reward.count)
        end
    end
    
    return rewards
end

function DungeonSystem.skip_dialogue(state)
    state.pendingDialogue = nil
end

function DungeonSystem.skip_tutorial(state)
    state.pendingTutorial = nil
end

function DungeonSystem.get_spawn_position(state)
    local area = state.currentDungeon:getArea(state.currentAreaIndex)
    if area and area.spawnPoint then
        return area.spawnPoint.x, area.spawnPoint.y
    end
    return state.currentDungeon.startPosition.x, state.currentDungeon.startPosition.y
end

function DungeonSystem.get_exit_position(state)
    local area = state.currentDungeon:getArea(state.currentAreaIndex)
    if area and area.exitPoint then
        return area.exitPoint.x, area.exitPoint.y
    end
    return nil, nil
end

function DungeonSystem.get_enemies(state)
    return state.enemies
end

function DungeonSystem.get_boss(state)
    return state.currentBoss
end

function DungeonSystem.is_at_exit(state, playerX, playerY)
    local exitX, exitY = DungeonSystem.get_exit_position(state)
    if not exitX then return false end
    
    local distance = math.sqrt((playerX - exitX)^2 + (playerY - exitY)^2)
    return distance < 50
end

function DungeonSystem.get_current_area_info(state)
    return state.currentDungeon:getArea(state.currentAreaIndex)
end

function DungeonSystem.get_progress(state)
    return {
        dungeonId = state.currentDungeon and state.currentDungeon.id,
        currentArea = state.currentAreaIndex,
        totalAreas = state.currentDungeon and state.currentDungeon:getAreaCount() or 0,
        clearedAreas = #state.clearedAreas,
        state = state.state,
        bossDefeated = state.bossDefeated
    }
end

function DungeonSystem.is_dungeon_complete(state)
    return state.state == "completed"
end

function DungeonSystem.set_on_dialogue_callback(state, callback)
    state.onDialogueCallback = callback
end

function DungeonSystem.set_on_tutorial_callback(state, callback)
    state.onTutorialCallback = callback
end

function DungeonSystem.set_on_rewards_callback(state, callback)
    state.onRewardsCallback = callback
end

function DungeonSystem.set_on_dungeon_complete_callback(state, callback)
    state.onDungeonCompleteCallback = callback
end

function DungeonSystem.set_on_area_transition_callback(state, callback)
    state.onAreaTransitionCallback = callback
end

function DungeonSystem.update(state, dt, playerX, playerY)
    if state.state ~= "active" then return end
    
    if state.pendingDialogue and state.onDialogueCallback then
        state.onDialogueCallback(state.pendingDialogue)
    end
    
    if state.pendingTutorial and state.onTutorialCallback then
        state.onTutorialCallback(state.pendingTutorial)
    end
    
    if state.pendingRewards and state.onRewardsCallback then
        state.onRewardsCallback(state.pendingRewards)
    end
    
    if DungeonSystem.is_at_exit(state, playerX, playerY) and DungeonSystem.area_cleared(state) then
        if state.onAreaTransitionCallback then
            state.onAreaTransitionCallback(state.currentAreaIndex + 1)
        end
    end
end

function DungeonSystem.serialize(state)
    return {
        currentDungeonId = state.currentDungeon and state.currentDungeon.id,
        currentAreaIndex = state.currentAreaIndex,
        clearedAreas = state.clearedAreas,
        areaClearedFlags = state.areaClearedFlags,
        dungeonClearHistory = state.dungeonClearHistory,
        state = state.state,
        bossDefeated = state.bossDefeated
    }
end

function DungeonSystem.deserialize(state, data)
    if not data then return end
    
    if data.currentDungeonId then
        DungeonSystem.load_dungeon(state, data.currentDungeonId)
    end
    
    state.currentAreaIndex = data.currentAreaIndex or 0
    state.clearedAreas = data.clearedAreas or {}
    state.areaClearedFlags = data.areaClearedFlags or {}
    state.dungeonClearHistory = data.dungeonClearHistory or {}
    state.state = data.state or "idle"
    state.bossDefeated = data.bossDefeated or false
end

return DungeonSystem
