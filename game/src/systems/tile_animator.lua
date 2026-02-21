-- tile_animator.lua - Tile animation system
-- 瓦片动画系统，支持水面、火焰等动态效果

local TileAnimator = {}
TileAnimator.__index = TileAnimator

TileAnimator.animations = {}
TileAnimator.activeTiles = {}
TileAnimator.globalTime = 0

local ANIMATION_PRESETS = {
    water = {
        frames = {1, 2, 3, 2},
        fps = 4,
        offsetVariation = true
    },
    water_deep = {
        frames = {1, 2, 3, 4, 3, 2},
        fps = 3,
        offsetVariation = true
    },
    fire = {
        frames = {1, 2, 3, 1, 2},
        fps = 8,
        offsetVariation = false
    },
    torch = {
        frames = {1, 2, 1, 3, 2, 1},
        fps = 6,
        offsetVariation = false
    },
    lava = {
        frames = {1, 2, 3, 2, 1},
        fps = 2,
        offsetVariation = true
    },
    grass_sway = {
        frames = {1, 2, 1, 3},
        fps = 1,
        offsetVariation = true
    },
    flower = {
        frames = {1, 2, 1},
        fps = 2,
        offsetVariation = true
    },
    waterfall = {
        frames = {1, 2, 3, 4},
        fps = 6,
        offsetVariation = false
    },
    portal = {
        frames = {1, 2, 3, 4, 3, 2},
        fps = 4,
        offsetVariation = false
    }
}

function TileAnimator.new()
    local self = setmetatable({}, TileAnimator)
    self.animations = {}
    self.activeTiles = {}
    self.globalTime = 0
    self.enabled = true
    
    self:registerPresets()
    
    return self
end

function TileAnimator:registerPresets()
    for name, preset in pairs(ANIMATION_PRESETS) do
        self.animations[name] = {
            name = name,
            frames = preset.frames,
            fps = preset.fps,
            frameTime = 1 / preset.fps,
            offsetVariation = preset.offsetVariation,
            currentFrame = 1,
            timer = 0
        }
    end
end

function TileAnimator:registerAnimation(name, config)
    self.animations[name] = {
        name = name,
        frames = config.frames or {1},
        fps = config.fps or 4,
        frameTime = 1 / (config.fps or 4),
        offsetVariation = config.offsetVariation or false,
        currentFrame = 1,
        timer = 0,
        tileColors = config.tileColors
    }
end

function TileAnimator:registerAnimatedTile(tileX, tileY, animationName)
    local key = tileX .. "," .. tileY
    
    local anim = self.animations[animationName]
    if not anim then
        return false
    end
    
    local offset = 0
    if anim.offsetVariation then
        offset = (tileX * 7 + tileY * 13) % #anim.frames
    end
    
    self.activeTiles[key] = {
        x = tileX,
        y = tileY,
        animation = animationName,
        currentFrame = anim.frames[1],
        timer = 0,
        frameOffset = offset,
        frameIndex = 1 + offset
    }
    
    return true
end

function TileAnimator:removeAnimatedTile(tileX, tileY)
    local key = tileX .. "," .. tileY
    self.activeTiles[key] = nil
end

function TileAnimator:clearAnimatedTiles()
    self.activeTiles = {}
end

function TileAnimator:update(dt)
    if not self.enabled then return end
    
    self.globalTime = self.globalTime + dt
    
    for key, tile in pairs(self.activeTiles) do
        local anim = self.animations[tile.animation]
        if anim then
            tile.timer = tile.timer + dt
            
            if tile.timer >= anim.frameTime then
                tile.timer = tile.timer - anim.frameTime
                tile.frameIndex = tile.frameIndex + 1
                
                if tile.frameIndex > #anim.frames then
                    tile.frameIndex = 1
                end
                
                tile.currentFrame = anim.frames[tile.frameIndex]
            end
        end
    end
end

