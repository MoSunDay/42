Commit: aaa6785

# UI 系统 - 奇幻华丽风格

## 职责
统一管理游戏 UI 的视觉风格、动画、粒子和组件系统。

## 关键模块

### 基础设施
- `src/ui/theme.lua` — 颜色方案 + 装饰绘制（金色边框、角落装饰、发光效果、渐变、羊皮纸面板、宝石图标）
- `src/ui/animation.lua` — 补间引擎（7种缓动函数）+ 面板过渡（fadeIn/scaleIn/slideIn/popIn）
- `src/ui/particles.lua` — 粒子系统（预设：goldDust, fire, heal, frost, magic, sparkle, damage, levelUp）
- `src/ui/components.lua` — 组件库（9-slice + ornate 变体），所有组件均支持 assetManager 资源加载 + 代码回退
- `src/ui/slot_utils.lua` — 共享装备槽位颜色/图标映射（纯函数：getSlotColor, getSlotIcon, getItemColor）

### 交互 UI
- `src/ui/dialog_ui.lua` — NPC 对话面板（分页、头像圆、淡入动画，F键触发）
- `src/ui/shop_ui.lua` — 商店购买界面（商品列表、详情面板、灵晶余额、买入确认）
- `src/ui/battle/reward_ui.lua` — 战斗胜利奖励（灵晶逐个揭示动画 + 金色粒子）
- `src/ui/death_screen.lua` — 死亡覆盖层（淡入 "YOU DIED" + 复活按钮）

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

## 精灵集成
- `EncounterZone` — 通过 `setAssetManager()` 使用敌人精灵，回退为圆形
- `NPCManager` — 通过 `setAssetManager()` 使用 NPC 精灵（类型映射表 `NPC_SPRITE_MAP`）
- `BattleUI.drawPlayer` — 使用角色精灵（基于 `appearanceId`），回退为圆形
- `BattleUI.drawEnemy` — 已有精灵支持

## 视觉一致性规范

所有 UI 模块必须使用 Theme 颜色引用，禁止硬编码 RGB 值：
- 属性颜色: `Theme.colors.stat.{speed,hp,crit,evasion}`
- 战斗状态: `Theme.colors.battle.{turnPlayer,turnEnemy,victory,defeat,escaped}`
- 文本层级: `Theme.colors.text` / `Theme.colors.textDim`
- 金色系: `Theme.gold.{bright,normal,dark}`
- 反馈色: `Theme.colors.{success,warning,error,info}`
- 魔法值: `Theme.colors.mp`

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
- `src/ui/components.lua` ← 所有 UI 模块
- `src/ui/slot_utils.lua` ← unified_menu, equipment_ui, inventory_ui（槽位颜色/图标查询）
- `src/ui/animation.lua` ← render_system
- `src/ui/particles.lua` ← render_system
