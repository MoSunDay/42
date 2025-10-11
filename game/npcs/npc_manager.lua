-- npc_manager.lua - Manages NPC instances in the game world
-- Handles spawning, updating, and rendering NPCs

local NPCDatabase = require("npcs.npc_database")

local NPCManager = {}
NPCManager.__index = NPCManager

function NPCManager.new()
    local self = setmetatable({}, NPCManager)
    
    -- Active NPC instances
    self.npcs = {}
    self.nextId = 1
    
    -- Animation manager (will be set externally)
    self.animationManager = nil
    
    return self
end

-- Set animation manager
function NPCManager:setAnimationManager(animManager)
    self.animationManager = animManager
end

-- Spawn an NPC at a position
function NPCManager:spawnNPC(npcType, x, y)
    local template = NPCDatabase.getNPCData(npcType)
    if not template then
        print("Warning: Unknown NPC type: " .. tostring(npcType))
        return nil
    end
    
    -- Create NPC instance
    local npc = {
        id = self.nextId,
        type = npcType,
        x = x,
        y = y,
        -- Copy template data
        npcType = template.type,
        name = template.name,
        description = template.description,
        color = template.color,
        size = template.size,
        canTalk = template.canTalk,
        canTrade = template.canTrade,
        dialogue = template.dialogue,
        
        -- Monster-specific
        hp = template.hp,
        maxHp = template.maxHp,
        attack = template.attack,
        defense = template.defense,
        speed = template.speed,
        exp = template.exp,
        gold = template.gold,
        aggressive = template.aggressive,
        chaseRange = template.chaseRange,
        dropTable = template.dropTable,
        
        -- State
        isAlive = true,
        isChasing = false,
        targetX = x,
        targetY = y,
        
        -- Animation
        animationId = "npc_" .. self.nextId
    }
    
    -- Setup animation
    if self.animationManager then
        self.animationManager:createAnimationSet(npc.animationId)
    end
    
    self.npcs[self.nextId] = npc
    self.nextId = self.nextId + 1
    
    return npc
end

-- Remove an NPC
function NPCManager:removeNPC(npcId)
    local npc = self.npcs[npcId]
    if npc and self.animationManager then
        self.animationManager:removeEntity(npc.animationId)
    end
    self.npcs[npcId] = nil
end

-- Update all NPCs
function NPCManager:update(dt, playerX, playerY)
    for id, npc in pairs(self.npcs) do
        -- Update animation
        if self.animationManager then
            local isMoving = npc.isChasing
            self.animationManager:updateEntity(npc.animationId, dt, isMoving)
        end
        
        -- Update monster AI
        if npc.npcType == "monster" or npc.npcType == "boss" then
            self:updateMonsterAI(npc, dt, playerX, playerY)
        end
    end
end

-- Update monster AI (chase player if aggressive)
function NPCManager:updateMonsterAI(npc, dt, playerX, playerY)
    if not npc.aggressive or not npc.isAlive then
        npc.isChasing = false
        return
    end
    
    -- Calculate distance to player
    local dx = playerX - npc.x
    local dy = playerY - npc.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    -- Check if player is in chase range
    if distance < npc.chaseRange then
        npc.isChasing = true
        
        -- Move towards player
        local moveSpeed = 50  -- NPC movement speed
        local dirX = dx / distance
        local dirY = dy / distance
        
        npc.x = npc.x + dirX * moveSpeed * dt
        npc.y = npc.y + dirY * moveSpeed * dt
    else
        npc.isChasing = false
    end
end

-- Draw all NPCs
function NPCManager:draw(cameraX, cameraY, screenWidth, screenHeight)
    for id, npc in pairs(self.npcs) do
        -- Simple culling: only draw if on screen
        local screenX = npc.x - cameraX + screenWidth / 2
        local screenY = npc.y - cameraY + screenHeight / 2
        
        if screenX > -50 and screenX < screenWidth + 50 and
           screenY > -50 and screenY < screenHeight + 50 then
            self:drawNPC(npc)
        end
    end
end

-- Draw a single NPC
function NPCManager:drawNPC(npc)
    if not npc.isAlive then
        return
    end
    
    -- Get animation transform
    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if self.animationManager then
        offsetX, offsetY, rotation, scaleX, scaleY = self.animationManager:getTransform(npc.animationId)
    end
    
    -- Draw shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", npc.x + offsetX, npc.y + offsetY + npc.size + 5, 
                          npc.size * 0.8 * scaleX, npc.size * 0.3)
    
    -- Apply transform
    love.graphics.push()
    love.graphics.translate(npc.x + offsetX, npc.y + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)
    
    -- Draw NPC body
    love.graphics.setColor(npc.color)
    love.graphics.circle("fill", 0, 0, npc.size)
    
    -- Draw type indicator
    if npc.npcType == "friendly" or npc.npcType == "merchant" or 
       npc.npcType == "healer" or npc.npcType == "service" then
        -- Friendly: draw smile
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", -npc.size * 0.3, -npc.size * 0.2, 2)
        love.graphics.circle("fill", npc.size * 0.3, -npc.size * 0.2, 2)
        love.graphics.arc("line", "open", 0, npc.size * 0.1, npc.size * 0.4, 
                         math.pi * 0.2, math.pi * 0.8)
    elseif npc.npcType == "monster" or npc.npcType == "boss" then
        -- Monster: draw angry eyes
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", -npc.size * 0.3, -npc.size * 0.2, 3)
        love.graphics.circle("fill", npc.size * 0.3, -npc.size * 0.2, 3)
    end
    
    love.graphics.pop()
    
    -- Draw name above NPC
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(npc.name, npc.x + offsetX - 50, npc.y + offsetY - npc.size - 20, 
                        100, "center")
    
    -- Draw chase indicator for aggressive monsters
    if npc.isChasing then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.circle("line", npc.x + offsetX, npc.y + offsetY, npc.size + 5)
    end
end

-- Get NPCs in range
function NPCManager:getNPCsInRange(x, y, range)
    local result = {}
    for id, npc in pairs(self.npcs) do
        local dx = npc.x - x
        local dy = npc.y - y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= range then
            table.insert(result, npc)
        end
    end
    return result
end

-- Get NPC by ID
function NPCManager:getNPC(npcId)
    return self.npcs[npcId]
end

-- Clear all NPCs
function NPCManager:clear()
    if self.animationManager then
        for id, npc in pairs(self.npcs) do
            self.animationManager:removeEntity(npc.animationId)
        end
    end
    self.npcs = {}
end

return NPCManager

