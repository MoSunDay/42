local TutorialPanel = {}
TutorialPanel.__index = TutorialPanel

local Theme = require("src.ui.theme")

function TutorialPanel.new(tutorialSystem)
    local self = setmetatable({}, TutorialPanel)
    
    self.tutorialSystem = tutorialSystem
    self.visible = false
    self.alpha = 0
    
    self.panelWidth = 500
    self.panelHeight = 350
    self.panelX = 0
    self.panelY = 0
    
    self.buttonWidth = 100
    self.buttonHeight = 36
    self.buttonY = 0
    
    self.textColor = {1, 1, 1, 1}
    self.titleColor = {1, 0.85, 0.2, 1}
    self.bgColor = {0.1, 0.1, 0.15, 0.95}
    self.borderColor = {0.4, 0.6, 0.9, 1}
    
    self.font = nil
    self.titleFont = nil
    self.smallFont = nil
    
    self.hoveredButton = nil
    
    return self
end

function TutorialPanel:init()
    self.font = love.graphics.newFont(18)
    self.titleFont = love.graphics.newFont(24)
    self.smallFont = love.graphics.newFont(14)
    
    self:updatePosition()
end

function TutorialPanel:updatePosition()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    self.panelX = (screenWidth - self.panelWidth) / 2
    self.panelY = (screenHeight - self.panelHeight) / 2
    
    self.buttonY = self.panelY + self.panelHeight - 50
end

function TutorialPanel:show()
    self.visible = true
    self.alpha = 0
end

function TutorialPanel:hide()
    self.visible = false
    self.alpha = 0
end

function TutorialPanel:isVisible()
    return self.visible
end

function TutorialPanel:update(dt)
    if not self.visible then return end
    
    if self.alpha < 1 then
        self.alpha = math.min(1, self.alpha + dt * 4)
    end
    
    self:updatePosition()
    
    local mx, my = love.mouse.getPosition()
    self.hoveredButton = nil
    
    local buttonStartX = self.panelX + (self.panelWidth - 320) / 2
    
    if self.tutorialSystem:canSkip() then
        if mx >= buttonStartX and mx <= buttonStartX + self.buttonWidth and
           my >= self.buttonY and my <= self.buttonY + self.buttonHeight then
            self.hoveredButton = "skip"
        end
    end
    
    local prevX = buttonStartX + 110
    if mx >= prevX and mx <= prevX + self.buttonWidth and
       my >= self.buttonY and my <= self.buttonY + self.buttonHeight then
        if not self.hoveredButton then
            self.hoveredButton = "prev"
        end
    end
    
    local nextX = buttonStartX + 220
    if mx >= nextX and mx <= nextX + self.buttonWidth and
       my >= self.buttonY and my <= self.buttonY + self.buttonHeight then
        if not self.hoveredButton then
            self.hoveredButton = self.tutorialSystem:isLastPage() and "complete" or "next"
        end
    end
end

function TutorialPanel:draw()
    if not self.visible then return end
    
    love.graphics.push("all")
    
    self:drawBackground()
    self:drawPanel()
    self:drawContent()
    self:drawButtons()
    self:drawProgress()
    
    love.graphics.pop()
end

function TutorialPanel:drawBackground()
    love.graphics.setColor(0, 0, 0, 0.5 * self.alpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function TutorialPanel:drawPanel()
    local r, g, b, a = self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4] * self.alpha
    love.graphics.setColor(r, g, b, a)
    
    love.graphics.rectangle("fill", self.panelX, self.panelY, self.panelWidth, self.panelHeight, 10, 10)
    
    local br, bg, bb, ba = self.borderColor[1], self.borderColor[2], self.borderColor[3], self.borderColor[4] * self.alpha
    love.graphics.setColor(br, bg, bb, ba)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.panelX, self.panelY, self.panelWidth, self.panelHeight, 10, 10)
    
    love.graphics.setColor(br * 0.3, bg * 0.3, bb * 0.3, ba * 0.5)
    love.graphics.rectangle("fill", self.panelX + 2, self.panelY + 2, self.panelWidth - 4, 50, 10, 10)
end

function TutorialPanel:drawContent()
    local page = self.tutorialSystem:getCurrentPage()
    if not page then return end
    
    local tutorial = self.tutorialSystem.currentTutorial
    if tutorial then
        love.graphics.setColor(self.titleColor[1], self.titleColor[2], self.titleColor[3], self.titleColor[4] * self.alpha)
        love.graphics.setFont(self.titleFont)
        
        local titleX = self.panelX + self.panelWidth / 2
        local titleY = self.panelY + 25
        love.graphics.printf(tutorial.title, titleX - 200, titleY, 400, "center")
    end
    
    if page.title then
        love.graphics.setColor(0.9, 0.9, 1, self.alpha)
        love.graphics.setFont(self.font)
        
        local pageTitleX = self.panelX + 30
        local pageTitleY = self.panelY + 70
        love.graphics.printf(page.title, pageTitleX, pageTitleY, self.panelWidth - 60, "left")
    end
    
    if page.content then
        love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.textColor[4] * self.alpha)
        love.graphics.setFont(self.font)
        
        local contentX = self.panelX + 30
        local contentY = self.panelY + 110
        love.graphics.printf(page.content, contentX, contentY, self.panelWidth - 60, "left")
    end
