Commit: TBD

# UI 系统 - PixelLab 像素风格 (Login/Select/Create)

## 职责
统一管理游戏 UI 的视觉风格、动画、粒子和组件系统。

## 视觉风格

### PixelLab 风格 (Login / Character Select / Character Create)
灵感来源于 [pixellab.ai](https://www.pixellab.ai)，简洁的像素艺术 UI 设计：

- **深色背景**: 渐变从 `#0f131c` 到 `#141b23`
- **霓虹强调色**: 青色 `#4db5e6` / 绿色 `#4ee666` / 蓝色 `#4590e6`
- **像素边框**: 简洁的 2px 直线边框，无圆角
- **内嵌边框**: 面板内 3px 偏移的淡色内边框
- **按钮**: 带底部分割线的填充矩形，hover 时高亮上半部
- **点状步进器**: 实心圆点 + 连接线，替代菱形分隔符
- **简洁分隔符**: 简单横线，替代金色装饰分隔符

### 奇幻华丽风格 (Battle / Inventory / HUD 等内玩 UI)
保留原有风格，用于游戏内界面：
- **金色系**: `Theme.gold.bright/normal/dark/glow/shimmer`
- **羊皮纸**: `Theme.parchment.light/mid/dark/border/text`
- **宝石**: `Theme.gem.ruby/sapphire/emerald/topaz/amethyst/diamond`

## 关键模块

### 基础设施
- `src/ui/theme.lua` — 双风格颜色方案 + 装饰绘制
  - `Theme.colors.*` — 通用颜色 (battle/inventory/etc.)
  - `Theme.gold.*` / `Theme.parchment.*` / `Theme.gem.*` — 奇幻风格装饰
  - `Theme.pixelLab.colors.*` — PixelLab 像素风格颜色
  - `Theme.pixelLab.drawPanel/Border/Button/Separator/Dot/Input` — 像素风格绘制
- `src/ui/animation.lua` — 补间引擎（7种缓动函数）+ 面板过渡（fadeIn/scaleIn/slideIn/popIn）
- `src/ui/particles.lua` — 粒子系统（预设：goldDust, fire, heal, frost, magic, sparkle, damage, levelUp）
- `src/ui/components.lua` — 组件库（9-slice + ornate 变体），用于内玩 UI
- `src/ui/slot_utils.lua` — 共享装备槽位颜色/图标映射

### 交互 UI
- `src/ui/dialog_ui.lua` — NPC 对话面板（分页、头像圆、淡入动画，F键触发）
- `src/ui/shop_ui.lua` — 商店购买界面（商品列表、详情面板、灵晶余额、买入确认）
- `src/ui/battle/reward_ui.lua` — 战斗胜利奖励（灵晶逐个揭示动画 + 金色粒子）
- `src/ui/death_screen.lua` — 死亡覆盖层（淡入 "YOU DIED" + 复活按钮）

### Account UI (PixelLab Style)
- `account/login_ui.lua` — 登录/注册界面（深色渐变背景、像素面板、霓虹按钮、输入框）
- `account/character_select_ui.lua` — 角色选择/创建（3步：姓名→职业→外观，点状步进器、像素面板、像素血条）

## 资源消费架构

所有 ornate 组件遵循 **asset-first, code-fallback** 模式：
1. 如果传入 `assetManager`，尝试加载对应 PNG 资源
2. 资源不存在时回退为代码绘制的圆角矩形
3. 装饰效果（金色边框、角落装饰、发光）在资源之上叠加

### 资源加载路径
| 组件 | 资源路径 | 回退 |
|------|---------|------|
| `drawOrnatePanel` | `getUIPanel(style)` 默认 `"small_panel"` | 圆角矩形 + 金边/角落/发光 |
| `drawOrnateButton` | `getUIButton("button_"..state)` | 圆角矩形 + 金边 |
| `drawOrnateHPBar` | `getUIBar("hp_bar_bg")` + `getUIBar("hp_bar_high/medium/low")` | 渐变填充 |
| `drawOrnateMPBar` | `getUIBar("mp_bar_bg")` + `getUIBar("mp_bar_fill")` | 渐变填充 |
| `drawXPBar` | `getUIBar("exp_bar_bg")` + `getUIBar("exp_bar_fill")` | 渐变填充 |
| `drawInput` | `getUIAsset("input", name)` | 圆角输入框 |
| `drawTab` | `getUIAsset("tabs", name)` | 彩色矩形 |
| `drawSlot` | `getUISlot("slot_"..state)` | 圆角方格 |
| `drawDialog` / `drawTooltip` | `getDialogAsset(name)` | 圆角面板 |

## PixelLab 组件 API

- `Theme.pixelLab.drawPanel(x, y, w, h, {bg, borderColor, borderWidth, hovered, innerBorder})`
- `Theme.pixelLab.drawButton(x, y, w, h, text, state, font, {hover})` — states: primary/danger/disabled/normal
- `Theme.pixelLab.drawBorder(x, y, w, h, color, width)`
- `Theme.pixelLab.drawSeparator(x1, x2, y, color)`
- `Theme.pixelLab.drawDot(x, y, size, color)`
- `Theme.pixelLab.drawDotLine(x1, x2, y, isActive, color)`
- `Theme.pixelLab.drawInput(x, y, w, h, isActive)`

## 奇幻风格颜色
- **金色系**: `Theme.gold.bright/normal/dark/glow/shimmer`
- **羊皮纸**: `Theme.parchment.light/mid/dark/border/text`
- **宝石**: `Theme.gem.ruby/sapphire/emerald/topaz/amethyst/diamond`

## Ornate 组件
- `Components.drawOrnatePanel(x, y, w, h, am, {style, title, corners, glow, shimmer})`
- `Components.drawOrnateButton(x, y, w, h, text, state, am, font, {gemColor})`
- `Components.drawOrnateHPBar(x, y, w, h, percent, level, am)` — 资源/渐变 + 低血量脉冲
- `Components.drawOrnateMPBar(x, y, w, h, percent, am)` — 资源/渐变
- `Components.drawGemButton(x, y, size, gemColor, isHovered, isPressed)`
- `Components.drawOrnateDialog(x, y, w, h, am, speakerName)`

## 装饰辅助函数 (Theme)
- `Theme.drawGoldBorder(x, y, w, h, thickness)`
- `Theme.drawCornerOrnaments(x, y, w, h, size)`
- `Theme.drawGlow(x, y, w, h, color, intensity)`
- `Theme.drawGradient(x, y, w, h, colorTop, colorBottom, steps)`
- `Theme.drawParchmentPanel(x, y, w, h, borderThickness)`
- `Theme.drawShimmer(x, y, w, h, speed)`
- `Theme.drawDiamondSeparator(cx, y, width)`

## 主循环集成
`render_system.lua` 的 `update(dt)` 调用:
```
Animation.update(dt) → Theme.update(dt) → Particles.update(dt) → BattleBackground.update(dt)
```
`renderUI()` 末尾调用 `Particles.draw()`

## 视觉一致性规范

所有 UI 模块必须使用 Theme 颜色引用，禁止硬编码 RGB 值：
- 属性颜色: `Theme.colors.stat.{speed,hp,crit,evasion}`
- 战斗状态: `Theme.colors.battle.{turnPlayer,turnEnemy,victory,defeat,escaped}`
- 文本层级: `Theme.colors.text` / `Theme.colors.textDim`
- 金色系: `Theme.gold.{bright,normal,dark}`
- 反馈色: `Theme.colors.{success,warning,error,info}`
- 魔法值: `Theme.colors.mp`
- PixelLab 色: `Theme.pixelLab.colors.{neonCyan,neonGreen,neonBlue,neonPink,neonYellow,neonPurple}`
- PixelLab 文本: `Theme.pixelLab.colors.{text,textDim,textMuted}`

## NPC 交互集成

NPC 系统通过 `game_state.lua` 集成到游戏循环：
- `NPCManager` 在 `initialize_world` 中从地图数据生成 NPC
- `render_system` 在 camera 变换下绘制可见 NPC（视口裁剪）
- `input_system` 的 F 键触发 `interact_nearby_npc`，按距离排序后：
  - 商人 NPC (canTrade + shop) → `ShopUI.open`
  - 可对话 NPC (canTalk/dialogue) → `DialogUI.open`
- 战斗胜利/失败通过 `pendingBattleResult` 机制延迟结算，先展示 RewardUI / DeathScreen

## 素材工具
- `src/tools/placeholder_assets.lua` — LÖVE 原生占位符生成器（角色/NPC/头像/UI 元素）
- `docs/PIXELLAB_GENERATION_MANIFEST.md` — Pixellab API 批量生成清单（~156 张素材的 prompt 和规格）
- 运行: `love game --generate-assets`

## 依赖
- `src/ui/theme.lua` ← 所有 UI 模块
- `src/ui/components.lua` ← 内玩 UI 模块
- `src/ui/slot_utils.lua` ← unified_menu, equipment_ui, inventory_ui
- `src/ui/animation.lua` ← render_system
- `src/ui/particles.lua` ← render_system
- `account/login_ui.lua` ← 直接使用 Theme.pixelLab (无 Components 依赖)
- `account/character_select_ui.lua` ← 直接使用 Theme.pixelLab (无 Components 依赖)
