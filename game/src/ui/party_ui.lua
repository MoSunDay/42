local Theme = require("src.ui.theme")
local Components = require("src.ui.components")

local PartyUI = {}

function PartyUI.create(assetManager)
    local state = {}
    state.assetManager = assetManager
    state.x = 10
    state.y = 220
    state.width = 200
    state.memberHeight = 65
    state.font = assetManager:getFont("default")
    state.isVisible = true
    return state
end

function PartyUI.toggle(state)
    state.isVisible = not state.isVisible
end

function PartyUI.setVisible(state, visible)
    state.isVisible = visible
end

function PartyUI.draw(state, partySystem)
    if not state.isVisible or partySystem:isEmpty() then
        return
    end

    local members = partySystem:getMembers()
    local leaderIndex = partySystem.leaderIndex
    local totalHeight = 30 + #members * (state.memberHeight + 5)

    Components.drawOrnatePanel(state.x, state.y, state.width, totalHeight, state.assetManager, {
        title = partySystem:getPartyName() .. " (" .. #members .. "/5)",
        corners = true,
        glow = true,
        font = state.font,
        borderColor = Theme.colors.party.border
    })

    local memberY = state.y + 30
    for i, member in ipairs(members) do
        PartyUI.drawMember(state, member, state.x + 5, memberY, i == leaderIndex)
        memberY = memberY + state.memberHeight + 5
    end
end

function PartyUI.drawMember(state, member, x, y, isLeader)
    local w = state.width - 10
    local h = state.memberHeight

    Components.drawOrnatePanel(x, y, w, h, state.assetManager, {
        corners = false,
        glow = isLeader,
        shimmer = isLeader,
        borderColor = isLeader and Theme.colors.party.leaderBorder or Theme.colors.borderDim
    })

    local avatarX = x + 22
    local avatarY = y + h / 2
    local avatarSize = 12

    local gemColor = member.isOnline and (member.avatarColor or Theme.gem.sapphire) or Theme.gem.diamond
    Components.drawGemButton(avatarX - avatarSize, avatarY - avatarSize, avatarSize * 2, gemColor, false, false)

    if isLeader then
        love.graphics.setFont(state.font)
        love.graphics.setColor(Theme.gold.bright)
        love.graphics.print("*", avatarX - 6, y + 2)
    end

    love.graphics.setFont(state.font)
    love.graphics.setColor(Theme.colors.text)
    love.graphics.print(member.name, avatarX + avatarSize + 12, y + 6)

    local barX = avatarX + avatarSize + 12
    local barW = w - (avatarX + avatarSize + 17 - x)
    local hpPercent = member.hp / member.maxHp

    Components.drawOrnateHPBar(barX, y + 24, barW, 14, hpPercent, member.level or 1, state.assetManager)

    if member.mp and member.maxMp then
        local mpPercent = member.mp / member.maxMp
        Components.drawOrnateMPBar(barX, y + 42, barW, 12, mpPercent, state.assetManager)
    end

    if not member.isOnline then
        love.graphics.setColor(Theme.colors.error)
        love.graphics.setFont(state.font)
        love.graphics.print("Offline", x + w - 55, y + 6)
    end
end

function PartyUI.isMouseOver(state, x, y, partySystem)
    if not state.isVisible or partySystem:isEmpty() then
        return false
    end

    local members = partySystem:getMembers()
    local totalHeight = 30 + #members * (state.memberHeight + 5)

    return x >= state.x and x <= state.x + state.width and
           y >= state.y and y <= state.y + totalHeight
end

return PartyUI
