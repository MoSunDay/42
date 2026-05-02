local RunningEffect = {}

function RunningEffect.create()
    return {
        time = 0,
        isRunning = false,
        runSpeed = 4.0,
        bobAmount = 3,
        tiltAmount = 0.1
    }
end

function RunningEffect.update(state, dt, isMoving)
    state.isRunning = isMoving

    if state.isRunning then
        state.time = state.time + dt
    else
        if state.time > 0 then
            state.time = state.time - dt * 2
            if state.time < 0 then
                state.time = 0
            end
        end
    end
end

function RunningEffect.getBobOffset(state)
    if state.time <= 0 then
        return 0
    end

    local cycle = math.abs(math.sin(state.time * math.pi * state.runSpeed))
    return -cycle * state.bobAmount
end

function RunningEffect.getTilt(state)
    if state.time <= 0 then
        return 0
    end

    local cycle = math.sin(state.time * math.pi * state.runSpeed)
    return cycle * state.tiltAmount
end

function RunningEffect.getScale(state)
    if state.time <= 0 then
        return 1.0, 1.0
    end

    local cycle = math.abs(math.sin(state.time * math.pi * state.runSpeed))
    local scaleX = 1.0 + cycle * 0.05
    local scaleY = 1.0 - cycle * 0.05

    return scaleX, scaleY
end

function RunningEffect.reset(state)
    state.time = 0
    state.isRunning = false
end

function RunningEffect.isActive(state)
    return state.isRunning
end

return RunningEffect
