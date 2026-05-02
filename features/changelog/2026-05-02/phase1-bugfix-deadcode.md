Commit: 99b2fb0a7c35b83446570e7572de829cc3946902

# Phase 1-2: 关键 Bug 修复与死代码清理

## Context
全面审查后发现的 8 个确认 Bug 和多处死代码。

## Change Summary

### Bug 修复
- `account/account_manager.lua:177` — `saveCharacter` 现在正确遍历 `account.characters` 匹配 ID 更新，不再覆写整个角色列表
- `systems/spirit_crystal_system.lua:157` — `getEnhancementBonus` 不再将 `crystalType` 字符串作为 fallback 乘法操作数
- `systems/companion_system.lua:164` — `addToParty` 边界检查从 `MAX_COMPANIONS(9)` 改为 `MAX_PARTY_SIZE - 1`
- `map/particle_system.lua` — 水花粒子创建时初始化 `alpha = 0` 和 `fadeIn = true`
- `map/tiled_loader.lua` — `decompressGZIP` 使用 `love.math.decompress` 实际解压 gzip/zlib 数据
- `src/core/asset_manager.lua:538` — `getAvailableDirections` 遍历 `sprite.rotations` 而非整个 sprite 表
- `src/systems/pet_system.lua` — 伤害公式统一为百分比减免（与 Player/Enemy 一致），`calculateDamage` 加入 variance+crit 机制

### 死代码清理
- `game_state.lua` — 删除重复定义的 `getPartySystem`
- `battle_utils.lua` — 删除从未被调用的 `calculateDamage`
- `audio_system.lua` — 删除空方法 `update`
- `tile_animator.lua` — 删除从未使用的模块级静态字段 `animations`/`activeTiles`/`globalTime`
- `autotile.lua` — 删除未调用的 `checkTile` 局部函数、从未读写的 `self.cache`、`clearCache` 方法
- `tileset_manager.lua` — 删除从未使用的 `cache`/`loadedImages`/`DEFAULT_TILESET`
- `tiled_integration.lua` — 整个文件删除（从未被引用的 demo 模块）
- `server/protocol/packet.py` — 删除未使用的 `Packet.TYPE` 和 `Packet.FULL_HEADER` struct

## Impact Surface
- 账号保存、灵晶强化、队伍管理、粒子渲染、地图加载、资产查询、宠物战斗、战斗工具函数
