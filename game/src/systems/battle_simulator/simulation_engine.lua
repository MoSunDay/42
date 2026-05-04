local SimCombatant = require("src.systems.battle_simulator.sim_combatant")
local SkillDatabase = require("src.systems.battle_simulator.skill_database")

local SimulationEngine = {}

function SimulationEngine.create()
    return {}
end

function SimulationEngine.run(state, partyConfigs, enemyConfigs, maxTurns)
    maxTurns = maxTurns or 100
    
    local party = SimulationEngine.build_team(state, partyConfigs)
    local enemies = SimulationEngine.build_team(state, enemyConfigs)
    
    local simState = {
        turn = 0,
        turnLog = {},
        totalDamageDealt = { party = 0, enemy = 0 },
        totalDamageTaken = { party = 0, enemy = 0 },
        totalHealing = { party = 0, enemy = 0 },
        critCount = { party = 0, enemy = 0 },
        evadeCount = { party = 0, enemy = 0 },
        skillUses = {},
    }
    
    while simState.turn < maxTurns do
        simState.turn = simState.turn + 1
        local turnActions = {}
        
        local turnOrder = SimulationEngine.get_turn_order(state, party, enemies)
        
        for _, combatant in ipairs(turnOrder) do
            if combatant.is_alive then
                local action = SimCombatant.decide_action(combatant, {
                    party = party,
                    enemies = enemies,
                    state = simState,
                })
                
                local actionResult = SimulationEngine.execute_action(state, combatant, action, party, enemies, simState)
                table.insert(turnActions, actionResult)
                
                if SimulationEngine.check_battle_end(state, party, enemies) then
                    return SimulationEngine.build_result(state, simState, party, enemies, turnActions)
                end
            end
        end
        
        SimulationEngine.end_turn(state, party, enemies)
        table.insert(simState.turnLog, turnActions)
        
        if SimulationEngine.check_battle_end(state, party, enemies) then
            return SimulationEngine.build_result(state, simState, party, enemies, turnActions)
        end
    end
    
    return SimulationEngine.build_result(state, simState, party, enemies, simState.turnLog[#simState.turnLog], "timeout")
end

function SimulationEngine.build_team(state, configs)
    local team = {}
    for _, config in ipairs(configs) do
        local combatant
        if type(config) == "table" then
            if config.type == "enemy" then
                combatant = SimCombatant.create(config)
            elseif config.type == "class" then
                combatant = SimCombatant.from_class(config.id, config.level)
            else
                combatant = SimCombatant.create(config)
            end
        end
        if combatant then
            table.insert(team, combatant)
        end
    end
    return team
end

function SimulationEngine.get_turn_order(state, party, enemies)
    local all = {}
    for _, c in ipairs(party) do
        if c.is_alive then table.insert(all, c) end
    end
    for _, c in ipairs(enemies) do
        if c.is_alive then table.insert(all, c) end
    end
    
    table.sort(all, function(a, b)
        return a.speed > b.speed
    end)
    
    return all
end

function SimulationEngine.execute_action(state, actor, action, party, enemies, simState)
    local result = {
        actor = actor.id,
        action = action.type,
        team = actor.team,
    }
    
    if action.type == "attack" then
        local targets = actor.team == "party" and enemies or party
        local target = SimulationEngine.get_alive_target(state, targets)
        
        if target then
            if SimCombatant.check_evade(target) then
                result.evaded = true
                result.target = target.id
                simState.evadeCount[target.team] = (simState.evadeCount[target.team] or 0) + 1
            else
                local damage, isCrit = SimCombatant.calculate_damage(actor, false)
                local actualDamage = SimCombatant.take_damage(target, damage)
                
                result.damage = actualDamage
                result.isCrit = isCrit
                result.target = target.id
                
                simState.totalDamageDealt[actor.team] = simState.totalDamageDealt[actor.team] + actualDamage
                simState.totalDamageTaken[target.team] = simState.totalDamageTaken[target.team] + actualDamage
                
                if isCrit then
                    simState.critCount[actor.team] = simState.critCount[actor.team] + 1
                end
            end
        end
        
    elseif action.type == "skill" then
        local skill = action.skill
        result.skillName = skill.name or "unknown"
        
        if SimCombatant.use_mana(actor, skill.cost or 10) then
            simState.skillUses[result.skillName] = (simState.skillUses[result.skillName] or 0) + 1
            
            local targets = actor.team == "party" and enemies or party
            local allies = actor.team == "party" and party or enemies
            
            if skill.targetType == "heal" then
                local healTarget = SimulationEngine.get_most_damaged_ally(state, allies)
                if healTarget then
                    local healAmount = SkillDatabase.calculate_effect(skill, actor) or actor.magicAttack * 2
                    SimCombatant.heal(healTarget, healAmount)
                    result.healAmount = healAmount
                    result.target = healTarget.id
                    simState.totalHealing[actor.team] = simState.totalHealing[actor.team] + healAmount
                end
            else
                local target = SimulationEngine.get_alive_target(state, targets)
                if target then
                    if not SimCombatant.check_evade(target) then
                        local damage, isCrit = SimCombatant.calculate_damage(actor, skill.isMagic or false)
                        local multiplier = skill.damageMultiplier or 1.5
                        damage = math.floor(damage * multiplier)
                        local actualDamage = SimCombatant.take_damage(target, damage)
                        
                        result.damage = actualDamage
                        result.isCrit = isCrit
                        result.target = target.id
                        
                        simState.totalDamageDealt[actor.team] = simState.totalDamageDealt[actor.team] + actualDamage
                        simState.totalDamageTaken[target.team] = simState.totalDamageTaken[target.team] + actualDamage
                        
                        if isCrit then
                            simState.critCount[actor.team] = simState.critCount[actor.team] + 1
                        end
                    else
                        result.evaded = true
                        simState.evadeCount[target.team] = (simState.evadeCount[target.team] or 0) + 1
                    end
                end
            end
        end
        
    elseif action.type == "defend" then
        SimCombatant.set_defending(actor, true)
        result.defended = true
    end
    
    return result
end

function SimulationEngine.get_alive_target(state, targets)
    local alive = {}
    for _, t in ipairs(targets) do
        if t.is_alive then
            table.insert(alive, t)
        end
    end
    if #alive == 0 then return nil end
    return alive[math.random(#alive)]
end

function SimulationEngine.get_most_damaged_ally(state, allies)
    local mostDamaged = nil
    local lowestHpPercent = 1.0
    
    for _, ally in ipairs(allies) do
        if ally.is_alive and SimCombatant.get_hp_percent(ally) < lowestHpPercent then
            lowestHpPercent = SimCombatant.get_hp_percent(ally)
            mostDamaged = ally
        end
    end
    
    return mostDamaged
end

function SimulationEngine.check_battle_end(state, party, enemies)
    local partyAlive = false
    for _, c in ipairs(party) do
        if c.is_alive then partyAlive = true end
    end
    
    local enemiesAlive = false
    for _, c in ipairs(enemies) do
        if c.is_alive then enemiesAlive = true end
    end
    
    return not partyAlive or not enemiesAlive
end

function SimulationEngine.end_turn(state, party, enemies)
    for _, c in ipairs(party) do
        SimCombatant.set_defending(c, false)
    end
    for _, c in ipairs(enemies) do
        SimCombatant.set_defending(c, false)
    end
end

function SimulationEngine.build_result(state, simState, party, enemies, lastTurnActions, endReason)
    local partyAlive = false
    local enemiesAlive = false
    
    for _, c in ipairs(party) do
        if c.is_alive then partyAlive = true end
    end
    for _, c in ipairs(enemies) do
        if c.is_alive then enemiesAlive = true end
    end
    
    local winner
    if not enemiesAlive then
        winner = "party"
    elseif not partyAlive then
        winner = "enemy"
    else
        winner = "none"
    end
    
    return {
        winner = winner,
        endReason = endReason or (winner == "party" and "victory" or "defeat"),
        turns = simState.turn,
        damageDealt = simState.totalDamageDealt,
        damageTaken = simState.totalDamageTaken,
        healing = simState.totalHealing,
        critCount = simState.critCount,
        evadeCount = simState.evadeCount,
        skillUses = simState.skillUses,
        partySurvivors = SimulationEngine.count_alive(state, party),
        enemySurvivors = SimulationEngine.count_alive(state, enemies),
        turnLog = simState.turnLog,
    }
end

function SimulationEngine.count_alive(state, team)
    local count = 0
    for _, c in ipairs(team) do
        if c.is_alive then count = count + 1 end
    end
    return count
end

return SimulationEngine
