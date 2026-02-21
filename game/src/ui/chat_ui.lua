-- chat_ui.lua - Chat UI display
-- Display chat box in bottom-left corner

local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local ChatUI = {}
ChatUI.__index = ChatUI

function ChatUI.new(assetManager)
    local self = setmetatable({}, ChatUI)
    
    self.assetManager = assetManager
    
    -- Screen dimensions
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- UI position (bottom-left corner)
    self.x = 10
    self.y = screenHeight - 210
    self.width = 400
    self.height = 200
    
    -- Chat display area
    self.chatHeight = 150
    
    -- Input area
    self.inputHeight = 40
    self.inputY = self.y + self.chatHeight + 5
    
    -- Colors
    self.colors = Theme.colors.chat
    
    -- Fonts
    self.font = assetManager:getFont("default")
    
    -- Visibility
    self.isVisible = true

    -- Scroll offset
    self.scrollOffset = 0
    self.manuallyScrolled = false  -- Auto-scroll to bottom by default

    return self
end

-- Toggle visibility
function ChatUI:toggle()
    self.isVisible = not self.isVisible
end

-- Set visibility
function ChatUI:setVisible(visible)
    self.isVisible = visible
end

-- Draw chat UI
function ChatUI:draw(chatSystem)
    if not self.isVisible then
        return
    end
    
    -- Draw chat message area
    self:drawChatArea(chatSystem)
    
    -- Draw input area
    self:drawInputArea(chatSystem)
end

-- Draw chat message area
function ChatUI:drawChatArea(chatSystem)
    Components.drawPanelSimple(self.x, self.y, self.width, self.chatHeight, 5)

    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.text)
    love.graphics.print("Chat", self.x + 10, self.y + 5)

    local allMessages = chatSystem:getMessages()
    local lineHeight = 16
    local contentHeight = #allMessages * lineHeight
    local viewHeight = self.chatHeight - 30

    local maxScroll = math.max(0, contentHeight - viewHeight)

    if not self.manuallyScrolled then
        self.scrollOffset = maxScroll
    end

    -- Clamp scroll offset
    self.scrollOffset = math.max(0, math.min(self.scrollOffset, maxScroll))

    -- Enable scissor to clip messages
    love.graphics.setScissor(self.x + 5, self.y + 25, self.width - 15, viewHeight)

    -- Draw messages from top to bottom (oldest to newest)
    -- Start from the top of the view area
    local startY = self.y + 25
    local messageY = startY - self.scrollOffset

    for i = 1, #allMessages do
        local msg = allMessages[i]

        -- Only draw if in visible area
        if messageY >= self.y + 25 - lineHeight and messageY <= self.y + 25 + viewHeight then
            -- Draw sender name
            love.graphics.setColor(self.colors.sender)
            local senderText = msg.sender .. ": "
            local senderWidth = self.font:getWidth(senderText)
            love.graphics.print(senderText, self.x + 10, messageY)

            -- Draw message text
            love.graphics.setColor(msg.color or {1, 1, 1})
            love.graphics.print(msg.text, self.x + 10 + senderWidth, messageY)
        end

        messageY = messageY + lineHeight
    end

    -- Disable scissor
    love.graphics.setScissor()

    -- Draw scrollbar if needed
    if contentHeight > viewHeight then
        self:drawScrollbar(contentHeight, viewHeight)
    end

    love.graphics.setColor(1, 1, 1)
end

-- Draw scrollbar
function ChatUI:drawScrollbar(contentHeight, viewHeight)
    local scrollbarX = self.x + self.width - 10
    local scrollbarY = self.y + 25
    local scrollbarHeight = viewHeight
    local scrollbarWidth = 5

    love.graphics.setColor(self.colors.scrollbarBg)
    love.graphics.rectangle("fill", scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight)

    local thumbHeight = math.max(20, (viewHeight / contentHeight) * scrollbarHeight)
    local thumbY = scrollbarY + (self.scrollOffset / (contentHeight - viewHeight)) * (scrollbarHeight - thumbHeight)

    love.graphics.setColor(self.colors.scrollbarThumb)
    love.graphics.rectangle("fill", scrollbarX, thumbY, scrollbarWidth, thumbHeight, 2, 2)
end

function ChatUI:drawInputArea(chatSystem)
    local isActive = chatSystem:isInputting()
    
    Components.drawInput(self.x, self.inputY, self.width, self.inputHeight, isActive, self.assetManager)
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.text)
    
    local displayText = chatSystem:getInputText()
    if isActive then
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            displayText = displayText .. "|"
        end
    else
        if displayText == "" then
            love.graphics.setColor(self.colors.textHint)
            displayText = "Press ENTER to chat..."
        end
    end
    
    love.graphics.print(displayText, self.x + 10, self.inputY + 12)
end

function ChatUI:isMouseOver(x, y)
    if not self.isVisible then
        return false
    end
    
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.inputY + self.inputHeight
end

-- Handle mouse scroll
function ChatUI:mousescroll(x, y)
    if self:isMouseOver(love.mouse.getX(), love.mouse.getY()) then
        self.scrollOffset = self.scrollOffset + y * 20
        self.scrollOffset = math.max(0, self.scrollOffset)
    end
end

-- Handle mouse press
function ChatUI:mousepressed(x, y, button, chatSystem)
    if button ~= 1 then
        return false
    end

    -- Check if clicked on input area
    local inputX = self.x + 5
    local inputY = self.inputY
    local inputW = self.width - 10
    local inputH = self.inputHeight

    if x >= inputX and x <= inputX + inputW and
       y >= inputY and y <= inputY + inputH then
        -- Clicked on input box, start input
        if chatSystem and not chatSystem:isInputting() then
            chatSystem:startInput()
            return true
        end
    end

    return false
end

return ChatUI

