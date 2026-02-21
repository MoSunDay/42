local SpiritCrystalSystem = {}
SpiritCrystalSystem.__index = SpiritCrystalSystem

SpiritCrystalSystem.TYPES = {
    CRIMSON = "crimson",
    AZURE = "azure",
    EMERALD = "emerald",
    VIOLET = "violet",
    GOLDEN = "golden"
}

SpiritCrystalSystem.TYPE_NAMES = {
    crimson = "赤灵晶",
    azure = "苍灵晶",
    emerald = "翠灵晶",
    violet = "紫灵晶",
    golden = "黄灵晶"
}

SpiritCrystalSystem.TIER_NAMES = {
    [1] = "碎片",
    [2] = "晶体",
    [3] = "宝石",
    [4] = "核心"
}

SpiritCrystalSystem.STATS_MAP = {
    crimson = "attack",
    azure = "defense",
    emerald = "hp",
    violet = "crit",
    golden = "eva"
}

local CRYSTAL_DATA = {
    crimson = {
        color = {1, 0.2, 0.2},
        stat = "attack",
        tiers = {
            {value = 1, name = "赤灵晶碎片", dropWeight = 60},
            {value = 3, name = "赤灵晶体", dropWeight = 25},
            {value = 8, name = "赤灵宝石", dropWeight = 12},
            {value = 20, name = "赤灵核心", dropWeight = 3}
        }
    },
    azure = {
        color = {0.2, 0.5, 1},
        stat = "defense",
        tiers = {
            {value = 1, name = "苍灵晶碎片", dropWeight = 60},
            {value = 3, name = "苍灵晶体", dropWeight = 25},
            {value = 8, name = "苍灵宝石", dropWeight = 12},
            {value = 20, name = "苍灵核心", dropWeight = 3}
        }
    },
    emerald = {
        color = {0.2, 0.9, 0.4},
        stat = "hp",
        tiers = {
            {value = 1, name = "翠灵晶碎片", dropWeight = 60},
            {value = 3, name = "翠灵晶体", dropWeight = 25},
            {value = 8, name = "翠灵宝石", dropWeight = 12},
            {value = 20, name = "翠灵核心", dropWeight = 3}
        }
    },
    violet = {
        color = {0.7, 0.3, 0.9},
        stat = "crit",
        tiers = {
            {value = 1, name = "紫灵晶碎片", dropWeight = 60},
            {value = 3, name = "紫灵晶体", dropWeight = 25},
            {value = 8, name = "紫灵宝石", dropWeight = 12},
            {value = 20, name = "紫灵核心", dropWeight = 3}
        }
    },
    golden = {
        color = {1, 0.85, 0.2},
        stat = "eva",
        tiers = {
            {value = 1, name = "黄灵晶碎片", dropWeight = 60},
            {value = 3, name = "黄灵晶体", dropWeight = 25},
            {value = 8, name = "黄灵宝石", dropWeight = 12},
            {value = 20, name = "黄灵核心", dropWeight = 3}
        }
    }
}

SpiritCrystalSystem.MAX_ENHANCE_LEVEL = 10

SpiritCrystalSystem.ENHANCE_COSTS = {
    1, 2, 4, 6, 10, 15, 22, 30, 40, 55
}

function SpiritCrystalSystem.new()
    local self = setmetatable({}, SpiritCrystalSystem)
    
    self.crystals = {
        crimson = {0, 0, 0, 0},
        azure = {0, 0, 0, 0},
        emerald = {0, 0, 0, 0},
        violet = {0, 0, 0, 0},
        golden = {0, 0, 0, 0}
    }
    
    return self
end

function SpiritCrystalSystem:addCrystal(crystalType, tier, amount)
    if not self.crystals[crystalType] then return false end
    if tier < 1 or tier > 4 then return false end
    
    self.crystals[crystalType][tier] = self.crystals[crystalType][tier] + (amount or 1)
    return true
end

function SpiritCrystalSystem:getCrystalCount(crystalType, tier)
    if not self.crystals[crystalType] then return 0 end
    if tier < 1 or tier > 4 then return 0 end
    return self.crystals[crystalType][tier]
end

function SpiritCrystalSystem:removeCrystal(crystalType, tier, amount)
    if self:getCrystalCount(crystalType, tier) < (amount or 1) then
        return false
    end
    self.crystals[crystalType][tier] = self.crystals[crystalType][tier] - (amount or 1)
    return true
end

function SpiritCrystalSystem:getTotalCrystalValue(crystalType)
    local data = CRYSTAL_DATA[crystalType]
    if not data then return 0 end
    
    local total = 0
    for tier, count in ipairs(self.crystals[crystalType]) do
        total = total + count * data.tiers[tier].value
    end
    return total
end

