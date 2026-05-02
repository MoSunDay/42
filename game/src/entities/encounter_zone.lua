-- encounter_zone.lua - Visible encounter monsters (明雷)
-- Visible monsters that trigger battles when player touches them

local Enemy = require("entities.enemy")

local EncounterZone = {}

function EncounterZone.create(x, y, radius)
    local state = {}

    state.x = x
    state.y = y
    state.radius = radius or 40
    state.isActive = true
    state.isTriggered = false

    state.enemyType = Enemy.getRandomType()
    state.color = EncounterZone.getColorForType(state.enemyType)
    state.animationTime = math.random() * 10
    state.assetManager = nil
    state.sprite = nil

    return state
end

function EncounterZone.setAssetManager(state, assetManager)
    state.assetManager = assetManager
    if assetManager then
        local spriteMap = {
            slime = "slime", goblin = "goblin", skeleton = "skeleton",
            bat = "bat", wolf = "wolf", orc = "orc_warrior",
            orc_warrior = "orc_warrior", skeleton_knight = "skeleton_knight",
            dark_mage = "dark_mage", orc_chieftain = "orc_chieftain",
            vampire = "vampire", golem = "golem", demon = "demon",
            ancient_dragon = "ancient_dragon", lich_king = "lich_king",
            chaos_serpent = "chaos_serpent", dragon = "ancient_dragon"
        }
        local spriteId = spriteMap[state.enemyType] or state.enemyType
        state.sprite = assetManager:getEnemySprite(spriteId, "south")
    end
end

-- Get color based on enemy type
function EncounterZone.getColorForType(enemyType)
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
function EncounterZone.contains(state, x, y)
    if not state.isActive then
        return false
    end

    local dx = x - state.x
    local dy = y - state.y
    local distance = math.sqrt(dx * dx + dy * dy)

    -- Add player collision radius (16 pixels) to detection
    local playerRadius = 16
    return distance <= (state.radius + playerRadius)
end

-- Trigger the encounter
function EncounterZone.trigger(state)
    if state.isActive and not state.isTriggered then
        state.isTriggered = true
        state.isActive = false
        return true
    end
    return false
end

-- Reset the zone
function EncounterZone.reset(state)
    state.isActive = true
    state.isTriggered = false
end

-- Deactivate the zone
function EncounterZone.deactivate(state)
    state.isActive = false
end

-- Update animation
function EncounterZone.update(state, dt)
    if state.isActive then
        state.animationTime = state.animationTime + dt
    end
end

-- Draw the visible monster (in world space, camera will transform)
function EncounterZone.draw(state, camera)
    if not state.isActive then
        return
    end

    local breathe = math.sin(state.animationTime * 2) * 2
    local size = state.radius + breathe

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", state.x, state.y + size + 5, size * 0.8, size * 0.3)

    if state.sprite then
        love.graphics.setColor(1, 1, 1, 1)
        local sw, sh = state.sprite:getDimensions()
        local bobY = math.sin(state.animationTime * 2) * 2
        love.graphics.draw(state.sprite, state.x - sw / 2, state.y - sh / 2 + bobY, 0, 1, 1)
    else
        love.graphics.setColor(state.color[1], state.color[2], state.color[3], 0.9)
        love.graphics.circle("fill", state.x, state.y, size)

        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", state.x - size * 0.3, state.y - size * 0.2, size * 0.2)
        love.graphics.circle("fill", state.x + size * 0.3, state.y - size * 0.2, size * 0.2)

        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", state.x - size * 0.3, state.y - size * 0.2, size * 0.1)
        love.graphics.circle("fill", state.x + size * 0.3, state.y - size * 0.2, size * 0.1)

        love.graphics.setColor(state.color[1] * 0.7, state.color[2] * 0.7, state.color[3] * 0.7)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", state.x, state.y, size)
        love.graphics.setLineWidth(1)
    end
end

-- Get enemy type for battle
function EncounterZone.getEnemyType(state)
    return state.enemyType
end

return EncounterZone
