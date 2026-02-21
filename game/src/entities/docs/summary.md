# Entities Module Summary

> Last updated: 0b5db5a - UI components + NPC expansion

## Purpose
Game entities: player, enemies, maps, and encounter zones.

## Files

| File | Description |
|------|-------------|
| `player.lua` | Player entity with movement, stats, equipment |
| `enemy.lua` | Enemy entity with 4-tier difficulty system and AI |
| `map.lua` | Basic map with town layout (fallback) |
| `encounter_zone.lua` | Visible monsters (明雷) that trigger battles |

## Key APIs

### player.lua
- `Player.new(x, y, assetManager)` - Create player
- `Player:moveTo(x, y)` - Set movement target
- `Player:update(dt)` - Update position/animation
- `Player:takeDamage(damage)` - Apply damage with defense
- `Player:updateStatsWithEquipment()` - Recalculate stats
- `Player:setAppearance(character)` - Set visual appearance
- `Player:setMapBounds(width, height)` - Set movement boundaries

### enemy.lua
- `Enemy.new(enemyType, assetManager)` - Create enemy by type
- `Enemy.getRandomType()` - Get random type (weighted by tier)
- `Enemy.getTypesByTier(tier)` - Get enemies by tier (1-4)
- `Enemy:decideAction(player)` - AI decision (attack/defend/skill)
- `Enemy:takeDamage(damage)` - Apply damage
- `Enemy:isAlive()` - Check if enemy is alive
- `Enemy:update(dt)` - Update enemy state

### encounter_zone.lua
- `EncounterZone.new(x, y, radius)` - Create visible monster
- `EncounterZone:contains(x, y)` - Check collision
- `EncounterZone:trigger()` - Activate battle
- `EncounterZone:getEnemyType()` - Get battle enemy type

## Enemy Tiers

| Tier | Name | Spawn Rate | Examples |
|------|------|------------|----------|
| 1 | Common | 50% | slime, goblin, skeleton, bat |
| 2 | Elite | 30% | orc_warrior, wolf, dark_mage |
| 3 | Boss | 15% | orc_chieftain, vampire, golem |
| 4 | Legendary | 5% | ancient_dragon, lich_king |

## Enemy AI Behavior

Enemies use a decision system for combat:
- **Attack** - Basic damage dealing
- **Defend** - Reduce incoming damage
- **Skill** - Use special abilities (when available)

AI decisions are based on:
- Current HP percentage
- Player's relative strength
- Enemy type tendencies

## Enemy Stats by Tier

| Tier | HP Multiplier | ATK Multiplier | DEF Multiplier |
|------|---------------|----------------|----------------|
| 1 | 1.0x | 1.0x | 1.0x |
| 2 | 1.5x | 1.3x | 1.2x |
| 3 | 2.5x | 1.8x | 1.5x |
| 4 | 4.0x | 2.5x | 2.0x |
