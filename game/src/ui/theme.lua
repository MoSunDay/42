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
        defeat = {0.800, 0.200, 0.200},
        escaped = {0.900, 0.900, 0.200}
    },

    stat = {
        speed = {0.800, 1.000, 0.300},
        hp = {0.300, 1.000, 0.300},
        crit = {1.000, 0.800, 0.200},
        evasion = {0.500, 0.800, 1.000},
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
    },
    
    inventory = {
        background = {0.102, 0.102, 0.180},
        slot = {0.150, 0.150, 0.200},
        slotHover = {0.220, 0.350, 0.450},
        slotSelected = {0.271, 0.500, 0.714},
        border = {0.271, 0.400, 0.549},
        equipment = {0.200, 0.600, 0.400},
        consumable = {0.800, 0.500, 0.300}
    },
    
    map = {
        overlay = {0, 0, 0, 0.700},
        panel = {0.102, 0.102, 0.180, 0.950},
        border = {0.271, 0.714, 0.820, 0.900},
        text = {0.910, 0.910, 0.910},
        road = {0.550, 0.550, 0.600},
        grass = {0.350, 0.650, 0.350},
        playerMarker = {0.914, 0.271, 0.376},
        playerView = {1.000, 1.000, 0, 0.300},
        navigationTarget = {0.200, 1.000, 0.200, 0.800},
        navigationLine = {0.200, 1.000, 0.200, 0.500}
    },
    
    tooltip = {
        background = {0.086, 0.129, 0.243, 0.950},
        border = {0.271, 0.714, 0.820, 0.900},
        text = {0.910, 0.910, 0.910},
        textDim = {0.627, 0.627, 0.627},
        title = {0.914, 0.271, 0.376},
        stat = {0.306, 0.804, 0.769}
    },
    
    battleBg = {
        forest = {
            gradient1 = {0.071, 0.118, 0.071},
            gradient2 = {0.118, 0.180, 0.102},
            ground = {0.200, 0.250, 0.150, 0.400}
        },
        desert = {
            gradient1 = {0.180, 0.141, 0.086},
            gradient2 = {0.259, 0.200, 0.129},
            ground = {0.310, 0.251, 0.180, 0.400}
        },
        dungeon = {
            gradient1 = {0.059, 0.059, 0.078},
            gradient2 = {0.102, 0.102, 0.141},
            ground = {0.078, 0.078, 0.098, 0.500}
        },
        boss = {
            gradient1 = {0.078, 0.039, 0.059},
            gradient2 = {0.180, 0.078, 0.118},
            ground = {0.118, 0.059, 0.078, 0.500}
        },
        sky = {
            gradient1 = {0.118, 0.141, 0.259},
            gradient2 = {0.180, 0.200, 0.310},
            ground = {0.502, 0.549, 0.600, 0.300}
        },
        volcanic = {
            gradient1 = {0.180, 0.059, 0.020},
            gradient2 = {0.259, 0.102, 0.039},
            ground = {0.200, 0.078, 0.039, 0.500}
        }
    },
    
    dialog = {
        background = {0.086, 0.129, 0.243, 0.950},
        border = {0.271, 0.714, 0.820, 0.900},
        text = {0.910, 0.910, 0.910},
        speaker = {0.914, 0.271, 0.376},
        prompt = {0.627, 0.627, 0.627}
    },
    
    loading = {
        background = {0.102, 0.102, 0.180, 0.950},
        barBg = {0.078, 0.078, 0.118},
        barFill = {0.271, 0.714, 0.820},
        barGlow = {0.271, 0.714, 0.820, 0.500},
        text = {0.910, 0.910, 0.910},
        textDim = {0.627, 0.627, 0.627}
    },
    
    equipmentUI = {
        background = {0.102, 0.102, 0.180, 0.950},
        panel = {0.086, 0.129, 0.243, 0.900},
        text = {0.910, 0.910, 0.910},
        selected = {0.271, 0.500, 0.714, 0.500},
        empty = {0.200, 0.200, 0.220},
        border = {0.271, 0.714, 0.820}
    },
    
    party = {
        panel = {0.071, 0.071, 0.118, 0.900},
        border = {0.271, 0.714, 0.820, 0.800},
        leaderBorder = {1.000, 0.800, 0.200, 0.900},
        text = {0.910, 0.910, 0.910},
        hpBar = {0.200, 0.800, 0.300},
        hpBarBg = {0.200, 0.200, 0.200},
        offline = {0.500, 0.500, 0.500}
    },
    
    pet = {
        panel = {0.086, 0.129, 0.243, 0.900},
        text = {0.910, 0.910, 0.910},
        hpBar = {0.306, 0.902, 0.502},
        hpBarBg = {0.086, 0.086, 0.102}
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

function Theme.hex_to_rgb(hex)
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

function Theme.get_hp_color(percent)
    if percent > 0.6 then
        return Theme.colors.hp.high
    elseif percent > 0.3 then
        return Theme.colors.hp.medium
    else
        return Theme.colors.hp.low
    end
end

function Theme.apply_alpha(color, alpha)
    return {color[1], color[2], color[3], alpha}
end

function Theme.set_color(color)
    love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
end

function Theme.get_panel_color()
    return Theme.colors.panel
end

function Theme.get_button_color(isHovered, isPressed, isDisabled)
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

function Theme.get_border_color(is_active)
    if is_active then
        return Theme.colors.borderBright
    else
        return Theme.colors.border
    end
end

Theme.gold = {
    bright = {0.95, 0.85, 0.4},
    normal = {0.85, 0.72, 0.3},
    dark = {0.65, 0.52, 0.2},
    glow = {0.95, 0.85, 0.4, 0.3},
    shimmer = {1.0, 0.95, 0.7}
}

Theme.parchment = {
    light = {0.93, 0.88, 0.78},
    mid = {0.88, 0.82, 0.70},
    dark = {0.78, 0.70, 0.58},
    border = {0.60, 0.50, 0.35},
    text = {0.25, 0.20, 0.15}
}

Theme.gem = {
    ruby = {0.85, 0.15, 0.20},
    sapphire = {0.20, 0.40, 0.90},
    emerald = {0.15, 0.70, 0.30},
    topaz = {0.90, 0.75, 0.15},
    amethyst = {0.60, 0.25, 0.80},
    diamond = {0.85, 0.92, 1.0}
}

Theme._animTime = 0

function Theme.update(dt)
    Theme._animTime = Theme._animTime + dt
end

function Theme.get_anim_time()
    return Theme._animTime
end

function Theme.draw_gold_border(x, y, w, h, thickness)
    thickness = thickness or 2
    local g = Theme.gold
    love.graphics.setLineWidth(thickness)
    love.graphics.setColor(g.normal)
    love.graphics.rectangle("line", x, y, w, h, 6)

    love.graphics.setColor(g.bright)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 1, y + 1, w - 2, h - 2, 5)

    love.graphics.setLineWidth(1)
