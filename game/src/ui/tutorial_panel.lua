local TutorialPanel = {}

local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

function TutorialPanel.create(tutorialSystem, assetManager)
    local state = {}
    
    state.tutorialSystem = tutorialSystem
    state.assetManager = assetManager
    state.visible = false
    state.alpha = 0
    
    state.panelWidth = 500
    state.panelHeight = 350
    state.panelX = 0
    state.panelY = 0
    
    state.buttonWidth = 100
    state.buttonHeight = 36
    state.buttonY = 0
    
    state.textColor = {1, 1, 1, 1}
    state.titleColor = {1, 0.85, 0.2, 1}
    state.bgColor = {0.1, 0.1, 0.15, 0.95}
    state.borderColor = {0.4, 0.6, 0.9, 1}
    
    state.font = nil
    state.titleFont = nil
    state.smallFont = nil
    
    state.hoveredButton = nil
    
    return state
end

function TutorialPanel.init(state)
    state.font = love.graphics.newFont(18)
    state.titleFont = love.graphics.newFont(24)
    state.smallFont = love.graphics.newFont(14)
    
    TutorialPanel.updatePosition(state)
end

function TutorialPanel.updatePosition(state)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    state.panelX = (screenWidth - state.panelWidth) / 2
    state.panelY = (screenHeight - state.panelHeight) / 2
    
    state.buttonY = state.panelY + state.panelHeight - 50
end

function TutorialPanel.show(state)
    state.visible = true
    state.alpha = 0
end

function TutorialPanel.hide(state)
    state.visible = false
    state.alpha = 0
end

function TutorialPanel.isVisible(state)
    return state.visible
end

function TutorialPanel.update(state, dt)
    if not state.visible then return end
    
    if state.alpha < 1 then
        state.alpha = math.min(1, state.alpha + dt * 4)
    end
    
    TutorialPanel.updatePosition(state)
    
    local mx, my = love.mouse.getPosition()
    state.hoveredButton = nil
    
    local buttonStartX = state.panelX + (state.panelWidth - 320) / 2
    
    if state.tutorialSystem:canSkip() then
        if mx >= buttonStartX and mx <= buttonStartX + state.buttonWidth and
           my >= state.buttonY and my <= state.buttonY + state.buttonHeight then
            state.hoveredButton = "skip"
        end
    end
    
    local prevX = buttonStartX + 110
    if mx >= prevX and mx <= prevX + state.buttonWidth and
       my >= state.buttonY and my <= state.buttonY + state.buttonHeight then
        if not state.hoveredButton then
            state.hoveredButton = "prev"
        end
    end
    
    local nextX = buttonStartX + 220
    if mx >= nextX and mx <= nextX + state.buttonWidth and
       my >= state.buttonY and my <= state.buttonY + state.buttonHeight then
        if not state.hoveredButton then
            state.hoveredButton = state.tutorialSystem:isLastPage() and "complete" or "next"
        end
    end
end

function TutorialPanel.draw(state)
    if not state.visible then return end
    
    love.graphics.push("all")
    
    TutorialPanel.drawBackground(state)
    TutorialPanel.drawPanel(state)
    TutorialPanel.drawContent(state)
    TutorialPanel.drawButtons(state)
    TutorialPanel.drawProgress(state)
    
    love.graphics.pop()
end

