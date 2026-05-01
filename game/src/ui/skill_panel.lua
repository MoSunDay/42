local SkillSystem = require("src.systems.skill_system")
local SkillDatabase = require("src.data.skill_database")
local ClassDatabase = require("src.data.class_database")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local SkillPanel = {}
SkillPanel.__index = SkillPanel

function SkillPanel.new()
    local self = setmetatable({}, SkillPanel)
    
    self.isOpen = false
    self.selectedSkillIndex = 1
    self.tab = "unlocked"
    self.message = ""
    self.messageTimer = 0
    
    return self
end

function SkillPanel:open(player)
    self.player = player
    self.isOpen = true
    self.selectedSkillIndex = 1
    self.tab = "unlocked"
    self:updateSkillLists()
end

function SkillPanel:close()
    self.isOpen = false
    self.player = nil
end

function SkillPanel:updateSkillLists()
    if not self.player then return end
    
    self.unlockedSkills = SkillSystem.getAvailableSkills(self.player)
    self.lockedSkills = SkillSystem.getLockedSkills(self.player)
end

function SkillPanel:toggle(player)
    if self.isOpen then
        self:close()
    else
        self:open(player)
    end
end

function SkillPanel:showMessage(msg)
    self.message = msg
    self.messageTimer = 3
end

function SkillPanel:update(dt)
    if self.messageTimer > 0 then
        self.messageTimer = self.messageTimer - dt
        if self.messageTimer <= 0 then
            self.message = ""
        end
    end
end

