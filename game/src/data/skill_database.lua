local SkillDatabase = {}

SkillDatabase.TYPES = {
    SINGLE = "single",
    AOE = "aoe",
    HEAL = "heal",
    SEAL = "seal",
}

SkillDatabase.TIER_UNLOCK_COST = {
    [1] = 0,
    [2] = 100,
    [3] = 250,
}

SkillDatabase.UPGRADE_BASE_COST = 40
SkillDatabase.UPGRADE_GROWTH_RATE = 0.08
SkillDatabase.EFFECT_BONUS_PER_LEVEL = 0.03

SkillDatabase.SKILLS = {
    whirlwind = {
        id = "whirlwind",
        name = "旋风斩",
        description = "旋转双刀，攻击多个敌人",
        type = SkillDatabase.TYPES.AOE,
        tier = 1,
        damageMultiplier = 1.2,
        targets = {2, 3},
        mpCost = 15,
        useClass = "physical",
        classId = "dual_blade",
    },
    
    shadow_blade = {
        id = "shadow_blade",
        name = "影刃舞",
        description = "如影随形的刀刃，提升暴击率",
        type = SkillDatabase.TYPES.AOE,
        tier = 2,
        damageMultiplier = 1.5,
        critBonus = 0.10,
        targets = {2, 3},
        mpCost = 25,
        useClass = "physical",
        classId = "dual_blade",
    },
    
    phantom_slash = {
        id = "phantom_slash",
        name = "绝影斩",
        description = "快速的单体斩击",
        type = SkillDatabase.TYPES.SINGLE,
        tier = 2,
        damageMultiplier = 2.0,
        targets = 1,
        mpCost = 20,
        useClass = "physical",
        classId = "dual_blade",
    },
    
    storm_blade = {
        id = "storm_blade",
        name = "疾风连斩",
        description = "疾风般的连斩，并提升自身速度",
        type = SkillDatabase.TYPES.AOE,
        tier = 3,
        damageMultiplier = 1.8,
        targets = {2, 3},
        mpCost = 35,
        useClass = "physical",
        selfBuff = { speedPercent = 0.2, duration = 1 },
        classId = "dual_blade",
    },
    
    heavy_strike = {
        id = "heavy_strike",
        name = "重击",
        description = "蓄力一击，造成重创",
        type = SkillDatabase.TYPES.SINGLE,
        tier = 1,
        damageMultiplier = 1.5,
        targets = 1,
        mpCost = 12,
        useClass = "physical",
        classId = "great_sword",
    },
    
    mountain_breaker = {
        id = "mountain_breaker",
        name = "崩山裂地",
        description = "劈开大地的重击，破防敌人",
        type = SkillDatabase.TYPES.SINGLE,
        tier = 2,
        damageMultiplier = 2.2,
        defBreak = 0.15,
        targets = 1,
        mpCost = 25,
        useClass = "physical",
        classId = "great_sword",
    },
    
    world_slash = {
        id = "world_slash",
        name = "灭世斩",
        description = "毁灭一切的终极斩击",
        type = SkillDatabase.TYPES.SINGLE,
        tier = 3,
        damageMultiplier = 3.5,
        critBonus = 0.25,
        targets = 1,
        mpCost = 45,
        useClass = "physical",
        classId = "great_sword",
    },
    
    sweep = {
        id = "sweep",
        name = "横扫千军",
        description = "横扫敌阵的群攻技能",
        type = SkillDatabase.TYPES.AOE,
        tier = 1,
        damageMultiplier = 1.0,
        targets = 3,
        mpCost = 18,
        useClass = "physical",
        classId = "blade_master",
    },
    
    sword_aura = {
        id = "sword_aura",
        name = "剑气纵横",
        description = "释放剑气攻击多个敌人",
        type = SkillDatabase.TYPES.AOE,
        tier = 2,
        damageMultiplier = 1.3,
        targets = 3,
        mpCost = 28,
        useClass = "physical",
        classId = "blade_master",
    },
    
    heaven_blade = {
        id = "heaven_blade",
        name = "天剑归宗",
        description = "天剑降世，群攻并提升防御",
        type = SkillDatabase.TYPES.AOE,
        tier = 3,
        damageMultiplier = 1.8,
        targets = 3,
        mpCost = 40,
        useClass = "physical",
        selfBuff = { defensePercent = 0.10, duration = 2 },
        classId = "blade_master",
    },
    
    bind_curse = {
        id = "bind_curse",
        name = "定身咒",
        description = "封印敌人行动1回合",
        type = SkillDatabase.TYPES.SEAL,
        tier = 1,
        sealType = "bind",
        sealDuration = 1,
        targets = 1,
        mpCost = 20,
        useClass = "magic",
        classId = "sealer",
    },
    
    silence = {
        id = "silence",
        name = "沉默术",
        description = "使敌人无法使用技能",
        type = SkillDatabase.TYPES.SEAL,
        tier = 2,
        sealType = "silence",
        sealDuration = 2,
        targets = 1,
        mpCost = 25,
        useClass = "magic",
        classId = "sealer",
    },
    
    confusion = {
        id = "confusion",
        name = "混乱术",
        description = "使敌人陷入混乱状态",
        type = SkillDatabase.TYPES.SEAL,
        tier = 3,
        sealType = "confusion",
        sealDuration = 2,
        targets = 1,
        mpCost = 35,
        useClass = "magic",
        classId = "sealer",
    },
    
    heal = {
        id = "heal",
        name = "治愈术",
        description = "恢复自身生命值",
        type = SkillDatabase.TYPES.HEAL,
        tier = 1,
        healPercent = 0.30,
        targets = "self",
        mpCost = 15,
        useClass = "magic",
        classId = "healer",
    },
    
    group_heal = {
        id = "group_heal",
        name = "群体治疗",
        description = "恢复全体队友生命值",
        type = SkillDatabase.TYPES.HEAL,
        tier = 2,
        healPercent = 0.20,
        targets = "all_allies",
        mpCost = 30,
        useClass = "magic",
        classId = "healer",
    },
    
    revival_light = {
        id = "revival_light",
        name = "复苏之光",
        description = "强力治疗并解除负面状态",
        type = SkillDatabase.TYPES.HEAL,
        tier = 3,
        healPercent = 0.50,
        cleanse = true,
        targets = "self",
        mpCost = 45,
        useClass = "magic",
        classId = "healer",
    },
    
    fire_storm = {
        id = "fire_storm",
        name = "火焰风暴",
        description = "召唤火焰风暴，灼烧敌人",
        type = SkillDatabase.TYPES.AOE,
        tier = 1,
        damageMultiplier = 1.4,
        targets = {3, 4},
        mpCost = 30,
        useClass = "magic",
        dot = { type = "burn", damage = 0.05, duration = 2 },
        classId = "elementalist",
    },
    
    ice_fall = {
        id = "ice_fall",
        name = "冰霜降临",
        description = "冰霜攻击并降低敌人速度",
        type = SkillDatabase.TYPES.AOE,
        tier = 2,
        damageMultiplier = 1.2,
        targets = {3, 4},
        mpCost = 28,
        useClass = "magic",
        debuff = { speedPercent = -0.20, duration = 2 },
        classId = "elementalist",
    },
    
    thunder_strike = {
        id = "thunder_strike",
        name = "雷霆万钧",
        description = "雷电攻击，有几率麻痹敌人",
        type = SkillDatabase.TYPES.AOE,
        tier = 3,
        damageMultiplier = 1.6,
        targets = {3, 4},
        mpCost = 40,
        useClass = "magic",
        stunChance = 0.30,
        classId = "elementalist",
    },
}

