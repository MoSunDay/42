-- teleporter.lua - Dimensional Guide NPC for map teleportation
-- 传送NPC - 维度向导

local Teleporter = {}

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

function Teleporter.create(x, y)
    local state = {}

    state.id = "dimensional_guide"
    state.type = "teleporter"
    state.name = "Dimensional Guide"
    state.x = x
    state.y = y
    state.color = {0.7, 0.5, 0.9}
    state.size = 22
    state.canTalk = true

    state.dialogueIndex = 0
    state.currentDialogue = DIALOGUES.greeting[1]

    return state
end

function Teleporter.getDialogue(state)
    local dialogues = DIALOGUES.greeting
    state.dialogueIndex = (state.dialogueIndex % #dialogues) + 1
    state.currentDialogue = dialogues[state.dialogueIndex]
    return state.currentDialogue
end

function Teleporter.getDestinations(state, currentMapId, playerLevel)
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

function Teleporter.canTeleportTo(state, destMapId, playerLevel)
    local map = MapRegistry.getById(destMapId)
    if not map then
        return false, "Unknown destination"
    end

    if playerLevel < map.level.min - 5 then
        return false, DIALOGUES.locked[math.random(#DIALOGUES.locked)]
    end

    return true
end

function Teleporter.getTeleportMessage(state, destMapId)
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

function Teleporter.draw(state, cameraX, cameraY)
    local screenX = state.x - cameraX
    local screenY = state.y - cameraY

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", screenX, screenY + state.size + 5,
                          state.size * 0.8, state.size * 0.3)

    love.graphics.setColor(state.color[1], state.color[2], state.color[3], 0.3)
    for i = 1, 3 do
        local pulseSize = state.size + 8 + math.sin(love.timer.getTime() * 3 + i) * 5
        love.graphics.circle("line", screenX, screenY, pulseSize)
    end

    love.graphics.setColor(state.color)
    love.graphics.circle("fill", screenX, screenY, state.size)

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.circle("fill", screenX - state.size * 0.3, screenY - state.size * 0.2, 3)
    love.graphics.circle("fill", screenX + state.size * 0.3, screenY - state.size * 0.2, 3)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(state.name, screenX - 60, screenY - state.size - 15, 120, "center")

    love.graphics.setColor(0.8, 0.6, 1.0, 0.8)
    love.graphics.printf("[Teleporter]", screenX - 60, screenY + state.size + 10, 120, "center")
end

return Teleporter
