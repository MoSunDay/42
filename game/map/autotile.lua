-- autotile.lua - Automatic tile selection system
-- 自动图块系统，根据相邻瓦片自动选择正确的图块样式

local Autotile = {}

Autotile.BITMAP = {
    NORTH = 1,
    SOUTH = 2,
    EAST = 4,
    WEST = 8,
    NORTH_EAST = 16,
    NORTH_WEST = 32,
    SOUTH_EAST = 64,
    SOUTH_WEST = 128
}

local TILE_47 = {
    [0] = 1,    [1] = 2,    [4] = 3,    [5] = 4,
    [2] = 5,    [3] = 6,    [6] = 7,    [7] = 8,
    [8] = 9,    [9] = 10,   [12] = 11,  [13] = 12,
    [10] = 13,  [11] = 14,  [14] = 15,  [15] = 16,
    [16] = 17,  [17] = 18,  [20] = 19,  [21] = 20,
    [18] = 21,  [19] = 22,  [22] = 23,  [23] = 24,
    [24] = 25,  [25] = 26,  [28] = 27,  [29] = 28,
    [26] = 29,  [27] = 30,  [30] = 31,  [31] = 32,
    [32] = 33,  [33] = 34,  [36] = 35,  [37] = 36,
    [34] = 37,  [35] = 38,  [38] = 39,  [39] = 40,
    [40] = 41,  [41] = 42,  [44] = 43,  [45] = 44,
    [42] = 45,  [43] = 46,  [46] = 47,  [47] = 48
}

local TILE_16 = {
    [0] = 1,    [1] = 5,    [4] = 7,    [5] = 9,
    [2] = 6,    [3] = 10,   [6] = 8,    [7] = 12,
    [8] = 2,    [9] = 13,   [12] = 4,   [13] = 15,
    [10] = 14,  [11] = 16,  [14] = 11,  [15] = 3
}

function Autotile.create()
    local state = {}
    state.rules = {}

    Autotile.register_default_rules(state)

    return state
end

function Autotile.register_default_rules(state)
    Autotile.register_rule(state, "water", {
        type = "47_tile",
        baseTileId = 1,
        connectTo = {"water", "water_deep"},
        edgeTiles = {grass = 10, dirt = 20, stone = 30}
    })

    Autotile.register_rule(state, "cliff", {
        type = "47_tile",
        baseTileId = 50,
        connectTo = {"cliff"},
        edgeTiles = {}
    })

    Autotile.register_rule(state, "road", {
        type = "16_tile",
        baseTileId = 100,
        connectTo = {"road"},
        edgeTiles = {}
    })

    Autotile.register_rule(state, "fence", {
        type = "16_tile",
        baseTileId = 150,
        connectTo = {"fence"},
        edgeTiles = {}
    })

    Autotile.register_rule(state, "wall", {
        type = "47_tile",
        baseTileId = 200,
        connectTo = {"wall", "wall_stone", "wall_wood"},
        edgeTiles = {}
    })
end

function Autotile.register_rule(state, name, config)
    state.rules[name] = {
        name = name,
        type = config.type or "47_tile",
        baseTileId = config.baseTileId or 1,
        connectTo = config.connectTo or {name},
        edgeTiles = config.edgeTiles or {}
    }
end

function Autotile.get_neighbor_bitmask(state, tiles, x, y, width, height, connectTypes)
    local bitmask = 0
    local connectSet = {}
    for _, t in ipairs(connectTypes) do
        connectSet[t] = true
    end

    local function get_tile(nx, ny)
        if nx < 0 or nx >= width or ny < 0 or ny >= height then
            return nil
        end
        return tiles[ny * width + nx + 1]
    end

    local n = get_tile(x, y - 1)
    local s = get_tile(x, y + 1)
    local e = get_tile(x + 1, y)
    local w = get_tile(x - 1, y)
    local ne = get_tile(x + 1, y - 1)
    local nw = get_tile(x - 1, y - 1)
    local se = get_tile(x + 1, y + 1)
    local sw = get_tile(x - 1, y + 1)

    local tile = tiles[y * width + x + 1]
    local isConnectable = tile and connectSet[tile]

    if n and connectSet[n] then
        bitmask = bitmask + Autotile.BITMAP.NORTH
    end
    if s and connectSet[s] then
        bitmask = bitmask + Autotile.BITMAP.SOUTH
    end
    if e and connectSet[e] then
        bitmask = bitmask + Autotile.BITMAP.EAST
    end
    if w and connectSet[w] then
        bitmask = bitmask + Autotile.BITMAP.WEST
    end

    local hasN = n and connectSet[n]
    local hasS = s and connectSet[s]
    local hasE = e and connectSet[e]
    local hasW = w and connectSet[w]

    if ne and connectSet[ne] and hasN and hasE then
        bitmask = bitmask + Autotile.BITMAP.NORTH_EAST
    end
    if nw and connectSet[nw] and hasN and hasW then
        bitmask = bitmask + Autotile.BITMAP.NORTH_WEST
    end
    if se and connectSet[se] and hasS and hasE then
        bitmask = bitmask + Autotile.BITMAP.SOUTH_EAST
    end
    if sw and connectSet[sw] and hasS and hasW then
        bitmask = bitmask + Autotile.BITMAP.SOUTH_WEST
    end

    return bitmask
