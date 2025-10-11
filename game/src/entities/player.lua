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

    -- 方向 (8方向)
    self.direction = "down" -- up, down, left, right, up-left, up-right, down-left, down-right
    self.angle = 0  -- 朝向角度

    -- 动画
    self.animationTime = 0
    self.animationFrame = 0

    -- 地图边界（将在 setMapBounds 中设置）
    self.mapWidth = 2000
    self.mapHeight = 2000

    -- 资源管理器
    self.assetManager = assetManager
    self.sprite = assetManager:getImage("player")

    -- Battle stats
    self.hp = 100
    self.maxHp = 100
    self.attack = 15
    self.defense = 5
    self.battleSpeed = 6
    self.level = 1
    self.exp = 0
    self.gold = 0
    self.isDefending = false

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

    -- 计算移动方向（8方向）
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y

    -- 计算角度
    self.angle = math.atan2(dy, dx)

    -- 确定8方向
    local absX = math.abs(dx)
    local absY = math.abs(dy)
    local threshold = 0.4  -- 斜向判定阈值

    if absX < 1 and absY < 1 then
        -- 几乎不移动
        return
    end

    -- 判断主要方向
    if absY < absX * threshold then
        -- 主要是水平移动
        self.direction = dx > 0 and "right" or "left"
    elseif absX < absY * threshold then
        -- 主要是垂直移动
        self.direction = dy > 0 and "down" or "up"
    else
        -- 斜向移动
        if dx > 0 and dy > 0 then
            self.direction = "down-right"
        elseif dx > 0 and dy < 0 then
            self.direction = "up-right"
        elseif dx < 0 and dy > 0 then
            self.direction = "down-left"
        else
            self.direction = "up-left"
        end
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

-- Battle methods
function Player:takeDamage(damage)
    local defense = self.isDefending and self.defense * 2 or self.defense
    local actualDamage = math.max(1, damage - defense)
    self.hp = self.hp - actualDamage

    if self.hp < 0 then
        self.hp = 0
    end

    self.isDefending = false
    return actualDamage
end

function Player:heal(amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

function Player:isAlive()
    return self.hp > 0
end

function Player:getHPPercent()
    return self.hp / self.maxHp
end

function Player:calculateDamage()
    -- Random damage between 80% to 120% of attack
    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    return math.floor(self.attack * multiplier)
end

function Player:gainExp(amount)
    self.exp = self.exp + amount
    -- Simple level up (every 100 exp)
    while self.exp >= 100 do
        self.exp = self.exp - 100
        self:levelUp()
    end
end

function Player:gainGold(amount)
    self.gold = self.gold + amount
end

function Player:levelUp()
    self.level = self.level + 1
    self.maxHp = self.maxHp + 10
    self.hp = self.maxHp
    self.attack = self.attack + 2
    self.defense = self.defense + 1
end

return Player

