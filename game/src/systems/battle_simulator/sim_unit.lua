local SimUnit = {}
SimUnit.__index = SimUnit

local ClassDatabase = require("src.data.class_database")
local Enemy = require("entities.enemy")

function SimUnit.new(name)
    local self = setmetatable({}, SimUnit)
    self.name = name or "Unit"
    self.hp = 100
    self.maxHp = 100
    self.mp = 50
    self.maxMp = 50
    self.attack = 15
    self.defense = 5
    self.magicAttack = 10
    self.defPercent = 5
    self.speed = 5
    self.crit = 5
    self.eva = 3
    self.level = 1
    self.skills = {}
    self.isDefending = false
    self._team = nil
    return self
end

function SimUnit.fromClass(classId, level, name)
    local self = SimUnit.new(name)
    level = level or 1
    self.level = level
    
    local class = ClassDatabase.getClass(classId)
    if class then
        self.name = name or class.name
        local stats = ClassDatabase.getBaseStats(classId)
        if stats then
            self.hp = stats.hp or 100
            self.maxHp = stats.maxHp or self.hp
            self.mp = stats.mp or 50
            self.maxMp = stats.maxMp or self.mp
            self.attack = stats.attack or 15
            self.defense = stats.defense or 5
            self.magicAttack = stats.magicAttack or 10
            self.defPercent = stats.defPercent or 5
            self.speed = stats.speed or 5
            self.crit = (stats.crit or 5) + (stats.critBonus or 0)
            self.eva = stats.eva or 3
        end
        
        if class.skillIds then
            self.skills = class.skillIds
        end
    end
    
    self:applyLevelScaling()
    return self
end

function SimUnit.fromEnemy(enemyType, level, name)
    local self = SimUnit.new(name)
    level = level or 1
    self.level = level
    
    local enemyData = Enemy.getAllTypes()[enemyType]
    if enemyData then
        self.name = name or enemyData.name
        self.hp = enemyData.hp or 100
        self.maxHp = enemyData.maxHp or self.hp
        self.mp = 30
        self.maxMp = 30
        self.attack = enemyData.attack or 15
        self.defense = enemyData.defense or 5
        self.magicAttack = enemyData.attack or 10
        self.defPercent = enemyData.defPercent or 5
        self.speed = enemyData.speed or 5
        self.crit = enemyData.crit or 5
        self.eva = enemyData.eva or 3
    end
    
    self:applyLevelScaling()
    return self
end

function SimUnit.fromStats(stats, name)
    local self = SimUnit.new(name)
    
    self.hp = stats.hp or 100
    self.maxHp = stats.maxHp or self.hp
    self.mp = stats.mp or 50
    self.maxMp = stats.maxMp or self.mp
    self.attack = stats.attack or 15
    self.defense = stats.defense or 5
    self.magicAttack = stats.magicAttack or 10
    self.defPercent = stats.defPercent or 5
    self.speed = stats.speed or 5
    self.crit = stats.crit or 5
    self.eva = stats.eva or 3
    self.level = stats.level or 1
    self.skills = stats.skills or {}
    
    return self
end

function SimUnit:applyLevelScaling()
    local scalePerLevel = 0.05
    local levelMult = 1 + scalePerLevel * (self.level - 1)
    
    self.maxHp = math.floor(self.maxHp * levelMult)
    self.hp = self.maxHp
    self.maxMp = math.floor(self.maxMp * levelMult)
    self.mp = self.maxMp
    self.attack = math.floor(self.attack * levelMult)
    self.defense = math.floor(self.defense * levelMult)
    self.magicAttack = math.floor(self.magicAttack * levelMult)
    self.speed = math.floor(self.speed * (1 + (levelMult - 1) * 0.5))
end

function SimUnit:reset()
    self.hp = self.maxHp
    self.mp = self.maxMp
    self.isDefending = false
end

function SimUnit:takeDamage(damage)
    local reduction = self.defPercent or 0
    if self.isDefending then
        reduction = reduction + 25
    end
    reduction = math.min(75, reduction)
    
    local actualDamage = math.floor(damage * (100 - reduction) / 100)
    actualDamage = math.max(1, actualDamage)
    
    self.hp = self.hp - actualDamage
    if self.hp < 0 then
        self.hp = 0
    end
    
    return actualDamage
end

function SimUnit:heal(amount)
    local oldHp = self.hp
    self.hp = math.min(self.maxHp, self.hp + amount)
    return self.hp - oldHp
end

function SimUnit:isAlive()
    return self.hp > 0
end

function SimUnit:getHPPercent()
    return self.hp / self.maxHp
end

function SimUnit:calculateDamage()
    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    local damage = math.floor(self.attack * multiplier)
    
    local isCrit = math.random(100) <= self.crit
    if isCrit then
        damage = math.floor(damage * 1.5)
    end
    
    return damage, isCrit
end

function SimUnit:checkEvade()
    return math.random(100) <= self.eva
end

function SimUnit:getSummary()
    return string.format("%s Lv.%d HP:%d/%d MP:%d/%d ATK:%d DEF:%d SPD:%d",
        self.name, self.level, self.hp, self.maxHp, self.mp, self.maxMp,
        self.attack, self.defense, self.speed)
end

return SimUnit
