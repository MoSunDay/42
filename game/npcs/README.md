# NPC System Documentation

## Overview

The NPC system provides centralized management for all non-player characters, including friendly NPCs, merchants, and monsters.

## Directory Structure

```
npcs/
├── README.md           # This file
├── npc_database.lua    # All NPC/Monster definitions
└── npc_manager.lua     # NPC instance management
```

## NPC Types

### 1. Friendly NPCs
- **town_guard**: Guards protecting the town
- **innkeeper**: Provides rest and save services

### 2. Merchants
- **weapon_merchant**: Sells weapons and armor
- **healer**: Restores HP and cures status

### 3. Monsters
- **slime**: Weak gelatinous creature (passive)
- **goblin**: Mischievous green creature (aggressive)
- **skeleton**: Animated bones (aggressive)
- **orc**: Brutal warrior (aggressive)
- **wolf**: Fierce wild wolf (very aggressive)
- **bat**: Flying night creature (passive)

### 4. Bosses
- **forest_guardian**: Ancient forest protector

## NPC Data Structure

```lua
{
    type = "monster",           -- NPC type: friendly, merchant, healer, service, monster, boss
    name = "Goblin",           -- Display name
    description = "...",       -- Description
    
    -- Visual
    color = {0.6, 0.4, 0.2},  -- RGB color
    size = 18,                 -- Radius in pixels
    
    -- Interaction
    canTalk = true,            -- Can player talk to this NPC?
    canTrade = false,          -- Can player trade with this NPC?
    dialogue = {...},          -- Dialogue lines
    
    -- Combat (monsters only)
    hp = 50,
    maxHp = 50,
    attack = 8,
    defense = 3,
    speed = 5,
    exp = 20,
    gold = 10,
    
    -- AI (monsters only)
    aggressive = true,         -- Will chase player?
    chaseRange = 150,          -- How far to chase
    
    -- Drops (monsters only)
    dropTable = {
        {item = "Goblin Ear", chance = 0.4},
        {item = "Rusty Dagger", chance = 0.15}
    }
}
```

## Usage

### 1. Import the NPC Database

```lua
local NPCDatabase = require("npcs.npc_database")
```

### 2. Get NPC Data

```lua
-- Get specific NPC
local goblinData = NPCDatabase.getNPCData("goblin")

-- Get all monsters
local monsters = NPCDatabase.getNPCsByType("monster")

-- Get random monster
local randomMonster = NPCDatabase.getRandomMonster()
```

### 3. Use NPC Manager

```lua
local NPCManager = require("npcs.npc_manager")

-- Create manager
local npcManager = NPCManager.new()

-- Set animation manager
npcManager:setAnimationManager(animationManager)

-- Spawn NPCs
npcManager:spawnNPC("goblin", 500, 500)
npcManager:spawnNPC("town_guard", 1000, 1000)

-- Update (in game loop)
npcManager:update(dt, playerX, playerY)

-- Draw (in render loop)
npcManager:draw(cameraX, cameraY, screenWidth, screenHeight)

-- Get NPCs in range
local nearbyNPCs = npcManager:getNPCsInRange(playerX, playerY, 100)
```

## Features

### Breathing Animation
All NPCs have breathing animation automatically applied through the animation manager.

### Monster AI
Aggressive monsters will chase the player when within chase range:
- **Wolf**: 250 pixels (very aggressive)
- **Orc**: 200 pixels
- **Goblin**: 150 pixels
- **Skeleton**: 120 pixels

### Drop System
Monsters have a drop table with items and chances:
```lua
dropTable = {
    {item = "Goblin Ear", chance = 0.4},  -- 40% chance
    {item = "Rusty Dagger", chance = 0.15} -- 15% chance
}
```

### Merchant System
Merchants have shop inventories:
```lua
shop = {
    {name = "Iron Sword", price = 100, attack = 5},
    {name = "Steel Shield", price = 150, defense = 3}
}
```

## Adding New NPCs

1. Open `npc_database.lua`
2. Add new entry to `NPC_DATABASE`:

```lua
my_new_npc = {
    type = "monster",
    name = "My Monster",
    description = "A new monster",
    hp = 60,
    maxHp = 60,
    attack = 10,
    defense = 4,
    speed = 5,
    exp = 25,
    gold = 12,
    color = {0.8, 0.2, 0.2},
    size = 20,
    aggressive = true,
    chaseRange = 180,
    dropTable = {
        {item = "Monster Claw", chance = 0.5}
    }
}
```

3. Spawn it in your game:
```lua
npcManager:spawnNPC("my_new_npc", x, y)
```

## Integration with Battle System

When a monster triggers a battle, use the NPC data to create enemies:

```lua
local npc = npcManager:getNPC(npcId)
if npc.npcType == "monster" or npc.npcType == "boss" then
    -- Create enemy from NPC data
    local enemy = Enemy.new(npc.type)
    -- Start battle
    battleSystem:startBattle(...)
end
```

## Performance

- NPCs are only drawn when on screen (culling)
- Animations are managed centrally
- Monster AI only updates for aggressive monsters
- Maximum recommended NPCs: 100 active instances

## Future Enhancements

- [ ] Patrol paths for NPCs
- [ ] Quest system integration
- [ ] NPC schedules (day/night)
- [ ] Faction system
- [ ] NPC conversations with choices
- [ ] Trading interface
- [ ] Pet/companion system

