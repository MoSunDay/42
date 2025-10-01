-- generate_placeholder_assets.lua
-- 生成占位符素材的工具脚本

-- 这个脚本需要在 Love2D 环境中运行
-- 运行方式: love game/tools/generate_placeholder_assets.lua

function love.load()
    print("开始生成占位符素材...")
    
    -- 生成玩家精灵
    generatePlayerSprite()
    
    -- 生成地图瓦片
    generateTileset()
    
    print("素材生成完成！")
    love.event.quit()
end

function generatePlayerSprite()
    local size = 32
    local canvas = love.graphics.newCanvas(size, size)
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- 绘制玩家（蓝色圆形）
    love.graphics.setColor(0.2, 0.6, 1.0)
    love.graphics.circle("fill", size/2, size/2, 12)
    
    -- 方向指示器
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", size/2, size/2 - 6, 3)
    
    -- 边框
    love.graphics.setColor(0.1, 0.4, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", size/2, size/2, 12)
    
    love.graphics.setCanvas()
    
    -- 保存图片
    local imageData = canvas:newImageData()
    imageData:encode("png", "../assets/images/player.png")
    
    print("  - 生成 player.png")
end

function generateTileset()
    local tileSize = 32
    local tilesX = 4
    local tilesY = 4
    local canvas = love.graphics.newCanvas(tileSize * tilesX, tileSize * tilesY)
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- 生成不同的瓦片
    for y = 0, tilesY - 1 do
        for x = 0, tilesX - 1 do
            local px = x * tileSize
            local py = y * tileSize
            
            -- 草地瓦片
            if (x + y) % 2 == 0 then
                love.graphics.setColor(0.25, 0.55, 0.25)
            else
                love.graphics.setColor(0.22, 0.50, 0.22)
            end
            love.graphics.rectangle("fill", px, py, tileSize, tileSize)
            
            -- 添加细节
            love.graphics.setColor(0.2, 0.45, 0.2, 0.3)
            for i = 1, 3 do
                local dx = math.random(0, tileSize - 4)
                local dy = math.random(0, tileSize - 4)
                love.graphics.rectangle("fill", px + dx, py + dy, 2, 2)
            end
        end
    end
    
    love.graphics.setCanvas()
    
    -- 保存图片
    local imageData = canvas:newImageData()
    imageData:encode("png", "../assets/images/tileset.png")
    
    print("  - 生成 tileset.png")
end

function love.draw()
    -- 不需要绘制
end

