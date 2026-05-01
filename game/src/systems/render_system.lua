-- render_system.lua - 渲染系统
-- 统一管理所有渲染逻辑，支持分层渲染

local UI = require("ui.hud")
local BattleUI = require("src.ui.battle.battle_ui")
local FullscreenMap = require("src.ui.fullscreen_map")
local PartyUI = require("src.ui.party_ui")
local ChatUI = require("src.ui.chat_ui")
local AvatarRenderer = require("account.avatar_renderer")
local UnifiedMenu = require("src.ui.unified_menu")
local SkillPanel = require("src.ui.skill_panel")
local MapManager = require("map.map_manager")

local RenderSystem = {}
RenderSystem.__index = RenderSystem

function RenderSystem.new(gameState, assetManager)
    local self = setmetatable({}, RenderSystem)

    self.gameState = gameState
    self.assetManager = assetManager

    self.hud = UI.new(assetManager)
    self.battleUI = BattleUI.new(assetManager)
    self.fullscreenMap = FullscreenMap.new(assetManager)
    self.partyUI = PartyUI.new(assetManager)
    self.chatUI = ChatUI.new(assetManager)
    self.unifiedMenu = UnifiedMenu.new(assetManager)

    return self
end

function RenderSystem:update(dt)
    self.hud:update(dt)
    
    local screenWidth = love.graphics.getWidth()
    MapManager.update(dt, self.gameState.camera, screenWidth)
end

function RenderSystem:render()
    local mode = self.gameState:getMode()

    if mode == "login" then
        self:renderLogin()
    elseif mode == "character_select" then
        self:renderCharacterSelect()
    elseif mode == "exploration" then
        self:renderExploration()
    elseif mode == "battle" then
        self:renderBattle()
    end
end

function RenderSystem:renderLogin()
    local loginUI = self.gameState:getLoginUI()
    if loginUI then
        loginUI:draw()
    end
end

function RenderSystem:renderCharacterSelect()
    local characterSelectUI = self.gameState:getCharacterSelectUI()

    if characterSelectUI then
        characterSelectUI:draw()
    end
end

function RenderSystem:renderExploration()
    if not self.gameState.camera or not self.gameState.map or not self.gameState.player then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Loading world...", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        return
    end

    self.gameState.camera:apply()
    self:renderWorld()
    self.gameState.camera:reset()
    self:renderUI()
end

function RenderSystem:renderBattle()
    local battleSystem = self.gameState:getBattleSystem()
    local player = self.gameState.player
    local map = self.gameState.map

    self.battleUI:draw(battleSystem, player, map)
end

function RenderSystem:renderWorld()
    self:renderGroundLayer()
    self:renderObjectsLayer()
    self:renderEntities()
    self:renderParticles()
    self:renderOverlayLayer()
end

function RenderSystem:renderGroundLayer()
    if self.gameState.map and self.gameState.map.draw then
        self.gameState.map:draw(self.gameState.camera)
    end
end

function RenderSystem:renderObjectsLayer()
    if self.gameState.map and self.gameState.map.drawObjectsLayer then
        self.gameState.map:drawObjectsLayer(self.gameState.camera)
    end
end

function RenderSystem:renderEntities()
    if self.gameState.encounterZones then
        for _, zone in ipairs(self.gameState.encounterZones) do
            zone:draw(self.gameState.camera)
        end
    end

    if self.gameState.player then
        self.gameState.player:draw()
    end

    local chatSystem = self.gameState:getChatSystem()
    if chatSystem then
        chatSystem:drawSpeechBubbles()
    end
end

function RenderSystem:renderParticles()
    MapManager.drawParticles(self.gameState.camera)
end

function RenderSystem:renderOverlayLayer()
    if self.gameState.map and self.gameState.map.drawOverlayLayer then
        self.gameState.map:drawOverlayLayer(self.gameState.camera)
    end
    
    if self.gameState.map and self.gameState.map.drawBorder then
        self.gameState.map:drawBorder()
    end
end

function RenderSystem:renderUI()
    local playerX, playerY = self.gameState:getPlayerPosition()
    self.hud:draw(playerX, playerY, self.gameState.map)

    local AccountManager = require("account.account_manager")
    local character = AccountManager.getCurrentCharacter()
    if character then
        local w, h = love.graphics.getDimensions()
        AvatarRenderer.drawCharacterPanel(10, 10, 200, 200, character, self.assetManager.fonts.default)
    end

    local partySystem = self.gameState:getPartySystem()
    if partySystem then
        self.partyUI:draw(partySystem)
    end

    local chatSystem = self.gameState:getChatSystem()
    if chatSystem then
        self.chatUI:draw(chatSystem)
    end

    if self.fullscreenMap:isMapOpen() then
        self.fullscreenMap:draw(playerX, playerY, self.gameState.map)
    end

    if self.unifiedMenu:isMenuOpen() then
        self.unifiedMenu:draw(self.gameState)
    end

    local skillPanel = self.gameState:getSkillPanel()
    if skillPanel and skillPanel.isOpen then
        skillPanel:draw()
    end
end

function RenderSystem:getBattleUI()
    return self.battleUI
end

function RenderSystem:getFullscreenMap()
    return self.fullscreenMap
end

function RenderSystem:getHUD()
    return self.hud
end

function RenderSystem:getPartyUI()
    return self.partyUI
end

function RenderSystem:getChatUI()
    return self.chatUI
end

function RenderSystem:getUnifiedMenu()
    return self.unifiedMenu
end

return RenderSystem
