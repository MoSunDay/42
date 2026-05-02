local BattleSystem = require("src.systems.battle.battle_system")
local BattleUI = require("src.ui.battle.battle_ui")
local BattleLog = require("src.systems.battle.battle_log")
local Camera = require("core.camera")
local FullscreenMap = require("src.ui.fullscreen_map")
local SkillPanel = require("src.ui.skill_panel")
local HUD = require("src.ui.hud")
local ChatUI = require("src.ui.chat_ui")
local UnifiedMenu = require("src.ui.unified_menu")
local Enemy = require("entities.enemy")

local InputSystem = {}

function InputSystem.new(gameState, renderSystem)
    return {
        gameState = gameState,
        renderSystem = renderSystem,
        battleUI = renderSystem:getBattleUI(),
        fullscreenMap = renderSystem:getFullscreenMap(),
        hud = renderSystem:getHUD(),
        chatUI = renderSystem:getChatUI(),
    }
end

function InputSystem.mousepressed(state, x, y, button)
    local mode = state.gameState:getMode()

    local skillPanel = state.gameState:getSkillPanel()
    if skillPanel and skillPanel.isOpen then
        if SkillPanel.mousepressed(skillPanel, x, y, button) then
            return
        end
    end

    if mode == "exploration" then
        local unifiedMenu = state.renderSystem:getUnifiedMenu()
        if unifiedMenu and UnifiedMenu.isMenuOpen(unifiedMenu) then
            if UnifiedMenu.mousepressed(unifiedMenu, x, y, button, state.gameState) then
                return
            end
        end

        if FullscreenMap.isMapOpen(state.fullscreenMap) then
            local worldX, worldY = FullscreenMap.mousepressed(state.fullscreenMap, x, y, button, state.gameState.map)
            if worldX and worldY then
                state.gameState:movePlayerTo(worldX, worldY)
                print(string.format("Navigate to: (%.0f, %.0f)", worldX, worldY))
            end
            return
        end

        if button == 1 and HUD.isMouseOverMinimap(state.hud, x, y) then
            FullscreenMap.open(state.fullscreenMap)
            return
        end

        if button == 1 then
            local buttonKey = HUD.isMouseOverButton(state.hud, x, y)
            if buttonKey then
                if buttonKey == "menu" then
                    local unifiedMenu = state.renderSystem:getUnifiedMenu()
                    if unifiedMenu then
                        UnifiedMenu.toggle(unifiedMenu)
                    end
                    return
                elseif buttonKey == "party" then
                    local unifiedMenu = state.renderSystem:getUnifiedMenu()
                    if unifiedMenu then
                        UnifiedMenu.open(unifiedMenu)
                        UnifiedMenu.setTab(unifiedMenu, 3)
                    end
                    return
                elseif buttonKey == "pet" then
                    local unifiedMenu = state.renderSystem:getUnifiedMenu()
                    if unifiedMenu then
                        UnifiedMenu.open(unifiedMenu)
                        UnifiedMenu.setTab(unifiedMenu, 4)
                    end
                    return
                end
            end
        end

        local chatUI = state.renderSystem:getChatUI()
        local chatSystem = state.gameState:getChatSystem()
        if chatUI and chatSystem then
            if ChatUI.mousepressed(chatUI, x, y, button, chatSystem) then
                return
            end
        end

        if button == 1 then
            local worldX, worldY = Camera.toWorld(state.gameState.camera, x, y)

            state.gameState:movePlayerTo(worldX, worldY)

            print(string.format("Click: Screen(%.0f, %.0f) -> World(%.0f, %.0f)",
                x, y, worldX, worldY))
        end
    elseif mode == "battle" then
        if button == 1 then
            local battleSystem = state.gameState:getBattleSystem()
            local battleState = BattleSystem.getState(battleSystem)

            if battleState == "player" then
                local action = BattleUI.mousepressed(state.battleUI, x, y, button, battleSystem)
                if action then
                    print("Clicked action: " .. action)
                    if action == "auto" then
                        BattleSystem.toggleAutoBattle(battleSystem)
                    else
                        local targetIndex = BattleUI.getSelectedEnemy(state.battleUI)
                        BattleSystem.selectAction(battleSystem, action, targetIndex)
                    end
                    return
                end

                local enemies = BattleSystem.getEnemies(battleSystem)
                local w, h = love.graphics.getDimensions()

                for i, enemy in ipairs(enemies) do
                    if Enemy.isAlive(enemy) then
                        local baseX = w * 0.2
                        local baseY = h * 0.6
                        local enemyX = baseX + (i - 1) * 100
                        local enemyY = baseY - (i - 1) * 80
                        local radius = 25

                        local dx = x - enemyX
                        local dy = y - enemyY
                        local distance = math.sqrt(dx * dx + dy * dy)

                        if distance <= radius then
                            BattleUI.setSelectedEnemy(state.battleUI, i)
                            print("Selected enemy " .. i .. ": " .. enemy.name)
                            return
                        end
                    end
                end
            end
        end
    end
