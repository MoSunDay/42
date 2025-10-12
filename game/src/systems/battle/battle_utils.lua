-- battle_utils.lua - Battle utility functions
-- Helper functions for battle system

local BattleUtils = {}

-- Check if all enemies are defeated
function BattleUtils.checkVictory(enemies)
    for _, enemy in ipairs(enemies) do
        if enemy:isAlive() then
            return false
        end
    end
    return true
end

-- Get list of alive enemies
function BattleUtils.getAliveEnemies(enemies)
    local alive = {}
    for _, enemy in ipairs(enemies) do
        if enemy:isAlive() then
            table.insert(alive, enemy)
        end
    end
    return alive
end

-- Calculate damage with defense
function BattleUtils.calculateDamage(attack, defense, isDefending)
    local baseDamage = math.max(1, attack - defense)
    local variance = math.random(80, 120) / 100
    local damage = math.floor(baseDamage * variance)
    
    if isDefending then
        damage = math.floor(damage * 0.5)
    end
    
    return damage
end

return BattleUtils