end

function TutorialPanel:drawButtons()
    local buttonStartX = self.panelX + (self.panelWidth - 320) / 2
    
    if self.tutorialSystem:canSkip() then
        self:drawButton(buttonStartX, self.buttonY, "跳过", "skip")
    end
    
    local prevX = buttonStartX + 110
    local prevEnabled = not self.tutorialSystem:isFirstPage()
    self:drawButton(prevX, self.buttonY, "上一页", "prev", prevEnabled)
    
    local nextX = buttonStartX + 220
    local nextText = self.tutorialSystem:isLastPage() and "完成" or "下一页"
    self:drawButton(nextX, self.buttonY, nextText, self.tutorialSystem:isLastPage() and "complete" or "next")
end

function TutorialPanel:drawButton(x, y, text, id, enabled)
    enabled = enabled ~= false
    
    local isHovered = self.hoveredButton == id
    
    local bgR, bgG, bgB = 0.2, 0.25, 0.35
    if isHovered and enabled then
        bgR, bgG, bgB = 0.3, 0.5, 0.7
    elseif not enabled then
        bgR, bgG, bgB = 0.15, 0.15, 0.18
    end
    
    love.graphics.setColor(bgR, bgG, bgB, self.alpha)
    love.graphics.rectangle("fill", x, y, self.buttonWidth, self.buttonHeight, 6, 6)
    
    love.graphics.setColor(0.4, 0.5, 0.6, self.alpha)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, self.buttonWidth, self.buttonHeight, 6, 6)
    
    local textAlpha = enabled and self.alpha or self.alpha * 0.5
    love.graphics.setColor(1, 1, 1, textAlpha)
    love.graphics.setFont(self.font)
    love.graphics.printf(text, x, y + (self.buttonHeight - 18) / 2, self.buttonWidth, "center")
end

function TutorialPanel:drawProgress()
    local current, total = self.tutorialSystem:getProgress()
    if total == 0 then return end
    
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.6, 0.6, 0.6, self.alpha)
    
    local progressText = string.format("%d / %d", current, total)
    local progressX = self.panelX + self.panelWidth - 60
    local progressY = self.panelY + self.panelHeight - 25
    
    love.graphics.print(progressText, progressX, progressY)
    
    local dotSpacing = 10
    local dotStartX = self.panelX + 30
    local dotY = self.panelY + self.panelHeight - 20
    
    for i = 1, total do
        if i <= current then
            love.graphics.setColor(0.3, 0.7, 0.9, self.alpha)
        else
            love.graphics.setColor(0.3, 0.3, 0.3, self.alpha)
        end
        love.graphics.circle("fill", dotStartX + (i - 1) * dotSpacing, dotY, 4)
    end
end

function TutorialPanel:handleClick(x, y)
    if not self.visible then return false end
    
    local buttonStartX = self.panelX + (self.panelWidth - 320) / 2
    
    if self.tutorialSystem:canSkip() then
        if x >= buttonStartX and x <= buttonStartX + self.buttonWidth and
           y >= self.buttonY and y <= self.buttonY + self.buttonHeight then
            self.tutorialSystem:skipTutorial()
            self:hide()
            return true
        end
    end
    
    local prevX = buttonStartX + 110
    if x >= prevX and x <= prevX + self.buttonWidth and
       y >= self.buttonY and y <= self.buttonY + self.buttonHeight then
        if not self.tutorialSystem:isFirstPage() then
            self.tutorialSystem:prevPage()
        end
        return true
    end
    
    local nextX = buttonStartX + 220
    if x >= nextX and x <= nextX + self.buttonWidth and
       y >= self.buttonY and y <= self.buttonY + self.buttonHeight then
        if self.tutorialSystem:isLastPage() then
            self.tutorialSystem:completeTutorial()
            self:hide()
        else
            self.tutorialSystem:nextPage()
        end
        return true
    end
    
    return false
end

function TutorialPanel:handleKeyPress(key)
    if not self.visible then return false end
    
    if key == "right" or key == "space" or key == "return" then
        if self.tutorialSystem:isLastPage() then
            self.tutorialSystem:completeTutorial()
            self:hide()
        else
            self.tutorialSystem:nextPage()
        end
        return true
    elseif key == "left" then
        if not self.tutorialSystem:isFirstPage() then
            self.tutorialSystem:prevPage()
        end
        return true
    elseif key == "escape" then
        if self.tutorialSystem:canSkip() then
            self.tutorialSystem:skipTutorial()
            self:hide()
        end
        return true
    end
    
    return false
end

return TutorialPanel
