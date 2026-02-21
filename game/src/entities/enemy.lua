local Enemy = {}
Enemy.__index = Enemy

local MAX_DEF_PERCENT = 50

local ENEMY_TYPES = {
    slime = {
        name = "史莱姆",
        tier = 1,
        hp = 120, maxHp = 120,
        attack = 12, defense = 3,
        defPercent = 0,
        speed = 3,
        crit = 2, eva = 0,
        gold = 8,
        crystalBonus = 1,
        color = {0.2, 0.8, 0.3}
    },
    goblin = {
        name = "哥布林",
        tier = 1,
        hp = 180, maxHp = 180,
        attack = 18, defense = 5,
        defPercent = 0,
        speed = 5,
        crit = 5, eva = 3,
        gold = 12,
        crystalBonus = 1,
        color = {0.6, 0.4, 0.2}
    },
    skeleton = {
        name = "骷髅兵",
        tier = 1,
        hp = 150, maxHp = 150,
        attack = 22, defense = 4,
        defPercent = 0,
        speed = 4,
        crit = 8, eva = 2,
        gold = 10,
        crystalBonus = 1,
        color = {0.9, 0.9, 0.9}
    },
    bat = {
        name = "蝙蝠",
        tier = 1,
        hp = 80, maxHp = 80,
        attack = 10, defense = 0,
        defPercent = 0,
        speed = 8,
        crit = 3, eva = 12,
        gold = 6,
        crystalBonus = 1,
        color = {0.3, 0.2, 0.4}
    },
    wolf = {
        name = "野狼",
        tier = 1,
        hp = 200, maxHp = 200,
        attack = 25, defense = 6,
        defPercent = 0,
        speed = 7,
        crit = 10, eva = 5,
        gold = 15,
        crystalBonus = 1,
        color = {0.5, 0.5, 0.5}
    },
    
    orc_warrior = {
        name = "兽人战士",
        tier = 2,
        hp = 400, maxHp = 400,
        attack = 30, defense = 12,
        defPercent = 5,
        speed = 4,
        crit = 5, eva = 2,
        gold = 25,
        crystalBonus = 2,
        color = {0.3, 0.6, 0.3}
    },
    skeleton_knight = {
        name = "骷髅骑士",
        tier = 2,
        hp = 320, maxHp = 320,
        attack = 38, defense = 10,
        defPercent = 4,
        speed = 5,
        crit = 12, eva = 3,
        gold = 30,
        crystalBonus = 2,
        color = {0.7, 0.7, 0.8}
    },
    dire_wolf = {
        name = "恐狼",
        tier = 2,
        hp = 280, maxHp = 280,
        attack = 35, defense = 8,
        defPercent = 0,
        speed = 9,
        crit = 15, eva = 10,
        gold = 22,
        crystalBonus = 2,
        color = {0.4, 0.4, 0.5}
    },
    dark_mage = {
        name = "暗黑法师",
        tier = 2,
        hp = 240, maxHp = 240,
        attack = 45, defense = 6,
        defPercent = 0,
        speed = 5,
        crit = 18, eva = 6,
        gold = 35,
        crystalBonus = 2,
        color = {0.4, 0.2, 0.6}
    },
    harpy = {
        name = "鹰身女妖",
        tier = 2,
        hp = 260, maxHp = 260,
        attack = 32, defense = 5,
        defPercent = 0,
        speed = 10,
        crit = 10, eva = 15,
        gold = 28,
        crystalBonus = 2,
        color = {0.8, 0.6, 0.8}
    },
    
    orc_chieftain = {
        name = "兽人酋长",
        tier = 3,
        hp = 800, maxHp = 800,
        attack = 55, defense = 25,
        defPercent = 18,
        speed = 4,
        crit = 8, eva = 3,
        gold = 70,
        crystalBonus = 3,
        multiTarget = true,
        color = {0.2, 0.5, 0.2}
    },
    vampire_lord = {
        name = "吸血鬼领主",
        tier = 3,
        hp = 700, maxHp = 700,
        attack = 65, defense = 18,
        defPercent = 12,
        speed = 8,
        crit = 18, eva = 15,
        gold = 85,
        crystalBonus = 3,
        multiTarget = true,
        color = {0.5, 0.1, 0.2}
    },
    stone_golem = {
        name = "石像巨人",
        tier = 3,
        hp = 1200, maxHp = 1200,
        attack = 45, defense = 40,
        defPercent = 30,
        speed = 2,
        crit = 3, eva = 0,
        gold = 100,
        crystalBonus = 3,
        color = {0.5, 0.5, 0.5}
    },
    demon = {
        name = "恶魔",
        tier = 3,
        hp = 900, maxHp = 900,
        attack = 70, defense = 22,
        defPercent = 15,
        speed = 6,
        crit = 15, eva = 10,
        gold = 120,
        crystalBonus = 3,
        multiTarget = true,
        color = {0.8, 0.2, 0.2}
    },
    elemental = {
        name = "元素使者",
        tier = 3,
        hp = 650, maxHp = 650,
        attack = 60, defense = 15,
        defPercent = 8,
        speed = 7,
        crit = 20, eva = 12,
        gold = 90,
        crystalBonus = 3,
        multiTarget = true,
        color = {0.3, 0.7, 0.9}
    },
    
    ancient_dragon = {
        name = "远古巨龙",
        tier = 4,
        hp = 2000, maxHp = 2000,
        attack = 90, defense = 35,
        defPercent = 35,
        speed = 5,
        crit = 12, eva = 8,
        gold = 200,
        crystalBonus = 5,
        multiTarget = true,
        boss = true,
        color = {0.8, 0.5, 0.1}
    },
    lich_king = {
        name = "巫妖王",
        tier = 4,
        hp = 1600, maxHp = 1600,
        attack = 100, defense = 28,
        defPercent = 25,
        speed = 6,
        crit = 25, eva = 12,
        gold = 250,
        crystalBonus = 5,
        multiTarget = true,
        boss = true,
        color = {0.2, 0.1, 0.3}
    },
    chaos_serpent = {
        name = "混沌巨蛇",
        tier = 4,
        hp = 1800, maxHp = 1800,
        attack = 85, defense = 32,
        defPercent = 28,
        speed = 9,
        crit = 18, eva = 18,
        gold = 220,
        crystalBonus = 5,
        multiTarget = true,
        boss = true,
        color = {0.5, 0.1, 0.5}
    },
    titan = {
        name = "泰坦",
        tier = 4,
        hp = 2500, maxHp = 2500,
        attack = 75, defense = 50,
        defPercent = 40,
        speed = 3,
        crit = 5, eva = 0,
        gold = 280,
        crystalBonus = 5,
        multiTarget = true,
        boss = true,
        color = {0.9, 0.8, 0.6}
    }
}

