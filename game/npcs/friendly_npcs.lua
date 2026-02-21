-- friendly_npcs.lua - Friendly NPC definitions
-- 友好NPC定义

local FRIENDLY_NPCS = {
    town_guard = {
        type = "friendly",
        name = "Town Guard",
        description = "A vigilant guard protecting the town",
        dialogue = {"Welcome to Newbie Village!", "Stay safe out there, adventurer."},
        color = {0.3, 0.3, 0.8},
        size = 20,
        canTalk = true
    },
    
    weapon_merchant = {
        type = "merchant",
        name = "Weapon Merchant",
        description = "Sells weapons and armor",
        dialogue = {"Looking for quality weapons?", "I have the best gear in town!"},
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
        dialogue = {"Need healing?", "I can restore your health for a small fee."},
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
        dialogue = {"Welcome to the inn!", "Rest here for 20 gold?"},
        color = {0.6, 0.4, 0.2},
        size = 20,
        canTalk = true,
        canTrade = true,
        restCost = 20
    },
    
    teleporter = {
        type = "teleporter",
        name = "Dimensional Guide",
        description = "Opens portals to distant lands",
        dialogue = {
            "Greetings, traveler! I can open portals to distant realms.",
            "Where would you like to go?",
            "The threads of fate connect all places."
        },
        color = {0.7, 0.5, 0.9},
        size = 22,
        canTalk = true,
        canTeleport = true
    }
}

return FRIENDLY_NPCS
