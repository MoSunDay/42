local Enemy = require("src.entities.enemy")

local BattleUtils = {}

function BattleUtils.check_victory(enemies)
    for _, enemy in ipairs(enemies) do
        if Enemy.is_alive(enemy) then
            return false
        end
    end
    return true
end

function BattleUtils.get_alive_enemies(enemies)
    local alive = {}
    for _, enemy in ipairs(enemies) do
        if Enemy.is_alive(enemy) then
            table.insert(alive, enemy)
        end
    end
    return alive
end

return BattleUtils

