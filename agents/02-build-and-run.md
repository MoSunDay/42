# Build & Run Commands

## Game (LÖVE 2D)

```bash
# Run the game
cd game && love .

# Run with debug console (macOS)
cd game && love . --console
```

## Server (Python/Sanic)

```bash
# Install dependencies
cd server && pip install -r requirements.txt

# Run the server
cd server && python app.py

# Or use the startup script (creates venv automatically)
cd server && ./start.sh

# Server runs on http://localhost:8000
```

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
