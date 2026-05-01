# Account Module Summary

> Last updated: 2026-02-21 - Class selection in character creation

## Purpose
Account management, login UI, and character selection with class system.

## Files

| File | Description |
|------|-------------|
| `account_manager.lua` | Account/character storage and auth |
| `login_ui.lua` | Login screen with input fields |
| `character_select_ui.lua` | Character selection/creation (3-step: name→class→appearance) |
| `character_data.lua` | Character data with class/skill support |
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
- `CharacterSelectUI:createCharacter(name, classId)` - New character with class
- 3-step creation flow: Enter Name → Select Class → Select Appearance

## Character Data

```lua
{
    id = "uuid",
    characterName = "Hero",
    classId = "dual_blade",      -- Class ID (6 options)
    level = 1,
    hp = 100, maxHp = 100,
    mp = 100, maxMp = 100,       -- MP for skills
    attack = 15, defense = 5,
    magicAttack = 10,            -- Magic attack stat
    critBonus = 0,               -- From class passive
    gold = 0,
    x = 1000, y = 1000,
    mapId = "town_01",
    equipment = {...},
    inventory = {...},
    skills = {                   -- Skill levels
        { id = "whirlwind", level = 1, unlocked = true },
        ...
    },
    skillCrystals = 0,           -- Currency for skill upgrades
}
```

## Related Documentation

- [CLASS_SKILL_SYSTEM.md](../docs/CLASS_SKILL_SYSTEM.md) - Full class/skill documentation
