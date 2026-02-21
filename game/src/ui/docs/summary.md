# UI Module Summary

> Last updated: TBD (commit on first change)

## Purpose
User interface components for HUD, menus, and interactions.

## Files

| File | Description |
|------|-------------|
| `hud.lua` | Health bar, gold, minimap |
| `chat_ui.lua` | Chat input and message display |
| `party_ui.lua` | Party member list |
| `inventory_ui.lua` | Item grid and details |
| `equipment_ui.lua` | Equipment slots display |
| `pet_ui.lua` | Pet status panel |
| `button_ui.lua` | Reusable button component |
| `unified_menu.lua` | Generic menu system |
| `fullscreen_map.lua` | Full world map view |
| `map_renderer.lua` | Minimap rendering |
| `battle/` | Battle UI subdirectory |

## Key APIs

### hud.lua
- `HUD.new(player)` - Create HUD
- `HUD:update(dt)` - Update display
- `HUD:draw()` - Render HUD

### chat_ui.lua
- `ChatUI.new()` - Create chat UI
- `ChatUI:toggle()` - Show/hide
- `ChatUI:input(text)` - Handle text input

### inventory_ui.lua
- `InventoryUI.new(inventorySystem)` - Create UI
- `InventoryUI:toggle()` - Show/hide
- `InventoryUI:getSelectedItem()` - Get selection

### button_ui.lua
- `ButtonUI.new(x, y, width, height, text)` - Create button
- `ButtonUI:isClicked(mouseX, mouseY)` - Check click
- `ButtonUI:draw()` - Render button
