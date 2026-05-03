local Theme = require("src.ui.theme")

local Components = {}

Components.CORNER_SIZE = 12

function Components.draw9Slice(img, x, y, w, h, cornerSize)
    if not img then return false end
    
    local iw, ih = img:getWidth(), img:getHeight()
    local cs = cornerSize or Components.CORNER_SIZE
    cs = math.min(cs, math.min(iw, ih) / 3)
    
    local scaleX = (w - 2 * cs) / (iw - 2 * cs)
    local scaleY = (h - 2 * cs) / (ih - 2 * cs)
    
    love.graphics.draw(img, 
        love.graphics.newQuad(0, 0, cs, cs, iw, ih),
        x, y)
    love.graphics.draw(img,
        love.graphics.newQuad(iw - cs, 0, cs, cs, iw, ih),
        x + w - cs, y)
    love.graphics.draw(img,
        love.graphics.newQuad(0, ih - cs, cs, cs, iw, ih),
        x, y + h - cs)
    love.graphics.draw(img,
        love.graphics.newQuad(iw - cs, ih - cs, cs, cs, iw, ih),
        x + w - cs, y + h - cs)
    
    love.graphics.draw(img,
        love.graphics.newQuad(cs, 0, iw - 2 * cs, cs, iw, ih),
        x + cs, y, 0, scaleX, 1)
    love.graphics.draw(img,
        love.graphics.newQuad(cs, ih - cs, iw - 2 * cs, cs, iw, ih),
        x + cs, y + h - cs, 0, scaleX, 1)
    love.graphics.draw(img,
        love.graphics.newQuad(0, cs, cs, ih - 2 * cs, iw, ih),
        x, y + cs, 0, 1, scaleY)
    love.graphics.draw(img,
        love.graphics.newQuad(iw - cs, cs, cs, ih - 2 * cs, iw, ih),
        x + w - cs, y + cs, 0, 1, scaleY)
    
    love.graphics.draw(img,
        love.graphics.newQuad(cs, cs, iw - 2 * cs, ih - 2 * cs, iw, ih),
        x + cs, y + cs, 0, scaleX, scaleY)
    
    return true
end

function Components.draw_slot(x, y, size, state, assetManager)
    state = state or "normal"
    local slotName = "slot_" .. state
    local slot = assetManager and assetManager:get_ui_slot(slotName)
    
    if slot then
        local scale = size / slot:getWidth()
        love.graphics.draw(slot, x, y, 0, scale, scale)
        return true
    end
    
    local color = Theme.colors.inventory["slot" .. state:gsub("^%l", string.upper)] 
                  or Theme.colors.inventory.slot
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, size, size, 5, 5)
    love.graphics.setColor(Theme.colors.inventory.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, size, size, 5, 5)
    
    return false
end

function Components.drawHPBar(x, y, w, h, percent, assetManager)
    percent = math.max(0, math.min(1, percent))
    
    local bgBar = assetManager and assetManager:get_ui_bar("hp_bar_bg")
    if bgBar then
        local scaleX = w / bgBar:getWidth()
        local scaleY = h / bgBar:getHeight()
        love.graphics.draw(bgBar, x, y, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.12, 0.12, 0.12)
        love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    end
    
    local fillColor = Theme.getHpColor(percent)
    local fillName = percent > 0.6 and "hp_bar_high" or (percent > 0.3 and "hp_bar_medium" or "hp_bar_low")
    local fillBar = assetManager and assetManager:get_ui_bar(fillName)
    
    if fillBar then
        local fillW = w * percent
        local scaleX = w / fillBar:getWidth()
        local scaleY = h / fillBar:getHeight()
        love.graphics.setScissor(x, y, fillW, h)
        love.graphics.draw(fillBar, x, y, 0, scaleX, scaleY)
        love.graphics.setScissor()
    else
        love.graphics.setColor(fillColor)
        love.graphics.rectangle("fill", x, y, w * percent, h, 3, 3)
    end
    
    love.graphics.setColor(Theme.colors.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 3, 3)
