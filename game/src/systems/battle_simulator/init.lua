local SkillDatabase = require("src.systems.battle_simulator.skill_database")
local SimCombatant = require("src.systems.battle_simulator.sim_combatant")

local BattleSimulator = {}

function BattleSimulator.new()
    return {
        teamA = {},
        teamB = {},
        turn = 0,
        log = {},
        isRunning = false,
        winner = nil,
        config = {
            maxTurns = 100,
            logDetail = "normal",
        },
    }
end

function BattleSimulator.reset(state)
    state.teamA = {}
    state.teamB = {}
    state.turn = 0
    state.log = {}
    state.isRunning = false
    state.winner = nil
end

function BattleSimulator.addUnitToTeamA(state, classId, level, name)
    local unit = SimCombatant.fromClass(classId, level, name)
    table.insert(state.teamA, unit)
    return unit
end

function BattleSimulator.addUnitToTeamB(state, enemyType, level, name)
    local unit = SimCombatant.fromEnemy(enemyType, level, name)
    table.insert(state.teamB, unit)
    return unit
end

function BattleSimulator.addCustomUnitToTeamB(state, stats, name)
    local unit = SimCombatant.fromStats(stats, name)
    table.insert(state.teamB, unit)
    return unit
end

function BattleSimulator.getAliveUnits(state, team)
    local alive = {}
    for _, unit in ipairs(team) do
        if SimCombatant.isAlive(unit) then
            table.insert(alive, unit)
        end
    end
    return alive
end

function BattleSimulator.sortUnitsBySpeed(state, units)
    table.sort(units, function(a, b)
        return a.speed > b.speed
    end)
end

function BattleSimulator.checkVictory(state)
    local aliveA = BattleSimulator.getAliveUnits(state, state.teamA)
    local aliveB = BattleSimulator.getAliveUnits(state, state.teamB)
    
    if #aliveA == 0 then
        state.winner = "B"
        return true
    end
    if #aliveB == 0 then
        state.winner = "A"
        return true
    end
    return false
end

function BattleSimulator.logMessage(state, msg)
    if state.config.logDetail ~= "none" then
        table.insert(state.log, msg)
    end
end

function BattleSimulator.executeTurn(state)
    state.turn = state.turn + 1
    BattleSimulator.logMessage(state, string.format("=== Turn %d ===", state.turn))
    
    local allUnits = {}
    for _, unit in ipairs(BattleSimulator.getAliveUnits(state, state.teamA)) do
        unit._team = "A"
        table.insert(allUnits, unit)
    end
    for _, unit in ipairs(BattleSimulator.getAliveUnits(state, state.teamB)) do
        unit._team = "B"
        table.insert(allUnits, unit)
    end
    
    BattleSimulator.sortUnitsBySpeed(state, allUnits)
    
    for _, unit in ipairs(allUnits) do
        if SimCombatant.isAlive(unit) then
            BattleSimulator.executeUnitAction(state, unit)
        end
        
        if BattleSimulator.checkVictory(state) then
            return false
        end
    end
    
    if state.turn >= state.config.maxTurns then
        BattleSimulator.logMessage(state, "Max turns reached!")
        state.winner = "draw"
        return false
    end
    
    return true
end

function BattleSimulator.executeUnitAction(state, unit)
    local enemies
    local allies
    
    if unit._team == "A" then
        enemies = BattleSimulator.getAliveUnits(state, state.teamB)
        allies = BattleSimulator.getAliveUnits(state, state.teamA)
    else
        enemies = BattleSimulator.getAliveUnits(state, state.teamA)
        allies = BattleSimulator.getAliveUnits(state, state.teamB)
    end
    
    if #enemies == 0 then
        return
    end
    
    local hpPercent = unit.hp / unit.maxHp
    local action = BattleSimulator.decideAction(state, unit, hpPercent, enemies, allies)
    
    if action.type == "skill" then
        BattleSimulator.executeSkill(state, unit, action.skill, action.targets, enemies)
    elseif action.type == "attack" then
        BattleSimulator.executeAttack(state, unit, action.target)
    elseif action.type == "defend" then
        BattleSimulator.executeDefend(state, unit)
    end
end

