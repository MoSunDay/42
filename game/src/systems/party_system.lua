local PartySystem = {}

local MAX_PARTY_SIZE = 5

function PartySystem.new()
    return {
        members = {},
        leaderIndex = 1,
        partyName = "Party",
    }
end

function PartySystem.addMember(state, memberData)
    if #state.members >= MAX_PARTY_SIZE then
        print("Party is full! Maximum " .. MAX_PARTY_SIZE .. " members.")
        return false
    end
    
    for _, member in ipairs(state.members) do
        if member.id == memberData.id then
            print("Member already in party: " .. memberData.name)
            return false
        end
    end
    
    table.insert(state.members, memberData)
    print("Added to party: " .. memberData.name)
    
    if #state.members == 1 then
        state.leaderIndex = 1
    end
    
    return true
end

function PartySystem.removeMember(state, memberId)
    for i, member in ipairs(state.members) do
        if member.id == memberId then
            local removedMember = table.remove(state.members, i)
            print("Removed from party: " .. removedMember.name)
            
            if i == state.leaderIndex then
                state.leaderIndex = 1
            elseif i < state.leaderIndex then
                state.leaderIndex = state.leaderIndex - 1
            end
            
            return true
        end
    end
    
    print("Member not found in party")
    return false
end

function PartySystem.setLeader(state, memberIndex)
    if memberIndex >= 1 and memberIndex <= #state.members then
        state.leaderIndex = memberIndex
        print("New party leader: " .. state.members[memberIndex].name)
        return true
    end
    return false
end

function PartySystem.getLeader(state)
    if #state.members > 0 and state.leaderIndex <= #state.members then
        return state.members[state.leaderIndex]
    end
    return nil
end

function PartySystem.getMembers(state)
    return state.members
end

function PartySystem.getSize(state)
    return #state.members
end

function PartySystem.isFull(state)
    return #state.members >= MAX_PARTY_SIZE
end

function PartySystem.isEmpty(state)
    return #state.members == 0
end

function PartySystem.getMember(state, memberId)
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
    print("Party cleared")
end

function PartySystem.setPartyName(state, name)
    state.partyName = name
end

function PartySystem.getPartyName(state)
    return state.partyName
end

function PartySystem.getMaxSize()
    return MAX_PARTY_SIZE
end

function PartySystem.createMemberData(id, name, hp, maxHp, avatarColor)
    return {
        id = id,
        name = name,
        hp = hp or 100,
        maxHp = maxHp or 100,
        avatarColor = avatarColor or {0.2, 0.6, 1.0},
        isOnline = true
    }
end

return PartySystem