end

function Components.drawMPBar(x, y, w, h, percent, assetManager)
    percent = math.max(0, math.min(1, percent))
    
    local bgBar = assetManager and assetManager:get_ui_bar("mp_bar_bg")
    if bgBar then
        local scaleX = w / bgBar:getWidth()
        local scaleY = h / bgBar:getHeight()
        love.graphics.draw(bgBar, x, y, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.12, 0.12, 0.12)
        love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    end
    
    local fillBar = assetManager and assetManager:get_ui_bar("mp_bar_fill")
    if fillBar then
        local fillW = w * percent
        local scaleX = w / fillBar:getWidth()
        local scaleY = h / fillBar:getHeight()
        love.graphics.setScissor(x, y, fillW, h)
        love.graphics.draw(fillBar, x, y, 0, scaleX, scaleY)
        love.graphics.setScissor()
    else
        love.graphics.setColor(Theme.colors.mp)
        love.graphics.rectangle("fill", x, y, w * percent, h, 3, 3)
    end
    
    love.graphics.setColor(Theme.colors.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 3, 3)
end

function Components.drawInput(x, y, w, h, is_active, assetManager)
    local inputName = is_active and "input_field_active" or "input_field"
    local input = assetManager and assetManager:get_ui_asset("input", inputName)
    
    if input and Components.draw9Slice(input, x, y, w, h, 6) then
        return true
    end
    
    love.graphics.setColor(is_active and Theme.colors.input.backgroundActive or Theme.colors.input.background)
    love.graphics.rectangle("fill", x, y, w, h, 5, 5)
    love.graphics.setColor(is_active and Theme.colors.input.borderActive or Theme.colors.input.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 5, 5)
    love.graphics.setLineWidth(1)
    
    return false
end

function Components.drawTab(x, y, w, h, text, is_active, assetManager, font)
    local tabName = is_active and "tab_active" or "tab_inactive"
    local tab = assetManager and assetManager:get_ui_asset("tabs", tabName)
    
    if tab then
        local scale = w / tab:getWidth()
        love.graphics.draw(tab, x, y, 0, scale, h / tab:getHeight())
    else
        love.graphics.setColor(is_active and Theme.colors.tab.active or Theme.colors.tab.inactive)
        love.graphics.rectangle("fill", x, y, w, h, 5, 5)
    end
    
    if text and font then
        love.graphics.setFont(font)
        love.graphics.setColor(Theme.colors.text)
        local textWidth = font:getWidth(text)
        love.graphics.print(text, x + (w - textWidth) / 2, y + (h - font:getHeight()) / 2)
    end
end

function Components.drawDialog(x, y, w, h, assetManager)
    local dialog = assetManager and assetManager:get_dialog_asset("dialog_panel")
    
    if dialog and Components.draw9Slice(dialog, x, y, w, h) then
        return true
    end
    
    love.graphics.setColor(Theme.colors.dialog.background)
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)
    love.graphics.setColor(Theme.colors.dialog.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 10, 10)
    love.graphics.setLineWidth(1)
    
    return false
end

function Components.drawTooltip(x, y, w, h, assetManager)
    local tooltip = assetManager and assetManager:get_dialog_asset("tooltip_bg")
    
    if tooltip and Components.draw9Slice(tooltip, x, y, w, h, 8) then
        return true
    end
    
    love.graphics.setColor(Theme.colors.tooltip.background)
    love.graphics.rectangle("fill", x, y, w, h, 5, 5)
    love.graphics.setColor(Theme.colors.tooltip.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, w, h, 5, 5)
    
    return false
end

function Components.drawOverlay(w, h, alpha)
    alpha = alpha or 0.7
    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.rectangle("fill", 0, 0, w, h)
end

function Components.drawBorder(x, y, w, h, radius, is_active)
    radius = radius or 10
    love.graphics.setColor(is_active and Theme.colors.borderBright or Theme.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, radius, radius)
    love.graphics.setLineWidth(1)
end

