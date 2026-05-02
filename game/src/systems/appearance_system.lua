local AppearanceSystem = {}

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
    return {}
end

function AppearanceSystem.getPreset(presetId)
    return APPEARANCE_PRESETS[presetId] or APPEARANCE_PRESETS.blue_hero
end

function AppearanceSystem.getAllPresets()
    local presets = {}
    for id, preset in pairs(APPEARANCE_PRESETS) do
        table.insert(presets, {id = id, preset = preset})
    end
    return presets
end

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
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.circle("fill", 0, 0, size + 3)
    
    love.graphics.setColor(color)
    love.graphics.circle("fill", 0, 0, size)
    
    love.graphics.setColor(highlightColor)
    love.graphics.circle("fill", -size * 0.3, -size * 0.3, size * 0.3)
    
    love.graphics.setColor(eyeColor)
    love.graphics.circle("fill", -size * 0.25, -size * 0.1, size * 0.15)
    love.graphics.circle("fill", size * 0.25, -size * 0.1, size * 0.15)
    
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", -size * 0.25 + 2, -size * 0.1 - 2, size * 0.06)
    love.graphics.circle("fill", size * 0.25 + 2, -size * 0.1 - 2, size * 0.06)
    
    love.graphics.setColor(eyeColor)
    love.graphics.setLineWidth(2)
    love.graphics.arc("line", "open", 0, size * 0.1, size * 0.4, 0.3, math.pi - 0.3)
    love.graphics.setLineWidth(1)
    
    love.graphics.pop()
end

function AppearanceSystem.drawAvatar(x, y, size, appearance)
    AppearanceSystem.drawSprite(x, y, size, appearance, 0, 0, 1, 1)
end

function AppearanceSystem.createAppearance(character)
    if not character then
        return AppearanceSystem.getPreset("blue_hero")
    end
    
    if character.appearanceId then
        return AppearanceSystem.getPreset(character.appearanceId)
    end
    
    if character.avatarColor then
        return {
            name = character.name or "Custom",
            color = character.avatarColor,
            eyeColor = character.eyeColor or {0.1, 0.1, 0.1},
            highlightColor = character.highlightColor or {1, 1, 1, 0.3}
        }
    end
    
    return AppearanceSystem.getPreset("blue_hero")
end

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
