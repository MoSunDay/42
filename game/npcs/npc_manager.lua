-- npc_manager.lua - Manages NPC instances in the game world
-- Handles spawning, updating, and rendering NPCs

local AnimationManager = require("src.animations.animation_manager")
local NPCDatabase = require("npcs.npc_database")

local NPCManager = {}

function NPCManager.create()
    local state = {}

    state.npcs = {}
    state.nextId = 1
    state.animationManager = nil
    state.assetManager = nil
    state.npcSprites = {}

    return state
end

function NPCManager.setAnimationManager(state, animManager)
    state.animationManager = animManager
end

function NPCManager.setAssetManager(state, assetManager)
    state.assetManager = assetManager
end

local NPC_SPRITE_MAP = {
    elder_adrian = "elder",
    spirit_guide_lina = "quest_giver",
    town_guard = "guard",
    weapon_merchant = "merchant",
    healer = "healer",
    innkeeper = "villager",
    teleporter = "villager"
}

function NPCManager.getSpriteForNPC(state, npcType)
    if state.npcSprites[npcType] then
        return state.npcSprites[npcType]
    end
    if not state.assetManager then return nil end

    local spriteId = NPC_SPRITE_MAP[npcType] or npcType
    local sprite = state.assetManager:getNPCSprite(spriteId, "south")
    if sprite then
        state.npcSprites[npcType] = sprite
    end
    return sprite
end

function NPCManager.spawnNPC(state, npcType, x, y)
    local template = NPCDatabase.getNPCData(npcType)
    if not template then
        print("Warning: Unknown NPC type: " .. tostring(npcType))
        return nil
    end

    local npc = {
        id = state.nextId,
        type = npcType,
        x = x,
        y = y,
        npcType = template.type,
        name = template.name,
        description = template.description,
        color = template.color,
        size = template.size,
        canTalk = template.canTalk,
        canTrade = template.canTrade,
        dialogue = template.dialogue,

        hp = template.hp,
        maxHp = template.maxHp,
        attack = template.attack,
        defense = template.defense,
        speed = template.speed,
        aggressive = template.aggressive,
        chaseRange = template.chaseRange,
        dropTable = template.dropTable,

        isAlive = true,
        isChasing = false,
        targetX = x,
        targetY = y,

        animationId = "npc_" .. state.nextId
    }

    if state.animationManager then
        AnimationManager.createAnimationSet(state.animationManager, npc.animationId)
    end

    state.npcs[state.nextId] = npc
    state.nextId = state.nextId + 1

    return npc
end

function NPCManager.removeNPC(state, npcId)
    local npc = state.npcs[npcId]
    if npc and state.animationManager then
        AnimationManager.removeEntity(state.animationManager, npc.animationId)
    end
    state.npcs[npcId] = nil
end

function NPCManager.update(state, dt, playerX, playerY)
    for id, npc in pairs(state.npcs) do
        if state.animationManager then
            local isMoving = npc.isChasing
            AnimationManager.updateEntity(state.animationManager, npc.animationId, dt, isMoving)
        end

        if npc.npcType == "monster" or npc.npcType == "boss" then
            NPCManager.updateMonsterAI(state, npc, dt, playerX, playerY)
        end
    end
end

function NPCManager.updateMonsterAI(state, npc, dt, playerX, playerY)
    if not npc.aggressive or not npc.isAlive then
        npc.isChasing = false
        return
    end

    local dx = playerX - npc.x
    local dy = playerY - npc.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance < npc.chaseRange then
        npc.isChasing = true

        local moveSpeed = 50
        local dirX = dx / distance
        local dirY = dy / distance

        npc.x = npc.x + dirX * moveSpeed * dt
        npc.y = npc.y + dirY * moveSpeed * dt
    else
        npc.isChasing = false
    end
end

function NPCManager.draw(state, cameraX, cameraY, screenWidth, screenHeight)
    for id, npc in pairs(state.npcs) do
        local screenX = npc.x - cameraX + screenWidth / 2
        local screenY = npc.y - cameraY + screenHeight / 2

        if screenX > -50 and screenX < screenWidth + 50 and
           screenY > -50 and screenY < screenHeight + 50 then
            NPCManager.drawNPC(state, npc)
        end
    end
end

function NPCManager.drawNPC(state, npc)
    if not npc.isAlive then
        return
    end

    local offsetX, offsetY, rotation, scaleX, scaleY = 0, 0, 0, 1, 1
    if state.animationManager then
        offsetX, offsetY, rotation, scaleX, scaleY = AnimationManager.getTransform(state.animationManager, npc.animationId)
    end

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", npc.x + offsetX, npc.y + offsetY + npc.size + 5,
                          npc.size * 0.8 * scaleX, npc.size * 0.3)

    local sprite = NPCManager.getSpriteForNPC(state, npc.type)

    love.graphics.push()
    love.graphics.translate(npc.x + offsetX, npc.y + offsetY)
    love.graphics.rotate(rotation)
    love.graphics.scale(scaleX, scaleY)

    if sprite then
        love.graphics.setColor(1, 1, 1, 1)
        local sw, sh = sprite:getDimensions()
        love.graphics.draw(sprite, -sw / 2, -sh / 2)
    else
        love.graphics.setColor(npc.color)
        love.graphics.circle("fill", 0, 0, npc.size)

        if npc.npcType == "friendly" or npc.npcType == "merchant" or
           npc.npcType == "healer" or npc.npcType == "service" then
            love.graphics.setColor(0, 0, 0)
            love.graphics.circle("fill", -npc.size * 0.3, -npc.size * 0.2, 2)
            love.graphics.circle("fill", npc.size * 0.3, -npc.size * 0.2, 2)
            love.graphics.arc("line", "open", 0, npc.size * 0.1, npc.size * 0.4,
                             math.pi * 0.2, math.pi * 0.8)
        elseif npc.npcType == "monster" or npc.npcType == "boss" then
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle("fill", -npc.size * 0.3, -npc.size * 0.2, 3)
            love.graphics.circle("fill", npc.size * 0.3, -npc.size * 0.2, 3)
        end
    end

    love.graphics.pop()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(npc.name, npc.x + offsetX - 50, npc.y + offsetY - npc.size - 20,
                        100, "center")

    if npc.isChasing then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.circle("line", npc.x + offsetX, npc.y + offsetY, npc.size + 5)
    end
end

function NPCManager.getNPCsInRange(state, x, y, range)
    local result = {}
    for id, npc in pairs(state.npcs) do
        local dx = npc.x - x
        local dy = npc.y - y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance <= range then
            table.insert(result, npc)
        end
    end
    return result
end

function NPCManager.getNPC(state, npcId)
    return state.npcs[npcId]
end

function NPCManager.clear(state)
    if state.animationManager then
        for id, npc in pairs(state.npcs) do
            AnimationManager.removeEntity(state.animationManager, npc.animationId)
        end
    end
    state.npcs = {}
end

return NPCManager
