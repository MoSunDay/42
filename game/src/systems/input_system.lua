-- input_system.lua - Input system
-- Handle all user input (mouse, keyboard, etc.)

local InputSystem = {}
InputSystem.__index = InputSystem

function InputSystem.new(gameState)
    local self = setmetatable({}, InputSystem)

    self.gameState = gameState

    return self
end

-- Handle mouse press events
function InputSystem:mousepressed(x, y, button)
    if button == 1 then -- Left click
        -- Convert screen coordinates to world coordinates
        local worldX, worldY = self.gameState.camera:toWorld(x, y)

        -- Command player to move to target position
        self.gameState:movePlayerTo(worldX, worldY)

        print(string.format("Click: Screen(%.0f, %.0f) -> World(%.0f, %.0f)",
            x, y, worldX, worldY))
    end
end

return InputSystem

