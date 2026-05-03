local MapThemes = require("map.map_themes")

local MapObjectRenderer = {}

function MapObjectRenderer.draw_tree(x, y, size, theme)
    size = size or 1
    theme = theme or MapThemes.get_season_theme("spring")

    local trunkWidth = 8 * size
    local trunkHeight = 20 * size
    local canopyRadius = 18 * size

    love.graphics.setColor(0, 0, 0, 0.15)
    love.graphics.ellipse("fill", x, y + trunkHeight - 2, canopyRadius * 0.9, canopyRadius * 0.3)

    love.graphics.setColor(theme.treeTrunk)
    love.graphics.rectangle("fill", x - trunkWidth/2, y, trunkWidth, trunkHeight)

    love.graphics.setColor(theme.tree[1] * 1.1, theme.tree[2] * 1.1, theme.tree[3] * 1.1)
    love.graphics.circle("fill", x + canopyRadius * 0.25, y - canopyRadius * 0.5, canopyRadius * 0.7)

    love.graphics.setColor(theme.tree)
    love.graphics.circle("fill", x, y - canopyRadius * 0.3, canopyRadius)

    love.graphics.setColor(theme.tree[1] * 0.85, theme.tree[2] * 0.85, theme.tree[3] * 0.85)
    love.graphics.circle("fill", x - canopyRadius * 0.35, y - canopyRadius * 0.45, canopyRadius * 0.55)

    love.graphics.setColor(theme.tree[1] * 0.7, theme.tree[2] * 0.7, theme.tree[3] * 0.7)
    love.graphics.circle("fill", x + canopyRadius * 0.2, y + canopyRadius * 0.2, canopyRadius * 0.4)
end

function MapObjectRenderer.draw_rock(x, y, size, theme)
    size = size or 1
    theme = theme or MapThemes.get_season_theme("spring")

    love.graphics.setColor(theme.rock)
    love.graphics.polygon("fill",
        x - 12 * size, y + 8 * size,
        x - 8 * size, y - 6 * size,
        x + 4 * size, y - 8 * size,
        x + 12 * size, y + 4 * size,
        x + 6 * size, y + 10 * size
    )

    love.graphics.setColor(theme.rock[1] * 1.2, theme.rock[2] * 1.2, theme.rock[3] * 1.2)
    love.graphics.polygon("fill",
        x - 4 * size, y - 2 * size,
        x + 2 * size, y - 4 * size,
        x + 6 * size, y + 2 * size,
        x - 2 * size, y + 4 * size
    )
end

function MapObjectRenderer.draw_water(x, y, width, height, theme)
    theme = theme or MapThemes.get_season_theme("spring")
    local time = love.timer.getTime and love.timer.getTime() or 0

    love.graphics.setColor(theme.water)
    love.graphics.rectangle("fill", x, y, width, height)

    love.graphics.setColor(theme.water[1] * 0.85, theme.water[2] * 0.85, theme.water[3] * 0.9)
    for i = 0, width, 20 do
        for j = 0, height, 20 do
            local waveX = math.sin(time * 1.5 + i * 0.08 + j * 0.05) * 3
            local waveY = math.cos(time * 1.2 + j * 0.06) * 2
            love.graphics.circle("fill", x + i + 10 + waveX, y + j + 10 + waveY, 6)
        end
    end

    love.graphics.setColor(1, 1, 1, 0.15)
    for i = 1, math.floor(width / 30) do
        for j = 1, math.floor(height / 25) do
            local sparkleX = x + (i * 30 + math.sin(time * 3 + i) * 10) % width
            local sparkleY = y + (j * 25 + math.cos(time * 2.5 + j) * 8) % height
            local sparkleAlpha = 0.1 + 0.15 * math.sin(time * 5 + i * 2 + j * 3)
            love.graphics.setColor(1, 1, 1, sparkleAlpha)
            love.graphics.circle("fill", sparkleX, sparkleY, 2)
        end
    end

    love.graphics.setColor(theme.water[1] + 0.1, theme.water[2] + 0.1, theme.water[3] + 0.15, 0.4)
    for i = 0, width - 8, 12 do
        local waveOffset = math.sin(time * 2 + i * 0.15) * 3
        love.graphics.line(x + i, y + height * 0.3 + waveOffset, x + i + 8, y + height * 0.3 + waveOffset)
        love.graphics.line(x + i + 4, y + height * 0.6 + waveOffset, x + i + 12, y + height * 0.6 + waveOffset)
    end

    love.graphics.setColor(1, 1, 1, 0.08)
    love.graphics.rectangle("fill", x + 2, y + 2, width * 0.3, 3)
end

return MapObjectRenderer
