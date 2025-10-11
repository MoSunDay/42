-- encounter_zone.lua - Hidden encounter zones (dark mines/暗雷)
-- Invisible zones that trigger battles when player enters

local EncounterZone = {}
EncounterZone.__index = EncounterZone

function EncounterZone.new(x, y, radius)
    local self = setmetatable({}, EncounterZone)
    
    self.x = x
    self.y = y
    self.radius = radius or 50
    self.isActive = true
    self.isTriggered = false
    
    return self
end

-- Check if point is inside zone
function EncounterZone:contains(x, y)
    if not self.isActive then
        return false
    end
    
    local dx = x - self.x
    local dy = y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    return distance <= self.radius
end

-- Trigger the encounter
function EncounterZone:trigger()
    if self.isActive and not self.isTriggered then
        self.isTriggered = true
        self.isActive = false
        return true
    end
    return false
end

-- Reset the zone
function EncounterZone:reset()
    self.isActive = true
    self.isTriggered = false
end

-- Deactivate the zone
function EncounterZone:deactivate()
    self.isActive = false
end

return EncounterZone

