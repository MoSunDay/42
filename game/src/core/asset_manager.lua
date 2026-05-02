local AssetManager = {}

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

function AssetManager.create()
    local state = {}

    state.images = {}
    state.fonts = {}
    state.sounds = {}
    state.characterSprites = {}
    state.enemySprites = {}
    state.npcSprites = {}
    state.mapObjects = {}
    state.uiAssets = {
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

    state.paths = {
        images = "assets/images/",
        fonts = "assets/fonts/",
        sounds = "assets/sounds/",
        characters = "assets/images/characters/",
        enemies = "assets/images/characters/enemies/",
        npcs = "assets/images/characters/npcs/",
        tilesets = "assets/images/tilesets/",
        ui = "assets/images/ui/"
    }

    return state
end

function AssetManager.loadAll(state)
    print("Loading resources...")

    AssetManager.loadFonts(state)

    AssetManager.loadImages(state)

    AssetManager.loadSounds(state)

    print("Resource loading complete!")
end

function AssetManager.loadFonts(state)
    state.fonts.default = love.graphics.newFont(14)
    state.fonts.large = love.graphics.newFont(20)
    state.fonts.small = love.graphics.newFont(12)

    print("  - Fonts loaded")
end

function AssetManager.loadImages(state)
    AssetManager.loadCharacterSprites(state)
    AssetManager.loadEnemySprites(state)
    AssetManager.loadNPCSprites(state)
    AssetManager.loadTilesets(state)
    AssetManager.loadMapObjects(state)
    AssetManager.loadUIAssets(state)
    state.images.player = AssetManager.createPlayerSprite()
    print("  - Image loading complete")
end

local function loadSpritesForIds(state, ids, basePath, directions, targetTable, label)
    local loadedCount = 0
    for _, spriteId in ipairs(ids) do
        local spritePath = basePath .. spriteId
        if love.filesystem.getInfo(spritePath) then
            targetTable[spriteId] = { rotations = {}, animations = {} }
            local rotationsPath = spritePath .. "/rotations"
            if love.filesystem.getInfo(rotationsPath) then
                for _, dir in ipairs(directions) do
                    local imgPath = rotationsPath .. "/" .. dir .. ".png"
                    if love.filesystem.getInfo(imgPath) then
                        targetTable[spriteId].rotations[dir] = love.graphics.newImage(imgPath)
                    end
                end
            elseif spritePath == basePath .. spriteId then
                for _, dir in ipairs(directions) do
                    local imgPath = spritePath .. "/" .. dir .. ".png"
                    if love.filesystem.getInfo(imgPath) then
                        targetTable[spriteId].rotations[dir] = love.graphics.newImage(imgPath)
                    end
                end
            end
            local animPath = spritePath .. "/animations"
            if love.filesystem.getInfo(animPath) then
                local animDirs = love.filesystem.getDirectoryItems(animPath)
                for _, animName in ipairs(animDirs) do
                    local animFullPath = animPath .. "/" .. animName
                    local animInfo = love.filesystem.getInfo(animFullPath)
                    if animInfo and animInfo.type == "directory" then
                        targetTable[spriteId].animations[animName] = {}
                        local directionDirs = love.filesystem.getDirectoryItems(animFullPath)
                        for _, dirName in ipairs(directionDirs) do
                            local dirPath = animFullPath .. "/" .. dirName
                            local dirInfo = love.filesystem.getInfo(dirPath)
                            if dirInfo and dirInfo.type == "directory" then
                                targetTable[spriteId].animations[animName][dirName] = {}
                                local frames = love.filesystem.getDirectoryItems(dirPath)
                                table.sort(frames)
                                for _, frameFile in ipairs(frames) do
                                    if frameFile:match("%.png$") then
                                        local frameImg = love.graphics.newImage(dirPath .. "/" .. frameFile)
                                        table.insert(targetTable[spriteId].animations[animName][dirName], frameImg)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            local hasRotations = false
            for _ in pairs(targetTable[spriteId].rotations) do
                hasRotations = true
                break
            end
            if hasRotations then
                loadedCount = loadedCount + 1
                local animCount = 0
                for _ in pairs(targetTable[spriteId].animations) do
                    animCount = animCount + 1
                end
                print("  - Loaded " .. label .. " sprites: " .. spriteId .. " (" .. animCount .. " animations)")
            else
                targetTable[spriteId] = nil
            end
        end
    end
    if loadedCount == 0 then
        print("  - No " .. label .. " sprites found, using fallback")
    end
end

function AssetManager.loadCharacterSprites(state)
    loadSpritesForIds(state, CHARACTER_IDS, state.paths.characters, DIRECTIONS_8, state.characterSprites, "character")
end

function AssetManager.loadEnemySprites(state)
    loadSpritesForIds(state, ENEMY_IDS, state.paths.enemies, DIRECTIONS_4, state.enemySprites, "enemy")
end

function AssetManager.loadNPCSprites(state)
    loadSpritesForIds(state, NPC_IDS, state.paths.npcs, DIRECTIONS_4, state.npcSprites, "NPC")
end

function AssetManager.loadMapObjects(state)
    local objectCategories = {"trees", "buildings", "props"}
    local loadedCount = 0

    for _, category in ipairs(objectCategories) do
        local categoryPath = state.paths.tilesets .. "objects/" .. category
        if love.filesystem.getInfo(categoryPath) then
            local files = love.filesystem.getDirectoryItems(categoryPath)
            for _, filename in ipairs(files) do
                if filename:match("%.png$") then
                    local objectName = filename:gsub("%.png$", "")
                    local objectPath = categoryPath .. "/" .. filename
                    state.mapObjects[objectName] = love.graphics.newImage(objectPath)
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

function AssetManager.loadTilesets(state)
    local tilesetFiles = {"grass_road.png", "grass_forest.png", "sand_ocean.png", "snow_ice.png"}

    for _, filename in ipairs(tilesetFiles) do
        local path = state.paths.tilesets .. filename
        if love.filesystem.getInfo(path) then
            local name = filename:gsub("%.png$", "")
            state.images["tileset_" .. name] = love.graphics.newImage(path)
            print("  - Loaded tileset: " .. name)
        end
    end

    local townPath = state.paths.images .. "town.png"
    local tilePath = state.paths.images .. "tileset.png"

    if love.filesystem.getInfo(townPath) then
        state.images.tileset = love.graphics.newImage(townPath)
        print("  - Loaded town tileset: " .. townPath)
    elseif love.filesystem.getInfo(tilePath) then
        state.images.tileset = love.graphics.newImage(tilePath)
        print("  - Loaded tileset: " .. tilePath)
    end
end

function AssetManager.loadUIAssets(state)
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
        local categoryPath = state.paths.ui .. category.path
        if love.filesystem.getInfo(categoryPath) then
            local files = love.filesystem.getDirectoryItems(categoryPath)
            for _, filename in ipairs(files) do
                if filename:match("%.png$") then
                    local assetName = filename:gsub("%.png$", "")
                    local assetPath = categoryPath .. filename
                    state.uiAssets[category.name][assetName] = love.graphics.newImage(assetPath)
                end
            end
        end
    end

    local count = 0
    for catName, cat in pairs(state.uiAssets) do
        for _ in pairs(cat) do count = count + 1 end
    end
    print("  - Loaded " .. count .. " UI assets")
end

function AssetManager.loadSounds(state)
    local loadedCount = 0

    local soundCategories = {
        {name = "combat", path = state.paths.sounds .. "sfx/combat/"},
        {name = "ui", path = state.paths.sounds .. "sfx/ui/"},
        {name = "character", path = state.paths.sounds .. "sfx/character/"},
        {name = "bgm", path = state.paths.sounds .. "bgm/"},
        {name = "seasonal", path = state.paths.sounds .. "bgm/seasonal/"}
    }

    for _, category in ipairs(soundCategories) do
        if love.filesystem.getInfo(category.path) then
            local files = love.filesystem.getDirectoryItems(category.path)
            for _, filename in ipairs(files) do
                if filename:match("%.ogg$") or filename:match("%.wav$") or filename:match("%.mp3$") then
                    local soundName = filename:gsub("%.[^.]+$", "")
                    local soundPath = category.path .. filename
                    local sourceType = (category.name == "bgm" or category.name == "seasonal") and "stream" or "static"
                    local success, source = pcall(love.audio.newSource, soundPath, sourceType)
                    if success then
                        local key = category.name .. "_" .. soundName
                        state.sounds[key] = source
                        loadedCount = loadedCount + 1
                    end
                end
            end
        end
    end

    print("  - Sounds loaded: " .. loadedCount .. " files")
end

function AssetManager.createPlayerSprite()
    local size = 32
    local canvas = love.graphics.newCanvas(size, size)

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)

    love.graphics.setColor(0.2, 0.6, 1.0)
    love.graphics.circle("fill", size/2, size/2, 12)

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", size/2, size/2 - 6, 3)

    love.graphics.setColor(0.1, 0.4, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", size/2, size/2, 12)

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)

    return canvas
