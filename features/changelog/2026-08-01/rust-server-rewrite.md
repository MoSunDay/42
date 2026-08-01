# Rust RUDP 服务器重写

## Context

原服务器为 Python/Sanic (`server/legacy_python/`)，被重写为纯 Rust RUDP
服务器（无 `impl`、数据型结构体 + 自由函数，文件 ≤400 行）。目标是保持与
LÖVE Lua 客户端 `game/src/network/` 的线上协议兼容，并补全客户端网络层缺失
的会话/可靠传输处理。已通过三层验证：Rust 单元测试、Python 线格式测试 +
活体集成测试、以及 LÖVE 真机 e2e（Lua 网络层 ↔ Rust 服务器）。

## Change Summary

### 新增 `server/src/`（Rust，cargo 包 `game-server` v1.0.0）
| 文件 | 职责 |
|------|------|
| `main.rs` | UDP socket 循环（0.0.0.0:9000）、会话分发、SIGINT 优雅退出 |
| `packet.rs` | 13 字节大端头 `total_len u16 | msg_type u8 | flags u8 | seq u32 | ack u32 | ack_mask u8` + JSON 载荷 |
| `rudp.rs` | 可靠传输：seq/ack 追踪、500ms×5 重试、30s 空闲超时 |
| `handlers.rs` | 各消息类型处理、广播排除发送方 SocketAddr |
| `accounts.rs` | 账户/角色业务逻辑（创建、改名检查、踢重复登录） |
| `storage.rs` | JSON 持久化、sha2 密码哈希、`migrate_legacy` 旧库迁移 |
| `constants.rs` | 调优常量 |
| `tests.rs` | 27 个集成测试 |

### 协议语义（对照 `legacy_python/` 逐条核实）
- 可靠消息：LOGIN/REGISTER/LOGOUT/GET/SAVE/CREATE/LIST/SELECT/DELETE/BATTLE_ACTION/CHAT_MESSAGE；
  POSITION_UPDATE/HEARTBEAT/ACK/ERROR 不可靠（除非 force 标记，如重复 SELECT 的 409 ERROR）。
- LOGIN 与 REGISTER 均回复 LOGIN 类型 `{success, characters}`；0 角色也登录成功。
- 每个会话独立服务端 seq 空间（从 1 起）；服务器 HEARTBEAT seq=0；ACK = seq 0 + ack=入站 seq。
- SAVE_CHARACTER 宽松处理，保留 `id/level/exp/gold`。
- 注册自动创建首个角色，名字取 `characterName or username`（`json_store.create_account` 旧行为）。
- 登录失败清除会话上残留的 `username/character_id`。
- 兼容 8 字节前缀（`len in [8,13)` 时 ack=0/ack_mask=0/无载荷），`total_len != len(data)` 仅对完整头强制。

### 客户端修复（两处均与 8/13 字节头及 LOGIN 回复类型对齐）
- `server/headless_client/protocol/packet.py` — 8 字节前缀容错的 `unpack_packet`（`!HBBI` 头 + `!IB` ack）。
- `server/headless_client/client.py` — `register()` 期望 LOGIN 类型回复。
- `game/src/core/game_state.lua` — CHARACTER_SELECT/EXPLORATION/BATTLE 分支补上
  `NetworkManager.update(state.network)`（此前仅登录后泵一次，网络层永不推进会话状态）。

### 验证结果
| 层级 | 结果 |
|------|------|
| `cargo test` | 27/27 通过，`cargo build --release` 0 警告 |
| `test_protocol.py` | 26 项线格式检查通过 |
| `test_client.py`（活体） | 16 项通过：登录、错误密码、注册自动建角色、角色增删选、位置同步、状态机 |
| `lua5.4` 工具测试 | 9/9 通过 |
| LÖVE e2e probe | `love /tmp/probe` 驱动真实 `NetworkManager` 登录：收到 LOGIN 回复
  `success=true, characters=1 (Test Hero lv=5)`；服务器侧 `last_login` 更新为 2026-08-01T12:56:19Z |
| LÖVE 窗口 e2e | Xvfb+openbox+xdotool 键入 `test/123` 后 UI 越过登录页（无崩溃；tcpdump 未捕获，UI 路径最佳努力） |

### 其他
- `server/start.sh` 重写：缺失时先 `cargo build --release`，再 `exec` 运行。
- `game/conf.lua`：`t.version` 11.4 → 11.3（本机 LÖVE 11.3；11.4+ 兼容性对话框会阻塞 Xvfb 自动化）。
- `data/accounts.json` 由 seed 生成，含 `test/123`、`admin/admin`、`player/pass`。

## Impact

- `server/` 目录职责变更：Rust 源码取代 Python 运行入口；`legacy_python/` 仅作语义参考归档。
- 文档同步：`server/README.md`（新增，协议/语义/运行）、`agents/02-build-and-run.md`（Python/Sanic → Rust RUDP）。
- 依赖：仅 `serde/serde_json/sha2 0.10/libc 0.2`，无网络拉取（ctrlc 不在本地缓存故未用）。
