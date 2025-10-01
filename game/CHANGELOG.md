# Changelog

All notable changes to this project will be documented in this file.

## [v1.1.0] - 2025-10-01

### Added
- **Map boundary restrictions**: Player cannot move outside the map boundaries
- **Knight character sprite**: Downloaded and integrated knight.png (475x470)
- **Town tileset**: Downloaded and integrated town.png (512x512) for city environment
- **Town-style map rendering**: 
  - Stone road system (grid pattern every 5 tiles)
  - Grass areas between roads
  - Wooden fence-style borders
  - Enhanced visual details
- **Boundary testing**: Added comprehensive boundary test suite

### Changed
- **Fixed encoding issues**: Replaced all Chinese text with English to prevent encoding problems
- **Map visual style**: Changed from simple grass checkerboard to town/city theme
  - Roads: Gray stone tiles
  - Grass: Green areas between roads
  - Border: Wooden fence appearance
- **Asset loading priority**: 
  - Player sprite: knight.png > player.png > generated
  - Map tileset: town.png > tileset.png > generated
- **Minimap display**: Now shows road patterns matching the main map

### Fixed
- Player movement now properly restricted to map boundaries
- Player cannot click outside map and move beyond edges
- Movement updates enforce boundary checks every frame
- All console output now in English (no encoding issues)

### Technical Details
- Added `Player:setMapBounds(width, height)` method
- Added boundary clamping in `Player:moveTo()` method
- Added boundary enforcement in `Player:update()` method
- Updated `Map:generateTownLayout()` for road generation
- Enhanced `Map:draw()` with town-themed rendering

### Testing
- All boundary tests passing (6/6)
- Movement restriction verified in all directions
- Core game logic tests passing (4/4)

## [v1.0.0] - 2025-10-01

### Initial Release
- Mouse left-click movement control
- Player coordinate display (top-left)
- Minimap display (top-right)
- Camera follow system
- Modular architecture (ECS-inspired)
- Asset management system
- Procedural graphics fallback
- FPS display

### Features
- Top-down view combat game MVP
- Smooth player movement
- Real-time coordinate tracking
- Minimap with player position indicator
- Modular code structure (<400 lines per file)
- Comprehensive documentation

---

## Asset Credits

### Knight Sprite
- Source: OpenGameArt.org
- File: knight.png (475x470 pixels)
- License: Check original source for license details

### Town Tileset
- Source: OpenGameArt.org
- File: town.png (512x512 pixels)
- License: Check original source for license details

---

## Upgrade Guide

### From v1.0.0 to v1.1.0

No breaking changes. Simply update your files and the game will:
1. Automatically load knight.png if present
2. Automatically load town.png if present
3. Enforce map boundaries automatically
4. Display English text instead of Chinese

If you don't have the asset files, the game will fall back to procedurally generated graphics.

