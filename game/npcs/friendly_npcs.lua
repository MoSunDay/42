local FRIENDLY_NPCS = {
    elder_adrian = {
        type = "quest_giver",
        name = "村长·艾德里安",
        displayName = "Elder Adrian",
        description = "新手村的村长，发现并引导觉醒者",
        dialogue = {
            "孩子，你在村外的灵泉边被发现时，浑身散发着奇异的光芒...",
            "那是灵晶共鸣的标志！你是百年难遇的觉醒者！",
            "去试炼场吧，证明你的力量，保护我们的村庄。",
            "记住，战斗中要合理运用攻击和防御！"
        },
        color = {0.6, 0.5, 0.3},
        size = 22,
        canTalk = true,
        questRole = "dungeon_intro",
        relatedDungeon = "trial_of_awakening"
    },
    
    spirit_guide_lina = {
        type = "tutorial",
        name = "灵晶向导·琳娜",
        displayName = "Spirit Guide Lina",
        description = "灵晶知识的守护者，为觉醒者讲解灵晶系统",
        dialogue = {
            "欢迎来到灵晶之室！让我为你介绍灵晶的奥秘...",
            "灵晶是这个世界力量的结晶，可以用来强化装备属性。",
            "灵晶分为四个等级：碎片、晶体、宝石、核心。等级越高，价值越大！",
            "击败敌人会掉落灵晶，收集它们来强化装备吧！"
        },
        color = {0.4, 0.6, 0.9},
        size = 20,
        canTalk = true,
        tutorialType = "spirit_crystal",
        relatedDungeon = "trial_of_awakening"
    },
    
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
            {name = "Iron Sword", crystalPrice = 100, attack = 5},
            {name = "Steel Shield", crystalPrice = 150, defense = 3},
            {name = "Leather Armor", crystalPrice = 80, defense = 2}
        }
    },
    
    healer = {
        type = "healer",
        name = "Healer",
        description = "Restores HP and cures status effects",
        dialogue = {"Need healing?", "I can restore your health using spirit crystals."},
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
        dialogue = {"Welcome to the inn!", "Rest here for 20 spirit crystals?"},
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
