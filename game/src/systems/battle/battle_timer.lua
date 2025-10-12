-- battle_timer.lua - Battle turn timer management
-- Manages 90-second turn timer and auto-battle timeout

local BattleTimer = {}
BattleTimer.__index = BattleTimer

function BattleTimer.new(maxTime)
    local self = setmetatable({}, BattleTimer)
    
    self.maxTime = maxTime or 90.0
    self.currentTime = self.maxTime
    self.autoTriggeredByTimeout = false
    
    return self
end

-- Reset timer for new turn
function BattleTimer:reset()
    self.currentTime = self.maxTime
    self.autoTriggeredByTimeout = false
end

-- Update timer
function BattleTimer:update(dt)
    if self.currentTime > 0 then
        self.currentTime = self.currentTime - dt
        return self.currentTime <= 0  -- Return true if time's up
    end
    return false
end

-- Get current time
function BattleTimer:getTime()
    return self.currentTime
end

-- Get max time
function BattleTimer:getMaxTime()
    return self.maxTime
end

-- Mark as auto-triggered
function BattleTimer:setAutoTriggered(value)
    self.autoTriggeredByTimeout = value
end

-- Check if auto was triggered by timeout
function BattleTimer:isAutoTriggered()
    return self.autoTriggeredByTimeout
end

return BattleTimer

