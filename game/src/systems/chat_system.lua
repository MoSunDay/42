-- chat_system.lua - Chat system
-- Manage chat messages and speech bubbles

local ChatSystem = {}
ChatSystem.__index = ChatSystem

function ChatSystem.new()
    local self = setmetatable({}, ChatSystem)
    
    -- Chat messages (history)
    self.messages = {}
    self.maxMessages = 50
    
    -- Speech bubbles (temporary messages above characters)
    self.speechBubbles = {}
    
    -- Current input
    self.inputText = ""
    self.isInputActive = false
    
    return self
end

-- Add a chat message
function ChatSystem:addMessage(sender, text, color)
    local message = {
        sender = sender,
        text = text,
        color = color or {1, 1, 1},
        timestamp = love.timer.getTime()
    }
    
    table.insert(self.messages, 1, message)
    
    -- Keep only max messages
    while #self.messages > self.maxMessages do
        table.remove(self.messages)
    end
    
    return message
end

-- Add a speech bubble above a character
function ChatSystem:addSpeechBubble(x, y, text, duration, color)
    local bubble = {
        x = x,
        y = y,
        text = text,
        duration = duration or 3.0,
        timer = 0,
        color = color or {1, 1, 1},
        alpha = 1.0
    }
    
    table.insert(self.speechBubbles, bubble)
    return bubble
end

-- Send a message (adds to chat and creates speech bubble)
function ChatSystem:sendMessage(sender, text, senderX, senderY, color)
    -- Add to chat history
    self:addMessage(sender, text, color)
    
    -- Create speech bubble above sender
    if senderX and senderY then
        self:addSpeechBubble(senderX, senderY - 50, text, 3.0, color)
    end
    
    print("[Chat] " .. sender .. ": " .. text)
end

-- Update chat system (for speech bubbles)
function ChatSystem:update(dt)
    -- Update speech bubbles
    for i = #self.speechBubbles, 1, -1 do
        local bubble = self.speechBubbles[i]
        bubble.timer = bubble.timer + dt
        
        -- Fade out in last 0.5 seconds
        if bubble.timer > bubble.duration - 0.5 then
            bubble.alpha = (bubble.duration - bubble.timer) / 0.5
        end
        
        -- Remove expired bubbles
        if bubble.timer >= bubble.duration then
            table.remove(self.speechBubbles, i)
        end
    end
end

-- Draw speech bubbles (in world space)
function ChatSystem:drawSpeechBubbles()
    for _, bubble in ipairs(self.speechBubbles) do
        self:drawSpeechBubble(bubble)
    end
end

-- Draw a single speech bubble
function ChatSystem:drawSpeechBubble(bubble)
    local text = bubble.text
    local maxWidth = 200
    
    -- Calculate text dimensions
    local font = love.graphics.getFont()
    local _, wrappedText = font:getWrap(text, maxWidth)
    local textHeight = #wrappedText * font:getHeight()
    local textWidth = 0
    for _, line in ipairs(wrappedText) do
        local lineWidth = font:getWidth(line)
        if lineWidth > textWidth then
            textWidth = lineWidth
        end
    end
    
    -- Bubble dimensions
    local padding = 10
    local bubbleWidth = math.min(textWidth + padding * 2, maxWidth + padding * 2)
    local bubbleHeight = textHeight + padding * 2
    local bubbleX = bubble.x - bubbleWidth / 2
    local bubbleY = bubble.y - bubbleHeight
    
    -- Draw bubble background
    love.graphics.setColor(0, 0, 0, 0.8 * bubble.alpha)
    love.graphics.rectangle("fill", bubbleX, bubbleY, bubbleWidth, bubbleHeight, 8, 8)
    
    -- Draw bubble border
    love.graphics.setColor(1, 1, 1, 0.9 * bubble.alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", bubbleX, bubbleY, bubbleWidth, bubbleHeight, 8, 8)
    love.graphics.setLineWidth(1)
    
    -- Draw tail (small triangle pointing down)
    local tailX = bubble.x
    local tailY = bubble.y
    love.graphics.setColor(0, 0, 0, 0.8 * bubble.alpha)
    love.graphics.polygon("fill", 
        tailX - 8, bubbleY + bubbleHeight,
        tailX + 8, bubbleY + bubbleHeight,
        tailX, tailY)
    
    love.graphics.setColor(1, 1, 1, 0.9 * bubble.alpha)
    love.graphics.line(tailX - 8, bubbleY + bubbleHeight, tailX, tailY)
    love.graphics.line(tailX + 8, bubbleY + bubbleHeight, tailX, tailY)
    
    -- Draw text
    love.graphics.setColor(bubble.color[1], bubble.color[2], bubble.color[3], bubble.alpha)
    love.graphics.printf(text, bubbleX + padding, bubbleY + padding, maxWidth, "left")
    
    love.graphics.setColor(1, 1, 1)
end

-- Get recent messages
function ChatSystem:getRecentMessages(count)
    count = count or 10
    local recent = {}
    for i = 1, math.min(count, #self.messages) do
        table.insert(recent, self.messages[i])
    end
    return recent
end

-- Clear all messages
function ChatSystem:clear()
    self.messages = {}
    self.speechBubbles = {}
end

-- Input handling
function ChatSystem:startInput()
    self.isInputActive = true
    self.inputText = ""
end

function ChatSystem:endInput()
    self.isInputActive = false
    local text = self.inputText
    self.inputText = ""
    return text
end

function ChatSystem:isInputting()
    return self.isInputActive
end

function ChatSystem:addInputChar(char)
    if self.isInputActive then
        self.inputText = self.inputText .. char
    end
end

function ChatSystem:removeInputChar()
    if self.isInputActive and #self.inputText > 0 then
        self.inputText = self.inputText:sub(1, -2)
    end
end

function ChatSystem:getInputText()
    return self.inputText
end

return ChatSystem

