Commit: aaa6785

# UI 视觉风格统一 + 素材覆盖 + NPC 交互

## Context
游戏 UI 存在大量硬编码颜色（未走 Theme 系统）、缺失素材（8 角色/5 NPC 无精灵、头像不完整、4 个 UI 目录为空）、以及 NPC 系统未接入游戏循环。

## Change Summary

### 视觉一致性修复（6 文件 42 处）
- `battle_ui.lua` — 回合指示器 5 处 → `Theme.colors.battle.*`，技能面板 7 处 → `Theme.colors.*`
- `inventory_ui.lua` — SPD/HP/CRIT/EVA/价格 5 处 → `Theme.colors.stat.*` / `Theme.gold.bright`
- `unified_menu.lua` — 属性颜色 5 处 → `Theme.colors.stat.*`
- `skill_panel.lua` — 全部文本颜色 14 处 → `Theme.gold.*/text/textDim/mp/stat/success`
- `tutorial_panel.lua` — 背景遮罩 → `Components.drawOverlay`，标题/进度 → `Theme.gold.bright/colors.info`
- `avatar_renderer.lua` — 属性文本 4 处 → `Theme.colors.text/hp.high/equipment.*`

### 新增交互 UI 模块
- `src/ui/dialog_ui.lua` — NPC 对话（分页、头像、Space/ESC 控制）
- `src/ui/shop_ui.lua` — 商店购买（灵晶余额、商品列表、详情面板）
- `src/ui/battle/reward_ui.lua` — 胜利奖励（灵晶逐个揭示 + 粒子）
- `src/ui/death_screen.lua` — 死亡覆盖层（淡入 + 复活按钮）

### NPC 系统集成
- `game_state.lua` — 实例化 NPCManager，从地图数据生成 NPC，交互路由（F键），延迟战斗结算
- `render_system.lua` — 视口裁剪绘制 NPC，渲染新 UI 模块
- `input_system.lua` — F键交互，新 UI 输入路由优先级
- `npc_manager.lua` — 修复 `getNPCData` → `get_npc_data` 方法名

### 素材系统扩展
- `asset_manager.lua` — 新增 input/minimap/portraits 分类加载 + getter API
- `src/tools/placeholder_assets.lua` — LÖVE 原生占位符生成器
- `docs/PIXELLAB_GENERATION_MANIFEST.md` — ~156 张素材的 Pixellab prompt 清单
- 已生成占位符: 8 角色×8方向, 5 NPC×4方向, 24 头像×2尺寸, 8 UI 元素

## Impact Surface
- 所有 UI 模块的视觉输出（颜色统一）
- 探索模式的 NPC 交互体验（新功能）
- 战斗结束流程（奖励/死亡画面替代静默结算）
- 素材加载管线（新增分类）

## Related Docs
- [agents/game/ui.md](../../../agents/game/ui.md)
- [agents/10-art-assets.md](../../../agents/10-art-assets.md)
