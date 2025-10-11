-- running_effect.lua - Running animation for characters
-- Creates bobbing and tilting effects when moving

local RunningEffect = {}
RunningEffect.__index = RunningEffect

function RunningEffect.new()
    local self = setmetatable({}, RunningEffect)
    
    self.time = 0
    self.isRunning = false
    self.runSpeed = 4.0  -- Animation speed (cycles per second)
    self.bobAmount = 3   -- Vertical bobbing amount (pixels)
    self.tiltAmount = 0.1  -- Rotation tilt amount (radians)
    
    return self
end

-- Update running animation
function RunningEffect:update(dt, isMoving)
    self.isRunning = isMoving
    
    if self.isRunning then
        self.time = self.time + dt
    else
        -- Gradually return to idle
        if self.time > 0 then
            self.time = self.time - dt * 2
            if self.time < 0 then
                self.time = 0
            end
        end
    end
end

-- Get vertical offset (bobbing)
function RunningEffect:getBobOffset()
    if self.time <= 0 then
        return 0
    end
    
    -- Use absolute sine for bobbing (always up/down, never negative)
    local cycle = math.abs(math.sin(self.time * math.pi * self.runSpeed))
    return -cycle * self.bobAmount
end

-- Get rotation tilt
function RunningEffect:getTilt()
    if self.time <= 0 then
        return 0
    end
    
    -- Use sine for left/right tilt
    local cycle = math.sin(self.time * math.pi * self.runSpeed)
    return cycle * self.tiltAmount
end

-- Get scale factor (slight squash and stretch)
function RunningEffect:getScale()
    if self.time <= 0 then
        return 1.0, 1.0
    end
    
    -- Squash and stretch
    local cycle = math.abs(math.sin(self.time * math.pi * self.runSpeed))
    local scaleX = 1.0 + cycle * 0.05  -- Slightly wider when compressed
    local scaleY = 1.0 - cycle * 0.05  -- Slightly shorter when compressed
    
    return scaleX, scaleY
end

-- Reset animation
function RunningEffect:reset()
    self.time = 0
    self.isRunning = false
end

-- Check if running
function RunningEffect:isActive()
    return self.isRunning
end

return RunningEffect

