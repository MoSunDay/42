# Deduplicate shared utilities

## Context
装备槽位颜色/图标映射在 3 个 UI 文件中重复（unified_menu, equipment_ui, inventory_ui）。服务端 `_send_error` 方法和 payload 解析样板在 3 个 handler 文件中完全相同。

## Change Summary
- 提取 `game/src/ui/slot_utils.lua`：纯函数 `getSlotColor`, `getSlotIcon`, `getItemColor`，使用表查找代替 if/elseif 链
- 提取 `server/handlers/common.py`：`send_error` 和 `parse_payload` 函数
- 3 个 Lua UI 文件改为 `require("src.ui.slot_utils")`，移除内联映射
- 3 个 Python handler 文件改为 `from handlers.common import send_error, parse_payload`，移除 `_send_error` 方法和重复的 payload 解析

## Impact Surface
- `game/src/ui/unified_menu.lua`, `equipment_ui.lua`, `inventory_ui.lua`
- `server/handlers/auth_handler.py`, `character_handler.py`, `sync_handler.py`

## Related Docs
- [agents/game/ui.md](../../../agents/game/ui.md)
