-- chat_system.lua - Chat system
-- Manage chat messages and speech bubbles

local ChatSystem = {}
ChatSystem.__index = ChatSystem

function ChatSystem.new()
    local self = setmetatable({}, ChatSystem)
    
    -- Chat messages (history)
    self.messages = {}
    self.maxMessages = 1000  -- Save last 1000 messages
    
    -- Speech bubbles (temporary messages above characters)
    self.speechBubbles = {}
    self.maxBubbles = 5  -- Maximum 5 bubbles at once
    
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
-- owner: reference to the entity (player/NPC) to follow
function ChatSystem:addSpeechBubble(owner, text, duration, color)
    local bubble = {
        owner = owner,  -- Reference to entity to follow
        text = text,
        duration = duration or 3.0,
        timer = 0,
        color = color or {1, 1, 1},
        alpha = 1.0,
        offsetY = 0  -- Vertical offset for stacking
    }

    -- Insert at the beginning (newest on top)
    table.insert(self.speechBubbles, 1, bubble)

    -- Keep only max bubbles
    while #self.speechBubbles > self.maxBubbles do
        table.remove(self.speechBubbles)
    end

    -- Update offsets for stacking (newest bubbles push older ones up)
    self:updateBubbleOffsets()

    return bubble
end

-- Update bubble offsets for stacking
function ChatSystem:updateBubbleOffsets()
    local bubbleHeight = 40  -- Height of each bubble
    for i, bubble in ipairs(self.speechBubbles) do
        -- Newer bubbles (lower index) are at the bottom
        -- Older bubbles (higher index) are pushed up
        bubble.offsetY = -(i - 1) * bubbleHeight
    end
end

-- Send a message (adds to chat and creates speech bubble)
-- owner: reference to the entity (player/NPC) to follow
function ChatSystem:sendMessage(sender, text, owner, color)
    -- Add to chat history
    self:addMessage(sender, text, color)

    -- Create speech bubble above sender (follows the owner entity)
    if owner then
        self:addSpeechBubble(owner, text, 3.0, color)
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
            -- Update offsets after removing a bubble
            self:updateBubbleOffsets()
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
    -- Get position from owner entity (follows the entity)
    if not bubble.owner then
        return
    end

    local x = bubble.owner.x
    local y = bubble.owner.y - 50 + bubble.offsetY  -- Above head + stacking offset

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
    local bubbleX = x - bubbleWidth / 2
    local bubbleY = y - bubbleHeight
    
    -- Draw bubble background
    love.graphics.setColor(0, 0, 0, 0.8 * bubble.alpha)
    love.graphics.rectangle("fill", bubbleX, bubbleY, bubbleWidth, bubbleHeight, 8, 8)
    
    -- Draw bubble border
    love.graphics.setColor(1, 1, 1, 0.9 * bubble.alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", bubbleX, bubbleY, bubbleWidth, bubbleHeight, 8, 8)
    love.graphics.setLineWidth(1)
    
    -- Draw tail (small triangle pointing down)
    local tailX = x
    local tailY = y
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

-- Get all messages
function ChatSystem:getMessages()
    return self.messages
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

