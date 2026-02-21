# Tests Module Summary

> Last updated: TBD (commit on first change)

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

## Running Tests

### Game (Lua)
```bash
# From game/tools directory
lua test_battle.lua
lua test_game.lua
lua test_boundaries.lua
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
