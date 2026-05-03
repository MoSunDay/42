-- main.lua - Game main entry point
-- Top-down combat game MVP v1

-- Add src directory to Lua path
package.path = package.path .. ";src/?.lua;src/core/?.lua;src/entities/?.lua;src/systems/?.lua;src/ui/?.lua;src/animations/?.lua;src/network/?.lua;account/?.lua;map/?.lua;map/maps/?.lua;map/minimap/?.lua;npcs/?.lua;lib/?.lua;src/tools/?.lua;src/data/?.lua"

-- Early intercept for asset generation (before loading game modules)
local rawArgs = arg or {}
for _, a in ipairs(rawArgs) do
    if a == "--generate-assets" then
        love.update = function() end
        love.draw = function()
            love.graphics.clear(0.1, 0.1, 0.18)
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.printf("Generating placeholder assets...", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
        end
        function love.load()
            love.window.setTitle("Asset Generator")
            love.window.setMode(800, 400, {resizable=false})
            local ok, err = pcall(function()
                local PlaceholderAssets = require("src.tools.placeholder_assets")
                PlaceholderAssets.generate_all()
            end)
            if ok then
                print("=== Placeholder assets generated successfully! ===")
            else
                print("ERROR: " .. tostring(err))
            end
            love.event.quit()
        end
        return
    end
end

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
    game.assetManager = AssetManager.create()
    AssetManager.load_all(game.assetManager)

    -- Initialize game state
    game.state = GameState.create(game.assetManager)

    -- Initialize render system first
    game.renderSystem = RenderSystem.create(game.state, game.assetManager)

    -- Initialize input system with render system
    game.inputSystem = InputSystem.create(game.state, game.renderSystem)

    -- Set background color
    love.graphics.setBackgroundColor(0.15, 0.15, 0.2)

    print("Game loaded successfully!")
    print("Battle System Active - Walk around to encounter enemies!")
    print("Battle Controls: WASD/Arrows to navigate, Enter/Space to confirm")
end

function love.update(dt)
    if game.state then
        GameState.update(game.state, dt)
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
    if game.state and GameState.get_mode(game.state) == "login" then
        GameState.keypressed(game.state, key)
    elseif game.state and GameState.get_mode(game.state) == "character_select" then
        GameState.keypressed(game.state, key)
    elseif game.inputSystem then
        game.inputSystem:keypressed(key)
    end
end

function love.textinput(text)
    -- Handle login text input
    if game.state and GameState.get_mode(game.state) == "login" then
        GameState.textinput(game.state, text)
    elseif game.state and GameState.get_mode(game.state) == "character_select" then
        GameState.textinput(game.state, text)
    elseif game.state and GameState.get_mode(game.state) == "exploration" then
        -- Handle chat input
        local chatSystem = GameState.get_chat_system(game.state)
        if chatSystem and chatSystem:isInputting() then
            chatSystem:addInputChar(text)
        end
    end
end

function love.mousepressed(x, y, button)
    -- Handle mouse input based on game mode
    if game.state and GameState.get_mode(game.state) == "login" then
        GameState.mousepressed(game.state, x, y, button)
    elseif game.state and GameState.get_mode(game.state) == "character_select" then
        GameState.mousepressed(game.state, x, y, button)
    elseif game.inputSystem then
        game.inputSystem:mousepressed(x, y, button)
    end
end

function love.wheelmoved(x, y)
    -- Handle mouse wheel scroll
    if game.inputSystem then
        game.inputSystem:wheelmoved(x, y)
    end
end

function love.mousemoved(x, y)
    -- Handle mouse move (for hover effects)
    if game.inputSystem then
        game.inputSystem:mousemoved(x, y)
    end
end
