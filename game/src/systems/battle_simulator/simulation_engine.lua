local SimulatedCombatant = require("src.systems.battle_simulator.simulated_combatant")

local SimulationEngine = {}
SimulationEngine.__index = SimulationEngine

function SimulationEngine.new()
    local self = setmetatable({}, SimulationEngine)
    return self
end

function SimulationEngine:run(partyConfigs, enemyConfigs, maxTurns)
    maxTurns = maxTurns or 100
    
    local party = self:buildTeam(partyConfigs)
    local enemies = self:buildTeam(enemyConfigs)
    
    local state = {
        turn = 0,
        turnLog = {},
        totalDamageDealt = { party = 0, enemy = 0 },
        totalDamageTaken = { party = 0, enemy = 0 },
        totalHealing = { party = 0, enemy = 0 },
        critCount = { party = 0, enemy = 0 },
        evadeCount = { party = 0, enemy = 0 },
        skillUses = {},
    }
    
    while state.turn < maxTurns do
        state.turn = state.turn + 1
        local turnActions = {}
        
        local turnOrder = self:getTurnOrder(party, enemies)
        
        for _, combatant in ipairs(turnOrder) do
            if combatant.isAlive then
                local action = combatant:decideAction({
                    party = party,
                    enemies = enemies,
                    state = state,
                })
                
                local actionResult = self:executeAction(combatant, action, party, enemies, state)
                table.insert(turnActions, actionResult)
                
                if self:checkBattleEnd(party, enemies) then
                    return self:buildResult(state, party, enemies, turnActions)
                end
            end
        end
        
        self:endTurn(party, enemies)
        table.insert(state.turnLog, turnActions)
        
        if self:checkBattleEnd(party, enemies) then
            return self:buildResult(state, party, enemies, turnActions)
        end
    end
    
    return self:buildResult(state, party, enemies, state.turnLog[#state.turnLog], "timeout")
end

function SimulationEngine:buildTeam(configs)
    local team = {}
    for _, config in ipairs(configs) do
        local combatant
        if type(config) == "table" then
            if config.type == "enemy" then
                combatant = SimulatedCombatant.fromEnemyType(config.id)
            elseif config.type == "class" then
                combatant = SimulatedCombatant.fromClassId(config.id)
            else
                combatant = SimulatedCombatant.new(config)
            end
        end
        if combatant then
            table.insert(team, combatant)
        end
    end
    return team
end

function SimulationEngine:getTurnOrder(party, enemies)
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

function SimulationEngine:executeAction(actor, action, party, enemies, state)
    local result = {
        actor = actor.id,
        action = action.type,
        team = actor.team,
    }
    
    if action.type == "attack" then
        local targets = actor.team == "party" and enemies or party
        local target = self:getAliveTarget(targets)
        
        if target then
            if target:checkEvade() then
                result.evaded = true
                result.target = target.id
                state.evadeCount[target.team] = (state.evadeCount[target.team] or 0) + 1
            else
                local damage, isCrit = actor:calculateDamage(false)
                local actualDamage = target:takeDamage(damage)
                
                result.damage = actualDamage
                result.isCrit = isCrit
                result.target = target.id
                
                state.totalDamageDealt[actor.team] = state.totalDamageDealt[actor.team] + actualDamage
                state.totalDamageTaken[target.team] = state.totalDamageTaken[target.team] + actualDamage
                
                if isCrit then
                    state.critCount[actor.team] = state.critCount[actor.team] + 1
                end
            end
        end
        
    elseif action.type == "skill" then
        local skill = action.skill
        result.skillName = skill.name or "unknown"
        
        if actor:useMana(skill.cost or 10) then
            state.skillUses[result.skillName] = (state.skillUses[result.skillName] or 0) + 1
            
            local targets = actor.team == "party" and enemies or party
            local allies = actor.team == "party" and party or enemies
            
            if skill.targetType == "heal" then
                local healTarget = self:getMostDamagedAlly(allies)
                if healTarget then
                    local healAmount = skill:calculateEffect(actor) or actor.magicAttack * 2
                    healTarget:heal(healAmount)
                    result.healAmount = healAmount
                    result.target = healTarget.id
                    state.totalHealing[actor.team] = state.totalHealing[actor.team] + healAmount
                end
            else
                local target = self:getAliveTarget(targets)
                if target then
                    if not target:checkEvade() then
                        local damage, isCrit = actor:calculateDamage(skill.isMagic or false)
                        local multiplier = skill.damageMultiplier or 1.5
                        damage = math.floor(damage * multiplier)
                        local actualDamage = target:takeDamage(damage)
                        
                        result.damage = actualDamage
                        result.isCrit = isCrit
                        result.target = target.id
                        
                        state.totalDamageDealt[actor.team] = state.totalDamageDealt[actor.team] + actualDamage
                        state.totalDamageTaken[target.team] = state.totalDamageTaken[target.team] + actualDamage
                        
                        if isCrit then
                            state.critCount[actor.team] = state.critCount[actor.team] + 1
                        end
                    else
                        result.evaded = true
                        state.evadeCount[target.team] = (state.evadeCount[target.team] or 0) + 1
                    end
                end
            end
        end
        
    elseif action.type == "defend" then
        actor:setDefending(true)
        result.defended = true
    end
    
    return result
end

function SimulationEngine:getAliveTarget(targets)
    local alive = {}
    for _, t in ipairs(targets) do
        if t.isAlive then
            table.insert(alive, t)
        end
    end
    if #alive == 0 then return nil end
    return alive[math.random(#alive)]
end

function SimulationEngine:getMostDamagedAlly(allies)
    local mostDamaged = nil
    local lowestHpPercent = 1.0
    
    for _, ally in ipairs(allies) do
        if ally.isAlive and ally:getHPPercent() < lowestHpPercent then
            lowestHpPercent = ally:getHPPercent()
            mostDamaged = ally
        end
    end
    
    return mostDamaged
end

function SimulationEngine:checkBattleEnd(party, enemies)
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

function SimulationEngine:endTurn(party, enemies)
    for _, c in ipairs(party) do
        c:setDefending(false)
    end
    for _, c in ipairs(enemies) do
        c:setDefending(false)
    end
end

function SimulationEngine:buildResult(state, party, enemies, lastTurnActions, endReason)
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
        turns = state.turn,
        damageDealt = state.totalDamageDealt,
        damageTaken = state.totalDamageTaken,
        healing = state.totalHealing,
        critCount = state.critCount,
        evadeCount = state.evadeCount,
        skillUses = state.skillUses,
        partySurvivors = self:countAlive(party),
        enemySurvivors = self:countAlive(enemies),
        turnLog = state.turnLog,
    }
end

function SimulationEngine:countAlive(team)
    local count = 0
    for _, c in ipairs(team) do
        if c.isAlive then count = count + 1 end
    end
    return count
end

return SimulationEngine
