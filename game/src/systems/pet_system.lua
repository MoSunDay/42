local AnimationManager = require("src.animations.animation_manager")

local PetSystem = {}

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
    return {
        activePet = nil,
        animationManager = nil,
    }
end

function PetSystem.setAnimationManager(state, animManager)
    state.animationManager = animManager
end

function PetSystem.summon(state, petId)
    local template = PET_DATABASE[petId]
    if not template then
        print("Warning: Unknown pet: " .. tostring(petId))
        return false
    end
    
    state.activePet = {
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
    
    if state.animationManager then
        AnimationManager.createAnimationSet(state.animationManager, state.activePet.animationId)
    end
    
    print("Summoned: " .. state.activePet.name)
    return true
end

function PetSystem.dismiss(state)
    if state.activePet then
        if state.animationManager then
            AnimationManager.removeEntity(state.animationManager, state.activePet.animationId)
        end
        print("Dismissed: " .. state.activePet.name)
        state.activePet = nil
    end
end

function PetSystem.getActivePet(state)
    return state.activePet
end

function PetSystem.hasPet(state)
    return state.activePet ~= nil
end

function PetSystem.takeDamage(state, damage)
    if not state.activePet then
        return 0
    end

    local defPercent = math.min(50, math.floor(state.activePet.defense / 5))
    if state.activePet.isDefending then
        defPercent = defPercent + 25
    end
    defPercent = math.min(75, defPercent)

    local actualDamage = math.floor(damage * (100 - defPercent) / 100)
    actualDamage = math.max(1, actualDamage)
    state.activePet.hp = state.activePet.hp - actualDamage

    if state.activePet.hp < 0 then
        state.activePet.hp = 0
    end

    return actualDamage
end

function PetSystem.calculateDamage(state)
    if not state.activePet then
        return 0, false
    end

    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    local damage = math.floor(state.activePet.attack * multiplier)

    local isCrit = math.random(100) <= 5
    if isCrit then
        damage = math.floor(damage * 1.5)
    end

    return damage, isCrit
end

function PetSystem.isAlive(state)
    return state.activePet and state.activePet.hp > 0
end

function PetSystem.heal(state, amount)
    if state.activePet then
        state.activePet.hp = math.min(state.activePet.maxHp, state.activePet.hp + amount)
    end
end

function PetSystem.getHPPercent(state)
    if not state.activePet then
        return 0
    end
    return state.activePet.hp / state.activePet.maxHp
end

function PetSystem.update(state, dt)
    if state.activePet and state.animationManager then
        AnimationManager.updateEntity(state.animationManager, state.activePet.animationId, dt, false)
    end
end

function PetSystem.getAllPets()
    return PET_DATABASE
end

function PetSystem.getPetData(petId)
    return PET_DATABASE[petId]
end

function PetSystem.serialize(state)
    if not state.activePet then
        return nil
    end
    
    return {
        id = state.activePet.id,
        hp = state.activePet.hp
    }
end

function PetSystem.deserialize(state, data)
    if not data then
        return
    end
    
    PetSystem.summon(state, data.id)
    if state.activePet and data.hp then
        state.activePet.hp = data.hp
    end
end

return PetSystem