end

function Theme.draw_corner_ornaments(x, y, w, h, size)
    size = size or 10
    local g = Theme.gold
    love.graphics.setColor(g.bright)
    love.graphics.setLineWidth(2)

    love.graphics.line(x, y + size, x, y, x + size, y)
    love.graphics.line(x + w - size, y, x + w, y, x + w, y + size)
    love.graphics.line(x, y + h - size, x, y + h, x + size, y + h)
    love.graphics.line(x + w - size, y + h, x + w, y + h, x + w, y + h - size)

    love.graphics.setColor(g.normal)
    love.graphics.setLineWidth(1)
    love.graphics.circle("fill", x, y, 2)
    love.graphics.circle("fill", x + w, y, 2)
    love.graphics.circle("fill", x, y + h, 2)
    love.graphics.circle("fill", x + w, y + h, 2)
end

function Theme.draw_glow(x, y, w, h, color, intensity)
    color = color or Theme.colors.border
    intensity = intensity or 0.3
    local pulse = 0.8 + 0.2 * math.sin(Theme._animTime * 2)
    local alpha = intensity * pulse

    love.graphics.setColor(color[1], color[2], color[3], alpha * 0.5)
    love.graphics.rectangle("line", x - 2, y - 2, w + 4, h + 4, 8)

    love.graphics.setColor(color[1], color[2], color[3], alpha * 0.25)
    love.graphics.rectangle("line", x - 4, y - 4, w + 8, h + 8, 10)
