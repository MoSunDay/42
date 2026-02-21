# 资源生成说明

## 已完成的工作

### 1. 代码修改
- **AssetManager** (`game/src/core/asset_manager.lua`)
  - 添加敌人精灵加载 (`loadEnemySprites`)
  - 添加NPC精灵加载 (`NPCSprites`)
  - 添加地图物件加载 (`loadMapObjects`)
  - 新增获取敌人/NPC/地图物件的方法

- **Enemy** (`game/src/entities/enemy.lua`)
  - 添加 `assetManager` 支持
  - 添加 `hasSprite()`, `getSprite()`, `getAnimation()` 方法
  - 添加动画更新逻辑

- **BattleUI** (`game/src/ui/battle/battle_ui.lua`)
  - 添加 `assetManager` 参数
  - 修改 `drawEnemy()` 支持真实精灵
  - 保留回退到颜色圆形的逻辑

- **BattleSystem** (`game/src/systems/battle/battle_system.lua`)
  - 添加 `assetManager` 参数
  - 传递 `assetManager` 给 Enemy

- **RenderSystem** (`game/src/systems/render_system.lua`)
  - 传递 `assetManager` 给 BattleUI

- **GameState** (`game/src/core/game_state.lua`)
  - 传递 `assetManager` 给 BattleSystem

### 2. 资源生成脚本
- `tools/generate_assets.py` - 提交所有资源生成任务
- `tools/check_status.py` - 检查生成状态
- `tools/download_assets.py` - 下载完成的资源
- `tools/queue_animations.py` - 排队动画任务

### 3. MCP 配置
- `.mcp.json` - PixelLab MCP 配置文件

## 待生成的资源

### 角色 (22个)
- hero (玩家角色, 8方向)
- 16种敌人 (slime, goblin, skeleton, bat, orc_warrior, skeleton_knight, wolf, dark_mage, orc_chieftain, vampire, golem, demon, ancient_dragon, lich_king, chaos_serpent)
- 5种NPC (village_chief, spring_guardian, summer_merchant, autumn_innkeeper, winter_priest)

### 地形瓦片 (6组)
- ocean_beach
- beach_grass
- grass_path
- forest_floor
- summer_grass
- autumn_leaves

## 使用方法

### 检查生成状态
```bash
cd tools && python3 check_status.py status
```

### 下载完成的资源
```bash
cd tools && python3 download_assets.py
```

### 运行游戏
```bash
cd game && love .
```

## 资源文件结构

```
game/assets/images/
├── characters/
│   ├── hero/
│   │   ├── rotations/      # 8方向
│   │   └── animations/
│   │       ├── walking/
│   │       └── breathing-idle/
│   ├── enemies/
│   │   ├── slime/
│   │   ├── goblin/
│   │   └── ... (16种敌人)
│   └── npcs/
│       ├── village_chief/
│       └── ... (5种NPC)
└── tilesets/
    ├── terrain/
    │   ├── ocean_beach.png
    │   ├── beach_grass.png
    │   └── ...
    └── objects/
        ├── trees/
        ├── buildings/
        └── props/
```

## 注意事项

1. **生成时间**: PixelLab 资源生成通常需要 2-5 分钟
2. **动画排队**: 角色创建完成后需要单独排队动画任务
3. **下载限制**: 下载链接 8 小时后过期
4. **回退机制**: 如果没有精灵资源，游戏会使用颜色圆形作为回退

## API Token

当前使用的 API Token: `${PIXELLAB_API_KEY:-}`

如需更换，修改:
- `.mcp.json`
- `tools/generate_assets.py`
- `tools/check_status.py`
- `tools/download_assets.py`
- `tools/queue_animations.py`
