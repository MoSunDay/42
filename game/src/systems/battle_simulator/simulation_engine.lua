local SimCombatant = require("src.systems.battle_simulator.sim_combatant")

local SimulationEngine = {}

function SimulationEngine.new()
    return {}
end

function SimulationEngine.run(state, partyConfigs, enemyConfigs, maxTurns)
    maxTurns = maxTurns or 100
    
    local party = SimulationEngine.buildTeam(state, partyConfigs)
    local enemies = SimulationEngine.buildTeam(state, enemyConfigs)
    
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
        
        local turnOrder = SimulationEngine.getTurnOrder(state, party, enemies)
        
        for _, combatant in ipairs(turnOrder) do
            if combatant.isAlive then
                local action = SimCombatant.decideAction(combatant, {
                    party = party,
                    enemies = enemies,
                    state = simState,
                })
                
                local actionResult = SimulationEngine.executeAction(state, combatant, action, party, enemies, simState)
                table.insert(turnActions, actionResult)
                
                if SimulationEngine.checkBattleEnd(state, party, enemies) then
                    return SimulationEngine.buildResult(state, simState, party, enemies, turnActions)
                end
            end
        end
        
        SimulationEngine.endTurn(state, party, enemies)
        table.insert(simState.turnLog, turnActions)
        
        if SimulationEngine.checkBattleEnd(state, party, enemies) then
            return SimulationEngine.buildResult(state, simState, party, enemies, turnActions)
        end
    end
    
    return SimulationEngine.buildResult(state, simState, party, enemies, simState.turnLog[#simState.turnLog], "timeout")
end

function SimulationEngine.buildTeam(state, configs)
    local team = {}
    for _, config in ipairs(configs) do
        local combatant
        if type(config) == "table" then
            if config.type == "enemy" then
                combatant = SimCombatant.new(config)
            elseif config.type == "class" then
                combatant = SimCombatant.fromClass(config.id, config.level)
            else
                combatant = SimCombatant.new(config)
            end
        end
        if combatant then
            table.insert(team, combatant)
        end
    end
    return team
end

function SimulationEngine.getTurnOrder(state, party, enemies)
    local all = {}
    for _, c in ipairs(party) do
        if c.isAlive then table.insert(all, c) end
    end
    for _, c in ipairs(enemies) do
        if c.isAlive then table.insert(all, c) end
    end
    
    table.sort(all, function(a, b)
        return a.speed > b.speed
    end)
    
    return all
end

function SimulationEngine.executeAction(state, actor, action, party, enemies, simState)
    local result = {
        actor = actor.id,
        action = action.type,
        team = actor.team,
    }
    
    if action.type == "attack" then
        local targets = actor.team == "party" and enemies or party
        local target = SimulationEngine.getAliveTarget(state, targets)
        
        if target then
            if SimCombatant.checkEvade(target) then
                result.evaded = true
                result.target = target.id
                simState.evadeCount[target.team] = (simState.evadeCount[target.team] or 0) + 1
            else
                local damage, isCrit = SimCombatant.calculateDamage(actor, false)
                local actualDamage = SimCombatant.takeDamage(target, damage)
                
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
        
        if SimCombatant.useMana(actor, skill.cost or 10) then
            simState.skillUses[result.skillName] = (simState.skillUses[result.skillName] or 0) + 1
            
            local targets = actor.team == "party" and enemies or party
            local allies = actor.team == "party" and party or enemies
            
            if skill.targetType == "heal" then
                local healTarget = SimulationEngine.getMostDamagedAlly(state, allies)
                if healTarget then
                    local healAmount = skill:calculateEffect(actor) or actor.magicAttack * 2
                    SimCombatant.heal(healTarget, healAmount)
                    result.healAmount = healAmount
                    result.target = healTarget.id
                    simState.totalHealing[actor.team] = simState.totalHealing[actor.team] + healAmount
                end
            else
                local target = SimulationEngine.getAliveTarget(state, targets)
                if target then
                    if not SimCombatant.checkEvade(target) then
                        local damage, isCrit = SimCombatant.calculateDamage(actor, skill.isMagic or false)
                        local multiplier = skill.damageMultiplier or 1.5
                        damage = math.floor(damage * multiplier)
                        local actualDamage = SimCombatant.takeDamage(target, damage)
                        
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
        SimCombatant.setDefending(actor, true)
        result.defended = true
    end
    
    return result
end

function SimulationEngine.getAliveTarget(state, targets)
    local alive = {}
    for _, t in ipairs(targets) do
        if t.isAlive then
            table.insert(alive, t)
        end
    end
    if #alive == 0 then return nil end
    return alive[math.random(#alive)]
end

function SimulationEngine.getMostDamagedAlly(state, allies)
    local mostDamaged = nil
    local lowestHpPercent = 1.0
    
    for _, ally in ipairs(allies) do
        if ally.isAlive and SimCombatant.getHPPercent(ally) < lowestHpPercent then
            lowestHpPercent = SimCombatant.getHPPercent(ally)
            mostDamaged = ally
        end
    end
    
    return mostDamaged
end

function SimulationEngine.checkBattleEnd(state, party, enemies)
    local partyAlive = false
    for _, c in ipairs(party) do
        if c.isAlive then partyAlive = true end
    end
    
    local enemiesAlive = false
    for _, c in ipairs(enemies) do
        if c.isAlive then enemiesAlive = true end
    end
    
    return not partyAlive or not enemiesAlive
end

function SimulationEngine.endTurn(state, party, enemies)
    for _, c in ipairs(party) do
        SimCombatant.setDefending(c, false)
    end
    for _, c in ipairs(enemies) do
        SimCombatant.setDefending(c, false)
    end
end

function SimulationEngine.buildResult(state, simState, party, enemies, lastTurnActions, endReason)
    local partyAlive = false
    local enemiesAlive = false
    
    for _, c in ipairs(party) do
        if c.isAlive then partyAlive = true end
    end
    for _, c in ipairs(enemies) do
        if c.isAlive then enemiesAlive = true end
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
        partySurvivors = SimulationEngine.countAlive(state, party),
        enemySurvivors = SimulationEngine.countAlive(state, enemies),
        turnLog = simState.turnLog,
    }
end

function SimulationEngine.countAlive(state, team)
    local count = 0
    for _, c in ipairs(team) do
        if c.isAlive then count = count + 1 end
    end
    return count
end

return SimulationEngine
