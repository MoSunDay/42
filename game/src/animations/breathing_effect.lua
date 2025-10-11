-- breathing_effect.lua - Breathing animation for characters and NPCs
-- Creates a subtle breathing effect by scaling the character

local BreathingEffect = {}
BreathingEffect.__index = BreathingEffect

function BreathingEffect.new()
    local self = setmetatable({}, BreathingEffect)
    
    self.time = 0
    self.breathSpeed = 1.5  -- Breathing cycle speed (seconds per breath)
    self.breathAmount = 0.05  -- How much to scale (5%)
    
    return self
end

-- Update breathing animation
function BreathingEffect:update(dt)
    self.time = self.time + dt
end

-- Get current scale factor
function BreathingEffect:getScale()
    -- Use sine wave for smooth breathing
    local breathCycle = math.sin(self.time * math.pi * 2 / self.breathSpeed)
    return 1.0 + breathCycle * self.breathAmount
end

-- Reset animation
function BreathingEffect:reset()
    self.time = 0
end

-- Set breathing speed
function BreathingEffect:setSpeed(speed)
    self.breathSpeed = speed
end

-- Set breathing amount
function BreathingEffect:setAmount(amount)
    self.breathAmount = amount
end

return BreathingEffect

