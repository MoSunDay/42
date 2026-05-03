local MapRenderer = require("src.ui.map_renderer")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local FullscreenMap = {}

function FullscreenMap.create(assetManager)
    local state = {}

    state.assetManager = assetManager
    state.isOpen = false
    
    state.screenWidth = love.graphics.getWidth()
    state.screenHeight = love.graphics.getHeight()
    
    state.panelWidth = state.screenWidth * 0.8
    state.panelHeight = state.screenHeight * 0.8
    state.panelX = (state.screenWidth - state.panelWidth) / 2
    state.panelY = (state.screenHeight - state.panelHeight) / 2
    
    state.padding = 40
    state.mapRenderWidth = state.panelWidth - state.padding * 2
    state.mapRenderHeight = state.panelHeight - state.padding * 2
    state.mapRenderX = state.panelX + state.padding
    state.mapRenderY = state.panelY + state.padding
    
    state.colors = Theme.colors.map
    
    state.navigationTarget = nil
    
    state.font = assetManager:get_font("default")
    state.fontLarge = assetManager:get_font("large")
    
    return state
end

function FullscreenMap.toggle(state)
    state.isOpen = not state.isOpen
    if not state.isOpen then
        state.navigationTarget = nil
    end
end

function FullscreenMap.open(state)
    state.isOpen = true
end

function FullscreenMap.close(state)
    state.isOpen = false
    state.navigationTarget = nil
end

function FullscreenMap.is_map_open(state)
    return state.isOpen
end

function FullscreenMap.mousepressed(state, x, y, button, map)
    if not state.isOpen then
        return nil
    end

    if x >= state.mapRenderX and x <= state.mapRenderX + state.mapRenderWidth and
       y >= state.mapRenderY and y <= state.mapRenderY + state.mapRenderHeight then

        if button == 1 then
            local worldX = ((x - state.mapRenderX) / state.mapRenderWidth) * map.width
            local worldY = ((y - state.mapRenderY) / state.mapRenderHeight) * map.height

            state.navigationTarget = {x = worldX, y = worldY}

            state.isOpen = false
            return worldX, worldY
        end
    end

    if x < state.panelX or x > state.panelX + state.panelWidth or
       y < state.panelY or y > state.panelY + state.panelHeight then
        FullscreenMap.close(state)
    end

    return nil
end

function FullscreenMap.draw(state, playerX, playerY, map)
    if not state.isOpen then
        return
    end

    local w, h = state.screenWidth, state.screenHeight
    Components.drawOverlay(w, h, state.colors.overlay[4])

    Components.drawOrnatePanel(state.panelX, state.panelY, state.panelWidth, state.panelHeight, state.assetManager, {
        title = "World Map",
        corners = true,
        glow = true,
        shimmer = true,
        font = state.fontLarge
    })

    love.graphics.setFont(state.font)

    FullscreenMap.draw_map_content(state, playerX, playerY, map)

    love.graphics.setColor(Theme.colors.textDim)
    love.graphics.printf("Click on map to navigate | Press TAB or ESC to close",
                        state.panelX, state.panelY + state.panelHeight - 25,
                        state.panelWidth, "center")
end

function FullscreenMap.draw_map_content(state, playerX, playerY, map)
    MapRenderer.render(map, state.mapRenderX, state.mapRenderY,
                      state.mapRenderWidth, state.mapRenderHeight,
                      playerX, playerY, {
        showPlayer = true,
        showBuildings = true,
        showEncounters = false,
        showNPCs = false,
        playerRadius = 8
    })

    local playerMapX = state.mapRenderX + (playerX / map.width) * state.mapRenderWidth
    local playerMapY = state.mapRenderY + (playerY / map.height) * state.mapRenderHeight

    love.graphics.setColor(state.colors.text)
    love.graphics.printf(string.format("Player: (%.0f, %.0f)", playerX, playerY),
                        playerMapX - 50, playerMapY + 40, 100, "center")

    if state.navigationTarget then
        local targetMapX = state.mapRenderX + (state.navigationTarget.x / map.width) * state.mapRenderWidth
        local targetMapY = state.mapRenderY + (state.navigationTarget.y / map.height) * state.mapRenderHeight
        
        local pulse = 0.5 + 0.5 * math.sin(love.timer.getTime() * 3)
        love.graphics.setColor(state.colors.navigationTarget[1], 
                              state.colors.navigationTarget[2], 
                              state.colors.navigationTarget[3], 
                              pulse)
        love.graphics.circle("fill", targetMapX, targetMapY, 10)
        
        love.graphics.setColor(state.colors.navigationTarget[1], state.colors.navigationTarget[2], state.colors.navigationTarget[3])
        love.graphics.circle("line", targetMapX, targetMapY, 10)
        love.graphics.circle("line", targetMapX, targetMapY, 15)
        
        love.graphics.setColor(state.colors.navigationLine)
        love.graphics.setLineWidth(2)
        love.graphics.line(playerMapX, playerMapY, targetMapX, targetMapY)
        love.graphics.setLineWidth(1)
    end
end

function FullscreenMap.get_navigation_target(state)
    return state.navigationTarget
end

function FullscreenMap.clear_navigation_target(state)
    state.navigationTarget = nil
end

return FullscreenMap
