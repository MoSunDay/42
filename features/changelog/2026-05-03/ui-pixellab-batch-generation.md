# UI 素材全覆盖 — Pixellab 批量生成

## Context

项目 UI 素材（18 个目录、~104 个 PNG）此前全部由 `generate_placeholder_assets.lua` 和 `generate_ui_phase2.py` 用代码几何图形生成，为占位质量。Pixellab MCP 已配置，API key 可用。

## Change Summary

编写批量生成脚本并执行，将 114 个 UI 素材替换为 Pixellab AI 生成的像素画。新增 battle_bg (Phase 5) 到 manifest。

### 新增文件

- `game/tools/pixellab_client.py` — Pixellab API v2 客户端
  - `generate-ui-v2` 异步任务提交 + `background-jobs/{id}` 轮询
  - `create-image-pixflux` 同步生成（用于小图标）
  - 并发控制（MAX_CONCURRENT=3）、超时、重试、备份
- `game/tools/generate_all_ui.py` — 114 个素材 manifest + 批量执行入口

### 生成结果

| Phase | 目录 | 数量 | API | 结果 |
|-------|------|------|-----|------|
| 0 | icons/ | 33 | pixflux (同步) | 33/33 ✅ |
| 1 | buttons/ + bars/ + tabs/ + slots/ | 30 | generate-ui-v2 | 30/30 ✅ |
| 2 | panels/ + borders/ + input/ | 13 | generate-ui-v2 | 13/13 ✅ |
| 3 | dialog/ + chat/ + menu/ + loading/ + minimap/ | 12 | generate-ui-v2 | 12/12 ✅ |
| 4 | login/ + character_select/ + classes/ + effects/ | 20 | generate-ui-v2 | 20/20 ✅ |
| 5 | battle_bg/ | 6 | generate-ui-v2 | 3/6 (额度耗尽) |
| **Total** | | **114** | | **111/114 Pixellab** |

### API 响应格式发现

- `pixflux`: 同步返回 `{"image": {"type": "base64", "base64": "...", "format": "png"}}`
- `generate-ui-v2`: 异步返回 `{"background_job_id": "..."}`, 轮询 `background-jobs/{id}` 返回 `{"status": "completed", "last_response": {"images": [...]}}`
- `generate-ui-v2` 最大尺寸: 688x384 (aspect ratio 限制)

## 多模态视觉审计结果

### 风格一致性 ✅

- **颜色主题**: 全部 Pixellab 生成素材统一使用 dark navy blue + gold 色板
- **像素画风格**: 一致的 retro pixel art 风格，清晰轮廓
- **图标可辨识度**: 33 个图标全部可识别（crossed swords, flame, potion 等）
- **职业图标**: warrior/mage/archer/cleric/knight/wizard/ranger/rogue 均可识别
- **面板/边框**: 空/干净的设计，适合文字叠加
- **血条/标签**: 干净的框架和填充，风格一致
- **战斗背景**: boss 房间（暗紫色+水晶+王座）质量优秀

### 已知问题（额度恢复后修复）

1. **按钮有装饰性符号**: AI 在空按钮中生成了星形图案。prompt 已更新为 "empty blank, no symbols no text"，但额度耗尽未重新生成
2. **character_select 有嵌入文字**: "CHAR 01" 文字嵌入。prompt 已修复但未重新生成
3. **battle_bg 3/6**: forest/dungeon/sky 仍为代码生成的渐变占位图

### 未通过的素材（恢复为 Pixellab Phase 1 版本）

- buttons/ 的 10 个按钮: 保留 Phase 1 版本（有装饰符号），待额度恢复后用新 prompt 重新生成
- character_select/ 的 2 个卡槽: 同上

## Impact Surface

- 所有 18 个 `game/assets/images/ui/` 子目录的 PNG 文件已替换
- `game/src/ui/components.lua` 的 asset-first/code-fallback 架构无需改动
- battle_bg 尺寸从 1280x720 变为 688x384 (Pixellab 最大限制)，Lua 代码需确认 scaling 逻辑

## Notes

- 总消耗: ~2054/2000 generations (Pixellab subscription 限额)
- 脚本支持 `--replace` 重新生成和 `restore` 恢复备份
- 待额度恢复后: `python generate_all_ui.py --replace phase1` 修复按钮, `--replace phase5` 完成 battle_bg

## Related Docs

- [agents/09-mcp-configuration.md](../../agents/09-mcp-configuration.md)
- [agents/10-art-assets.md](../../agents/10-art-assets.md)
- [docs/PIXELLAB_GENERATION_MANIFEST.md](../../docs/PIXELLAB_GENERATION_MANIFEST.md)
