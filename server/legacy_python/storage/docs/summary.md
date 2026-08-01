# Storage Module Summary

> Last updated: 0b5db5a - UI components + NPC expansion

## Purpose
JSON-based data persistence for accounts and characters.

## Files

| File | Description |
|------|-------------|
| `json_store.py` | JSON file storage manager |

## Key APIs

### json_store.py - JsonStore
- `JsonStore(data_dir)` - Create store
- `store.get_account(username)` - Get account data
- `store.save_account(username, data)` - Save account
- `store.get_account_count()` - Count accounts
- `store.character_exists(username, char_name)` - Check character
- `store.get_characters(username)` - Get all characters
- `store.save_character(username, char_name, data)` - Save character

## Data Structure

### accounts.json
```json
{
    "username": {
        "password_hash": "...",
        "created_at": "2024-01-01T00:00:00"
    }
}
```

### characters/{username}/{char_name}.json
```json
{
    "id": "uuid",
    "characterName": "Hero",
    "level": 1,
    "hp": 100,
    "maxHp": 100,
    "attack": 15,
    "defense": 5,
    "gold": 0,
    "x": 1000,
    "y": 1000,
    "mapId": "town_01",
    "equipment": {...},
    "inventory": [...]
}
```

## File Location
```
server/
└── data/
    ├── accounts.json
    └── characters/
        └── {username}/
            └── {char_name}.json
```