end

function Autotile.get_tile_index(state, bitmask, ruleType)
    if ruleType == "47_tile" then
        return TILE_47[bitmask] or 1
    elseif ruleType == "16_tile" then
        return TILE_16[bitmask] or 1
    end
    return 1
end

function Autotile.process_map(state, tiles, width, height)
    local result = {}

    for i = 1, #tiles do
        result[i] = tiles[i]
    end

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local tileType = tiles[y * width + x + 1]

            if tileType then
                local rule = state.rules[tileType]
                if rule then
                    local bitmask = Autotile.get_neighbor_bitmask(state, tiles, x, y, width, height, rule.connectTo)
                    local tileIndex = Autotile.get_tile_index(state, bitmask, rule.type)
                    result[y * width + x + 1] = rule.baseTileId + tileIndex - 1
                end
            end
        end
    end

    return result
end

function Autotile.process_tile(state, tiles, x, y, width, height)
    local tileType = tiles[y * width + x + 1]

    if not tileType then
        return nil
    end

    local rule = state.rules[tileType]
    if not rule then
        return tileType
    end

    local bitmask = Autotile.get_neighbor_bitmask(state, tiles, x, y, width, height, rule.connectTo)
    local tileIndex = Autotile.get_tile_index(state, bitmask, rule.type)

    return rule.baseTileId + tileIndex - 1
end

function Autotile.process_map_layer(state, map, layerName)
    if not map or not map.layers then return end

    local layer = map.layers[layerName]
    if not layer or not layer.tiles then return end

    local width = math.floor(map.width / map.tileSize)
    local height = math.floor(map.height / map.tileSize)

    layer.tiles = Autotile.process_map(state, layer.tiles, width, height)
end

function Autotile.update_tile(state, tiles, x, y, width, height)
    local affectedTiles = {}

    for dy = -1, 1 do
        for dx = -1, 1 do
            local nx = x + dx
            local ny = y + dy

            if nx >= 0 and nx < width and ny >= 0 and ny < height then
                local tileType = tiles[ny * width + nx + 1]
                if tileType and state.rules[tileType] then
                    local newTileId = Autotile.process_tile(state, tiles, nx, ny, width, height)
                    if newTileId then
                        tiles[ny * width + nx + 1] = newTileId
                        table.insert(affectedTiles, {x = nx, y = ny, tileId = newTileId})
                    end
                end
            end
        end
    end

    return affectedTiles
end

function Autotile.get_tile_sprite_position(state, tileIndex, columns)
    columns = columns or 8
    local col = (tileIndex - 1) % columns
    local row = math.floor((tileIndex - 1) / columns)
    return col, row
end

function Autotile.draw_debug_bitmask(state, x, y, tileSize, bitmask)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)

    love.graphics.setColor(1, 1, 1)
    local cx = x + tileSize / 2
    local cy = y + tileSize / 2

    if bit.band(bitmask, Autotile.BITMAP.NORTH) ~= 0 then
        love.graphics.line(cx, cy, cx, y)
    end
    if bit.band(bitmask, Autotile.BITMAP.SOUTH) ~= 0 then
        love.graphics.line(cx, cy, cx, y + tileSize)
    end
    if bit.band(bitmask, Autotile.BITMAP.EAST) ~= 0 then
        love.graphics.line(cx, cy, x + tileSize, cy)
    end
    if bit.band(bitmask, Autotile.BITMAP.WEST) ~= 0 then
        love.graphics.line(cx, cy, x, cy)
    end

    love.graphics.circle("fill", cx, cy, 3)
    love.graphics.print(tostring(bitmask), x + 2, y + 2)
end

function Autotile.get_rule_for_tile(state, tileType)
    return state.rules[tileType]
end

return Autotile
