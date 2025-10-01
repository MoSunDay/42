-- game_state.lua - 游戏状态管理
-- 管理所有游戏实体和状态

local Player = require("entities.player")
local Map = require("entities.map")
local Camera = require("core.camera")

local GameState = {}
GameState.__index = GameState

function GameState.new(assetManager)
    local self = setmetatable({}, GameState)

    self.assetManager = assetManager

    -- 创建地图
    self.map = Map.new(2000, 2000)

    -- 创建玩家（初始位置在地图中央）
    self.player = Player.new(1000, 1000, assetManager)

    -- 设置玩家的地图边界
    self.player:setMapBounds(self.map.width, self.map.height)

    -- 创建相机
    self.camera = Camera.new()

    -- 游戏时间
    self.time = 0

    return self
end

function GameState:update(dt)
    self.time = self.time + dt
    
    -- 更新玩家
    self.player:update(dt)
    
    -- 更新相机跟随玩家
    self.camera:follow(self.player.x, self.player.y, dt)
end

function GameState:getPlayerPosition()
    return self.player.x, self.player.y
end

function GameState:movePlayerTo(worldX, worldY)
    self.player:moveTo(worldX, worldY)
end

return GameState

