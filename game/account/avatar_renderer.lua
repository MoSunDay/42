-- avatar_renderer.lua - Character avatar rendering
-- 角色头像渲染（使用统一外观系统）

local AppearanceSystem = require("src.systems.appearance_system")
local Components = require("src.ui.components")
local Theme = require("src.ui.theme")

local AvatarRenderer = {}

-- Draw character avatar (uses unified appearance system)
function AvatarRenderer.draw_avatar(x, y, size, character)
    if not character then
        return
    end

    local appearance = AppearanceSystem.create_appearance(character)
    AppearanceSystem.draw_avatar(x, y, size, appearance)
end

-- Draw character info panel
function AvatarRenderer.draw_character_panel(x, y, width, height, character, font, assetManager)
    if not character then
        return
    end
    
    font = font or love.graphics.newFont(14)
    
    Components.drawOrnatePanel(x, y, width, height, assetManager, {title="Player", corners=true, glow=true})
    
    -- Avatar
    local avatarSize = 30
    local avatarX = x + avatarSize + 10
    local avatarY = y + avatarSize + 10
    AvatarRenderer.draw_avatar(avatarX, avatarY, avatarSize, character)
    
    -- Character name
    love.graphics.setFont(font)
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print(character.characterName, avatarX + avatarSize + 15, y + 10)
    
    local statsY = y + 70
    local lineHeight = 20
    
    love.graphics.setColor(Theme.colors.hp.high)
    love.graphics.print("HP: " .. character.hp .. "/" .. character.maxHp, x + 10, statsY)
    
    love.graphics.setColor(Theme.colors.equipment.weapon)
    love.graphics.print("ATK: " .. character.attack, x + 10, statsY + lineHeight)
    
    love.graphics.setColor(Theme.colors.equipment.clothes)
    love.graphics.print("DEF: " .. character.defense, x + 10, statsY + lineHeight * 2)
end

-- Draw HP bar (for battle)
function AvatarRenderer.draw_hp_bar(x, y, width, height, current, max, assetManager)
    local hpPercent = current / max
    Components.drawOrnateHPBar(x, y, width, height, hpPercent, nil, assetManager)
    
    -- Text
    love.graphics.setColor(Theme.colors.text)
    love.graphics.printf(current .. "/" .. max, x, y + 2, width, "center")
end

return AvatarRenderer

