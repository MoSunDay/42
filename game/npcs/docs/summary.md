# NPCs Module Summary

> Last updated: TBD (commit on first change)

## Purpose
NPC definitions, dialogue, and interactions.

## Files

| File | Description |
|------|-------------|
| `npc_manager.lua` | NPC spawning and interaction |
| `npc_database.lua` | NPC definitions and dialogue |

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
