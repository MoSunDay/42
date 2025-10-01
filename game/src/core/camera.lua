-- camera.lua - 相机系统
-- 处理视角跟随和坐标转换

local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)
    
    -- 相机位置（世界坐标）
    self.x = 0
    self.y = 0
    
    -- 屏幕尺寸
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    -- 相机平滑跟随速度
    self.smoothness = 8
    
    -- 缩放（预留功能）
    self.scale = 1
    
    return self
end

-- 跟随目标
function Camera:follow(targetX, targetY, dt)
    -- 计算相机应该在的位置（让目标在屏幕中央）
    local desiredX = targetX - self.screenWidth / 2
    local desiredY = targetY - self.screenHeight / 2
    
    -- 平滑移动（线性插值）
    local factor = math.min(1, self.smoothness * dt)
    
    self.x = self.x + (desiredX - self.x) * factor
    self.y = self.y + (desiredY - self.y) * factor
end

-- 应用相机变换
function Camera:apply()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
    love.graphics.scale(self.scale, self.scale)
end

-- 重置相机变换
function Camera:reset()
    love.graphics.pop()
end

-- 将屏幕坐标转换为世界坐标
function Camera:toWorld(screenX, screenY)
    return (screenX / self.scale) + self.x, (screenY / self.scale) + self.y
end

-- 将世界坐标转换为屏幕坐标
function Camera:toScreen(worldX, worldY)
    return (worldX - self.x) * self.scale, (worldY - self.y) * self.scale
end

return Camera

