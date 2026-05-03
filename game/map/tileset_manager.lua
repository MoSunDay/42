-- tileset_manager.lua - Tileset management system
-- 管理瓦片集加载、缓存和渲染

local TilesetManager = {}

function TilesetManager.create()
    local state = {}
    state.tilesets = {}
    state.tileDefinitions = {}
    state.animationFrames = {}
    state.autotileRules = {}

    TilesetManager.register_default_tiles(state)

    return state
end

function TilesetManager.register_default_tiles(state)
    state.tileDefinitions["grass1"] = {
        id = 1,
        name = "grass1",
        color = {0.35, 0.70, 0.35},
        walkable = true
    }

    state.tileDefinitions["grass2"] = {
        id = 2,
        name = "grass2",
        color = {0.30, 0.65, 0.30},
        walkable = true
    }

    state.tileDefinitions["road"] = {
        id = 3,
        name = "road",
        color = {0.50, 0.48, 0.45},
        walkable = true
    }

    state.tileDefinitions["water"] = {
        id = 4,
        name = "water",
        color = {0.3, 0.5, 0.8},
        walkable = false,
        animated = true,
        animation = {
            frames = {4, 5, 6, 5},
            fps = 4
        }
    }

    state.tileDefinitions["wall"] = {
        id = 10,
        name = "wall",
        color = {0.5, 0.4, 0.3},
        walkable = false
    }

    state.tileDefinitions["tree"] = {
        id = 20,
        name = "tree",
        color = {0.2, 0.5, 0.2},
        walkable = false,
        hasOverlay = true
    }

    state.tileDefinitions["rock"] = {
        id = 21,
        name = "rock",
        color = {0.5, 0.5, 0.5},
        walkable = false
    }
end

function TilesetManager.load(state, name, imagePath, config)
    config = config or {}

    if state.tilesets[name] then
        return state.tilesets[name]
    end

    local tileset = {
        name = name,
        imagePath = imagePath,
        tileSize = config.tileSize or 32,
        columns = config.columns or 1,
        rows = config.rows or 1,
        tileCount = (config.columns or 1) * (config.rows or 1),
        margin = config.margin or 0,
        spacing = config.spacing or 0,
        tiles = {}
    }

    local success, image = pcall(love.graphics.newImage, imagePath)
    if success then
        tileset.image = image
        tileset.width = image:getWidth()
        tileset.height = image:getHeight()

        if not config.columns then
            tileset.columns = math.floor((tileset.width - config.margin * 2 + config.spacing) /
                                         (tileset.tileSize + config.spacing))
        end
        if not config.rows then
            tileset.rows = math.floor((tileset.height - config.margin * 2 + config.spacing) /
                                      (tileset.tileSize + config.spacing))
        end
        tileset.tileCount = tileset.columns * tileset.rows

        TilesetManager.generate_quads(state, tileset)
    end

    state.tilesets[name] = tileset
    return tileset
end

function TilesetManager.generate_quads(state, tileset)
    tileset.quads = {}

    for i = 0, tileset.tileCount - 1 do
        local col = i % tileset.columns
        local row = math.floor(i / tileset.columns)

        local x = tileset.margin + col * (tileset.tileSize + tileset.spacing)
        local y = tileset.margin + row * (tileset.tileSize + tileset.spacing)

        tileset.quads[i + 1] = love.graphics.newQuad(
            x, y,
            tileset.tileSize, tileset.tileSize,
            tileset.width, tileset.height
        )
    end
end

function TilesetManager.get_tileset(state, name)
    return state.tilesets[name] or state.tilesets["default"]
end

function TilesetManager.get_quad(state, tilesetName, tileId)
    local tileset = TilesetManager.get_tileset(state, tilesetName)
    if tileset and tileset.quads and tileset.quads[tileId] then
        return tileset.quads[tileId]
    end
    return nil
end

