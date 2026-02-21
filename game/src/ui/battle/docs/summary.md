# Battle UI Module Summary

> Last updated: b2dd66d - Refactored with Components module

## Purpose
Battle-specific UI: menu, background, and status panels.

## Files

| File | Description |
|------|-------------|
| `battle_ui.lua` | Main battle UI coordinator |
| `battle_menu.lua` | Action buttons (Attack/Defend/Escape/Auto) |
| `battle_background.lua` | Battle scene background |
| `battle_panels.lua` | HP bars, player info, battle log |

## Key APIs

### battle_ui.lua
- `BattleUI.new()` - Create battle UI
- `BattleUI:update(battleSystem, dt)` - Update UI state
- `BattleUI:draw(battleSystem)` - Render all battle UI
- `BattleUI:mousepressed(x, y, button, battleSystem)` - Handle clicks
- `BattleUI:getSelectedEnemy()` - Get targeted enemy index

### battle_menu.lua
- `BattleMenu.draw(battleUI, battleSystem, x, y)` - Render action buttons
- `BattleMenu.mousepressed(battleUI, x, y, button, battleSystem)` - Handle click
- Uses `Components.drawPanelSimple()` for styling

### battle_panels.lua
- `BattlePanels.drawPlayerPanel(colors, player, x, y)` - Player HP bar and stats
- `BattlePanels.drawHPBar(colors, entity, x, y, width, height)` - HP bar
- `BattlePanels.drawBattleLog(colors, battleSystem, x, y)` - Battle log panel
- Uses `Components` module for consistent styling

## Dependencies

- `src/ui/theme.lua` - Color palette
- `src/ui/components.lua` - Reusable UI components

## UI Layout

```
+------------------------------------------+
|  [Enemy HP bars]                         |
|                                          |
|  [Battle Background + Sprites]           |
|                                          |
|  [Player HP bar + Stats]                 |
|  [Attack] [Defend] [Escape] [Auto]       |
|  [Battle Log]                            |
+------------------------------------------+
```