end

function InputSystem.keypressed(state, key)
    local mode = state.gameState:getMode()

    local skillPanel = state.gameState:getSkillPanel()
    if skillPanel and skillPanel.isOpen then
        if SkillPanel.keypressed(skillPanel, key) then
            return
        end
    end

    if mode == "exploration" then
        local unifiedMenu = state.renderSystem:getUnifiedMenu()
        if unifiedMenu then
            if key == "m" then
                UnifiedMenu.toggle(unifiedMenu)
                return
            elseif UnifiedMenu.isMenuOpen(unifiedMenu) then
                if UnifiedMenu.keypressed(unifiedMenu, key) then
                    return
                end
            end
        end
    end

    if mode == "exploration" then
        local chatSystem = state.gameState:getChatSystem()
        
        if key == "k" then
            if skillPanel then
                SkillPanel.toggle(skillPanel, state.gameState.player)
            end
            return
        end

        if chatSystem and chatSystem:isInputting() then
            if key == "return" then
                local text = chatSystem:endInput()
                if text and text ~= "" then
                    state.gameState:sendChatMessage(text)
                end
                return
            elseif key == "escape" then
                chatSystem:endInput()
                return
            elseif key == "backspace" then
                chatSystem:removeInputChar()
                return
            end
        else
            if key == "return" then
                if chatSystem then
                    chatSystem:startInput()
                end
                return
            end
        end

        if key == "tab" then
            FullscreenMap.toggle(state.fullscreenMap)
            return
        elseif key == "escape" and FullscreenMap.isMapOpen(state.fullscreenMap) then
            FullscreenMap.close(state.fullscreenMap)
            return
        end
    end

    if mode == "battle" and state.battleUI then
        local battleSystem = state.gameState:getBattleSystem()
        local battleState = BattleSystem.getState(battleSystem)

        if BattleUI.isSkillMode(state.battleUI) then
            if key == "up" or key == "w" then
                BattleUI.navigateSkillUp(state.battleUI)
            elseif key == "down" or key == "s" then
                BattleUI.navigateSkillDown(state.battleUI)
            elseif key == "return" or key == "space" then
                local skillId = BattleUI.getSelectedSkill(state.battleUI)
                if skillId then
                    BattleSystem.selectSkill(battleSystem, skillId)
                    BattleUI.exitSkillMode(state.battleUI)
                    local targetIndex = BattleUI.getSelectedEnemy(state.battleUI)
                    BattleSystem.selectAction(battleSystem, "skill", targetIndex)
                end
            elseif key == "escape" then
                BattleUI.exitSkillMode(state.battleUI)
            end
            return
        end

        if battleState == "player" then
            if key == "up" or key == "w" then
                BattleUI.navigateUp(state.battleUI)
            elseif key == "down" or key == "s" then
                BattleUI.navigateDown(state.battleUI)
            elseif key == "left" or key == "a" then
                BattleUI.navigateLeft(state.battleUI)
            elseif key == "right" or key == "d" then
                local enemies = BattleSystem.getAliveEnemies(battleSystem)
                BattleUI.navigateRight(state.battleUI, #enemies)
            elseif key == "return" or key == "space" then
                local action = BattleUI.getSelectedAction(state.battleUI)

                if action == "skill" then
                    BattleUI.enterSkillMode(state.battleUI, battleSystem)
                    return
                end

                if action == "auto" then
                    BattleSystem.toggleAutoBattle(battleSystem)
                else
                    local targetIndex = BattleUI.getSelectedEnemy(state.battleUI)
                    BattleSystem.selectAction(battleSystem, action, targetIndex)
                end
            end
        elseif battleState == "victory" or battleState == "defeat" or battleState == "escaped" then
            if key == "return" or key == "space" then
                state.gameState:endBattle()
            end
        end
    end
end

function InputSystem.wheelmoved(state, x, y)
    local mode = state.gameState:getMode()

    if mode == "exploration" then
        local chatUI = state.renderSystem:getChatUI()
        if chatUI then
            ChatUI.mousescroll(chatUI, x, y)
        end
    elseif mode == "battle" then
        local battleSystem = state.gameState:getBattleSystem()
        if battleSystem and battleSystem.battleLog then
            BattleLog.scroll(battleSystem.battleLog, -y * 20)
        end
    end
end

function InputSystem.mousemoved(state, x, y)
    local mode = state.gameState:getMode()
    
    if mode == "exploration" then
        local unifiedMenu = state.renderSystem:getUnifiedMenu()
        if unifiedMenu and UnifiedMenu.isMenuOpen(unifiedMenu) then
            UnifiedMenu.mousemoved(unifiedMenu, x, y, state.gameState)
        end
    end
end

return InputSystem