end

function AssetManager.getImage(state, name)
    return state.images[name]
end

function AssetManager.getCharacterSprite(state, charId, direction)
    if state.characterSprites[charId] and state.characterSprites[charId].rotations then
        return state.characterSprites[charId].rotations[direction]
    end
    return nil
end

function AssetManager.getCharacterAnimation(state, charId, animName, direction, frameIndex)
    if state.characterSprites[charId] and
       state.characterSprites[charId].animations and
       state.characterSprites[charId].animations[animName] and
       state.characterSprites[charId].animations[animName][direction] then
        local frames = state.characterSprites[charId].animations[animName][direction]
        if frameIndex and frames[frameIndex] then
            return frames[frameIndex]
        end
        return frames
    end
    return nil
end

function AssetManager.hasCharacterSprite(state, charId)
    return state.characterSprites[charId] ~= nil and
           state.characterSprites[charId].rotations ~= nil
end

function AssetManager.hasCharacterAnimation(state, charId, animName)
    return state.characterSprites[charId] ~= nil and
           state.characterSprites[charId].animations ~= nil and
           state.characterSprites[charId].animations[animName] ~= nil
end

function AssetManager.getAnimationFrameCount(state, charId, animName, direction)
    if AssetManager.hasCharacterAnimation(state, charId, animName) then
        local anim = state.characterSprites[charId].animations[animName]
        if anim[direction] then
            return #anim[direction]
        end
    end
    return 0
