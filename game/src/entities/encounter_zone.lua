-- encounter_zone.lua - Visible encounter monsters (明雷)
-- Visible monsters that trigger battles when player touches them

local Enemy = require("entities.enemy")

local EncounterZone = {}
EncounterZone.__index = EncounterZone

function EncounterZone.new(x, y, radius)
    local self = setmetatable({}, EncounterZone)

    self.x = x
    self.y = y
    self.radius = radius or 20  -- Smaller radius for visible monsters
    self.isActive = true
    self.isTriggered = false

    -- Visual representation
    self.enemyType = Enemy.getRandomType()
    self.color = self:getColorForType(self.enemyType)
    self.animationTime = math.random() * 10  -- Random start time for animation

    return self
end

-- Get color based on enemy type
function EncounterZone:getColorForType(enemyType)
    local colors = {
        slime = {0.2, 0.8, 0.3},      -- Green
        goblin = {0.6, 0.4, 0.2},     -- Brown
        skeleton = {0.9, 0.9, 0.9},   -- White
        orc = {0.5, 0.3, 0.2},        -- Dark brown
        dragon = {0.8, 0.2, 0.2},     -- Red
        wolf = {0.5, 0.5, 0.5},       -- Gray
        bat = {0.3, 0.2, 0.3}         -- Purple
    }
    return colors[enemyType] or {0.5, 0.5, 0.5}
end

-- Check if point is inside zone (with player collision radius)
function EncounterZone:contains(x, y)
    if not self.isActive then
        return false
    end

    local dx = x - self.x
    local dy = y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    -- Add player collision radius (16 pixels) to detection
    local playerRadius = 16
    return distance <= (self.radius + playerRadius)
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

-- Update animation
function EncounterZone:update(dt)
    if self.isActive then
        self.animationTime = self.animationTime + dt
    end
end

-- Draw the visible monster
function EncounterZone:draw(camera)
    if not self.isActive then
        return
    end

    -- Get screen position
    local screenX, screenY = camera:toScreen(self.x, self.y)

    -- Breathing animation
    local breathe = math.sin(self.animationTime * 2) * 2
    local size = self.radius + breathe

    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", screenX, screenY + size + 5, size * 0.8, size * 0.3)

    -- Draw monster body
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.9)
    love.graphics.circle("fill", screenX, screenY, size)

    -- Draw eyes (simple)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", screenX - size * 0.3, screenY - size * 0.2, size * 0.2)
    love.graphics.circle("fill", screenX + size * 0.3, screenY - size * 0.2, size * 0.2)

    -- Draw pupils
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", screenX - size * 0.3, screenY - size * 0.2, size * 0.1)
    love.graphics.circle("fill", screenX + size * 0.3, screenY - size * 0.2, size * 0.1)

    -- Draw border
    love.graphics.setColor(self.color[1] * 0.7, self.color[2] * 0.7, self.color[3] * 0.7)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", screenX, screenY, size)
    love.graphics.setLineWidth(1)
end

-- Get enemy type for battle
function EncounterZone:getEnemyType()
    return self.enemyType
end

return EncounterZone

