-- battle_ai.lua - Battle AI logic
-- Simple AI for enemy and auto-battle decisions

local BattleAI = {}

-- Auto execute player action (simple AI)
function BattleAI.autoPlayerAction(battleSystem)
    -- Simple AI: always attack the first alive enemy
    local aliveEnemies = battleSystem:getAliveEnemies()
    if #aliveEnemies > 0 then
        -- Find first alive enemy
        local enemies = battleSystem:getEnemies()
        for i, enemy in ipairs(enemies) do
            if enemy:isAlive() then
                return "attack", i
            end
        end
    end
    return nil, nil
end

-- Enemy AI decision
function BattleAI.enemyAction(enemy, player)
    -- Simple AI: 80% attack, 20% defend
    if math.random() < 0.8 then
        return "attack"
    else
        return "defend"
    end
end

return BattleAI

