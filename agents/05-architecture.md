# Architecture Notes

## Game States

1. `login` - Account login screen
2. `character_select` - Character selection/creation
3. `exploration` - Free roam on map
4. `battle` - Turn-based combat

## Key Systems

- **Battle System** (`src/systems/battle/`): Modular design with separate files for AI, animation, log, state, timer, executor
- **Party System**: Max 5 members, leader tracking
- **Chat System**: Chat box + speech bubbles
- **Collision System**: Tile-based walkability

## LÖVE Callbacks

```lua
love.load()      -- Initialize game
love.update(dt)  -- Game loop update
love.draw()      -- Render frame
love.keypressed(key)
love.textinput(text)
love.mousepressed(x, y, button)
love.wheelmoved(x, y)
```
