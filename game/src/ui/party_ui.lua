-- party_ui.lua - Party UI display
-- Display party members and their status

local Theme = require("src.ui.theme")

local PartyUI = {}
PartyUI.__index = PartyUI

function PartyUI.new(assetManager)
    local self = setmetatable({}, PartyUI)
    
    self.assetManager = assetManager
    
    self.x = 10
    self.y = 220
    self.width = 200
    self.memberHeight = 60
    
    self.colors = Theme.colors.party
    
    self.font = assetManager:getFont("default")
    
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
    
    local totalHeight = 30 + #members * (self.memberHeight + 5)
    
    love.graphics.setColor(self.colors.panel)
    love.graphics.rectangle("fill", self.x, self.y, self.width, totalHeight, 5, 5)
    
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, self.y, self.width, totalHeight, 5, 5)
    love.graphics.setLineWidth(1)
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf(partySystem:getPartyName() .. " (" .. #members .. "/5)", 
                        self.x, self.y + 8, self.width, "center")
    
    local memberY = self.y + 30
    for i, member in ipairs(members) do
        self:drawMember(member, self.x + 5, memberY, i == leaderIndex)
        memberY = memberY + self.memberHeight + 5
    end
end

function PartyUI:drawMember(member, x, y, isLeader)
    local w = self.width - 10
    local h = self.memberHeight
    
    love.graphics.setColor(Theme.colors.panelLight[1], Theme.colors.panelLight[2], Theme.colors.panelLight[3], 0.8)
    love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    
    if isLeader then
        love.graphics.setColor(self.colors.leaderBorder)
    else
        love.graphics.setColor(Theme.colors.borderDim)
    end
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 3, 3)
    love.graphics.setLineWidth(1)
    
    local avatarX = x + 20
    local avatarY = y + h / 2
    local avatarSize = 15
    
    if member.isOnline then
        love.graphics.setColor(member.avatarColor)
    else
        love.graphics.setColor(self.colors.offline)
    end
    love.graphics.circle("fill", avatarX, avatarY, avatarSize)
    
    love.graphics.setColor(Theme.colors.text)
    love.graphics.circle("line", avatarX, avatarY, avatarSize)
    
    if isLeader then
        love.graphics.setColor(Theme.colors.warning)
        love.graphics.print("*", avatarX - 5, avatarY - avatarSize - 15)
    end
    
    love.graphics.setColor(self.colors.text)
    love.graphics.print(member.name, avatarX + avatarSize + 10, y + 8)

    local hpBarX = avatarX + avatarSize + 10
    local hpBarY = y + 38
    local hpBarW = w - (avatarX + avatarSize + 15 - x)
    local hpBarH = 8
    
    love.graphics.setColor(self.colors.hpBarBg)
    love.graphics.rectangle("fill", hpBarX, hpBarY, hpBarW, hpBarH, 2, 2)
    
    local hpPercent = member.hp / member.maxHp
    love.graphics.setColor(Theme.getHpColor(hpPercent))
    love.graphics.rectangle("fill", hpBarX, hpBarY, hpBarW * hpPercent, hpBarH, 2, 2)
    
    love.graphics.setColor(Theme.colors.text)
    love.graphics.printf(member.hp .. "/" .. member.maxHp, 
                        hpBarX, hpBarY + 10, hpBarW, "center")
    
    if not member.isOnline then
        love.graphics.setColor(Theme.colors.error)
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

