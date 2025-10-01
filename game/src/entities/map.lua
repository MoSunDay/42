-- map.lua - 地图实体
-- 处理地图的生成和渲染

local Map = {}
Map.__index = Map

function Map.new(width, height)
    local self = setmetatable({}, Map)

    -- 地图尺寸
    self.width = width or 2000
    self.height = height or 2000

    -- 瓦片尺寸
    self.tileSize = 50

    -- 城镇地图颜色方案（石板路、建筑等）
    self.colors = {
        road1 = {0.55, 0.55, 0.60},      -- 浅灰色石板路
        road2 = {0.50, 0.50, 0.55},      -- 深灰色石板路
        grass1 = {0.35, 0.65, 0.35},     -- 草地
        grass2 = {0.30, 0.60, 0.30},     -- 草地变化
        gridLine = {0.40, 0.40, 0.45, 0.3},  -- 网格线
        border = {0.6, 0.5, 0.3}         -- 城镇边界（木栅栏色）
    }

    -- 生成城镇布局（简单的道路系统）
    self:generateTownLayout()

    return self
end

-- 生成城镇布局
function Map:generateTownLayout()
    self.layout = {}
    local tilesX = math.floor(self.width / self.tileSize)
    local tilesY = math.floor(self.height / self.tileSize)

    for y = 0, tilesY - 1 do
        self.layout[y] = {}
        for x = 0, tilesX - 1 do
            -- 创建主要道路（每隔5个瓦片一条道路）
            if x % 5 == 0 or y % 5 == 0 then
                self.layout[y][x] = "road"
            else
                self.layout[y][x] = "grass"
            end
        end
    end
end

-- 绘制地图
function Map:draw()
    local tilesX = math.floor(self.width / self.tileSize)
    local tilesY = math.floor(self.height / self.tileSize)

    -- 绘制城镇地面
    for y = 0, tilesY - 1 do
        for x = 0, tilesX - 1 do
            local px = x * self.tileSize
            local py = y * self.tileSize
            local tileType = self.layout[y] and self.layout[y][x] or "grass"

            if tileType == "road" then
                -- 绘制道路（石板路效果）
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(self.colors.road1)
                else
                    love.graphics.setColor(self.colors.road2)
                end
                love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)

                -- 添加石板纹理
                love.graphics.setColor(0.45, 0.45, 0.50, 0.3)
                love.graphics.rectangle("line", px + 2, py + 2, self.tileSize - 4, self.tileSize - 4)
            else
                -- 绘制草地
                local colorIndex = (x + y) % 2
                if colorIndex == 0 then
                    love.graphics.setColor(self.colors.grass1)
                else
                    love.graphics.setColor(self.colors.grass2)
                end
                love.graphics.rectangle("fill", px, py, self.tileSize, self.tileSize)

                -- 添加草地细节
                love.graphics.setColor(0.25, 0.55, 0.25, 0.2)
                for i = 1, 2 do
                    local dx = (x * 7 + y * 11 + i * 13) % (self.tileSize - 6) + 3
                    local dy = (x * 11 + y * 7 + i * 17) % (self.tileSize - 6) + 3
                    love.graphics.circle("fill", px + dx, py + dy, 1)
                end
            end
        end
    end

    -- 绘制网格线（淡化）
    love.graphics.setColor(self.colors.gridLine)
    for x = 0, tilesX do
        local px = x * self.tileSize
        love.graphics.line(px, 0, px, self.height)
    end
    for y = 0, tilesY do
        local py = y * self.tileSize
        love.graphics.line(0, py, self.width, py)
    end

    -- 绘制城镇边界（木栅栏效果）
    love.graphics.setColor(self.colors.border)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)

    -- 内边界装饰
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0.5, 0.4, 0.2, 0.5)
    love.graphics.rectangle("line", 5, 5, self.width - 10, self.height - 10)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

return Map

