local SkillSystem = require("src.systems.skill_system")
local SkillDatabase = require("src.data.skill_database")
local ClassDatabase = require("src.data.class_database")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local SkillPanel = {}

function SkillPanel.create(assetManager)
    local state = {}
    
    state.assetManager = assetManager
    state.isOpen = false
    state.selectedSkillIndex = 1
    state.tab = "unlocked"
    state.message = ""
    state.messageTimer = 0
    
    return state
end

function SkillPanel.open(state, player)
    state.player = player
    state.isOpen = true
    state.selectedSkillIndex = 1
    state.tab = "unlocked"
    SkillPanel.updateSkillLists(state)
end

function SkillPanel.close(state)
    state.isOpen = false
    state.player = nil
end

function SkillPanel.updateSkillLists(state)
    if not state.player then return end
    
    state.unlockedSkills = SkillSystem.getAvailableSkills(state.player)
    state.lockedSkills = SkillSystem.getLockedSkills(state.player)
end

function SkillPanel.toggle(state, player)
    if state.isOpen then
        SkillPanel.close(state)
    else
        SkillPanel.open(state, player)
    end
end

function SkillPanel.showMessage(state, msg)
    state.message = msg
    state.messageTimer = 3
end

function SkillPanel.update(state, dt)
    if state.messageTimer > 0 then
        state.messageTimer = state.messageTimer - dt
        if state.messageTimer <= 0 then
            state.message = ""
        end
    end
end

function SkillPanel.draw(state)
    if not state.isOpen or not state.player then return end
    
    local w, h = love.graphics.getDimensions()
    
    Components.drawOverlay(w, h, 0.7)
    
    local panelW, panelH = 700, 500
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2
    
    local class = ClassDatabase.getClass(state.player.classId)
    local title = string.format("技能面板 - %s", class and class.name or "Unknown")
    Components.drawOrnatePanel(panelX, panelY, panelW, panelH, state.assetManager, {title = title, corners = true, glow = true})
    
    love.graphics.setColor(0.8, 0.6, 0.2)
    love.graphics.printf(string.format("灵晶: %d", state.player.skillCrystals or 0), panelX, panelY + 40, panelW, "center")
    
    local tabW = 120
    local tabH = 35
    local tabY = panelY + 70
    
    local unlockedTabX = panelX + panelW/2 - tabW - 10
    local lockedTabX = panelX + panelW/2 + 10
    
    Components.drawTab(unlockedTabX, tabY, tabW, tabH, "已解锁", state.tab == "unlocked", state.assetManager, love.graphics.getFont())
    Components.drawTab(lockedTabX, tabY, tabW, tabH, "未解锁", state.tab == "locked", state.assetManager, love.graphics.getFont())
    
    local listY = tabY + tabH + 15
    local listH = 280
    local listX = panelX + 20
    local listW = panelW - 40
    
    Components.drawOrnatePanel(listX, listY, listW, listH, state.assetManager, {corners=false, glow=false, borderColor={0.2, 0.2, 0.2}})
    
    local skills = state.tab == "unlocked" and state.unlockedSkills or state.lockedSkills
    
    if #skills == 0 then
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.printf(state.tab == "unlocked" and "暂无已解锁技能" or "所有技能已解锁", listX, listY + listH/2, listW, "center")
    else
        local itemH = 65
        local maxVisible = math.floor(listH / itemH)
        local startY = listY + 5
        
        for i, skillData in ipairs(skills) do
            if i > maxVisible then break end
            
            local itemY = startY + (i - 1) * itemH
            local isSelected = (i == state.selectedSkillIndex)
            
            if isSelected then
                Components.drawOrnatePanel(listX + 5, itemY, listW - 10, itemH - 5, state.assetManager, {
                    corners = false,
                    glow = true,
                    borderColor = Theme.colors.borderBright,
                    glowIntensity = 0.15
                })
            end
            
            love.graphics.setColor(1, 1, 1)
            local skill = skillData.data
            
            if state.tab == "unlocked" then
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
    
    if state.message ~= "" then
        love.graphics.setColor(0.2, 0.8, 0.4)
        love.graphics.printf(state.message, panelX, panelY + panelH - 80, panelW, "center")
    end
    
    local btnY = panelY + panelH - 50
    local btnW = 120
    local btnH = 35
    
    if state.tab == "unlocked" and #state.unlockedSkills > 0 then
        Components.drawOrnateButton(panelX + 50, btnY, btnW, btnH, "升级技能", "normal", state.assetManager, love.graphics.getFont())
    elseif state.tab == "locked" and #state.lockedSkills > 0 then
        Components.drawOrnateButton(panelX + 50, btnY, btnW, btnH, "解锁技能", "normal", state.assetManager, love.graphics.getFont())
    end
    
    Components.drawOrnateButton(panelX + panelW - 170, btnY, btnW, btnH, "关闭", "normal", state.assetManager, love.graphics.getFont())
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("↑↓选择  Enter确认  Tab切换  ESC关闭", panelX, panelY + panelH - 20, panelW, "center")
end

