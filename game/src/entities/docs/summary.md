# Entities Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Game entities: player, enemies, maps, and encounter zones.

## Files

| File | Description |
|------|-------------|
| `player.lua` | Player entity with movement, stats, equipment |
| `enemy.lua` | Enemy entity with 4-tier difficulty system |
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

### enemy.lua
- `Enemy.new(enemyType, assetManager)` - Create enemy by type
- `Enemy.getRandomType()` - Get random type (weighted by tier)
- `Enemy.getTypesByTier(tier)` - Get enemies by tier (1-4)
- `Enemy:decideAction(player)` - AI decision (attack/defend)

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