function SkillDatabase.get_skill(skillId)
    return SkillDatabase.SKILLS[skillId]
end

function SkillDatabase.get_skills_by_class(classId)
    local skills = {}
    for id, skill in pairs(SkillDatabase.SKILLS) do
        if skill.classId == classId then
            skills[id] = skill
        end
    end
    return skills
end

function SkillDatabase.get_upgrade_cost(currentLevel)
    return math.floor(SkillDatabase.UPGRADE_BASE_COST * currentLevel * (1 + SkillDatabase.UPGRADE_GROWTH_RATE * currentLevel))
end

function SkillDatabase.get_unlock_cost(tier)
    return SkillDatabase.TIER_UNLOCK_COST[tier] or 0
end

function SkillDatabase.get_effect_multiplier(skillLevel)
    return 1 + SkillDatabase.EFFECT_BONUS_PER_LEVEL * (skillLevel - 1)
end

function SkillDatabase.get_effective_damage(skill, skillLevel)
    local multiplier = skill.damageMultiplier or 1.0
    local levelBonus = SkillDatabase.get_effect_multiplier(skillLevel)
    return multiplier * levelBonus
end

function SkillDatabase.get_effective_heal_percent(skill, skillLevel)
    local basePercent = skill.healPercent or 0.3
    local levelBonus = SkillDatabase.get_effect_multiplier(skillLevel)
    return basePercent * levelBonus
end

function SkillDatabase.get_target_count(skill)
    if type(skill.targets) == "number" then
        return skill.targets, skill.targets
    elseif type(skill.targets) == "table" then
        return skill.targets[1], skill.targets[2]
    elseif skill.targets == "self" or skill.targets == "all_allies" then
        return 1, 1
    end
    return 1, 1
end

function SkillDatabase.get_skill_tier_name(tier)
    local names = {[1] = "初级", [2] = "中级", [3] = "高级"}
    return names[tier] or "未知"
end

return SkillDatabase
