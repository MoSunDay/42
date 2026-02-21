# Tests Module Summary

> Last updated: 0b5db5a - UI components + NPC expansion

## Purpose
Unit tests for game client and server.

## Directories

| Directory | Description |
|-----------|-------------|
| `tests/game/` | Lua game client tests |
| `tests/server/` | Python server tests |

## Game Tests Structure

```
tests/game/
├── mocks/           # Mock objects for testing
├── core/            # Core system tests
├── entities/        # Entity tests
├── network/         # Network tests
└── systems/         # System tests
    └── battle/      # Battle system tests
```

## Test Files (game/tools/)

| Test File | Coverage |
|-----------|----------|
| `test_battle.lua` | Enemy creation, damage, death, tier system |
| `test_game.lua` | Module loading, player movement, camera |
| `test_boundaries.lua` | Map boundary restrictions |
| `test_audio.lua` | Audio file loading, fallback generation, BGM themes |
| `test_tiled.lua` | Tiled JSON parsing, layers, objects, properties |
| `test_companion.lua` | Companion templates, party management, leveling |
| `test_spirit_crystal.lua` | Crystal types/tiers, collection, fusion |
| `test_equipment.lua` | Equipment slots, stats, enhancement, set bonuses |

## Running Tests

### Game (Lua)
```bash
# From game/tools directory
cd game/tools

# Core tests
lua test_battle.lua
lua test_game.lua
lua test_boundaries.lua

# New system tests
lua test_audio.lua
lua test_tiled.lua
lua test_companion.lua
lua test_spirit_crystal.lua
lua test_equipment.lua
```

### Server (Python)
```bash
cd tests/server
pytest
```

## Test Accounts

| Username | Password | Purpose |
|----------|----------|---------|
| test | 123 | Basic testing |
| admin | admin | Admin features |
| player | pass | Player features |

## Mock Objects

Located in `tests/game/mocks/`:
- Mock love graphics
- Mock network
- Mock assets
- Mock audio system
