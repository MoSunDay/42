local ClassDatabase = {}

ClassDatabase.CLASSES = {
    dual_blade = {
        id = "dual_blade",
        name = "双刀流",
        category = "warrior",
        description = "主物理群攻，副单体输出",
        passiveBonus = {
            speedPercent = 0.15,
            critPercent = 0.10,
        },
        baseStats = {
            hp = 100,
            mp = 60,
            attack = 15,
            defense = 5,
            speed = 8,
            magicAttack = 5,
        },
        skillIds = {"whirlwind", "shadow_blade", "phantom_slash", "storm_blade"},
    },
    
    great_sword = {
        id = "great_sword",
        name = "巨剑士",
        category = "warrior",
        description = "单体物理爆发，一击必杀",
        passiveBonus = {
            attackPercent = 0.20,
            critPercent = 0.05,
        },
        baseStats = {
            hp = 120,
            mp = 50,
            attack = 20,
            defense = 8,
            speed = 5,
            magicAttack = 3,
        },
        skillIds = {"heavy_strike", "mountain_breaker", "world_slash"},
    },
    
    blade_master = {
        id = "blade_master",
        name = "侠客",
        category = "warrior",
        description = "物理群攻坦克，高血高防",
        passiveBonus = {
            maxHpPercent = 0.30,
            defensePercent = 0.20,
        },
        baseStats = {
            hp = 150,
            mp = 40,
            attack = 12,
            defense = 10,
            speed = 5,
            magicAttack = 2,
        },
        skillIds = {"sweep", "sword_aura", "heaven_blade"},
    },
    
    sealer = {
        id = "sealer",
        name = "封印师",
        category = "mage",
        description = "控制型法师，高防高血高速",
        passiveBonus = {
            defensePercent = 0.25,
            maxHpPercent = 0.20,
            speedPercent = 0.15,
        },
        baseStats = {
            hp = 90,
            mp = 120,
            attack = 5,
            defense = 8,
            speed = 8,
            magicAttack = 18,
        },
        skillIds = {"bind_curse", "silence", "confusion"},
    },
    
    healer = {
        id = "healer",
        name = "治愈师",
        category = "mage",
        description = "治疗辅助，高防高血高速",
        passiveBonus = {
            defensePercent = 0.20,
            maxHpPercent = 0.25,
            speedPercent = 0.10,
        },
        baseStats = {
            hp = 100,
            mp = 140,
            attack = 3,
            defense = 8,
            speed = 7,
            magicAttack = 15,
        },
        skillIds = {"heal", "group_heal", "revival_light"},
    },
    
    elementalist = {
        id = "elementalist",
        name = "元素师",
        category = "mage",
        description = "群法输出，目标最多但速度慢",
        passiveBonus = {
            magicAttackPercent = 0.25,
            speedPercent = -0.20,
        },
        baseStats = {
            hp = 80,
            mp = 100,
            attack = 3,
            defense = 4,
            speed = 4,
            magicAttack = 25,
        },
        skillIds = {"fire_storm", "ice_fall", "thunder_strike"},
    },
}

ClassDatabase.CATEGORIES = {
    warrior = {
        id = "warrior",
        name = "战士",
        description = "物理输出，近战专家",
        classIds = {"dual_blade", "great_sword", "blade_master"},
    },
    mage = {
        id = "mage",
        name = "法师",
        description = "魔法大师，掌控元素与治愈",
        classIds = {"sealer", "healer", "elementalist"},
    },
}

function ClassDatabase.get_class(classId)
    return ClassDatabase.CLASSES[classId]
end

function ClassDatabase.get_category(categoryId)
    return ClassDatabase.CATEGORIES[categoryId]
end

function ClassDatabase.get_classes_by_category(categoryId)
    local classes = {}
    for _, classId in ipairs(ClassDatabase.CATEGORIES[categoryId].classIds) do
        table.insert(classes, ClassDatabase.CLASSES[classId])
    end
    return classes
end

function ClassDatabase.apply_passive_bonus(classId, stats)
    local class = ClassDatabase.get_class(classId)
    if not class then return stats end
    
    local bonus = class.passiveBonus
    local result = {}
    
    for k, v in pairs(stats) do
        result[k] = v
    end
    
    if bonus.maxHpPercent then
        result.maxHp = result.maxHp * (1 + bonus.maxHpPercent)
        result.hp = result.maxHp
    end
    if bonus.attackPercent then
        result.attack = result.attack * (1 + bonus.attackPercent)
    end
    if bonus.defensePercent then
        result.defense = result.defense * (1 + bonus.defensePercent)
    end
    if bonus.speedPercent then
        result.speed = result.speed * (1 + bonus.speedPercent)
    end
    if bonus.magicAttackPercent then
        result.magicAttack = result.magicAttack * (1 + bonus.magicAttackPercent)
    end
    if bonus.critPercent then
        result.critBonus = (result.critBonus or 0) + bonus.critPercent
    end
    
    return result
end

function ClassDatabase.get_base_stats(classId)
    local class = ClassDatabase.get_class(classId)
    if not class then return nil end
    
    local stats = {}
    for k, v in pairs(class.baseStats) do
        stats[k] = v
    end
    stats.maxHp = stats.hp
    stats.maxMp = stats.mp
    
    return ClassDatabase.apply_passive_bonus(classId, stats)
end

return ClassDatabase