function TileAnimator:getAnimationFrame(tileX, tileY)
    local key = tileX .. "," .. tileY
    local tile = self.activeTiles[key]
    
    if tile then
        return tile.currentFrame
    end
    
    return nil
end

function TileAnimator:getAnimationColor(animationName, frame)
    local anim = self.animations[animationName]
    if anim and anim.tileColors then
        local colorIndex = ((frame or 1) - 1) % #anim.tileColors + 1
        return anim.tileColors[colorIndex]
    end
    return nil
end

function TileAnimator:drawAnimatedTile(tileX, tileY, x, y, tileSize, theme)
    local key = tileX .. "," .. tileY
    local tile = self.activeTiles[key]
    
    if not tile then
        return false
    end
    
    local anim = self.animations[tile.animation]
    if not anim then
        return false
    end
    
    if anim.tileColors then
        local color = self:getAnimationColor(tile.animation, tile.currentFrame)
        if color then
            love.graphics.setColor(color)
            love.graphics.rectangle("fill", x, y, tileSize, tileSize)
            return true
        end
    end
    
    if tile.animation == "water" or tile.animation == "water_deep" then
        self:drawWaterTile(x, y, tileSize, tile.currentFrame, theme)
        return true
    elseif tile.animation == "fire" or tile.animation == "torch" then
        self:drawFireTile(x, y, tileSize, tile.currentFrame, theme)
        return true
    elseif tile.animation == "lava" then
        self:drawLavaTile(x, y, tileSize, tile.currentFrame, theme)
        return true
    elseif tile.animation == "portal" then
        self:drawPortalTile(x, y, tileSize, tile.currentFrame, theme)
        return true
    elseif tile.animation == "waterfall" then
        self:drawWaterfallTile(x, y, tileSize, tile.currentFrame, theme)
        return true
    end
    
    return false
end

function TileAnimator:drawWaterTile(x, y, tileSize, frame, theme)
    local baseColor = theme and theme.water or {0.3, 0.5, 0.8}
    
    local colorVariation = {
        {baseColor[1], baseColor[2], baseColor[3]},
        {baseColor[1] + 0.05, baseColor[2] + 0.05, baseColor[3] + 0.05},
        {baseColor[1] - 0.03, baseColor[2] - 0.03, baseColor[3] + 0.02},
        {baseColor[1] + 0.02, baseColor[2] + 0.02, baseColor[3] + 0.03}
    }
    
    local color = colorVariation[((frame - 1) % 4) + 1]
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    
    love.graphics.setColor(1, 1, 1, 0.3)
    local waveOffset = (frame - 1) * 4
    for i = 0, tileSize - 4, 8 do
        local waveY = y + 4 + ((i + waveOffset) % 16)
        if waveY < y + tileSize then
            love.graphics.rectangle("fill", x + i + 2, waveY, 4, 2)
        end
    end
end

function TileAnimator:drawFireTile(x, y, tileSize, frame, theme)
    love.graphics.setColor(0.2, 0.1, 0.05)
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    
    local fireColors = {
        {1.0, 0.9, 0.3},
        {1.0, 0.6, 0.1},
        {1.0, 0.3, 0.1},
        {0.9, 0.2, 0.1}
    }
    
    local numFlames = 3 + (frame % 2)
    for i = 1, numFlames do
        local flameX = x + (i - 1) * (tileSize / numFlames) + tileSize / (numFlames * 2)
        local flameY = y + tileSize
        local flameHeight = tileSize * 0.5 + (frame + i) % 3 * 4
        
        local colorIndex = ((frame + i - 2) % 4) + 1
        love.graphics.setColor(fireColors[colorIndex])
        
        local offsetX = math.sin(self.globalTime * 5 + i) * 2
        
        love.graphics.polygon("fill",
            flameX + offsetX - 4, flameY,
            flameX + offsetX, flameY - flameHeight,
            flameX + offsetX + 4, flameY
        )
    end
end

