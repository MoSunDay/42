-- party_system.lua - Party/Team system
-- Manage party members (max 5 members)

local PartySystem = {}
PartySystem.__index = PartySystem

-- Party constants
local MAX_PARTY_SIZE = 5

function PartySystem.new()
    local self = setmetatable({}, PartySystem)
    
    -- Party members (array of player data)
    self.members = {}
    
    -- Party leader (index in members array)
    self.leaderIndex = 1
    
    -- Party name
    self.partyName = "Party"
    
    return self
end

-- Add a member to the party
function PartySystem:addMember(memberData)
    if #self.members >= MAX_PARTY_SIZE then
        print("Party is full! Maximum " .. MAX_PARTY_SIZE .. " members.")
        return false
    end
    
    -- Check if member already in party
    for _, member in ipairs(self.members) do
        if member.id == memberData.id then
            print("Member already in party: " .. memberData.name)
            return false
        end
    end
    
    table.insert(self.members, memberData)
    print("Added to party: " .. memberData.name)
    
    -- If this is the first member, make them leader
    if #self.members == 1 then
        self.leaderIndex = 1
    end
    
    return true
end

-- Remove a member from the party
function PartySystem:removeMember(memberId)
    for i, member in ipairs(self.members) do
        if member.id == memberId then
            local removedMember = table.remove(self.members, i)
            print("Removed from party: " .. removedMember.name)
            
            -- Adjust leader index if needed
            if i == self.leaderIndex then
                self.leaderIndex = 1
            elseif i < self.leaderIndex then
                self.leaderIndex = self.leaderIndex - 1
            end
            
            return true
        end
    end
    
    print("Member not found in party")
    return false
end

-- Set party leader
function PartySystem:setLeader(memberIndex)
    if memberIndex >= 1 and memberIndex <= #self.members then
        self.leaderIndex = memberIndex
        print("New party leader: " .. self.members[memberIndex].name)
        return true
    end
    return false
end

-- Get party leader
function PartySystem:getLeader()
    if #self.members > 0 and self.leaderIndex <= #self.members then
        return self.members[self.leaderIndex]
    end
    return nil
end

-- Get all party members
function PartySystem:getMembers()
    return self.members
end

-- Get party size
function PartySystem:getSize()
    return #self.members
end

-- Check if party is full
function PartySystem:isFull()
    return #self.members >= MAX_PARTY_SIZE
end

-- Check if party is empty
function PartySystem:isEmpty()
    return #self.members == 0
end

-- Get member by ID
function PartySystem:getMember(memberId)
    for _, member in ipairs(self.members) do
        if member.id == memberId then
            return member
        end
    end
    return nil
end

-- Clear all members
function PartySystem:clear()
    self.members = {}
    self.leaderIndex = 1
    print("Party cleared")
end

-- Set party name
function PartySystem:setPartyName(name)
    self.partyName = name
end

-- Get party name
function PartySystem:getPartyName()
    return self.partyName
end

-- Get max party size
function PartySystem.getMaxSize()
    return MAX_PARTY_SIZE
end

-- Create member data structure
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