local TIER_SPAWN_WEIGHTS = {55, 28, 13, 4}

local TYPES_BY_TIER = {
    [1] = {"slime", "goblin", "skeleton", "bat", "wolf"},
    [2] = {"orc_warrior", "skeleton_knight", "dire_wolf", "dark_mage", "harpy"},
    [3] = {"orc_chieftain", "vampire_lord", "stone_golem", "demon", "elemental"},
    [4] = {"ancient_dragon", "lich_king", "chaos_serpent", "titan"}
}

function Enemy.new(enemyType, assetManager)
    local self = setmetatable({}, Enemy)
    
    local template = ENEMY_TYPES[enemyType] or ENEMY_TYPES.slime
    
    self.type = enemyType
    self.name = template.name
    self.tier = template.tier or 1
    self.hp = template.hp
    self.maxHp = template.maxHp
    self.attack = template.attack
    self.defense = template.defense
    self.defPercent = template.defPercent or 0
    self.speed = template.speed
    self.crit = template.crit or 0
    self.eva = template.eva or 0
    self.gold = template.gold
    self.crystalBonus = template.crystalBonus or 1
    self.multiTarget = template.multiTarget or false
    self.boss = template.boss or false
    self.color = template.color

    self.isDefending = false

    self.animationManager = nil
    self.animationId = nil
    
    self.assetManager = assetManager
    self.currentDirection = "south"
    self.animFrame = 1
    self.animTimer = 0
    self.animSpeed = 0.15

    return self