function TileAnimator:drawLavaTile(x, y, tileSize, frame, theme)
    local baseColor = {0.8, 0.3, 0.1}
    local brightColor = {1.0, 0.6, 0.2}
    local darkColor = {0.6, 0.2, 0.05}
    
    love.graphics.setColor(baseColor)
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    
    love.graphics.setColor(brightColor)
    local bubbleCount = 2 + (frame % 3)
    for i = 1, bubbleCount do
        local bubbleX = x + (i * 11 % tileSize)
        local bubbleY = y + (i * 7 % tileSize)
        local bubbleSize = 3 + (frame + i) % 3
        love.graphics.circle("fill", bubbleX, bubbleY, bubbleSize)
    end
    
    love.graphics.setColor(darkColor)
    local crackX = x + frame % (tileSize - 4)
    love.graphics.line(crackX, y, crackX + 4, y + tileSize)
end

function TileAnimator:drawPortalTile(x, y, tileSize, frame, theme)
    love.graphics.setColor(0.1, 0.05, 0.2)
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    
    local portalColors = {
        {0.5, 0.2, 0.8},
        {0.6, 0.3, 0.9},
        {0.7, 0.4, 1.0},
        {0.6, 0.3, 0.9}
    }
    
    local colorIndex = ((frame - 1) % 4) + 1
    love.graphics.setColor(portalColors[colorIndex][1], portalColors[colorIndex][2], portalColors[colorIndex][3], 0.8)
    
    local centerX = x + tileSize / 2
    local centerY = y + tileSize / 2
    local radius = tileSize / 3
    
    love.graphics.circle("fill", centerX, centerY, radius)
    
    love.graphics.setColor(1, 1, 1, 0.5)
    local sparkleCount = 3
    for i = 1, sparkleCount do
        local angle = self.globalTime * 2 + i * 2.1
        local sparkleX = centerX + math.cos(angle) * radius * 0.7
        local sparkleY = centerY + math.sin(angle) * radius * 0.7
        love.graphics.circle("fill", sparkleX, sparkleY, 2)
    end
end

function TileAnimator:drawWaterfallTile(x, y, tileSize, frame, theme)
    local baseColor = theme and theme.water or {0.3, 0.5, 0.8}
    
    love.graphics.setColor(baseColor[1] - 0.1, baseColor[2] - 0.1, baseColor[3])
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    
    love.graphics.setColor(baseColor[1] + 0.1, baseColor[2] + 0.1, baseColor[3] + 0.1, 0.8)
    local dropCount = 4
    for i = 1, dropCount do
        local dropX = x + (i * 7) % tileSize
        local dropY = y + ((frame + i) * 8) % tileSize
        love.graphics.rectangle("fill", dropX, dropY, 2, 6)
    end
    
    love.graphics.setColor(1, 1, 1, 0.4)
    local mistY = y + tileSize - 8
    love.graphics.ellipse("fill", x + tileSize / 2, mistY, tileSize / 2, 4)
end

function TileAnimator:scanMapForAnimatedTiles(map)
    if not map or not map.tiles then return end
    
    self:clearAnimatedTiles()
    
    local animationTileTypes = {
        [4] = "water",
        [5] = "water_deep",
        [6] = "fire",
        [7] = "lava",
        [8] = "torch",
        [9] = "portal",
        [10] = "waterfall"
    }
    
    local tilesX = math.floor(map.width / map.tileSize)
    local tilesY = math.floor(map.height / map.tileSize)
    
    for y = 0, tilesY - 1 do
        for x = 0, tilesX - 1 do
            local tileId = map.tiles[y * tilesX + x + 1]
            local animName = animationTileTypes[tileId]
            
            if animName then
                self:registerAnimatedTile(x, y, animName)
            end
        end
    end
end

function TileAnimator:setEnabled(enabled)
    self.enabled = enabled
end

function TileAnimator:getActiveTileCount()
    local count = 0
    for _ in pairs(self.activeTiles) do
        count = count + 1
    end
    return count
end

return TileAnimator
