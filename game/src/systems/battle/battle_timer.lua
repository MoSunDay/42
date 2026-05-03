local BattleTimer = {}

function BattleTimer.create(maxTime)
    local mt = maxTime or 90.0
    return {
        maxTime = mt,
        currentTime = mt,
        autoTriggeredByTimeout = false,
    }
end

function BattleTimer.reset(state)
    state.currentTime = state.maxTime
    state.autoTriggeredByTimeout = false
end

function BattleTimer.update(state, dt)
    if state.currentTime > 0 then
        state.currentTime = state.currentTime - dt
        return state.currentTime <= 0
    end
    return false
end

function BattleTimer.get_time(state)
    return state.currentTime
end

function BattleTimer.get_max_time(state)
    return state.maxTime
end

function BattleTimer.set_auto_triggered(state, value)
    state.autoTriggeredByTimeout = value
end

function BattleTimer.is_auto_triggered(state)
    return state.autoTriggeredByTimeout
end

return BattleTimer
