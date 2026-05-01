local SkillDatabase = require("src.systems.battle_simulator.skill_database")
local SimUnit = require("src.systems.battle_simulator.sim_unit")

local BattleSimulator = {}
BattleSimulator.__index = BattleSimulator

function BattleSimulator.new()
    local self = setmetatable({}, BattleSimulator)
    self.teamA = {}
    self.teamB = {}
    self.turn = 0
    self.log = {}
    self.isRunning = false
    self.winner = nil
    self.config = {
        maxTurns = 100,
        logDetail = "normal",
    }
    return self
end

function BattleSimulator:reset()
    self.teamA = {}
    self.teamB = {}
    self.turn = 0
    self.log = {}
    self.isRunning = false
    self.winner = nil
end

function BattleSimulator:addUnitToTeamA(classId, level, name)
    local unit = SimUnit.fromClass(classId, level, name)
    table.insert(self.teamA, unit)
    return unit
end

function BattleSimulator:addUnitToTeamB(enemyType, level, name)
    local unit = SimUnit.fromEnemy(enemyType, level, name)
    table.insert(self.teamB, unit)
    return unit
end

function BattleSimulator:addCustomUnitToTeamB(stats, name)
    local unit = SimUnit.fromStats(stats, name)
    table.insert(self.teamB, unit)
    return unit
end

function BattleSimulator:getAliveUnits(team)
    local alive = {}
    for _, unit in ipairs(team) do
        if unit:isAlive() then
            table.insert(alive, unit)
        end
    end
    return alive
end

function BattleSimulator:sortUnitsBySpeed(units)
    table.sort(units, function(a, b)
        return a.speed > b.speed
    end)
end

function BattleSimulator:checkVictory()
    local aliveA = self:getAliveUnits(self.teamA)
    local aliveB = self:getAliveUnits(self.teamB)
    
    if #aliveA == 0 then
        self.winner = "B"
        return true
    end
    if #aliveB == 0 then
        self.winner = "A"
        return true
    end
    return false
end

function BattleSimulator:logMessage(msg)
    if self.config.logDetail ~= "none" then
        table.insert(self.log, msg)
    end
end

function BattleSimulator:executeTurn()
    self.turn = self.turn + 1
    self:logMessage(string.format("=== Turn %d ===", self.turn))
    
    local allUnits = {}
    for _, unit in ipairs(self:getAliveUnits(self.teamA)) do
        unit._team = "A"
        table.insert(allUnits, unit)
    end
    for _, unit in ipairs(self:getAliveUnits(self.teamB)) do
        unit._team = "B"
        table.insert(allUnits, unit)
    end
    
    self:sortUnitsBySpeed(allUnits)
    
    for _, unit in ipairs(allUnits) do
        if unit:isAlive() then
            self:executeUnitAction(unit)
        end
        
        if self:checkVictory() then
            return false
        end
    end
    
    if self.turn >= self.config.maxTurns then
        self:logMessage("Max turns reached!")
        self.winner = "draw"
        return false
    end
    
    return true
end

function BattleSimulator:executeUnitAction(unit)
    local enemies
    local allies
    
    if unit._team == "A" then
        enemies = self:getAliveUnits(self.teamB)
        allies = self:getAliveUnits(self.teamA)
    else
        enemies = self:getAliveUnits(self.teamA)
        allies = self:getAliveUnits(self.teamB)
    end
    
    if #enemies == 0 then
        return
    end
    
    local hpPercent = unit.hp / unit.maxHp
    local action = self:decideAction(unit, hpPercent, enemies, allies)
    
    if action.type == "skill" then
        self:executeSkill(unit, action.skill, action.targets, enemies)
    elseif action.type == "attack" then
        self:executeAttack(unit, action.target)
    elseif action.type == "defend" then
        self:executeDefend(unit)
    end
end

function BattleSimulator:decideAction(unit, hpPercent, enemies, allies)
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
                if skill.targetType == "ally" and not self:needsHealing(allies) then
                    canUse = false
                end
                
                if canUse and math.random() < 0.6 then
                    local targets = self:selectSkillTargets(skill, unit, enemies, allies)
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

function BattleSimulator:needsHealing(allies)
    for _, ally in ipairs(allies) do
        if ally.hp / ally.maxHp < 0.6 then
            return true
        end
    end
    return false
end

function BattleSimulator:selectSkillTargets(skill, unit, enemies, allies)
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

function BattleSimulator:executeSkill(unit, skill, targets, enemies)
    unit.mp = unit.mp - skill.mpCost
    self:logMessage(string.format("  %s uses %s!", unit.name, skill.name))
    
    local effectValue = SkillDatabase.calculateEffect(skill, unit)
    
    for _, target in ipairs(targets) do
        if skill.category == "damage" then
            local damage = self:calculateSkillDamage(effectValue, target)
            local actualDmg = target:takeDamage(damage)
            self:logMessage(string.format("    -> %s takes %d damage (HP: %d/%d)", 
                target.name, actualDmg, target.hp, target.maxHp))
        elseif skill.category == "heal" then
            local healAmount = effectValue
            target:heal(healAmount)
            self:logMessage(string.format("    -> %s heals %d (HP: %d/%d)", 
                target.name, healAmount, target.hp, target.maxHp))
        elseif skill.category == "buff" or skill.category == "debuff" then
            self:logMessage(string.format("    -> %s receives %s effect", target.name, skill.name))
        end
    end
end

function BattleSimulator:calculateSkillDamage(effectValue, target)
    local reduction = target.defPercent or 0
    local damage = math.floor(effectValue * (100 - reduction) / 100)
    return math.max(1, damage)
end

function BattleSimulator:executeAttack(unit, target)
    self:logMessage(string.format("  %s attacks %s!", unit.name, target.name))
    
    if target:checkEvade() then
        self:logMessage(string.format("    -> %s evaded!", target.name))
        return
    end
    
    local damage, isCrit = unit:calculateDamage()
    local actualDmg = target:takeDamage(damage)
    
    local critText = isCrit and " (CRIT!)" or ""
    self:logMessage(string.format("    -> %d damage%s (HP: %d/%d)", 
        actualDmg, critText, target.hp, target.maxHp))
end

function BattleSimulator:executeDefend(unit)
    unit.isDefending = true
    self:logMessage(string.format("  %s defends!", unit.name))
end

function BattleSimulator:run()
    self.isRunning = true
    self:logMessage("=== Battle Start ===")
    self:logMessage(string.format("Team A: %d units", #self.teamA))
    self:logMessage(string.format("Team B: %d units", #self.teamB))
    
    while self.isRunning do
        local continue = self:executeTurn()
        if not continue then
            self.isRunning = false
        end
    end
    
    self:logMessage("=== Battle End ===")
    if self.winner then
        self:logMessage(string.format("Winner: Team %s", self.winner))
    end
    
    return {
        winner = self.winner,
        turns = self.turn,
        log = self.log,
        teamASurvivors = self:getAliveUnits(self.teamA),
        teamBSurvivors = self:getAliveUnits(self.teamB),
    }
end

function BattleSimulator:runMultiple(iterations)
    local results = {
        teamAWins = 0,
        teamBWins = 0,
        draws = 0,
        totalTurns = 0,
        iterations = iterations,
    }
    
    for i = 1, iterations do
        self:reset()
        for _, unit in ipairs(self.teamA) do unit:reset() end
        for _, unit in ipairs(self.teamB) do unit:reset() end
        
        local result = self:run()
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
        return SimUnit.fromEnemy(classIdOrEnemy, level, name)
    else
        return SimUnit.fromClass(classIdOrEnemy, level, name)
    end
end

return BattleSimulator
