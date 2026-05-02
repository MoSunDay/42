local Animation = {}

Animation.tweens = {}
Animation.time = 0

local EASING = {
    linear = function(t) return t end,
    easeIn = function(t) return t * t end,
    easeOut = function(t) return t * (2 - t) end,
    easeInOut = function(t) return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t end,
    bounce = function(t)
        if t < 1 / 2.75 then
            return 7.5625 * t * t
        elseif t < 2 / 2.75 then
            t = t - 1.5 / 2.75
            return 7.5625 * t * t + 0.75
        elseif t < 2.5 / 2.75 then
            t = t - 2.25 / 2.75
            return 7.5625 * t * t + 0.9375
        else
            t = t - 2.625 / 2.75
            return 7.5625 * t * t + 0.984375
        end
    end,
    elastic = function(t)
        if t == 0 or t == 1 then return t end
        return -math.pow(2, 10 * (t - 1)) * math.sin((t - 1.1) * 5 * math.pi)
    end,
    back = function(t)
        local s = 1.70158
        return t * t * ((s + 1) * t - s)
    end
}

function Animation.tween(target, props, duration, easingName, onComplete)
    local tween = {
        target = target,
        startValues = {},
        endValues = {},
        duration = duration or 0.3,
        elapsed = 0,
        easing = EASING[easingName] or EASING.easeOut,
        onComplete = onComplete,
        active = true
    }

    for k, v in pairs(props) do
        tween.startValues[k] = target[k] or 0
        tween.endValues[k] = v
    end

    table.insert(Animation.tweens, tween)
    return tween
end

function Animation.update(dt)
    Animation.time = Animation.time + dt

    local i = 1
    while i <= #Animation.tweens do
        local tw = Animation.tweens[i]
        if tw.active then
            tw.elapsed = tw.elapsed + dt
            local progress = math.min(tw.elapsed / tw.duration, 1)
            local easedProgress = tw.easing(progress)

            for k, endVal in pairs(tw.endValues) do
                local startVal = tw.startValues[k]
                tw.target[k] = startVal + (endVal - startVal) * easedProgress
            end

            if progress >= 1 then
                tw.active = false
                if tw.onComplete then
                    tw.onComplete()
                end
                table.remove(Animation.tweens, i)
            else
                i = i + 1
            end
        else
            table.remove(Animation.tweens, i)
        end
    end
end

function Animation.cancelAll()
    Animation.tweens = {}
end

function Animation.createPanelState()
    return {
        alpha = 0,
        scaleX = 0.9,
        scaleY = 0.9,
        offsetY = 10,
        glowAlpha = 0
    }
end

function Animation.animatePanelIn(state, onComplete)
    Animation.cancelByTarget(state)
    state.alpha = 0
    state.scaleX = 0.9
    state.scaleY = 0.9
    state.offsetY = 10
    Animation.tween(state, { alpha = 1, scaleX = 1, scaleY = 1, offsetY = 0 }, 0.25, "easeOut", onComplete)
    Animation.tween(state, { glowAlpha = 0.4 }, 0.15, "easeOut")
    Animation.tween(state, { glowAlpha = 0 }, 0.4, "easeIn")
end

function Animation.animatePanelOut(state, onComplete)
    Animation.cancelByTarget(state)
    Animation.tween(state, { alpha = 0, scaleX = 0.95, scaleY = 0.95, offsetY = 5 }, 0.2, "easeIn", onComplete)
end

function Animation.cancelByTarget(target)
    local i = 1
    while i <= #Animation.tweens do
        if Animation.tweens[i].target == target then
            table.remove(Animation.tweens, i)
        else
            i = i + 1
        end
    end
end

function Animation.createPulseState(speed)
    return {
        time = 0,
        speed = speed or 3,
        value = 0
    }
end

function Animation.updatePulse(state, dt)
    state.time = state.time + dt * state.speed
    state.value = (math.sin(state.time) + 1) / 2
end

function Animation.createDelayedCall(delay, callback)
    local state = { elapsed = 0, delay = delay, callback = callback, active = true }
    Animation.tween(state, { elapsed = delay }, delay, "linear", function()
        if callback then callback() end
    end)
    return state
end

return Animation
