Commit: 99b2fb0a7c35b83446570e7572de829cc3946902

# UI 奇幻华丽风格全面升级

## Context
游戏 UI 原先使用简单的圆角矩形和圆形绘制，视觉风格单调。此次升级为奇幻华丽 RPG 风格，加入金色边框、宝石图标、发光效果和粒子系统。

## Change Summary

### 新增模块
- `src/ui/animation.lua` — 补间动画引擎（7种缓动 + 面板过渡 + 脉冲动画）
- `src/ui/particles.lua` — 粒子系统（8种预设：goldDust, fire, heal, frost, magic, sparkle, damage, levelUp）

### Theme 增强
- 金色系颜色 (`Theme.gold.*`)
- 羊皮纸颜色 (`Theme.parchment.*`)
- 宝石颜色 (`Theme.gem.*`)
- 9个装饰绘制函数（金色边框、角落装饰、发光、渐变、羊皮纸面板、宝石图标、装饰线、闪光、菱形分隔符）
- `Theme.update(dt)` 驱动动画时间

### Components 增强（asset-first, code-fallback）
- `drawOrnatePanel` — 使用 `getUIPanel(style)` 加载面板 PNG，叠加角落装饰 + 发光
- `drawOrnateButton` — 使用 `getUIButton("button_"..state)` 加载按钮 PNG
- `drawOrnateHPBar` — 使用 `getUIBar("hp_bar_bg/high/medium/low")` 加载血条 PNG，回退为渐变填充
- `drawOrnateMPBar` — 使用 `getUIBar("mp_bar_bg/mp_bar_fill")` 加载蓝条 PNG，回退为渐变填充
- `drawXPBar` — 使用 `getUIBar("exp_bar_bg/exp_bar_fill")` 加载经验条 PNG，回退为渐变填充（预留，尚无调用者）
- `drawInput` — 使用 `getUIAsset("input", name)` 加载输入框 PNG
- `drawTab` — 使用 `getUIAsset("tabs", name)` 加载标签 PNG
- `drawGemButton`, `drawScrollbar`, `drawOrnateDialog`, `drawRarityBorder`, `drawSprite`
- 已清理废弃函数：`drawPanel`, `drawPanelSimple`, `drawButton`, `drawButtonSimple`, `drawSlotSimple`

### 调用者修复（assetManager 传递）
- `avatar_renderer.lua` — `drawCharacterPanel` 和 `drawHPBar` 新增 `assetManager` 参数
- `render_system.lua` — 向 `AvatarRenderer.drawCharacterPanel` 传入 `self.assetManager`
- `battle_panels.lua` — `drawHPBar` 向 `drawOrnateHPBar` 传递 `assetManager`
- `battle_menu.lua` — `drawTimer` 向 `drawOrnateHPBar` 传递 `assetManager`
- `unified_menu.lua` — HP 条和标签页均传入 `self.assetManager`
- `login_ui.lua` — 背景叠加 `login_panel` 资源，输入框使用 `drawInput`，标签使用 `drawTab`，面板使用 `style="login_panel"`

### UI 模块升级
- `hud.lua` — 全面重写：ornate 面板 minimap + 宝石风格操作按钮
- `chat_ui.lua` — 全面重写：ornate 面板 + 金色发送者名
- `unified_menu.lua` — ornate 面板/按钮/HP条 + 资源化标签页 + 装备槽 drawOrnatePanel
- `fullscreen_map.lua` — ornate 面板 + 金色标题
- `party_ui.lua` — ornate 面板 + 宝石头像 + ornate HP/MP条
- `pet_ui.lua` — ornate 面板 + 宝石图标 + ornate HP条
- `skill_panel.lua` — ornate 面板/按钮 + 资源化标签页/列表容器 + 选中项发光
- `button_ui.lua` — drawButtonSimple → drawOrnateButton + assetManager
- `equipment_ui.lua` — drawOrnatePanel 带 assetManager + 装备槽 ornate 面板
- `login_ui.lua` — ornate 面板/按钮 + 资源化标签/输入框 + login_panel 背景
- `character_select_ui.lua` — ornate 面板/按钮/角色卡片 + drawInput 带 assetManager

### 非UI模块升级
- `chat_system.lua` — 语音气泡从原始矩形升级为 drawOrnatePanel + 金色尾巴线条

### 战斗系统升级
- `battle_background.lua` — 渐变背景 + 浮动粒子
- `battle_menu.lua` — ornate 面板/按钮 + 宝石颜色动作按钮
- `battle_panels.lua` — ornate 面板/HP条 + 金色标题

### 精灵集成
- `encounter_zone.lua` — 新增 `setAssetManager()` + 敌人精灵绘制（回退圆形）
- `npc_manager.lua` — 新增 `setAssetManager()` + NPC 精灵绘制 + 类型映射
- `battle_ui.lua:drawPlayer` — 使用角色精灵（基于 appearanceId）

### 渲染管线
- `render_system.lua` — 集成 Animation/Theme/Particles/BattleBackground 的 update + Particles.draw

## Impact Surface
- 所有 UI 屏幕（登录、选角、探索、战斗、菜单）
- 世界实体绘制（明雷敌人、NPC）
- 战斗场景

## Related Docs
- [agents/game/ui.md](../../agents/game/ui.md)
