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

function RenderSystem.create(gameState, assetManager)
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
        RenderSystem.render_login(state)
    elseif mode == "character_select" then
        RenderSystem.render_character_select(state)
    elseif mode == "exploration" then
        RenderSystem.render_exploration(state)
    elseif mode == "battle" then
        RenderSystem.render_battle(state)
    end
end

function RenderSystem.render_login(state)
    local loginUI = state.gameState:getLoginUI()
    if loginUI then
        loginUI:draw()
    end
end

function RenderSystem.render_character_select(state)
    local characterSelectUI = state.gameState:getCharacterSelectUI()

    if characterSelectUI then
        characterSelectUI:draw()
    end
end

function RenderSystem.render_exploration(state)
    if not state.gameState.camera or not state.gameState.map or not state.gameState.player then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Loading world...", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        return
    end

    Camera.apply(state.gameState.camera)
    RenderSystem.render_world(state)
    Camera.reset(state.gameState.camera)
    RenderSystem.render_ui(state)
end

function RenderSystem.render_battle(state)
    local battleSystem = state.gameState:getBattleSystem()
    local player = state.gameState.player
    local map = state.gameState.map

    BattleUI.draw(state.battleUI, battleSystem, player, map)
end

function RenderSystem.render_world(state)
    RenderSystem.render_ground_layer(state)
    RenderSystem.render_objects_layer(state)
    RenderSystem.render_entities(state)
    RenderSystem.render_particles(state)
    RenderSystem.render_overlay_layer(state)
end

function RenderSystem.render_ground_layer(state)
    if state.gameState.map and state.gameState.map.draw then
        MapData.draw(state.gameState.map, state.gameState.camera)
    end
end

function RenderSystem.render_objects_layer(state)
    if state.gameState.map and state.gameState.map.drawObjectsLayer then
        MapData.draw_objects_layer(state.gameState.map, state.gameState.camera)
    end
end

function RenderSystem.render_entities(state)
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
        chatSystem:draw_speech_bubbles()
    end
end

function RenderSystem.render_particles(state)
    MapManager.draw_particles(state.gameState.camera)
end

function RenderSystem.render_overlay_layer(state)
    if state.gameState.map and state.gameState.map.drawOverlayLayer then
        MapData.draw_overlay_layer(state.gameState.map, state.gameState.camera)
    end
    
    if state.gameState.map and state.gameState.map.drawBorder then
        MapData.draw_border(state.gameState.map)
    end
end

function RenderSystem.render_ui(state)
    local playerX, playerY = state.gameState:getPlayerPosition()
    UI.draw(state.hud, playerX, playerY, state.gameState.map)

    local AccountManager = require("account.account_manager")
    local character = AccountManager.get_current_character()
    if character then
        local w, h = love.graphics.getDimensions()
        AvatarRenderer.draw_character_panel(10, 10, 200, 200, character, state.assetManager.fonts.default, state.assetManager)
    end

    local partySystem = state.gameState:getPartySystem()
    if partySystem then
        PartyUI.draw(state.partyUI, partySystem)
    end

    local chatSystem = state.gameState:getChatSystem()
    if chatSystem then
        ChatUI.draw(state.chatUI, chatSystem)
    end

    if FullscreenMap.is_map_open(state.fullscreenMap) then
        FullscreenMap.draw(state.fullscreenMap, playerX, playerY, state.gameState.map)
    end

    if UnifiedMenu.is_menu_open(state.unifiedMenu) then
        UnifiedMenu.draw(state.unifiedMenu, state.gameState)
    end

    local skillPanel = state.gameState:getSkillPanel()
    if skillPanel and skillPanel.isOpen then
        SkillPanel.draw(skillPanel)
    end

    Particles.draw()
end

function RenderSystem.get_battle_ui(state)
    return state.battleUI
end

function RenderSystem.get_fullscreen_map(state)
    return state.fullscreenMap
end

function RenderSystem.get_hud(state)
    return state.hud
end

function RenderSystem.get_party_ui(state)
    return state.partyUI
end

function RenderSystem.get_chat_ui(state)
    return state.chatUI
end

function RenderSystem.get_unified_menu(state)
    return state.unifiedMenu
end

return RenderSystem
