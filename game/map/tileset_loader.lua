local TilesetLoader = {}

local TILESET_DIR = "assets/images/tilesets"

local TILE_TYPE_FILE_MAP = {
    grass1 = "ground_1",
    grass2 = "ground_2",
    grass3 = "ground_3",
    grass4 = "ground_4",
    road1 = "road_1",
    road2 = "road_2",
    water = "water",
}

local SEASON_FALLBACKS = {
    spring = {
        ground = {"terrain/grass", "terrain/grass_alt"},
        road = {"terrain/dirt_path", "terrain/wood"},
    },
    summer = {
        ground = {"terrain/grass_alt", "terrain/grass"},
        road = {"terrain/dirt_path", "terrain/stone"},
    },
    autumn = {
        ground = {"terrain/dirt", "terrain/dirt_path"},
        road = {"terrain/stone", "terrain/stone_alt"},
    },
    winter = {
        ground = {"terrain/snow", "terrain/snow"},
        road = {"terrain/stone", "terrain/stone_alt"},
    },
    desert = {
        ground = {"terrain/sand", "terrain/dirt"},
        road = {"terrain/dirt_path", "terrain/stone"},
    },
    volcanic = {
        ground = {"terrain/lava", "terrain/stone"},
        road = {"terrain/stone_alt", "terrain/stone"},
    },
    underwater = {
        ground = {"terrain/stone_alt", "terrain/stone"},
        road = {"dungeon/floor", "dungeon/floor_alt"},
    },
    sky = {
        ground = {"terrain/snow", "terrain/snow"},
        road = {"terrain/stone", "terrain/stone_alt"},
    },
}

local THEME_SEASON_MAP = {
    forest = "spring",
    desert = "desert",
    snow = "winter",
    volcanic = "volcanic",
    cave = "underwater",
    sky = "sky",
    swamp = "autumn",
    crystal = "underwater",
    ruins = "summer",
    mystical = "sky",
}

local OBJECT_SPRITES = {
    tree_oak = "objects/trees/tree_oak",
    tree_pine = "objects/trees/tree_pine",
    tree_dead = "objects/trees/tree_dead",
    rock = "objects/props/rock",
    bush = "objects/props/bush",
}

function TilesetLoader.create()
    local state = {}
    state.imageCache = {}
    state.tileCache = {}
    state.objectCache = {}
    state.loaded = false
    return state
end

function TilesetLoader.load_image(state, relativePath)
    if state.imageCache[relativePath] then
        return state.imageCache[relativePath]
    end

    local fullPath = TILESET_DIR .. "/" .. relativePath .. ".png"
    local info = love.filesystem.getInfo(fullPath)
    if not info then
        state.imageCache[relativePath] = false
        return nil
    end

    local success, image = pcall(love.graphics.newImage, fullPath)
    if success and image then
        image:setFilter("nearest", "nearest")
        image:setWrap("repeat", "repeat")
        state.imageCache[relativePath] = image
        return image
    end

    state.imageCache[relativePath] = false
    return nil
end

function TilesetLoader.get_tile_image(state, season, tileType)
    local cacheKey = season .. "/" .. tileType
    if state.tileCache[cacheKey] ~= nil then
        return state.tileCache[cacheKey]
    end

    local fileName = TILE_TYPE_FILE_MAP[tileType]
    if fileName then
        local seasonPath = season .. "/" .. fileName
        local img = TilesetLoader.load_image(state, seasonPath)
        if img then
            state.tileCache[cacheKey] = img
            return img
        end
    end

    local fallbacks = SEASON_FALLBACKS[season] or SEASON_FALLBACKS.spring
    local fallbackList
    if tileType == "water" then
        fallbackList = {"terrain/water"}
    elseif tileType:find("road") then
        fallbackList = fallbacks.road
    else
        fallbackList = fallbacks.ground
    end

    for _, path in ipairs(fallbackList) do
        local img = TilesetLoader.load_image(state, path)
        if img then
            state.tileCache[cacheKey] = img
            return img
        end
    end

    state.tileCache[cacheKey] = false
    return nil
end

function TilesetLoader.get_object_sprite(state, spriteName)
    if state.objectCache[spriteName] ~= nil then
        return state.objectCache[spriteName]
    end

    local path = OBJECT_SPRITES[spriteName]
    if path then
        local img = TilesetLoader.load_image(state, path)
        if img then
            state.objectCache[spriteName] = img
            return img
        end
    end

    state.objectCache[spriteName] = false
    return nil
end

function TilesetLoader.draw_image(image, x, y, tileSize, imgSize)
    if not image then return false end
    imgSize = imgSize or 32
    local scale = tileSize / imgSize
    love.graphics.draw(image, x, y, 0, scale, scale)
    return true
end

function TilesetLoader.draw_image_scaled(image, x, y, targetW, targetH, imgSize)
    if not image then return false end
    imgSize = imgSize or 32
    local scaleX = targetW / imgSize
    local scaleY = targetH / imgSize
    love.graphics.draw(image, x, y, 0, scaleX, scaleY)
    return true
end

function TilesetLoader.get_tiles_for_season(state, season)
    local mapped = SEASON_FALLBACKS[season] or SEASON_FALLBACKS.spring
    local result = { ground = {}, road = {} }

    for _, path in ipairs(mapped.ground) do
        local img = TilesetLoader.load_image(state, path)
        if img then table.insert(result.ground, img) end
    end

    for _, path in ipairs(mapped.road) do
        local img = TilesetLoader.load_image(state, path)
        if img then table.insert(result.road, img) end
    end

    return result
end

function TilesetLoader.get_season_for_theme(theme)
    return THEME_SEASON_MAP[theme] or theme
end

function TilesetLoader.has_tiles(state, season)
    local tiles = TilesetLoader.get_tiles_for_season(state, season)
    return #tiles.ground > 0 or #tiles.road > 0
end

function TilesetLoader.preload_all(state)
    for season, _ in pairs(SEASON_FALLBACKS) do
        TilesetLoader.get_tiles_for_season(state, season)
    end
    state.loaded = true
end

return TilesetLoader
