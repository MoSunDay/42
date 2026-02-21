# Common Tasks

## Adding a New Enemy Type

1. Edit `src/entities/enemy.lua`
2. Add to `ENEMY_DATA` table with stats

## Adding a New Map

1. Create `map/maps/map_name.lua` with tile data
2. Create `map/minimap/map_name.lua` for minimap
3. Register in `map/map_manager.lua`

## Adding a New Battle Action

1. Add action to `src/systems/battle/battle_system.lua`
2. Update UI in `src/ui/battle/battle_menu.lua`
3. Add animation in `src/systems/battle/battle_animation.lua`
