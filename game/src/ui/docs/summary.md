# UI Module Summary

> Last updated: b2dd66d - UI refactored with Components

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
- `Components.drawPanel(x, y, w, h, assetManager, style)` - Panel with asset fallback
- `Components.drawPanelSimple(x, y, w, h, radius)` - Simple panel without assets
- `Components.drawButton(x, y, w, h, text, state, assetManager, font)` - Button with states
- `Components.drawButtonSimple(x, y, w, h, text, isHovered, isPressed, font)` - Simple button
- `Components.drawSlot(x, y, size, state, assetManager)` - Inventory/equip slot with assets
- `Components.drawSlotSimple(x, y, size, isHovered, isSelected)` - Simple slot
- `Components.drawHPBar(x, y, w, h, percent, assetManager)` - Health bar (color changes by %)
- `Components.drawMPBar(x, y, w, h, percent, assetManager)` - Mana bar
- `Components.drawInput(x, y, w, h, isActive, assetManager)` - Text input field
- `Components.drawTab(x, y, w, h, text, isActive, assetManager, font)` - Tab button
- `Components.drawDialog(x, y, w, h, assetManager)` - Dialog panel
- `Components.drawTooltip(x, y, w, h, assetManager)` - Tooltip background
- `Components.drawOverlay(w, h, alpha)` - Full-screen overlay
- `Components.drawBorder(x, y, w, h, radius, isActive)` - Border outline

### theme.lua
- `Theme.colors` - Color palette table (background, panel, text, accent, button, hp, mp, etc.)
- `Theme.palette` - Hex color strings for reference
- `Theme.getHpColor(percent)` - Get HP color based on percentage (high/medium/low)
- `Theme.getButtonColor(isHovered, isPressed, isDisabled)` - Get button state color
- `Theme.getBorderColor(isActive)` - Get border color
- `Theme.setColor(color)` - Set love.graphics color from table
- `Theme.hexToRgb(hex)` - Convert hex string to RGB table
- `Theme.rgba(r, g, b, a)` - Create color table with alpha
- `Theme.applyAlpha(color, alpha)` - Add alpha to existing color

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

## Color Categories (theme.lua)

| Category | Colors |
|----------|--------|
| Base | background, panel, text, border |
| States | button, buttonHover, buttonPressed, buttonDisabled |
| Feedback | success, warning, error, info |
| HP/MP | hp.high/medium/low, mp |
| UI Elements | tab, input, minimap, battle, chat, inventory, tooltip, dialog, loading |
