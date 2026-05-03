-- player.lua - 玩家实体
-- 处理玩家的移动、动画和状态

local AnimationManager = require("src.animations.animation_manager")
local AppearanceSystem = require("src.systems.appearance_system")
local SpriteAnimator = require("src.systems.sprite_animator")
local CombatUtils = require("src.systems.combat_utils")
local CollisionSystem = require("src.systems.collision_system")
local EquipmentSystem = require("src.systems.equipment_system")

local Player = {}

local DIRECTION_MAP = {
    ["down"] = "south",
    ["down-left"] = "south-west",
    ["left"] = "west",
    ["up-left"] = "north-west",
    ["up"] = "north",
    ["up-right"] = "north-east",
    ["right"] = "east",
    ["down-right"] = "south-east"
}

function Player.create(x, y, assetManager)
    local state = {}

    state.x = x or 0
    state.y = y or 0

    state.targetX = state.x
    state.targetY = state.y

    state.speed = 250

    state.isMoving = false

    state.width = 48
    state.height = 48

    state.direction = "down"
    state.angle = 0

    state.animationTime = 0
    state.animationFrame = 0

    state.mapWidth = 2000
    state.mapHeight = 2000

    state.collisionRadius = 16

    state.assetManager = assetManager
    state.sprite = assetManager:get_image("player")

    state.collisionSystem = nil

    state.baseHp = 100
    state.hp = 100
    state.maxHp = 100
    state.baseAttack = 15
    state.attack = 15
    state.baseDefense = 5
    state.defense = 5
    state.defPercent = 1
    state.battleSpeed = 6
    state.isDefending = false

    state.baseCrit = 5
    state.crit = 5
    state.baseEva = 3
    state.eva = 3

    state.mp = 100
    state.maxMp = 100
    state.baseMp = 100
    state.baseMagicAttack = 10
    state.magicAttack = 10

    state.classId = nil
    state.skills = {}
    state.skillCrystals = 0
    state.critBonus = 0

    state.animationManager = nil
    state.animationId = "player"

    state.equipmentSystem = nil
    state.inventorySystem = nil

    state.appearance = nil
    state.appearanceId = "blue_hero"

    state.spriteAnimator = nil
    state.useSpriteAnimator = false

    Player.init_sprite_animator(state)

    return state
end

function Player.init_sprite_animator(state)
    if not state.assetManager then return end

    if state.assetManager:has_character_sprite(state.appearanceId) then
        state.spriteAnimator = SpriteAnimator.create({
            frameWidth = 48,
            frameHeight = 48,
            frameDuration = 0.12
        })

        state.spriteAnimator:loadFromAssetManager(state.assetManager, state.appearanceId)

        if not state.spriteAnimator:hasAnimation("walking") then
            local basePath = "assets/images/characters/" .. state.appearanceId .. "/rotations"
            state.spriteAnimator:loadDirectionalSprites(basePath)
        end

        state.useSpriteAnimator = true
    end
end

function Player.set_animation_manager(state, animManager)
    state.animationManager = animManager
    if animManager then
        AnimationManager.create_animation_set(state.animationManager, state.animationId)
    end
end

function Player.set_appearance(state, character)
    state.appearance = AppearanceSystem.create_appearance(character)
    if character and character.appearanceId then
        state.appearanceId = character.appearanceId
        Player.init_sprite_animator(state)
    end
end

function Player.set_appearance_id(state, appearanceId)
    state.appearanceId = appearanceId
    Player.init_sprite_animator(state)
end

function Player.set_map_bounds(state, width, height)
    state.mapWidth = width
    state.mapHeight = height
end

function Player.set_collision_system(state, collisionSystem)
    state.collisionSystem = collisionSystem
end

function Player.move_to(state, x, y)
    if state.collisionSystem then
        x, y = CollisionSystem.getClosestWalkable(state.collisionSystem, x, y, state.x, state.y, state.collisionRadius)
    end

    state.targetX = math.max(state.collisionRadius, math.min(x, state.mapWidth - state.collisionRadius))
    state.targetY = math.max(state.collisionRadius, math.min(y, state.mapHeight - state.collisionRadius))

    state.isMoving = true

    local dx = state.targetX - state.x
    local dy = state.targetY - state.y

    state.angle = math.atan2(dy, dx)

    local absX = math.abs(dx)
    local absY = math.abs(dy)
    local threshold = 0.4

    if absX < 1 and absY < 1 then
        return
    end

    if absY < absX * threshold then
        state.direction = dx > 0 and "right" or "left"
    elseif absX < absY * threshold then
        state.direction = dy > 0 and "down" or "up"
    else
        if dx > 0 and dy > 0 then
            state.direction = "down-right"
        elseif dx > 0 and dy < 0 then
            state.direction = "up-right"
        elseif dx < 0 and dy > 0 then
            state.direction = "down-left"
        else
            state.direction = "up-left"
        end
    end
end

