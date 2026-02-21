-- asset_manager.lua - 资源管理器
-- 统一管理所有游戏资源（图片、音效等）

local AssetManager = {}
AssetManager.__index = AssetManager

local CHARACTER_IDS = {
    "warrior", "mage", "archer", "rogue", "cleric", "knight", "wizard", "ranger",
    "blue_hero", "red_warrior", "green_ranger", "yellow_mage",
    "purple_assassin", "cyan_priest", "orange_knight", "pink_dancer",
    "hero"
}

local ENEMY_IDS = {
    "slime", "goblin", "skeleton", "bat",
    "orc_warrior", "skeleton_knight", "wolf", "dark_mage",
    "orc_chieftain", "vampire", "golem", "demon",
    "ancient_dragon", "lich_king", "chaos_serpent"
}

local NPC_IDS = {
    "villager", "merchant", "healer", "guard", "quest_giver", "elder",
    "village_chief", "spring_guardian", "summer_merchant",
    "autumn_innkeeper", "winter_priest"
}

local DIRECTIONS_4 = {"south", "west", "east", "north"}
local DIRECTIONS_8 = {
    "south", "south-west", "west", "north-west",
    "north", "north-east", "east", "south-east"
}

function AssetManager.new()
    local self = setmetatable({}, AssetManager)
    
    self.images = {}
    self.fonts = {}
    self.sounds = {}
    self.characterSprites = {}
    self.enemySprites = {}
    self.npcSprites = {}
    self.mapObjects = {}
    self.uiAssets = {
        panels = {},
        buttons = {},
        icons = {},
        bars = {},
        borders = {},
        tabs = {},
        slots = {},
        battleBg = {},
        dialog = {},
        loading = {},
        classes = {},
        effects = {}
    }
    
    self.paths = {
        images = "assets/images/",
        fonts = "assets/fonts/",
        sounds = "assets/sounds/",
        characters = "assets/images/characters/",
        enemies = "assets/images/characters/enemies/",
        npcs = "assets/images/characters/npcs/",
        tilesets = "assets/images/tilesets/",
        ui = "assets/images/ui/"
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

-- Load image resources
function AssetManager:loadImages()
    self:loadCharacterSprites()
    self:loadEnemySprites()
    self:NPCSprites()
    self:loadTilesets()
    self:loadMapObjects()
    self:loadUIAssets()
    self.images.player = self:createPlayerSprite()
    print("  - Image loading complete")
end

function AssetManager:loadCharacterSprites()
    local loadedCount = 0
    
    for _, charId in ipairs(CHARACTER_IDS) do
        local charPath = self.paths.characters .. charId
        if love.filesystem.getInfo(charPath) then
            self.characterSprites[charId] = {
                rotations = {},
                animations = {}
            }
            
            local rotationsPath = charPath .. "/rotations"
            if love.filesystem.getInfo(rotationsPath) then
                for _, dir in ipairs(DIRECTIONS_8) do
                    local spritePath = rotationsPath .. "/" .. dir .. ".png"
                    if love.filesystem.getInfo(spritePath) then
                        self.characterSprites[charId].rotations[dir] = love.graphics.newImage(spritePath)
                    end
                end
            else
                for _, dir in ipairs(DIRECTIONS_8) do
                    local spritePath = charPath .. "/" .. dir .. ".png"
                    if love.filesystem.getInfo(spritePath) then
                        self.characterSprites[charId].rotations[dir] = love.graphics.newImage(spritePath)
                    end
                end
            end
            
            local animPath = charPath .. "/animations"
            if love.filesystem.getInfo(animPath) then
                local animDirs = love.filesystem.getDirectoryItems(animPath)
                for _, animName in ipairs(animDirs) do
                    local animFullPath = animPath .. "/" .. animName
                    local animInfo = love.filesystem.getInfo(animFullPath)
                    if animInfo and animInfo.type == "directory" then
                        self.characterSprites[charId].animations[animName] = {}
                        local directionDirs = love.filesystem.getDirectoryItems(animFullPath)
                        for _, dirName in ipairs(directionDirs) do
                            local dirPath = animFullPath .. "/" .. dirName
                            local dirInfo = love.filesystem.getInfo(dirPath)
                            if dirInfo and dirInfo.type == "directory" then
                                self.characterSprites[charId].animations[animName][dirName] = {}
                                local frames = love.filesystem.getDirectoryItems(dirPath)
                                table.sort(frames)
                                for _, frameFile in ipairs(frames) do
                                    if frameFile:match("%.png$") then
                                        local framePath = dirPath .. "/" .. frameFile
                                        local frameImg = love.graphics.newImage(framePath)
                                        table.insert(self.characterSprites[charId].animations[animName][dirName], frameImg)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            local hasRotations = false
            for _ in pairs(self.characterSprites[charId].rotations) do
                hasRotations = true
                break
            end
            
            if hasRotations then
                loadedCount = loadedCount + 1
                local animCount = 0
                for _ in pairs(self.characterSprites[charId].animations) do
                    animCount = animCount + 1
                end
                print("  - Loaded character sprites: " .. charId .. " (" .. animCount .. " animations)")
            else
                self.characterSprites[charId] = nil
            end
        end
    end
    
    if loadedCount == 0 then
        print("  - No character sprites found, using generated sprites")
    end
end

function AssetManager:loadEnemySprites()
    local loadedCount = 0
    
    for _, enemyId in ipairs(ENEMY_IDS) do
        local enemyPath = self.paths.enemies .. enemyId
        if love.filesystem.getInfo(enemyPath) then
            self.enemySprites[enemyId] = {
                rotations = {},
                animations = {}
            }
            
            local rotationsPath = enemyPath .. "/rotations"
            if love.filesystem.getInfo(rotationsPath) then
                for _, dir in ipairs(DIRECTIONS_4) do
                    local spritePath = rotationsPath .. "/" .. dir .. ".png"
                    if love.filesystem.getInfo(spritePath) then
                        self.enemySprites[enemyId].rotations[dir] = love.graphics.newImage(spritePath)
                    end
                end
            end
            
            local animPath = enemyPath .. "/animations"
            if love.filesystem.getInfo(animPath) then
                local animDirs = love.filesystem.getDirectoryItems(animPath)
                for _, animName in ipairs(animDirs) do
                    local animFullPath = animPath .. "/" .. animName
                    if love.filesystem.getInfo(animFullPath) == "directory" then
                        self.enemySprites[enemyId].animations[animName] = {}
                        local directionDirs = love.filesystem.getDirectoryItems(animFullPath)
                        for _, dirName in ipairs(directionDirs) do
                            local dirPath = animFullPath .. "/" .. dirName
                            if love.filesystem.getInfo(dirPath) == "directory" then
                                self.enemySprites[enemyId].animations[animName][dirName] = {}
                                local frames = love.filesystem.getDirectoryItems(dirPath)
                                table.sort(frames)
                                for _, frameFile in ipairs(frames) do
                                    if frameFile:match("%.png$") then
                                        local framePath = dirPath .. "/" .. frameFile
                                        local frameImg = love.graphics.newImage(framePath)
                                        table.insert(self.enemySprites[enemyId].animations[animName][dirName], frameImg)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            local hasRotations = false
            for _ in pairs(self.enemySprites[enemyId].rotations) do
                hasRotations = true
                break
            end
            
            if hasRotations then
                loadedCount = loadedCount + 1
                local animCount = 0
                for _ in pairs(self.enemySprites[enemyId].animations) do
                    animCount = animCount + 1
                end
                print("  - Loaded enemy sprites: " .. enemyId .. " (" .. animCount .. " animations)")
            else
                self.enemySprites[enemyId] = nil
            end
        end
    end
    
    if loadedCount == 0 then
        print("  - No enemy sprites found, using fallback colors")
    end
end

function AssetManager:NPCSprites()
    local loadedCount = 0
    
    for _, npcId in ipairs(NPC_IDS) do
        local npcPath = self.paths.npcs .. npcId
        if love.filesystem.getInfo(npcPath) then
            self.npcSprites[npcId] = {
                rotations = {},
                animations = {}
            }
            
            local rotationsPath = npcPath .. "/rotations"
            if love.filesystem.getInfo(rotationsPath) then
                for _, dir in ipairs(DIRECTIONS_4) do
                    local spritePath = rotationsPath .. "/" .. dir .. ".png"
                    if love.filesystem.getInfo(spritePath) then
                        self.npcSprites[npcId].rotations[dir] = love.graphics.newImage(spritePath)
                    end
                end
            end
            
            local animPath = npcPath .. "/animations"
            if love.filesystem.getInfo(animPath) then
                local animDirs = love.filesystem.getDirectoryItems(animPath)
                for _, animName in ipairs(animDirs) do
                    local animFullPath = animPath .. "/" .. animName
                    if love.filesystem.getInfo(animFullPath) == "directory" then
                        self.npcSprites[npcId].animations[animName] = {}
                        local directionDirs = love.filesystem.getDirectoryItems(animFullPath)
                        for _, dirName in ipairs(directionDirs) do
                            local dirPath = animFullPath .. "/" .. dirName
                            if love.filesystem.getInfo(dirPath) == "directory" then
                                self.npcSprites[npcId].animations[animName][dirName] = {}
                                local frames = love.filesystem.getDirectoryItems(dirPath)
                                table.sort(frames)
                                for _, frameFile in ipairs(frames) do
                                    if frameFile:match("%.png$") then
                                        local framePath = dirPath .. "/" .. frameFile
                                        local frameImg = love.graphics.newImage(framePath)
                                        table.insert(self.npcSprites[npcId].animations[animName][dirName], frameImg)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            local hasRotations = false
            for _ in pairs(self.npcSprites[npcId].rotations) do
                hasRotations = true
                break
            end
            
            if hasRotations then
                loadedCount = loadedCount + 1
                print("  - Loaded NPC sprites: " .. npcId)
            else
                self.npcSprites[npcId] = nil
            end
        end
    end
    
    if loadedCount == 0 then
        print("  - No NPC sprites found, using fallback colors")
    end
end

function AssetManager:loadMapObjects()
    local objectCategories = {"trees", "buildings", "props"}
    local loadedCount = 0
    
    for _, category in ipairs(objectCategories) do
        local categoryPath = self.paths.tilesets .. "objects/" .. category
        if love.filesystem.getInfo(categoryPath) then
            local files = love.filesystem.getDirectoryItems(categoryPath)
            for _, filename in ipairs(files) do
                if filename:match("%.png$") then
                    local objectName = filename:gsub("%.png$", "")
                    local objectPath = categoryPath .. "/" .. filename
                    self.mapObjects[objectName] = love.graphics.newImage(objectPath)
                    loadedCount = loadedCount + 1
                    print("  - Loaded map object: " .. objectName)
                end
            end
        end
    end
    
    if loadedCount == 0 then
        print("  - No map objects found")
    end
end

function AssetManager:loadTilesets()
    local tilesetFiles = {"grass_road.png", "grass_forest.png", "sand_ocean.png", "snow_ice.png"}
    
    for _, filename in ipairs(tilesetFiles) do
        local path = self.paths.tilesets .. filename
        if love.filesystem.getInfo(path) then
            local name = filename:gsub("%.png$", "")
            self.images["tileset_" .. name] = love.graphics.newImage(path)
            print("  - Loaded tileset: " .. name)
        end
    end
    
    local townPath = self.paths.images .. "town.png"
    local tilePath = self.paths.images .. "tileset.png"

    if love.filesystem.getInfo(townPath) then
        self.images.tileset = love.graphics.newImage(townPath)
        print("  - Loaded town tileset: " .. townPath)
    elseif love.filesystem.getInfo(tilePath) then
        self.images.tileset = love.graphics.newImage(tilePath)
        print("  - Loaded tileset: " .. tilePath)
    end
end

function AssetManager:loadUIAssets()
    print("  - Loading UI assets...")
    
    local uiCategories = {
        {name = "panels", path = "panels/"},
        {name = "buttons", path = "buttons/"},
        {name = "icons", path = "icons/"},
        {name = "bars", path = "bars/"},
        {name = "borders", path = "borders/"},
        {name = "tabs", path = "tabs/"},
        {name = "slots", path = "slots/"},
        {name = "battleBg", path = "battle_bg/"},
        {name = "dialog", path = "dialog/"},
        {name = "loading", path = "loading/"},
        {name = "classes", path = "classes/"},
        {name = "effects", path = "effects/"}
    }
    
    for _, category in ipairs(uiCategories) do
        local categoryPath = self.paths.ui .. category.path
        if love.filesystem.getInfo(categoryPath) then
            local files = love.filesystem.getDirectoryItems(categoryPath)
            for _, filename in ipairs(files) do
                if filename:match("%.png$") then
                    local assetName = filename:gsub("%.png$", "")
                    local assetPath = categoryPath .. filename
                    self.uiAssets[category.name][assetName] = love.graphics.newImage(assetPath)
                end
            end
        end
    end
    
    local count = 0
    for catName, cat in pairs(self.uiAssets) do
        for _ in pairs(cat) do count = count + 1 end
    end
    print("  - Loaded " .. count .. " UI assets")
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

-- 获取角色精灵
function AssetManager:getCharacterSprite(charId, direction)
    if self.characterSprites[charId] and self.characterSprites[charId].rotations then
        return self.characterSprites[charId].rotations[direction]
    end
    return nil
end

-- 获取角色动画帧
function AssetManager:getCharacterAnimation(charId, animName, direction, frameIndex)
    if self.characterSprites[charId] and 
       self.characterSprites[charId].animations and 
       self.characterSprites[charId].animations[animName] and
       self.characterSprites[charId].animations[animName][direction] then
        local frames = self.characterSprites[charId].animations[animName][direction]
        if frameIndex and frames[frameIndex] then
            return frames[frameIndex]
        end
        return frames
    end
    return nil
end

-- 检查角色是否有精灵
function AssetManager:hasCharacterSprite(charId)
    return self.characterSprites[charId] ~= nil and 
           self.characterSprites[charId].rotations ~= nil
end

-- 检查角色是否有动画
function AssetManager:hasCharacterAnimation(charId, animName)
    return self.characterSprites[charId] ~= nil and
           self.characterSprites[charId].animations ~= nil and
           self.characterSprites[charId].animations[animName] ~= nil
end

-- 获取动画帧数
function AssetManager:getAnimationFrameCount(charId, animName, direction)
    if self:hasCharacterAnimation(charId, animName) then
        local anim = self.characterSprites[charId].animations[animName]
        if anim[direction] then
            return #anim[direction]
        end
    end
    return 0
end

-- 获取所有可用方向
function AssetManager:getAvailableDirections(charId)
    local dirs = {}
    if self.characterSprites[charId] then
        for dir, _ in pairs(self.characterSprites[charId]) do
            table.insert(dirs, dir)
        end
    end
    return dirs
end

-- 获取字体
function AssetManager:getFont(name)
    return self.fonts[name] or self.fonts.default
end

-- 获取音效
function AssetManager:getSound(name)
    return self.sounds[name]
end

-- 获取敌人精灵
function AssetManager:getEnemySprite(enemyId, direction)
    direction = direction or "south"
    if self.enemySprites[enemyId] and self.enemySprites[enemyId].rotations then
        return self.enemySprites[enemyId].rotations[direction]
    end
    return nil
end

-- 获取敌人动画帧
function AssetManager:getEnemyAnimation(enemyId, animName, direction, frameIndex)
    direction = direction or "south"
    if self.enemySprites[enemyId] and 
       self.enemySprites[enemyId].animations and 
       self.enemySprites[enemyId].animations[animName] and
       self.enemySprites[enemyId].animations[animName][direction] then
        local frames = self.enemySprites[enemyId].animations[animName][direction]
        if frameIndex and frames[frameIndex] then
            return frames[frameIndex]
        end
        return frames
    end
    return nil
end

-- 检查敌人是否有精灵
function AssetManager:hasEnemySprite(enemyId)
    return self.enemySprites[enemyId] ~= nil and 
           next(self.enemySprites[enemyId].rotations) ~= nil
end

-- 检查敌人是否有动画
function AssetManager:hasEnemyAnimation(enemyId, animName)
    return self.enemySprites[enemyId] ~= nil and
           self.enemySprites[enemyId].animations ~= nil and
           self.enemySprites[enemyId].animations[animName] ~= nil
end

-- 获取敌人动画帧数
function AssetManager:getEnemyAnimationFrameCount(enemyId, animName, direction)
    direction = direction or "south"
    if self:hasEnemyAnimation(enemyId, animName) then
        local anim = self.enemySprites[enemyId].animations[animName]
        if anim[direction] then
            return #anim[direction]
        end
    end
    return 0
end

-- 获取NPC精灵
function AssetManager:getNPCSprite(npcId, direction)
    direction = direction or "south"
    if self.npcSprites[npcId] and self.npcSprites[npcId].rotations then
        return self.npcSprites[npcId].rotations[direction]
    end
    return nil
end

-- 检查NPC是否有精灵
function AssetManager:hasNPCSprite(npcId)
    return self.npcSprites[npcId] ~= nil and 
           next(self.npcSprites[npcId].rotations) ~= nil
end

-- 获取地图物件
function AssetManager:getMapObject(objectName)
    return self.mapObjects[objectName]
end

function AssetManager:hasMapObject(objectName)
    return self.mapObjects[objectName] ~= nil
end

function AssetManager:getUIAsset(category, name)
    if self.uiAssets[category] then
        return self.uiAssets[category][name]
    end
    return nil
end

function AssetManager:getUIPanel(name)
    return self:getUIAsset("panels", name)
end

function AssetManager:getUIButton(name)
    return self:getUIAsset("buttons", name)
end

function AssetManager:getUIIcon(name)
    return self:getUIAsset("icons", name)
end

function AssetManager:getUIBar(name)
    return self:getUIAsset("bars", name)
end

function AssetManager:getUISlot(name)
    return self:getUIAsset("slots", name)
end

function AssetManager:getBattleBackground(name)
    return self:getUIAsset("battleBg", name)
end

function AssetManager:getDialogAsset(name)
    return self:getUIAsset("dialog", name)
end

function AssetManager:getLoadingAsset(name)
    return self:getUIAsset("loading", name)
end

function AssetManager:getClassIcon(name)
    return self:getUIAsset("classes", name)
end

function AssetManager:getEffect(name)
    return self:getUIAsset("effects", name)
end

return AssetManager

