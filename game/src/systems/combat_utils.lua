local CombatUtils = {}

CombatUtils.MAX_DEF_PERCENT = 50
CombatUtils.DEFEND_BONUS = 25
CombatUtils.MAX_TOTAL_DEF = CombatUtils.MAX_DEF_PERCENT + CombatUtils.DEFEND_BONUS
CombatUtils.DAMAGE_VARIANCE = 0.2
CombatUtils.CRIT_MULTIPLIER = 1.5
CombatUtils.DEF_TO_PERCENT = 5

function CombatUtils.take_damage(state, damage)
    local reduction = state.defPercent or 0
    if state.isDefending then
        reduction = reduction + CombatUtils.DEFEND_BONUS
    end
    reduction = math.min(CombatUtils.MAX_TOTAL_DEF, reduction)
    local actualDamage = math.floor(damage * (100 - reduction) / 100)
    actualDamage = math.max(1, actualDamage)
    local newHp = math.max(0, state.hp - actualDamage)
    local newState = {}
    for k, v in pairs(state) do newState[k] = v end
    newState.hp = newHp
    newState.isDefending = false
    return newState, actualDamage
end

function CombatUtils.heal(state, amount)
    local newState = {}
    for k, v in pairs(state) do newState[k] = v end
    newState.hp = math.min(state.maxHp, state.hp + amount)
    return newState
end

function CombatUtils.is_alive(state)
    return state.hp > 0
end

function CombatUtils.get_hp_percent(state)
    if not state.maxHp or state.maxHp <= 0 then return 0 end
    return state.hp / state.maxHp
end

function CombatUtils.calculate_damage(state)
    local multiplier = 1 + (math.random() * 2 - 1) * CombatUtils.DAMAGE_VARIANCE
    local damage = math.floor((state.attack or 0) * multiplier)
    local isCrit = math.random(100) <= (state.crit or 0)
    if isCrit then
        damage = math.floor(damage * CombatUtils.CRIT_MULTIPLIER)
    end
    return damage, isCrit
end

function CombatUtils.check_evade(state)
    return math.random(100) <= (state.eva or 0)
end

function CombatUtils.calc_def_percent(defense)
    return math.min(CombatUtils.MAX_DEF_PERCENT, math.floor((defense or 0) / CombatUtils.DEF_TO_PERCENT))
end

function CombatUtils.take_damage_mutating(self, damage)
    local reduction = self.defPercent or 0
    if self.isDefending then
        reduction = reduction + CombatUtils.DEFEND_BONUS
    end
    reduction = math.min(CombatUtils.MAX_TOTAL_DEF, reduction)
    local actualDamage = math.floor(damage * (100 - reduction) / 100)
    actualDamage = math.max(1, actualDamage)
    self.hp = math.max(0, self.hp - actualDamage)
    self.isDefending = false
    return actualDamage
end

function CombatUtils.heal_mutating(self, amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

function CombatUtils.calculate_damage_mutating(self)
    local multiplier = 1 + (math.random() * 2 - 1) * CombatUtils.DAMAGE_VARIANCE
    local damage = math.floor(self.attack * multiplier)
    local isCrit = math.random(100) <= self.crit
    if isCrit then
        damage = math.floor(damage * CombatUtils.CRIT_MULTIPLIER)
    end
    return damage, isCrit
end

return CombatUtils
