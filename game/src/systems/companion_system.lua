local CompanionSystem = {}
CompanionSystem.__index = CompanionSystem

CompanionSystem.MAX_COMPANIONS = 9
CompanionSystem.MAX_PARTY_SIZE = 10

local BASE_STATS = {
    hp = 100,
    attack = 15,
    defense = 5,
    speed = 6,
    crit = 5,
    eva = 3
}

local COMPANION_TEMPLATES = {
    {
        id = "warrior",
        name = "战士",
        description = "攻防平衡的战斗伙伴",
        statModifiers = { hp = 1.1, attack = 1.0, defense = 1.2, speed = 0.9, crit = 0.8, eva = 0.8 },
        defaultEquipment = { weapon = "iron_sword", hat = "leather_cap", clothes = "leather_vest" }
    },
    {
        id = "berserker",
        name = "狂战士",
        description = "高攻击低防御的输出伙伴",
        statModifiers = { hp = 0.9, attack = 1.3, defense = 0.7, speed = 1.0, crit = 1.2, eva = 0.9 },
        defaultEquipment = { weapon = "assassin_dagger", clothes = "cloth_shirt", shoes = "sandals" }
    },
    {
        id = "guardian",
        name = "守护者",
        description = "高防御低攻击的坦克伙伴",
        statModifiers = { hp = 1.3, attack = 0.7, defense = 1.4, speed = 0.7, crit = 0.6, eva = 0.7 },
        defaultEquipment = { weapon = "wooden_sword", hat = "iron_helmet", clothes = "chain_mail", shoes = "iron_boots" }
    },
    {
        id = "assassin",
        name = "刺客",
        description = "高暴击高闪避的敏捷伙伴",
        statModifiers = { hp = 0.8, attack = 1.1, defense = 0.8, speed = 1.2, crit = 1.5, eva = 1.3 },
        defaultEquipment = { weapon = "assassin_dagger", hat = "hood_of_shadows", clothes = "shadow_cloak", shoes = "shadow_step" }
    },
    {
        id = "mage",
        name = "法师",
        description = "高攻击低生命的魔法伙伴",
        statModifiers = { hp = 0.7, attack = 1.4, defense = 0.6, speed = 1.0, crit = 1.1, eva = 1.0 },
        defaultEquipment = { weapon = "flame_blade", clothes = "wizard_robe", shoes = "sandals", necklace = "copper_necklace" }
    },
    {
        id = "paladin",
        name = "圣骑士",
        description = "平衡型辅助伙伴",
        statModifiers = { hp = 1.2, attack = 0.9, defense = 1.1, speed = 0.9, crit = 0.9, eva = 1.0 },
        defaultEquipment = { weapon = "steel_sword", hat = "iron_helmet", clothes = "plate_armor", shoes = "greaves_of_might", necklace = "silver_necklace" }
    }
}

function CompanionSystem.new()
    local self = setmetatable({}, CompanionSystem)
    
    self.companions = {}
    self.activeParty = {}
    
    return self
end

local function createCompanion(template, index)
    local mods = template.statModifiers
    return {
        id = template.id .. "_" .. index,
        templateId = template.id,
        name = template.name,
        description = template.description,
        
        baseHp = math.floor(BASE_STATS.hp * mods.hp),
        hp = math.floor(BASE_STATS.hp * mods.hp),
        maxHp = math.floor(BASE_STATS.hp * mods.hp),
        baseAttack = math.floor(BASE_STATS.attack * mods.attack),
        attack = math.floor(BASE_STATS.attack * mods.attack),
        baseDefense = math.floor(BASE_STATS.defense * mods.defense),
        defense = math.floor(BASE_STATS.defense * mods.defense),
        baseSpeed = math.floor(BASE_STATS.speed * mods.speed),
        speed = math.floor(BASE_STATS.speed * mods.speed),
        baseCrit = math.floor(BASE_STATS.crit * mods.crit),
        crit = math.floor(BASE_STATS.crit * mods.crit),
        baseEva = math.floor(BASE_STATS.eva * mods.eva),
        eva = math.floor(BASE_STATS.eva * mods.eva),
        
        defPercent = 0,
        isDefending = false,
        
        equipment = {
            weapon = nil,
            hat = nil,
            clothes = nil,
            shoes = nil,
            necklace = nil
        },
        enhanceLevels = {
            weapon = 0,
            hat = 0,
            clothes = 0,
            shoes = 0,
            necklace = 0
        },
        
        inParty = false,
        slot = nil,
        defaultEquipment = template.defaultEquipment or {}
    }
end

