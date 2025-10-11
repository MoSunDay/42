-- npc_database.lua - Centralized NPC and Monster database
-- All NPC and monster definitions in one place

local NPC_DATABASE = {
    -- ========== Friendly NPCs ==========
    town_guard = {
        type = "friendly",
        name = "Town Guard",
        description = "A vigilant guard protecting the town",
        dialogue = {
            "Welcome to Newbie Village!",
            "Stay safe out there, adventurer.",
            "The monsters have been more active lately..."
        },
        color = {0.3, 0.3, 0.8},
        size = 20,
        canTalk = true,
        canTrade = false
    },
    
    weapon_merchant = {
        type = "merchant",
        name = "Weapon Merchant",
        description = "Sells weapons and armor",
        dialogue = {
            "Looking for quality weapons?",
            "I have the best gear in town!",
            "Come back when you have more gold."
        },
        color = {0.8, 0.6, 0.2},
        size = 20,
        canTalk = true,
        canTrade = true,
        shop = {
            {name = "Iron Sword", price = 100, attack = 5},
            {name = "Steel Shield", price = 150, defense = 3},
            {name = "Leather Armor", price = 80, defense = 2}
        }
    },
    
    healer = {
        type = "healer",
        name = "Healer",
        description = "Restores HP and cures status effects",
        dialogue = {
            "Need healing?",
            "I can restore your health for a small fee.",
            "May the light protect you."
        },
        color = {0.9, 0.9, 0.3},
        size = 20,
        canTalk = true,
        canTrade = true,
        healCost = 10
    },
    
    innkeeper = {
        type = "service",
        name = "Innkeeper",
        description = "Provides rest and saves your progress",
        dialogue = {
            "Welcome to the inn!",
            "Rest here for 20 gold?",
            "Sleep well, adventurer."
        },
        color = {0.6, 0.4, 0.2},
        size = 20,
        canTalk = true,
        canTrade = true,
        restCost = 20
    },
    
    -- ========== Hostile Monsters ==========
    slime = {
        type = "monster",
        name = "Slime",
        description = "A weak gelatinous creature",
        hp = 30,
        maxHp = 30,
        attack = 5,
        defense = 2,
        speed = 3,
        exp = 10,
        gold = 5,
        color = {0.2, 0.8, 0.3},
        size = 18,
        aggressive = false,  -- Won't chase player
        dropTable = {
            {item = "Slime Gel", chance = 0.5},
            {item = "Small Potion", chance = 0.2}
        }
    },
    
    goblin = {
        type = "monster",
        name = "Goblin",
        description = "A mischievous green creature",
        hp = 50,
        maxHp = 50,
        attack = 8,
        defense = 3,
        speed = 5,
        exp = 20,
        gold = 10,
        color = {0.6, 0.4, 0.2},
        size = 18,
        aggressive = true,  -- Will chase player
        chaseRange = 150,
        dropTable = {
            {item = "Goblin Ear", chance = 0.4},
            {item = "Rusty Dagger", chance = 0.15}
        }
    },
    
    skeleton = {
        type = "monster",
        name = "Skeleton",
        description = "Animated bones of the dead",
        hp = 40,
        maxHp = 40,
        attack = 10,
        defense = 1,
        speed = 4,
        exp = 15,
        gold = 8,
        color = {0.9, 0.9, 0.9},
        size = 18,
        aggressive = true,
        chaseRange = 120,
        dropTable = {
            {item = "Bone", chance = 0.6},
            {item = "Old Sword", chance = 0.1}
        }
    },
    
    orc = {
        type = "monster",
        name = "Orc",
        description = "A brutal warrior",
        hp = 80,
        maxHp = 80,
        attack = 12,
        defense = 5,
        speed = 3,
        exp = 35,
        gold = 20,
        color = {0.4, 0.6, 0.3},
        size = 22,
        aggressive = true,
        chaseRange = 200,
        dropTable = {
            {item = "Orc Tusk", chance = 0.3},
            {item = "Iron Axe", chance = 0.12},
            {item = "Medium Potion", chance = 0.25}
        }
    },
    
    wolf = {
        type = "monster",
        name = "Wolf",
        description = "A fierce wild wolf",
        hp = 45,
        maxHp = 45,
        attack = 9,
        defense = 2,
        speed = 7,
        exp = 18,
        gold = 6,
        color = {0.5, 0.5, 0.5},
        size = 18,
        aggressive = true,
        chaseRange = 250,  -- Wolves chase far
        dropTable = {
            {item = "Wolf Pelt", chance = 0.5},
            {item = "Sharp Fang", chance = 0.3}
        }
    },
    
    bat = {
        type = "monster",
        name = "Bat",
        description = "A flying creature of the night",
        hp = 25,
        maxHp = 25,
        attack = 6,
        defense = 1,
        speed = 8,
        exp = 12,
        gold = 4,
        color = {0.3, 0.2, 0.3},
        size = 15,
        aggressive = false,
        dropTable = {
            {item = "Bat Wing", chance = 0.4}
        }
    },
    
    -- ========== Boss Monsters ==========
    forest_guardian = {
        type = "boss",
        name = "Forest Guardian",
        description = "Ancient protector of the forest",
        hp = 200,
        maxHp = 200,
        attack = 18,
        defense = 8,
        speed = 5,
        exp = 100,
        gold = 100,
        color = {0.2, 0.6, 0.2},
        size = 30,
        aggressive = true,
        chaseRange = 300,
        dropTable = {
            {item = "Guardian's Heart", chance = 1.0},
            {item = "Ancient Sword", chance = 0.5},
            {item = "Large Potion", chance = 0.8}
        },
        abilities = {
            "Vine Whip",
            "Nature's Wrath",
            "Healing Roots"
        }
    }
}

-- Get NPC/Monster data by ID
local function getNPCData(npcId)
    return NPC_DATABASE[npcId]
end

-- Get all NPCs of a specific type
local function getNPCsByType(npcType)
    local result = {}
    for id, data in pairs(NPC_DATABASE) do
        if data.type == npcType then
            result[id] = data
        end
    end
    return result
end

-- Get random monster
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

-- Get random boss
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

return {
    database = NPC_DATABASE,
    getNPCData = getNPCData,
    getNPCsByType = getNPCsByType,
    getRandomMonster = getRandomMonster,
    getRandomBoss = getRandomBoss
}

