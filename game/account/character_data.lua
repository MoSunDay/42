local ClassDatabase = require("src.data.class_database")
local SkillSystem = require("src.systems.skill_system")

local CharacterData = {}

function CharacterData.create(config)
    local state = {
        username = config.username or "Player",
        characterName = config.characterName or "Hero",
        classId = config.classId or "dual_blade",
    }
    
    local baseStats = ClassDatabase.get_base_stats(state.classId)
    
    state.hp = config.hp or baseStats.hp
    state.maxHp = config.maxHp or baseStats.maxHp
    state.mp = config.mp or baseStats.mp
    state.maxMp = config.maxMp or baseStats.maxMp
    state.attack = config.attack or baseStats.attack
    state.defense = config.defense or baseStats.defense
    state.speed = config.speed or baseStats.speed
    state.magicAttack = config.magicAttack or baseStats.magicAttack
    state.critBonus = config.critBonus or baseStats.critBonus or 0
    
    state.x = config.x or 1600
    state.y = config.y or 1600
    state.mapId = config.mapId or "newbie_village"
    
    state.avatarColor = config.avatarColor or {0.3, 0.5, 1.0}
    state.appearanceId = config.appearanceId or "blue_hero"
    
    state.inventory = config.inventory or {}
    state.quests = config.quests or {}
    
    state.skills = config.skills or {}
    state.skillCrystals = config.skillCrystals or 0
    
    if not config.skills or #config.skills == 0 then
        SkillSystem.initPlayerSkills(state, state.classId)
    end
    
    return state
end

CharacterData.new = CharacterData.create

function CharacterData.to_table(state)
    return {
        username = state.username,
        characterName = state.characterName,
        classId = state.classId,
        hp = state.hp,
        maxHp = state.maxHp,
        mp = state.mp,
        maxMp = state.maxMp,
        attack = state.attack,
        defense = state.defense,
        speed = state.speed,
        magicAttack = state.magicAttack,
        critBonus = state.critBonus,
        x = state.x,
        y = state.y,
        mapId = state.mapId,
        avatarColor = state.avatarColor,
        appearanceId = state.appearanceId,
        inventory = state.inventory,
        quests = state.quests,
        skills = state.skills,
        skillCrystals = state.skillCrystals,
    }
end

function CharacterData.take_damage(state, damage)
    local actualDamage = math.max(1, damage - state.defense)
    state.hp = math.max(0, state.hp - actualDamage)
    return actualDamage
end

function CharacterData.heal(state, amount)
    state.hp = math.min(state.maxHp, state.hp + amount)
end

function CharacterData.heal_percent(state, percent)
    local amount = math.floor(state.maxHp * percent)
    CharacterData.heal(state, amount)
    return amount
end

function CharacterData.restore_mp(state, amount)
    state.mp = math.min(state.maxMp, state.mp + amount)
end

function CharacterData.use_mp(state, amount)
    if state.mp >= amount then
        state.mp = state.mp - amount
        return true
    end
    return false
end

function CharacterData.is_alive(state)
    return state.hp > 0
end

function CharacterData.get_class(state)
    return ClassDatabase.get_class(state.classId)
end

function CharacterData.get_class_name(state)
    local class = CharacterData.get_class(state)
    return class and class.name or "未知"
end

function CharacterData.create_character(name, classId)
    classId = classId or "dual_blade"
    
    return CharacterData.create({
        characterName = name,
        classId = classId,
    })
end

function CharacterData.from_table(data)
    return CharacterData.create(data)
end

return CharacterData
