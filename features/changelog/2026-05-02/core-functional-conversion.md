Commit: HEAD

# Core Modules (GameState, AssetManager) + Entry Point OOP → Pure Functional

## Context

Global coding rules mandate pure functional style. The core coordinator (`game_state.lua`) and asset manager (`asset_manager.lua`) still used OOP patterns with metatables and colon-syntax methods. The entry point (`main.lua`) used colon calls on these modules.

## Change Summary

Converted 2 core modules from OOP to pure functional style:

- `game/src/core/asset_manager.lua` — removed `__index`/`setmetatable`, `.new()` → `.create()` returning plain table, all `self:` → dot syntax with `state` param; internal helper `loadSpritesForIds` updated to take `state` instead of `self`
- `game/src/core/game_state.lua` — removed `__index`/`setmetatable`, `.new()` → `.create()` returning plain table, all `self:` → `state.`, all internal `self:method()` → `GameState.method(state, ...)`; all cross-module calls converted: `Player.update(state.player, dt)`, `Camera.follow(state.camera, ...)`, `BattleSystem.startBattle(state.battleSystem, ...)`, `AudioSystem.playBGM(state.audioSystem, ...)`, `CollisionSystem.isWalkable(state.collisionSystem, ...)`, `EquipmentSystem.serialize(state.equipmentSystem)`, `InventorySystem.addItem(state.inventorySystem, ...)`, `SpiritCrystalSystem.addCrystal(state.spiritCrystalSystem, ...)`, `SkillPanel.update(state.skillPanel, dt)`, etc.

Updated entry point and callers:

- `game/main.lua` — `AssetManager.new()` → `AssetManager.create()`, `GameState.new()` → `GameState.create()`; all `game.state:method()` → `GameState.method(game.state, ...)`, all `game.assetManager:method()` → `AssetManager.method(game.assetManager, ...)`
- `game/tools/test_game.lua` — same pattern
- `game/tools/test_boundaries.lua` — same pattern

## Impact Surface

- All callers of AssetManager and GameState must use dot syntax: `AssetManager.loadAll(am)`, `GameState.update(state, dt)`
- `AssetManager.new()` no longer exists; use `AssetManager.create()`
- `GameState.new()` no longer exists; use `GameState.create()`
- Subsystems still using OOP (NetworkManager, LoginUI, CharacterSelectUI, PartySystem, ChatSystem, CompanionSystem) are called via `Module.method(obj, ...)` from GameState which works via their `__index` metatable dispatch

## Notes

- game_state.lua is the central coordinator; it now holds ~18 subsystem references as plain table fields and delegates to them via functional call syntax
- Some subsystems (PartySystem, ChatSystem, CompanionSystem, NetworkManager, LoginUI, CharacterSelectUI) still use OOP internally; calling them with `Module.method(obj, ...)` is functionally equivalent to `obj:method(...)` due to their `__index` setup
