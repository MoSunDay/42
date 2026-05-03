local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local Particles = require("src.ui.particles")

local RewardUI = {}

function RewardUI.create(assetManager)
    local state = {}
    state.assetManager = assetManager
    state.isVisible = false
    state.rewards = nil
    state.alpha = 0
    state.revealIndex = 0
    state.revealTimer = 0
    state.font = love.graphics.newFont(22)
    state.titleFont = love.graphics.newFont(30)
    state.smallFont = love.graphics.newFont(16)
    return state
end

function RewardUI.show(state, rewards)
    state.isVisible = true
    state.rewards = rewards or {}
    state.alpha = 0
    state.revealIndex = 0
    state.revealTimer = 0

    if state.rewards.crystals then
        Particles.emit(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 - 50,
            "goldDust", #state.rewards.crystals * 3)
    end
end

function RewardUI.hide(state)
    state.isVisible = false
    state.rewards = nil
    state.revealIndex = 0
end

function RewardUI.is_visible(state)
    return state.isVisible
end

function RewardUI.update(state, dt)
    if not state.isVisible then return end

    if state.alpha < 1 then
        state.alpha = math.min(1, state.alpha + dt * 3)
    end

    if state.rewards and state.rewards.crystals then
        local totalCrystals = #state.rewards.crystals
        if state.revealIndex < totalCrystals then
            state.revealTimer = state.revealTimer + dt
            if state.revealTimer > 0.3 then
                state.revealTimer = 0
                state.revealIndex = state.revealIndex + 1
            end
        end
    else
        state.revealIndex = 0
    end
end

function RewardUI.draw(state)
    if not state.isVisible then return end

    local w, h = love.graphics.getDimensions()

    Components.drawOverlay(w, h, 0.6 * state.alpha)

    local panelW = math.min(500, w - 100)
    local panelH = 300
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2

    love.graphics.setColor(1, 1, 1, state.alpha)
    Components.drawOrnatePanel(panelX, panelY, panelW, panelH, state.assetManager, {
        title = "Victory!",
        corners = true,
        glow = true,
        shimmer = true,
        borderColor = Theme.colors.battle.victory,
    })

    love.graphics.setFont(state.titleFont)
    local victoryPulse = 0.8 + 0.2 * math.sin(Theme.get_anim_time() * 3)
    love.graphics.setColor(Theme.colors.battle.victory[1], Theme.colors.battle.victory[2], Theme.colors.battle.victory[3], state.alpha * victoryPulse)
    love.graphics.printf("VICTORY", panelX, panelY + 30, panelW, "center")

    local crystals = (state.rewards and state.rewards.crystals) or {}
    if #crystals > 0 then
        love.graphics.setFont(state.font)
        love.graphics.setColor(Theme.colors.text[1], Theme.colors.text[2], Theme.colors.text[3], state.alpha)
        love.graphics.printf("Spirit Crystals Obtained:", panelX, panelY + 80, panelW, "center")

        local itemY = panelY + 115
        for i = 1, math.min(state.revealIndex, #crystals) do
            local crystal = crystals[i]
            local cy = itemY + (i - 1) * 30

            if crystal.color then
                Theme.draw_gem_icon(panelX + panelW / 2 - 100, cy + 8, 6, crystal.color)
            end

            love.graphics.setFont(state.smallFont)
            love.graphics.setColor(Theme.colors.text[1], Theme.colors.text[2], Theme.colors.text[3], state.alpha)
            love.graphics.print(
                (crystal.name or "Crystal") .. "  x1",
                panelX + panelW / 2 - 70, cy
            )

            if crystal.value then
                love.graphics.setColor(Theme.gold.normal)
                love.graphics.print(
                    "Value: " .. crystal.value,
                    panelX + panelW / 2 + 50, cy
                )
            end
        end

        if state.revealIndex >= #crystals then
            local totalValue = 0
            for _, c in ipairs(crystals) do
                totalValue = totalValue + (c.value or 0)
            end
            love.graphics.setFont(state.font)
            love.graphics.setColor(Theme.gold.bright[1], Theme.gold.bright[2], Theme.gold.bright[3], state.alpha)
            love.graphics.printf("Total: " .. totalValue, panelX, panelY + panelH - 80, panelW, "center")
        end
    else
        love.graphics.setFont(state.font)
        love.graphics.setColor(Theme.colors.textDim[1], Theme.colors.textDim[2], Theme.colors.textDim[3], state.alpha)
        love.graphics.printf("No rewards", panelX, panelY + 120, panelW, "center")
    end

    local continueAlpha = state.alpha * (0.5 + 0.5 * math.sin(Theme.get_anim_time() * 3))
    love.graphics.setFont(state.smallFont)
    love.graphics.setColor(Theme.colors.textDim[1], Theme.colors.textDim[2], Theme.colors.textDim[3], continueAlpha)
    love.graphics.printf("Press SPACE to continue", panelX, panelY + panelH - 40, panelW, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

function RewardUI.is_complete(state)
    if not state.isVisible or not state.rewards then return false end
    local crystals = state.rewards.crystals or {}
    return state.revealIndex >= #crystals
end

function RewardUI.keypressed(state, key)
    if not state.isVisible then return false end
    if key == "space" or key == "return" then
        return true
    end
    return false
end

function RewardUI.mousepressed(state, x, y, button)
    if not state.isVisible then return false end
    if button == 1 then
        return true
    end
    return false
end

return RewardUI
