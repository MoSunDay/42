local Theme = require("src.ui.theme")
local Components = require("src.ui.components")
local SpiritCrystalSystem = require("src.systems.spirit_crystal_system")

local ShopUI = {}

function ShopUI.create(assetManager)
    local state = {}
    state.assetManager = assetManager
    state.isOpen = false
    state.npc = nil
    state.items = {}
    state.selectedIndex = 1
    state.scrollOffset = 0
    state.spiritCrystalSystem = nil
    state.message = nil
    state.messageTimer = 0
    state.font = love.graphics.newFont(15)
    state.titleFont = love.graphics.newFont(18)
    state.smallFont = love.graphics.newFont(13)
    return state
end

function ShopUI.open(state, npc, spiritCrystalSystem)
    state.isOpen = true
    state.npc = npc
    state.spiritCrystalSystem = spiritCrystalSystem
    state.selectedIndex = 1
    state.scrollOffset = 0
    state.message = nil
    state.messageTimer = 0

    if npc and npc.shop then
        state.items = npc.shop
    else
        state.items = {}
    end
end

function ShopUI.close(state)
    state.isOpen = false
    state.npc = nil
    state.items = {}
    state.message = nil
end

function ShopUI.is_open(state)
    return state.isOpen
end

function ShopUI.update(state, dt)
    if not state.isOpen then return end
    if state.messageTimer > 0 then
        state.messageTimer = state.messageTimer - dt
        if state.messageTimer <= 0 then
            state.message = nil
        end
    end
end

function ShopUI._get_balance(state)
    if state.spiritCrystalSystem then
        return SpiritCrystalSystem.get_total_value(state.spiritCrystalSystem)
    end
    return 0
end

function ShopUI._try_buy(state, index)
    local item = state.items[index]
    if not item then return end

    local balance = ShopUI._get_balance(state)
    if balance < (item.crystalPrice or 0) then
        state.message = "Not enough spirit crystals!"
        state.messageTimer = 2.0
        return
    end

    if state.spiritCrystalSystem then
        local ok = SpiritCrystalSystem.spend_value(state.spiritCrystalSystem, item.crystalPrice)
        if ok then
            state.message = "Purchased: " .. item.name
            state.messageTimer = 2.0
        else
            state.message = "Purchase failed!"
            state.messageTimer = 2.0
        end
    end
end

