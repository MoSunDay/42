-- player.lua - 玩家实体
-- 处理玩家的移动、动画和状态

local Player = {}
Player.__index = Player

function Player.new(x, y, assetManager)
    local self = setmetatable({}, Player)

    -- 位置
    self.x = x or 0
    self.y = y or 0

    -- 目标位置
    self.targetX = self.x
    self.targetY = self.y

    -- 移动速度（像素/秒）
    self.speed = 250

    -- 状态
    self.isMoving = false

    -- 尺寸
    self.width = 32
    self.height = 32

    -- 方向
    self.direction = "down" -- up, down, left, right

    -- 动画
    self.animationTime = 0
    self.animationFrame = 0

    -- 地图边界（将在 setMapBounds 中设置）
    self.mapWidth = 2000
    self.mapHeight = 2000

    -- 资源管理器
    self.assetManager = assetManager
    self.sprite = assetManager:getImage("player")

    return self
end

-- 设置地图边界
function Player:setMapBounds(width, height)
    self.mapWidth = width
    self.mapHeight = height
end

-- 设置移动目标（带边界检查）
function Player:moveTo(x, y)
    -- 限制目标位置在地图边界内
    self.targetX = math.max(self.width/2, math.min(x, self.mapWidth - self.width/2))
    self.targetY = math.max(self.height/2, math.min(y, self.mapHeight - self.height/2))

    self.isMoving = true

    -- 计算移动方向
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y

    if math.abs(dx) > math.abs(dy) then
        self.direction = dx > 0 and "right" or "left"
    else
        self.direction = dy > 0 and "down" or "up"
    end
end

-- 更新玩家状态
function Player:update(dt)
    if not self.isMoving then
        return
    end

    -- 计算到目标的距离
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    -- 如果已经到达目标
    if distance < 3 then
        self.x = self.targetX
        self.y = self.targetY
        self.isMoving = false
        self.animationFrame = 0
        return
    end

    -- 归一化方向向量
    local dirX = dx / distance
    local dirY = dy / distance

    -- 移动玩家
    local moveDistance = self.speed * dt
    if moveDistance > distance then
        moveDistance = distance
    end

    self.x = self.x + dirX * moveDistance
    self.y = self.y + dirY * moveDistance

    -- 确保玩家不会超出地图边界
    self.x = math.max(self.width/2, math.min(self.x, self.mapWidth - self.width/2))
    self.y = math.max(self.height/2, math.min(self.y, self.mapHeight - self.height/2))

    -- 更新动画
    self.animationTime = self.animationTime + dt
    if self.animationTime > 0.15 then
        self.animationTime = 0
        self.animationFrame = (self.animationFrame + 1) % 4
    end
end

-- 绘制玩家
function Player:draw()
    love.graphics.setColor(1, 1, 1)
    
    -- 绘制玩家精灵
    if self.sprite then
        love.graphics.draw(self.sprite, 
            self.x - self.width/2, 
            self.y - self.height/2)
    end
    
    -- 如果正在移动，绘制目标位置标记
    if self.isMoving then
        love.graphics.setColor(1, 1, 0, 0.6)
        love.graphics.circle("line", self.targetX, self.targetY, 12)
        love.graphics.line(self.targetX - 10, self.targetY, self.targetX + 10, self.targetY)
        love.graphics.line(self.targetX, self.targetY - 10, self.targetX, self.targetY + 10)
        
        -- 绘制移动路径
        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.line(self.x, self.y, self.targetX, self.targetY)
    end
    
    -- 绘制移动动画效果（脚步）
    if self.isMoving and self.animationFrame % 2 == 0 then
        love.graphics.setColor(0.2, 0.6, 1.0, 0.2)
        love.graphics.circle("fill", self.x, self.y + self.height/2, 10)
    end
    
    love.graphics.setColor(1, 1, 1)
end

return Player