function Components.drawOrnatePanel(x, y, w, h, assetManager, options)
    options = options or {}
    local showTitle = options.title
    local showGlow = options.glow ~= false
    local showCorners = options.corners ~= false
    local showShimmer = options.shimmer

    local style = options.style or "small_panel"
    local panel = assetManager and assetManager:get_ui_panel(style)
    if not panel and style ~= "small_panel" then
        panel = assetManager and assetManager:get_ui_panel("small_panel")
    end

    if panel and Components.draw9Slice(panel, x, y, w, h) then
        if showCorners then
            Theme.drawCornerOrnaments(x + 3, y + 3, w - 6, h - 6, options.cornerSize or 10)
        end
        if showGlow then
            local borderColor = options.borderColor or Theme.colors.border
            Theme.drawGlow(x, y, w, h, borderColor, options.glowIntensity or 0.2)
        end
        if showShimmer then
            Theme.drawShimmer(x, y, w, h, 0.8)
        end
    else
        love.graphics.setColor(Theme.colors.panel)
        love.graphics.rectangle("fill", x, y, w, h, 8, 8)

        local borderColor = options.borderColor or Theme.colors.border
        love.graphics.setColor(borderColor)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, w, h, 8, 8)
        love.graphics.setLineWidth(1)

        if showGlow then
            Theme.drawGlow(x, y, w, h, borderColor, options.glowIntensity or 0.2)
        end

        if showShimmer then
            Theme.drawShimmer(x, y, w, h, 0.8)
        end

        if showCorners then
            Theme.drawCornerOrnaments(x + 3, y + 3, w - 6, h - 6, options.cornerSize or 10)
        end
    end

    if showTitle then
        local font = options.font or love.graphics.get_font()
        local titleW = font:getWidth(showTitle) + 30
        local titleX = x + (w - titleW) / 2
        local titleY = y - 8

        love.graphics.setColor(Theme.colors.panel)
        love.graphics.rectangle("fill", titleX, titleY, titleW, 18, 4, 4)

        Theme.drawGoldBorder(titleX, titleY, titleW, 18, 1)

        love.graphics.setFont(font)
        love.graphics.setColor(Theme.gold.bright)
        love.graphics.printf(showTitle, titleX, titleY + 2, titleW, "center")
    end
end

function Components.drawOrnateButton(x, y, w, h, text, state, assetManager, font, options)
    options = options or {}
    state = state or "normal"

    local isHovered = state == "hover"
    local isPressed = state == "pressed"
    local isDisabled = state == "disabled"

    local btnName = "button_" .. state
    local btn = assetManager and assetManager:get_ui_button(btnName)
    local usedAsset = false

    if btn then
        usedAsset = Components.draw9Slice(btn, x, y, w, h, 8)
    end

    if not usedAsset then
        local baseColor
        if isDisabled then
            baseColor = Theme.colors.buttonDisabled
        elseif isPressed then
            baseColor = Theme.colors.buttonPressed
        elseif isHovered then
            baseColor = Theme.colors.buttonHover
        else
            baseColor = Theme.colors.button
        end

        love.graphics.setColor(baseColor)
        love.graphics.rectangle("fill", x, y, w, h, 5, 5)

        Theme.drawGoldBorder(x, y, w, h, 1)

        if isHovered then
            love.graphics.setColor(Theme.gold.glow)
            love.graphics.rectangle("fill", x + 2, y + 2, w - 4, h - 4, 4, 4)
        end

        if isPressed then
            love.graphics.setColor(0, 0, 0, 0.15)
            love.graphics.rectangle("fill", x + 2, y + 2, w - 4, h - 4, 4, 4)
        end
    end

    if options.gemColor then
        Theme.drawGemIcon(x + 12, y + h / 2, 5, options.gemColor)
    end

    if text then
        love.graphics.setFont(font or love.graphics.get_font())
        local textOffsetX = options.gemColor and 15 or 0
        love.graphics.setColor(isDisabled and Theme.colors.textDim or Theme.colors.text)
        local tw = (font or love.graphics.get_font()):getWidth(text)
        love.graphics.print(text, x + textOffsetX + (w - textOffsetX - tw) / 2, y + (h - (font or love.graphics.get_font()):getHeight()) / 2)
    end
