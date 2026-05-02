local ClassDatabase = require("src.data.class_database")
local SkillDatabase = require("src.data.skill_database")

local SkillSystem = {}

function SkillSystem.create(player)
    local state = {}
    state.player = player
    return state
end

function SkillSystem.initPlayerSkills(player, classId)
    local class = ClassDatabase.getClass(classId)
    if not class then return false end

    player.classId = classId
    player.skills = {}

    for _, skillId in ipairs(class.skillIds) do
        local skill = SkillDatabase.getSkill(skillId)
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

function SkillSystem.getPlayerSkill(player, skillId)
    if not player.skills then return nil end
    for _, skill in ipairs(player.skills) do
        if skill.id == skillId then
            return skill
        end
    end
    return nil
end

function SkillSystem.isSkillUnlocked(player, skillId)
    local skill = SkillSystem.getPlayerSkill(player, skillId)
    return skill and skill.unlocked
end

function SkillSystem.getSkillLevel(player, skillId)
    local skill = SkillSystem.getPlayerSkill(player, skillId)
    if skill and skill.unlocked then
        return skill.level
    end
    return 0
end

function SkillSystem.canUnlockSkill(player, skillId)
    local playerSkill = SkillSystem.getPlayerSkill(player, skillId)
    if not playerSkill then return false, "技能不存在" end
    if playerSkill.unlocked then return false, "技能已解锁" end

    local skillData = SkillDatabase.getSkill(skillId)
    if not skillData then return false, "技能数据错误" end

    local cost = SkillDatabase.getUnlockCost(skillData.tier)
    if player.skillCrystals < cost then
        return false, string.format("灵晶不足，需要 %d", cost)
    end

    return true, nil, cost
end

function SkillSystem.unlockSkill(player, skillId)
    local canUnlock, err, cost = SkillSystem.canUnlockSkill(player, skillId)
    if not canUnlock then
        return false, err
    end

    local playerSkill = SkillSystem.getPlayerSkill(player, skillId)
    player.skillCrystals = player.skillCrystals - cost
    playerSkill.unlocked = true
    playerSkill.level = 1

    return true, string.format("成功解锁 %s！", SkillDatabase.getSkill(skillId).name)
end

function SkillSystem.canUpgradeSkill(player, skillId)
    local playerSkill = SkillSystem.getPlayerSkill(player, skillId)
    if not playerSkill then return false, "技能不存在" end
    if not playerSkill.unlocked then return false, "技能未解锁" end

    local cost = SkillDatabase.getUpgradeCost(playerSkill.level)
    if player.skillCrystals < cost then
        return false, string.format("灵晶不足，需要 %d", cost)
    end

    return true, nil, cost
end

function SkillSystem.upgradeSkill(player, skillId)
    local canUpgrade, err, cost = SkillSystem.canUpgradeSkill(player, skillId)
    if not canUpgrade then
        return false, err
    end

    local playerSkill = SkillSystem.getPlayerSkill(player, skillId)
    player.skillCrystals = player.skillCrystals - cost
    playerSkill.level = playerSkill.level + 1

    local skillData = SkillDatabase.getSkill(skillId)
    return true, string.format("%s 升级到 Lv.%d！", skillData.name, playerSkill.level)
end

function SkillSystem.addSkillCrystals(player, amount)
    player.skillCrystals = (player.skillCrystals or 0) + amount
    return player.skillCrystals
end

function SkillSystem.getAvailableSkills(player)
    local result = {}
    if not player.skills then return result end

    for _, playerSkill in ipairs(player.skills) do
        if playerSkill.unlocked then
            local skillData = SkillDatabase.getSkill(playerSkill.id)
            if skillData then
                table.insert(result, {
                    id = playerSkill.id,
                    level = playerSkill.level,
                    data = skillData,
                    effectiveDamage = SkillDatabase.getEffectiveDamage(skillData, playerSkill.level),
                    effectiveHeal = SkillDatabase.getEffectiveHealPercent(skillData, playerSkill.level),
                })
            end
        end
    end

    return result
end

function SkillSystem.getLockedSkills(player)
    local result = {}
    if not player.skills then return result end

    for _, playerSkill in ipairs(player.skills) do
        if not playerSkill.unlocked then
            local skillData = SkillDatabase.getSkill(playerSkill.id)
            if skillData then
                table.insert(result, {
                    id = playerSkill.id,
                    data = skillData,
                    unlockCost = SkillDatabase.getUnlockCost(skillData.tier),
                })
            end
        end
    end

    return result
end

function SkillSystem.canUseSkill(player, skillId)
    if not SkillSystem.isSkillUnlocked(player, skillId) then
        return false, "技能未解锁"
    end

    local skillData = SkillDatabase.getSkill(skillId)
    if not skillData then
        return false, "技能数据错误"
    end

    if player.mp < skillData.mpCost then
        return false, string.format("MP不足，需要 %d", skillData.mpCost)
    end

    return true, nil
end

function SkillSystem.useSkill(player, skillId)
    local canUse, err = SkillSystem.canUseSkill(player, skillId)
    if not canUse then
        return false, err
    end

    local skillData = SkillDatabase.getSkill(skillId)
    local skillLevel = SkillSystem.getSkillLevel(player, skillId)

    player.mp = player.mp - skillData.mpCost

    local result = {
        skillId = skillId,
        skillData = skillData,
        level = skillLevel,
        damageMultiplier = SkillDatabase.getEffectiveDamage(skillData, skillLevel),
        healPercent = SkillDatabase.getEffectiveHealPercent(skillData, skillLevel),
    }

    return true, result
end

function SkillSystem.getSkillInfo(player, skillId)
    local skillData = SkillDatabase.getSkill(skillId)
    if not skillData then return nil end

    local playerSkill = SkillSystem.getPlayerSkill(player, skillId)
    local isUnlocked = playerSkill and playerSkill.unlocked
    local level = isUnlocked and playerSkill.level or 0

    return {
        id = skillId,
        name = skillData.name,
        description = skillData.description,
        tier = skillData.tier,
        tierName = SkillDatabase.getSkillTierName(skillData.tier),
        type = skillData.type,
        mpCost = skillData.mpCost,
        unlocked = isUnlocked,
        level = level,
        upgradeCost = isUnlocked and SkillDatabase.getUpgradeCost(level) or nil,
        unlockCost = not isUnlocked and SkillDatabase.getUnlockCost(skillData.tier) or nil,
        effectiveDamage = isUnlocked and SkillDatabase.getEffectiveDamage(skillData, level) or skillData.damageMultiplier,
        effectiveHeal = isUnlocked and SkillDatabase.getEffectiveHealPercent(skillData, level) or skillData.healPercent,
    }
end

return SkillSystem
