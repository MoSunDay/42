# Build & Run Commands

## Game (LÖVE 2D)

```bash
# Run the game
cd game && love .

# Run with debug console (macOS)
cd game && love . --console
```

## Server (Rust RUDP)

```bash
# Build and run (binds 0.0.0.0:9000 UDP; start.sh builds if missing)
cd server && ./start.sh
# or: cd server && cargo run --release

# Unit/integration tests (no server needed)
cd server && cargo test              # 27 tests

# Wire-format checks (no server needed)
cd server && python3 test_protocol.py   # 26 checks

# Live integration (server must be running)
cd server && python3 test_client.py     # 16 checks
```

Server source lives in `server/src/` (Rust). The old Python/Sanic server is
archived in `server/legacy_python/` and is not run by `start.sh`; it remains
the semantic reference for protocol behavior. Client-side protocol reference:
`server/headless_client/protocol/` (mirrors `game/src/network/`). See
`server/README.md` for the wire format and message-type table.

> Note: `game/conf.lua` requires LÖVE >= 11.3 (tested on 11.3; 11.4+ shows a
> version compatibility dialog that can block headless automation).

## Testing

### Running Tests

```bash
# All Lua tests (from game/tools directory)
cd game/tools && lua test_battle.lua        # Battle system tests
cd game/tools && lua test_game.lua          # Core module tests
cd game/tools && lua test_boundaries.lua    # Boundary tests
cd game/tools && lua test_audio.lua         # Audio system tests
cd game/tools && lua test_tiled.lua         # Tiled map loading tests
cd game/tools && lua test_companion.lua     # Companion system tests
cd game/tools && lua test_spirit_crystal.lua # Spirit crystal tests
cd game/tools && lua test_equipment.lua     # Equipment system tests
```

### Test Coverage

| Test File | Coverage |
|-----------|----------|
| `test_battle.lua` | Enemy creation, damage, death |
| `test_game.lua` | Module loading, player movement, camera |
| `test_boundaries.lua` | Map boundary restrictions |
| `test_audio.lua` | SFX/BGM loading, fallback generation |
| `test_tiled.lua` | JSON parsing, layers, objects |
| `test_companion.lua` | Templates, leveling, party management |
| `test_spirit_crystal.lua` | Crystal types, tiers, fusion |
| `test_equipment.lua` | Slots, stats, enhancement, sets |

### Manual API testing (server must be running)
```bash
curl http://localhost:8000/api/health
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"123"}'
```

### Test Accounts

| Username | Password | Level |
|----------|----------|-------|
| test     | 123      | 5     |
| admin    | admin    | 10    |
| player   | pass     | 1     |
