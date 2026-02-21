-- player.lua - 玩家实体
-- 处理玩家的移动、动画和状态

local AnimationManager = require("src.animations.animation_manager")
local AppearanceSystem = require("src.systems.appearance_system")
local SpriteAnimator = require("src.systems.sprite_animator")

local Player = {}
Player.__index = Player

local MAX_DEF_PERCENT = 50

local DIRECTION_MAP = {
    ["down"] = "south",
    ["down-left"] = "south-west",
    ["left"] = "west",
    ["up-left"] = "north-west",
    ["up"] = "north",
    ["up-right"] = "north-east",
    ["right"] = "east",
    ["down-right"] = "south-east"
}

function Player.new(x, y, assetManager)
    local self = setmetatable({}, Player)

    self.x = x or 0
    self.y = y or 0

    self.targetX = self.x
    self.targetY = self.y

    self.speed = 250

    self.isMoving = false

    self.width = 48
    self.height = 48

    self.direction = "down"
    self.angle = 0

    self.animationTime = 0
    self.animationFrame = 0

    self.mapWidth = 2000
    self.mapHeight = 2000

    self.collisionRadius = 16

    self.assetManager = assetManager
    self.sprite = assetManager:getImage("player")

    self.collisionSystem = nil

    self.baseHp = 100
    self.hp = 100
    self.maxHp = 100
    self.baseAttack = 15
    self.attack = 15
    self.baseDefense = 5
    self.defense = 5
    self.defPercent = 1
    self.battleSpeed = 6
    self.gold = 0
    self.isDefending = false
    
    self.baseCrit = 5
    self.crit = 5
    self.baseEva = 3
    self.eva = 3

    self.animationManager = nil
    self.animationId = "player"

    self.equipmentSystem = nil
    self.inventorySystem = nil

    self.appearance = nil
    self.appearanceId = "blue_hero"
    
    self.spriteAnimator = nil
    self.useSpriteAnimator = false

    self:initSpriteAnimator()

    return self
end

function Player:initSpriteAnimator()
    if not self.assetManager then return end
    
    if self.assetManager:hasCharacterSprite(self.appearanceId) then
        self.spriteAnimator = SpriteAnimator.new({
            frameWidth = 48,
            frameHeight = 48,
            frameDuration = 0.12
        })
        
        self.spriteAnimator:loadFromAssetManager(self.assetManager, self.appearanceId)
        
        if not self.spriteAnimator:hasAnimation("walking") then
            local basePath = "assets/images/characters/" .. self.appearanceId .. "/rotations"
            self.spriteAnimator:loadDirectionalSprites(basePath)
        end
        
        self.useSpriteAnimator = true
    end
end

function Player:setAnimationManager(animManager)
    self.animationManager = animManager
    if animManager then
        animManager:createAnimationSet(self.animationId)
    end
end

function Player:setAppearance(character)
    self.appearance = AppearanceSystem.createAppearance(character)
    if character and character.appearanceId then
        self.appearanceId = character.appearanceId
        self:initSpriteAnimator()
    end
end

function Player:setAppearanceId(appearanceId)
    self.appearanceId = appearanceId
    self:initSpriteAnimator()
end

function Player:setMapBounds(width, height)
    self.mapWidth = width
    self.mapHeight = height
end

function Player:setCollisionSystem(collisionSystem)
    self.collisionSystem = collisionSystem
end

function Player:moveTo(x, y)
    if self.collisionSystem then
        x, y = self.collisionSystem:getClosestWalkable(x, y, self.x, self.y, self.collisionRadius)
    end

    self.targetX = math.max(self.collisionRadius, math.min(x, self.mapWidth - self.collisionRadius))
    self.targetY = math.max(self.collisionRadius, math.min(y, self.mapHeight - self.collisionRadius))

    self.isMoving = true

    local dx = self.targetX - self.x
    local dy = self.targetY - self.y

    self.angle = math.atan2(dy, dx)

    local absX = math.abs(dx)
    local absY = math.abs(dy)
    local threshold = 0.4

    if absX < 1 and absY < 1 then
        return
    end

    if absY < absX * threshold then
        self.direction = dx > 0 and "right" or "left"
    elseif absX < absY * threshold then
        self.direction = dy > 0 and "down" or "up"
    else
        if dx > 0 and dy > 0 then
            self.direction = "down-right"
        elseif dx > 0 and dy < 0 then
            self.direction = "up-right"
        elseif dx < 0 and dy > 0 then
            self.direction = "down-left"
        else
            self.direction = "up-left"
        end
    end
end

