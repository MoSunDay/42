local ClassDatabase = require("src.data.class_database")
local SkillSystem = require("src.systems.skill_system")

local CharacterData = {}
CharacterData.__index = CharacterData

function CharacterData.new(config)
    local self = setmetatable({}, CharacterData)
    
    self.username = config.username or "Player"
    self.characterName = config.characterName or "Hero"
    self.classId = config.classId or "dual_blade"
    
    local baseStats = ClassDatabase.getBaseStats(self.classId)
    
    self.hp = config.hp or baseStats.hp
    self.maxHp = config.maxHp or baseStats.maxHp
    self.mp = config.mp or baseStats.mp
    self.maxMp = config.maxMp or baseStats.maxMp
    self.attack = config.attack or baseStats.attack
    self.defense = config.defense or baseStats.defense
    self.speed = config.speed or baseStats.speed
    self.magicAttack = config.magicAttack or baseStats.magicAttack
    self.critBonus = config.critBonus or baseStats.critBonus or 0
    
    self.x = config.x or 1600
    self.y = config.y or 1600
    self.mapId = config.mapId or "newbie_village"
    
    self.avatarColor = config.avatarColor or {0.3, 0.5, 1.0}
    self.appearanceId = config.appearanceId or "blue_hero"
    
    self.inventory = config.inventory or {}
    self.quests = config.quests or {}
    
    self.skills = config.skills or {}
    self.skillCrystals = config.skillCrystals or 0
    
    if not config.skills or #config.skills == 0 then
        SkillSystem.initPlayerSkills(self, self.classId)
    end
    
    return self
end

function CharacterData:toTable()
    return {
        username = self.username,
        characterName = self.characterName,
        classId = self.classId,
        hp = self.hp,
        maxHp = self.maxHp,
        mp = self.mp,
        maxMp = self.maxMp,
        attack = self.attack,
        defense = self.defense,
        speed = self.speed,
        magicAttack = self.magicAttack,
        critBonus = self.critBonus,
        x = self.x,
        y = self.y,
        mapId = self.mapId,
        avatarColor = self.avatarColor,
        appearanceId = self.appearanceId,
        inventory = self.inventory,
        quests = self.quests,
        skills = self.skills,
        skillCrystals = self.skillCrystals,
    }
end

function CharacterData:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.defense)
    self.hp = math.max(0, self.hp - actualDamage)
    return actualDamage
end

function CharacterData:heal(amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

function CharacterData:healPercent(percent)
    local amount = math.floor(self.maxHp * percent)
    self:heal(amount)
    return amount
end

function CharacterData:restoreMp(amount)
    self.mp = math.min(self.maxMp, self.mp + amount)
end

function CharacterData:useMp(amount)
    if self.mp >= amount then
        self.mp = self.mp - amount
        return true
    end
    return false
end

function CharacterData:isAlive()
    return self.hp > 0
end

function CharacterData:getClass()
    return ClassDatabase.getClass(self.classId)
end

function CharacterData:getClassName()
    local class = self:getClass()
    return class and class.name or "未知"
end

function CharacterData.createCharacter(name, classId)
    classId = classId or "dual_blade"
    
    return CharacterData.new({
        characterName = name,
        classId = classId,
    })
end

function CharacterData.fromTable(data)
    return CharacterData.new(data)
end

return CharacterData
