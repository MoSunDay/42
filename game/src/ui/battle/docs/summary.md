# Battle UI Module Summary

> Last updated: TBD (commit on first change)

## Purpose
Battle-specific UI: menu, background, and status panels.

## Files

| File | Description |
|------|-------------|
| `battle_ui.lua` | Main battle UI coordinator |
| `battle_menu.lua` | Action buttons (Attack/Defend/Escape) |
| `battle_background.lua` | Battle scene background |
| `battle_panels.lua` | HP bars and status panels |

## Key APIs

### battle_ui.lua
- `BattleUI.new()` - Create battle UI
- `BattleUI:update(battleSystem, dt)` - Update UI state
- `BattleUI:draw(battleSystem)` - Render all battle UI
- `BattleUI:mousepressed(x, y, button, battleSystem)` - Handle clicks
- `BattleUI:getSelectedEnemy()` - Get targeted enemy index

### battle_menu.lua
- `BattleMenu.new(x, y)` - Create menu
- `BattleMenu:draw(battleSystem)` - Render buttons
- `BattleMenu:isClicked(x, y)` - Check button click

### battle_panels.lua
- `BattlePanels.drawPlayerPanel(player, x, y)` - Player HP bar
- `BattlePanels.drawEnemyPanel(enemy, x, y, index)` - Enemy HP bar
- `BattlePanels.drawTurnTimer(battleSystem, x, y)` - Timer display

## UI Layout

```
+------------------------------------------+
|  [Enemy HP bars]                         |
|                                          |
|  [Battle Background + Sprites]           |
|                                          |
|  [Player HP bar]                         |
|  [Attack] [Defend] [Escape] [Auto]       |
|  [Battle Log]                            |
+------------------------------------------+
```
