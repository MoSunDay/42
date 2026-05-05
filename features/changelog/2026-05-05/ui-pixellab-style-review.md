# UI 统一 PixelLab 风格焕新

## Context
登录/角色选择/角色创建三个界面使用奇幻华丽风格（金色边框、宝石按钮、菱形分隔符），与游戏内 battle/inventory 风格耦合。需要统一刷新为 clean pixel-art 风格，灵感来源于 [pixellab.ai](https://www.pixellab.ai)。

## Change Summary

### theme.lua — 新增 PixelLab 风格原语 (~150 行)
- `Theme.pixelLab.colors` — 像素风格颜色表（深色背景、霓虹强调色、像素边框色）
- `Theme.pixelLab.drawPanel()` — 简洁面板（纯色填充 + 2px 边框 + 可选内边框）
- `Theme.pixelLab.drawButton()` — 像素按钮（primary/danger/disabled/normal 状态 + hover 高亮）
- `Theme.pixelLab.drawBorder()` — 简单像素边框
- `Theme.pixelLab.drawSeparator()` — 横线分隔符（替代菱形）
- `Theme.pixelLab.drawDot()` / `drawDotLine()` — 点状步进指示器
- `Theme.pixelLab.drawInput()` — 像素风格输入框

### login_ui.lua — 完全使用 PixelLab 风格
- 移除 `Components` 依赖，直接使用 `Theme.pixelLab.draw*`
- 深色渐变背景 (gradient)、标题 "PIXEL RPG" (cyan)
- 像素面板 + 简洁分隔线
- 标签页使用青线指示器替代金边
- 按钮 "Sign In" / "Create Account" (primary/danger)
- 光标颜色改为 neonCyan

### character_select_ui.lua — 完全使用 PixelLab 风格
- 移除 `Components` 依赖，直接使用 `Theme.pixelLab.draw*`
- 深色渐变背景
- 角色卡用像素面板 + 选中时左侧青线指示
- 3 步创建流程：圆点步进器替代菱形
- 像素血条 (draw_pixel_bar) 替代 ornate HP/MP bars
- 名称/职业/外观步骤全面像素化
- 按钮状态: Next/Create → primary, Cancel/Back → danger
- 鼠标点击区域坐标全部适配新布局

### Pixellab MCP 素材生成 — 10 张 UI 资产
通过 [pixellab.ai MCP](https://www.pixellab.ai/mcp) 生成像素艺术 UI 素材，放置于 `game/assets/images/ui/`：
| 素材 | 尺寸 | 位置 |
|------|------|------|
| `pixellab_panel.png` | 128x128 | `panels/` — 深色面板，9-slice 渲染 |
| `pixellab_primary.png` | 64x32 | `buttons/` — 青色霓虹主按钮 |
| `pixellab_danger.png` | 64x32 | `buttons/` — 红色霓虹危险按钮 |
| `pixellab_input.png` | 128x32 | `input/` — 深色输入框 |
| `pixellab_active.png` | 64x32 | `tabs/` — 青色底边高亮活动标签 |
| `pixellab_inactive.png` | 64x32 | `tabs/` — 灰色非活动标签 |
| `pixellab_slot.png` | 256x48 | `character_select/` — 角色槽位，9-slice 渲染 |
| `pixellab_separator.png` | 256x32 | `character_select/` — 青色横线分隔符 |
| `pixellab_dot_active.png` | 32x32 | `character_select/` — 青点活动步进器 |
| `pixellab_dot_inactive.png` | 32x32 | `character_select/` — 灰点非活动步进器 |

素材使用 **asset-first, code-fallback** 模式集成：优先使用 Pixellab PNG 资源（9-slice/缩放），资源不可用时回退到 Theme.pixelLab 代码绘制。

### battle_system.lua — 修复 parse 错误
`process_status_effects` 函数因合并冲突积累了 6 份重复的 DoT/debuff 处理代码，多余的 `end` 导致语法错误。合并为 1 份干净版本。

## Impact Surface
- **视觉**: 登录/角色选择/角色创建三个界面从奇幻华丽风格变为统一像素风格
- **素材**: 10 张 Pixellab AI 生成的像素艺术 UI 素材
- **代码**: login_ui.lua, character_select_ui.lua 回归 asset-first 架构
- **主题**: theme.lua (647 lines) 新增 PixelLab 风格体系，与现有华丽风格并存
- **修复**: battle_system.lua 语法错误
- **内存**: agents/game/ui.md, game/src/ui/docs/summary.md, game/account/docs/summary.md 已更新

## Related Docs
- [agents/game/ui.md](../../../agents/game/ui.md)
- [game/src/ui/docs/summary.md](../../../game/src/ui/docs/summary.md)
- [game/account/docs/summary.md](../../../game/account/docs/summary.md)