function TilesetManager.draw_tile(state, tilesetName, tileId, x, y, scale)
    scale = scale or 1
    local tileset = TilesetManager.get_tileset(state, tilesetName)

    if tileset and tileset.image and tileset.quads then
        local quad = tileset.quads[tileId]
        if quad then
            love.graphics.draw(tileset.image, quad, x, y, 0, scale, scale)
            return true
        end
    end

    local def = state.tileDefinitions[tileId] or TilesetManager.get_tile_def_by_id(state, tileId)
    if def and def.color then
        love.graphics.setColor(def.color)
        love.graphics.rectangle("fill", x, y, 32 * scale, 32 * scale)
        return true
    end

    return false
end

function TilesetManager.get_tile_def_by_id(state, id)
    for name, def in pairs(state.tileDefinitions) do
        if def.id == id then
            return def
        end
    end
    return nil
end

function TilesetManager.register_tile(state, id, config)
    state.tileDefinitions[id] = {
        id = config.id or id,
        name = config.name or tostring(id),
        color = config.color or {1, 1, 1},
        walkable = config.walkable ~= false,
        animated = config.animated or false,
        animation = config.animation,
        hasOverlay = config.hasOverlay or false,
        autotile = config.autotile or false
    }

    if config.animated and config.animation then
        state.animationFrames[id] = {
            frames = config.animation.frames or {id},
            fps = config.animation.fps or 4,
            currentFrame = 1,
            timer = 0
        }
    end

    if config.autotile then
        state.autotileRules[id] = config.autotile
    end
end

function TilesetManager.update_animations(state, dt)
    for tileId, anim in pairs(state.animationFrames) do
        anim.timer = anim.timer + dt
        local frameTime = 1 / anim.fps

        if anim.timer >= frameTime then
            anim.timer = anim.timer - frameTime
            anim.currentFrame = anim.currentFrame + 1
            if anim.currentFrame > #anim.frames then
                anim.currentFrame = 1
            end
        end
    end
end

function TilesetManager.get_animated_tile_id(state, tileId)
    local anim = state.animationFrames[tileId]
    if anim then
        return anim.frames[anim.currentFrame]
    end
    return tileId
end

function TilesetManager.is_walkable(state, tileId)
    local def = state.tileDefinitions[tileId] or TilesetManager.get_tile_def_by_id(state, tileId)
    if def then
        return def.walkable
    end
    return true
end

function TilesetManager.has_overlay(state, tileId)
    local def = state.tileDefinitions[tileId] or TilesetManager.get_tile_def_by_id(state, tileId)
    if def then
        return def.hasOverlay
    end
    return false
end

function TilesetManager.get_autotile_rule(state, tileId)
    return state.autotileRules[tileId]
end

function TilesetManager.unload(state, name)
    if state.tilesets[name] then
        state.tilesets[name] = nil
    end
end

function TilesetManager.unload_all(state)
    state.tilesets = {}
end

function TilesetManager.get_tileset_name_for_id(state, tileId, firstgids)
    if not firstgids then
        return "default"
    end

    for i = #firstgids, 1, -1 do
        if tileId >= firstgids[i].firstgid then
            return firstgids[i].name
        end
    end

    return "default"
end

function TilesetManager.create_procedural_tileset(state, name, colors, tileSize)
    tileSize = tileSize or 32
    local width = #colors * tileSize
    local height = tileSize

    local canvas = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas(canvas)

    for i, color in ipairs(colors) do
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", (i - 1) * tileSize, 0, tileSize, tileSize)
    end

    love.graphics.setCanvas()

    local imageData = canvas:newImageData()
    local image = love.graphics.newImage(imageData)

    local tileset = {
        name = name,
        image = image,
        width = width,
        height = height,
        tileSize = tileSize,
        columns = #colors,
        rows = 1,
        tileCount = #colors,
        procedural = true
    }

    TilesetManager.generate_quads(state, tileset)
    state.tilesets[name] = tileset

    return tileset
end

return TilesetManager
