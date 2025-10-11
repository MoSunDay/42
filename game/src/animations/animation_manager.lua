-- animation_manager.lua - Centralized animation management
-- Manages all character and NPC animations

local BreathingEffect = require("src.animations.breathing_effect")
local RunningEffect = require("src.animations.running_effect")

local AnimationManager = {}
AnimationManager.__index = AnimationManager

function AnimationManager.new()
    local self = setmetatable({}, AnimationManager)
    
    -- Animation instances for different entities
    self.animations = {}
    
    return self
end

-- Create animation set for an entity
function AnimationManager:createAnimationSet(entityId)
    self.animations[entityId] = {
        breathing = BreathingEffect.new(),
        running = RunningEffect.new()
    }
    return self.animations[entityId]
end

-- Get animation set for an entity
function AnimationManager:getAnimationSet(entityId)
    if not self.animations[entityId] then
        return self:createAnimationSet(entityId)
    end
    return self.animations[entityId]
end

-- Update all animations for an entity
function AnimationManager:updateEntity(entityId, dt, isMoving)
    local anims = self:getAnimationSet(entityId)
    
    anims.breathing:update(dt)
    anims.running:update(dt, isMoving or false)
end

-- Get combined transform for rendering
-- Returns: offsetX, offsetY, rotation, scaleX, scaleY
function AnimationManager:getTransform(entityId)
    local anims = self:getAnimationSet(entityId)
    
    -- Start with defaults
    local offsetX = 0
    local offsetY = 0
    local rotation = 0
    local scaleX = 1.0
    local scaleY = 1.0
    
    -- Apply breathing (affects scale)
    local breathScale = anims.breathing:getScale()
    scaleX = scaleX * breathScale
    scaleY = scaleY * breathScale
    
    -- Apply running effects
    if anims.running:isActive() or anims.running.time > 0 then
        offsetY = offsetY + anims.running:getBobOffset()
        rotation = anims.running:getTilt()
        
        local runScaleX, runScaleY = anims.running:getScale()
        scaleX = scaleX * runScaleX
        scaleY = scaleY * runScaleY
    end
    
    return offsetX, offsetY, rotation, scaleX, scaleY
end

-- Remove animation set for an entity
function AnimationManager:removeEntity(entityId)
    self.animations[entityId] = nil
end

-- Clear all animations
function AnimationManager:clear()
    self.animations = {}
end

return AnimationManager

