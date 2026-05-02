local BreathingEffect = {}

function BreathingEffect.create()
    return {
        time = 0,
        breathSpeed = 1.5,
        breathAmount = 0.05
    }
end

function BreathingEffect.update(state, dt)
    state.time = state.time + dt
end

function BreathingEffect.getScale(state)
    local breathCycle = math.sin(state.time * math.pi * 2 / state.breathSpeed)
    return 1.0 + breathCycle * state.breathAmount
end

function BreathingEffect.reset(state)
    state.time = 0
end

function BreathingEffect.setSpeed(state, speed)
    state.breathSpeed = speed
end

function BreathingEffect.setAmount(state, amount)
    state.breathAmount = amount
end

return BreathingEffect