function SkillPanel:draw()
    if not self.isOpen or not self.player then return end
    
    local w, h = love.graphics.getDimensions()
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    local panelW, panelH = 700, 500
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2
    
    Components.drawPanelSimple(panelX, panelY, panelW, panelH, 10)
    
    love.graphics.setColor(1, 1, 1)
    local class = self.player:getClass()
    local title = string.format("技能面板 - %s", class and class.name or "Unknown")
    love.graphics.printf(title, panelX, panelY + 15, panelW, "center")
    
    love.graphics.setColor(0.8, 0.6, 0.2)
    love.graphics.printf(string.format("灵晶: %d", self.player.skillCrystals or 0), panelX, panelY + 40, panelW, "center")
    
    local tabW = 120
    local tabH = 35
    local tabY = panelY + 70
    
    local unlockedTabX = panelX + panelW/2 - tabW - 10
    local lockedTabX = panelX + panelW/2 + 10
    
    love.graphics.setColor(self.tab == "unlocked" and {0.3, 0.5, 0.7} or {0.2, 0.2, 0.2})
    love.graphics.rectangle("fill", unlockedTabX, tabY, tabW, tabH, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("已解锁", unlockedTabX, tabY + 10, tabW, "center")
    
    love.graphics.setColor(self.tab == "locked" and {0.3, 0.5, 0.7} or {0.2, 0.2, 0.2})
    love.graphics.rectangle("fill", lockedTabX, tabY, tabW, tabH, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("未解锁", lockedTabX, tabY + 10, tabW, "center")
    
    local listY = tabY + tabH + 15
    local listH = 280
    local listX = panelX + 20
    local listW = panelW - 40
    
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", listX, listY, listW, listH, 5, 5)
    
    local skills = self.tab == "unlocked" and self.unlockedSkills or self.lockedSkills
    
    if #skills == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.printf(self.tab == "unlocked" and "暂无已解锁技能" or "所有技能已解锁", listX, listY + listH/2, listW, "center")
    else
        local itemH = 65
        local maxVisible = math.floor(listH / itemH)
        local startY = listY + 5
        
        for i, skillData in ipairs(skills) do
            if i > maxVisible then break end
            
            local itemY = startY + (i - 1) * itemH
            local isSelected = (i == self.selectedSkillIndex)
            
            if isSelected then
                love.graphics.setColor(0.3, 0.4, 0.6, 0.5)
                love.graphics.rectangle("fill", listX + 5, itemY, listW - 10, itemH - 5, 5, 5)
            end
            
            love.graphics.setColor(1, 1, 1)
            local skill = skillData.data
            
            if self.tab == "unlocked" then
                love.graphics.print(string.format("%s Lv.%d", skill.name, skillData.level), listX + 15, itemY + 5)
                
                love.graphics.setColor(0.7, 0.7, 0.7)
                love.graphics.print(skill.description, listX + 15, itemY + 22)
                
                love.graphics.setColor(0.6, 0.8, 0.6)
                local dmgText = ""
                if skill.damageMultiplier then
                    dmgText = string.format("伤害: %d%%", skillData.effectiveDamage * 100)
                elseif skill.healPercent then
                    dmgText = string.format("治疗: %d%%HP", skillData.effectiveHeal * 100)
                end
                love.graphics.print(dmgText, listX + 15, itemY + 39)
                
                love.graphics.setColor(0.5, 0.5, 0.8)
                love.graphics.print(string.format("MP: %d", skill.mpCost), listX + 200, itemY + 39)
                
                love.graphics.setColor(0.9, 0.7, 0.3)
                love.graphics.print(string.format("升级: %d灵晶", skillData.upgradeCost), listX + 350, itemY + 39)
            else
                love.graphics.print(skill.name, listX + 15, itemY + 5)
                
                love.graphics.setColor(0.7, 0.7, 0.7)
                love.graphics.print(skill.description, listX + 15, itemY + 22)
                
                love.graphics.setColor(0.6, 0.6, 0.6)
                love.graphics.print(string.format("等级: %s", SkillDatabase.getSkillTierName(skill.tier)), listX + 15, itemY + 39)
                
                love.graphics.setColor(0.9, 0.6, 0.3)
                love.graphics.print(string.format("解锁: %d灵晶", skillData.unlockCost), listX + 350, itemY + 39)
            end
        end
    end
    
    if self.message ~= "" then
        love.graphics.setColor(0.2, 0.8, 0.4)
        love.graphics.printf(self.message, panelX, panelY + panelH - 80, panelW, "center")
    end
    
    local btnY = panelY + panelH - 50
    local btnW = 120
    local btnH = 35
    
    if self.tab == "unlocked" and #self.unlockedSkills > 0 then
        Components.drawButtonSimple(panelX + 50, btnY, btnW, btnH, "升级技能", false, false, love.graphics.getFont())
    elseif self.tab == "locked" and #self.lockedSkills > 0 then
        Components.drawButtonSimple(panelX + 50, btnY, btnW, btnH, "解锁技能", false, false, love.graphics.getFont())
    end
    
    Components.drawButtonSimple(panelX + panelW - 170, btnY, btnW, btnH, "关闭", false, false, love.graphics.getFont())
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("↑↓选择  Enter确认  Tab切换  ESC关闭", panelX, panelY + panelH - 20, panelW, "center")
end

function SkillPanel:keypressed(key)
    if not self.isOpen then return false end
    
    if key == "escape" then
        self:close()
        return true
    end
    
    if key == "tab" then
        self.tab = self.tab == "unlocked" and "locked" or "unlocked"
        self.selectedSkillIndex = 1
        return true
    end
    
    local skills = self.tab == "unlocked" and self.unlockedSkills or self.lockedSkills
    
    if key == "up" then
        self.selectedSkillIndex = math.max(1, self.selectedSkillIndex - 1)
        return true
    elseif key == "down" then
        self.selectedSkillIndex = math.min(#skills, self.selectedSkillIndex + 1)
        return true
    elseif key == "return" then
        if #skills > 0 and self.selectedSkillIndex <= #skills then
            local skillData = skills[self.selectedSkillIndex]
            if self.tab == "unlocked" then
                local success, msg = SkillSystem.upgradeSkill(self.player, skillData.id)
                self:showMessage(msg)
                if success then
                    self:updateSkillLists()
                end
            else
                local success, msg = SkillSystem.unlockSkill(self.player, skillData.id)
                self:showMessage(msg)
                if success then
                    self:updateSkillLists()
                end
            end
        end
        return true
    end
    
    return true
end

function SkillPanel:mousepressed(x, y, button)
    if not self.isOpen then return false end
    
    local w, h = love.graphics.getDimensions()
    local panelW, panelH = 700, 500
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2
    
    if button == 1 then
        if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
            self:close()
            return true
        end
        
        local tabW = 120
        local tabH = 35
        local tabY = panelY + 70
        
        local unlockedTabX = panelX + panelW/2 - tabW - 10
        local lockedTabX = panelX + panelW/2 + 10
        
        if y >= tabY and y <= tabY + tabH then
            if x >= unlockedTabX and x <= unlockedTabX + tabW then
                self.tab = "unlocked"
                self.selectedSkillIndex = 1
                return true
            elseif x >= lockedTabX and x <= lockedTabX + tabW then
                self.tab = "locked"
                self.selectedSkillIndex = 1
                return true
            end
        end
        
        local listY = tabY + tabH + 15
        local listH = 280
        local listX = panelX + 20
        local listW = panelW - 40
        local itemH = 65
        
        if x >= listX and x <= listX + listW and y >= listY and y <= listY + listH then
            local clickedIndex = math.floor((y - listY) / itemH) + 1
            local skills = self.tab == "unlocked" and self.unlockedSkills or self.lockedSkills
            if clickedIndex >= 1 and clickedIndex <= #skills then
                self.selectedSkillIndex = clickedIndex
            end
            return true
        end
        
        local btnY = panelY + panelH - 50
        local btnW = 120
        local btnH = 35
        
        if y >= btnY and y <= btnY + btnH then
            if x >= panelX + 50 and x <= panelX + 50 + btnW then
                local skills = self.tab == "unlocked" and self.unlockedSkills or self.lockedSkills
                if #skills > 0 and self.selectedSkillIndex <= #skills then
                    local skillData = skills[self.selectedSkillIndex]
                    if self.tab == "unlocked" then
                        local success, msg = SkillSystem.upgradeSkill(self.player, skillData.id)
                        self:showMessage(msg)
                        if success then
                            self:updateSkillLists()
                        end
                    else
                        local success, msg = SkillSystem.unlockSkill(self.player, skillData.id)
                        self:showMessage(msg)
                        if success then
                            self:updateSkillLists()
                        end
                    end
                end
                return true
            end
            
            if x >= panelX + panelW - 170 and x <= panelX + panelW - 170 + btnW then
                self:close()
                return true
            end
        end
    end
    
    return true
end

return SkillPanel
