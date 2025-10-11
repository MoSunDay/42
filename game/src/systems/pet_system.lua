-- pet_system.lua - Pet companion system
-- Pets fight alongside the player in battle

local PetSystem = {}
PetSystem.__index = PetSystem

-- Pet database
local PET_DATABASE = {
    slime_pet = {
        id = "slime_pet",
        name = "Baby Slime",
        hp = 50,
        maxHp = 50,
        attack = 8,
        defense = 3,
        speed = 4,
        color = {0.3, 0.9, 0.4},
        size = 15,
        description = "A cute baby slime"
    },
    wolf_pup = {
        id = "wolf_pup",
        name = "Wolf Pup",
        hp = 60,
        maxHp = 60,
        attack = 12,
        defense = 4,
        speed = 6,
        color = {0.6, 0.6, 0.6},
        size = 16,
        description = "A loyal wolf companion"
    },
    dragon_hatchling = {
        id = "dragon_hatchling",
        name = "Dragon Hatchling",
        hp = 80,
        maxHp = 80,
        attack = 15,
        defense = 6,
        speed = 5,
        color = {0.9, 0.3, 0.3},
        size = 18,
        description = "A rare dragon baby"
    }
}

function PetSystem.new()
    local self = setmetatable({}, PetSystem)
    
    self.activePet = nil
    self.animationManager = nil
    
    return self
end

-- Set animation manager
function PetSystem:setAnimationManager(animManager)
    self.animationManager = animManager
end

-- Summon a pet
function PetSystem:summon(petId)
    local template = PET_DATABASE[petId]
    if not template then
        print("Warning: Unknown pet: " .. tostring(petId))
        return false
    end
    
    self.activePet = {
        id = template.id,
        name = template.name,
        hp = template.hp,
        maxHp = template.maxHp,
        attack = template.attack,
        defense = template.defense,
        speed = template.speed,
        color = template.color,
        size = template.size,
        description = template.description,
        isDefending = false,
        animationId = "pet"
    }
    
    -- Setup animation
    if self.animationManager then
        self.animationManager:createAnimationSet(self.activePet.animationId)
    end
    
    print("Summoned: " .. self.activePet.name)
    return true
end

-- Dismiss current pet
function PetSystem:dismiss()
    if self.activePet then
        if self.animationManager then
            self.animationManager:removeEntity(self.activePet.animationId)
        end
        print("Dismissed: " .. self.activePet.name)
        self.activePet = nil
    end
end

-- Get active pet
function PetSystem:getActivePet()
    return self.activePet
end

-- Check if pet is active
function PetSystem:hasPet()
    return self.activePet ~= nil
end

-- Pet takes damage
function PetSystem:takeDamage(damage)
    if not self.activePet then
        return 0
    end
    
    local defense = self.activePet.isDefending and self.activePet.defense * 2 or self.activePet.defense
    local actualDamage = math.max(1, damage - defense)
    self.activePet.hp = self.activePet.hp - actualDamage
    
    if self.activePet.hp < 0 then
        self.activePet.hp = 0
    end
    
    return actualDamage
end

-- Pet attacks
function PetSystem:calculateDamage()
    if not self.activePet then
        return 0
    end
    
    return self.activePet.attack + math.random(-2, 2)
end

-- Check if pet is alive
function PetSystem:isAlive()
    return self.activePet and self.activePet.hp > 0
end

-- Heal pet
function PetSystem:heal(amount)
    if self.activePet then
        self.activePet.hp = math.min(self.activePet.maxHp, self.activePet.hp + amount)
    end
end

-- Get HP percentage
function PetSystem:getHPPercent()
    if not self.activePet then
        return 0
    end
    return self.activePet.hp / self.activePet.maxHp
end

-- Update pet animation
function PetSystem:update(dt)
    if self.activePet and self.animationManager then
        self.animationManager:updateEntity(self.activePet.animationId, dt, false)
    end
end

-- Get all available pets
function PetSystem.getAllPets()
    return PET_DATABASE
end

-- Get pet data
function PetSystem.getPetData(petId)
    return PET_DATABASE[petId]
end

-- Serialize for saving
function PetSystem:serialize()
    if not self.activePet then
        return nil
    end
    
    return {
        id = self.activePet.id,
        hp = self.activePet.hp
    }
end

-- Deserialize from saved data
function PetSystem:deserialize(data)
    if not data then
        return
    end
    
    self:summon(data.id)
    if self.activePet and data.hp then
        self.activePet.hp = data.hp
    end
end

return PetSystem

