local DungeonSystem = {}
DungeonSystem.__index = DungeonSystem

local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")

function DungeonSystem.new(player, spiritCrystalSystem)
    local self = setmetatable({}, DungeonSystem)
    
    self.player = player
    self.spiritCrystalSystem = spiritCrystalSystem or SpiritCrystalSystem.new()
    
    self.currentDungeon = nil
    self.currentAreaIndex = 0
    self.clearedAreas = {}
    self.areaClearedFlags = {}
    self.dungeonClearHistory = {}
    self.currentWave = 0
    self.wavesCleared = false
    self.bossDefeated = false
    
    self.enemies = {}
    self.currentBoss = nil
    
    self.pendingDialogue = nil
    self.pendingTutorial = nil
    self.pendingRewards = nil
    
    self.state = "idle"
    self.onDialogueCallback = nil
    self.onTutorialCallback = nil
    self.onRewardsCallback = nil
    self.onDungeonCompleteCallback = nil
    self.onAreaTransitionCallback = nil
    
    return self
end

function DungeonSystem:loadDungeon(dungeonId)
    local success, dungeonData = pcall(require, "map.maps." .. dungeonId)
    if not success or not dungeonData then
        print("Failed to load dungeon: " .. dungeonId)
        return false
    end
    
    self.currentDungeon = dungeonData
    self.currentAreaIndex = 0
    self.clearedAreas = {}
    self.areaClearedFlags = {}
    self.currentWave = 0
    self.wavesCleared = false
    self.bossDefeated = false
    self.enemies = {}
    self.currentBoss = nil
    self.state = "loaded"
    
    return true
end

function DungeonSystem:startDungeon()
    if not self.currentDungeon then return false end
    
    self.currentAreaIndex = self.currentDungeon.startArea or 1
    self.state = "active"
    
    local area = self.currentDungeon:getArea(self.currentAreaIndex)
    if area then
        self:setupArea(area)
    end
    
    return true
end

function DungeonSystem:setupArea(area)
    self.enemies = {}
    self.currentWave = 0
    self.wavesCleared = false
    self.currentBoss = nil
    
    if area.enemies then
        for _, enemyData in ipairs(area.enemies) do
            table.insert(self.enemies, self:createEnemy(enemyData))
        end
    end
    
    if area.waves then
        self.currentWave = 1
        local wave = area.waves[1]
        if wave and wave.enemies then
            for _, enemyData in ipairs(wave.enemies) do
                table.insert(self.enemies, self:createEnemy(enemyData))
            end
        end
    end
    
    if area.boss then
        self.currentBoss = self:createBoss(area.boss)
    end
    
    if area.dialogue and area.dialogue.onEnter then
        self.pendingDialogue = {
            speaker = area.dialogue.onEnter.speaker,
            text = area.dialogue.onEnter.text
        }
    end
    
    if area.tutorial and area.tutorial.triggerOnEnter then
        self.pendingTutorial = {
            tutorialId = area.tutorial.tutorialId,
            canSkip = area.tutorial.canSkip
        }
    end
end

function DungeonSystem:createEnemy(enemyData)
    local Enemy = require("src.entities.enemy")
    local enemy = Enemy.new(enemyData.type)
    
    enemy.x = enemyData.x
    enemy.y = enemyData.y
    
    if enemyData.weakened then
        enemy.hp = math.floor(enemy.hp * (enemyData.hpMultiplier or 0.7))
        enemy.maxHp = enemy.hp
        enemy.attack = math.floor(enemy.attack * (enemyData.hpMultiplier or 0.7))
    end
    
    return enemy
end

function DungeonSystem:createBoss(bossData)
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

function DungeonSystem:areaCleared()
    if self.currentBoss and self.currentBoss.hp > 0 then
        return false
    end
    
    if #self.enemies > 0 then
        for _, enemy in ipairs(self.enemies) do
            if enemy.hp > 0 then
                return false
            end
        end
    end
    
    local area = self.currentDungeon:getArea(self.currentAreaIndex)
    if area and area.waves then
        if self.currentWave < #area.waves then
            return false
        end
    end
    
    return true
end

function DungeonSystem:checkAreaProgress()
    if not self:areaCleared() then return false end
    
    local areaIndex = self.currentAreaIndex
    if self.areaClearedFlags[areaIndex] then return false end
    
    self.areaClearedFlags[areaIndex] = true
    table.insert(self.clearedAreas, areaIndex)
    
    local area = self.currentDungeon:getArea(areaIndex)
    if area and area.rewards and area.rewards.firstClear then
        if not self.dungeonClearHistory[self.currentDungeon.id] then
            self.pendingRewards = area.rewards.firstClear
        end
    end
    
    if area and area.boss and self.currentBoss and self.currentBoss.hp <= 0 then
        self.bossDefeated = true
        if area.dialogue and area.dialogue.onBossDefeat then
            self.pendingDialogue = {
                speaker = area.dialogue.onBossDefeat.speaker,
                text = area.dialogue.onBossDefeat.text,
                isBossDefeat = true
            }
        end
        
        if area.onClear then
            self.state = "completed"
            if self.onDungeonCompleteCallback then
                self.onDungeonCompleteCallback(area.onClear)
            end
        end
    end
    
    return true
end

