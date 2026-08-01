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
│   │   │   ├── enemy_data.lua   # Enemy stat/loot data tables
│   │   │   └── ...
│   │   ├── systems/        # Game systems → [docs/summary.md](../game/src/systems/docs/summary.md)
│   │   │   ├── combat_utils.lua  # Shared combat calculation functions
│   │   │   ├── item_data.lua     # Item definition data tables
│   │   │   ├── battle_simulator/ # Battle simulator
│   │   │   │   ├── sim_combatant.lua
│   │   │   │   ├── simulation_engine.lua
│   │   │   │   ├── skill_database.lua
│   │   │   │   └── init.lua
│   │   │   └── ...
│   │   ├── ui/             # UI components → [docs/summary.md](../game/src/ui/docs/summary.md)
│   │   │   ├── slot_utils.lua   # Slot/grid helper functions
│   │   │   └── ...
│   │   └── animations/     # Animation system → [docs/summary.md](../game/src/animations/docs/summary.md)
│   ├── map/                # Map system → [docs/summary.md](../game/map/docs/summary.md)
│   │   ├── maps/           # Map data files (manual + generated)
│   │   ├── minimap/        # Minimap data
│   │   ├── map_manager.lua # Map loading/management
│   │   ├── map_generator.lua # Procedural map generation
│   │   ├── map_registry.lua  # Map unlock/progression
│   │   ├── map_themes.lua     # Theme color/asset definitions
│   │   └── map_object_renderer.lua # Object layer rendering
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
└── server/                  # Rust RUDP server (UDP/9000) → [README.md](../server/README.md)
    ├── src/                # Rust source (main, packet, rudp, handlers, accounts, storage)
    ├── headless_client/    # Python client + protocol lib (tests, tooling)
    ├── test_protocol.py    # Wire-format checks (26)
    ├── test_client.py      # Live integration checks (16)
    ├── legacy_python/      # Archived Python/Sanic server (semantic reference)
    └── start.sh            # Build (if needed) + run
```

> 详见各模块的 `docs/summary.md` 获取详细 API 和文件说明。
