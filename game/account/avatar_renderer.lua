-- avatar_renderer.lua - Character avatar rendering
-- 角色头像渲染

local AvatarRenderer = {}

-- Draw character avatar (simple circle with color)
function AvatarRenderer.drawAvatar(x, y, size, character)
    if not character then
        return
    end
    
    local color = character.avatarColor or {0.3, 0.5, 1.0}
    
    -- Outer circle (border)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.circle("fill", x, y, size + 3)
    
    -- Main circle (avatar)
    love.graphics.setColor(color)
    love.graphics.circle("fill", x, y, size)
    
    -- Highlight
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.circle("fill", x - size * 0.3, y - size * 0.3, size * 0.3)
    
    -- Eyes
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.circle("fill", x - size * 0.25, y - size * 0.1, size * 0.15)
    love.graphics.circle("fill", x + size * 0.25, y - size * 0.1, size * 0.15)
    
    -- Eye shine
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.circle("fill", x - size * 0.25 + 2, y - size * 0.1 - 2, size * 0.06)
    love.graphics.circle("fill", x + size * 0.25 + 2, y - size * 0.1 - 2, size * 0.06)
    
    -- Smile
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.setLineWidth(2)
    love.graphics.arc("line", "open", x, y + size * 0.1, size * 0.4, 0.3, math.pi - 0.3)
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
    
    -- Level
    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.print("Lv." .. character.level, avatarX + avatarSize + 15, y + 30)
    
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
    
    -- EXP bar
    local expBarY = statsY + lineHeight * 4 + 10
    local expBarWidth = width - 20
    local expBarHeight = 15
    
    local expNeeded = character.level * 100
    local expProgress = character.exp / expNeeded
    
    -- EXP bar background
    love.graphics.setColor(0.2, 0.2, 0.25)
    love.graphics.rectangle("fill", x + 10, expBarY, expBarWidth, expBarHeight, 3, 3)
    
    -- EXP bar fill
    love.graphics.setColor(0.3, 0.8, 0.4)
    love.graphics.rectangle("fill", x + 10, expBarY, expBarWidth * expProgress, expBarHeight, 3, 3)
    
    -- EXP bar border
    love.graphics.setColor(0.4, 0.4, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 10, expBarY, expBarWidth, expBarHeight, 3, 3)
    
    -- EXP text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("EXP: " .. character.exp .. "/" .. expNeeded, 
        x + 10, expBarY + 1, expBarWidth, "center")
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