function DungeonSystem:advanceToNextArea()
    local nextAreaIndex = self.currentAreaIndex + 1
    if nextAreaIndex > self.currentDungeon:getAreaCount() then
        return false
    end
    
    self.currentAreaIndex = nextAreaIndex
    local area = self.currentDungeon:getArea(nextAreaIndex)
    if area then
        self:setupArea(area)
    end
    
    return true
end

function DungeonSystem:processWave()
    local area = self.currentDungeon:getArea(self.currentAreaIndex)
    if not area or not area.waves then return false end
    
    if self.currentWave < #area.waves then
        self.currentWave = self.currentWave + 1
        self.enemies = {}
        
        local wave = area.waves[self.currentWave]
        if wave and wave.enemies then
            for _, enemyData in ipairs(wave.enemies) do
                table.insert(self.enemies, self:createEnemy(enemyData))
            end
        end
        
        if area.dialogue and area.dialogue.onWaveStart and area.dialogue.onWaveStart[self.currentWave] then
            self.pendingDialogue = {
                speaker = area.dialogue.onWaveStart[self.currentWave].speaker,
                text = area.dialogue.onWaveStart[self.currentWave].text
            }
        end
        
        return true
    end
    
    self.wavesCleared = true
    return false
end

function DungeonSystem:claimRewards()
    if not self.pendingRewards then return nil end
    
    local rewards = self.pendingRewards
    self.pendingRewards = nil
    
    for _, reward in ipairs(rewards) do
        if reward.tier and self.spiritCrystalSystem then
            self.spiritCrystalSystem:addCrystal(reward.tier, reward.count)
        end
    end
    
    return rewards
end

function DungeonSystem:skipDialogue()
    self.pendingDialogue = nil
end

function DungeonSystem:skipTutorial()
    self.pendingTutorial = nil
end

function DungeonSystem:getSpawnPosition()
    local area = self.currentDungeon:getArea(self.currentAreaIndex)
    if area and area.spawnPoint then
        return area.spawnPoint.x, area.spawnPoint.y
    end
    return self.currentDungeon.startPosition.x, self.currentDungeon.startPosition.y
end

function DungeonSystem:getExitPosition()
    local area = self.currentDungeon:getArea(self.currentAreaIndex)
    if area and area.exitPoint then
        return area.exitPoint.x, area.exitPoint.y
    end
    return nil, nil
end

function DungeonSystem:getEnemies()
    return self.enemies
end

function DungeonSystem:getBoss()
    return self.currentBoss
end

function DungeonSystem:isAtExit(playerX, playerY)
    local exitX, exitY = self:getExitPosition()
    if not exitX then return false end
    
    local distance = math.sqrt((playerX - exitX)^2 + (playerY - exitY)^2)
    return distance < 50
end

function DungeonSystem:getCurrentAreaInfo()
    return self.currentDungeon:getArea(self.currentAreaIndex)
end

function DungeonSystem:getProgress()
    return {
        dungeonId = self.currentDungeon and self.currentDungeon.id,
        currentArea = self.currentAreaIndex,
        totalAreas = self.currentDungeon and self.currentDungeon:getAreaCount() or 0,
        clearedAreas = #self.clearedAreas,
        state = self.state,
        bossDefeated = self.bossDefeated
    }
end

function DungeonSystem:isDungeonComplete()
    return self.state == "completed"
end

function DungeonSystem:setOnDialogueCallback(callback)
    self.onDialogueCallback = callback
end

function DungeonSystem:setOnTutorialCallback(callback)
    self.onTutorialCallback = callback
end

function DungeonSystem:setOnRewardsCallback(callback)
    self.onRewardsCallback = callback
end

function DungeonSystem:setOnDungeonCompleteCallback(callback)
    self.onDungeonCompleteCallback = callback
end

function DungeonSystem:setOnAreaTransitionCallback(callback)
    self.onAreaTransitionCallback = callback
end

function DungeonSystem:update(dt, playerX, playerY)
    if self.state ~= "active" then return end
    
    if self.pendingDialogue and self.onDialogueCallback then
        self.onDialogueCallback(self.pendingDialogue)
    end
    
    if self.pendingTutorial and self.onTutorialCallback then
        self.onTutorialCallback(self.pendingTutorial)
    end
    
    if self.pendingRewards and self.onRewardsCallback then
        self.onRewardsCallback(self.pendingRewards)
    end
    
    if self:isAtExit(playerX, playerY) and self:areaCleared() then
        if self.onAreaTransitionCallback then
            self.onAreaTransitionCallback(self.currentAreaIndex + 1)
        end
    end
end

function DungeonSystem:serialize()
    return {
        currentDungeonId = self.currentDungeon and self.currentDungeon.id,
        currentAreaIndex = self.currentAreaIndex,
        clearedAreas = self.clearedAreas,
        areaClearedFlags = self.areaClearedFlags,
        dungeonClearHistory = self.dungeonClearHistory,
        state = self.state,
        bossDefeated = self.bossDefeated
    }
end

function DungeonSystem:deserialize(data)
    if not data then return end
    
    if data.currentDungeonId then
        self:loadDungeon(data.currentDungeonId)
    end
    
    self.currentAreaIndex = data.currentAreaIndex or 0
    self.clearedAreas = data.clearedAreas or {}
    self.areaClearedFlags = data.areaClearedFlags or {}
    self.dungeonClearHistory = data.dungeonClearHistory or {}
    self.state = data.state or "idle"
    self.bossDefeated = data.bossDefeated or false
end

return DungeonSystem
