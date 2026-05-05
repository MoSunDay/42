local BattleAnimation = {}

function BattleAnimation.create()
    return {
        animations = {},
        damageNumbers = {},
        effectSprites = {},
        spells = {},
    }
end

function BattleAnimation.add_attack_animation(state, fromX, fromY, toX, toY, callback)
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

function BattleAnimation.add_damage_number(state, x, y, damage, isPlayer, hitType)
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

function BattleAnimation.add_hit_flash(state, x, y)
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

function BattleAnimation.add_heal_animation(state, x, y)
    local spell = {
        type = "heal",
        x = x,
        y = y,
        alpha = 1.0,
        scale = 0.5,
        duration = 0.8,
        timer = 0
    }
    table.insert(state.spells, spell)
end

function BattleAnimation.add_buff_animation(state, x, y)
    local spell = {
        type = "buff",
        x = x,
        y = y,
        alpha = 1.0,
        scale = 0.5,
        duration = 0.6,
        timer = 0
    }
    table.insert(state.spells, spell)
end

function BattleAnimation.add_debuff_animation(state, x, y)
    local spell = {
        type = "debuff",
        x = x,
        y = y,
        alpha = 1.0,
        scale = 0.5,
        duration = 0.6,
        timer = 0
    }
    table.insert(state.spells, spell)
end

function BattleAnimation.add_attack_animation(state, fromX, fromY, toX, toY, callback)
    local anim = {
        type = "attack",
        fromX = fromX,
        fromY = fromY,
        toX = toX,
        toY = toY,
        progress = 0,
        duration = 0.3,
        callback = callback,
        impacted = false
    }
    table.insert(state.animations, anim)
end

function BattleAnimation.add_damage_number(state, x, y, damage, isPlayer, hitType)
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

function BattleAnimation.add_hit_flash(state, x, y)
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

function BattleAnimation.add_effect_sprite(state, x, y, effectName, size, duration)
    local effect = {
        x = x,
        y = y,
        imageName = effectName,
        alpha = 1.0,
        timer = 0,
        duration = duration or 0.5,
        scale = size / 1
    }
    table.insert(state.effectSprites, effect)
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

    for i = #state.effectSprites, 1, -1 do
        local eff = state.effectSprites[i]
        eff.timer = eff.timer + dt
        eff.alpha = 1 - (eff.timer / eff.duration)
        if eff.timer >= eff.duration then
            table.remove(state.effectSprites, i)
        end
    end
end

function BattleAnimation.draw(state, assetManager)
    for _, anim in ipairs(state.animations) do
        if anim.type == "attack" then
            BattleAnimation.draw_attack_line(state, anim, assetManager)
        elseif anim.type == "flash" then
            BattleAnimation.draw_flash(state, anim, assetManager)
        end
    end

    for _, dmg in ipairs(state.damageNumbers) do
        BattleAnimation.draw_damage_number(state, dmg, assetManager)
    end

    for _, eff in ipairs(state.effectSprites) do
        BattleAnimation.draw_effect(state, eff, assetManager)
    end
end

function BattleAnimation.draw_effect(state, eff, assetManager)
    local img = assetManager and assetManager:get_effect(eff.imageName)
    if not img then return end

    local iw, ih = img:getWidth(), img:getHeight()
    local s = math.max(1, math.min(2, 1 + eff.timer * 2))
    local drawW = iw * s
    local drawH = ih * s

    love.graphics.setColor(1, 1, 1, eff.alpha)
    love.graphics.draw(img, eff.x - drawW / 2, eff.y - drawH / 2, 0, s, s)
end

function BattleAnimation.draw_attack_line(state, anim, assetManager)
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

    if t > 0.75 and not anim.impacted then
        anim.impacted = true
        local slashImg = assetManager and assetManager:get_effect("effect_attack_slash")
        if slashImg then
            local iw, ih = slashImg:getWidth(), slashImg:getHeight()
            local s = 1.5
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.draw(slashImg, anim.toX - iw * s / 2, anim.toY - ih * s / 2, 0, s, s)
        end
    end
end

function BattleAnimation.draw_flash(state, flash, assetManager)
    local impactImg = assetManager and assetManager:get_effect("effect_attack_impact")
    if impactImg then
        local iw, ih = impactImg:getWidth(), impactImg:getHeight()
        local s = flash.radius / 30
        love.graphics.setColor(1, 1, 1, flash.alpha)
        love.graphics.draw(impactImg, flash.x - iw * s / 2, flash.y - ih * s / 2, 0, s, s)
    else
        love.graphics.setColor(1, 1, 1, flash.alpha * 0.8)
        love.graphics.circle("fill", flash.x, flash.y, flash.radius)
        love.graphics.setColor(1, 0.5, 0, flash.alpha * 0.5)
        love.graphics.circle("line", flash.x, flash.y, flash.radius)
    end
end

function BattleAnimation.draw_damage_number(state, dmg, assetManager)
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

        local critImg = assetManager and assetManager:get_effect("effect_critical")
        if critImg then
            local iw, ih = critImg:getWidth(), critImg:getHeight()
            local s = 1.2
            love.graphics.setColor(1, 1, 1, dmg.alpha * 0.6)
            love.graphics.draw(critImg, x - iw * s / 2, y - ih * s / 2, 0, s, s)
        end
    elseif dmg.hitType == "heal" then
        text = "+" .. tostring(dmg.damage)
        color = {0.2, 0.95, 0.3, dmg.alpha}
        scale = 1.3

        local healImg = assetManager and assetManager:get_effect("effect_heal")
        if healImg then
            local iw, ih = healImg:getWidth(), healImg:getHeight()
            local s = 1.0
            love.graphics.setColor(1, 1, 1, dmg.alpha * 0.5)
            love.graphics.draw(healImg, x - iw * s / 2, y - ih * s / 2 + 10, 0, s, s)
        end
    else
        text = tostring(dmg.damage)
        if dmg.isPlayer then
            color = {1, 0.4, 0.4, dmg.alpha}
        else
            color = {1, 1, 1, dmg.alpha}
        end
        scale = 1.2

        local hitImg = assetManager and assetManager:get_effect("effect_hit")
        if hitImg then
            local iw, ih = hitImg:getWidth(), hitImg:getHeight()
            local s = 0.8
            love.graphics.setColor(1, 1, 1, dmg.alpha * 0.6)
            love.graphics.draw(hitImg, x - iw * s / 2, y - ih * s / 2 + 10, 0, s, s)
        end
    end

    love.graphics.setColor(0, 0, 0, dmg.alpha * 0.5)
    love.graphics.print(text, x + 2, y + 2, 0, scale, scale)

    love.graphics.setColor(color)
    love.graphics.print(text, x, y, 0, scale, scale)
end

function BattleAnimation.is_playing(state)
    return #state.animations > 0 or #state.damageNumbers > 0 or #state.effectSprites > 0
end

function BattleAnimation.clear(state)
    state.animations = {}
    state.damageNumbers = {}
    state.effectSprites = {}
end

return BattleAnimation
