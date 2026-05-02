local BattleSystem = require("src.systems.battle.battle_system")
local Enemy = require("src.entities.enemy")

local BattleAI = {}

function BattleAI.autoPlayerAction(battleSystem)
    local aliveEnemies = BattleSystem.getAliveEnemies(battleSystem)
    if #aliveEnemies > 0 then
        local enemies = BattleSystem.getEnemies(battleSystem)
        for i, enemy in ipairs(enemies) do
            if Enemy.isAlive(enemy) then
                return "attack", i
            end
        end
    end
    return nil, nil
end

function BattleAI.enemyAction(enemy, player)
    if math.random() < 0.8 then
        return "attack"
    else
        return "defend"
    end
end

return BattleAI
