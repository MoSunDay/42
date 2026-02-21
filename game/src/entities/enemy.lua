-- enemy.lua - Enemy entity for battle
-- Defines enemy stats, AI, and behavior with 4-tier system

local Enemy = {}
Enemy.__index = Enemy

local MAX_DEF_PERCENT = 50

local ENEMY_TYPES = {
    -- Tier 1: Common (50% spawn rate)
    slime = {
        name = "Slime",
        tier = 1,
        hp = 30, maxHp = 30,
        attack = 8, defense = 2,
        defPercent = 0,
        speed = 3,
        crit = 2, eva = 0,
        exp = 10, gold = 5,
        color = {0.2, 0.8, 0.3}
    },
    goblin = {
        name = "Goblin",
        tier = 1,
        hp = 45, maxHp = 45,
        attack = 12, defense = 3,
        defPercent = 0,
        speed = 5,
        crit = 5, eva = 3,
        exp = 15, gold = 8,
        color = {0.6, 0.4, 0.2}
    },
    skeleton = {
        name = "Skeleton",
        tier = 1,
        hp = 35, maxHp = 35,
        attack = 15, defense = 1,
        defPercent = 0,
        speed = 4,
        crit = 8, eva = 2,
        exp = 12, gold = 6,
        color = {0.9, 0.9, 0.9}
    },
    bat = {
        name = "Bat",
        tier = 1,
        hp = 20, maxHp = 20,
        attack = 6, defense = 0,
        defPercent = 0,
        speed = 7,
        crit = 3, eva = 10,
        exp = 8, gold = 4,
        color = {0.3, 0.2, 0.4}
    },
    
    -- Tier 2: Elite (30% spawn rate)
    orc_warrior = {
        name = "Orc Warrior",
        tier = 2,
        hp = 100, maxHp = 100,
        attack = 20, defense = 8,
        defPercent = 5,
        speed = 4,
        crit = 5, eva = 2,
        exp = 30, gold = 18,
        color = {0.3, 0.6, 0.3}
    },
    skeleton_knight = {
        name = "Skeleton Knight",
        tier = 2,
        hp = 80, maxHp = 80,
        attack = 25, defense = 5,
        defPercent = 3,
        speed = 5,
        crit = 10, eva = 3,
        exp = 35, gold = 20,
        color = {0.7, 0.7, 0.8}
    },
    wolf = {
        name = "Dire Wolf",
        tier = 2,
        hp = 70, maxHp = 70,
        attack = 22, defense = 3,
        defPercent = 0,
        speed = 8,
        crit = 12, eva = 8,
        exp = 28, gold = 15,
        color = {0.4, 0.4, 0.5}
    },
    dark_mage = {
        name = "Dark Mage",
        tier = 2,
        hp = 60, maxHp = 60,
        attack = 30, defense = 2,
        defPercent = 0,
        speed = 5,
        crit = 15, eva = 5,
        exp = 40, gold = 25,
        color = {0.4, 0.2, 0.6}
    },
    
    -- Tier 3: Boss (15% spawn rate)
    orc_chieftain = {
        name = "Orc Chieftain",
        tier = 3,
        hp = 200, maxHp = 200,
        attack = 35, defense = 15,
        defPercent = 15,
        speed = 4,
        crit = 8, eva = 3,
        exp = 80, gold = 50,
        color = {0.2, 0.5, 0.2}
    },
    vampire = {
        name = "Vampire Lord",
        tier = 3,
        hp = 180, maxHp = 180,
        attack = 40, defense = 10,
        defPercent = 10,
        speed = 7,
        crit = 15, eva = 12,
        exp = 100, gold = 60,
        color = {0.5, 0.1, 0.2}
    },
    golem = {
        name = "Stone Golem",
        tier = 3,
        hp = 300, maxHp = 300,
        attack = 28, defense = 25,
        defPercent = 25,
        speed = 2,
        crit = 3, eva = 0,
        exp = 90, gold = 70,
        color = {0.5, 0.5, 0.5}
    },
    demon = {
        name = "Demon",
        tier = 3,
        hp = 250, maxHp = 250,
        attack = 45, defense = 12,
        defPercent = 12,
        speed = 6,
        crit = 12, eva = 8,
        exp = 120, gold = 80,
        color = {0.8, 0.2, 0.2}
    },
    
    -- Tier 4: Legendary (5% spawn rate)
    ancient_dragon = {
        name = "Ancient Dragon",
        tier = 4,
        hp = 500, maxHp = 500,
        attack = 55, defense = 20,
        defPercent = 30,
        speed = 5,
        crit = 10, eva = 5,
        exp = 200, gold = 150,
        color = {0.8, 0.5, 0.1}
    },
    lich_king = {
        name = "Lich King",
        tier = 4,
        hp = 400, maxHp = 400,
        attack = 60, defense = 15,
        defPercent = 20,
        speed = 6,
        crit = 20, eva = 10,
        exp = 250, gold = 180,
        color = {0.2, 0.1, 0.3}
    },
    chaos_serpent = {
        name = "Chaos Serpent",
        tier = 4,
        hp = 450, maxHp = 450,
        attack = 50, defense = 18,
        defPercent = 25,
        speed = 8,
        crit = 15, eva = 15,
        exp = 220, gold = 160,
        color = {0.5, 0.1, 0.5}
    }
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
    self.exp = template.exp
    self.gold = template.gold
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

function Enemy:decideAction(player)
    local hpPercent = self:getHPPercent()
    
    if hpPercent < 0.3 and math.random() < 0.3 then
        return "defend"
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
    local typesByTier = {
        [1] = {"slime", "goblin", "skeleton", "bat"},
        [2] = {"orc_warrior", "skeleton_knight", "wolf", "dark_mage"},
        [3] = {"orc_chieftain", "vampire", "golem", "demon"},
        [4] = {"ancient_dragon", "lich_king", "chaos_serpent"}
    }
    
    local tierWeights = {50, 30, 15, 5}
    local tierRoll = math.random(100)
    local tierSum = 0
    local selectedTier = 1
    
    for i, weight in ipairs(tierWeights) do
        tierSum = tierSum + weight
        if tierRoll <= tierSum then
            selectedTier = i
            break
        end
    end
    
    local tierTypes = typesByTier[selectedTier]
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

return Enemy