function Player.update(state, dt)
    if state.spriteAnimator then
        local spriteDir = DIRECTION_MAP[state.direction] or "south"
        state.spriteAnimator:setDirection(spriteDir)
        state.spriteAnimator:setAnimationState(state.isMoving)
        state.spriteAnimator:update(dt)
    end

    if state.animationManager then
        AnimationManager.update_entity(state.animationManager, state.animationId, dt, state.isMoving)
    end

    if not state.isMoving then
        return
    end

    local dx = state.targetX - state.x
    local dy = state.targetY - state.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < 3 then
        state.x = state.targetX
        state.y = state.targetY
        state.isMoving = false
        state.animationFrame = 0
        return
    end

    local dirX = dx / distance
    local dirY = dy / distance

    local moveDistance = state.speed * dt
    if moveDistance > distance then
        moveDistance = distance
    end

    local newX = state.x + dirX * moveDistance
    local newY = state.y + dirY * moveDistance

    if state.collisionSystem then
        local can_move, validX, validY = CollisionSystem.can_move(state.collisionSystem,
            state.x, state.y, newX, newY, state.collisionRadius
        )

        if can_move then
            state.x = validX
            state.y = validY
        else
            state.x = validX
            state.y = validY
            state.isMoving = false
        end
    else
        state.x = newX
        state.y = newY
    end

    state.x = math.max(state.collisionRadius, math.min(state.x, state.mapWidth - state.collisionRadius))
    state.y = math.max(state.collisionRadius, math.min(state.y, state.mapHeight - state.collisionRadius))

    state.animationTime = state.animationTime + dt
    if state.animationTime > 0.15 then
        state.animationTime = 0
        state.animationFrame = (state.animationFrame + 1) % 4
    end
end

function Player.draw(state)
    love.graphics.setColor(1, 1, 1)

    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if state.animationManager then
        offsetX, offsetY, rotation, scaleX, scaleY = AnimationManager.get_transform(state.animationManager, state.animationId)
    end

    if state.useSpriteAnimator and state.spriteAnimator then
        local spriteDir = DIRECTION_MAP[state.direction] or "south"
        state.spriteAnimator:setDirection(spriteDir)
        state.spriteAnimator:draw(state.x, state.y, 2, offsetX, offsetY)
    elseif state.appearance then
        AppearanceSystem.draw_sprite(state.x, state.y, 32, state.appearance, offsetX, offsetY, scaleX, scaleY)
    elseif state.sprite then
        love.graphics.push()
        love.graphics.translate(state.x + offsetX, state.y + offsetY)
        love.graphics.rotate(rotation)
        love.graphics.scale(scaleX, scaleY)
        love.graphics.draw(state.sprite,
            -state.width/2,
            -state.height/2)
        love.graphics.pop()
    end

    if state.isMoving then
        love.graphics.setColor(1, 1, 0, 0.6)
        love.graphics.circle("line", state.targetX, state.targetY, 12)
        love.graphics.line(state.targetX - 10, state.targetY, state.targetX + 10, state.targetY)
        love.graphics.line(state.targetX, state.targetY - 10, state.targetX, state.targetY + 10)

        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.line(state.x, state.y, state.targetX, state.targetY)
    end

    if state.isMoving and state.animationFrame % 2 == 0 then
        love.graphics.setColor(0.2, 0.6, 1.0, 0.2)
        love.graphics.circle("fill", state.x, state.y + state.height/2, 10)
    end

    love.graphics.setColor(1, 1, 1)
end

function Player.take_damage(state, damage)
    return CombatUtils.take_damageMutating(state, damage)
end

function Player.heal(state, amount)
    CombatUtils.healMutating(state, amount)
end

function Player.is_alive(state)
    return state.hp > 0
end

function Player.get_hp_percent(state)
    if not state.maxHp or state.maxHp <= 0 then return 0 end
    return state.hp / state.maxHp
end

function Player.calculate_damage(state)
    return CombatUtils.calculate_damageMutating(state)
end

function Player.set_equipment_system(state, equipSystem)
    state.equipmentSystem = equipSystem
    Player.update_stats_with_equipment(state)
end

function Player.set_inventory_system(state, invSystem)
    state.inventorySystem = invSystem
end

function Player.update_stats_with_equipment(state)
    if not state.equipmentSystem then
        return
    end

    local equipStats = EquipmentSystem.get_total_stats(state.equipmentSystem)
    state.attack = state.baseAttack + equipStats.attack
    state.defense = state.baseDefense + equipStats.defense
    state.battleSpeed = 6 + equipStats.speed
    state.crit = state.baseCrit + equipStats.crit
    state.eva = state.baseEva + equipStats.eva

    state.defPercent = EquipmentSystem.get_defense_percent(state.equipmentSystem)

    local oldMaxHp = state.maxHp
    state.maxHp = state.baseHp + (equipStats.hp or 0)
    if state.maxHp ~= oldMaxHp and state.hp > state.maxHp then
        state.hp = state.maxHp
    end
end

function Player.check_evade(state)
    return CombatUtils.check_evade(state)
end

return Player
