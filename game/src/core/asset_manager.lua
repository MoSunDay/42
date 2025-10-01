-- asset_manager.lua - 资源管理器
-- 统一管理所有游戏资源（图片、音效等）

local AssetManager = {}
AssetManager.__index = AssetManager

function AssetManager.new()
    local self = setmetatable({}, AssetManager)
    
    self.images = {}
    self.fonts = {}
    self.sounds = {}
    
    -- 资源路径配置
    self.paths = {
        images = "assets/images/",
        fonts = "assets/fonts/",
        sounds = "assets/sounds/"
    }
    
    return self
end

-- 加载所有资源
function AssetManager:loadAll()
    print("Loading resources...")

    -- 加载字体
    self:loadFonts()

    -- 加载图片
    self:loadImages()

    -- 加载音效
    self:loadSounds()

    print("Resource loading complete!")
end

-- 加载字体
function AssetManager:loadFonts()
    -- 使用 Love2D 默认字体
    self.fonts.default = love.graphics.newFont(14)
    self.fonts.large = love.graphics.newFont(20)
    self.fonts.small = love.graphics.newFont(12)

    print("  - Fonts loaded")
end

-- 加载图片资源
function AssetManager:loadImages()
    -- 尝试加载剑客精灵（优先级：knight.png > player.png > 程序生成）
    local knightPath = self.paths.images .. "knight.png"
    local playerPath = self.paths.images .. "player.png"

    if love.filesystem.getInfo(knightPath) then
        self.images.player = love.graphics.newImage(knightPath)
        print("  - Loaded knight sprite: " .. knightPath)
    elseif love.filesystem.getInfo(playerPath) then
        self.images.player = love.graphics.newImage(playerPath)
        print("  - Loaded player sprite: " .. playerPath)
    else
        print("  - No sprite found, using generated graphics")
        self.images.player = self:createPlayerSprite()
    end

    -- 尝试加载城镇地图瓦片（优先级：town.png > tileset.png > 程序生成）
    local townPath = self.paths.images .. "town.png"
    local tilePath = self.paths.images .. "tileset.png"

    if love.filesystem.getInfo(townPath) then
        self.images.tileset = love.graphics.newImage(townPath)
        print("  - Loaded town tileset: " .. townPath)
    elseif love.filesystem.getInfo(tilePath) then
        self.images.tileset = love.graphics.newImage(tilePath)
        print("  - Loaded tileset: " .. tilePath)
    else
        print("  - No tileset found, using generated graphics")
    end

    print("  - Image loading complete")
end

-- 加载音效
function AssetManager:loadSounds()
    -- 音效加载（暂时为空）
    print("  - Sounds loaded (none yet)")
end

-- 程序生成玩家精灵
function AssetManager:createPlayerSprite()
    local size = 32
    local canvas = love.graphics.newCanvas(size, size)
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    
    -- 绘制玩家身体（蓝色圆形）
    love.graphics.setColor(0.2, 0.6, 1.0)
    love.graphics.circle("fill", size/2, size/2, 12)
    
    -- 绘制方向指示器（白色小圆）
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", size/2, size/2 - 6, 3)
    
    -- 绘制边框
    love.graphics.setColor(0.1, 0.4, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", size/2, size/2, 12)
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    
    return canvas
end

-- 获取图片
function AssetManager:getImage(name)
    return self.images[name]
end

-- 获取字体
function AssetManager:getFont(name)
    return self.fonts[name] or self.fonts.default
end

-- 获取音效
function AssetManager:getSound(name)
    return self.sounds[name]
end

return AssetManager

