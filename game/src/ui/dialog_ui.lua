local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local DialogUI = {}

function DialogUI.create(assetManager)
    local state = {}
    state.assetManager = assetManager
    state.isOpen = false
    state.npc = nil
    state.lines = {}
    state.lineIndex = 1
    state.showAdvanced = false
    state.alpha = 0
    state.font = love.graphics.newFont(16)
    state.titleFont = love.graphics.newFont(18)
    return state
end

function DialogUI.open(state, npc)
    state.isOpen = true
    state.npc = npc
    state.lineIndex = 1
    state.alpha = 0
    state.showAdvanced = false

    state.lines = DialogUI._extract_lines(npc)
    if #state.lines == 0 then
        state.lines = { "..." }
    end
end

function DialogUI.close(state)
    state.isOpen = false
    state.npc = nil
    state.lines = {}
    state.lineIndex = 1
end

function DialogUI.is_open(state)
    return state.isOpen
end

function DialogUI._extract_lines(npc)
    if not npc then return {} end

    local dialogue = npc.dialogue
    if type(dialogue) == "string" then
        return { dialogue }
    end

    if type(dialogue) == "table" then
        if dialogue[1] and type(dialogue[1]) == "string" then
            local result = {}
            for _, line in ipairs(dialogue) do
                table.insert(result, line)
            end
            return result
        end

        if dialogue.onEngage then
            return { dialogue.onEngage }
        end
        if dialogue.greeting then
            return { dialogue.greeting }
        end
    end

    return {}
end

function DialogUI.update(state, dt)
    if not state.isOpen then return end
    if state.alpha < 1 then
        state.alpha = math.min(1, state.alpha + dt * 4)
    end
end

function DialogUI.draw(state)
    if not state.isOpen or not state.npc then return end

    local w, h = love.graphics.getDimensions()
    local panelW = math.min(900, w - 80)
    local panelH = 180
    local panelX = (w - panelW) / 2
    local panelY = h - panelH - 20

    love.graphics.setColor(1, 1, 1, state.alpha)

    Components.drawOrnateDialog(panelX, panelY, panelW, panelH, state.assetManager, state.npc.name)

    local avatarSize = 40
    local avatarX = panelX + 25
    local avatarY = panelY + 30

    love.graphics.setColor(state.npc.color or {0.5, 0.5, 0.5})
    love.graphics.circle("fill", avatarX + avatarSize / 2, avatarY + avatarSize / 2, avatarSize / 2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", avatarX + avatarSize * 0.35, avatarY + avatarSize * 0.4, 3)
    love.graphics.circle("fill", avatarX + avatarSize * 0.65, avatarY + avatarSize * 0.4, 3)
    love.graphics.arc("line", "open", avatarX + avatarSize / 2, avatarY + avatarSize * 0.6, avatarSize * 0.2, math.pi * 0.2, math.pi * 0.8)

    local textX = avatarX + avatarSize + 20
    local textY = panelY + 30
    local textW = panelW - avatarSize - 80
    local textH = panelH - 70

    if state.lines[state.lineIndex] then
        love.graphics.setFont(state.font)
        love.graphics.setColor(Theme.colors.dialog.text[1], Theme.colors.dialog.text[2], Theme.colors.dialog.text[3], state.alpha)
        love.graphics.printf(state.lines[state.lineIndex], textX, textY, textW, "left")
    end

    local isLast = state.lineIndex >= #state.lines
    local promptText = isLast and "[ESC] Close" or "[Space] Next"
    local promptW = state.titleFont:getWidth(promptText) + 20
    local promptX = panelX + panelW - promptW - 20
    local promptY = panelY + panelH - 35

    love.graphics.setFont(state.titleFont)
    local pulse = 0.5 + 0.5 * math.sin(Theme.get_anim_time() * 3)
    love.graphics.setColor(Theme.colors.dialog.prompt[1], Theme.colors.dialog.prompt[2], Theme.colors.dialog.prompt[3], pulse * state.alpha)
    love.graphics.printf(promptText, promptX, promptY, promptW, "right")

    if #state.lines > 1 then
        local pageText = string.format("%d/%d", state.lineIndex, #state.lines)
        love.graphics.setFont(state.font)
        love.graphics.setColor(Theme.colors.textDim[1], Theme.colors.textDim[2], Theme.colors.textDim[3], state.alpha * 0.6)
        love.graphics.print(pageText, panelX + 20, panelY + panelH - 30)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function DialogUI.advance(state)
    if not state.isOpen then return false end
    if state.lineIndex < #state.lines then
        state.lineIndex = state.lineIndex + 1
        return true
    end
    return false
end

function DialogUI.keypressed(state, key)
    if not state.isOpen then return false end

    if key == "space" or key == "return" then
        if not DialogUI.advance(state) then
            DialogUI.close(state)
        end
        return true
    elseif key == "escape" then
        DialogUI.close(state)
        return true
    end

    return false
end

function DialogUI.mousepressed(state, x, y, button)
    if not state.isOpen then return false end
    if button ~= 1 then return false end

    local w, h = love.graphics.getDimensions()
    local panelW = math.min(900, w - 80)
    local panelH = 180
    local panelX = (w - panelW) / 2
    local panelY = h - panelH - 20

    if x >= panelX and x <= panelX + panelW and y >= panelY and y <= panelY + panelH then
        if not DialogUI.advance(state) then
            DialogUI.close(state)
        end
        return true
    end

    return false
end

return DialogUI
