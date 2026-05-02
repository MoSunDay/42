local BattleLog = {}

function BattleLog.create()
    return {
        messages = {},
        maxMessages = 1000,
        scrollOffset = 0,
    }
end

function BattleLog.add(state, message)
    table.insert(state.messages, 1, message)

    while #state.messages > state.maxMessages do
        table.remove(state.messages)
    end
end

function BattleLog.getMessages(state)
    return state.messages
end

function BattleLog.clear(state)
    state.messages = {}
    state.scrollOffset = 0
end

function BattleLog.getScrollOffset(state)
    return state.scrollOffset
end

function BattleLog.setScrollOffset(state, offset)
    state.scrollOffset = offset
end

function BattleLog.scroll(state, delta)
    state.scrollOffset = state.scrollOffset + delta
end

return BattleLog
