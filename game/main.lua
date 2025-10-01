-- main.lua - Game main entry point
-- Top-down combat game MVP v1

-- Add src directory to Lua path
package.path = package.path .. ";src/?.lua;src/core/?.lua;src/entities/?.lua;src/systems/?.lua;src/ui/?.lua"

-- Core modules
local GameState = require("core.game_state")
local AssetManager = require("core.asset_manager")

-- System modules
local InputSystem = require("systems.input_system")
local RenderSystem = require("systems.render_system")

-- Global game state
local game = {
    state = nil,
    assetManager = nil,
    inputSystem = nil,
    renderSystem = nil
}

function love.load()
    -- Setup window
    love.window.setTitle("Top-Down Combat Game - MVP v1")
    love.window.setMode(1280, 720, {
        resizable = false,
        vsync = true,
        msaa = 0
    })

    -- Initialize asset manager
    game.assetManager = AssetManager.new()
    game.assetManager:loadAll()

    -- Initialize game state
    game.state = GameState.new(game.assetManager)

    -- Initialize systems
    game.inputSystem = InputSystem.new(game.state)
    game.renderSystem = RenderSystem.new(game.state, game.assetManager)

    -- Set background color
    love.graphics.setBackgroundColor(0.15, 0.15, 0.2)

    print("Game loaded successfully!")
end

function love.update(dt)
    if game.state then
        game.state:update(dt)
    end
end

function love.draw()
    if game.renderSystem then
        game.renderSystem:render()
    end
end

function love.mousepressed(x, y, button)
    if game.inputSystem then
        game.inputSystem:mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

