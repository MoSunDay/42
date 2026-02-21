# Build & Run Commands

## Game (LÖVE 2D)

```bash
# Run the game
cd game && love .

# Run with debug console (macOS)
cd game && love . --console

# Run specific test files
cd game/tools && lua test_battle.lua
cd game/tools && lua test_game.lua
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
# Lua tests (from game/tools directory)
cd game/tools && lua test_battle.lua      # Battle system tests
cd game/tools && lua test_game.lua        # Core module tests
cd game/tools && lua test_boundaries.lua  # Boundary tests

# Manual API testing (server must be running)
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