function TutorialPanel.drawBackground(state)
    love.graphics.setColor(0, 0, 0, 0.5 * state.alpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

function TutorialPanel.drawPanel(state)
    love.graphics.setColor(1, 1, 1, state.alpha)

    local tutorial = state.tutorialSystem.currentTutorial
    local titleText = tutorial and tutorial.title or nil

    Components.drawOrnatePanel(
        state.panelX, state.panelY,
        state.panelWidth, state.panelHeight,
        state.assetManager,
        { title = titleText, corners = true, glow = true, shimmer = false, font = state.titleFont }
    )

    love.graphics.setColor(1, 1, 1, 1)
end

function TutorialPanel.drawContent(state)
    local page = state.tutorialSystem:getCurrentPage()
    if not page then return end

    if page.title then
        love.graphics.setColor(0.9, 0.9, 1, state.alpha)
        love.graphics.setFont(state.font)
        
        local pageTitleX = state.panelX + 30
        local pageTitleY = state.panelY + 70
        love.graphics.printf(page.title, pageTitleX, pageTitleY, state.panelWidth - 60, "left")
    end
    
    if page.content then
        love.graphics.setColor(state.textColor[1], state.textColor[2], state.textColor[3], state.textColor[4] * state.alpha)
        love.graphics.setFont(state.font)
        
        local contentX = state.panelX + 30
        local contentY = state.panelY + 110
        love.graphics.printf(page.content, contentX, contentY, state.panelWidth - 60, "left")
    end
end

function TutorialPanel.drawButtons(state)
    local buttonStartX = state.panelX + (state.panelWidth - 320) / 2
    
    if state.tutorialSystem:canSkip() then
        TutorialPanel.drawButton(state, buttonStartX, state.buttonY, "跳过", "skip")
    end
    
    local prevX = buttonStartX + 110
    local prevEnabled = not state.tutorialSystem:isFirstPage()
    TutorialPanel.drawButton(state, prevX, state.buttonY, "上一页", "prev", prevEnabled)
    
    local nextX = buttonStartX + 220
    local nextText = state.tutorialSystem:isLastPage() and "完成" or "下一页"
    TutorialPanel.drawButton(state, nextX, state.buttonY, nextText, state.tutorialSystem:isLastPage() and "complete" or "next")
end

function TutorialPanel.drawButton(state, x, y, text, id, enabled)
    enabled = enabled ~= false

    local btnState = "normal"
    if not enabled then
        btnState = "disabled"
    elseif state.hoveredButton == id then
        btnState = "hover"
    end

    Components.drawOrnateButton(
        x, y,
        state.buttonWidth, state.buttonHeight,
        text, btnState,
        state.assetManager, state.font
    )
end

function TutorialPanel.drawProgress(state)
    local current, total = state.tutorialSystem:getProgress()
    if total == 0 then return end
    
    love.graphics.setFont(state.smallFont)
    love.graphics.setColor(0.6, 0.6, 0.6, state.alpha)
    
    local progressText = string.format("%d / %d", current, total)
    local progressX = state.panelX + state.panelWidth - 60
    local progressY = state.panelY + state.panelHeight - 25
    
    love.graphics.print(progressText, progressX, progressY)
    
    local dotSpacing = 10
    local dotStartX = state.panelX + 30
    local dotY = state.panelY + state.panelHeight - 20
    
    for i = 1, total do
        if i <= current then
            love.graphics.setColor(0.3, 0.7, 0.9, state.alpha)
        else
            love.graphics.setColor(0.3, 0.3, 0.3, state.alpha)
        end
        love.graphics.circle("fill", dotStartX + (i - 1) * dotSpacing, dotY, 4)
    end
end

function TutorialPanel.handleClick(state, x, y)
    if not state.visible then return false end
    
    local buttonStartX = state.panelX + (state.panelWidth - 320) / 2
    
    if state.tutorialSystem:canSkip() then
        if x >= buttonStartX and x <= buttonStartX + state.buttonWidth and
           y >= state.buttonY and y <= state.buttonY + state.buttonHeight then
            state.tutorialSystem:skipTutorial()
            TutorialPanel.hide(state)
            return true
        end
    end
    
    local prevX = buttonStartX + 110
    if x >= prevX and x <= prevX + state.buttonWidth and
       y >= state.buttonY and y <= state.buttonY + state.buttonHeight then
        if not state.tutorialSystem:isFirstPage() then
            state.tutorialSystem:prevPage()
        end
        return true
    end
    
    local nextX = buttonStartX + 220
    if x >= nextX and x <= nextX + state.buttonWidth and
       y >= state.buttonY and y <= state.buttonY + state.buttonHeight then
        if state.tutorialSystem:isLastPage() then
            state.tutorialSystem:completeTutorial()
            TutorialPanel.hide(state)
        else
            state.tutorialSystem:nextPage()
        end
        return true
    end
    
    return false
end

function TutorialPanel.handleKeyPress(state, key)
    if not state.visible then return false end
    
    if key == "right" or key == "space" or key == "return" then
        if state.tutorialSystem:isLastPage() then
            state.tutorialSystem:completeTutorial()
            TutorialPanel.hide(state)
        else
            state.tutorialSystem:nextPage()
        end
        return true
    elseif key == "left" then
        if not state.tutorialSystem:isFirstPage() then
            state.tutorialSystem:prevPage()
        end
        return true
    elseif key == "escape" then
        if state.tutorialSystem:canSkip() then
            state.tutorialSystem:skipTutorial()
            TutorialPanel.hide(state)
        end
        return true
    end
    
    return false
end

return TutorialPanel
