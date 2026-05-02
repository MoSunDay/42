local BattleAnimation = {}

function BattleAnimation.create()
    return {
        animations = {},
        damageNumbers = {},
    }
end

function BattleAnimation.addAttackAnimation(state, fromX, fromY, toX, toY, callback)
    local anim = {
        type = "attack",
        fromX = fromX,
        fromY = fromY,
        toX = toX,
        toY = toY,
        progress = 0,
        duration = 0.3,
        callback = callback
    }
    table.insert(state.animations, anim)
end

function BattleAnimation.addDamageNumber(state, x, y, damage, isPlayer, hitType)
    local dmg = {
        x = x,
        y = y,
        damage = damage,
        isPlayer = isPlayer or false,
        hitType = hitType or "normal",
        alpha = 1.0,
        offsetY = 0,
        duration = 1.5,
        timer = 0
    }
    table.insert(state.damageNumbers, dmg)
end

function BattleAnimation.addHitFlash(state, x, y)
    local flash = {
        type = "flash",
        x = x,
        y = y,
        radius = 30,
        alpha = 1.0,
        duration = 0.2,
        timer = 0
    }
    table.insert(state.animations, flash)
end

function BattleAnimation.update(state, dt)
    for i = #state.animations, 1, -1 do
        local anim = state.animations[i]

        if anim.type == "attack" then
            anim.progress = anim.progress + dt / anim.duration
            if anim.progress >= 1 then
                if anim.callback then
                    anim.callback()
                end
                table.remove(state.animations, i)
            end
        elseif anim.type == "flash" then
            anim.timer = anim.timer + dt
            anim.alpha = 1 - (anim.timer / anim.duration)
            if anim.timer >= anim.duration then
                table.remove(state.animations, i)
            end
        end
    end

    for i = #state.damageNumbers, 1, -1 do
        local dmg = state.damageNumbers[i]
        dmg.timer = dmg.timer + dt
        dmg.offsetY = dmg.offsetY - dt * 50
        dmg.alpha = 1 - (dmg.timer / dmg.duration)

        if dmg.timer >= dmg.duration then
            table.remove(state.damageNumbers, i)
        end
    end
end

function BattleAnimation.draw(state)
    for _, anim in ipairs(state.animations) do
        if anim.type == "attack" then
            BattleAnimation.drawAttackLine(state, anim)
        elseif anim.type == "flash" then
            BattleAnimation.drawFlash(state, anim)
        end
    end

    for _, dmg in ipairs(state.damageNumbers) do
        BattleAnimation.drawDamageNumber(state, dmg)
    end
end

function BattleAnimation.drawAttackLine(state, anim)
    local t = anim.progress
    t = 1 - math.pow(1 - t, 3)

    local x = anim.fromX + (anim.toX - anim.fromX) * t
    local y = anim.fromY + (anim.toY - anim.fromY) * t

    love.graphics.setColor(1, 1, 0, 0.8)
    love.graphics.setLineWidth(3)
    love.graphics.line(anim.fromX, anim.fromY, x, y)

    love.graphics.setColor(1, 0.5, 0, 1)
    love.graphics.circle("fill", x, y, 8)

    love.graphics.setLineWidth(1)
end

function BattleAnimation.drawFlash(state, flash)
    love.graphics.setColor(1, 1, 1, flash.alpha * 0.8)
    love.graphics.circle("fill", flash.x, flash.y, flash.radius)

    love.graphics.setColor(1, 0.5, 0, flash.alpha * 0.5)
    love.graphics.circle("line", flash.x, flash.y, flash.radius)
end

function BattleAnimation.drawDamageNumber(state, dmg)
    local x = dmg.x
    local y = dmg.y + dmg.offsetY

    local text, color, scale

    if dmg.hitType == "miss" then
        text = "MISS"
        color = {0.5, 0.5, 0.5, dmg.alpha}
        scale = 0.9
    elseif dmg.hitType == "crit" then
        text = tostring(dmg.damage) .. "!"
        color = {1, 0.8, 0.1, dmg.alpha}
        scale = 1.6
    else
        text = tostring(dmg.damage)
        if dmg.isPlayer then
            color = {1, 0.4, 0.4, dmg.alpha}
        else
            color = {1, 1, 1, dmg.alpha}
        end
        scale = 1.2
    end

    love.graphics.setColor(0, 0, 0, dmg.alpha * 0.5)
    love.graphics.print(text, x + 2, y + 2, 0, scale, scale)

    love.graphics.setColor(color)
    love.graphics.print(text, x, y, 0, scale, scale)
end

function BattleAnimation.isPlaying(state)
    return #state.animations > 0 or #state.damageNumbers > 0
end

function BattleAnimation.clear(state)
    state.animations = {}
    state.damageNumbers = {}
end

return BattleAnimation
