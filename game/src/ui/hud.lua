local MapRenderer = require("src.ui.map_renderer")
local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local Animation = require("src.ui.animation")

local HUD = {}

function HUD.create(assetManager)
    local state = {}

    state.assetManager = assetManager
    state.screenWidth = love.graphics.getWidth()
    state.screenHeight = love.graphics.getHeight()

    state.minimap = {
        size = 180,
        x = state.screenWidth - 200,
        y = 20,
        padding = 10
    }

    state.buttons = {
        {
            name = "Menu",
            key = "menu",
            gem = Theme.gem.topaz,
            width = 100,
            height = 50
        },
        {
            name = "Party",
            key = "party",
            gem = Theme.gem.sapphire,
            width = 100,
            height = 50
        },
        {
            name = "Pet",
            key = "pet",
            gem = Theme.gem.emerald,
            width = 100,
            height = 50
        }
    }

    state.hoveredButton = nil
    state.font = assetManager:get_font("default")
    state.fontLarge = assetManager:get_font("large")
    state.minimapHintAlpha = 0
    state.minimapHintTimer = 0
    state.panelState = Animation.create_panel_state()
    state.pulseState = Animation.create_pulse_state(3)

    return state
end

function HUD.update(state, dt)
    MapRenderer.update(dt)
    Animation.update_pulse(state.pulseState or {}, dt)

    if state.minimapHintTimer > 0 then
        state.minimapHintTimer = state.minimapHintTimer - dt
        state.minimapHintAlpha = math.max(0, state.minimapHintTimer / 2.0)
    end
end

function HUD.draw(state, playerX, playerY, map)
    HUD.draw_minimap(state, playerX, playerY, map)
    HUD.draw_buttons(state)
end

function HUD.draw_minimap(state, playerX, playerY, map)
    local mm = state.minimap
    local borderPad = 6

    Components.drawOrnatePanel(
        mm.x - borderPad, mm.y - borderPad,
        mm.size + borderPad * 2, mm.size + borderPad * 2,
        state.assetManager,
        { corners = true, glow = true, shimmer = true }
    )

    MapRenderer.render(map, mm.x, mm.y, mm.size, mm.size, playerX, playerY, {
        showPlayer = true,
        showBuildings = true,
        showEncounters = false,
        showNPCs = false,
        playerRadius = 5
    })

    local coordY = mm.y + mm.size + 10

    Components.drawOrnatePanel(mm.x, coordY, mm.size, 28, state.assetManager, {
        corners = false,
        glow = false
    })

    love.graphics.setFont(state.font)
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print(string.format("X: %.0f  Y: %.0f", playerX, playerY), mm.x + 10, coordY + 7)

    if map and map.name then
        local nameY = mm.y - 22
        Components.drawOrnatePanel(mm.x, nameY, mm.size, 20, state.assetManager, {
            corners = false,
            glow = false
        })

        love.graphics.setColor(Theme.gold.bright)
        love.graphics.printf(map.name, mm.x, nameY + 3, mm.size, "center")
    end

    if state.minimapHintAlpha > 0 then
        love.graphics.setColor(Theme.colors.warning[1], Theme.colors.warning[2], Theme.colors.warning[3], state.minimapHintAlpha * 0.8)
        love.graphics.setFont(state.font)
        love.graphics.printf("Click to open map", mm.x, mm.y + mm.size / 2 - 8, mm.size, "center")
    end

    love.graphics.setColor(1, 1, 1)
end

function HUD.is_mouse_over_minimap(state, x, y)
    local mm = state.minimap
    return x >= mm.x and x <= mm.x + mm.size and
           y >= mm.y and y <= mm.y + mm.size
end

function HUD.show_minimap_hint(state)
    state.minimapHintTimer = 2.0
    state.minimapHintAlpha = 1.0
end

function HUD.draw_buttons(state)
    local mouseX, mouseY = love.mouse.getPosition()
    local totalWidth = 0
    local gap = 10
    for _, btn in ipairs(state.buttons) do
        totalWidth = totalWidth + btn.width + gap
    end
    totalWidth = totalWidth - gap

    local startX = state.screenWidth - totalWidth - 20
    local startY = state.screenHeight - 60

    local btnX = startX
    for _, btn in ipairs(state.buttons) do
        btn.x = btnX
        btn.y = startY
        local isHovered = mouseX >= btn.x and mouseX <= btn.x + btn.width and
                         mouseY >= btn.y and mouseY <= btn.y + btn.height

        Components.drawOrnateButton(
            btn.x, btn.y, btn.width, btn.height,
            btn.name,
            isHovered and "hover" or "normal",
            state.assetManager,
            state.font,
            { gemColor = btn.gem }
        )

        btnX = btnX + btn.width + gap
    end

    love.graphics.setColor(1, 1, 1)
end

function HUD.is_mouse_over_button(state, x, y)
    for _, button in ipairs(state.buttons) do
        if button.x and button.y and
           x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height then
            return button.key
        end
    end
    return nil
end

return HUD
