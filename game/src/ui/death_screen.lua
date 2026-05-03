local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local DeathScreen = {}

function DeathScreen.create(assetManager)
    local state = {}
    state.assetManager = assetManager
    state.isVisible = false
    state.alpha = 0
    state.font = love.graphics.newFont(42)
    state.subFont = love.graphics.newFont(20)
    state.smallFont = love.graphics.newFont(16)
    return state
end

function DeathScreen.show(state)
    state.isVisible = true
    state.alpha = 0
end

function DeathScreen.hide(state)
    state.isVisible = false
    state.alpha = 0
end

function DeathScreen.is_visible(state)
    return state.isVisible
end

function DeathScreen.update(state, dt)
    if not state.isVisible then return end
    if state.alpha < 1 then
        state.alpha = math.min(1, state.alpha + dt * 1.5)
    end
end

function DeathScreen.draw(state)
    if not state.isVisible then return end

    local w, h = love.graphics.getDimensions()

    Components.drawOverlay(w, h, 0.75 * state.alpha)

    love.graphics.setColor(1, 1, 1, state.alpha)

    local text = "YOU DIED"
    love.graphics.setFont(state.font)
    local tw = state.font:getWidth(text)
    local tx = (w - tw) / 2
    local ty = h / 2 - 80

    love.graphics.setColor(0, 0, 0, 0.7 * state.alpha)
    love.graphics.rectangle("fill", tx - 30, ty - 10, tw + 60, 60, 10, 10)

    local defeatPulse = 0.7 + 0.3 * math.sin(Theme.get_anim_time() * 2)
    love.graphics.setColor(
        Theme.colors.battle.defeat[1],
        Theme.colors.battle.defeat[2],
        Theme.colors.battle.defeat[3],
        state.alpha * defeatPulse
    )
    love.graphics.printf(text, 0, ty, w, "center")

    love.graphics.setFont(state.subFont)
    love.graphics.setColor(Theme.colors.textDim[1], Theme.colors.textDim[2], Theme.colors.textDim[3], state.alpha * 0.8)
    love.graphics.printf("You will be revived at the village...", 0, ty + 70, w, "center")

    local btnW = 200
    local btnH = 40
    local btnX = (w - btnW) / 2
    local btnY = ty + 120

    Components.drawOrnateButton(btnX, btnY, btnW, btnH,
        "Revive", "normal", state.assetManager, state.subFont)

    love.graphics.setFont(state.smallFont)
    local continueAlpha = state.alpha * (0.5 + 0.5 * math.sin(Theme.get_anim_time() * 3))
    love.graphics.setColor(Theme.colors.textDim[1], Theme.colors.textDim[2], Theme.colors.textDim[3], continueAlpha)
    love.graphics.printf("Press SPACE to revive", 0, btnY + 50, w, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

function DeathScreen.keypressed(state, key)
    if not state.isVisible then return false end
    if key == "space" or key == "return" then
        return true
    end
    return false
end

function DeathScreen.mousepressed(state, x, y, button)
    if not state.isVisible then return false end
    if button ~= 1 then return false end

    local w, h = love.graphics.getDimensions()
    local btnW = 200
    local btnH = 40
    local btnX = (w - btnW) / 2
    local btnY = h / 2 - 80 + 120

    if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
        return true
    end

    return false
end

return DeathScreen