end

function Theme.draw_gradient(x, y, w, h, colorTop, colorBottom, steps)
    steps = steps or 8
    local stepH = h / steps
    for i = 0, steps - 1 do
        local t = i / (steps - 1)
        local r = colorTop[1] + (colorBottom[1] - colorTop[1]) * t
        local g = colorTop[2] + (colorBottom[2] - colorTop[2]) * t
        local b = colorTop[3] + (colorBottom[3] - colorTop[3]) * t
        local a = (colorTop[4] or 1) + ((colorBottom[4] or 1) - (colorTop[4] or 1)) * t
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", x, y + i * stepH, w, stepH + 1)
    end
end

function Theme.draw_parchment_panel(x, y, w, h, borderThickness)
    borderThickness = borderThickness or 2
    local p = Theme.parchment

    Theme.draw_gradient(x, y, w, h, p.light, p.mid, 6)

    love.graphics.setColor(p.dark)
    love.graphics.setLineWidth(borderThickness)
    love.graphics.rectangle("line", x, y, w, h, 4)
    love.graphics.setLineWidth(1)

    Theme.draw_corner_ornaments(x + 2, y + 2, w - 4, h - 4, 8)
end

function Theme.draw_gem_icon(x, y, size, gemColor)
    if not gemColor or not gemColor[1] then return end
    love.graphics.setColor(gemColor[1] * 0.3, gemColor[2] * 0.3, gemColor[3] * 0.3, 0.5)
    love.graphics.circle("fill", x + 1, y + 1, size)

    love.graphics.setColor(gemColor)
    love.graphics.circle("fill", x, y, size)

    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.circle("fill", x - size * 0.25, y - size * 0.25, size * 0.35)

    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.setLineWidth(1)
    love.graphics.circle("line", x, y, size)
end

function Theme.draw_ornamental_line(x1, y1, x2, y2, color)
    color = color or Theme.gold.normal
    love.graphics.setColor(color)
    love.graphics.setLineWidth(2)
    love.graphics.line(x1, y1, x2, y2)

    love.graphics.setColor(color[1], color[2], color[3], 0.4)
    love.graphics.setLineWidth(1)
    love.graphics.line(x1, y1 + 1, x2, y2 + 1)

    love.graphics.setLineWidth(1)
end

function Theme.draw_shimmer(x, y, w, h, speed)
    speed = speed or 1
    local t = Theme._animTime * speed
    local shimmerX = x + ((math.sin(t) + 1) / 2) * w

    love.graphics.setColor(1, 1, 1, 0.05)
    love.graphics.rectangle("fill", shimmerX - 20, y, 40, h)
    love.graphics.setColor(1, 1, 1, 0.03)
    love.graphics.rectangle("fill", shimmerX - 40, y, 80, h)
end

function Theme.draw_diamond_separator(cx, y, width)
    width = width or 80
    local g = Theme.gold

    love.graphics.setColor(g.dark)
    love.graphics.setLineWidth(1)
    love.graphics.line(cx - width / 2, y, cx - 5, y)
    love.graphics.line(cx + 5, y, cx + width / 2, y)

    love.graphics.setColor(g.bright)
    love.graphics.push()
    love.graphics.translate(cx, y)
    love.graphics.rotate(math.pi / 4)
    love.graphics.rectangle("fill", -3, -3, 6, 6)
    love.graphics.pop()
end

return Theme
