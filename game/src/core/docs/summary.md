# Core Module Summary

> Last updated: 0b5db5a - UI components + NPC expansion

## Purpose
Core game systems: state management, camera, and asset loading.

## Files

| File | Description |
|------|-------------|
| `game_state.lua` | Central state machine managing all game modes |
| `camera.lua` | Viewport with follow, bounds, shake, deadzone |
| `asset_manager.lua` | Loads and caches images, fonts, sprites, sounds |

## Key APIs

### game_state.lua
- `GameState.new(assetManager)` - Create game state
- `GameState:update(dt)` - Main update loop
- `GameState:initializeWorld(character)` - Setup after login
- `GameState:startBattle()` / `endBattle()` - Battle transitions
- `GameState.MODE` - LOGIN, CHARACTER_SELECT, EXPLORATION, BATTLE

### camera.lua
- `Camera:follow(x, y, dt)` - Smooth follow target
- `Camera:toWorld(screenX, screenY)` - Screen to world coords
- `Camera:toScreen(worldX, worldY)` - World to screen coords
- `Camera:startShake(intensity, duration)` - Screen shake effect
- `Camera:setBounds(width, height)` - Limit camera to map

### asset_manager.lua
- `AssetManager:loadAll()` - Load all resources
- `AssetManager:loadSounds()` - Load sound files from assets/sounds/
- `AssetManager:getCharacterSprite(id, direction)` - Get sprite
- `AssetManager:getCharacterAnimation(id, anim, dir, frame)` - Get animation frame
- `AssetManager:hasCharacterSprite(id)` - Check sprite exists
- `AssetManager:getSound(name)` - Get cached sound

## Asset Paths

| Type | Path |
|------|------|
| Images | `assets/images/` |
| Fonts | `assets/fonts/` |
| Sounds | `assets/sounds/` |
| Characters | `assets/images/characters/` |
| Enemies | `assets/images/characters/enemies/` |
| NPCs | `assets/images/characters/npcs/` |
| Tilesets | `assets/images/tilesets/` |
| UI | `assets/images/ui/` |

## Sound Loading

The asset manager loads sounds from the following structure:
```
assets/sounds/
├── bgm/           # Background music (.ogg/.wav)
├── bgm/seasonal/  # Seasonal variations
└── sfx/           # Sound effects
    ├── combat/
    ├── ui/
    └── character/
```
