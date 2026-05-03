local PartySystem = {}

local MAX_PARTY_SIZE = 5

function PartySystem.create()
    return setmetatable({
        members = {},
        leaderIndex = 1,
        partyName = "Party",
    }, { __index = PartySystem })
end

function PartySystem.add_member(state, memberData)
    if #state.members >= MAX_PARTY_SIZE then
        return false
    end
    
    for _, member in ipairs(state.members) do
        if member.id == memberData.id then
            return false
        end
    end
    
    table.insert(state.members, memberData)
    
    if #state.members == 1 then
        state.leaderIndex = 1
    end
    
    return true
end

function PartySystem.remove_member(state, memberId)
    for i, member in ipairs(state.members) do
        if member.id == memberId then
            local removedMember = table.remove(state.members, i)
            
            if i == state.leaderIndex then
                state.leaderIndex = 1
            elseif i < state.leaderIndex then
                state.leaderIndex = state.leaderIndex - 1
            end
            
            return true
        end
    end
    
    return false
end

function PartySystem.set_leader(state, memberIndex)
    if memberIndex >= 1 and memberIndex <= #state.members then
        state.leaderIndex = memberIndex
        return true
    end
    return false
end

function PartySystem.get_leader(state)
    if #state.members > 0 and state.leaderIndex <= #state.members then
        return state.members[state.leaderIndex]
    end
    return nil
end

function PartySystem.get_members(state)
    return state.members
end

function PartySystem.get_size(state)
    return #state.members
end

function PartySystem.isFull(state)
    return #state.members >= MAX_PARTY_SIZE
end

function PartySystem.isEmpty(state)
    return #state.members == 0
end

function PartySystem.get_member(state, memberId)
    for _, member in ipairs(state.members) do
        if member.id == memberId then
            return member
        end
    end
    return nil
end

function PartySystem.clear(state)
    state.members = {}
    state.leaderIndex = 1
end

function PartySystem.set_party_name(state, name)
    state.partyName = name
end

function PartySystem.get_party_name(state)
    return state.partyName
end

function PartySystem.get_max_size()
    return MAX_PARTY_SIZE
end

function PartySystem.create_member_data(id, name, hp, maxHp, avatarColor)
    return {
        id = id,
        name = name,
        hp = hp or 100,
        maxHp = maxHp or 100,
        avatarColor = avatarColor or {0.2, 0.6, 1.0},
        isOnline = true
    }
end

PartySystem.addMember = PartySystem.add_member
PartySystem.setPartyName = PartySystem.set_party_name

return PartySystem
