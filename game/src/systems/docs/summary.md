# Systems Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Game systems for battle, party, chat, inventory, equipment, collision, etc.

## Files

| File | Description |
|------|-------------|
| `appearance_system.lua` | Character visual appearance |
| `audio_system.lua` | BGM and SFX management |
| `chat_system.lua` | Chat box + speech bubbles |
| `collision_system.lua` | Tile-based walkability |
| `equipment_system.lua` | Equipment slots and stat bonuses |
| `input_system.lua` | Keyboard/mouse input handling |
| `inventory_system.lua` | Item storage and management |
| `item_database.lua` | Item definitions with stats |
| `party_system.lua` | Party management (max 5 members) |
| `pet_system.lua` | Pet companion system |
| `render_system.lua` | Rendering coordination |
| `sprite_animator.lua` | Sprite sheet animation |
| `tile_animator.lua` | Animated tiles (water, etc.) |
| `enhanced_audio.lua` | Extended audio features |
| `battle/` | Battle system subdirectory |

## Key APIs

### collision_system.lua
- `CollisionSystem:isWalkable(x, y)` - Check if position walkable
- `CollisionSystem:canMove(fromX, fromY, toX, toY, radius)` - Check movement

### inventory_system.lua
- `InventorySystem:addItem(itemId)` - Add item
- `InventorySystem:removeItem(index)` - Remove item
- `InventorySystem:serialize()` / `deserialize(data)` - Save/load

### equipment_system.lua
- `EquipmentSystem:equip(slot, itemId)` - Equip item
- `EquipmentSystem:getTotalStats()` - Get stat bonuses
- `EquipmentSystem:getDefensePercent()` - Get damage reduction %

### party_system.lua
- `PartySystem:addMember(memberData)` - Add member
- `PartySystem:removeMember(id)` - Remove member
- `PartySystem.MAX_MEMBERS` = 5
