-- camera.lua - 相机系统
-- 处理视角跟随、边界限制和坐标转换

local Camera = {}
Camera.__index = Camera

function Camera.new()
    local self = setmetatable({}, Camera)
    
    self.x = 0
    self.y = 0
    
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
    
    self.smoothness = 8
    
    self.scale = 1
    
    self.bounds = {
        enabled = false,
        minX = 0,
        minY = 0,
        maxX = 0,
        maxY = 0
    }
    
    self.shake = {
        active = false,
        intensity = 0,
        duration = 0,
        timer = 0,
        offsetX = 0,
        offsetY = 0
    }
    
    self.deadzone = {
        enabled = false,
        x = 0,
        y = 0,
        width = 0,
        height = 0
    }
    
    return self
end

function Camera:updateScreenSize()
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()
end

function Camera:setBounds(mapWidth, mapHeight)
    self.bounds.enabled = true
    self.bounds.minX = 0
    self.bounds.minY = 0
    local safeScale = math.max(0.1, self.scale)
    self.bounds.maxX = math.max(0, mapWidth - self.screenWidth / safeScale)
    self.bounds.maxY = math.max(0, mapHeight - self.screenHeight / safeScale)
end

function Camera:clearBounds()
    self.bounds.enabled = false
end

function Camera:follow(targetX, targetY, dt)
    local desiredX, desiredY
    
    if self.deadzone.enabled then
        local dz = self.deadzone
        local screenCenterX = self.x + self.screenWidth / 2
        local screenCenterY = self.y + self.screenHeight / 2
        
        desiredX = self.x
        desiredY = self.y
        
        if targetX < screenCenterX - dz.width / 2 - dz.x then
            desiredX = targetX - self.screenWidth / 2 + dz.width / 2 + dz.x
        elseif targetX > screenCenterX + dz.width / 2 - dz.x then
            desiredX = targetX - self.screenWidth / 2 - dz.width / 2 + dz.x
        end
        
        if targetY < screenCenterY - dz.height / 2 - dz.y then
            desiredY = targetY - self.screenHeight / 2 + dz.height / 2 + dz.y
        elseif targetY > screenCenterY + dz.height / 2 - dz.y then
            desiredY = targetY - self.screenHeight / 2 - dz.height / 2 + dz.y
        end
    else
        desiredX = targetX - self.screenWidth / 2
        desiredY = targetY - self.screenHeight / 2
    end
    
    local factor = math.min(1, self.smoothness * dt)
    
    self.x = self.x + (desiredX - self.x) * factor
    self.y = self.y + (desiredY - self.y) * factor
    
    self:applyBounds()
end

function Camera:setPosition(x, y, instant)
    self.x = x - self.screenWidth / 2
    self.y = y - self.screenHeight / 2
    
    self:applyBounds()
end

function Camera:applyBounds()
    if self.bounds.enabled then
        self.x = math.max(self.bounds.minX, math.min(self.bounds.maxX, self.x))
        self.y = math.max(self.bounds.minY, math.min(self.bounds.maxY, self.y))
    end
end

function Camera:apply()
    love.graphics.push()
    
    self:updateShake(love.timer.getDelta and love.timer.getDelta() or 0)
    
    love.graphics.translate(-self.x + self.shake.offsetX, -self.y + self.shake.offsetY)
    love.graphics.scale(self.scale, self.scale)
end

function Camera:reset()
    love.graphics.pop()
end

function Camera:toWorld(screenX, screenY)
    return (screenX / self.scale) + self.x, (screenY / self.scale) + self.y
end

function Camera:toScreen(worldX, worldY)
    return (worldX - self.x) * self.scale, (worldY - self.y) * self.scale
end

function Camera:getVisibleBounds()
    local x1 = math.max(0, self.x)
    local y1 = math.max(0, self.y)
    local x2 = self.x + self.screenWidth / self.scale
    local y2 = self.y + self.screenHeight / self.scale
    
    return x1, y1, x2, y2
end

function Camera:isVisible(x, y, width, height)
    width = width or 0
    height = height or 0
    
    local x1, y1, x2, y2 = self:getVisibleBounds()
    
    return x + width >= x1 and x <= x2 and y + height >= y1 and y <= y2
end

function Camera:startShake(intensity, duration)
    self.shake.active = true
    self.shake.intensity = intensity or 5
    self.shake.duration = duration or 0.3
    self.shake.timer = 0
end

function Camera:stopShake()
    self.shake.active = false
    self.shake.offsetX = 0
    self.shake.offsetY = 0
end

function Camera:updateShake(dt)
    if not self.shake.active then
        return
    end
    
    self.shake.timer = self.shake.timer + dt
    
    if self.shake.timer >= self.shake.duration then
        self:stopShake()
        return
    end
    
    local progress = self.shake.timer / self.shake.duration
    local currentIntensity = self.shake.intensity * (1 - progress)
    
    self.shake.offsetX = (math.random() * 2 - 1) * currentIntensity
    self.shake.offsetY = (math.random() * 2 - 1) * currentIntensity
end

function Camera:setDeadzone(x, y, width, height)
    self.deadzone.enabled = true
    self.deadzone.x = x or 0
    self.deadzone.y = y or 0
    self.deadzone.width = width or self.screenWidth * 0.3
    self.deadzone.height = height or self.screenHeight * 0.3
end

function Camera:clearDeadzone()
    self.deadzone.enabled = false
end

function Camera:setScale(scale, centerX, centerY)
    local oldScale = self.scale
    self.scale = math.max(0.1, math.min(4, scale))
    
    if centerX and centerY then
        local scaleRatio = self.scale / oldScale
        self.x = centerX - (centerX - self.x) * scaleRatio
        self.y = centerY - (centerY - self.y) * scaleRatio
    end
    
    self:applyBounds()
end

return Camera
