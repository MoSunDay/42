-- character_data.lua - Character data structure
-- 角色数据结构

local CharacterData = {}
CharacterData.__index = CharacterData

-- Create new character
function CharacterData.new(config)
    local self = setmetatable({}, CharacterData)
    
    -- Basic info
    self.username = config.username or "Player"
    self.characterName = config.characterName or "Hero"
    self.gold = config.gold or 100
    
    -- Combat stats (气血、防御、攻击)
    self.hp = config.hp or 100
    self.maxHp = config.maxHp or 100
    self.attack = config.attack or 15
    self.defense = config.defense or 5
    self.speed = config.speed or 6
    
    -- Position (safe default spawn point)
    self.x = config.x or 1600
    self.y = config.y or 1600  -- Village center, safe area
    self.mapId = config.mapId or "newbie_village"
    
    -- Avatar (头像颜色)
    self.avatarColor = config.avatarColor or {0.3, 0.5, 1.0}  -- Blue
    
    -- Inventory (future)
    self.inventory = config.inventory or {}
    
    -- Quest progress (future)
    self.quests = config.quests or {}
    
    return self
end

-- Convert to saveable table
function CharacterData:toTable()
    return {
        username = self.username,
        characterName = self.characterName,
        gold = self.gold,
        hp = self.hp,
        maxHp = self.maxHp,
        attack = self.attack,
        defense = self.defense,
        speed = self.speed,
        x = self.x,
        y = self.y,
        mapId = self.mapId,
        avatarColor = self.avatarColor,
        inventory = self.inventory,
        quests = self.quests,
    }
end



-- Gain gold
function CharacterData:gainGold(amount)
    self.gold = self.gold + amount
end

-- Take damage
function CharacterData:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.defense)
    self.hp = math.max(0, self.hp - actualDamage)
    return actualDamage
end

-- Heal
function CharacterData:heal(amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

-- Check if alive
function CharacterData:isAlive()
    return self.hp > 0
end

-- Helper function to create a new character with just a name
function CharacterData.createCharacter(name)
    return CharacterData.new({
        characterName = name,
        gold = 100,
        hp = 100,
        maxHp = 100,
        attack = 15,
        defense = 5,
        speed = 6,
        x = 1600,
        y = 1600,
        mapId = "newbie_village",
        avatarColor = {0.3, 0.5, 1.0}
    })
end

return CharacterData

