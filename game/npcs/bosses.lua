-- bosses.lua - Boss monster definitions
-- Boss怪物定义

local BOSSES = {
    forest_guardian = {
        type = "boss",
        name = "Forest Guardian",
        description = "Ancient protector of the forest",
        hp = 200, maxHp = 200,
        attack = 18, defense = 8, speed = 5,
        exp = 100, gold = 100,
        color = {0.2, 0.6, 0.2},
        size = 30,
        aggressive = true,
        chaseRange = 300,
        dropTable = {
            {item = "Guardian's Heart", chance = 1.0},
            {item = "Ancient Sword", chance = 0.5},
            {item = "Large Potion", chance = 0.8}
        },
        abilities = {"Vine Whip", "Nature's Wrath", "Healing Roots"}
    },
    
    dreamweaver = {
        type = "boss",
        name = "The Dreamweaver",
        description = "Master of the realm between dreams and reality",
        hp = 500, maxHp = 500,
        attack = 40, defense = 20, speed = 6,
        exp = 500, gold = 300,
        color = {0.5, 0.3, 0.7},
        size = 35,
        aggressive = true,
        chaseRange = 350,
        dropTable = {
            {item = "Dreamweaver's Essence", chance = 1.0},
            {item = "Reality Shard", chance = 0.3},
            {item = "Celestial Crown", chance = 0.1}
        },
        abilities = {"Dream Weave", "Reality Rift", "Mind Shatter", "Eternal Slumber"}
    },
    
    sand_king = {
        type = "boss",
        name = "Sand King",
        description = "Ancient ruler of the desert depths",
        hp = 350, maxHp = 350,
        attack = 32, defense = 15, speed = 4,
        exp = 250, gold = 200,
        color = {0.85, 0.7, 0.4},
        size = 32,
        aggressive = true,
        chaseRange = 280,
        dropTable = {
            {item = "Sand King's Crown", chance = 1.0},
            {item = "Desert Heart", chance = 0.4},
            {item = "Sandstorm Ring", chance = 0.2}
        },
        abilities = {"Sandstorm", "Quicksand", "Dune Crusher"}
    },
    
    frost_titan = {
        type = "boss",
        name = "Frost Titan",
        description = "An immense being of eternal ice",
        hp = 400, maxHp = 400,
        attack = 35, defense = 25, speed = 3,
        exp = 300, gold = 250,
        color = {0.5, 0.7, 0.9},
        size = 38,
        aggressive = true,
        chaseRange = 250,
        dropTable = {
            {item = "Titan's Core", chance = 1.0},
            {item = "Eternal Ice", chance = 0.5},
            {item = "Frostbrand", chance = 0.15}
        },
        abilities = {"Glacial Crush", "Blizzard", "Frozen Tomb"}
    }
}

return BOSSES
