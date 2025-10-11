-- input_system.lua - Input system
-- Handle all user input (mouse, keyboard, etc.)

local InputSystem = {}
InputSystem.__index = InputSystem

function InputSystem.new(gameState, battleUI)
    local self = setmetatable({}, InputSystem)

    self.gameState = gameState
    self.battleUI = battleUI

    return self
end

-- Handle mouse press events
function InputSystem:mousepressed(x, y, button)
    local mode = self.gameState:getMode()

    if mode == "exploration" then
        if button == 1 then -- Left click
            -- Convert screen coordinates to world coordinates
            local worldX, worldY = self.gameState.camera:toWorld(x, y)

            -- Command player to move to target position
            self.gameState:movePlayerTo(worldX, worldY)

            print(string.format("Click: Screen(%.0f, %.0f) -> World(%.0f, %.0f)",
                x, y, worldX, worldY))
        end
    elseif mode == "battle" then
        if button == 1 then -- Left click in battle
            local battleSystem = self.gameState:getBattleSystem()
            local state = battleSystem:getState()

            if state == "player" then
                -- Check if clicked on an enemy
                local enemies = battleSystem:getEnemies()
                local w, h = love.graphics.getDimensions()

                for i, enemy in ipairs(enemies) do
                    if enemy:isAlive() then
                        -- Diagonal positioning: left-bottom to right-top
                        local baseX = w * 0.2
                        local baseY = h * 0.6
                        local enemyX = baseX + (i - 1) * 100
                        local enemyY = baseY - (i - 1) * 80
                        local radius = 25

                        local dx = x - enemyX
                        local dy = y - enemyY
                        local distance = math.sqrt(dx * dx + dy * dy)

                        if distance <= radius then
                            -- Clicked on this enemy
                            self.battleUI:setSelectedEnemy(i)
                            print("Selected enemy " .. i .. ": " .. enemy.name)
                            return
                        end
                    end
                end
            end
        end
    end
end

-- Handle keyboard input
function InputSystem:keypressed(key)
    local mode = self.gameState:getMode()

    if mode == "battle" and self.battleUI then
        local battleSystem = self.gameState:getBattleSystem()
        local state = battleSystem:getState()

        if state == "player" then
            if key == "up" or key == "w" then
                self.battleUI:navigateUp()
            elseif key == "down" or key == "s" then
                self.battleUI:navigateDown()
            elseif key == "left" or key == "a" then
                self.battleUI:navigateLeft()
            elseif key == "right" or key == "d" then
                local enemies = battleSystem:getAliveEnemies()
                self.battleUI:navigateRight(#enemies)
            elseif key == "return" or key == "space" then
                -- Confirm action
                local action = self.battleUI:getSelectedAction()

                -- Check if auto battle selected
                if action == "auto" then
                    battleSystem:toggleAutoBattle()
                else
                    local targetIndex = self.battleUI:getSelectedEnemy()
                    battleSystem:selectAction(action, targetIndex)
                end
            end
        elseif state == "victory" or state == "defeat" or state == "escaped" then
            -- Press any key to continue
            if key == "return" or key == "space" then
                self.gameState:endBattle()
            end
        end
    end
end

return InputSystem

