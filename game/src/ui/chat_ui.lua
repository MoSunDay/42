local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local ChatUI = {}

function ChatUI.create(assetManager)
    local state = {}
    
    state.assetManager = assetManager
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    state.x = 10
    state.y = screenHeight - 210
    state.width = 400
    state.height = 200
    state.chatHeight = 150
    state.inputHeight = 40
    state.inputY = state.y + state.chatHeight + 5
    state.colors = Theme.colors.chat
    state.font = assetManager:get_font("default")
    state.isVisible = true
    state.scrollOffset = 0
    state.manuallyScrolled = false

    return state
end

function ChatUI.toggle(state)
    state.isVisible = not state.isVisible
end

function ChatUI.set_visible(state, visible)
    state.isVisible = visible
end

function ChatUI.draw(state, chatSystem)
    if not state.isVisible then return end
    ChatUI.draw_chat_area(state, chatSystem)
    ChatUI.draw_input_area(state, chatSystem)
end

function ChatUI.draw_chat_area(state, chatSystem)
    Components.drawOrnatePanel(state.x, state.y, state.width, state.chatHeight, state.assetManager, {
        title = "Chat",
        corners = true,
        glow = true,
        shimmer = false,
        font = state.font
    })

    love.graphics.setFont(state.font)
    
    local allMessages = chatSystem:get_messages()
    local lineHeight = 16
    local contentHeight = #allMessages * lineHeight
    local viewHeight = state.chatHeight - 35

    local maxScroll = math.max(0, contentHeight - viewHeight)

    if not state.manuallyScrolled then
        state.scrollOffset = maxScroll
    end

    state.scrollOffset = math.max(0, math.min(state.scrollOffset, maxScroll))

    love.graphics.setScissor(state.x + 5, state.y + 28, state.width - 15, viewHeight)

    local startY = state.y + 28
    local messageY = startY - state.scrollOffset

    for i = 1, #allMessages do
        local msg = allMessages[i]

        if messageY >= state.y + 28 - lineHeight and messageY <= state.y + 28 + viewHeight then
            love.graphics.setColor(Theme.gold.bright)
            local senderText = msg.sender .. ": "
            local senderWidth = state.font:getWidth(senderText)
            love.graphics.print(senderText, state.x + 10, messageY)

            love.graphics.setColor(msg.color or Theme.colors.text)
            love.graphics.print(msg.text, state.x + 10 + senderWidth, messageY)
        end

        messageY = messageY + lineHeight
    end

    love.graphics.setScissor()

    if contentHeight > viewHeight then
        Components.drawScrollbar(state.x + state.width - 12, state.y + 28, 5, viewHeight, contentHeight, state.scrollOffset)
    end

    love.graphics.setColor(1, 1, 1)
end

function ChatUI.draw_input_area(state, chatSystem)
    local is_active = chatSystem:isInputting()
    
    Components.drawInput(state.x, state.inputY, state.width, state.inputHeight, is_active, state.assetManager)
    
    if is_active then
        Theme.draw_gold_border(state.x, state.inputY, state.width, state.inputHeight, 1)
    end

    love.graphics.setFont(state.font)
    love.graphics.setColor(state.colors.text)
    
    local displayText = chatSystem:getInputText()
    if is_active then
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            displayText = displayText .. "|"
        end
    else
        if displayText == "" then
            love.graphics.setColor(state.colors.textHint)
            displayText = "Press ENTER to chat..."
        end
    end
    
    love.graphics.print(displayText, state.x + 10, state.inputY + 12)
end

function ChatUI.is_mouse_over(state, x, y)
    if not state.isVisible then return false end
    return x >= state.x and x <= state.x + state.width and
           y >= state.y and y <= state.inputY + state.inputHeight
end

function ChatUI.mousescroll(state, x, y)
    if ChatUI.is_mouse_over(state, love.mouse.getX(), love.mouse.getY()) then
        state.scrollOffset = state.scrollOffset + y * 20
        state.scrollOffset = math.max(0, state.scrollOffset)
    end
end

function ChatUI.mousepressed(state, x, y, button, chatSystem)
    if button ~= 1 then return false end

    local inputX = state.x + 5
    local inputY = state.inputY
    local inputW = state.width - 10
    local inputH = state.inputHeight

    if x >= inputX and x <= inputX + inputW and
       y >= inputY and y <= inputY + inputH then
        if chatSystem and not chatSystem:isInputting() then
            chatSystem:startInput()
            return true
        end
    end

    return false
end

return ChatUI
