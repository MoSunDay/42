-- battle_log.lua - Battle log management
-- Manages battle messages and history

local BattleLog = {}
BattleLog.__index = BattleLog

function BattleLog.new()
    local self = setmetatable({}, BattleLog)

    self.messages = {}
    self.maxMessages = 1000  -- Save last 1000 messages
    self.scrollOffset = 0  -- Scroll position

    return self
end

-- Add a message to the log
function BattleLog:add(message)
    table.insert(self.messages, 1, message)
    
    -- Keep only the most recent messages
    while #self.messages > self.maxMessages do
        table.remove(self.messages)
    end
end

-- Get all messages
function BattleLog:getMessages()
    return self.messages
end

-- Clear the log
function BattleLog:clear()
    self.messages = {}
    self.scrollOffset = 0
end

-- Get scroll offset
function BattleLog:getScrollOffset()
    return self.scrollOffset
end

-- Set scroll offset
function BattleLog:setScrollOffset(offset)
    self.scrollOffset = offset
end

-- Scroll by delta
function BattleLog:scroll(delta)
    self.scrollOffset = self.scrollOffset + delta
end

return BattleLog