function Player:update(dt)
    if self.spriteAnimator then
        local spriteDir = DIRECTION_MAP[self.direction] or "south"
        self.spriteAnimator:setDirection(spriteDir)
        self.spriteAnimator:setAnimationState(self.isMoving)
        self.spriteAnimator:update(dt)
    end
    
    if self.animationManager then
        self.animationManager:updateEntity(self.animationId, dt, self.isMoving)
    end

    if not self.isMoving then
        return
    end

    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < 3 then
        self.x = self.targetX
        self.y = self.targetY
        self.isMoving = false
        self.animationFrame = 0
        return
    end

    local dirX = dx / distance
    local dirY = dy / distance

    local moveDistance = self.speed * dt
    if moveDistance > distance then
        moveDistance = distance
    end

    local newX = self.x + dirX * moveDistance
    local newY = self.y + dirY * moveDistance

    if self.collisionSystem then
        local canMove, validX, validY = self.collisionSystem:canMove(
            self.x, self.y, newX, newY, self.collisionRadius
        )

        if canMove then
            self.x = validX
            self.y = validY
        else
            self.x = validX
            self.y = validY
            self.isMoving = false
        end
    else
        self.x = newX
        self.y = newY
    end

    self.x = math.max(self.collisionRadius, math.min(self.x, self.mapWidth - self.collisionRadius))
    self.y = math.max(self.collisionRadius, math.min(self.y, self.mapHeight - self.collisionRadius))

    self.animationTime = self.animationTime + dt
    if self.animationTime > 0.15 then
        self.animationTime = 0
        self.animationFrame = (self.animationFrame + 1) % 4
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)

    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if self.animationManager then
        offsetX, offsetY, rotation, scaleX, scaleY = self.animationManager:getTransform(self.animationId)
    end

    if self.useSpriteAnimator and self.spriteAnimator then
        local spriteDir = DIRECTION_MAP[self.direction] or "south"
        self.spriteAnimator:setDirection(spriteDir)
        self.spriteAnimator:draw(self.x, self.y, 2, offsetX, offsetY)
    elseif self.appearance then
        AppearanceSystem.drawSprite(self.x, self.y, 32, self.appearance, offsetX, offsetY, scaleX, scaleY)
    elseif self.sprite then
        love.graphics.push()
        love.graphics.translate(self.x + offsetX, self.y + offsetY)
        love.graphics.rotate(rotation)
        love.graphics.scale(scaleX, scaleY)
        love.graphics.draw(self.sprite,
            -self.width/2,
            -self.height/2)
        love.graphics.pop()
    end
    
    if self.isMoving then
        love.graphics.setColor(1, 1, 0, 0.6)
        love.graphics.circle("line", self.targetX, self.targetY, 12)
        love.graphics.line(self.targetX - 10, self.targetY, self.targetX + 10, self.targetY)
        love.graphics.line(self.targetX, self.targetY - 10, self.targetX, self.targetY + 10)
        
        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.line(self.x, self.y, self.targetX, self.targetY)
    end
    
    if self.isMoving and self.animationFrame % 2 == 0 then
        love.graphics.setColor(0.2, 0.6, 1.0, 0.2)
        love.graphics.circle("fill", self.x, self.y + self.height/2, 10)
    end
    
    love.graphics.setColor(1, 1, 1)
end

function Player:takeDamage(damage)
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

    self.isDefending = false
    return actualDamage
end

function Player:heal(amount)
    self.hp = math.min(self.maxHp, self.hp + amount)
end

function Player:isAlive()
    return self.hp > 0
end

function Player:getHPPercent()
    return self.hp / self.maxHp
end

function Player:calculateDamage()
    local variance = 0.2
    local multiplier = 1 + (math.random() * 2 - 1) * variance
    local damage = math.floor(self.attack * multiplier)
    
    local isCrit = math.random(100) <= self.crit
    if isCrit then
        damage = math.floor(damage * 1.5)
    end
    
    return damage, isCrit
end

function Player:gainGold(amount)
    self.gold = self.gold + amount
end

function Player:setEquipmentSystem(equipSystem)
    self.equipmentSystem = equipSystem
    self:updateStatsWithEquipment()
end

function Player:setInventorySystem(invSystem)
    self.inventorySystem = invSystem
end

function Player:updateStatsWithEquipment()
    if not self.equipmentSystem then
        return
    end

    local equipStats = self.equipmentSystem:getTotalStats()
    self.attack = self.baseAttack + equipStats.attack
    self.defense = self.baseDefense + equipStats.defense
    self.battleSpeed = 6 + equipStats.speed
    self.crit = self.baseCrit + equipStats.crit
    self.eva = self.baseEva + equipStats.eva
    
    self.defPercent = self.equipmentSystem:getDefensePercent()
    
    local oldMaxHp = self.maxHp
    self.maxHp = self.baseHp + (equipStats.hp or 0)
    if self.maxHp ~= oldMaxHp and self.hp > self.maxHp then
        self.hp = self.maxHp
    end
end

function Player:checkEvade()
    return math.random(100) <= self.eva
end

return Player
