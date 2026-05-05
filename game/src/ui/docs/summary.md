# UI Module Summary

> Last updated: 2026-05-05 - PixelLab style added for Login/Character Select/Create

## Purpose
User interface components for HUD, menus, skills, and interactions.

## Visual Styles

### PixelLab Style (Login, Character Select, Character Create)
- Clean pixel-art aesthetic inspired by [pixellab.ai](https://www.pixellab.ai)
- Deep background gradient `#0f131c` → `#141b23`
- Neon accent colors: cyan `#4db5e6`, green `#4ee666`, blue `#4590e6`
- Simple 2px pixel borders, no rounded corners
- Pill-style buttons with bottom highlights on hover
- Dot-based step indicators with connecting lines
- Defined in `Theme.pixelLab.colors` and `Theme.pixelLab.draw*` functions

### Ornate Fantasy Style (In-game: Battle, Inventory, HUD, etc.)
- Gold borders, corner ornaments, gem icons, diamond separators
- Parchment panels, shimmer effects, glow effects
- Defined in `Theme.gold`, `Theme.gem`, `Theme.parchment`, `Theme.draw*` functions

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
| `tutorial_panel.lua` | Tutorial display with navigation buttons |
| `skill_panel.lua` | Skill management (unlock/upgrade skills) |
| `dialog_ui.lua` | NPC dialog with paging and avatar |
| `shop_ui.lua` | Buy items from merchant NPCs with spirit crystals |
| `death_screen.lua` | Death overlay with revive button |
| `battle/` | Battle UI subdirectory |
| `battle/reward_ui.lua` | Victory rewards display with crystal reveal animation |

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

### tutorial_panel.lua
- `TutorialPanel.new(tutorialSystem)` - Create panel
- `TutorialPanel:init()` - Initialize fonts and positions
- `TutorialPanel:show()` / `hide()` - Toggle visibility
- `TutorialPanel:update(dt)` - Update animations and hover
- `TutorialPanel:draw()` - Render panel with content
- `TutorialPanel:handleClick(x, y)` - Handle button clicks
- `TutorialPanel:handleKeyPress(key)` - Handle keyboard navigation (arrows, space, escape)

### skill_panel.lua
- `SkillPanel.new(assetManager)` - Create skill panel
- `SkillPanel:open(player)` - Open panel with player data
- `SkillPanel:close()` - Close panel
- `SkillPanel:toggle(player)` - Toggle open/close
- `SkillPanel:update(dt)` - Update message timer
- `SkillPanel:draw()` - Render skill list
- `SkillPanel:keypressed(key)` - Handle keyboard (↑↓ select, Enter confirm, Tab switch, ESC close)
- `SkillPanel:mousepressed(x, y, button)` - Handle mouse clicks
- Tabs: "unlocked" / "locked"
- Shows skill name, level, description, MP cost, upgrade cost
- Press `K` in exploration mode to open

### dialog_ui.lua
- `DialogUI.create(assetManager)` - Create dialog UI
- `DialogUI.open(state, npc)` - Open dialog with NPC data
- `DialogUI.close(state)` - Close dialog
- `DialogUI.is_open(state)` - Check if open
- `DialogUI.update(state, dt)` - Fade-in animation
- `DialogUI.draw(state)` - Render dialog panel with avatar, name, text, paging
- `DialogUI.keypressed(state, key)` - Space/Enter advance, Escape close
- `DialogUI.mousepressed(state, x, y, button)` - Click to advance
- Handles string arrays, structured dialogue tables, and single strings
- Press `F` near NPC to interact

### shop_ui.lua
- `ShopUI.create(assetManager)` - Create shop UI
- `ShopUI.open(state, npc, spiritCrystalSystem)` - Open shop with merchant NPC
- `ShopUI.close(state)` - Close shop
- `ShopUI.is_open(state)` - Check if open
- `ShopUI.update(state, dt)` - Update message timer
- `ShopUI.draw(state)` - Render item list, detail panel, balance, buy button
- `ShopUI.keypressed(state, key)` - Up/Down select, Enter buy, Escape close
- `ShopUI.mousepressed(state, x, y, button)` - Click items and buttons
- Shows item name, price, stats (ATK/DEF/SPD)
- Uses `SpiritCrystalSystem.spend_value` for purchases

### battle/reward_ui.lua
- `RewardUI.create(assetManager)` - Create reward UI
- `RewardUI.show(state, rewards)` - Show victory rewards
- `RewardUI.hide(state)` - Hide rewards
- `RewardUI.is_visible(state)` - Check visibility
- `RewardUI.is_complete(state)` - Check if reveal animation finished
- `RewardUI.update(state, dt)` - Animate crystal reveal
- `RewardUI.draw(state)` - Render victory overlay with crystal list
- Crystals revealed one by one with gold particle effects

### death_screen.lua
- `DeathScreen.create(assetManager)` - Create death screen
- `DeathScreen.show(state)` - Show death overlay
- `DeathScreen.hide(state)` - Hide death overlay
- `DeathScreen.is_visible(state)` - Check visibility
- `DeathScreen.update(state, dt)` - Fade-in animation
- `DeathScreen.draw(state)` - Render "YOU DIED" text, revive button
- On confirm: restores HP to max, teleports to (1000, 1000)

## Color Categories (theme.lua)

| Category | Colors |
|----------|--------|
| Base | background, panel, text, border |
| States | button, buttonHover, buttonPressed, buttonDisabled |
| Feedback | success, warning, error, info |
| HP/MP | hp.high/medium/low, mp |
| UI Elements | tab, input, minimap, battle, chat, inventory, tooltip, dialog, loading |
