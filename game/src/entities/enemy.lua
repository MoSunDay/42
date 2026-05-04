local CombatUtils = require("src.systems.combat_utils")
local EnemyData = require("entities.enemy_data")
local AnimationManager = require("src.animations.animation_manager")

local Enemy = {}

function Enemy.create(enemyType, assetManager)
    local state = {}

    local template = EnemyData.TYPES[enemyType] or EnemyData.TYPES.slime

    state.type = enemyType
    state.name = template.name
    state.tier = template.tier or 1
    state.hp = template.hp
    state.maxHp = template.maxHp
    state.attack = template.attack
    state.defense = template.defense
    state.defPercent = template.defPercent or 0
    state.speed = template.speed
    state.crit = template.crit or 0
    state.eva = template.eva or 0
    state.crystalBonus = template.crystalBonus or 0
    state.multiTarget = template.multiTarget or false
    state.boss = template.boss or false
    state.color = { template.color[1], template.color[2], template.color[3] } and {template.color[1], template.color[2], template.color[3]}

    state.isDefending = false

    state.animationManager = nil
    state.animationId = nil

    state.assetManager = assetManager
    state.currentDirection = "south"
    state.animFrame = 1
    state.animTimer = 0
    state.animSpeed = 0.15

    return state
end

function Enemy.set_asset_manager(state, assetManager)
    state.assetManager = assetManager
end

function Enemy.has_sprite(state)
    if state.assetManager then
        return state.assetManager:has_enemy_sprite(state.type)
    end
    return false
end

function Enemy.get_sprite(state, direction)
    if state.assetManager then
        return state.assetManager:get_enemy_sprite(state.type, direction or state.currentDirection)
    end
    return nil
end

function Enemy.get_animation(state, animName, direction, frameIndex)
    if state.assetManager then
        return state.assetManager:get_enemy_animation(state.type, animName, direction or state.currentDirection, frameIndex)
    end
    return nil
end

function Enemy.update_animation(state, dt)
    state.animTimer = state.animTimer + dt
    if state.animTimer >= state.animSpeed then
        state.animTimer = 0
        local frameCount = 1
        if state.assetManager then
            frameCount = state.assetManager:get_enemy_animation_frame_count(state.type, "idle", state.currentDirection)
            if frameCount == 0 then frameCount = 1 end
        end
        state.animFrame = (state.animFrame % frameCount) + 1
    end
end

function Enemy.set_animation_manager(state, animManager, animId)
    state.animationManager = animManager
    state.animationId = animId
    if animManager and animId then
        AnimationManager.create_animation_set(animManager, animId)
    end
end

function Enemy.take_damage(state, damage)
    return CombatUtils.take_damageMutating(state, damage)
end

function Enemy.heal(state, amount)
    CombatUtils.healMutating(state, amount)
end

function Enemy.is_alive(state)
    return state.hp > 0
end

function Enemy.get_hp_percent(state)
    if not state.maxHp or state.maxHp <= 0 then return 0 end
    return state.hp / state.maxHp
end

function Enemy.decide_action(state, partySize)
    local hpPercent = Enemy.get_hp_percent(state)

    if hpPercent < 0.25 then
        if math.random() < 0.4 then
            return "defend"
        end
    end

    if state.multiTarget and partySize and partySize > 1 then
        if math.random() < 0.3 then
            return "attack_all"
        end
    end

    return "attack"
end

function Enemy.calculate_damage(state)
    return CombatUtils.calculate_damageMutating(state)
end

function Enemy.check_evade(state)
    return CombatUtils.check_evade(state)
end

function Enemy.get_random_type()
    local tierRoll = math.random(100)
    local tierSum = 0
    local selectedTier = 1

    for i, weight in ipairs(EnemyData.TIER_SPAWN_WEIGHTS) do
        tierSum = tierSum + weight
        if tierRoll <= tierSum then
            selectedTier = i
            break
        end
    end

    local tierTypes = EnemyData.TYPES_BY_TIER[selectedTier]
    return tierTypes[math.random(#tierTypes)]
end

function Enemy.get_all_types()
    return EnemyData.TYPES
end

function Enemy.get_types_by_tier(tier)
    local result = {}
    for id, data in pairs(EnemyData.TYPES) do
        if data.tier == tier then
            result[id] = data
        end
    end
    return result
end

function Enemy.get_tier_spawn_weight(tier)
    return EnemyData.TIER_SPAWN_WEIGHTS[tier] or 0
end

function Enemy.get_types_by_tier_list(tier)
    return EnemyData.TYPES_BY_TIER[tier] or {}
end

function Enemy.scale_for_party_size(state, partySize)
    if not partySize or partySize <= 1 then return end

    local baseMultiplier = 1.0
    local perMemberBonus = 0.18
    local maxMultiplier = 2.8

    local multiplier = math.min(maxMultiplier, baseMultiplier + perMemberBonus * (partySize - 1))

    state.maxHp = math.floor(state.maxHp * multiplier)
    state.hp = state.maxHp
    state.hpRatio = multiplier

    if partySize >= 5 then
        state.crystalBonus = state.crystalBonus + 1
    end
end

return Enemy