end

function AssetManager.getAvailableDirections(state, charId)
    local dirs = {}
    local sprite = state.characterSprites[charId]
    if sprite and sprite.rotations then
        for dir, _ in pairs(sprite.rotations) do
            table.insert(dirs, dir)
        end
    end
    return dirs
end

function AssetManager.getFont(state, name)
    return state.fonts[name] or state.fonts.default
end

function AssetManager.getSound(state, name)
    return state.sounds[name]
end

function AssetManager.getEnemySprite(state, enemyId, direction)
    direction = direction or "south"
    if state.enemySprites[enemyId] and state.enemySprites[enemyId].rotations then
        return state.enemySprites[enemyId].rotations[direction]
    end
    return nil
end

function AssetManager.getEnemyAnimation(state, enemyId, animName, direction, frameIndex)
    direction = direction or "south"
    if state.enemySprites[enemyId] and
       state.enemySprites[enemyId].animations and
       state.enemySprites[enemyId].animations[animName] and
       state.enemySprites[enemyId].animations[animName][direction] then
        local frames = state.enemySprites[enemyId].animations[animName][direction]
        if frameIndex and frames[frameIndex] then
            return frames[frameIndex]
        end
        return frames
    end
    return nil
end

function AssetManager.hasEnemySprite(state, enemyId)
    return state.enemySprites[enemyId] ~= nil and
           next(state.enemySprites[enemyId].rotations) ~= nil
end

function AssetManager.hasEnemyAnimation(state, enemyId, animName)
    return state.enemySprites[enemyId] ~= nil and
           state.enemySprites[enemyId].animations ~= nil and
           state.enemySprites[enemyId].animations[animName] ~= nil
end

function AssetManager.getEnemyAnimationFrameCount(state, enemyId, animName, direction)
    direction = direction or "south"
    if AssetManager.hasEnemyAnimation(state, enemyId, animName) then
        local anim = state.enemySprites[enemyId].animations[animName]
        if anim[direction] then
            return #anim[direction]
        end
    end
    return 0
end

function AssetManager.getNPCSprite(state, npcId, direction)
    direction = direction or "south"
    if state.npcSprites[npcId] and state.npcSprites[npcId].rotations then
        return state.npcSprites[npcId].rotations[direction]
    end
    return nil
end

function AssetManager.hasNPCSprite(state, npcId)
    return state.npcSprites[npcId] ~= nil and
           next(state.npcSprites[npcId].rotations) ~= nil
end

function AssetManager.getMapObject(state, objectName)
    return state.mapObjects[objectName]
end

function AssetManager.hasMapObject(state, objectName)
    return state.mapObjects[objectName] ~= nil
end

function AssetManager.getUIAsset(state, category, name)
    if state.uiAssets[category] then
        return state.uiAssets[category][name]
    end
    return nil
end

function AssetManager.getUIPanel(state, name)
    return AssetManager.getUIAsset(state, "panels", name)
end

function AssetManager.getUIButton(state, name)
    return AssetManager.getUIAsset(state, "buttons", name)
end

function AssetManager.getUIIcon(state, name)
    return AssetManager.getUIAsset(state, "icons", name)
end

function AssetManager.getUIBar(state, name)
    return AssetManager.getUIAsset(state, "bars", name)
end

function AssetManager.getUISlot(state, name)
    return AssetManager.getUIAsset(state, "slots", name)
end

function AssetManager.getBattleBackground(state, name)
    return AssetManager.getUIAsset(state, "battleBg", name)
end

function AssetManager.getDialogAsset(state, name)
    return AssetManager.getUIAsset(state, "dialog", name)
end

function AssetManager.getLoadingAsset(state, name)
    return AssetManager.getUIAsset(state, "loading", name)
end

function AssetManager.getClassIcon(state, name)
    return AssetManager.getUIAsset(state, "classes", name)
end

function AssetManager.getEffect(state, name)
    return AssetManager.getUIAsset(state, "effects", name)
end

return AssetManager
