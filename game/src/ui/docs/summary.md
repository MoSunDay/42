# UI Module Summary

> Last updated: 0b5db5a - UI components module

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
| `theme.lua` | Color palette and theming |
| `components.lua` | Reusable UI components (9-slice, panels, buttons, bars, etc.) |
| `battle/` | Battle UI subdirectory |

## Key APIs

### components.lua
- `Components.draw9Slice(img, x, y, w, h, cornerSize)` - 9-slice scaling for panels
- `Components.drawPanel(x, y, w, h, assetManager, style)` - Panel with fallback
- `Components.drawButton(x, y, w, h, text, state, assetManager, font)` - Button with states
- `Components.drawSlot(x, y, size, state, assetManager)` - Inventory/equip slot
- `Components.drawHPBar(x, y, w, h, percent, assetManager)` - Health bar
- `Components.drawMPBar(x, y, w, h, percent, assetManager)` - Mana bar
- `Components.drawInput(x, y, w, h, isActive, assetManager)` - Text input field
- `Components.drawTab(x, y, w, h, text, isActive, assetManager, font)` - Tab button
- `Components.drawDialog(x, y, w, h, assetManager)` - Dialog panel
- `Components.drawTooltip(x, y, w, h, assetManager)` - Tooltip background
- `Components.drawOverlay(w, h, alpha)` - Full-screen overlay
- `Components.drawBorder(x, y, w, h, radius, isActive)` - Border outline

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
