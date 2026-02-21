# Core Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Core game systems: state management, camera, and asset loading.

## Files

| File | Description |
|------|-------------|
| `game_state.lua` | Central state machine managing all game modes |
| `camera.lua` | Viewport with follow, bounds, shake, deadzone |
| `asset_manager.lua` | Loads and caches images, fonts, sprites |

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
- `AssetManager:getCharacterSprite(id, direction)` - Get sprite
- `AssetManager:getCharacterAnimation(id, anim, dir, frame)` - Get animation frame
- `AssetManager:hasCharacterSprite(id)` - Check sprite exists
