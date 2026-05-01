# Battle UI Module Summary

> Last updated: 2026-02-21 - Skill selection added

## Purpose
Battle-specific UI: menu, skill selection, background, and status panels.

## Files

| File | Description |
|------|-------------|
| `battle_ui.lua` | Main battle UI coordinator with skill selection |
| `battle_menu.lua` | Action buttons (Attack/Skill/Defend/Escape/Auto) |
| `battle_background.lua` | Battle scene background |
| `battle_panels.lua` | HP bars, player info, battle log |

## Key APIs

### battle_ui.lua
- `BattleUI.new()` - Create battle UI
- `BattleUI:update(battleSystem, dt)` - Update UI state
- `BattleUI:draw(battleSystem)` - Render all battle UI
- `BattleUI:mousepressed(x, y, button, battleSystem)` - Handle clicks
- `BattleUI:getSelectedEnemy()` - Get targeted enemy index
- `BattleUI:enterSkillMode(battleSystem)` - Open skill selection
- `BattleUI:exitSkillMode()` - Close skill selection
- `BattleUI:isSkillMode()` - Check if in skill mode
- `BattleUI:navigateSkillUp/Down()` - Navigate skill list
- `BattleUI:getSelectedSkill()` - Get selected skill ID
- `BattleUI:drawSkillSelectPanel(battleSystem, w, h)` - Render skill popup

### battle_menu.lua
- `BattleMenu.draw(battleUI, battleSystem, x, y)` - Render action buttons
- `BattleMenu.mousepressed(battleUI, x, y, button, battleSystem)` - Handle click
- Uses `Components.drawPanelSimple()` for styling

### battle_panels.lua
- `BattlePanels.drawPlayerPanel(colors, player, x, y)` - Player HP/MP bars and stats
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
|  [Player HP/MP bars + Stats]             |
|  [Attack] [Skill] [Defend] [Escape] [Auto]|
|  [Battle Log]                            |
+------------------------------------------+

Skill Selection Popup (when Skill selected):
+------------------------------------------+
|           Select Skill                    |
|  +------------------------------------+  |
|  | Whirlwind Lv.5        MP: 15      |  |
|  | Rotating dual blades attack        |  |
|  | DMG: 144%                         |  |
|  +------------------------------------+  |
|  | Shadow Blade Lv.3     MP: 25      |  |
|  | ...                               |  |
|  +------------------------------------+  |
|     ↑↓ Select  Enter Confirm  ESC Cancel |
+------------------------------------------+
```
