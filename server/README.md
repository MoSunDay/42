# game-server — Rust RUDP Server

RUDP (reliable UDP) game server for PIXEL RPG. Wire-compatible with the LÖVE
Lua client (`game/src/network/`) and the headless Python client
(`server/headless_client/`).

## Build & Run

```bash
# Requires Rust toolchain (rustc/cargo 1.96+)
cargo build --release

# Run (binds 0.0.0.0:9000 UDP)
./start.sh            # builds if missing, then runs target/release/game-server
# or directly:
cargo run --release
```

Stop with Ctrl+C (SIGINT handler performs graceful shutdown + store save).

## Tests

```bash
cargo test            # 27 unit/integration tests (accounts, handlers, rudp, packet)
python3 test_protocol.py   # 26 wire-format checks (standalone, no server needed)
# Live integration (server must be running):
python3 test_client.py     # 16 checks: login, register auto-char, CRUD, movement, state machine
```

Lua-side compatibility is covered by `game/tools/test_*.lua` (9 suites under
`lua5.4`) plus the LÖVE e2e probe (see `features/changelog/2026-08-01/rust-server-rewrite.md`).

## Wire Protocol

13-byte big-endian header + JSON payload (UTF-8):

```
offset  field        size  note
0       total_len    u16   header(13) + payload bytes
2       msg_type     u8    see PACKET_TYPE below
3       flags        u8    bit0 = RELIABLE
4       seq          u32   sender sequence number (starts at 1)
8       ack          u32   last received seq from peer
12      ack_mask     u8    bitfield of received seqs (1 = received)
```

ACK packets are `msg_type=ACK` with `seq=0`, `ack=incoming seq`. HEARTBEAT
uses `seq=0`. An 8-byte header prefix (`len in [8,13)`) is tolerated by both
server and client (`ack=0`, `ack_mask=0`, no payload).

### Message Types (`server/headless_client/protocol/constants.py`)

| type | value | reliable |
|------|-------|----------|
| LOGIN | 1 | yes |
| REGISTER | 2 | yes |
| LOGOUT | 3 | yes |
| ACK | 10 | no |
| HEARTBEAT | 11 | no |
| ERROR | 12 | no (unless force-reliable, e.g. duplicate SELECT 409) |
| GET_CHARACTER | 13 | yes |
| SAVE_CHARACTER | 14 | yes |
| CREATE_CHARACTER | 15 | yes |
| LIST_CHARACTERS | 16 | yes |
| SELECT_CHARACTER | 17 | yes |
| DELETE_CHARACTER | 18 | yes |
| POSITION_UPDATE | 20 | no |
| BATTLE_ACTION | 21 | yes |
| CHAT_MESSAGE | 22 | yes |

### Semantics (verified against `legacy_python/`)

- Reliable messages: 500ms × 5 retries, then dropped.
- 30s idle timeout closes the session.
- First non-ACK/HEARTBEAT packet creates a session; per-session server seq
  starts at 1.
- LOGIN and REGISTER both reply with a LOGIN-typed `{success, characters}`;
  login succeeds with 0 characters.
- Broadcast excludes the sender by SocketAddr.
- SAVE_CHARACTER is lenient and preserves `id/level/exp/gold`.
- SELECT_CHARACTER kicks duplicates with a force-reliable ERROR 409.
- Register auto-creates a first character named `characterName or username`
  (legacy `json_store.create_account` behavior).
- Failed login clears any previous `username/character_id` on the session.

## Storage

`data/accounts.json` (auto-created from `data/accounts.seed.json` on first
run; seed contains `test/123`, `admin/admin`, `player/pass`). Legacy Python
store (`legacy_python/`) can be migrated via `migrate_legacy` in
`src/storage.rs`. Store is written on change and on graceful shutdown.

## Layout

| file | purpose |
|------|---------|
| `src/main.rs` | UDP socket loop, session dispatch |
| `src/packet.rs` | header encode/decode, message types |
| `src/rudp.rs` | reliability: seq/ack tracking, retry, timeout |
| `src/handlers.rs` | per-message-type handling |
| `src/accounts.rs` | account/character business logic |
| `src/storage.rs` | JSON persistence, hashing (sha2), legacy migration |
| `src/constants.rs` | tuning constants |
| `src/tests.rs` | integration tests (27) |
| `headless_client/` | Python client + protocol lib (used by tests) |
| `legacy_python/` | archived Python/Sanic server (semantic reference only) |
