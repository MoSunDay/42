# Account Module Summary

> Last updated: b2dd66d - UI refactored with Components

## Purpose
Account management, login UI, and character selection.

## Files

| File | Description |
|------|-------------|
| `account_manager.lua` | Account/character storage and auth |
| `login_ui.lua` | Login screen with input fields |
| `character_select_ui.lua` | Character selection/creation |
| `character_data.lua` | Character data templates |
| `avatar_renderer.lua` | Avatar sprite rendering |

## Key APIs

### account_manager.lua
- `AccountManager.login(username, password)` - Authenticate
- `AccountManager.register(username, password)` - Create account
- `AccountManager.getCharacters(username)` - Get character list
- `AccountManager.selectCharacter(character)` - Set active character
- `AccountManager.getCurrentCharacter()` - Get active character
- `AccountManager.saveCharacter()` - Save progress

### login_ui.lua
- `LoginUI.new()` - Create login UI
- `LoginUI:update(dt)` - Update animations
- `LoginUI:draw()` - Render login screen
- `LoginUI:keypressed(key)` - Handle input
- `LoginUI:setNetwork(networkManager)` - Set network

### character_select_ui.lua
- `CharacterSelectUI.new()` - Create UI
- `CharacterSelectUI:draw(accounts)` - Render selection
- `CharacterSelectUI:createCharacter(name, appearanceId)` - New character

## Character Data

```lua
{
    id = "uuid",
    characterName = "Hero",
    level = 1,
    hp = 100, maxHp = 100,
    attack = 15, defense = 5,
    gold = 0,
    x = 1000, y = 1000,
    mapId = "town_01",
    equipment = {...},
    inventory = {...}
}
```
