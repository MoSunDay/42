-- main.lua - Game main entry point
-- Top-down combat game MVP v1

-- Add src directory to Lua path
package.path = package.path .. ";src/?.lua;src/core/?.lua;src/entities/?.lua;src/systems/?.lua;src/ui/?.lua;src/animations/?.lua;account/?.lua;map/?.lua;map/maps/?.lua;map/minimap/?.lua;npcs/?.lua"

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

    -- Initialize render system first
    game.renderSystem = RenderSystem.new(game.state, game.assetManager)

    -- Initialize input system with render system
    game.inputSystem = InputSystem.new(game.state, game.renderSystem)

    -- Set background color
    love.graphics.setBackgroundColor(0.15, 0.15, 0.2)

    print("Game loaded successfully!")
    print("Battle System Active - Walk around to encounter enemies!")
    print("Battle Controls: WASD/Arrows to navigate, Enter/Space to confirm")
end

function love.update(dt)
    if game.state then
        game.state:update(dt)
    end
    if game.renderSystem then
        game.renderSystem:update(dt)
    end
end

function love.draw()
    if game.renderSystem then
        game.renderSystem:render()
    end
end

function love.keypressed(key)
    -- Handle login input first
    if game.state and game.state:getMode() == "login" then
        game.state:keypressed(key)
    elseif game.state and game.state:getMode() == "character_select" then
        game.state:keypressed(key)
    elseif game.inputSystem then
        game.inputSystem:keypressed(key)
    end
end

function love.textinput(text)
    -- Handle login text input
    if game.state and game.state:getMode() == "login" then
        game.state:textinput(text)
    elseif game.state and game.state:getMode() == "character_select" then
        game.state:textinput(text)
    elseif game.state and game.state:getMode() == "exploration" then
        -- Handle chat input
        local chatSystem = game.state:getChatSystem()
        if chatSystem and chatSystem:isInputting() then
            chatSystem:addInputChar(text)
        end
    end
end

function love.mousepressed(x, y, button)
    -- Handle mouse input based on game mode
    if game.state and game.state:getMode() == "login" then
        game.state:mousepressed(x, y, button)
    elseif game.state and game.state:getMode() == "character_select" then
        game.state:mousepressed(x, y, button)
    elseif game.inputSystem then
        game.inputSystem:mousepressed(x, y, button)
    end
end

