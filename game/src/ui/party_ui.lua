-- party_ui.lua - Party UI display
-- Display party members and their status

local PartyUI = {}
PartyUI.__index = PartyUI

function PartyUI.new(assetManager)
    local self = setmetatable({}, PartyUI)
    
    self.assetManager = assetManager
    
    -- UI position (top-left, below character panel)
    self.x = 10
    self.y = 220
    self.width = 200
    self.memberHeight = 60
    
    -- Colors
    self.colors = {
        panel = {0.1, 0.1, 0.15, 0.9},
        border = {0.4, 0.6, 1.0, 0.8},
        leaderBorder = {1.0, 0.8, 0.2, 0.9},
        text = {1, 1, 1},
        hpBar = {0.2, 0.8, 0.2},
        hpBarBg = {0.3, 0.3, 0.3},
        offline = {0.5, 0.5, 0.5}
    }
    
    -- Fonts
    self.font = assetManager:getFont("default")
    
    -- Visibility
    self.isVisible = true
    
    return self
end

-- Toggle visibility
function PartyUI:toggle()
    self.isVisible = not self.isVisible
end

-- Set visibility
function PartyUI:setVisible(visible)
    self.isVisible = visible
end

-- Draw party UI
function PartyUI:draw(partySystem)
    if not self.isVisible or partySystem:isEmpty() then
        return
    end
    
    local members = partySystem:getMembers()
    local leaderIndex = partySystem.leaderIndex
    
    -- Calculate total height
    local totalHeight = 30 + #members * (self.memberHeight + 5)
    
    -- Draw panel background
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", self.x, self.y, self.width, totalHeight, 5, 5)
    
    -- Draw panel border
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, totalHeight, 5, 5)
    love.graphics.setLineWidth(1)
    
    -- Draw title
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf(partySystem:getPartyName() .. " (" .. #members .. "/5)", 
                        self.x, self.y + 8, self.width, "center")
    
    -- Draw members
    local memberY = self.y + 30
    for i, member in ipairs(members) do
        self:drawMember(member, self.x + 5, memberY, i == leaderIndex)
        memberY = memberY + self.memberHeight + 5
    end
end

-- Draw a single party member
function PartyUI:drawMember(member, x, y, isLeader)
    local w = self.width - 10
    local h = self.memberHeight
    
    -- Member background
    love.graphics.setColor(0.15, 0.15, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    
    -- Member border (gold for leader)
    if isLeader then
        love.graphics.setColor(self.colors.leaderBorder)
    else
        love.graphics.setColor(0.3, 0.3, 0.4)
    end
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 3, 3)
    love.graphics.setLineWidth(1)
    
    -- Avatar (small circle)
    local avatarX = x + 20
    local avatarY = y + h / 2
    local avatarSize = 15
    
    if member.isOnline then
        love.graphics.setColor(member.avatarColor)
    else
        love.graphics.setColor(self.colors.offline)
    end
    love.graphics.circle("fill", avatarX, avatarY, avatarSize)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", avatarX, avatarY, avatarSize)
    
    -- Leader crown
    if isLeader then
        love.graphics.setColor(1, 0.8, 0.2)
        love.graphics.print("★", avatarX - 5, avatarY - avatarSize - 15)
    end
    
    -- Member name
    love.graphics.setColor(self.colors.text)
    love.graphics.print(member.name, avatarX + avatarSize + 10, y + 8)
    
    -- Level
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Lv." .. member.level, avatarX + avatarSize + 10, y + 23)
    
    -- HP bar
    local hpBarX = avatarX + avatarSize + 10
    local hpBarY = y + 38
    local hpBarW = w - (avatarX + avatarSize + 15 - x)
    local hpBarH = 8
    
    -- HP bar background
    love.graphics.setColor(self.colors.hpBarBg)
    love.graphics.rectangle("fill", hpBarX, hpBarY, hpBarW, hpBarH, 2, 2)
    
    -- HP bar fill
    local hpPercent = member.hp / member.maxHp
    love.graphics.setColor(self.colors.hpBar)
    love.graphics.rectangle("fill", hpBarX, hpBarY, hpBarW * hpPercent, hpBarH, 2, 2)
    
    -- HP text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(member.hp .. "/" .. member.maxHp, 
                        hpBarX, hpBarY + 10, hpBarW, "center")
    
    -- Online status
    if not member.isOnline then
        love.graphics.setColor(0.8, 0.3, 0.3)
        love.graphics.print("Offline", x + w - 50, y + 8)
    end
end

-- Check if mouse is over party UI
function PartyUI:isMouseOver(x, y, partySystem)
    if not self.isVisible or partySystem:isEmpty() then
        return false
    end
    
    local members = partySystem:getMembers()
    local totalHeight = 30 + #members * (self.memberHeight + 5)
    
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + totalHeight
end

return PartyUI

