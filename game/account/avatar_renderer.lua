-- avatar_renderer.lua - Character avatar rendering
-- 角色头像渲染（使用统一外观系统）

local AppearanceSystem = require("src.systems.appearance_system")

local AvatarRenderer = {}

-- Draw character avatar (uses unified appearance system)
function AvatarRenderer.drawAvatar(x, y, size, character)
    if not character then
        return
    end

    local appearance = AppearanceSystem.createAppearance(character)
    AppearanceSystem.drawAvatar(x, y, size, appearance)
end

-- Draw character info panel
function AvatarRenderer.drawCharacterPanel(x, y, width, height, character, font)
    if not character then
        return
    end
    
    font = font or love.graphics.newFont(14)
    
    -- Panel background
    love.graphics.setColor(0.15, 0.15, 0.2, 0.9)
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    -- Panel border
    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 5, 5)
    
    -- Avatar
    local avatarSize = 30
    local avatarX = x + avatarSize + 10
    local avatarY = y + avatarSize + 10
    AvatarRenderer.drawAvatar(avatarX, avatarY, avatarSize, character)
    
    -- Character name
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(character.characterName, avatarX + avatarSize + 15, y + 10)
    
    -- Stats
    local statsY = y + 70
    local lineHeight = 20
    
    love.graphics.setColor(0.9, 0.3, 0.3)
    love.graphics.print("HP: " .. character.hp .. "/" .. character.maxHp, x + 10, statsY)
    
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.print("Gold: " .. character.gold, x + 10, statsY + lineHeight)
    
    love.graphics.setColor(1, 0.5, 0.3)
    love.graphics.print("ATK: " .. character.attack, x + 10, statsY + lineHeight * 2)
    
    love.graphics.setColor(0.5, 0.7, 1)
    love.graphics.print("DEF: " .. character.defense, x + 10, statsY + lineHeight * 3)
end

-- Draw HP bar (for battle)
function AvatarRenderer.drawHPBar(x, y, width, height, current, max)
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.25)
    love.graphics.rectangle("fill", x, y, width, height, 3, 3)
    
    -- HP fill
    local hpPercent = current / max
    local color
    if hpPercent > 0.5 then
        color = {0.3, 0.8, 0.3}  -- Green
    elseif hpPercent > 0.25 then
        color = {0.9, 0.7, 0.2}  -- Yellow
    else
        color = {0.9, 0.3, 0.3}  -- Red
    end
    
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, width * hpPercent, height, 3, 3)
    
    -- Border
    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height, 3, 3)
    
    -- Text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(current .. "/" .. max, x, y + 2, width, "center")
end

return AvatarRenderer

