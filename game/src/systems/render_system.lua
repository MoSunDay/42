-- render_system.lua - 渲染系统
-- 统一管理所有渲染逻辑

local UI = require("ui.hud")

local RenderSystem = {}
RenderSystem.__index = RenderSystem

function RenderSystem.new(gameState, assetManager)
    local self = setmetatable({}, RenderSystem)
    
    self.gameState = gameState
    self.assetManager = assetManager
    
    -- 创建UI
    self.hud = UI.new(assetManager)
    
    return self
end

-- 主渲染函数
function RenderSystem:render()
    -- 应用相机变换
    self.gameState.camera:apply()
    
    -- 渲染世界空间的对象
    self:renderWorld()
    
    -- 重置相机变换
    self.gameState.camera:reset()
    
    -- 渲染屏幕空间的UI
    self:renderUI()
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
end

return RenderSystem

