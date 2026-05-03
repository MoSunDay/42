local ClassDatabase = require("src.data.class_database")
local SkillDatabase = require("src.data.skill_database")

local SkillSystem = {}

function SkillSystem.create(player)
    local state = {}
    state.player = player
    return state
end

function SkillSystem.init_player_skills(player, classId)
    local class = ClassDatabase.get_class(classId)
    if not class then return false end

    player.classId = classId
    player.skills = {}

    for _, skillId in ipairs(class.skillIds) do
        local skill = SkillDatabase.get_skill(skillId)
        if skill then
            local playerSkill = {
                id = skillId,
                level = 1,
                unlocked = skill.tier == 1,
            }
            table.insert(player.skills, playerSkill)
        end
    end

    player.skillCrystals = player.skillCrystals or 0

    return true
end

function SkillSystem.get_player_skill(player, skillId)
    if not player.skills then return nil end
    for _, skill in ipairs(player.skills) do
        if skill.id == skillId then
            return skill
        end
    end
    return nil
end

function SkillSystem.is_skill_unlocked(player, skillId)
    local skill = SkillSystem.get_player_skill(player, skillId)
    return skill and skill.unlocked
end

function SkillSystem.get_skill_level(player, skillId)
    local skill = SkillSystem.get_player_skill(player, skillId)
    if skill and skill.unlocked then
        return skill.level
    end
    return 0
end

function SkillSystem.can_unlock_skill(player, skillId)
    local playerSkill = SkillSystem.get_player_skill(player, skillId)
    if not playerSkill then return false, "技能不存在" end
    if playerSkill.unlocked then return false, "技能已解锁" end

    local skillData = SkillDatabase.get_skill(skillId)
    if not skillData then return false, "技能数据错误" end

    local cost = SkillDatabase.get_unlock_cost(skillData.tier)
    if player.skillCrystals < cost then
        return false, string.format("灵晶不足，需要 %d", cost)
    end

    return true, nil, cost
end

function SkillSystem.unlock_skill(player, skillId)
    local canUnlock, err, cost = SkillSystem.can_unlock_skill(player, skillId)
    if not canUnlock then
        return false, err
    end

    local playerSkill = SkillSystem.get_player_skill(player, skillId)
    player.skillCrystals = player.skillCrystals - cost
    playerSkill.unlocked = true
    playerSkill.level = 1

    return true, string.format("成功解锁 %s！", SkillDatabase.get_skill(skillId).name)
end

function SkillSystem.can_upgrade_skill(player, skillId)
    local playerSkill = SkillSystem.get_player_skill(player, skillId)
    if not playerSkill then return false, "技能不存在" end
    if not playerSkill.unlocked then return false, "技能未解锁" end

    local cost = SkillDatabase.get_upgrade_cost(playerSkill.level)
    if player.skillCrystals < cost then
        return false, string.format("灵晶不足，需要 %d", cost)
    end

    return true, nil, cost
end

function SkillSystem.upgrade_skill(player, skillId)
    local canUpgrade, err, cost = SkillSystem.can_upgrade_skill(player, skillId)
    if not canUpgrade then
        return false, err
    end

    local playerSkill = SkillSystem.get_player_skill(player, skillId)
    player.skillCrystals = player.skillCrystals - cost
    playerSkill.level = playerSkill.level + 1

    local skillData = SkillDatabase.get_skill(skillId)
    return true, string.format("%s 升级到 Lv.%d！", skillData.name, playerSkill.level)
end

function SkillSystem.add_skill_crystals(player, amount)
    player.skillCrystals = (player.skillCrystals or 0) + amount
    return player.skillCrystals
end

function SkillSystem.get_available_skills(player)
    local result = {}
    if not player.skills then return result end

    for _, playerSkill in ipairs(player.skills) do
        if playerSkill.unlocked then
            local skillData = SkillDatabase.get_skill(playerSkill.id)
            if skillData then
                table.insert(result, {
                    id = playerSkill.id,
                    level = playerSkill.level,
                    data = skillData,
                    effectiveDamage = SkillDatabase.get_effective_damage(skillData, playerSkill.level),
                    effectiveHeal = SkillDatabase.get_effective_heal_percent(skillData, playerSkill.level),
                })
            end
        end
    end

    return result
end

function SkillSystem.get_locked_skills(player)
    local result = {}
    if not player.skills then return result end

    for _, playerSkill in ipairs(player.skills) do
        if not playerSkill.unlocked then
            local skillData = SkillDatabase.get_skill(playerSkill.id)
            if skillData then
                table.insert(result, {
                    id = playerSkill.id,
                    data = skillData,
                    unlockCost = SkillDatabase.get_unlock_cost(skillData.tier),
                })
            end
        end
    end

    return result
end

function SkillSystem.can_use_skill(player, skillId)
    if not SkillSystem.is_skill_unlocked(player, skillId) then
        return false, "技能未解锁"
    end

    local skillData = SkillDatabase.get_skill(skillId)
    if not skillData then
        return false, "技能数据错误"
    end

    if player.mp < skillData.mpCost then
        return false, string.format("MP不足，需要 %d", skillData.mpCost)
    end

    return true, nil
end

function SkillSystem.use_skill(player, skillId)
    local canUse, err = SkillSystem.can_use_skill(player, skillId)
    if not canUse then
        return false, err
    end

    local skillData = SkillDatabase.get_skill(skillId)
    local skillLevel = SkillSystem.get_skill_level(player, skillId)

    player.mp = player.mp - skillData.mpCost

    local result = {
        skillId = skillId,
        skillData = skillData,
        level = skillLevel,
        damageMultiplier = SkillDatabase.get_effective_damage(skillData, skillLevel),
        healPercent = SkillDatabase.get_effective_heal_percent(skillData, skillLevel),
    }

    return true, result
end

function SkillSystem.get_skill_info(player, skillId)
    local skillData = SkillDatabase.get_skill(skillId)
    if not skillData then return nil end

    local playerSkill = SkillSystem.get_player_skill(player, skillId)
    local isUnlocked = playerSkill and playerSkill.unlocked
    local level = isUnlocked and playerSkill.level or 0

    return {
        id = skillId,
        name = skillData.name,
        description = skillData.description,
        tier = skillData.tier,
        tierName = SkillDatabase.get_skillTierName(skillData.tier),
        type = skillData.type,
        mpCost = skillData.mpCost,
        unlocked = isUnlocked,
        level = level,
        upgradeCost = isUnlocked and SkillDatabase.get_upgrade_cost(level) or nil,
        unlockCost = not isUnlocked and SkillDatabase.get_unlock_cost(skillData.tier) or nil,
        effectiveDamage = isUnlocked and SkillDatabase.get_effective_damage(skillData, level) or skillData.damageMultiplier,
        effectiveHeal = isUnlocked and SkillDatabase.get_effective_heal_percent(skillData, level) or skillData.healPercent,
    }
end

return SkillSystem
