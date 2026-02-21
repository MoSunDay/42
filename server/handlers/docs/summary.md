# Handlers Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Request handlers for authentication, characters, and game sync.

## Files

| File | Description |
|------|-------------|
| `auth_handler.py` | Login, register, logout |
| `character_handler.py` | Character CRUD operations |
| `sync_handler.py` | Position and chat sync |

## Key APIs

### auth_handler.py - AuthHandler
- `handle_login(packet, send_response, on_success)` - Authenticate
- `handle_register(packet, send_response)` - Create account
- `handle_logout(packet, send_response)` - End session

### character_handler.py - CharacterHandler
- `handle_get_character(packet, send_response)` - Load character data
- `handle_save_character(packet, send_response)` - Save progress
- `handle_create_character(packet, send_response)` - Create new character

### sync_handler.py - SyncHandler
- `handle_position_update(packet, send_response, username)` - Update position
- `handle_chat_message(packet, send_response, broadcast)` - Chat message
- `register_player(username, session_id)` - Register for sync
- `unregister_player(username)` - Remove from sync

## Response Format

```python
{
    "success": True/False,
    "error": "error message",  # if failed
    "data": {...}              # if success
}
```
