local BattleAI = {}

local BattleSystem = nil
local function get_battle_system()
    if not BattleSystem then
        BattleSystem = require("src.systems.battle.battle_system")
    end
    return BattleSystem
end

local Enemy = nil
local function get_enemy()
    if not Enemy then
        Enemy = require("src.entities.enemy")
    end
    return Enemy
end

function BattleAI.auto_player_action(battleSystem)
    local BS = get_battle_system()
    local E = get_enemy()
    local aliveEnemies = BS.get_alive_enemies(battleSystem)
    if #aliveEnemies > 0 then
        local enemies = BS.get_enemies(battleSystem)
        for i, enemy in ipairs(enemies) do
            if E.is_alive(enemy) then
                return "attack", i
            end
        end
    end
    return nil, nil
end

function BattleAI.enemy_action(enemy, player)
    if enemy.stunned then
        return "defend"
    end

    if enemy.sealed then
        return "defend"
    end

    if math.random() < 0.8 then
        return "attack"
    else
        return "defend"
    end
end

return BattleAI