end

function Enemy:setAssetManager(assetManager)
    self.assetManager = assetManager
end

function Enemy:hasSprite()
    if self.assetManager then
        return self.assetManager:hasEnemySprite(self.type)
    end
    return false
end

function Enemy:getSprite(direction)
    if self.assetManager then
        return self.assetManager:getEnemySprite(self.type, direction or self.currentDirection)
    end
    return nil
end

function Enemy:getAnimation(animName, direction, frameIndex)
    if self.assetManager then
        return self.assetManager:getEnemyAnimation(self.type, animName, direction or self.currentDirection, frameIndex)
    end
    return nil
end

function Enemy:updateAnimation(dt)
    self.animTimer = self.animTimer + dt
    if self.animTimer >= self.animSpeed then
        self.animTimer = 0
        local frameCount = 1
        if self.assetManager then
            frameCount = self.assetManager:getEnemyAnimationFrameCount(self.type, "idle", self.currentDirection)
            if frameCount == 0 then frameCount = 1 end
        end
        self.animFrame = (self.animFrame % frameCount) + 1
    end
end

function Enemy:setAnimationManager(animManager, animId)
    self.animationManager = animManager
    self.animationId = animId
    if animManager and animId then
        animManager:createAnimationSet(animId)
    end
end

function Enemy:takeDamage(damage)
    local reduction = self.defPercent
    if self.isDefending then
        reduction = reduction + 25
    end
    reduction = math.min(MAX_DEF_PERCENT + 25, reduction)
    
    local actualDamage = math.floor(damage * (100 - reduction) / 100)
    actualDamage = math.max(1, actualDamage)
    
    self.hp = self.hp - actualDamage

    if self.hp < 0 then
        self.hp = 0
    end

    return actualDamage
end

function Enemy:heal(amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

function Enemy:isAlive()
    return self.hp > 0
end

function Enemy:getHPPercent()
    return self.hp / self.maxHp
end

function Enemy:decideAction(partySize)
    local hpPercent = self:getHPPercent()
    
    if hpPercent < 0.25 then
        if math.random() < 0.4 then
            return "defend"
        end
    end
    
    if self.multiTarget and partySize and partySize > 1 then
        if math.random() < 0.3 then
            return "attack_all"
        end
    end
    
    return "attack"
end

function Enemy:calculateDamage()
    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    local damage = math.floor(self.attack * multiplier)
    
    local isCrit = math.random(100) <= self.crit
    if isCrit then
        damage = math.floor(damage * 1.5)
    end
    
    return damage, isCrit
end

function Enemy:checkEvade()
    return math.random(100) <= self.eva
end

function Enemy.getRandomType()
    local tierRoll = math.random(100)
    local tierSum = 0
    local selectedTier = 1
    
    for i, weight in ipairs(TIER_SPAWN_WEIGHTS) do
        tierSum = tierSum + weight
        if tierRoll <= tierSum then
            selectedTier = i
            break
        end
    end
    
    local tierTypes = TYPES_BY_TIER[selectedTier]
    return tierTypes[math.random(#tierTypes)]
end

function Enemy.getAllTypes()
    return ENEMY_TYPES
end

function Enemy.getTypesByTier(tier)
    local result = {}
    for id, data in pairs(ENEMY_TYPES) do
        if data.tier == tier then
            result[id] = data
        end
    end
    return result
end

function Enemy.getTierSpawnWeight(tier)
    return TIER_SPAWN_WEIGHTS[tier] or 0
end

function Enemy.getTypesByTierList(tier)
    return TYPES_BY_TIER[tier] or {}
end

return Enemy
