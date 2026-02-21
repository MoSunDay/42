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

function Components.drawPanel(x, y, w, h, assetManager, style)
    style = style or "small_panel"
    local panel = assetManager and assetManager:getUIPanel(style)
    
    if panel and Components.draw9Slice(panel, x, y, w, h) then
        return true
    end
    
    love.graphics.setColor(Theme.colors.panel)
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)
    love.graphics.setColor(Theme.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 10, 10)
    love.graphics.setLineWidth(1)
    
    return false
end

function Components.drawPanelSimple(x, y, w, h, radius)
    radius = radius or 10
    love.graphics.setColor(Theme.colors.panel)
    love.graphics.rectangle("fill", x, y, w, h, radius, radius)
    love.graphics.setColor(Theme.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, radius, radius)
    love.graphics.setLineWidth(1)
end

function Components.drawButton(x, y, w, h, text, state, assetManager, font)
    state = state or "normal"
    local btnName = "button_" .. state
    local btn = assetManager and assetManager:getUIButton(btnName)
    
    if btn and Components.draw9Slice(btn, x, y, w, h, 8) then
        -- OK
    else
        local color = Theme.getButtonColor(
            state == "hover", 
            state == "pressed", 
            state == "disabled"
        )
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", x, y, w, h, 5, 5)
        love.graphics.setColor(Theme.colors.border)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, w, h, 5, 5)
        love.graphics.setLineWidth(1)
    end
    
    if text then
        love.graphics.setFont(font)
        love.graphics.setColor(Theme.colors.text)
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        love.graphics.print(text, x + (w - textWidth) / 2, y + (h - textHeight) / 2)
    end
end

function Components.drawButtonSimple(x, y, w, h, text, isHovered, isPressed, font)
    local color = Theme.getButtonColor(isHovered, isPressed, false)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, w, h, 5, 5)
    love.graphics.setColor(Theme.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 5, 5)
    love.graphics.setLineWidth(1)
    
    if text and font then
        love.graphics.setFont(font)
        love.graphics.setColor(Theme.colors.text)
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        love.graphics.print(text, x + (w - textWidth) / 2, y + (h - textHeight) / 2)
    end
end

function Components.drawSlot(x, y, size, state, assetManager)
    state = state or "normal"
    local slotName = "slot_" .. state
    local slot = assetManager and assetManager:getUISlot(slotName)
    
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

function Components.drawSlotSimple(x, y, size, isHovered, isSelected)
    local color
    if isSelected then
        color = Theme.colors.inventory.slotSelected
    elseif isHovered then
        color = Theme.colors.inventory.slotHover
    else
        color = Theme.colors.inventory.slot
    end
    
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, size, size, 5, 5)
    love.graphics.setColor(Theme.colors.inventory.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, size, size, 5, 5)
end

function Components.drawHPBar(x, y, w, h, percent, assetManager)
    percent = math.max(0, math.min(1, percent))
    
    local bgBar = assetManager and assetManager:getUIBar("hp_bar_bg")
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
    local fillBar = assetManager and assetManager:getUIBar(fillName)
    
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
    
    local bgBar = assetManager and assetManager:getUIBar("mp_bar_bg")
    if bgBar then
        local scaleX = w / bgBar:getWidth()
        local scaleY = h / bgBar:getHeight()
        love.graphics.draw(bgBar, x, y, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.12, 0.12, 0.12)
        love.graphics.rectangle("fill", x, y, w, h, 3, 3)
    end
    
    local fillBar = assetManager and assetManager:getUIBar("mp_bar_fill")
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

function Components.drawInput(x, y, w, h, isActive, assetManager)
    local inputName = isActive and "input_field_active" or "input_field"
    local input = assetManager and assetManager:getUIAsset("input", inputName)
    
    if input and Components.draw9Slice(input, x, y, w, h, 6) then
        return true
    end
    
    love.graphics.setColor(isActive and Theme.colors.input.backgroundActive or Theme.colors.input.background)
    love.graphics.rectangle("fill", x, y, w, h, 5, 5)
    love.graphics.setColor(isActive and Theme.colors.input.borderActive or Theme.colors.input.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 5, 5)
    love.graphics.setLineWidth(1)
    
    return false
end

function Components.drawTab(x, y, w, h, text, isActive, assetManager, font)
    local tabName = isActive and "tab_active" or "tab_inactive"
    local tab = assetManager and assetManager:getUIAsset("tabs", tabName)
    
    if tab then
        local scale = w / tab:getWidth()
        love.graphics.draw(tab, x, y, 0, scale, h / tab:getHeight())
    else
        love.graphics.setColor(isActive and Theme.colors.tab.active or Theme.colors.tab.inactive)
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
    local dialog = assetManager and assetManager:getDialogAsset("dialog_panel")
    
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
    local tooltip = assetManager and assetManager:getDialogAsset("tooltip_bg")
    
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

function Components.drawBorder(x, y, w, h, radius, isActive)
    radius = radius or 10
    love.graphics.setColor(isActive and Theme.colors.borderBright or Theme.colors.border)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, radius, radius)
    love.graphics.setLineWidth(1)
end

return Components
