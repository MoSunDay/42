-- render_system.lua - 渲染系统
-- 统一管理所有渲染逻辑

local UI = require("ui.hud")
local BattleUI = require("src.ui.battle.battle_ui")
local FullscreenMap = require("src.ui.fullscreen_map")
local PartyUI = require("src.ui.party_ui")
local ChatUI = require("src.ui.chat_ui")
local AvatarRenderer = require("account.avatar_renderer")
local UnifiedMenu = require("src.ui.unified_menu")

local RenderSystem = {}
RenderSystem.__index = RenderSystem

function RenderSystem.new(gameState, assetManager)
    local self = setmetatable({}, RenderSystem)

    self.gameState = gameState
    self.assetManager = assetManager

    -- 创建UI
    self.hud = UI.new(assetManager)
    self.battleUI = BattleUI.new()
    self.fullscreenMap = FullscreenMap.new(assetManager)
    self.partyUI = PartyUI.new(assetManager)
    self.chatUI = ChatUI.new(assetManager)
    self.unifiedMenu = UnifiedMenu.new(assetManager)

    return self
end

-- Update render system
function RenderSystem:update(dt)
    self.hud:update(dt)
end

-- 主渲染函数
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

-- Render login screen
function RenderSystem:renderLogin()
    local loginUI = self.gameState:getLoginUI()
    if loginUI then
        loginUI:draw()
    end
end

-- Render character select screen
function RenderSystem:renderCharacterSelect()
    local AccountManager = require("account.account_manager")
    local characterSelectUI = self.gameState:getCharacterSelectUI()
    local username = self.gameState:getCurrentUsername()

    if characterSelectUI and username then
        characterSelectUI:draw(AccountManager, username)
    end
end

-- Render exploration mode
function RenderSystem:renderExploration()
    -- Check if world is initialized
    if not self.gameState.camera or not self.gameState.map or not self.gameState.player then
        -- World not ready yet, show loading
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Loading world...", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
        return
    end

    -- 应用相机变换
    self.gameState.camera:apply()

    -- 渲染世界空间的对象
    self:renderWorld()

    -- 重置相机变换
    self.gameState.camera:reset()

    -- 渲染屏幕空间的UI
    self:renderUI()
end

-- Render battle mode
function RenderSystem:renderBattle()
    local battleSystem = self.gameState:getBattleSystem()
    local player = self.gameState.player

    self.battleUI:draw(battleSystem, player)
end

-- 渲染世界空间对象
function RenderSystem:renderWorld()
    -- 绘制地图
    self.gameState.map:draw()

    -- 绘制可见怪物（明雷）
    if self.gameState.encounterZones then
        for _, zone in ipairs(self.gameState.encounterZones) do
            zone:draw(self.gameState.camera)
        end
    end

    -- 绘制玩家
    self.gameState.player:draw()

    -- 绘制聊天气泡（在世界空间）
    local chatSystem = self.gameState:getChatSystem()
    if chatSystem then
        chatSystem:drawSpeechBubbles()
    end
end

-- 渲染UI
function RenderSystem:renderUI()
    local playerX, playerY = self.gameState:getPlayerPosition()
    self.hud:draw(playerX, playerY, self.gameState.map.width, self.gameState.map.height)

    -- Draw character info panel
    local AccountManager = require("account.account_manager")
    local character = AccountManager.getCurrentCharacter()
    if character then
        local w, h = love.graphics.getDimensions()
        AvatarRenderer.drawCharacterPanel(10, 10, 200, 200, character, self.assetManager.fonts.default)
    end

    -- Draw party UI
    local partySystem = self.gameState:getPartySystem()
    if partySystem then
        self.partyUI:draw(partySystem)
    end

    -- Draw chat UI
    local chatSystem = self.gameState:getChatSystem()
    if chatSystem then
        self.chatUI:draw(chatSystem)
    end

    -- Draw fullscreen map if open (on top of everything)
    if self.fullscreenMap:isMapOpen() then
        -- Get minimap data
        local MapManager = require("map.map_manager")
        local minimapData = MapManager.getMinimap("town_01")

        self.fullscreenMap:draw(playerX, playerY,
                               self.gameState.map.width,
                               self.gameState.map.height,
                               minimapData)
    end

    -- Draw unified menu if open (on top of everything)
    if self.unifiedMenu:isMenuOpen() then
        self.unifiedMenu:draw(self.gameState)
    end
end

-- Get battle UI (for input system)
function RenderSystem:getBattleUI()
    return self.battleUI
end

-- Get fullscreen map (for input system)
function RenderSystem:getFullscreenMap()
    return self.fullscreenMap
end

-- Get HUD (for input system)
function RenderSystem:getHUD()
    return self.hud
end

-- Get party UI (for input system)
function RenderSystem:getPartyUI()
    return self.partyUI
end

-- Get chat UI (for input system)
function RenderSystem:getChatUI()
    return self.chatUI
end

-- Get unified menu (for input system)
function RenderSystem:getUnifiedMenu()
    return self.unifiedMenu
end

return RenderSystem