end

function Components.drawOrnateHPBar(x, y, w, h, percent, level, assetManager)
    percent = math.max(0, math.min(1, percent))

    local bgBar = assetManager and assetManager:get_ui_bar("hp_bar_bg")
    if bgBar then
        local scaleX = w / bgBar:getWidth()
        local scaleY = h / bgBar:getHeight()
        love.graphics.draw(bgBar, x, y, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.08, 0.08, 0.12)
        love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    end

    local fillW = w * percent
    if fillW > 0 then
        local fillName = percent > 0.6 and "hp_bar_high" or (percent > 0.3 and "hp_bar_medium" or "hp_bar_low")
        local fillBar = assetManager and assetManager:get_ui_bar(fillName)

        if fillBar then
            local scaleX = w / fillBar:getWidth()
            local scaleY = h / fillBar:getHeight()
            love.graphics.setScissor(x, y, fillW, h)
            love.graphics.draw(fillBar, x, y, 0, scaleX, scaleY)
            love.graphics.setScissor()
        else
            local fillColor = Theme.getHpColor(percent)
            local steps = 4
            local stepW = fillW / steps
            for i = 0, steps - 1 do
                local t = i / (steps - 1)
                local r = fillColor[1] * (1 - t * 0.2)
                local g = fillColor[2] * (1 - t * 0.1)
                local b = fillColor[3]
                love.graphics.setColor(r, g, b)
                love.graphics.rectangle("fill", x + i * stepW, y, stepW + 1, h, i == 0 and 3 or 0, i == steps - 1 and 3 or 0, i == steps - 1 and 3 or 0, i == 0 and 3 or 0)
            end
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.rectangle("fill", x, y, fillW, h / 3, 3, 3, 0, 0)
        end
    end

    if percent < 0.3 and percent > 0 then
        local pulse = 0.5 + 0.5 * math.sin(Theme.getAnimTime() * 6)
        love.graphics.setColor(1, 0.2, 0.2, pulse * 0.4)
        love.graphics.rectangle("fill", x, y, fillW, h, 3, 3)
    end

    Theme.drawGoldBorder(x, y, w, h, 1)

    local font = love.graphics.get_font()
    love.graphics.setFont(font)
    love.graphics.setColor(Theme.colors.text)
    local hpText = string.format("%d%%", math.floor(percent * 100))
    love.graphics.printf(hpText, x, y + (h - font:getHeight()) / 2, w, "center")
end

function Components.drawOrnateMPBar(x, y, w, h, percent, assetManager)
    percent = math.max(0, math.min(1, percent))

    local bgBar = assetManager and assetManager:get_ui_bar("mp_bar_bg")
    if bgBar then
        local scaleX = w / bgBar:getWidth()
        local scaleY = h / bgBar:getHeight()
        love.graphics.draw(bgBar, x, y, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.08, 0.08, 0.12)
        love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    end

    local fillW = w * percent
    if fillW > 0 then
        local fillBar = assetManager and assetManager:get_ui_bar("mp_bar_fill")
        if fillBar then
            local scaleX = w / fillBar:getWidth()
            local scaleY = h / fillBar:getHeight()
            love.graphics.setScissor(x, y, fillW, h)
            love.graphics.draw(fillBar, x, y, 0, scaleX, scaleY)
            love.graphics.setScissor()
        else
            Theme.drawGradient(x, y, fillW, h, {0.2, 0.4, 0.95}, {0.3, 0.55, 1.0}, 4)
            love.graphics.setColor(1, 1, 1, 0.12)
            love.graphics.rectangle("fill", x, y, fillW, h / 3, 3, 3, 0, 0)
        end
    end

    Theme.drawGoldBorder(x, y, w, h, 1)

    local font = love.graphics.get_font()
    love.graphics.setColor(Theme.colors.text)
    local mpText = string.format("%d%%", math.floor(percent * 100))
    love.graphics.printf(mpText, x, y + (h - font:getHeight()) / 2, w, "center")
