local Theme = {}

Theme.colors = {
    background = {0.102, 0.102, 0.180},
    backgroundDark = {0.059, 0.059, 0.122},
    panel = {0.086, 0.129, 0.243},
    panelDark = {0.059, 0.204, 0.376},
    panelLight = {0.122, 0.165, 0.282},
    
    text = {0.910, 0.910, 0.910},
    textDim = {0.627, 0.627, 0.627},
    textBright = {0.953, 0.953, 0.953},
    
    accent = {0.914, 0.271, 0.376},
    accentAlt = {0.306, 0.804, 0.769},
    accentBlue = {0.271, 0.714, 0.820},
    
    button = {0.169, 0.298, 0.502},
    buttonHover = {0.220, 0.369, 0.612},
    buttonPressed = {0.129, 0.227, 0.392},
    buttonDisabled = {0.200, 0.200, 0.243},
    
    border = {0.271, 0.714, 0.820},
    borderBright = {0.400, 0.800, 0.900},
    borderDim = {0.169, 0.459, 0.549},
    
    success = {0.200, 0.800, 0.300},
    warning = {0.953, 0.749, 0.200},
    error = {0.902, 0.302, 0.302},
    info = {0.302, 0.702, 0.902},
    
    hp = {
        high = {0.200, 0.800, 0.300},
        medium = {0.902, 0.859, 0.200},
        low = {0.902, 0.302, 0.302}
    },
    
    mp = {0.302, 0.502, 0.902},
    
    tab = {
        active = {0.169, 0.298, 0.502},
        inactive = {0.122, 0.122, 0.157}
    },
    
    input = {
        background = {0.078, 0.078, 0.118},
        backgroundActive = {0.118, 0.157, 0.220},
        border = {0.271, 0.271, 0.353},
        borderActive = {0.271, 0.714, 0.820}
    },
    
    minimap = {
        background = {0.071, 0.071, 0.118},
        border = {0.271, 0.714, 0.820, 0.600},
        glow = {0.271, 0.714, 0.820, 0.300}
    },
    
    player = {
        marker = {0.914, 0.271, 0.376},
        markerGlow = {1.000, 1.000, 0.400}
    },
    
    battle = {
        background = {0.071, 0.071, 0.118},
        playerPanel = {0.086, 0.129, 0.243, 0.900},
        enemySelected = {1.000, 0.800, 0.200},
        turnPlayer = {0.200, 0.800, 1.000},
        turnEnemy = {1.000, 0.302, 0.302},
        victory = {0.200, 1.000, 0.302},
        defeat = {0.800, 0.200, 0.200}
    },
    
    equipment = {
        weapon = {1.000, 0.502, 0.302},
        hat = {0.800, 0.600, 0.400},
        clothes = {0.502, 0.702, 1.000},
        shoes = {0.600, 0.502, 0.702},
        necklace = {1.000, 0.800, 0.200}
    },
    
    chat = {
        panel = {0.071, 0.071, 0.118, 0.850},
        border = {0.271, 0.714, 0.820, 0.800},
        inputBg = {0.094, 0.094, 0.141, 0.900},
        inputActive = {0.118, 0.169, 0.243, 0.900},
        inputBorderActive = {0.400, 0.800, 1.000},
        inputBorderInactive = {0.300, 0.300, 0.400},
        text = {0.910, 0.910, 0.910},
        sender = {0.271, 0.702, 0.820},
        timestamp = {0.502, 0.502, 0.502},
        textHint = {0.500, 0.500, 0.500},
        scrollbarBg = {0.200, 0.200, 0.250, 0.500},
        scrollbarThumb = {0.400, 0.600, 1.000, 0.800}
    }
}

Theme.palette = {
    bg1 = "#1a1a2e",
    bg2 = "#16213e",
    bg3 = "#0f3460",
    fg1 = "#e8e8e8",
    fg2 = "#c8c8c8",
    fg3 = "#a0a0a0",
    accent1 = "#e94560",
    accent2 = "#ff6b6b",
    accent3 = "#4ecdc4",
    accent4 = "#45b7d1",
    nature1 = "#2d5a27",
    nature2 = "#4a7c59",
    nature3 = "#8b7355",
    nature4 = "#d4a574",
    magic1 = "#9b59b6",
    magic2 = "#3498db",
    magic3 = "#1abc9c",
    magic4 = "#f39c12"
}

function Theme.hexToRgb(hex)
    hex = hex:gsub("#", "")
    return {
        tonumber(hex:sub(1, 2), 16) / 255,
        tonumber(hex:sub(3, 4), 16) / 255,
        tonumber(hex:sub(5, 6), 16) / 255
    }
end

function Theme.rgba(r, g, b, a)
    return {r, g, b, a or 1}
end

function Theme.getHpColor(percent)
    if percent > 0.6 then
        return Theme.colors.hp.high
    elseif percent > 0.3 then
        return Theme.colors.hp.medium
    else
        return Theme.colors.hp.low
    end
end

function Theme.applyAlpha(color, alpha)
    return {color[1], color[2], color[3], alpha}
end

function Theme.setColor(color)
    love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
end

function Theme.getPanelColor()
    return Theme.colors.panel
end

function Theme.getButtonColor(isHovered, isPressed, isDisabled)
    if isDisabled then
        return Theme.colors.buttonDisabled
    elseif isPressed then
        return Theme.colors.buttonPressed
    elseif isHovered then
        return Theme.colors.buttonHover
    else
        return Theme.colors.button
    end
end

function Theme.getBorderColor(isActive)
    if isActive then
        return Theme.colors.borderBright
    else
        return Theme.colors.border
    end
end

return Theme
