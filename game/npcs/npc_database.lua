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

local function get_npc_data(npcId)
    return NPC_DATABASE[npcId]
end

local function get_npcs_by_type(npcType)
    local result = {}
    for id, data in pairs(NPC_DATABASE) do
        if data.type == npcType then
            result[id] = data
        end
    end
    return result
end

local function get_random_monster()
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

local function get_random_boss()
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

local function get_monsters_by_theme(theme)
    return Monsters.getByTheme(theme)
end

local function get_monster_count()
    local count = 0
    for _ in pairs(allMonsters) do
        count = count + 1
    end
    return count
end

return {
    database = NPC_DATABASE,
    get_npc_data = get_npc_data,
    get_npcs_by_type = get_npcs_by_type,
    get_random_monster = get_random_monster,
    get_random_boss = get_random_boss,
    get_monsters_by_theme = get_monsters_by_theme,
    get_monster_count = get_monster_count
}
