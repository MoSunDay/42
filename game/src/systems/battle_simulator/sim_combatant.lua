local CombatUtils = require("src.systems.combat_utils")
local ClassDatabase = require("src.data.class_database")

local SimCombatant = {}

function SimCombatant.new(name)
    return {
        name = name or "Unit",
        hp = 100,
        maxHp = 100,
        mp = 50,
        maxMp = 50,
        attack = 15,
        defense = 5,
        magicAttack = 10,
        defPercent = 5,
        speed = 5,
        crit = 5,
        eva = 3,
        level = 1,
        skills = {},
        isDefending = false,
        _team = nil,
    }
end

function SimCombatant.fromClass(classId, level, name)
    local self = SimCombatant.new(name)
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
    SimCombatant.applyLevelScaling(self)
    return self
end

function SimCombatant.fromEnemy(enemyType, level, name)
    local self = SimCombatant.new(name)
    level = level or 1
    self.level = level
    local Enemy = require("entities.enemy")
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
    SimCombatant.applyLevelScaling(self)
    return self
end

function SimCombatant.fromStats(stats, name)
    local self = SimCombatant.new(name)
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

function SimCombatant.applyLevelScaling(self)
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

function SimCombatant.reset(self)
    self.hp = self.maxHp
    self.mp = self.maxMp
    self.isDefending = false
end

function SimCombatant.takeDamage(self, damage)
    return CombatUtils.takeDamageMutating(self, damage)
end

function SimCombatant.heal(self, amount)
    local oldHp = self.hp
    self.hp = math.min(self.maxHp, self.hp + amount)
    return self.hp - oldHp
end

function SimCombatant.isAlive(self)
    return CombatUtils.isAlive(self)
end

function SimCombatant.getHPPercent(self)
    return CombatUtils.getHPPercent(self)
end

function SimCombatant.calculateDamage(self)
    return CombatUtils.calculateDamageMutating(self)
end

function SimCombatant.checkEvade(self)
    return CombatUtils.checkEvade(self)
end

function SimCombatant.getSummary(self)
    return string.format("%s Lv.%d HP:%d/%d MP:%d/%d ATK:%d DEF:%d SPD:%d",
        self.name, self.level, self.hp, self.maxHp, self.mp, self.maxMp,
        self.attack, self.defense, self.speed)
end

return SimCombatant