function CompanionSystem:recruit(templateId, itemDatabase)
    if #self.companions >= CompanionSystem.MAX_COMPANIONS then
        return false, "伙伴数量已达上限"
    end
    
    local template = nil
    for _, t in ipairs(COMPANION_TEMPLATES) do
        if t.id == templateId then
            template = t
            break
        end
    end
    
    if not template then
        return false, "未知的伙伴类型"
    end
    
    local companion = createCompanion(template, #self.companions + 1)
    
    if itemDatabase and template.defaultEquipment then
        for slot, itemId in pairs(template.defaultEquipment) do
            local item = itemDatabase.getItem(itemId)
            if item then
                companion.equipment[slot] = item
            end
        end
    end
    
    self:updateCompanionStats(companion)
    table.insert(self.companions, companion)
    
    return true, companion
end

function CompanionSystem:dismiss(companionId)
    for i, companion in ipairs(self.companions) do
        if companion.id == companionId then
            if companion.inParty then
                self:removeFromParty(companionId)
            end
            table.remove(self.companions, i)
            return true
        end
    end
    return false
end

function CompanionSystem:addToParty(companionId)
    if #self.activeParty >= CompanionSystem.MAX_COMPANIONS then
        return false, "队伍已满"
    end
    
    for _, companion in ipairs(self.companions) do
        if companion.id == companionId and not companion.inParty then
            companion.inParty = true
            companion.slot = #self.activeParty + 1
            table.insert(self.activeParty, companion)
            return true
        end
    end
    
    return false, "伙伴未找到或已在队伍中"
end

function CompanionSystem:removeFromParty(companionId)
    for i, companion in ipairs(self.activeParty) do
        if companion.id == companionId then
            companion.inParty = false
            companion.slot = nil
            table.remove(self.activeParty, i)
            
            for j, c in ipairs(self.activeParty) do
                c.slot = j
            end
            return true
        end
    end
    return false
end

function CompanionSystem:getParty()
    return self.activeParty
end

function CompanionSystem:getPartySize()
    return #self.activeParty
end

function CompanionSystem:getTotalPartySize()
    return #self.activeParty + 1
end

function CompanionSystem:getAllCompanions()
    return self.companions
end

function CompanionSystem:getCompanion(companionId)
    for _, companion in ipairs(self.companions) do
        if companion.id == companionId then
            return companion
        end
    end
    return nil
end

local MAX_DEF_PERCENT = 50
local DEF_TO_PERCENT = 5

function CompanionSystem:updateCompanionStats(companion)
    if not companion then return end
    
    local equipStats = {
        attack = 0, defense = 0, speed = 0, hp = 0, crit = 0, eva = 0
    }
    
    for slot, item in pairs(companion.equipment) do
        if item then
            equipStats.attack = equipStats.attack + (item.attack or 0)
            equipStats.defense = equipStats.defense + (item.defense or 0)
            equipStats.speed = equipStats.speed + (item.speed or 0)
            equipStats.hp = equipStats.hp + (item.hp or 0)
            equipStats.crit = equipStats.crit + (item.crit or 0)
            equipStats.eva = equipStats.eva + (item.eva or 0)
        end
    end
    
    local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")
    local enhanceBonus = {
        attack = 0, defense = 0, speed = 0, hp = 0, crit = 0, eva = 0
    }
    
    local crystalTypeMap = {
        weapon = "crimson",
        hat = "azure",
        clothes = "emerald",
        shoes = "golden",
        necklace = "violet"
    }
    
    for slot, level in pairs(companion.enhanceLevels) do
        if level > 0 then
            local crystalType = crystalTypeMap[slot]
            local bonus = SpiritCrystalSystem.getEnhancementBonus(crystalType, level)
            local stat = SpiritCrystalSystem.STATS_MAP[crystalType]
            if stat then
                enhanceBonus[stat] = enhanceBonus[stat] + bonus
            end
        end
    end
    
    companion.attack = companion.baseAttack + equipStats.attack + enhanceBonus.attack
    companion.defense = companion.baseDefense + equipStats.defense + enhanceBonus.defense
    companion.speed = companion.baseSpeed + equipStats.speed + enhanceBonus.speed
    companion.crit = companion.baseCrit + equipStats.crit + enhanceBonus.crit
    companion.eva = companion.baseEva + equipStats.eva + enhanceBonus.eva
    
    local totalDef = companion.defense + enhanceBonus.defense
    companion.defPercent = math.min(MAX_DEF_PERCENT, math.floor(totalDef / DEF_TO_PERCENT))
    
    local newMaxHp = companion.baseHp + equipStats.hp + enhanceBonus.hp
    if newMaxHp ~= companion.maxHp then
        local hpRatio = companion.maxHp > 0 and companion.hp / companion.maxHp or 1
        companion.maxHp = newMaxHp
        companion.hp = math.floor(newMaxHp * hpRatio)
    end
end

function CompanionSystem:equipItem(companionId, slot, item)
    local companion = self:getCompanion(companionId)
    if not companion then return false, "伙伴未找到" end
    
    local oldItem = companion.equipment[slot]
    companion.equipment[slot] = item
    self:updateCompanionStats(companion)
    return true, oldItem
end

function CompanionSystem:unequipItem(companionId, slot)
    local companion = self:getCompanion(companionId)
    if not companion then return false, "伙伴未找到" end
    
    local item = companion.equipment[slot]
    companion.equipment[slot] = nil
    self:updateCompanionStats(companion)
    return true, item
end

function CompanionSystem:setEnhanceLevel(companionId, slot, level)
    local companion = self:getCompanion(companionId)
    if not companion then return false end
    
    companion.enhanceLevels[slot] = level
    self:updateCompanionStats(companion)
    return true
end

function CompanionSystem:takeDamage(companion, damage)
    if not companion then return 0 end
    
    local reduction = companion.defPercent
    if companion.isDefending then
        reduction = reduction + 25
    end
    reduction = math.min(MAX_DEF_PERCENT + 25, reduction)
    
    local actualDamage = math.floor(damage * (100 - reduction) / 100)
    actualDamage = math.max(1, actualDamage)
    
    companion.hp = companion.hp - actualDamage
    if companion.hp < 0 then companion.hp = 0 end
    
    companion.isDefending = false
    return actualDamage
end

function CompanionSystem:heal(companion, amount)
    if not companion then return end
    companion.hp = math.min(companion.maxHp, companion.hp + amount)
end

function CompanionSystem:calculateDamage(companion)
    if not companion then return 0, false end
    
    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    local damage = math.floor(companion.attack * multiplier)
    
    local isCrit = math.random(100) <= companion.crit
    if isCrit then
        damage = math.floor(damage * 1.5)
    end
    
    return damage, isCrit
end

function CompanionSystem:checkEvade(companion)
    if not companion then return false end
    return math.random(100) <= companion.eva
end

function CompanionSystem:isAlive(companion)
    return companion and companion.hp > 0
end

function CompanionSystem:getHPPercent(companion)
    if not companion or companion.maxHp <= 0 then return 0 end
    return companion.hp / companion.maxHp
end

function CompanionSystem:reviveAll()
    for _, companion in ipairs(self.companions) do
        companion.hp = companion.maxHp
        companion.isDefending = false
    end
end

function CompanionSystem:getAlivePartyMembers()
    local alive = {}
    for _, companion in ipairs(self.activeParty) do
        if self:isAlive(companion) then
            table.insert(alive, companion)
        end
    end
    return alive
end

function CompanionSystem:serialize()
    local data = {
        companions = {},
        activePartyIds = {}
    }
    
    for _, companion in ipairs(self.companions) do
        local companionData = {
            id = companion.id,
            templateId = companion.templateId,
            hp = companion.hp,
            equipment = {},
            enhanceLevels = {},
            inParty = companion.inParty,
            slot = companion.slot
        }
        
        for slot, item in pairs(companion.equipment) do
            if item then
                companionData.equipment[slot] = item.id
            end
        end
        companionData.enhanceLevels = companion.enhanceLevels
        
        table.insert(data.companions, companionData)
        if companion.inParty then
            table.insert(data.activePartyIds, companion.id)
        end
    end
    
    return data
end

function CompanionSystem:deserialize(data, itemDatabase)
    if not data then return end
    
    self.companions = {}
    self.activeParty = {}
    
    for _, companionData in ipairs(data.companions or {}) do
        local template = nil
        for _, t in ipairs(COMPANION_TEMPLATES) do
            if t.id == companionData.templateId then
                template = t
                break
            end
        end
        
        if template then
            local companion = createCompanion(template, #self.companions + 1)
            companion.id = companionData.id
            companion.hp = companionData.hp or companion.maxHp
            companion.inParty = companionData.inParty or false
            companion.slot = companionData.slot
            
            if companionData.equipment and itemDatabase then
                for slot, itemId in pairs(companionData.equipment) do
                    local item = itemDatabase.getItem(itemId)
                    if item then
                        companion.equipment[slot] = item
                    end
                end
            end
            
            if companionData.enhanceLevels then
                companion.enhanceLevels = companionData.enhanceLevels
            end
            
            table.insert(self.companions, companion)
            
            if companion.inParty then
                table.insert(self.activeParty, companion)
            end
        end
    end
end

function CompanionSystem:getCompanionEquipmentInfo(companionId)
    local companion = self:getCompanion(companionId)
    if not companion then return nil end
    
    local info = {}
    for slot, item in pairs(companion.equipment) do
        if item then
            info[slot] = {
                id = item.id,
                name = item.name,
                enhanceLevel = companion.enhanceLevels[slot] or 0
            }
        else
            info[slot] = nil
        end
    end
    return info
end

function CompanionSystem:getEquipmentSlots()
    return {"weapon", "hat", "clothes", "shoes", "necklace"}
end

CompanionSystem.TEMPLATES = COMPANION_TEMPLATES
CompanionSystem.BASE_STATS = BASE_STATS

return CompanionSystem
