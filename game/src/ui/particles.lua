local Particles = {}

Particles.emitters = {}
Particles.time = 0

local GOLD = {0.95, 0.85, 0.4}
local FIRE_COLORS = {
    {1.0, 0.9, 0.3},
    {1.0, 0.6, 0.1},
    {1.0, 0.3, 0.1},
    {0.8, 0.1, 0.0}
}
local HEAL_COLORS = {
    {0.3, 1.0, 0.5},
    {0.5, 1.0, 0.7},
    {0.2, 0.8, 0.4}
}
local FROST_COLORS = {
    {0.6, 0.8, 1.0},
    {0.8, 0.9, 1.0},
    {0.4, 0.7, 1.0},
    {1.0, 1.0, 1.0}
}
local MAGIC_COLORS = {
    {0.6, 0.3, 1.0},
    {0.8, 0.5, 1.0},
    {0.4, 0.2, 0.9},
    {1.0, 0.8, 1.0}
}
local SPARK_COLORS = {
    {1.0, 1.0, 0.8},
    {1.0, 0.95, 0.6},
    {0.9, 0.9, 1.0},
    {1.0, 1.0, 1.0}
}

local PRESETS = {
    goldDust = {
        count = 3,
        lifeMin = 0.8, lifeMax = 2.0,
        speedMin = 10, speedMax = 30,
        sizeMin = 1, sizeMax = 3,
        colors = {GOLD, {0.9, 0.8, 0.3}},
        direction = {0, -1},
        spread = 0.8,
        gravity = -5,
        fadeOut = true,
        shrink = true
    },
    fire = {
        count = 5,
        lifeMin = 0.3, lifeMax = 0.8,
        speedMin = 30, speedMax = 60,
        sizeMin = 2, sizeMax = 5,
        colors = FIRE_COLORS,
        direction = {0, -1},
        spread = 0.5,
        gravity = -20,
        fadeOut = true,
        shrink = true
    },
    heal = {
        count = 4,
        lifeMin = 0.5, lifeMax = 1.2,
        speedMin = 15, speedMax = 35,
        sizeMin = 2, sizeMax = 4,
        colors = HEAL_COLORS,
        direction = {0, -1},
        spread = 0.6,
        gravity = -10,
        fadeOut = true,
        shrink = true
    },
    frost = {
        count = 4,
        lifeMin = 0.5, lifeMax = 1.5,
        speedMin = 10, speedMax = 25,
        sizeMin = 1, sizeMax = 3,
        colors = FROST_COLORS,
        direction = {0, -1},
        spread = 1.0,
        gravity = -3,
        fadeOut = true,
        shrink = true
    },
    magic = {
        count = 3,
        lifeMin = 0.6, lifeMax = 1.5,
        speedMin = 15, speedMax = 40,
        sizeMin = 1, sizeMax = 4,
        colors = MAGIC_COLORS,
        direction = {0, -1},
        spread = 1.2,
        gravity = -8,
        fadeOut = true,
        shrink = true
    },
    sparkle = {
        count = 2,
        lifeMin = 0.3, lifeMax = 0.8,
        speedMin = 5, speedMax = 20,
        sizeMin = 1, sizeMax = 2,
        colors = SPARK_COLORS,
        direction = {0, 0},
        spread = 1.5,
        gravity = 0,
        fadeOut = true,
        shrink = false
    },
    damage = {
        count = 6,
        lifeMin = 0.2, lifeMax = 0.5,
        speedMin = 40, speedMax = 80,
        sizeMin = 2, sizeMax = 4,
        colors = {{1, 0.2, 0.2}, {1, 0.5, 0.1}},
        direction = {0, 0},
        spread = 2.0,
        gravity = 0,
        fadeOut = true,
        shrink = true
    },
    levelUp = {
        count = 10,
        lifeMin = 0.8, lifeMax = 2.0,
        speedMin = 30, speedMax = 60,
        sizeMin = 2, sizeMax = 5,
        colors = {GOLD, {1, 1, 0.8}, {0.9, 0.9, 0.3}},
        direction = {0, -1},
        spread = 1.5,
        gravity = -15,
        fadeOut = true,
        shrink = true
    }
}

local function random_range(min, max)
    return min + math.random() * (max - min)
end

