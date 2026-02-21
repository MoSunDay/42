-- npc_database.lua - Centralized NPC and Monster database interface
-- NPC和怪物数据库接口

local FriendlyNPCs = require("npcs.friendly_npcs")
local Monsters = require("npcs.monsters")
local Bosses = require("npcs.bosses")

local NPC_DATABASE = {}

for id, data in pairs(FriendlyNPCs) do
    NPC_DATABASE[id] = data
end

local allMonsters = Monsters.getAll()
for id, data in pairs(allMonsters) do
    NPC_DATABASE[id] = data
end

for id, data in pairs(Bosses) do
    NPC_DATABASE[id] = data
end

local function getNPCData(npcId)
    return NPC_DATABASE[npcId]
end

local function getNPCsByType(npcType)
    local result = {}
    for id, data in pairs(NPC_DATABASE) do
        if data.type == npcType then
            result[id] = data
        end
    end
    return result
end

local function getRandomMonster()
    local monsters = {}
    for id, data in pairs(NPC_DATABASE) do
        if data.type == "monster" then
            table.insert(monsters, id)
        end
    end
    
    if #monsters > 0 then
        return monsters[math.random(#monsters)]
    end
    return nil
end

local function getRandomBoss()
    local bosses = {}
    for id, data in pairs(NPC_DATABASE) do
        if data.type == "boss" then
            table.insert(bosses, id)
        end
    end
    
    if #bosses > 0 then
        return bosses[math.random(#bosses)]
    end
    return nil
end

local function getMonstersByTheme(theme)
    return Monsters.getByTheme(theme)
end

local function getMonsterCount()
    local count = 0
    for _ in pairs(allMonsters) do
        count = count + 1
    end
    return count
end

return {
    database = NPC_DATABASE,
    getNPCData = getNPCData,
    getNPCsByType = getNPCsByType,
    getRandomMonster = getRandomMonster,
    getRandomBoss = getRandomBoss,
    getMonstersByTheme = getMonstersByTheme,
    getMonsterCount = getMonsterCount
}
