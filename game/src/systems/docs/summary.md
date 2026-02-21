# Systems Module Summary

> Last updated: 0b5db5a - UI components + NPC expansion

## Purpose
Game systems for battle, party, chat, inventory, equipment, collision, audio, companions, and spirit crystals.

## Files

| File | Description |
|------|-------------|
| `appearance_system.lua` | Character visual appearance |
| `audio_system.lua` | BGM and SFX management with file loading and procedural fallback |
| `chat_system.lua` | Chat box + speech bubbles |
| `collision_system.lua` | Tile-based walkability |
| `companion_system.lua` | Companion/pet management with 6 templates, leveling, battle AI |
| `equipment_system.lua` | Equipment slots, stat bonuses, set bonuses, enhancement |
| `spirit_crystal_system.lua` | Spirit crystal collection, 5 types/4 tiers, stat bonuses, fusion |
| `input_system.lua` | Keyboard/mouse input handling |
| `inventory_system.lua` | Item storage and management |
| `item_database.lua` | Item definitions with stats |
| `party_system.lua` | Party management (max 5 members) |
| `pet_system.lua` | Pet companion system |
| `render_system.lua` | Rendering coordination |
| `sprite_animator.lua` | Sprite sheet animation |
| `tile_animator.lua` | Animated tiles (water, etc.) |
| `enhanced_audio.lua` | Extended audio features (procedural BGM generation) |
| `battle/` | Battle system subdirectory |

## Key APIs

### audio_system.lua
- `AudioSystem:loadSoundFiles()` - Load .ogg/.wav files from assets/sounds/
- `AudioSystem:playSFX(name)` - Play sound effect (attack, hit, victory, etc.)
- `AudioSystem:playBGM(mode)` - Play BGM (exploration, battle, spring/summer/autumn/winter)
- `AudioSystem:generateFallbackSounds()` - Generate procedural sounds if files missing
- `AudioSystem:setMusicVolume(vol)` / `setSFXVolume(vol)` - Volume control (0-1)

### companion_system.lua
- `CompanionSystem:createCompanion(templateId)` - Create companion by type
- `CompanionSystem:addCompanion(templateId)` - Add to party (max 9)
- `CompanionSystem:removeCompanion(id)` - Remove from party
- `CompanionSystem:gainExperience(id, xp)` - Level up companions
- `CompanionSystem:getBattleParty()` - Get party for combat
- `CompanionSystem.MAX_COMPANIONS = 9`
- Templates: warrior, berserker, guardian, assassin, mage, paladin

### spirit_crystal_system.lua
- `SpiritCrystalSystem:generateCrystal(type, tier)` - Create crystal
- `SpiritCrystalSystem:collectCrystal(crystal)` - Add to collection
- `SpiritCrystalSystem:equipCrystal(slot, crystal)` - Equip for bonuses
- `SpiritCrystalSystem:getTotalBonuses()` - Get all stat bonuses
- `SpiritCrystalSystem:fuseCrystals(id1, id2)` - Combine into higher tier
- Types: crimson (ATK), azure (DEF), emerald (HP), violet (CRIT), golden (EVA)
- Tiers: 1=fragment, 2=crystal, 3=gem, 4=core

### collision_system.lua
- `CollisionSystem:isWalkable(x, y)` - Check if position walkable
- `CollisionSystem:canMove(fromX, fromY, toX, toY, radius)` - Check movement

### inventory_system.lua
- `InventorySystem:addItem(itemId)` - Add item
- `InventorySystem:removeItem(index)` - Remove item
- `InventorySystem:serialize()` / `deserialize(data)` - Save/load

### equipment_system.lua
- `EquipmentSystem:equip(slot, itemId)` - Equip item
- `EquipmentSystem:unequip(slot)` - Remove equipment
- `EquipmentSystem:getTotalStats()` - Get stat bonuses
- `EquipmentSystem:getDefensePercent()` - Get damage reduction %
- `EquipmentSystem:enhance(slot)` - Upgrade equipment
- `EquipmentSystem:getSetBonus(setName)` - Check set bonuses
- Slots: weapon, armor, helmet, accessory, boots, gloves

### party_system.lua
- `PartySystem:addMember(memberData)` - Add member
- `PartySystem:removeMember(id)` - Remove member
- `PartySystem.MAX_MEMBERS` = 5

## Sound Effect Files

| Category | Sounds |
|----------|--------|
| Combat | attack, hit, critical, block, dodge, skill, victory, defeat |
| UI | click, hover, open, close, pickup, equip, levelup |
| Character | hurt, death |

## BGM Themes

| Theme | Description |
|-------|-------------|
| exploration | Main world exploration |
| battle | Combat music |
| town | Village/town ambient |
| spring/summer/autumn/winter | Seasonal variations |
