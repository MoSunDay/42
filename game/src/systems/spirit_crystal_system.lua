local SpiritCrystalSystem = {}
SpiritCrystalSystem.__index = SpiritCrystalSystem

SpiritCrystalSystem.TIER_NAMES = {
    [1] = "灵晶碎片",
    [2] = "灵晶体",
    [3] = "灵宝石",
    [4] = "灵核心"
}

SpiritCrystalSystem.TIER_VALUES = {
    [1] = 10,
    [2] = 50,
    [3] = 200,
    [4] = 1000
}

SpiritCrystalSystem.TIER_COLORS = {
    [1] = {0.6, 0.6, 0.7},
    [2] = {0.5, 0.7, 0.9},
    [3] = {0.7, 0.5, 0.9},
    [4] = {1.0, 0.85, 0.3}
}

SpiritCrystalSystem.MAX_ENHANCE_LEVEL = 10

SpiritCrystalSystem.ENHANCE_COSTS = {
    100, 200, 400, 700, 1000, 1500, 2000, 3000, 4000, 5000
}

function SpiritCrystalSystem.new()
    local self = setmetatable({}, SpiritCrystalSystem)
    self.crystals = {0, 0, 0, 0}
    return self
end

function SpiritCrystalSystem:addCrystal(tier, amount)
    if tier < 1 or tier > 4 then return false end
    self.crystals[tier] = self.crystals[tier] + (amount or 1)
    return true
end

function SpiritCrystalSystem:addCrystalValue(value)
    local remaining = value
    for tier = 4, 1, -1 do
        local tierValue = SpiritCrystalSystem.TIER_VALUES[tier]
        while remaining >= tierValue do
            self.crystals[tier] = self.crystals[tier] + 1
            remaining = remaining - tierValue
        end
    end
    if remaining > 0 then
        self.crystals[1] = self.crystals[1] + remaining
    end
    return true
end

function SpiritCrystalSystem:getCrystalCount(tier)
    if tier < 1 or tier > 4 then return 0 end
    return self.crystals[tier]
end

function SpiritCrystalSystem:getTotalValue()
    local total = 0
    for tier = 1, 4 do
        total = total + self.crystals[tier] * SpiritCrystalSystem.TIER_VALUES[tier]
    end
    return total
end

function SpiritCrystalSystem:removeCrystal(tier, amount)
    if self.crystals[tier] < (amount or 1) then
        return false
    end
    self.crystals[tier] = self.crystals[tier] - (amount or 1)
    return true
end

function SpiritCrystalSystem:spendValue(cost)
    if self:getTotalValue() < cost then
        return false, "灵晶不足"
    end
    
    local remaining = cost
    for tier = 4, 1, -1 do
        local value = SpiritCrystalSystem.TIER_VALUES[tier]
        while self.crystals[tier] > 0 and remaining >= value do
            self.crystals[tier] = self.crystals[tier] - 1
            remaining = remaining - value
        end
    end
    
    if remaining > 0 then
        for tier = 1, 4 do
            local value = SpiritCrystalSystem.TIER_VALUES[tier]
            while self.crystals[tier] > 0 and remaining > 0 do
                self.crystals[tier] = self.crystals[tier] - 1
                remaining = remaining - value
            end
        end
    end
    
    return true
end

function SpiritCrystalSystem:canEnhance(currentLevel)
    if currentLevel >= SpiritCrystalSystem.MAX_ENHANCE_LEVEL then
        return false, "已达最大强化等级"
    end
    
    local cost = SpiritCrystalSystem.ENHANCE_COSTS[currentLevel + 1]
    local totalValue = self:getTotalValue()
    
    if totalValue < cost then
        return false, string.format("需要 %d 灵晶，当前 %d", cost, totalValue)
    end
    
    return true, cost
end

function SpiritCrystalSystem:enhance(currentLevel)
    local canEnhance, costOrMsg = self:canEnhance(currentLevel)
    if not canEnhance then
        return false, costOrMsg
    end
    
    return self:spendValue(costOrMsg)
end

function SpiritCrystalSystem.getEnhancementBonus(level)
    return level * 2
end

function SpiritCrystalSystem.generateDrop(enemyTier)
    local drops = {}
    local dropCount = enemyTier
    
    local tierWeights = {
        [1] = {70, 22, 7, 1},
        [2] = {50, 35, 12, 3},
        [3] = {30, 35, 25, 10},
        [4] = {15, 25, 40, 20}
    }
    
    local weights = tierWeights[enemyTier] or tierWeights[1]
    
    for i = 1, dropCount do
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
        
        table.insert(drops, {
            tier = selectedTier,
            name = SpiritCrystalSystem.TIER_NAMES[selectedTier],
            value = SpiritCrystalSystem.TIER_VALUES[selectedTier],
            color = SpiritCrystalSystem.TIER_COLORS[selectedTier]
        })
    end
    
    return drops
end

function SpiritCrystalSystem:getAllCrystals()
    return self.crystals
end

function SpiritCrystalSystem:getCrystalInfo(tier)
    if tier < 1 or tier > 4 then return nil end
    
    return {
        tier = tier,
        name = SpiritCrystalSystem.TIER_NAMES[tier],
        value = SpiritCrystalSystem.TIER_VALUES[tier],
        color = SpiritCrystalSystem.TIER_COLORS[tier],
        count = self.crystals[tier]
    }
end

function SpiritCrystalSystem:serialize()
    return { crystals = self.crystals }
end

function SpiritCrystalSystem:deserialize(data)
    if not data or not data.crystals then return end
    for i = 1, 4 do
        self.crystals[i] = data.crystals[i] or 0
    end
end

return SpiritCrystalSystem
