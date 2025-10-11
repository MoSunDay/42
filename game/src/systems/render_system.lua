-- render_system.lua - 渲染系统
-- 统一管理所有渲染逻辑

local UI = require("ui.hud")
local BattleUI = require("ui.battle_ui")
local AvatarRenderer = require("account.avatar_renderer")

local RenderSystem = {}
RenderSystem.__index = RenderSystem

function RenderSystem.new(gameState, assetManager)
    local self = setmetatable({}, RenderSystem)

    self.gameState = gameState
    self.assetManager = assetManager

    -- 创建UI
    self.hud = UI.new(assetManager)
    self.battleUI = BattleUI.new()

    return self
end

-- 主渲染函数
function RenderSystem:render()
    local mode = self.gameState:getMode()

    if mode == "login" then
        self:renderLogin()
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
    
    -- 绘制玩家
    self.gameState.player:draw()
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
end

-- Get battle UI (for input system)
function RenderSystem:getBattleUI()
    return self.battleUI
end

return RenderSystem

