-- camera.lua - 相机系统
-- 处理视角跟随、边界限制和坐标转换

local Camera = {}

function Camera.create()
    local state = {}

    state.x = 0
    state.y = 0

    state.screenWidth = love.graphics.getWidth()
    state.screenHeight = love.graphics.getHeight()

    state.smoothness = 8

    state.scale = 1

    state.bounds = {
        enabled = false,
        minX = 0,
        minY = 0,
        maxX = 0,
        maxY = 0
    }

    state.shake = {
        active = false,
        intensity = 0,
        duration = 0,
        timer = 0,
        offsetX = 0,
        offsetY = 0
    }

    state.deadzone = {
        enabled = false,
        x = 0,
        y = 0,
        width = 0,
        height = 0
    }

    return state
end

function Camera.updateScreenSize(state)
    state.screenWidth = love.graphics.getWidth()
    state.screenHeight = love.graphics.getHeight()
end

function Camera.setBounds(state, mapWidth, mapHeight)
    state.bounds.enabled = true
    state.bounds.minX = 0
    state.bounds.minY = 0
    local safeScale = math.max(0.1, state.scale)
    state.bounds.maxX = math.max(0, mapWidth - state.screenWidth / safeScale)
    state.bounds.maxY = math.max(0, mapHeight - state.screenHeight / safeScale)
end

function Camera.clearBounds(state)
    state.bounds.enabled = false
end

function Camera.follow(state, targetX, targetY, dt)
    local desiredX, desiredY

    if state.deadzone.enabled then
        local dz = state.deadzone
        local screenCenterX = state.x + state.screenWidth / 2
        local screenCenterY = state.y + state.screenHeight / 2

        desiredX = state.x
        desiredY = state.y

        if targetX < screenCenterX - dz.width / 2 - dz.x then
            desiredX = targetX - state.screenWidth / 2 + dz.width / 2 + dz.x
        elseif targetX > screenCenterX + dz.width / 2 - dz.x then
            desiredX = targetX - state.screenWidth / 2 - dz.width / 2 + dz.x
        end

        if targetY < screenCenterY - dz.height / 2 - dz.y then
            desiredY = targetY - state.screenHeight / 2 + dz.height / 2 + dz.y
        elseif targetY > screenCenterY + dz.height / 2 - dz.y then
            desiredY = targetY - state.screenHeight / 2 - dz.height / 2 + dz.y
        end
    else
        desiredX = targetX - state.screenWidth / 2
        desiredY = targetY - state.screenHeight / 2
    end

    local factor = math.min(1, state.smoothness * dt)

    state.x = state.x + (desiredX - state.x) * factor
    state.y = state.y + (desiredY - state.y) * factor

    Camera.applyBounds(state)
end

function Camera.setPosition(state, x, y, instant)
    state.x = x - state.screenWidth / 2
    state.y = y - state.screenHeight / 2

    Camera.applyBounds(state)
end

function Camera.applyBounds(state)
    if state.bounds.enabled then
        state.x = math.max(state.bounds.minX, math.min(state.bounds.maxX, state.x))
        state.y = math.max(state.bounds.minY, math.min(state.bounds.maxY, state.y))
    end
end

function Camera.apply(state)
    love.graphics.push()

    Camera.updateShake(state, love.timer.getDelta and love.timer.getDelta() or 0)

    love.graphics.translate(-state.x + state.shake.offsetX, -state.y + state.shake.offsetY)
    love.graphics.scale(state.scale, state.scale)
end

function Camera.reset(state)
    love.graphics.pop()
end

function Camera.toWorld(state, screenX, screenY)
    return (screenX / state.scale) + state.x, (screenY / state.scale) + state.y
end

function Camera.toScreen(state, worldX, worldY)
    return (worldX - state.x) * state.scale, (worldY - state.y) * state.scale
end

function Camera.getVisibleBounds(state)
    local x1 = math.max(0, state.x)
    local y1 = math.max(0, state.y)
    local x2 = state.x + state.screenWidth / state.scale
    local y2 = state.y + state.screenHeight / state.scale

    return x1, y1, x2, y2
end

function Camera.isVisible(state, x, y, width, height)
    width = width or 0
    height = height or 0

    local x1, y1, x2, y2 = Camera.getVisibleBounds(state)

    return x + width >= x1 and x <= x2 and y + height >= y1 and y <= y2
end

function Camera.startShake(state, intensity, duration)
    state.shake.active = true
    state.shake.intensity = intensity or 5
    state.shake.duration = duration or 0.3
    state.shake.timer = 0
end

function Camera.stopShake(state)
    state.shake.active = false
    state.shake.offsetX = 0
    state.shake.offsetY = 0
end

function Camera.updateShake(state, dt)
    if not state.shake.active then
        return
    end

    state.shake.timer = state.shake.timer + dt

    if state.shake.timer >= state.shake.duration then
        Camera.stopShake(state)
        return
    end

    local progress = state.shake.timer / state.shake.duration
    local currentIntensity = state.shake.intensity * (1 - progress)

    state.shake.offsetX = (math.random() * 2 - 1) * currentIntensity
    state.shake.offsetY = (math.random() * 2 - 1) * currentIntensity
end

function Camera.setDeadzone(state, x, y, width, height)
    state.deadzone.enabled = true
    state.deadzone.x = x or 0
    state.deadzone.y = y or 0
    state.deadzone.width = width or state.screenWidth * 0.3
    state.deadzone.height = height or state.screenHeight * 0.3
end

function Camera.clearDeadzone(state)
    state.deadzone.enabled = false
end

function Camera.setScale(state, scale, centerX, centerY)
    local oldScale = state.scale
    state.scale = math.max(0.1, math.min(4, scale))

    if centerX and centerY then
        local scaleRatio = state.scale / oldScale
        state.x = centerX - (centerX - state.x) * scaleRatio
        state.y = centerY - (centerY - state.y) * scaleRatio
    end

    Camera.applyBounds(state)
end

return Camera
