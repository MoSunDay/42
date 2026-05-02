local Components = require("src.ui.components")
local Theme = require("src.ui.theme")

local ChatSystem = {}

function ChatSystem.new()
    return {
        messages = {},
        maxMessages = 1000,
        speechBubbles = {},
        maxBubbles = 5,
        inputText = "",
        isInputActive = false,
    }
end

function ChatSystem.addMessage(state, sender, text, color)
    local message = {
        sender = sender,
        text = text,
        color = color or {1, 1, 1},
        timestamp = love.timer.getTime()
    }

    table.insert(state.messages, message)

    while #state.messages > state.maxMessages do
        table.remove(state.messages, 1)
    end

    return message
end

function ChatSystem.addSpeechBubble(state, owner, text, duration, color)
    local bubble = {
        owner = owner,
        text = text,
        duration = duration or 3.0,
        timer = 0,
        color = color or {1, 1, 1},
        alpha = 1.0,
        offsetY = 0
    }

    table.insert(state.speechBubbles, 1, bubble)

    while #state.speechBubbles > state.maxBubbles do
        table.remove(state.speechBubbles)
    end

    ChatSystem.updateBubbleOffsets(state)

    return bubble
end

function ChatSystem.updateBubbleOffsets(state)
    local bubbleHeight = 40
    for i, bubble in ipairs(state.speechBubbles) do
        bubble.offsetY = -(i - 1) * bubbleHeight
    end
end

function ChatSystem.sendMessage(state, sender, text, owner, color)
    ChatSystem.addMessage(state, sender, text, color)

    if owner then
        ChatSystem.addSpeechBubble(state, owner, text, 3.0, color)
    end

    print("[Chat] " .. sender .. ": " .. text)
end

function ChatSystem.update(state, dt)
    for i = #state.speechBubbles, 1, -1 do
        local bubble = state.speechBubbles[i]
        bubble.timer = bubble.timer + dt

        if bubble.timer > bubble.duration - 0.5 then
            bubble.alpha = (bubble.duration - bubble.timer) / 0.5
        end

        if bubble.timer >= bubble.duration then
            table.remove(state.speechBubbles, i)
            ChatSystem.updateBubbleOffsets(state)
        end
    end
end

function ChatSystem.drawSpeechBubbles(state)
    for _, bubble in ipairs(state.speechBubbles) do
        ChatSystem.drawSpeechBubble(bubble)
    end
end

function ChatSystem.drawSpeechBubble(bubble)
    if not bubble.owner then
        return
    end

    local x = bubble.owner.x
    local y = bubble.owner.y - 50 + bubble.offsetY

    local text = bubble.text
    local maxWidth = 200

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

    local padding = 10
    local bubbleWidth = math.min(textWidth + padding * 2, maxWidth + padding * 2)
    local bubbleHeight = textHeight + padding * 2
    local bubbleX = x - bubbleWidth / 2
    local bubbleY = y - bubbleHeight
    local tailX = x
    local tailY = y
    
    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1, bubble.alpha)
    Components.drawOrnatePanel(bubbleX, bubbleY, bubbleWidth, bubbleHeight, nil, {
        corners = true,
        glow = false,
        shimmer = false,
        borderColor = {0.9, 0.9, 0.9, 0.9}
    })
    love.graphics.pop()
    
    love.graphics.setColor(0, 0, 0, 0.8 * bubble.alpha)
    love.graphics.polygon("fill", 
        tailX - 8, bubbleY + bubbleHeight,
        tailX + 8, bubbleY + bubbleHeight,
        tailX, tailY)
    
    love.graphics.setColor(Theme.gold.normal[1], Theme.gold.normal[2], Theme.gold.normal[3], 0.9 * bubble.alpha)
    love.graphics.line(tailX - 8, bubbleY + bubbleHeight, tailX, tailY)
    love.graphics.line(tailX + 8, bubbleY + bubbleHeight, tailX, tailY)
    
    love.graphics.setColor(bubble.color[1], bubble.color[2], bubble.color[3], bubble.alpha)
    love.graphics.printf(text, bubbleX + padding, bubbleY + padding, maxWidth, "left")
    
    love.graphics.setColor(1, 1, 1)
end

function ChatSystem.getRecentMessages(state, count)
    count = count or 10
    local recent = {}
    for i = 1, math.min(count, #state.messages) do
        table.insert(recent, state.messages[i])
    end
    return recent
end

function ChatSystem.getMessages(state)
    return state.messages
end

function ChatSystem.clear(state)
    state.messages = {}
    state.speechBubbles = {}
end

function ChatSystem.startInput(state)
    state.isInputActive = true
    state.inputText = ""
end

function ChatSystem.endInput(state)
    state.isInputActive = false
    local text = state.inputText
    state.inputText = ""
    return text
end

function ChatSystem.isInputting(state)
    return state.isInputActive
end

function ChatSystem.addInputChar(state, char)
    if state.isInputActive then
        state.inputText = state.inputText .. char
    end
end

function ChatSystem.removeInputChar(state)
    if state.isInputActive and #state.inputText > 0 then
        state.inputText = state.inputText:sub(1, -2)
    end
end

function ChatSystem.getInputText(state)
    return state.inputText
end

return ChatSystem
