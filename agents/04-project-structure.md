# Project Structure

```
42/
├── game/                    # LÖVE 2D game client
│   ├── main.lua            # Entry point
│   ├── conf.lua            # LÖVE configuration
│   ├── account/            # Account/login system
│   ├── src/
│   │   ├── core/           # Core systems (game_state, camera, assets)
│   │   ├── entities/       # Game entities (player, enemy, map)
│   │   ├── systems/        # Game systems (battle, party, chat)
│   │   ├── ui/             # UI components
│   │   └── animations/     # Animation system
│   ├── map/                # Map data and minimaps
│   ├── npcs/               # NPC definitions
│   ├── assets/             # Images, sounds
│   └── tools/              # Test files and utilities
│
└── server/                  # Python API server
    ├── app.py              # Main server application
    ├── requirements.txt    # Python dependencies
    └── start.sh            # Startup script
```
