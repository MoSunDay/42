local SkillDatabase = {}

SkillDatabase.SKILLS = {
    whirlwind = {
        id = "whirlwind",
        name = "旋风斩",
        category = "damage",
        targetType = "all_enemies",
        mpCost = 15,
        baseEffect = 20,
        effectType = "physical",
        description = "攻击所有敌人",
        levelScaling = {
            effectBonus = 0.08,
            mpCostBonus = 0.03,
        },
    },
    
    shadow_blade = {
        id = "shadow_blade",
        name = "影刃",
        category = "damage",
        targetType = "single_enemy",
        mpCost = 10,
        baseEffect = 35,
        effectType = "physical",
        description = "单体高伤害",
        levelScaling = {
            effectBonus = 0.10,
            mpCostBonus = 0.02,
        },
    },
    
    phantom_slash = {
        id = "phantom_slash",
        name = "幻影斩",
        category = "damage",
        targetType = "single_enemy",
        mpCost = 20,
        baseEffect = 50,
        effectType = "physical",
        description = "强力单体攻击",
        levelScaling = {
            effectBonus = 0.12,
            mpCostBonus = 0.04,
        },
    },
    
    storm_blade = {
        id = "storm_blade",
        name = "暴风剑",
        category = "damage",
        targetType = "all_enemies",
        mpCost = 30,
        baseEffect = 40,
        effectType = "physical",
        description = "全体强力攻击",
        levelScaling = {
            effectBonus = 0.10,
            mpCostBonus = 0.05,
        },
    },
    
    heavy_strike = {
        id = "heavy_strike",
        name = "重击",
        category = "damage",
        targetType = "single_enemy",
        mpCost = 12,
        baseEffect = 45,
        effectType = "physical",
        description = "强力单体攻击",
        levelScaling = {
            effectBonus = 0.12,
            mpCostBonus = 0.03,
        },
    },
    
    mountain_breaker = {
        id = "mountain_breaker",
        name = "破山击",
        category = "damage",
        targetType = "single_enemy",
        mpCost = 25,
        baseEffect = 70,
        effectType = "physical",
        description = "极高单体伤害",
        levelScaling = {
            effectBonus = 0.15,
            mpCostBonus = 0.05,
        },
    },
    
    world_slash = {
        id = "world_slash",
        name = "天地斩",
        category = "damage",
        targetType = "single_enemy",
        mpCost = 40,
        baseEffect = 100,
        effectType = "physical",
        description = "终极单体攻击",
        levelScaling = {
            effectBonus = 0.18,
            mpCostBonus = 0.06,
        },
    },
    
    sweep = {
        id = "sweep",
        name = "横扫",
        category = "damage",
        targetType = "all_enemies",
        mpCost = 12,
        baseEffect = 18,
        effectType = "physical",
        description = "攻击所有敌人",
        levelScaling = {
            effectBonus = 0.07,
            mpCostBonus = 0.02,
        },
    },
    
    sword_aura = {
        id = "sword_aura",
        name = "剑气",
        category = "damage",
        targetType = "all_enemies",
        mpCost = 20,
        baseEffect = 30,
        effectType = "physical",
        description = "中等级全体攻击",
        levelScaling = {
            effectBonus = 0.09,
            mpCostBonus = 0.03,
        },
    },
    
    heaven_blade = {
        id = "heaven_blade",
        name = "天剑",
        category = "damage",
        targetType = "all_enemies",
        mpCost = 35,
        baseEffect = 50,
        effectType = "physical",
        description = "高级全体攻击",
        levelScaling = {
            effectBonus = 0.11,
            mpCostBonus = 0.04,
        },
    },
    
    bind_curse = {
        id = "bind_curse",
        name = "束缚咒",
        category = "debuff",
        targetType = "single_enemy",
        mpCost = 15,
        baseEffect = 0,
        effectType = "magic",
        description = "降低敌人速度",
        levelScaling = {
            effectBonus = 0,
            mpCostBonus = 0.02,
        },
    },
    
    silence = {
        id = "silence",
        name = "沉默",
        category = "debuff",
        targetType = "single_enemy",
        mpCost = 20,
        baseEffect = 0,
        effectType = "magic",
        description = "禁止敌人使用技能",
        levelScaling = {
            effectBonus = 0,
            mpCostBonus = 0.03,
        },
    },
    
    confusion = {
        id = "confusion",
        name = "混乱",
        category = "debuff",
        targetType = "single_enemy",
        mpCost = 18,
        baseEffect = 0,
        effectType = "magic",
        description = "使敌人混乱",
        levelScaling = {
            effectBonus = 0,
            mpCostBonus = 0.02,
        },
    },
    
    heal = {
        id = "heal",
        name = "治愈",
        category = "heal",
        targetType = "ally",
        mpCost = 12,
        baseEffect = 40,
        effectType = "magic",
        description = "恢复单体队友生命",
        levelScaling = {
            effectBonus = 0.10,
            mpCostBonus = 0.03,
        },
    },
    
    group_heal = {
        id = "group_heal",
        name = "群体治愈",
        category = "heal",
        targetType = "all_allies",
        mpCost = 25,
        baseEffect = 30,
        effectType = "magic",
        description = "恢复全体队友生命",
        levelScaling = {
            effectBonus = 0.08,
            mpCostBonus = 0.04,
        },
    },
    
    revival_light = {
        id = "revival_light",
        name = "复活之光",
        category = "heal",
        targetType = "ally",
        mpCost = 50,
        baseEffect = 100,
        effectType = "magic",
        description = "复活并恢复大量生命",
        levelScaling = {
            effectBonus = 0.12,
            mpCostBonus = 0.05,
        },
    },
    
    fire_storm = {
        id = "fire_storm",
        name = "烈焰风暴",
        category = "damage",
        targetType = "all_enemies",
        mpCost = 22,
        baseEffect = 35,
        effectType = "magic",
        description = "火焰全体攻击",
        levelScaling = {
            effectBonus = 0.10,
            mpCostBonus = 0.04,
        },
    },
    
    ice_fall = {
        id = "ice_fall",
        name = "冰陨",
        category = "damage",
        targetType = "all_enemies",
        mpCost = 25,
        baseEffect = 38,
        effectType = "magic",
        description = "冰霜全体攻击",
        levelScaling = {
            effectBonus = 0.10,
            mpCostBonus = 0.04,
        },
    },
    
    thunder_strike = {
        id = "thunder_strike",
        name = "雷击",
        category = "damage",
        targetType = "all_enemies",
        mpCost = 28,
        baseEffect = 42,
        effectType = "magic",
        description = "雷电全体攻击",
        levelScaling = {
            effectBonus = 0.11,
            mpCostBonus = 0.04,
        },
    },
}

