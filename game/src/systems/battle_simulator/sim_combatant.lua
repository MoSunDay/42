local CombatUtils = require("src.systems.combat_utils")
local ClassDatabase = require("src.data.class_database")

local SimCombatant = {}

function SimCombatant.create(name)
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
        is_alive = true,
        _team = nil,
    }
end

function SimCombatant.from_class(classId, level, name)
    local self = SimCombatant.create(name)
    level = level or 1
    self.level = level
    local class = ClassDatabase.get_class(classId)
    if class then
        self.name = name or class.name
        local stats = ClassDatabase.get_base_stats(classId)
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
    SimCombatant.apply_level_scaling(self)
    return self
end

function SimCombatant.from_enemy(enemyType, level, name)
    local self = SimCombatant.create(name)
    level = level or 1
    self.level = level
    local Enemy = require("entities.enemy")
    local enemyData = Enemy.get_all_types()[enemyType]
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
    SimCombatant.apply_level_scaling(self)
    return self
end

function SimCombatant.from_stats(stats, name)
    local self = SimCombatant.create(name)
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

function SimCombatant.apply_level_scaling(self)
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
    self.is_alive = true
end

function SimCombatant.take_damage(self, damage)
    local result = CombatUtils.take_damageMutating(self, damage)
    self.is_alive = self.hp > 0
    return result
end

function SimCombatant.heal(self, amount)
    local oldHp = self.hp
    self.hp = math.min(self.maxHp, self.hp + amount)
    return self.hp - oldHp
end

function SimCombatant.is_alive(self)
    return CombatUtils.is_alive(self)
end

function SimCombatant.get_hp_percent(self)
    return CombatUtils.get_hp_percent(self)
end

function SimCombatant.calculate_damage(self)
    return CombatUtils.calculate_damageMutating(self)
end

function SimCombatant.check_evade(self)
    return CombatUtils.check_evade(self)
end

function SimCombatant.get_summary(self)
    return string.format("%s Lv.%d HP:%d/%d MP:%d/%d ATK:%d DEF:%d SPD:%d",
        self.name, self.level, self.hp, self.maxHp, self.mp, self.maxMp,
        self.attack, self.defense, self.speed)
end

function SimCombatant.use_mana(self, cost)
    if self.mp >= cost then
        self.mp = self.mp - cost
        return true
    end
    return false
end

function SimCombatant.set_defending(self, defending)
    self.isDefending = defending
end

function SimCombatant.decide_action(self, context)
    local hpPercent = self.hp / self.maxHp
    
    if hpPercent < 0.3 and math.random() < 0.3 then
        return {type = "defend"}
    end
    
    if self.skills and #self.skills > 0 and self.mp > 0 then
        local SkillDatabase = require("src.systems.battle_simulator.skill_database")
        for _, skillId in ipairs(self.skills) do
            local skill = SkillDatabase.get_skill(skillId)
            if skill and self.mp >= skill.mpCost then
                if math.random() < 0.5 then
                    local targets = context.enemies
                    if #targets > 0 then
                        return {type = "skill", skill = skill, targets = {targets[math.random(#targets)]}}
                    end
                end
            end
        end
    end
    
    local aliveEnemies = {}
    for _, e in ipairs(context.enemies) do
        if e.is_alive then
            table.insert(aliveEnemies, e)
        end
    end
    
    if #aliveEnemies > 0 then
        return {type = "attack", target = aliveEnemies[math.random(#aliveEnemies)]}
    end
    
    return {type = "defend"}
end

return SimCombatant
