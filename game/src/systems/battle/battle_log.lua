-- battle_log.lua - Battle log management
-- Manages battle messages and history

local BattleLog = {}
BattleLog.__index = BattleLog

function BattleLog.new()
    local self = setmetatable({}, BattleLog)
    
    self.messages = {}
    self.maxMessages = 5
    
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
end

return BattleLog

