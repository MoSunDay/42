# Map System - 地图系统

## 目录结构

```
map/
├── README.md           # 本文档
├── map_manager.lua     # 地图管理器
├── map_data.lua        # 地图数据结构
├── maps/               # 具体地图数据
│   ├── town_01.lua     # 城镇地图
│   └── ...
└── minimap/            # 小地图数据
    ├── town_01.lua     # 城镇小地图
    └── ...
```

## 地图数据格式

每个地图包含：
- **全地图数据**：完整的地图信息（尺寸、图块、碰撞等）
- **小地图数据**：简化的地图预览

## 使用方法

```lua
local MapManager = require("map.map_manager")

-- 加载地图
local map = MapManager.loadMap("town_01")

-- 获取小地图
local minimap = MapManager.getMinimap("town_01")
```