function SkillDatabase.get_skill(skillId)
    return SkillDatabase.SKILLS[skillId]
end

function SkillDatabase.get_all_skills()
    return SkillDatabase.SKILLS
end

function SkillDatabase.calculate_effect(skill, caster)
    if not skill then return 0 end
    
    local base = skill.baseEffect or 0
    local level = caster.level or 1
    local scaling = skill.levelScaling or {}
    local statMod = 1.0
    
    if skill.effectType == "physical" then
        statMod = 1 + (caster.attack or 15) / 100
    elseif skill.effectType == "magic" then
        statMod = 1 + (caster.magicAttack or 15) / 100
    end
    
    local levelBonus = 1 + (scaling.effectBonus or 0) * (level - 1)
    
    local effect = base * statMod * levelBonus
    
    local variance = 0.1
    effect = effect * (1 + (math.random() * 2 - 1) * variance)
    
    return math.floor(effect)
end

function SkillDatabase.get_mp_cost(skill, level)
    if not skill then return 0 end
    
    local base = skill.mpCost or 0
    local scaling = skill.levelScaling or {}
    local costBonus = (scaling.mpCostBonus or 0) * (level - 1)
    
    return math.floor(base * (1 + costBonus))
end

function SkillDatabase.get_skills_for_class(classId)
    local ClassDatabase = require("src.data.class_database")
    local class = ClassDatabase.get_class(classId)
    if not class or not class.skillIds then
        return {}
    end
    
    local skills = {}
    for _, skillId in ipairs(class.skillIds) do
        local skill = SkillDatabase.get_skill(skillId)
        if skill then
            table.insert(skills, skill)
        end
    end
    return skills
end

return SkillDatabase
