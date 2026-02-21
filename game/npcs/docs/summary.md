# NPCs Module Summary

> Last updated: f86d842 - Expanded NPC types

## Purpose
NPC definitions, dialogue, and interactions.

## Files

| File | Description |
|------|-------------|
| `npc_manager.lua` | NPC spawning and interaction |
| `npc_database.lua` | NPC definitions and dialogue |
| `teleporter.lua` | Dimensional Guide for map teleportation |
| `bosses.lua` | Boss monster definitions |
| `friendly_npcs.lua` | Friendly NPC definitions |
| `monsters.lua` | Monster NPC definitions |

## Key APIs

### npc_manager.lua
- `NPCManager.new()` - Create manager
- `NPCManager:loadNPCs(mapId)` - Load NPCs for map
- `NPCManager:getNPCAt(x, y)` - Get NPC at position
- `NPCManager:interact(npcId)` - Start interaction
- `NPCManager:update(dt)` - Update NPC animations

### npc_database.lua
- `NPCDatabase.getNPC(npcId)` - Get NPC data
- `NPCDatabase.getDialogue(npcId, dialogueId)` - Get dialogue
- `NPCDatabase.getAllNPCs()` - All NPCs

### teleporter.lua
- `Teleporter.new(x, y)` - Create dimensional guide
- `Teleporter:getDialogue()` - Get current dialogue
- `Teleporter:getDestinations()` - Get available maps
- `Teleporter:teleport(mapId)` - Initiate teleport

## NPC Data Structure

```lua
{
    id = "village_chief",
    name = "Village Chief",
    sprite = "npc_chief",
    x = 500, y = 600,
    direction = "south",
    dialogue = {
        {
            text = "Welcome, adventurer!",
            options = {
                {"Tell me about the village", "dialogue_2"},
                {"Goodbye", nil}
            }
        }
    }
}
```

## NPC Types

| NPC | Location | Purpose |
|-----|----------|---------|
| village_chief | Town | Quests, story |
| spring_guardian | Forest | Healing |
| summer_merchant | Town | Shop |
| autumn_innkeeper | Town | Rest/save |
| winter_priest | Temple | Blessings |
| teleporter | Various | Map teleportation |

## Monster NPCs

| Type | Description |
|------|-------------|
| slime | Basic enemy, Tier 1 |
| goblin | Tier 1 enemy |
| wolf | Tier 1-2 enemy |
| orc_warrior | Tier 2 enemy |
| demon | Tier 3 enemy |
| ancient_dragon | Tier 4 boss |

## Boss NPCs

Located in `bosses.lua`:
- Unique boss encounters
- Special abilities
- Loot tables
