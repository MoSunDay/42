# How to Play - Top-Down Combat Game

## Quick Start (30 seconds)

```bash
cd /Users/amos/42/game
love .
```

That's it! The game will start immediately.

## Game Controls

### Mouse
- **Left Click**: Click anywhere on the map to move your knight to that location
- The knight will automatically walk to the clicked position
- A yellow marker shows where you clicked
- A yellow line shows the path

### Keyboard
- **ESC**: Quit the game

## Game Interface

### Top-Left Panel: Position Display
Shows your knight's current coordinates:
- **X**: Horizontal position (0 to 2000)
- **Y**: Vertical position (0 to 2000)

### Top-Right Panel: Minimap
- **Red dot**: Your knight's current position
- **Gray areas**: Stone roads
- **Green areas**: Grass
- **Yellow circle**: Your view range

### Bottom-Right: FPS Counter
Shows the game's performance (should be 60 FPS)

## Game World

### The Town
You're in a medieval town with:
- **Stone Roads**: Gray pathways in a grid pattern
- **Grass Areas**: Green spaces between the roads
- **Wooden Fence**: Brown border around the town

### Map Size
- **Width**: 2000 pixels
- **Height**: 2000 pixels
- The camera follows your knight smoothly

## Movement System

### How Movement Works
1. Click anywhere on the visible map
2. Your knight will walk toward that point
3. Movement is smooth and automatic
4. You can click again to change destination mid-movement

### Boundary Protection
- You **cannot** move outside the map boundaries
- If you click beyond the edge, the knight will stop at the border
- This prevents getting lost or stuck

### Movement Speed
- Default speed: 250 pixels per second
- Smooth acceleration and deceleration
- Natural-looking movement

## Visual Feedback

### When Moving
- **Yellow crosshair**: Shows your target destination
- **Yellow line**: Shows the path from knight to target
- **Footstep effect**: Subtle animation while walking

### When Stationary
- Knight stands still
- No target marker visible
- Ready for next command

## Tips & Tricks

### Efficient Movement
- Click far away for long-distance travel
- Click nearby for precise positioning
- Click again to change direction instantly

### Exploring the Town
- Follow the stone roads for easy navigation
- The minimap helps you see the overall layout
- Roads form a grid pattern every 5 tiles

### Using the Minimap
- Red dot = your position
- Watch it move as you walk
- Use it to navigate to different areas
- Yellow circle shows your view range

## Technical Details

### Performance
- Target: 60 FPS
- Smooth camera following
- Efficient rendering
- No lag or stuttering

### Graphics
- **Knight Sprite**: 475x470 pixel swordsman
- **Town Tileset**: 512x512 pixel town tiles
- **Fallback**: If sprites missing, uses simple shapes

### Map Layout
- Roads every 5 tiles (grid pattern)
- Grass fills spaces between roads
- Procedurally generated layout
- Consistent and predictable

## Troubleshooting

### Game Won't Start
```bash
# Check if Love2D is installed
love --version

# Should show: LOVE 11.4 or higher
```

If not installed:
```bash
# macOS
brew install love

# Linux
sudo apt-get install love
```

### Knight Not Visible
- Check if `knight.png` exists in `assets/images/`
- Game will use blue circle if sprite missing
- This is normal fallback behavior

### Can't Move
- Make sure you're left-clicking (not right-click)
- Click within the visible map area
- Check console for error messages

### Low FPS
- Close other applications
- Check system resources
- Game should run at 60 FPS on most systems

### Map Looks Different
- If `town.png` is missing, uses procedural graphics
- Both versions work fine
- Download assets for better visuals

## Advanced Features

### Camera System
- Automatically follows your knight
- Smooth interpolation (not instant)
- Keeps knight centered on screen
- Adjusts when near map edges

### Coordinate System
- Origin (0,0) is top-left corner
- X increases to the right
- Y increases downward
- Standard screen coordinates

### Boundary System
- Invisible walls at map edges
- Prevents movement beyond (0,0) to (2000,2000)
- Smooth stopping at boundaries
- No glitches or errors

## What's Next?

Future features planned:
- **Combat**: Attack enemies with your sword
- **NPCs**: Townspeople to interact with
- **Buildings**: Houses and shops to explore
- **Quests**: Missions to complete
- **Items**: Weapons and armor to collect
- **Sound**: Music and sound effects

## Getting Help

### Documentation
- `README.md` - Project overview
- `CHANGELOG.md` - Version history
- `docs/QUICK_START.md` - Setup guide
- `docs/DEVELOPMENT.md` - Developer info

### Testing
```bash
# Run core tests
cd game/tools
lua test_game.lua

# Run boundary tests
lua test_boundaries.lua
```

### Common Questions

**Q: How do I quit?**
A: Press ESC key

**Q: Can I resize the window?**
A: No, window is fixed at 1280x720

**Q: Can I move with keyboard?**
A: Not yet, only mouse movement currently

**Q: What's the goal?**
A: This is MVP - just explore and test movement

**Q: Can I go fullscreen?**
A: Not in current version

## Enjoy the Game!

This is version 1.1 of the MVP. More features coming soon!

Have fun exploring the town with your knight! 🗡️