function BattleSimulator.decideAction(state, unit, hpPercent, enemies, allies)
    if hpPercent < 0.3 and math.random() < 0.3 then
        return {type = "defend"}
    end
    
    if unit.skills and #unit.skills > 0 and unit.mp > 0 then
        for _, skillId in ipairs(unit.skills) do
            local skill = SkillDatabase.getSkill(skillId)
            if skill and unit.mp >= skill.mpCost then
                local canUse = true
                if skill.targetType == "self" and hpPercent > 0.5 then
                    canUse = false
                end
                if skill.targetType == "ally" and not BattleSimulator.needsHealing(state, allies) then
                    canUse = false
                end
                
                if canUse and math.random() < 0.6 then
                    local targets = BattleSimulator.selectSkillTargets(state, skill, unit, enemies, allies)
                    if #targets > 0 then
                        return {type = "skill", skill = skill, targets = targets}
                    end
                end
            end
        end
    end
    
    local target = enemies[math.random(#enemies)]
    return {type = "attack", target = target}
end

function BattleSimulator.needsHealing(state, allies)
    for _, ally in ipairs(allies) do
        if ally.hp / ally.maxHp < 0.6 then
            return true
        end
    end
    return false
end

function BattleSimulator.selectSkillTargets(state, skill, unit, enemies, allies)
    local targets = {}
    
    if skill.targetType == "single_enemy" then
        if #enemies > 0 then
            table.insert(targets, enemies[math.random(#enemies)])
        end
    elseif skill.targetType == "all_enemies" then
        targets = enemies
    elseif skill.targetType == "self" then
        targets = {unit}
    elseif skill.targetType == "ally" then
        local lowestHp = nil
        local lowestPercent = 1
        for _, ally in ipairs(allies) do
            local percent = ally.hp / ally.maxHp
            if percent < lowestPercent then
                lowestPercent = percent
                lowestHp = ally
            end
        end
        if lowestHp then
            table.insert(targets, lowestHp)
        end
    elseif skill.targetType == "all_allies" then
        targets = allies
    end
    
    return targets
end

function BattleSimulator.executeSkill(state, unit, skill, targets, enemies)
    unit.mp = unit.mp - skill.mpCost
    BattleSimulator.logMessage(state, string.format("  %s uses %s!", unit.name, skill.name))
    
    local effectValue = SkillDatabase.calculateEffect(skill, unit)
    
    for _, target in ipairs(targets) do
        if skill.category == "damage" then
            local damage = BattleSimulator.calculateSkillDamage(state, effectValue, target)
            local actualDmg = SimCombatant.takeDamage(target, damage)
            BattleSimulator.logMessage(state, string.format("    -> %s takes %d damage (HP: %d/%d)", 
                target.name, actualDmg, target.hp, target.maxHp))
        elseif skill.category == "heal" then
            local healAmount = effectValue
            SimCombatant.heal(target, healAmount)
            BattleSimulator.logMessage(state, string.format("    -> %s heals %d (HP: %d/%d)", 
                target.name, healAmount, target.hp, target.maxHp))
        elseif skill.category == "buff" or skill.category == "debuff" then
            BattleSimulator.logMessage(state, string.format("    -> %s receives %s effect", target.name, skill.name))
        end
    end
end

function BattleSimulator.calculateSkillDamage(state, effectValue, target)
    local reduction = target.defPercent or 0
    local damage = math.floor(effectValue * (100 - reduction) / 100)
    return math.max(1, damage)
end

function BattleSimulator.executeAttack(state, unit, target)
    BattleSimulator.logMessage(state, string.format("  %s attacks %s!", unit.name, target.name))
    
    if SimCombatant.checkEvade(target) then
        BattleSimulator.logMessage(state, string.format("    -> %s evaded!", target.name))
        return
    end
    
    local damage, isCrit = SimCombatant.calculateDamage(unit)
    local actualDmg = SimCombatant.takeDamage(target, damage)
    
    local critText = isCrit and " (CRIT!)" or ""
    BattleSimulator.logMessage(state, string.format("    -> %d damage%s (HP: %d/%d)", 
        actualDmg, critText, target.hp, target.maxHp))
end

function BattleSimulator.executeDefend(state, unit)
    unit.isDefending = true
    BattleSimulator.logMessage(state, string.format("  %s defends!", unit.name))
end

function BattleSimulator.run(state)
    state.isRunning = true
    BattleSimulator.logMessage(state, "=== Battle Start ===")
    BattleSimulator.logMessage(state, string.format("Team A: %d units", #state.teamA))
    BattleSimulator.logMessage(state, string.format("Team B: %d units", #state.teamB))
    
    while state.isRunning do
        local continue = BattleSimulator.executeTurn(state)
        if not continue then
            state.isRunning = false
        end
    end
    
    BattleSimulator.logMessage(state, "=== Battle End ===")
    if state.winner then
        BattleSimulator.logMessage(state, string.format("Winner: Team %s", state.winner))
    end
    
    return {
        winner = state.winner,
        turns = state.turn,
        log = state.log,
        teamASurvivors = BattleSimulator.getAliveUnits(state, state.teamA),
        teamBSurvivors = BattleSimulator.getAliveUnits(state, state.teamB),
    }
end

function BattleSimulator.runMultiple(state, iterations)
    local results = {
        teamAWins = 0,
        teamBWins = 0,
        draws = 0,
        totalTurns = 0,
        iterations = iterations,
    }
    
    for i = 1, iterations do
        BattleSimulator.reset(state)
        for _, unit in ipairs(state.teamA) do SimCombatant.reset(unit) end
        for _, unit in ipairs(state.teamB) do SimCombatant.reset(unit) end
        
        local result = BattleSimulator.run(state)
        results.totalTurns = results.totalTurns + result.turns
        
        if result.winner == "A" then
            results.teamAWins = results.teamAWins + 1
        elseif result.winner == "B" then
            results.teamBWins = results.teamBWins + 1
        else
            results.draws = results.draws + 1
        end
    end
    
    return results
end

function BattleSimulator.getSkillDatabase()
    return SkillDatabase
end

function BattleSimulator.createUnit(classIdOrEnemy, level, name, isEnemy)
    if isEnemy then
        return SimCombatant.fromEnemy(classIdOrEnemy, level, name)
    else
        return SimCombatant.fromClass(classIdOrEnemy, level, name)
    end
end

return BattleSimulator
