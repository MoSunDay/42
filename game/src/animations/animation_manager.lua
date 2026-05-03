local BreathingEffect = require("src.animations.breathing_effect")
local RunningEffect = require("src.animations.running_effect")

local AnimationManager = {}

function AnimationManager.create()
    return {
        animations = {}
    }
end

function AnimationManager.create_animation_set(state, entityId)
    state.animations[entityId] = {
        breathing = BreathingEffect.create(),
        running = RunningEffect.create()
    }
    return state.animations[entityId]
end

function AnimationManager.get_animation_set(state, entityId)
    if not state.animations[entityId] then
        return AnimationManager.create_animation_set(state, entityId)
    end
    return state.animations[entityId]
end

function AnimationManager.update_entity(state, entityId, dt, isMoving)
    local anims = AnimationManager.get_animation_set(state, entityId)

    BreathingEffect.update(anims.breathing, dt)
    RunningEffect.update(anims.running, dt, isMoving or false)
end

function AnimationManager.get_transform(state, entityId)
    local anims = AnimationManager.get_animation_set(state, entityId)

    local offsetX = 0
    local offsetY = 0
    local rotation = 0
    local scaleX = 1.0
    local scaleY = 1.0

    local breathScale = BreathingEffect.get_scale(anims.breathing)
    scaleX = scaleX * breathScale
    scaleY = scaleY * breathScale

    if RunningEffect.is_active(anims.running) or anims.running.time > 0 then
        offsetY = offsetY + RunningEffect.get_bob_offset(anims.running)
        rotation = RunningEffect.get_tilt(anims.running)

        local runScaleX, runScaleY = RunningEffect.get_scale(anims.running)
        scaleX = scaleX * runScaleX
        scaleY = scaleY * runScaleY
    end

    return offsetX, offsetY, rotation, scaleX, scaleY
end

function AnimationManager.remove_entity(state, entityId)
    state.animations[entityId] = nil
end

function AnimationManager.clear(state)
    state.animations = {}
end

return AnimationManager
