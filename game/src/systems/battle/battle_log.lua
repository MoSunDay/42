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

function BattleLog.get_messages(state)
    return state.messages
end

function BattleLog.clear(state)
    state.messages = {}
    state.scrollOffset = 0
end

function BattleLog.get_scroll_offset(state)
    return state.scrollOffset
end

function BattleLog.set_scroll_offset(state, offset)
    state.scrollOffset = offset
end

function BattleLog.scroll(state, delta)
    state.scrollOffset = state.scrollOffset + delta
end

return BattleLog
