-- appearance_system.lua - Character appearance system
-- 统一管理角色外观（头像和精灵）

local AppearanceSystem = {}
AppearanceSystem.__index = AppearanceSystem

-- Appearance presets (predefined character looks)
local APPEARANCE_PRESETS = {
    blue_hero = {
        name = "Blue Hero",
        color = {0.3, 0.5, 1.0},
        eyeColor = {0.1, 0.1, 0.1},
        highlightColor = {1, 1, 1, 0.3}
    },
    red_warrior = {
        name = "Red Warrior",
        color = {1.0, 0.3, 0.3},
        eyeColor = {0.1, 0.1, 0.1},
        highlightColor = {1, 1, 1, 0.3}
    },
    green_ranger = {
        name = "Green Ranger",
        color = {0.3, 0.8, 0.3},
        eyeColor = {0.1, 0.1, 0.1},
        highlightColor = {1, 1, 1, 0.3}
    },
    yellow_mage = {
        name = "Yellow Mage",
        color = {1.0, 0.9, 0.2},
        eyeColor = {0.1, 0.1, 0.1},
        highlightColor = {1, 1, 1, 0.3}
    },
    purple_assassin = {
        name = "Purple Assassin",
        color = {0.7, 0.3, 0.9},
        eyeColor = {0.1, 0.1, 0.1},
        highlightColor = {1, 1, 1, 0.3}
    },
    cyan_priest = {
        name = "Cyan Priest",
        color = {0.3, 0.9, 0.9},
        eyeColor = {0.1, 0.1, 0.1},
        highlightColor = {1, 1, 1, 0.3}
    },
    orange_knight = {
        name = "Orange Knight",
        color = {1.0, 0.6, 0.2},
        eyeColor = {0.1, 0.1, 0.1},
        highlightColor = {1, 1, 1, 0.3}
    },
    pink_dancer = {
        name = "Pink Dancer",
        color = {1.0, 0.5, 0.8},
        eyeColor = {0.1, 0.1, 0.1},
        highlightColor = {1, 1, 1, 0.3}
    }
}

function AppearanceSystem.new()
    local self = setmetatable({}, AppearanceSystem)
    return self
end

-- Get appearance preset by ID
function AppearanceSystem.getPreset(presetId)
    return APPEARANCE_PRESETS[presetId] or APPEARANCE_PRESETS.blue_hero
end

-- Get all available presets
function AppearanceSystem.getAllPresets()
    local presets = {}
    for id, preset in pairs(APPEARANCE_PRESETS) do
        table.insert(presets, {id = id, preset = preset})
    end
    return presets
end

-- Draw character sprite (for game world)
function AppearanceSystem.drawSprite(x, y, size, appearance, offsetX, offsetY, scaleX, scaleY)
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    scaleX = scaleX or 1
    scaleY = scaleY or 1
    
    local color = appearance.color or {0.3, 0.5, 1.0}
    local eyeColor = appearance.eyeColor or {0.1, 0.1, 0.1}
    local highlightColor = appearance.highlightColor or {1, 1, 1, 0.3}
    
    love.graphics.push()
    love.graphics.translate(x + offsetX, y + offsetY)
    love.graphics.scale(scaleX, scaleY)
    
    -- Outer circle (border)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.circle("fill", 0, 0, size + 3)
    
    -- Main circle (body)
    love.graphics.setColor(color)
    love.graphics.circle("fill", 0, 0, size)
    
    -- Highlight
    love.graphics.setColor(highlightColor)
    love.graphics.circle("fill", -size * 0.3, -size * 0.3, size * 0.3)
    
    -- Eyes
    love.graphics.setColor(eyeColor)
    love.graphics.circle("fill", -size * 0.25, -size * 0.1, size * 0.15)
    love.graphics.circle("fill", size * 0.25, -size * 0.1, size * 0.15)
    
    -- Eye shine
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", -size * 0.25 + 2, -size * 0.1 - 2, size * 0.06)
    love.graphics.circle("fill", size * 0.25 + 2, -size * 0.1 - 2, size * 0.06)
    
    -- Smile
    love.graphics.setColor(eyeColor)
    love.graphics.setLineWidth(2)
    love.graphics.arc("line", "open", 0, size * 0.1, size * 0.4, 0.3, math.pi - 0.3)
    love.graphics.setLineWidth(1)
    
    love.graphics.pop()
end

-- Draw character avatar (for UI panels)
function AppearanceSystem.drawAvatar(x, y, size, appearance)
    -- Avatar is the same as sprite, just a wrapper for clarity
    AppearanceSystem.drawSprite(x, y, size, appearance, 0, 0, 1, 1)
end

-- Create appearance from character data
function AppearanceSystem.createAppearance(character)
    if not character then
        return AppearanceSystem.getPreset("blue_hero")
    end
    
    -- If character has a preset ID, use it
    if character.appearanceId then
        return AppearanceSystem.getPreset(character.appearanceId)
    end
    
    -- If character has custom colors, use them
    if character.avatarColor then
        return {
            name = character.name or "Custom",
            color = character.avatarColor,
            eyeColor = character.eyeColor or {0.1, 0.1, 0.1},
            highlightColor = character.highlightColor or {1, 1, 1, 0.3}
        }
    end
    
    -- Default to blue hero
    return AppearanceSystem.getPreset("blue_hero")
end

-- Set character appearance
function AppearanceSystem.setCharacterAppearance(character, presetId)
    if not character then
        return
    end
    
    local preset = AppearanceSystem.getPreset(presetId)
    character.appearanceId = presetId
    character.avatarColor = preset.color
    character.eyeColor = preset.eyeColor
    character.highlightColor = preset.highlightColor
end

return AppearanceSystem

