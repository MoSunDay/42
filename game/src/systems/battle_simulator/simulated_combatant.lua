local SimulatedCombatant = {}
SimulatedCombatant.__index = SimulatedCombatant

local MAX_DEF_PERCENT = 50

function SimulatedCombatant.new(config)
    local self = setmetatable({}, SimulatedCombatant)
    
    self.id = config.id or "unknown"
    self.name = config.name or "Combatant"
    self.team = config.team or "party"
    self.isPlayer = config.isPlayer or false
    
    self.maxHp = config.maxHp or config.hp or 100
    self.hp = config.hp or self.maxHp
    self.maxMp = config.maxMp or config.mp or 50
    self.mp = config.mp or self.maxMp
    
    self.attack = config.attack or 10
    self.defense = config.defense or 5
    self.magicAttack = config.magicAttack or 10
    self.defPercent = config.defPercent or 0
    self.speed = config.speed or 5
    self.crit = config.crit or 5
    self.eva = config.eva or 3
    
    self.isDefending = false
    self.isAlive = true
    
    self.skills = config.skills or {}
    self.aiType = config.aiType or "simple"
    
    self.originalHp = self.hp
    self.originalMp = self.mp
    
    return self
end

function SimulatedCombatant:reset()
    self.hp = self.originalHp
    self.mp = self.originalMp
    self.isDefending = false
    self.isAlive = true
end

function SimulatedCombatant:takeDamage(damage)
    local reduction = self.defPercent
    if self.isDefending then
        reduction = reduction + 25
    end
    reduction = math.min(MAX_DEF_PERCENT + 25, reduction)
    
    local actualDamage = math.max(1, math.floor(damage * (100 - reduction) / 100))
    self.hp = math.max(0, self.hp - actualDamage)
    
    if self.hp <= 0 then
        self.isAlive = false
    end
    
    return actualDamage
end

function SimulatedCombatant:heal(amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
    return amount
end

function SimulatedCombatant:useMana(cost)
    if self.mp >= cost then
        self.mp = self.mp - cost
        return true
    end
    return false
end

function SimulatedCombatant:calculateDamage(isMagic)
    local baseAttack = isMagic and self.magicAttack or self.attack
    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    local damage = math.floor(baseAttack * multiplier)
    
    local isCrit = math.random(100) <= self.crit
    if isCrit then
        damage = math.floor(damage * 1.5)
    end
    
    return damage, isCrit
end

function SimulatedCombatant:checkEvade()
    return math.random(100) <= self.eva
end

function SimulatedCombatant:getHPPercent()
    return self.hp / self.maxHp
end

function SimulatedCombatant:getMPPercent()
    return self.mp / self.maxMp
end

function SimulatedCombatant:setDefending(state)
    self.isDefending = state
end

function SimulatedCombatant:decideAction(context)
    local hpPercent = self:getHPPercent()
    
    if self.aiType == "defensive" and hpPercent < 0.3 then
        if math.random() < 0.5 then
            return { type = "defend" }
        end
    end
    
    if self.aiType == "aggressive" and #self.skills > 0 and hpPercent > 0.5 then
        if math.random() < 0.3 then
            local skill = self.skills[math.random(#self.skills)]
            if self.mp >= (skill.cost or 10) then
                return { type = "skill", skill = skill }
            end
        end
    end
    
    if #self.skills > 0 and self.mp >= 10 and math.random() < 0.2 then
        local skill = self.skills[math.random(#self.skills)]
        if self.mp >= (skill.cost or 10) then
            return { type = "skill", skill = skill }
        end
    end
    
    return { type = "attack" }
end

function SimulatedCombatant.fromEnemyType(enemyType, assetManager)
    local Enemy = require("entities.enemy")
    local template = Enemy.getAllTypes()[enemyType]
    if not template then return nil end
    
    return SimulatedCombatant.new({
        id = enemyType,
        name = template.name,
        team = "enemy",
        isPlayer = false,
        hp = template.hp,
        maxHp = template.maxHp,
        attack = template.attack,
        defense = template.defense,
        defPercent = template.defPercent or 0,
        speed = template.speed,
        crit = template.crit or 0,
        eva = template.eva or 0,
        aiType = template.multiTarget and "aggressive" or "simple",
    })
end

function SimulatedCombatant.fromClassId(classId)
    local ClassDatabase = require("src.data.class_database")
    local class = ClassDatabase.getClass(classId)
    if not class then return nil end
    
    local stats = ClassDatabase.getBaseStats(classId)
    
    return SimulatedCombatant.new({
        id = classId,
        name = class.name,
        team = "party",
        isPlayer = true,
        hp = stats.hp,
        maxHp = stats.maxHp,
        mp = stats.mp,
        maxMp = stats.maxMp,
        attack = stats.attack,
        defense = stats.defense,
        magicAttack = stats.magicAttack or 10,
        defPercent = 1,
        speed = stats.speed,
        crit = (stats.critBonus or 0) * 100 + 5,
        eva = 3,
        skills = {},
        aiType = "aggressive",
    })
end

return SimulatedCombatant
