# Server Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Python UDP game server with reliable protocol (RUDP) for game state synchronization.

## Files

| File | Description |
|------|-------------|
| `app.py` | Main server application |
| `requirements.txt` | Python dependencies |
| `start.sh` | Startup script |
| `data/` | JSON data storage |
| `handlers/` | Request handlers |
| `protocol/` | Network protocol |
| `storage/` | Data persistence |

## Key APIs

### app.py - GameUDPServer
- `GameUDPServer(host, port)` - Create server
- `server.run()` - Start async server loop
- `server.stop()` - Shutdown server

## Server Architecture

```
+------------------+
|  GameUDPServer   |
+------------------+
         |
    +----+----+----+----+
    |    |    |    |
 handlers protocol storage
```

## Endpoints (Packet Types)

| Type | Handler | Description |
|------|---------|-------------|
| LOGIN | auth_handler | Authenticate user |
| REGISTER | auth_handler | Create account |
| LOGOUT | auth_handler | End session |
| GET_CHARACTER | character_handler | Load character |
| SAVE_CHARACTER | character_handler | Save progress |
| CREATE_CHARACTER | character_handler | New character |
| POSITION_UPDATE | sync_handler | Sync position |
| CHAT_MESSAGE | sync_handler | Broadcast chat |

## Running

```bash
cd server && python app.py
# Server runs on UDP port 9000
```
