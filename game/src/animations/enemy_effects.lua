local EnemyEffects = {}

local EFFECT_DATABASE = {
    slime = {
        breathSpeed = 1.2,
        breathAmount = 0.08,
        attackColor = {0.3, 0.9, 0.4},
        attackParticles = "bounce",
        moveStyle = "bounce"
    },
    goblin = {
        breathSpeed = 1.5,
        breathAmount = 0.05,
        attackColor = {0.9, 0.5, 0.2},
        attackParticles = "slash",
        moveStyle = "walk"
    },
    skeleton = {
        breathSpeed = 2.0,
        breathAmount = 0.03,
        attackColor = {0.8, 0.8, 0.9},
        attackParticles = "bone",
        moveStyle = "float"
    },
    orc = {
        breathSpeed = 1.0,
        breathAmount = 0.06,
        attackColor = {0.8, 0.3, 0.3},
        attackParticles = "smash",
        moveStyle = "stomp"
    },
    wolf = {
        breathSpeed = 1.8,
        breathAmount = 0.07,
        attackColor = {0.6, 0.6, 0.7},
        attackParticles = "claw",
        moveStyle = "prowl"
    },
    bat = {
        breathSpeed = 2.5,
        breathAmount = 0.1,
        attackColor = {0.5, 0.3, 0.5},
        attackParticles = "swoop",
        moveStyle = "fly"
    },
    dragon = {
        breathSpeed = 0.8,
        breathAmount = 0.04,
        attackColor = {0.9, 0.3, 0.3},
        attackParticles = "fire",
        moveStyle = "hover"
    }
}

function EnemyEffects.create()
    return {
        activeEffects = {}
    }
end

function EnemyEffects.getEffectData(enemyType)
    for key, effect in pairs(EFFECT_DATABASE) do
        if string.find(string.lower(enemyType), key) then
            return effect
        end
    end

    return {
        breathSpeed = 1.5,
        breathAmount = 0.05,
        attackColor = {1, 1, 0},
        attackParticles = "default",
        moveStyle = "walk"
    }
end

function EnemyEffects.createAttackEffect(state, enemyType, x, y, targetX, targetY)
    local effect = EnemyEffects.getEffectData(enemyType)

    local attackEffect = {
        type = effect.attackParticles,
        color = effect.attackColor,
        startX = x,
        startY = y,
        endX = targetX,
        endY = targetY,
        time = 0,
        duration = 0.3,
        particles = {}
    }

    if effect.attackParticles == "bounce" then
        for i = 1, 5 do
            table.insert(attackEffect.particles, {
                x = x,
                y = y,
                vx = math.random(-50, 50),
                vy = math.random(-100, -50),
                life = 0.5
            })
        end
    elseif effect.attackParticles == "slash" then
        for i = 1, 3 do
            table.insert(attackEffect.particles, {
                angle = math.random() * math.pi * 2,
                distance = 0,
                maxDistance = 30,
                life = 0.3
            })
        end
    elseif effect.attackParticles == "fire" then
        for i = 1, 10 do
            table.insert(attackEffect.particles, {
                x = x,
                y = y,
                vx = (targetX - x) / 0.3 + math.random(-30, 30),
                vy = (targetY - y) / 0.3 + math.random(-30, 30),
                life = 0.4,
                size = math.random(3, 8)
            })
        end
    end

    table.insert(state.activeEffects, attackEffect)
end

function EnemyEffects.update(state, dt)
    for i = #state.activeEffects, 1, -1 do
        local effect = state.activeEffects[i]
        effect.time = effect.time + dt

        for j = #effect.particles, 1, -1 do
            local p = effect.particles[j]
            p.life = p.life - dt

            if effect.type == "bounce" then
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                p.vy = p.vy + 200 * dt
            elseif effect.type == "slash" then
                p.distance = p.distance + 100 * dt
            elseif effect.type == "fire" then
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
            end

            if p.life <= 0 then
                table.remove(effect.particles, j)
            end
        end

        if effect.time >= effect.duration and #effect.particles == 0 then
            table.remove(state.activeEffects, i)
        end
    end
end

function EnemyEffects.draw(state)
    for _, effect in ipairs(state.activeEffects) do
        love.graphics.setColor(effect.color)

        for _, p in ipairs(effect.particles) do
            local alpha = p.life / 0.5
            love.graphics.setColor(effect.color[1], effect.color[2], effect.color[3], alpha)

            if effect.type == "bounce" then
                love.graphics.circle("fill", p.x, p.y, 4)
            elseif effect.type == "slash" then
                local x = effect.startX + math.cos(p.angle) * p.distance
                local y = effect.startY + math.sin(p.angle) * p.distance
                love.graphics.circle("fill", x, y, 3)
            elseif effect.type == "fire" then
                love.graphics.circle("fill", p.x, p.y, p.size * alpha)
            else
                love.graphics.circle("fill", p.x, p.y, 3)
            end
        end
    end
end

function EnemyEffects.getMovementOffset(enemyType, time)
    local effect = EnemyEffects.getEffectData(enemyType)
    local offsetX, offsetY = 0, 0

    if effect.moveStyle == "bounce" then
        offsetY = math.abs(math.sin(time * 3)) * -5
    elseif effect.moveStyle == "float" then
        offsetY = math.sin(time * 2) * 3
    elseif effect.moveStyle == "fly" then
        offsetY = math.sin(time * 4) * 8
        offsetX = math.cos(time * 3) * 3
    elseif effect.moveStyle == "hover" then
        offsetY = math.sin(time * 1.5) * 5
    elseif effect.moveStyle == "stomp" then
        local cycle = time % 1.0
        if cycle < 0.1 then
            offsetY = -2
        end
    end

    return offsetX, offsetY
end

return EnemyEffects