function SkillPanel.keypressed(state, key)
    if not state.isOpen then return false end
    
    if key == "escape" then
        SkillPanel.close(state)
        return true
    end
    
    if key == "tab" then
        state.tab = state.tab == "unlocked" and "locked" or "unlocked"
        state.selectedSkillIndex = 1
        return true
    end
    
    local skills = state.tab == "unlocked" and state.unlockedSkills or state.lockedSkills
    
    if key == "up" then
        state.selectedSkillIndex = math.max(1, state.selectedSkillIndex - 1)
        return true
    elseif key == "down" then
        state.selectedSkillIndex = math.min(#skills, state.selectedSkillIndex + 1)
        return true
    elseif key == "return" then
        if #skills > 0 and state.selectedSkillIndex <= #skills then
            local skillData = skills[state.selectedSkillIndex]
            if state.tab == "unlocked" then
                local success, msg = SkillSystem.upgradeSkill(state.player, skillData.id)
                SkillPanel.showMessage(state, msg)
                if success then
                    SkillPanel.updateSkillLists(state)
                end
            else
                local success, msg = SkillSystem.unlockSkill(state.player, skillData.id)
                SkillPanel.showMessage(state, msg)
                if success then
                    SkillPanel.updateSkillLists(state)
                end
            end
        end
        return true
    end
    
    return true
end

function SkillPanel.mousepressed(state, x, y, button)
    if not state.isOpen then return false end
    
    local w, h = love.graphics.getDimensions()
    local panelW, panelH = 700, 500
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2
    
    if button == 1 then
        if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
            SkillPanel.close(state)
            return true
        end
        
        local tabW = 120
        local tabH = 35
        local tabY = panelY + 70
        
        local unlockedTabX = panelX + panelW/2 - tabW - 10
        local lockedTabX = panelX + panelW/2 + 10
        
        if y >= tabY and y <= tabY + tabH then
            if x >= unlockedTabX and x <= unlockedTabX + tabW then
                state.tab = "unlocked"
                state.selectedSkillIndex = 1
                return true
            elseif x >= lockedTabX and x <= lockedTabX + tabW then
                state.tab = "locked"
                state.selectedSkillIndex = 1
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
            local skills = state.tab == "unlocked" and state.unlockedSkills or state.lockedSkills
            if clickedIndex >= 1 and clickedIndex <= #skills then
                state.selectedSkillIndex = clickedIndex
            end
            return true
        end
        
        local btnY = panelY + panelH - 50
        local btnW = 120
        local btnH = 35
        
        if y >= btnY and y <= btnY + btnH then
            if x >= panelX + 50 and x <= panelX + 50 + btnW then
                local skills = state.tab == "unlocked" and state.unlockedSkills or state.lockedSkills
                if #skills > 0 and state.selectedSkillIndex <= #skills then
                    local skillData = skills[state.selectedSkillIndex]
                    if state.tab == "unlocked" then
                        local success, msg = SkillSystem.upgradeSkill(state.player, skillData.id)
                        SkillPanel.showMessage(state, msg)
                        if success then
                            SkillPanel.updateSkillLists(state)
                        end
                    else
                        local success, msg = SkillSystem.unlockSkill(state.player, skillData.id)
                        SkillPanel.showMessage(state, msg)
                        if success then
                            SkillPanel.updateSkillLists(state)
                        end
                    end
                end
                return true
            end
            
            if x >= panelX + panelW - 170 and x <= panelX + panelW - 170 + btnW then
                SkillPanel.close(state)
                return true
            end
        end
    end
    
    return true
end

return SkillPanel
