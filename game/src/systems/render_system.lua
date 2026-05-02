local UI = require("ui.hud")
local BattleUI = require("src.ui.battle.battle_ui")
local FullscreenMap = require("src.ui.fullscreen_map")
local PartyUI = require("src.ui.party_ui")
local ChatUI = require("src.ui.chat_ui")
local AvatarRenderer = require("account.avatar_renderer")
local UnifiedMenu = require("src.ui.unified_menu")
local SkillPanel = require("src.ui.skill_panel")
local MapManager = require("map.map_manager")
local Animation = require("src.ui.animation")
local Particles = require("src.ui.particles")
local Theme = require("src.ui.theme")
local BattleBackground = require("src.ui.battle.battle_background")
local Camera = require("core.camera")
local Map = require("entities.map")
local EncounterZone = require("entities.encounter_zone")
local Player = require("entities.player")
local MapData = require("map.map_data")

local RenderSystem = {}

function RenderSystem.new(gameState, assetManager)
    return {
        gameState = gameState,
        assetManager = assetManager,
        hud = UI.create(assetManager),
        battleUI = BattleUI.create(assetManager),
        fullscreenMap = FullscreenMap.create(assetManager),
        partyUI = PartyUI.create(assetManager),
        chatUI = ChatUI.create(assetManager),
        unifiedMenu = UnifiedMenu.create(assetManager),
    }
end

function RenderSystem.update(state, dt)
    Animation.update(dt)
    Theme.update(dt)
    Particles.update(dt)
    BattleBackground.update(dt)
    UI.update(state.hud, dt)
    
    local screenWidth = love.graphics.getWidth()
    MapManager.update(dt, state.gameState.camera, screenWidth)
end

function RenderSystem.render(state)
    local mode = state.gameState:getMode()

    if mode == "login" then
        RenderSystem.renderLogin(state)
    elseif mode == "character_select" then
        RenderSystem.renderCharacterSelect(state)
    elseif mode == "exploration" then
        RenderSystem.renderExploration(state)
    elseif mode == "battle" then
        RenderSystem.renderBattle(state)
    end
end

function RenderSystem.renderLogin(state)
    local loginUI = state.gameState:getLoginUI()
    if loginUI then
        loginUI:draw()
    end
end

function RenderSystem.renderCharacterSelect(state)
    local characterSelectUI = state.gameState:getCharacterSelectUI()

    if characterSelectUI then
        characterSelectUI:draw()
    end
end

function RenderSystem.renderExploration(state)
    if not state.gameState.camera or not state.gameState.map or not state.gameState.player then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Loading world...", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        return
    end

    Camera.apply(state.gameState.camera)
    RenderSystem.renderWorld(state)
    Camera.reset(state.gameState.camera)
    RenderSystem.renderUI(state)
end

function RenderSystem.renderBattle(state)
    local battleSystem = state.gameState:getBattleSystem()
    local player = state.gameState.player
    local map = state.gameState.map

    BattleUI.draw(state.battleUI, battleSystem, player, map)
end

function RenderSystem.renderWorld(state)
    RenderSystem.renderGroundLayer(state)
    RenderSystem.renderObjectsLayer(state)
    RenderSystem.renderEntities(state)
    RenderSystem.renderParticles(state)
    RenderSystem.renderOverlayLayer(state)
end

function RenderSystem.renderGroundLayer(state)
    if state.gameState.map and state.gameState.map.draw then
        MapData.draw(state.gameState.map, state.gameState.camera)
    end
end

function RenderSystem.renderObjectsLayer(state)
    if state.gameState.map and state.gameState.map.drawObjectsLayer then
        MapData.drawObjectsLayer(state.gameState.map, state.gameState.camera)
    end
end

function RenderSystem.renderEntities(state)
    if state.gameState.encounterZones then
        for _, zone in ipairs(state.gameState.encounterZones) do
            EncounterZone.draw(zone, state.gameState.camera)
        end
    end

    if state.gameState.player then
        Player.draw(state.gameState.player)
    end

    local chatSystem = state.gameState:getChatSystem()
    if chatSystem then
        chatSystem:drawSpeechBubbles()
    end
end

function RenderSystem.renderParticles(state)
    MapManager.drawParticles(state.gameState.camera)
end

function RenderSystem.renderOverlayLayer(state)
    if state.gameState.map and state.gameState.map.drawOverlayLayer then
        MapData.drawOverlayLayer(state.gameState.map, state.gameState.camera)
    end
    
    if state.gameState.map and state.gameState.map.drawBorder then
        MapData.drawBorder(state.gameState.map)
    end
end

function RenderSystem.renderUI(state)
    local playerX, playerY = state.gameState:getPlayerPosition()
    UI.draw(state.hud, playerX, playerY, state.gameState.map)

    local AccountManager = require("account.account_manager")
    local character = AccountManager.getCurrentCharacter()
    if character then
        local w, h = love.graphics.getDimensions()
        AvatarRenderer.drawCharacterPanel(10, 10, 200, 200, character, state.assetManager.fonts.default, state.assetManager)
    end

    local partySystem = state.gameState:getPartySystem()
    if partySystem then
        PartyUI.draw(state.partyUI, partySystem)
    end

    local chatSystem = state.gameState:getChatSystem()
    if chatSystem then
        ChatUI.draw(state.chatUI, chatSystem)
    end

    if FullscreenMap.isMapOpen(state.fullscreenMap) then
        FullscreenMap.draw(state.fullscreenMap, playerX, playerY, state.gameState.map)
    end

    if UnifiedMenu.isMenuOpen(state.unifiedMenu) then
        UnifiedMenu.draw(state.unifiedMenu, state.gameState)
    end

    local skillPanel = state.gameState:getSkillPanel()
    if skillPanel and skillPanel.isOpen then
        SkillPanel.draw(skillPanel)
    end

    Particles.draw()
end

function RenderSystem.getBattleUI(state)
    return state.battleUI
end

function RenderSystem.getFullscreenMap(state)
    return state.fullscreenMap
end

function RenderSystem.getHUD(state)
    return state.hud
end

function RenderSystem.getPartyUI(state)
    return state.partyUI
end

function RenderSystem.getChatUI(state)
    return state.chatUI
end

function RenderSystem.getUnifiedMenu(state)
    return state.unifiedMenu
end

return RenderSystem
