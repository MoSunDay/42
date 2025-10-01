# 开发文档

## 项目架构

本项目采用模块化架构设计，遵循以下原则：

### 1. 核心原则

- **单一职责**: 每个模块只负责一个功能
- **代码行数限制**: 每个文件不超过 400 行
- **模块化**: 功能独立，易于测试和维护
- **可扩展性**: 预留扩展接口

### 2. 目录结构说明

```
game/
├── main.lua                    # 游戏入口，初始化各个系统
├── conf.lua                    # Love2D 配置
├── src/
│   ├── core/                   # 核心系统（不依赖具体游戏逻辑）
│   │   ├── game_state.lua      # 游戏状态管理
│   │   ├── asset_manager.lua   # 资源加载和管理
│   │   └── camera.lua          # 相机系统
│   ├── entities/               # 游戏实体（具有状态和行为的对象）
│   │   ├── player.lua          # 玩家实体
│   │   ├── map.lua             # 地图实体
│   │   └── enemy.lua           # 敌人实体（待实现）
│   ├── systems/                # 游戏系统（处理特定类型的逻辑）
│   │   ├── input_system.lua    # 输入处理
│   │   ├── render_system.lua   # 渲染管理
│   │   └── combat_system.lua   # 战斗系统（待实现）
│   └── ui/                     # 用户界面
│       ├── hud.lua             # 游戏内HUD
│       └── menu.lua            # 菜单界面（待实现）
├── assets/                     # 资源文件
└── docs/                       # 文档
```

### 3. 模块职责

#### Core 模块

**game_state.lua**
- 管理游戏的全局状态
- 持有所有游戏实体的引用
- 协调各个系统的更新

**asset_manager.lua**
- 统一加载和管理所有资源
- 提供资源访问接口
- 处理资源缺失的降级方案

**camera.lua**
- 管理游戏视角
- 提供世界坐标和屏幕坐标的转换
- 实现平滑跟随效果

#### Entities 模块

**player.lua**
- 玩家角色的状态和行为
- 移动逻辑
- 动画状态管理

**map.lua**
- 地图数据和渲染
- 碰撞检测（待实现）
- 地图瓦片管理

#### Systems 模块

**input_system.lua**
- 处理所有用户输入
- 将输入转换为游戏指令
- 支持鼠标和键盘

**render_system.lua**
- 统一管理所有渲染逻辑
- 分层渲染（世界层、UI层）
- 相机变换应用

#### UI 模块

**hud.lua**
- 游戏内信息显示
- 坐标面板
- 小地图
- FPS 显示

## 代码规范

### Lua 编码规范

1. **命名规范**
   - 模块名: PascalCase (如 `GameState`)
   - 函数名: camelCase (如 `moveTo`)
   - 变量名: camelCase (如 `playerX`)
   - 常量名: UPPER_SNAKE_CASE (如 `MAX_SPEED`)

2. **缩进和格式**
   - 使用 4 个空格缩进
   - 函数之间空一行
   - 逻辑块之间适当空行

3. **注释**
   - 文件头注释说明模块功能
   - 复杂逻辑添加行内注释
   - 公共函数添加功能说明

### 模块模板

```lua
-- module_name.lua - 模块简短描述
-- 详细说明模块的职责和功能

local ModuleName = {}
ModuleName.__index = ModuleName

-- 构造函数
function ModuleName.new(param1, param2)
    local self = setmetatable({}, ModuleName)
    
    -- 初始化属性
    self.property1 = param1
    self.property2 = param2
    
    return self
end

-- 公共方法
function ModuleName:publicMethod()
    -- 实现
end

-- 私有方法（使用 local）
local function privateHelper()
    -- 实现
end

return ModuleName
```

## 扩展指南

### 添加新实体

1. 在 `src/entities/` 创建新文件
2. 实现 `new()`, `update(dt)`, `draw()` 方法
3. 在 `game_state.lua` 中创建和管理实例

### 添加新系统

1. 在 `src/systems/` 创建新文件
2. 接收 `gameState` 作为参数
3. 实现系统特定的逻辑
4. 在 `main.lua` 中初始化

### 添加新资源

1. 将资源文件放到 `assets/` 对应目录
2. 在 `asset_manager.lua` 中添加加载逻辑
3. 通过 `assetManager:getXXX()` 访问

## 性能优化建议

1. **避免频繁创建对象**
   - 使用对象池
   - 重用临时变量

2. **优化渲染**
   - 只渲染可见区域
   - 使用批量渲染
   - 合理使用 Canvas

3. **减少计算**
   - 缓存计算结果
   - 使用增量更新
   - 避免不必要的数学运算

## 调试技巧

1. **使用 print 调试**
   ```lua
   print(string.format("Player pos: (%.2f, %.2f)", x, y))
   ```

2. **可视化调试**
   - 绘制碰撞盒
   - 显示调试信息
   - 使用不同颜色标记状态

3. **性能分析**
   - 监控 FPS
   - 使用 Love2D 的性能分析工具

## 测试

### 手动测试清单

- [ ] 鼠标点击移动功能
- [ ] 坐标显示正确
- [ ] 小地图显示正确
- [ ] 相机跟随流畅
- [ ] 边界检测正常
- [ ] FPS 稳定在 60

### 未来计划

- 添加单元测试框架
- 实现自动化测试
- 性能基准测试

## 常见问题

**Q: 如何修改地图大小？**
A: 修改 `src/entities/map.lua` 中的 `width` 和 `height` 参数。

**Q: 如何调整玩家移动速度？**
A: 修改 `src/entities/player.lua` 中的 `speed` 属性。

**Q: 如何添加新的 UI 元素？**
A: 在 `src/ui/hud.lua` 中添加新的绘制方法，或创建新的 UI 模块。

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 遵循代码规范
4. 提交 Pull Request
5. 等待代码审查

## 参考资源

- [Love2D 官方文档](https://love2d.org/wiki/Main_Page)
- [Lua 5.1 参考手册](https://www.lua.org/manual/5.1/)
- [游戏编程模式](https://gameprogrammingpatterns.com/)

