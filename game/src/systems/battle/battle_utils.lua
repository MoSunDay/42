local Enemy = require("src.entities.enemy")

local BattleUtils = {}

function BattleUtils.checkVictory(enemies)
    for _, enemy in ipairs(enemies) do
        if Enemy.isAlive(enemy) then
            return false
        end
    end
    return true
end

function BattleUtils.getAliveEnemies(enemies)
    local alive = {}
    for _, enemy in ipairs(enemies) do
        if Enemy.isAlive(enemy) then
            table.insert(alive, enemy)
        end
    end
    return alive
end

return BattleUtils

