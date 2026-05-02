-- particle_system.lua - Environmental particle system
-- 环境粒子系统，支持季节性粒子效果

local ParticleSystem = {}

local SEASON_CONFIGS = {
    spring = {
        type = "petals",
        emitRate = 8,
        maxParticles = 150,
        colors = {
            {1.0, 0.85, 0.9, 0.9},
            {1.0, 0.75, 0.85, 0.85},
            {1.0, 0.95, 0.95, 0.8},
            {0.95, 0.8, 0.95, 0.9}
        },
        size = {min = 3, max = 6},
        speed = {x = {min = -15, max = 15}, y = {min = 20, max = 50}},
        lifetime = {min = 6, max = 12},
        rotation = true,
        rotationSpeed = {min = -2, max = 2},
        sway = {amplitude = 30, frequency = 2},
        gravity = 5
    },
    summer = {
        type = "dandelion",
        emitRate = 3,
        maxParticles = 60,
        colors = {
            {1.0, 1.0, 1.0, 0.7},
            {0.95, 0.95, 0.9, 0.6}
        },
        size = {min = 2, max = 4},
        speed = {x = {min = 5, max = 25}, y = {min = -10, max = 10}},
        lifetime = {min = 10, max = 20},
        rotation = false,
        sway = {amplitude = 50, frequency = 0.5},
        gravity = -2,
        glowEffect = true
    },
    autumn = {
        type = "leaves",
        emitRate = 12,
        maxParticles = 200,
        colors = {
            {0.9, 0.5, 0.2, 0.95},
            {0.85, 0.35, 0.15, 0.9},
            {0.95, 0.65, 0.25, 0.95},
            {0.75, 0.4, 0.2, 0.9},
            {0.8, 0.55, 0.2, 0.9}
        },
        size = {min = 4, max = 8},
        speed = {x = {min = -20, max = 20}, y = {min = 30, max = 70}},
        lifetime = {min = 5, max = 10},
        rotation = true,
        rotationSpeed = {min = -3, max = 3},
        sway = {amplitude = 40, frequency = 1.5},
        gravity = 10,
        wobble = true
    },
    winter = {
        type = "snow",
        emitRate = 25,
        maxParticles = 400,
        colors = {
            {1.0, 1.0, 1.0, 0.9},
            {0.95, 0.97, 1.0, 0.85},
            {0.9, 0.95, 1.0, 0.8}
        },
        size = {min = 2, max = 5},
        speed = {x = {min = -5, max = 5}, y = {min = 15, max = 35}},
        lifetime = {min = 8, max = 15},
        rotation = false,
        sway = {amplitude = 20, frequency = 0.8},
        gravity = 2,
        sparkle = true
    }
}

local WATER_SPARKLE_CONFIG = {
    maxSparkles = 50,
    colors = {
        {1.0, 1.0, 1.0, 0.8},
        {0.9, 0.95, 1.0, 0.7}
    },
    size = {min = 1, max = 3},
    lifetime = {min = 0.5, max = 1.5}
}

function ParticleSystem.create()
    local state = {}

    state.particles = {}
    state.waterSparkles = {}
    state.season = "spring"
    state.config = SEASON_CONFIGS.spring

    state.wind = 0
    state.windTarget = 0
    state.windChangeTimer = 0

    state.enabled = true
    state.time = 0

    return state
end

function ParticleSystem.setSeason(state, season)
    state.season = season
    state.config = SEASON_CONFIGS[season] or SEASON_CONFIGS.spring
    ParticleSystem.clearParticles(state)
end

function ParticleSystem.clearParticles(state)
    state.particles = {}
    state.waterSparkles = {}
end

function ParticleSystem.setEnabled(state, enabled)
    state.enabled = enabled
    if not enabled then
        ParticleSystem.clearParticles(state)
    end
end