end

function Components.drawXPBar(x, y, w, h, percent, assetManager)
    percent = math.max(0, math.min(1, percent))

    local bgBar = assetManager and assetManager:get_ui_bar("exp_bar_bg")
    if bgBar then
        local scaleX = w / bgBar:getWidth()
        local scaleY = h / bgBar:getHeight()
        love.graphics.draw(bgBar, x, y, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.08, 0.08, 0.12)
        love.graphics.rectangle("fill", x, y, w, h, 2, 2)
    end

    local fillW = w * percent
    if fillW > 0 then
        local fillBar = assetManager and assetManager:get_ui_bar("exp_bar_fill")
        if fillBar then
            local scaleX = w / fillBar:getWidth()
            local scaleY = h / fillBar:getHeight()
            love.graphics.setScissor(x, y, fillW, h)
            love.graphics.draw(fillBar, x, y, 0, scaleX, scaleY)
            love.graphics.setScissor()
        else
            Theme.drawGradient(x, y, fillW, h, {0.6, 0.3, 0.9}, {0.8, 0.5, 1.0}, 4)
        end
    end

    Theme.drawGoldBorder(x, y, w, h, 1)
end

function Components.drawGemButton(x, y, size, gemColor, isHovered, isPressed)
    local scale = isPressed and 0.9 or (isHovered and 1.1 or 1.0)
    local actualSize = size * scale
    local offset = (actualSize - size) / 2

    if isHovered then
        love.graphics.setColor(gemColor[1], gemColor[2], gemColor[3], 0.2)
        love.graphics.circle("fill", x + size / 2 - offset, y + size / 2 - offset, actualSize * 0.7)
    end

    Theme.drawGemIcon(x + size / 2 - offset, y + size / 2 - offset, actualSize * 0.35, gemColor)
end

function Components.drawScrollbar(x, y, width, height, contentHeight, scrollOffset)
    if contentHeight <= height then return end

    local maxScroll = contentHeight - height
    local thumbRatio = height / contentHeight
    local thumbHeight = math.max(20, height * thumbRatio)
    local thumbY = y + (scrollOffset / maxScroll) * (height - thumbHeight)

    love.graphics.setColor(0.15, 0.15, 0.2, 0.5)
    love.graphics.rectangle("fill", x, y, width, height, 3)

    love.graphics.setColor(Theme.colors.border[1], Theme.colors.border[2], Theme.colors.border[3], 0.6)
    love.graphics.rectangle("fill", x, thumbY, width, thumbHeight, 3)

    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.rectangle("fill", x, thumbY, width, thumbHeight / 2, 3, 3, 0, 0)
end

function Components.drawOrnateDialog(x, y, w, h, assetManager, speakerName)
    Components.drawOrnatePanel(x, y, w, h, assetManager, {
        corners = true,
        glow = true,
        shimmer = false,
        title = speakerName,
        borderColor = Theme.colors.border
    })

    if speakerName then
        Theme.drawDiamondSeparator(x + w / 2, y + 8, w * 0.6)
    end
end

function Components.drawRarityBorder(x, y, w, h, rarity)
    local rarityColors = {
        common = {0.6, 0.6, 0.6},
        uncommon = {0.2, 0.8, 0.2},
        rare = {0.2, 0.5, 1.0},
        epic = {0.7, 0.3, 1.0},
        legendary = {1.0, 0.7, 0.0}
    }
    local color = rarityColors[rarity] or rarityColors.common
    love.graphics.setColor(color)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 4)
    love.graphics.setLineWidth(1)
end

function Components.drawSprite(image, x, y, targetW, targetH)
    if not image then return false end
    local iw, ih = image:getWidth(), image:getHeight()
    if iw == 0 or ih == 0 then return false end
    local sx = targetW / iw
    local sy = targetH / ih
    love.graphics.draw(image, x, y, 0, sx, sy)
    return true
end

return Components
