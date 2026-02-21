-- teleporter.lua - Dimensional Guide NPC for map teleportation
-- 传送NPC - 维度向导

local Teleporter = {}
Teleporter.__index = Teleporter

local MapRegistry = require("map.map_registry")

local DIALOGUES = {
    greeting = {
        "Greetings, traveler! I am the Dimensional Guide.",
        "I can open portals to distant lands. Where shall I send you?",
        "The threads of fate connect all places. Choose your destination."
    },
    farewell = {
        "Safe travels, adventurer!",
        "May the winds guide you to glory!",
        "Until we meet again, brave one."
    },
    sameMap = {
        "You're already here! Choose another destination.",
        "This is your current location. Try somewhere else.",
        "Why leave when you've just arrived?"
    },
    locked = {
        "That realm is not yet accessible to you.",
        "Your journey must continue before you can go there.",
        "The path remains hidden for now."
    }
}

function Teleporter.new(x, y)
    local self = setmetatable({}, Teleporter)
    
    self.id = "dimensional_guide"
    self.type = "teleporter"
    self.name = "Dimensional Guide"
    self.x = x
    self.y = y
    self.color = {0.7, 0.5, 0.9}
    self.size = 22
    self.canTalk = true
    
    self.dialogueIndex = 0
    self.currentDialogue = DIALOGUES.greeting[1]
    
    return self
end

function Teleporter:getDialogue()
    local dialogues = DIALOGUES.greeting
    self.dialogueIndex = (self.dialogueIndex % #dialogues) + 1
    self.currentDialogue = dialogues[self.dialogueIndex]
    return self.currentDialogue
end

function Teleporter:getDestinations(currentMapId, playerLevel)
    local allMaps = MapRegistry.getAll()
    local destinations = {}
    
    for i, map in ipairs(allMaps) do
        if map.id ~= currentMapId then
            local accessible = playerLevel >= map.level.min - 5
            table.insert(destinations, {
                id = map.id,
                name = map.name,
                level = map.level,
                description = map.description,
                accessible = accessible,
                index = i
            })
        end
    end
    
    return destinations
end

function Teleporter:canTeleportTo(destMapId, playerLevel)
    local map = MapRegistry.getById(destMapId)
    if not map then
        return false, "Unknown destination"
    end
    
    if playerLevel < map.level.min - 5 then
        return false, DIALOGUES.locked[math.random(#DIALOGUES.locked)]
    end
    
    return true
end

function Teleporter:getTeleportMessage(destMapId)
    local map = MapRegistry.getById(destMapId)
    if map then
        return string.format("Opening portal to %s...", map.name)
    end
    return "Opening portal..."
end

function Teleporter.getFarewell()
    return DIALOGUES.farewell[math.random(#DIALOGUES.farewell)]
end

function Teleporter.formatMapList(destinations, currentIndex)
    local lines = {}
    table.insert(lines, "=== Available Destinations ===")
    table.insert(lines, "")
    
    for _, dest in ipairs(destinations) do
        local levelText = string.format("Lv.%d-%d", dest.level.min, dest.level.max)
        local status = dest.accessible and "[OPEN]" or "[LOCKED]"
        local marker = (dest.index == currentIndex) and ">>>" or "   "
        
        table.insert(lines, string.format("%s %d. %-25s %s %s", 
            marker, dest.index, dest.name, levelText, status))
    end
    
    table.insert(lines, "")
    table.insert(lines, "Enter number to teleport, or 'q' to quit")
    
    return table.concat(lines, "\n")
end

function Teleporter.draw(self, cameraX, cameraY)
    local screenX = self.x - cameraX
    local screenY = self.y - cameraY
    
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", screenX, screenY + self.size + 5, 
                          self.size * 0.8, self.size * 0.3)
    
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.3)
    for i = 1, 3 do
        local pulseSize = self.size + 8 + math.sin(love.timer.getTime() * 3 + i) * 5
        love.graphics.circle("line", screenX, screenY, pulseSize)
    end
    
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", screenX, screenY, self.size)
    
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("fill", screenX - self.size * 0.3, screenY - self.size * 0.2, 3)
    love.graphics.circle("fill", screenX + self.size * 0.3, screenY - self.size * 0.2, 3)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.name, screenX - 60, screenY - self.size - 15, 120, "center")
    
    love.graphics.setColor(0.8, 0.6, 1.0, 0.8)
    love.graphics.printf("[Teleporter]", screenX - 60, screenY + self.size + 10, 120, "center")
end

return Teleporter