function SpiritCrystalSystem:canEnhance(crystalType, currentLevel)
    if currentLevel >= SpiritCrystalSystem.MAX_ENHANCE_LEVEL then
        return false, "已达最大强化等级"
    end
    
    local totalValue = self:getTotalCrystalValue(crystalType)
    local cost = SpiritCrystalSystem.ENHANCE_COSTS[currentLevel + 1]
    
    if totalValue < cost then
        return false, string.format("需要 %d 点灵晶值，当前 %d 点", cost, totalValue)
    end
    
    return true, cost
end

function SpiritCrystalSystem:enhance(crystalType, currentLevel)
    local canEnhance, costOrMsg = self:canEnhance(crystalType, currentLevel)
    if not canEnhance then
        return false, costOrMsg
    end
    
    local cost = costOrMsg
    local remaining = cost
    
    for tier = 4, 1, -1 do
        local data = CRYSTAL_DATA[crystalType]
        local value = data.tiers[tier].value
        local count = self.crystals[crystalType][tier]
        
        while count > 0 and remaining >= value do
            remaining = remaining - value
            count = count - 1
            self.crystals[crystalType][tier] = count
        end
    end
    
    if remaining > 0 then
        for tier = 1, 4 do
            local data = CRYSTAL_DATA[crystalType]
            local value = data.tiers[tier].value
            local count = self.crystals[crystalType][tier]
            
            while count > 0 and remaining > 0 do
                remaining = remaining - value
                count = count - 1
                self.crystals[crystalType][tier] = count
            end
        end
    end
    
    return true, "强化成功"
end

function SpiritCrystalSystem:getEnhancementBonus(crystalType, level)
    local baseValues = {
        attack = 2,
        defense = 2,
        hp = 15,
        crit = 1.5,
        eva = 1.5
    }
    
    local stat = CRYSTAL_DATA[crystalType] and CRYSTAL_DATA[crystalType].stat
    if not stat then return 0 end
    
    local base = baseValues[stat] or 1
    
    if stat == "crit" or stat == "eva" then
        return math.floor(base * level * (1 + level * 0.08))
    else
        return math.floor(base * level * (1 + level * 0.1))
    end
end

function SpiritCrystalSystem.getPreferredCrystalType(enemy)
    if not enemy then return nil end
    
    local stats = {
        {type = "crimson", value = (enemy.attack or 0) / 20},
        {type = "azure", value = (enemy.defense or 0) / 10 + (enemy.defPercent or 0) / 20},
        {type = "emerald", value = (enemy.maxHp or 0) / 300},
        {type = "violet", value = (enemy.crit or 0) / 10},
        {type = "golden", value = (enemy.eva or 0) / 8}
    }
    
    table.sort(stats, function(a, b) return a.value > b.value end)
    
    return stats[1].type
end

function SpiritCrystalSystem.generateDrop(enemyTier, preferredType)
    local dropCount = enemyTier
    local drops = {}
    
    local tierWeights = {
        [1] = {70, 22, 7, 1},
        [2] = {50, 35, 12, 3},
        [3] = {30, 35, 25, 10},
        [4] = {15, 25, 40, 20}
    }
    
    local weights = tierWeights[enemyTier] or tierWeights[1]
    
    for i = 1, dropCount do
        local crystalType
        
        if preferredType and math.random(100) <= 35 then
            crystalType = preferredType
        else
            local crystalTypes = {"crimson", "azure", "emerald", "violet", "golden"}
            crystalType = crystalTypes[math.random(#crystalTypes)]
        end
        
        local tierRoll = math.random(100)
        local tierSum = 0
        local selectedTier = 1
        
        for tier, weight in ipairs(weights) do
            tierSum = tierSum + weight
            if tierRoll <= tierSum then
                selectedTier = tier
                break
            end
        end
        
        local data = CRYSTAL_DATA[crystalType]
        table.insert(drops, {
            type = crystalType,
            tier = selectedTier,
            name = data.tiers[selectedTier].name,
            value = data.tiers[selectedTier].value
        })
    end
    
    return drops
end

function SpiritCrystalSystem:getAllCrystals()
    return self.crystals
end

function SpiritCrystalSystem:getCrystalInfo(crystalType, tier)
    local data = CRYSTAL_DATA[crystalType]
    if not data or not data.tiers[tier] then return nil end
    
    return {
        type = crystalType,
        tier = tier,
        name = data.tiers[tier].name,
        value = data.tiers[tier].value,
        stat = data.stat,
        color = data.color,
        count = self.crystals[crystalType][tier]
    }
end

function SpiritCrystalSystem:serialize()
    return {
        crystals = self.crystals
    }
end

function SpiritCrystalSystem:deserialize(data)
    if not data or not data.crystals then return end
    
    for crystalType, tiers in pairs(data.crystals) do
        if self.crystals[crystalType] then
            self.crystals[crystalType] = tiers
        end
    end
end

SpiritCrystalSystem.CRYSTAL_DATA = CRYSTAL_DATA

return SpiritCrystalSystem
