local SimEntity = {}
SimEntity.__index = SimEntity

local MAX_DEF_PERCENT = 50

function SimEntity.new(config)
    local self = setmetatable({}, SimEntity)
    
    self.id = config.id or "entity"
    self.name = config.name or "Unknown"
    self.team = config.team or "player"
    
    self.maxHp = config.hp or 100
    self.hp = self.maxHp
    self.maxMp = config.mp or 50
    self.mp = self.maxMp
    
    self.attack = config.attack or 10
    self.defense = config.defense or 5
    self.defPercent = config.defPercent or 0
    self.magicAttack = config.magicAttack or 0
    self.speed = config.speed or 5
    
    self.crit = config.crit or 5
    self.eva = config.eva or 3
    
    self.skills = config.skills or {}
    self.skillLevels = config.skillLevels or {}
    
    self.isDefending = false
    self.isAlive = true
    
    self.stats = {
        damageDealt = 0,
        damageTaken = 0,
        healingDone = 0,
        skillsUsed = {},
        attacksLanded = 0,
        attacksMissed = 0,
        critsLanded = 0,
        timesEvaded = 0,
        turnsTaken = 0
    }
    
    return self
end

function SimEntity:takeDamage(damage)
    local reduction = self.defPercent
    if self.isDefending then
        reduction = reduction + 25
    end
    reduction = math.min(MAX_DEF_PERCENT + 25, reduction)
    
    local actualDamage = math.floor(damage * (100 - reduction) / 100)
    actualDamage = math.max(1, actualDamage)
    
    self.hp = self.hp - actualDamage
    self.stats.damageTaken = self.stats.damageTaken + actualDamage
    
    if self.hp <= 0 then
        self.hp = 0
        self.isAlive = false
    end
    
    return actualDamage
end

function SimEntity:heal(amount)
    local actualHeal = math.min(amount, self.maxHp - self.hp)
    self.hp = self.hp + actualHeal
    self.stats.healingDone = self.stats.healingDone + actualHeal
    return actualHeal
end

function SimEntity:useMp(amount)
    if self.mp >= amount then
        self.mp = self.mp - amount
        return true
    end
    return false
end

function SimEntity:restoreMp(amount)
    self.mp = math.min(self.maxMp, self.mp + amount)
end

function SimEntity:calculateDamage(isMagic)
    local baseAtk = isMagic and self.magicAttack or self.attack
    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    local damage = math.floor(baseAtk * multiplier)
    
    local isCrit = math.random(100) <= self.crit
    if isCrit then
        damage = math.floor(damage * 1.5)
        self.stats.critsLanded = self.stats.critsLanded + 1
    end
    
    return damage, isCrit
end

function SimEntity:checkEvade()
    local evaded = math.random(100) <= self.eva
    if evaded then
        self.stats.timesEvaded = self.stats.timesEvaded + 1
    end
    return evaded
end

function SimEntity:recordDamageDealt(damage)
    self.stats.damageDealt = self.stats.damageDealt + damage
    self.stats.attacksLanded = self.stats.attacksLanded + 1
end

function SimEntity:recordMiss()
    self.stats.attacksMissed = self.stats.attacksMissed + 1
end

function SimEntity:recordSkillUse(skillId)
    self.stats.skillsUsed[skillId] = (self.stats.skillsUsed[skillId] or 0) + 1
    self.stats.turnsTaken = self.stats.turnsTaken + 1
end

function SimEntity:resetStats()
    self.stats = {
        damageDealt = 0,
        damageTaken = 0,
        healingDone = 0,
        skillsUsed = {},
        attacksLanded = 0,
        attacksMissed = 0,
        critsLanded = 0,
        timesEvaded = 0,
        turnsTaken = 0
    }
end

function SimEntity:reset()
    self.hp = self.maxHp
    self.mp = self.maxMp
    self.isAlive = true
    self.isDefending = false
    self:resetStats()
end

function SimEntity:getHpPercent()
    return self.hp / self.maxHp
end

function SimEntity:getMpPercent()
    return self.mp / self.maxMp
end

function SimEntity:getSummary()
    return {
        name = self.name,
        team = self.team,
        hpRemaining = self.hp,
        maxHp = self.maxHp,
        damageDealt = self.stats.damageDealt,
        damageTaken = self.stats.damageTaken,
        healingDone = self.stats.healingDone,
        dps = self.stats.turnsTaken > 0 and math.floor(self.stats.damageDealt / self.stats.turnsTaken) or 0,
        critRate = self.stats.attacksLanded > 0 and (self.stats.critsLanded / self.stats.attacksLanded * 100) or 0,
        skillsUsed = self.stats.skillsUsed,
        turnsTaken = self.stats.turnsTaken,
        alive = self.isAlive
    }
end

return SimEntity
