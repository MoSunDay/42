-- input_system.lua - Input system
-- Handle all user input (mouse, keyboard, etc.)

local InputSystem = {}
InputSystem.__index = InputSystem

function InputSystem.new(gameState, renderSystem)
    local self = setmetatable({}, InputSystem)

    self.gameState = gameState
    self.renderSystem = renderSystem
    self.battleUI = renderSystem:getBattleUI()
    self.fullscreenMap = renderSystem:getFullscreenMap()
    self.hud = renderSystem:getHUD()
    self.chatUI = renderSystem:getChatUI()

    return self
end

-- Handle mouse press events
function InputSystem:mousepressed(x, y, button)
    local mode = self.gameState:getMode()

    if mode == "exploration" then
        -- Check if clicked on unified menu
        local unifiedMenu = self.renderSystem:getUnifiedMenu()
        if unifiedMenu and unifiedMenu:isMenuOpen() then
            if unifiedMenu:mousepressed(x, y, button) then
                return
            end
        end

        -- Check if fullscreen map is open
        if self.fullscreenMap:isMapOpen() then
            local worldX, worldY = self.fullscreenMap:mousepressed(x, y, button,
                                                                   self.gameState.map.width,
                                                                   self.gameState.map.height)
            if worldX and worldY then
                -- Navigate to clicked position
                self.gameState:movePlayerTo(worldX, worldY)
                print(string.format("Navigate to: (%.0f, %.0f)", worldX, worldY))
            end
            return
        end

        -- Check if clicked on minimap
        if button == 1 and self.hud:isMouseOverMinimap(x, y) then
            self.fullscreenMap:open()
            return
        end

        -- Check if clicked on chat input
        local chatUI = self.renderSystem:getChatUI()
        local chatSystem = self.gameState:getChatSystem()
        if chatUI and chatSystem then
            if chatUI:mousepressed(x, y, button, chatSystem) then
                return
            end
        end

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
                -- First check if clicked on action menu
                local action = self.battleUI:mousepressed(x, y, button, battleSystem)
                if action then
                    print("Clicked action: " .. action)
                    -- Handle the action like keyboard input
                    if action == "auto" then
                        battleSystem:toggleAutoBattle()
                    else
                        local targetIndex = self.battleUI:getSelectedEnemy()
                        battleSystem:selectAction(action, targetIndex)
                    end
                    return
                end

                -- Then check if clicked on an enemy
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

    -- Handle unified menu (M key)
    if mode == "exploration" then
        local unifiedMenu = self.renderSystem:getUnifiedMenu()
        if unifiedMenu then
            if key == "m" then
                unifiedMenu:toggle()
                return
            elseif unifiedMenu:isMenuOpen() then
                -- Let menu handle the key
                if unifiedMenu:keypressed(key) then
                    return
                end
            end
        end
    end

    -- Handle chat input in exploration mode
    if mode == "exploration" then
        local chatSystem = self.gameState:getChatSystem()

        if chatSystem and chatSystem:isInputting() then
            -- Chat is active
            if key == "return" then
                -- Send message
                local text = chatSystem:endInput()
                if text and text ~= "" then
                    self.gameState:sendChatMessage(text)
                end
                return
            elseif key == "escape" then
                -- Cancel input
                chatSystem:endInput()
                return
            elseif key == "backspace" then
                chatSystem:removeInputChar()
                return
            end
        else
            -- Chat is not active
            if key == "return" then
                -- Start chat input
                if chatSystem then
                    chatSystem:startInput()
                end
                return
            end
        end

        -- Handle Tab key for fullscreen map
        if key == "tab" then
            self.fullscreenMap:toggle()
            return
        elseif key == "escape" and self.fullscreenMap:isMapOpen() then
            self.fullscreenMap:close()
            return
        end
    end

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

-- Handle mouse wheel scroll
function InputSystem:wheelmoved(x, y)
    local mode = self.gameState:getMode()

    if mode == "exploration" then
        -- Scroll chat window
        local chatUI = self.renderSystem:getChatUI()
        if chatUI then
            chatUI:mousescroll(x, y)
        end
    elseif mode == "battle" then
        -- Scroll battle log
        local battleSystem = self.gameState:getBattleSystem()
        if battleSystem and battleSystem.battleLog then
            battleSystem.battleLog:scroll(-y * 20)
        end
    end
end

return InputSystem

