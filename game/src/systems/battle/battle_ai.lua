local BattleSystem = require("src.systems.battle.battle_system")
local Enemy = require("src.entities.enemy")

local BattleAI = {}

function BattleAI.auto_player_action(battleSystem)
    local aliveEnemies = BattleSystem.get_alive_enemies(battleSystem)
    if #aliveEnemies > 0 then
        local enemies = BattleSystem.get_enemies(battleSystem)
        for i, enemy in ipairs(enemies) do
            if Enemy.is_alive(enemy) then
                return "attack", i
            end
        end
    end
    return nil, nil
end

function BattleAI.enemy_action(enemy, player)
    if math.random() < 0.8 then
        return "attack"
    else
        return "defend"
    end
end

return BattleAI
