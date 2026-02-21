# Project Structure

```
42/
├── game/                    # LÖVE 2D game client
│   ├── main.lua            # Entry point
│   ├── conf.lua            # LÖVE configuration
│   ├── account/            # Account/login system → [docs/summary.md](../game/account/docs/summary.md)
│   ├── src/
│   │   ├── core/           # Core systems → [docs/summary.md](../game/src/core/docs/summary.md)
│   │   ├── entities/       # Game entities → [docs/summary.md](../game/src/entities/docs/summary.md)
│   │   ├── systems/        # Game systems → [docs/summary.md](../game/src/systems/docs/summary.md)
│   │   ├── ui/             # UI components → [docs/summary.md](../game/src/ui/docs/summary.md)
│   │   └── animations/     # Animation system → [docs/summary.md](../game/src/animations/docs/summary.md)
│   ├── map/                # Map system → [docs/summary.md](../game/map/docs/summary.md)
│   │   ├── maps/           # Map data files (manual + generated)
│   │   ├── minimap/        # Minimap data
│   │   ├── map_manager.lua # Map loading/management
│   │   ├── map_generator.lua # Procedural map generation
│   │   └── map_registry.lua  # Map unlock/progression
│   ├── npcs/               # NPC system → [docs/summary.md](../game/npcs/docs/summary.md)
│   │   ├── npc_manager.lua   # NPC system manager
│   │   ├── npc_database.lua  # NPC definitions
│   │   ├── bosses.lua        # Boss NPCs
│   │   ├── friendly_npcs.lua # Friendly NPCs
│   │   ├── monsters.lua      # Monster NPCs
│   │   └── teleporter.lua    # Teleporter NPC
│   ├── assets/             # Images, sounds
│   └── tools/              # Test files and utilities
│
└── server/                  # Python API server → [docs/summary.md](../server/docs/summary.md)
    ├── app.py              # Main server application
    ├── requirements.txt    # Python dependencies
    └── start.sh            # Startup script
```

> 详见各模块的 `docs/summary.md` 获取详细 API 和文件说明。