local function pick_color(colors)
    return colors[math.random(#colors)]
end

local function create_particle(x, y, preset)
    local angle = math.atan2(preset.direction[2], preset.direction[1])
    angle = angle + random_range(-preset.spread, preset.spread)
    local speed = random_range(preset.speedMin, preset.speedMax)

    return {
        x = x + random_range(-5, 5),
        y = y + random_range(-5, 5),
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        life = random_range(preset.lifeMin, preset.lifeMax),
        maxLife = 0,
        size = random_range(preset.sizeMin, preset.sizeMax),
        color = pick_color(preset.colors),
        fadeOut = preset.fadeOut,
        shrink = preset.shrink,
        gravity = preset.gravity or 0,
        alpha = 1
    }
end

function Particles.emit(x, y, presetName, count)
    local preset = PRESETS[presetName]
    if not preset then return end

    local emitter = {
        x = x,
        y = y,
        preset = preset,
        particles = {},
        emitTimer = 0,
        emitInterval = 0.05,
        remaining = count or preset.count * 10,
        active = true
    }

    for _ = 1, preset.count do
        if emitter.remaining <= 0 then break end
        local p = create_particle(x, y, preset)
        p.maxLife = p.life
        table.insert(emitter.particles, p)
        emitter.remaining = emitter.remaining - 1
    end

    table.insert(Particles.emitters, emitter)
    return emitter
end

function Particles.burst(x, y, presetName, count)
    local preset = PRESETS[presetName]
    if not preset then return end

    count = count or 15

    local emitter = {
        x = x,
        y = y,
        preset = preset,
        particles = {},
        emitTimer = 0,
        emitInterval = 0,
        remaining = 0,
        active = true
    }

    for _ = 1, count do
        local p = create_particle(x, y, preset)
        p.maxLife = p.life
        table.insert(emitter.particles, p)
    end

    table.insert(Particles.emitters, emitter)
    return emitter
end

function Particles.continuous(x, y, presetName, rate)
    local preset = PRESETS[presetName]
    if not preset then return end

    local emitter = {
        x = x,
        y = y,
        preset = preset,
        particles = {},
        emitTimer = 0,
        emitInterval = 1 / (rate or 10),
        remaining = 999999,
        active = true,
        continuous = true
    }

    table.insert(Particles.emitters, emitter)
    return emitter
end

function Particles.update(dt)
    Particles.time = Particles.time + dt

    local i = 1
    while i <= #Particles.emitters do
        local emitter = Particles.emitters[i]

        if emitter.active and emitter.remaining > 0 then
            emitter.emitTimer = emitter.emitTimer + dt
            while emitter.emitTimer >= emitter.emitInterval and emitter.remaining > 0 do
                emitter.emitTimer = emitter.emitTimer - emitter.emitInterval
                local p = create_particle(emitter.x, emitter.y, emitter.preset)
                p.maxLife = p.life
                table.insert(emitter.particles, p)
                emitter.remaining = emitter.remaining - 1
            end
        end

        local pi = 1
        while pi <= #emitter.particles do
            local p = emitter.particles[pi]
            p.life = p.life - dt
            p.vy = p.vy + (p.gravity or 0) * dt
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt

            if p.life <= 0 then
                table.remove(emitter.particles, pi)
            else
                local lifeRatio = p.life / p.maxLife
                if p.fadeOut then
                    p.alpha = lifeRatio
                end
                if p.shrink then
                    p.currentSize = p.size * lifeRatio
                else
                    p.currentSize = p.size
                end
                pi = pi + 1
            end
        end

        if #emitter.particles == 0 and emitter.remaining <= 0 then
            emitter.active = false
            if not emitter.continuous then
                table.remove(Particles.emitters, i)
            else
                i = i + 1
            end
        else
            i = i + 1
        end
    end
end

function Particles.draw()
    for _, emitter in ipairs(Particles.emitters) do
        for _, p in ipairs(emitter.particles) do
            local c = p.color
            love.graphics.setColor(c[1], c[2], c[3], p.alpha or 1)
            local s = p.currentSize or p.size
            love.graphics.circle("fill", p.x, p.y, math.max(0.5, s))
        end
    end
    love.graphics.setColor(1, 1, 1)
end

function Particles.draw_at(x, y, presetName)
    return Particles.continuous(x, y, presetName, 5)
end

function Particles.clear()
    Particles.emitters = {}
end

function Particles.stop_emitter(emitter)
    if emitter then
        emitter.active = false
        emitter.remaining = 0
    end
end

function Particles.move_emitter(emitter, x, y)
    if emitter then
        emitter.x = x
        emitter.y = y
    end
end

return Particles