function ParticleSystem.createParticle(state, x, y, customConfig)
    local config = customConfig or state.config

    local particle = {
        x = x,
        y = y,
        vx = ParticleSystem.randomRange(state, config.speed.x.min, config.speed.x.max),
        vy = ParticleSystem.randomRange(state, config.speed.y.min, config.speed.y.max),
        size = ParticleSystem.randomRange(state, config.size.min, config.size.max),
        color = config.colors[math.random(1, #config.colors)],
        lifetime = ParticleSystem.randomRange(state, config.lifetime.min, config.lifetime.max),
        age = 0,
        rotation = config.rotation and math.random() * math.pi * 2 or 0,
        rotationSpeed = config.rotation and ParticleSystem.randomRange(state, config.rotationSpeed.min, config.rotationSpeed.max) or 0,
        swayOffset = math.random() * math.pi * 2,
        alpha = 0,
        fadeIn = true
    }

    if config.wobble then
        particle.wobblePhase = math.random() * math.pi * 2
        particle.wobbleSpeed = ParticleSystem.randomRange(state, 3, 6)
    end

    if config.sparkle then
        particle.sparklePhase = math.random() * math.pi * 2
    end

    if config.glowEffect then
        particle.glow = true
    end

    return particle
end

function ParticleSystem.randomRange(state, min, max)
    return min + math.random() * (max - min)
end

function ParticleSystem.emit(state, x, y, count, customConfig)
    if not state.enabled then return end

    count = count or 1
    local config = customConfig or state.config

    for i = 1, count do
        if #state.particles < config.maxParticles then
            local offsetX = (customConfig and 0) or math.random(-50, 50)
            local offsetY = (customConfig and 0) or math.random(-20, 20)
            table.insert(state.particles, ParticleSystem.createParticle(state, x + offsetX, y + offsetY, config))
        end
    end
end

function ParticleSystem.emitWaterSparkle(state, x, y, width, height)
    if not state.enabled then return end
    if #state.waterSparkles >= WATER_SPARKLE_CONFIG.maxSparkles then return end

    local sparkle = {
        x = x + math.random() * width,
        y = y + math.random() * height,
        size = ParticleSystem.randomRange(state, WATER_SPARKLE_CONFIG.size.min, WATER_SPARKLE_CONFIG.size.max),
        color = WATER_SPARKLE_CONFIG.colors[math.random(1, #WATER_SPARKLE_CONFIG.colors)],
        lifetime = ParticleSystem.randomRange(state, WATER_SPARKLE_CONFIG.lifetime.min, WATER_SPARKLE_CONFIG.lifetime.max),
        age = 0,
        phase = math.random() * math.pi * 2,
        alpha = 0,
        fadeIn = true
    }

    table.insert(state.waterSparkles, sparkle)
end

function ParticleSystem.updateWind(state, dt)
    state.windChangeTimer = state.windChangeTimer + dt

    if state.windChangeTimer > 3 then
        state.windChangeTimer = 0
        state.windTarget = ParticleSystem.randomRange(state, -20, 20)
    end

    state.wind = state.wind + (state.windTarget - state.wind) * dt * 0.5
end

function ParticleSystem.update(state, dt)
    if not state.enabled then return end

    state.time = state.time + dt
    ParticleSystem.updateWind(state, dt)

    ParticleSystem.updateParticles(state, dt, state.particles, state.config)
    ParticleSystem.updateParticles(state, dt, state.waterSparkles, WATER_SPARKLE_CONFIG)
end

function ParticleSystem.updateParticles(state, dt, particleList, config)
    local i = 1
    while i <= #particleList do
        local p = particleList[i]

        p.age = p.age + dt

        if p.age >= p.lifetime then
            table.remove(particleList, i)
        else
            local lifeRatio = p.age / p.lifetime

            if p.fadeIn and lifeRatio < 0.1 then
                p.alpha = lifeRatio / 0.1
            elseif lifeRatio > 0.7 then
                p.alpha = 1 - (lifeRatio - 0.7) / 0.3
            else
                p.alpha = 1
            end

            if config.gravity then
                p.vy = p.vy + config.gravity * dt
            end

            local swayX = 0
            if config.sway then
                swayX = math.sin(state.time * config.sway.frequency + p.swayOffset) * config.sway.amplitude * dt
            end

            p.x = p.x + (p.vx + state.wind) * dt + swayX
            p.y = p.y + p.vy * dt

            if p.rotationSpeed then
                p.rotation = p.rotation + p.rotationSpeed * dt
            end

            if p.wobble then
                p.wobblePhase = p.wobblePhase + p.wobbleSpeed * dt
                p.x = p.x + math.sin(p.wobblePhase) * 0.5
            end

            if p.sparkle then
                p.sparklePhase = p.sparklePhase + dt * 8
            end

            i = i + 1
        end
    end
end

function ParticleSystem.emitFromTop(state, screenWidth, cameraX, cameraY, mapWidth, mapHeight)
    if not state.enabled then return end

    local emitCount = math.floor(state.config.emitRate * 0.1)
    if math.random() < (state.config.emitRate * 0.1 - emitCount) then
        emitCount = emitCount + 1
    end

    for i = 1, emitCount do
        if #state.particles < state.config.maxParticles then
            local x = cameraX + math.random() * screenWidth + state.wind * 2
            local y = cameraY - 20

            if x >= 0 and x <= mapWidth then
                ParticleSystem.emit(state, x, y, 1)
            end
        end
    end
end

function ParticleSystem.draw(state, camera)
    if not state.enabled then return end

    local camX, camY, camX2, camY2 = 0, 0, math.huge, math.huge
    if camera and camera.getVisibleBounds then
        camX, camY, camX2, camY2 = camera:getVisibleBounds()
    end

    for _, p in ipairs(state.particles) do
        if p.x >= camX - 50 and p.x <= camX2 + 50 and
           p.y >= camY - 50 and p.y <= camY2 + 50 then
            ParticleSystem.drawParticle(state, p)
        end
    end

    for _, s in ipairs(state.waterSparkles) do
        if s.x >= camX and s.x <= camX2 and s.y >= camY and s.y <= camY2 then
            ParticleSystem.drawSparkle(state, s)
        end
    end
end

function ParticleSystem.drawParticle(state, p)
    local alpha = p.alpha * p.color[4]

    if p.glow then
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha * 0.3)
        love.graphics.circle("fill", p.x, p.y, p.size * 2)
    end

    love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)

    if p.rotation and p.rotation ~= 0 then
        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.rotate(p.rotation)

        if state.config.type == "petals" then
            love.graphics.ellipse("fill", 0, 0, p.size, p.size * 0.6)
        elseif state.config.type == "leaves" then
            love.graphics.ellipse("fill", 0, 0, p.size, p.size * 0.5)
        else
            love.graphics.circle("fill", 0, 0, p.size)
        end

        love.graphics.pop()
    else
        if p.sparkle then
            local sparkleAlpha = alpha * (0.5 + 0.5 * math.sin(p.sparklePhase))
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], sparkleAlpha)

            love.graphics.circle("fill", p.x, p.y, p.size)
            love.graphics.circle("fill", p.x, p.y, p.size * 0.5)
        else
            love.graphics.circle("fill", p.x, p.y, p.size)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function ParticleSystem.drawSparkle(state, s)
    local alpha = s.alpha * s.color[4] * (0.5 + 0.5 * math.sin(s.phase + s.age * 10))

    love.graphics.setColor(s.color[1], s.color[2], s.color[3], alpha)
    love.graphics.circle("fill", s.x, s.y, s.size)

    love.graphics.setColor(1, 1, 1, alpha * 0.5)
    love.graphics.circle("fill", s.x, s.y, s.size * 0.5)

    love.graphics.setColor(1, 1, 1, 1)
end

function ParticleSystem.getParticleCount(state)
    return #state.particles, #state.waterSparkles
end

function ParticleSystem.setWind(state, wind)
    state.windTarget = wind
end

return ParticleSystem