function ShopUI.draw(state)
    if not state.isOpen then return end

    local w, h = love.graphics.getDimensions()
    local panelW = math.min(700, w - 80)
    local panelH = math.min(500, h - 100)
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2

    Components.drawOverlay(w, h, 0.5)
    Components.drawOrnatePanel(panelX, panelY, panelW, panelH, state.assetManager, {
        title = state.npc and (state.npc.name .. " - Shop") or "Shop",
        corners = true,
        glow = true,
    })

    local balance = ShopUI._get_balance(state)
    love.graphics.setFont(state.smallFont)
    love.graphics.setColor(Theme.gold.bright)
    love.graphics.printf(
        "Balance: " .. balance .. " crystals",
        panelX + 20, panelY + 20, panelW - 40, "right"
    )

    local listX = panelX + 20
    local listY = panelY + 45
    local listW = panelW * 0.55
    local itemH = 50
    local visibleItems = math.floor((panelH - 120) / itemH)

    for i = 1, math.min(#state.items, visibleItems) do
        local itemIndex = i + state.scrollOffset
        if itemIndex > #state.items then break end

        local item = state.items[itemIndex]
        local iy = listY + (i - 1) * itemH
        local isSelected = itemIndex == state.selectedIndex
        local canAfford = balance >= (item.crystalPrice or 0)

        if isSelected then
            love.graphics.setColor(Theme.colors.inventory.slotSelected)
            love.graphics.rectangle("fill", listX, iy, listW, itemH - 4, 5, 5)
        else
            love.graphics.setColor(Theme.colors.panel)
            love.graphics.rectangle("fill", listX, iy, listW, itemH - 4, 5, 5)
        end

        love.graphics.setFont(state.font)
        love.graphics.setColor(canAfford and Theme.colors.text or Theme.colors.textDim)
        love.graphics.print(item.name or "???", listX + 10, iy + 5)

        love.graphics.setFont(state.smallFont)
        love.graphics.setColor(Theme.gold.normal)
        love.graphics.print((item.crystalPrice or 0) .. " crystals", listX + 10, iy + 26)

        local stats = {}
        if item.attack and item.attack > 0 then table.insert(stats, "ATK+" .. item.attack) end
        if item.defense and item.defense > 0 then table.insert(stats, "DEF+" .. item.defense) end
        if item.speed and item.speed > 0 then table.insert(stats, "SPD+" .. item.speed) end
        if #stats > 0 then
            love.graphics.setColor(Theme.colors.stat.hp)
            love.graphics.print(table.concat(stats, "  "), listX + listW - 150, iy + 26)
        end

        love.graphics.setColor(Theme.colors.border)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", listX, iy, listW, itemH - 4, 5, 5)
    end

    local detailX = panelX + listW + 40
    local detailY = listY
    local detailW = panelW - listW - 60

    Components.drawOrnatePanel(detailX, detailY, detailW, 150, state.assetManager, {
        corners = false,
        glow = false,
    })

    local selItem = state.items[state.selectedIndex]
    if selItem then
        love.graphics.setFont(state.titleFont)
        love.graphics.setColor(Theme.colors.text)
        love.graphics.printf(selItem.name, detailX + 10, detailY + 10, detailW - 20, "center")

        love.graphics.setFont(state.font)
        local dy = detailY + 40
        if selItem.attack and selItem.attack > 0 then
            love.graphics.setColor(Theme.colors.equipment.weapon)
            love.graphics.print("  ATK: +" .. selItem.attack, detailX + 10, dy)
            dy = dy + 20
        end
        if selItem.defense and selItem.defense > 0 then
            love.graphics.setColor(Theme.colors.equipment.clothes)
            love.graphics.print("  DEF: +" .. selItem.defense, detailX + 10, dy)
            dy = dy + 20
        end
        if selItem.speed and selItem.speed > 0 then
            love.graphics.setColor(Theme.colors.stat.speed)
            love.graphics.print("  SPD: +" .. selItem.speed, detailX + 10, dy)
        end

        love.graphics.setFont(state.smallFont)
        love.graphics.setColor(Theme.colors.textDim)
        love.graphics.printf(
            "Price: " .. (selItem.crystalPrice or 0) .. " crystals",
            detailX + 10, detailY + 120, detailW - 20, "center"
        )
    end

    local buyBtnY = detailY + 170
    local buyBtnW = detailW
    local buyBtnH = 35
    local canBuy = selItem and balance >= (selItem.crystalPrice or 0)
    Components.drawOrnateButton(detailX, buyBtnY, buyBtnW, buyBtnH,
        "Buy", canBuy and "normal" or "disabled", state.assetManager, state.font)

    local closeBtnY = panelY + panelH - 50
    local closeBtnW = 120
    local closeBtnX = panelX + panelW - closeBtnW - 20
    Components.drawOrnateButton(closeBtnX, closeBtnY, closeBtnW, 35,
        "Close (ESC)", "normal", state.assetManager, state.smallFont)

    if state.message then
        love.graphics.setFont(state.font)
        local msgColor = state.message:find("Purchased") and Theme.colors.success or Theme.colors.error
        love.graphics.setColor(msgColor)
        love.graphics.printf(state.message, panelX, panelY + panelH - 85, panelW, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function ShopUI.keypressed(state, key)
    if not state.isOpen then return false end

    if key == "escape" then
        ShopUI.close(state)
        return true
    elseif key == "up" then
        state.selectedIndex = math.max(1, state.selectedIndex - 1)
        return true
    elseif key == "down" then
        state.selectedIndex = math.min(#state.items, state.selectedIndex + 1)
        return true
    elseif key == "return" or key == "space" then
        ShopUI._try_buy(state, state.selectedIndex)
        return true
    end

    return false
end

function ShopUI.mousepressed(state, x, y, button)
    if not state.isOpen then return false end
    if button ~= 1 then return false end

    local w, h = love.graphics.getDimensions()
    local panelW = math.min(700, w - 80)
    local panelH = math.min(500, h - 100)
    local panelX = (w - panelW) / 2
    local panelY = (h - panelH) / 2

    local listX = panelX + 20
    local listY = panelY + 45
    local listW = panelW * 0.55
    local itemH = 50
    local visibleItems = math.floor((panelH - 120) / itemH)

    for i = 1, math.min(#state.items, visibleItems) do
        local itemIndex = i + state.scrollOffset
        if itemIndex > #state.items then break end
        local iy = listY + (i - 1) * itemH
        if x >= listX and x <= listX + listW and y >= iy and y <= iy + itemH - 4 then
            state.selectedIndex = itemIndex
            return true
        end
    end

    local detailX = panelX + listW + 40
    local detailW = panelW - listW - 60
    local buyBtnY = listY + 170
    local buyBtnH = 35
    if x >= detailX and x <= detailX + detailW and y >= buyBtnY and y <= buyBtnY + buyBtnH then
        ShopUI._try_buy(state, state.selectedIndex)
        return true
    end

    local closeBtnW = 120
    local closeBtnX = panelX + panelW - closeBtnW - 20
    local closeBtnY = panelY + panelH - 50
    if x >= closeBtnX and x <= closeBtnX + closeBtnW and y >= closeBtnY and y <= closeBtnY + 35 then
        ShopUI.close(state)
        return true
    end

    return false
end

return ShopUI
