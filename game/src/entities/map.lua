-- map.lua - 地图实体
-- 处理地图的生成和渲染

local Map = {}

function Map.create(width, height)
    local state = {}

    -- 地图尺寸
    state.width = width or 2000
    state.height = height or 2000

    -- 瓦片尺寸
    state.tileSize = 50

    -- 城镇地图颜色方案（石板路、建筑等）
    state.colors = {
        road1 = {0.55, 0.55, 0.60},      -- 浅灰色石板路
        road2 = {0.50, 0.50, 0.55},      -- 深灰色石板路
        grass1 = {0.35, 0.65, 0.35},     -- 草地
        grass2 = {0.30, 0.60, 0.30},     -- 草地变化
        gridLine = {0.40, 0.40, 0.45, 0.3},  -- 网格线
        border = {0.6, 0.5, 0.3}         -- 城镇边界（木栅栏色）
    }

    -- 生成城镇布局（简单的道路系统）
    Map.generate_town_layout(state)

    return state
end

-- 生成城镇布局
function Map.generate_town_layout(state)
    state.layout = {}
    local tilesX = math.floor(state.width / state.tileSize)
    local tilesY = math.floor(state.height / state.tileSize)

    for y = 0, tilesY - 1 do
        state.layout[y] = {}
        for x = 0, tilesX - 1 do
            -- 创建主要道路（每隔5个瓦片一条道路）
            if x % 5 == 0 or y % 5 == 0 then
                state.layout[y][x] = "road"
            else
                state.layout[y][x] = "grass"
            end
        end
    end
end

-- 绘制地图
function Map.draw(state)
    local tilesX = math.floor(state.width / state.tileSize)
    local tilesY = math.floor(state.height / state.tileSize)

    -- 绘制城镇地面
    for y = 0, tilesY - 1 do
        for x = 0, tilesX - 1 do
            local px = x * state.tileSize
            local py = y * state.tileSize
            local tileType = state.layout[y] and state.layout[y][x] or "grass"

            if tileType == "road" then
                -- 绘制道路（石板路效果）
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(state.colors.road1)
                else
                    love.graphics.setColor(state.colors.road2)
                end
                love.graphics.rectangle("fill", px, py, state.tileSize, state.tileSize)

                -- 添加石板纹理
                love.graphics.setColor(0.45, 0.45, 0.50, 0.3)
                love.graphics.rectangle("line", px + 2, py + 2, state.tileSize - 4, state.tileSize - 4)
            else
                -- 绘制草地
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(state.colors.grass1)
                else
                    love.graphics.setColor(state.colors.grass2)
                end
                love.graphics.rectangle("fill", px, py, state.tileSize, state.tileSize)

                -- 添加草地细节
                love.graphics.setColor(0.25, 0.55, 0.25, 0.2)
                for i = 1, 2 do
                    local dx = (x * 7 + y * 11 + i * 13) % (state.tileSize - 6) + 3
                    local dy = (x * 11 + y * 7 + i * 17) % (state.tileSize - 6) + 3
                    love.graphics.circle("fill", px + dx, py + dy, 1)
                end
            end
        end
    end

    -- 绘制网格线（淡化）
    love.graphics.setColor(state.colors.gridLine)
    for x = 0, tilesX do
        local px = x * state.tileSize
        love.graphics.line(px, 0, px, state.height)
    end
    for y = 0, tilesY do
        local py = y * state.tileSize
        love.graphics.line(0, py, state.width, py)
    end

    -- 绘制城镇边界（木栅栏效果）
    love.graphics.setColor(state.colors.border)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", 0, 0, state.width, state.height)

    -- 内边界装饰
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0.5, 0.4, 0.2, 0.5)
    love.graphics.rectangle("line", 5, 5, state.width - 10, state.height - 10)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

return Map
