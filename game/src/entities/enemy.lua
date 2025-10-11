-- enemy.lua - Enemy entity for battle
-- Defines enemy stats, AI, and behavior

local Enemy = {}
Enemy.__index = Enemy

-- Enemy types with different stats
local ENEMY_TYPES = {
    slime = {
        name = "Slime",
        hp = 30,
        maxHp = 30,
        attack = 5,
        defense = 2,
        speed = 3,
        exp = 10,
        gold = 5,
        color = {0.2, 0.8, 0.3}
    },
    goblin = {
        name = "Goblin",
        hp = 50,
        maxHp = 50,
        attack = 8,
        defense = 3,
        speed = 5,
        exp = 20,
        gold = 10,
        color = {0.6, 0.4, 0.2}
    },
    skeleton = {
        name = "Skeleton",
        hp = 40,
        maxHp = 40,
        attack = 10,
        defense = 1,
        speed = 4,
        exp = 15,
        gold = 8,
        color = {0.9, 0.9, 0.9}
    },
    orc = {
        name = "Orc",
        hp = 80,
        maxHp = 80,
        attack = 12,
        defense = 5,
        speed = 3,
        exp = 35,
        gold = 20,
        color = {0.3, 0.6, 0.3}
    }
}

function Enemy.new(enemyType)
    local self = setmetatable({}, Enemy)
    
    -- Get enemy template
    local template = ENEMY_TYPES[enemyType] or ENEMY_TYPES.slime
    
    -- Copy stats from template
    self.type = enemyType
    self.name = template.name
    self.hp = template.hp
    self.maxHp = template.maxHp
    self.attack = template.attack
    self.defense = template.defense
    self.speed = template.speed
    self.exp = template.exp
    self.gold = template.gold
    self.color = template.color

    -- Battle state
    self.isDefending = false

    return self
end

-- Take damage
function Enemy:takeDamage(damage)
    local actualDamage = math.max(1, damage - self.defense)
    self.hp = self.hp - actualDamage

    if self.hp < 0 then
        self.hp = 0
    end

    return actualDamage
end

-- Heal
function Enemy:heal(amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

-- Check if alive
function Enemy:isAlive()
    return self.hp > 0
end

-- Get HP percentage
function Enemy:getHPPercent()
    return self.hp / self.maxHp
end

-- AI decision making (simple AI)
function Enemy:decideAction(player)
    -- Simple AI logic
    local hpPercent = self:getHPPercent()
    
    -- If low HP (< 30%), 30% chance to defend
    if hpPercent < 0.3 and math.random() < 0.3 then
        return "defend"
    end
    
    -- Otherwise, attack
    return "attack"
end

-- Calculate attack damage
function Enemy:calculateDamage()
    -- Random damage between 80% to 120% of attack
    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    return math.floor(self.attack * multiplier)
end

-- Get random enemy type
function Enemy.getRandomType()
    local types = {"slime", "goblin", "skeleton", "orc"}
    local weights = {40, 30, 20, 10} -- Probability weights
    
    local total = 0
    for _, w in ipairs(weights) do
        total = total + w
    end
    
    local rand = math.random() * total
    local sum = 0
    
    for i, w in ipairs(weights) do
        sum = sum + w
        if rand <= sum then
            return types[i]
        end
    end
    
    return "slime"
end

-- Get all enemy types
function Enemy.getAllTypes()
    return ENEMY_TYPES
end

return Enemy

