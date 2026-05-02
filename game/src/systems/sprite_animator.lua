local SpriteAnimator = {}

local DIRECTION_TO_INDEX = {
    ["south"] = 1,
    ["south-west"] = 2,
    ["west"] = 3,
    ["north-west"] = 4,
    ["north"] = 5,
    ["north-east"] = 6,
    ["east"] = 7,
    ["south-east"] = 8,
    ["down"] = 1,
    ["down-left"] = 2,
    ["left"] = 3,
    ["up-left"] = 4,
    ["up"] = 5,
    ["up-right"] = 6,
    ["right"] = 7,
    ["down-right"] = 8,
}

local INDEX_TO_DIRECTION = {
    [1] = "south",
    [2] = "south-west",
    [3] = "west",
    [4] = "north-west",
    [5] = "north",
    [6] = "north-east",
    [7] = "east",
    [8] = "south-east",
}

local ALL_DIRECTIONS = {
    "south", "south-west", "west", "north-west",
    "north", "north-east", "east", "south-east"
}

function SpriteAnimator.new(config)
    config = config or {}
    return {
        frameWidth = config.frameWidth or 48,
        frameHeight = config.frameHeight or 48,
        frameDuration = config.frameDuration or 0.12,
        animations = {},
        rotations = {},
        currentDirection = "south",
        currentAnimation = "breathing-idle",
        currentFrame = 1,
        animationTime = 0,
        isPlaying = true,
    }
end

function SpriteAnimator.loadFromAssetManager(state, assetManager, characterId)
    if not assetManager or not characterId then return end
    
    for _, dir in ipairs(ALL_DIRECTIONS) do
        local rotation = assetManager:getCharacterSprite(characterId, dir)
        if rotation then
            state.rotations[dir] = rotation
        end
    end
    
    local animNames = {"walking", "breathing-idle"}
    for _, animName in ipairs(animNames) do
        if assetManager:hasCharacterAnimation(characterId, animName) then
            state.animations[animName] = {}
            for _, dir in ipairs(ALL_DIRECTIONS) do
                local frames = assetManager:getCharacterAnimation(characterId, animName, dir)
                if frames and #frames > 0 then
                    state.animations[animName][dir] = frames
                end
            end
        end
    end
end

function SpriteAnimator.loadDirectionalSprites(state, basePath, directions)
    directions = directions or ALL_DIRECTIONS
    
    for _, dir in ipairs(directions) do
        local path = basePath .. "/" .. dir .. ".png"
        if love.filesystem.getInfo(path) then
            state.rotations[dir] = love.graphics.newImage(path)
        end
    end
end

function SpriteAnimator.loadAnimationFrames(state, basePath, animName, direction, frameCount)
    frameCount = frameCount or 6
    state.animations[animName] = state.animations[animName] or {}
    state.animations[animName][direction] = {}
    
    for i = 0, frameCount - 1 do
        local framePath = string.format("%s/%s/frame_%03d.png", basePath, direction, i)
        if love.filesystem.getInfo(framePath) then
            table.insert(state.animations[animName][direction], love.graphics.newImage(framePath))
        end
    end
end

function SpriteAnimator.setDirection(state, direction)
    local normalizedDir = DIRECTION_TO_INDEX[direction] and direction or nil
    if normalizedDir then
        state.currentDirection = normalizedDir
    elseif DIRECTION_TO_INDEX[direction] then
        state.currentDirection = direction
    end
end

function SpriteAnimator.setAnimation(state, name)
    if state.currentAnimation ~= name then
        state.currentAnimation = name
        state.currentFrame = 1
        state.animationTime = 0
    end
end

function SpriteAnimator.setAnimationState(state, isMoving)
    if isMoving then
        SpriteAnimator.setAnimation(state, "walking")
    else
        SpriteAnimator.setAnimation(state, "breathing-idle")
    end
end

function SpriteAnimator.play(state)
    state.isPlaying = true
end

function SpriteAnimator.pause(state)
    state.isPlaying = false
end

function SpriteAnimator.reset(state)
    state.currentFrame = 1
    state.animationTime = 0
end

function SpriteAnimator.update(state, dt)
    if not state.isPlaying then
        return
    end
    
    state.animationTime = state.animationTime + dt
    
    local frameCount = SpriteAnimator.getFrameCount(state)
    if frameCount <= 1 then return end
    
    local currentDuration = state.frameDuration
    if state.currentAnimation == "walking" then
        currentDuration = 0.1
    elseif state.currentAnimation == "breathing-idle" then
        currentDuration = 0.2
    end
    
    while state.animationTime >= currentDuration do
        state.animationTime = state.animationTime - currentDuration
        state.currentFrame = state.currentFrame + 1
        if state.currentFrame > frameCount then
            state.currentFrame = 1
        end
    end
end

function SpriteAnimator.getFrameCount(state)
    local anim = state.animations[state.currentAnimation]
    if anim then
        local frames = anim[state.currentDirection]
        if frames and #frames > 0 then
            return #frames
        end
        for _, dirFrames in pairs(anim) do
            if dirFrames and #dirFrames > 0 then
                return #dirFrames
            end
        end
    end
    return 1
end

function SpriteAnimator.getCurrentFrameImage(state)
    local anim = state.animations[state.currentAnimation]
    if anim then
        local frames = anim[state.currentDirection]
        if frames and frames[state.currentFrame] then
            return frames[state.currentFrame]
        end
        if frames and #frames > 0 then
            return frames[math.min(state.currentFrame, #frames)]
        end
        for _, dirFrames in pairs(anim) do
            if dirFrames and #dirFrames > 0 then
                return dirFrames[math.min(state.currentFrame, #dirFrames)]
            end
        end
    end
    
    return state.rotations[state.currentDirection] or state.rotations["south"]
end

function SpriteAnimator.draw(state, x, y, scale, offsetX, offsetY)
    scale = scale or 1
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    
    local image = SpriteAnimator.getCurrentFrameImage(state)
    if not image then return end
    
    local w = image:getWidth()
    local h = image:getHeight()
    
    love.graphics.draw(
        image,
        x + offsetX,
        y + offsetY,
        0,
        scale,
        scale,
        w / 2,
        h / 2
    )
end

function SpriteAnimator.getCurrentDirection(state)
    return state.currentDirection
end

function SpriteAnimator.getCurrentFrame(state)
    return state.currentFrame
end

function SpriteAnimator.getSize(state)
    return state.frameWidth, state.frameHeight
end

function SpriteAnimator.hasAnimation(state, animName)
    return state.animations[animName] ~= nil
end

function SpriteAnimator.hasDirectionForAnimation(state, animName, direction)
    if not state.animations[animName] then return false end
    local frames = state.animations[animName][direction]
    return frames ~= nil and #frames > 0
end

function SpriteAnimator.hasRotation(state, direction)
    return state.rotations[direction] ~= nil
end

function SpriteAnimator.getAvailableDirections(state)
    local dirs = {}
    for dir, _ in pairs(state.rotations) do
        table.insert(dirs, dir)
    end
    return dirs
end

function SpriteAnimator.getClosestDirection(state, targetDir)
    if SpriteAnimator.hasDirectionForAnimation(state, state.currentAnimation, targetDir) then
        return targetDir
    end
    
    if SpriteAnimator.hasRotation(state, targetDir) then
        return targetDir
    end
    
    local alternatives = {
        ["south-west"] = {"south", "west"},
        ["south-east"] = {"south", "east"},
        ["north-west"] = {"north", "west"},
        ["north-east"] = {"north", "east"},
    }
    
    local alts = alternatives[targetDir]
    if alts then
        for _, alt in ipairs(alts) do
            if SpriteAnimator.hasDirectionForAnimation(state, state.currentAnimation, alt) or SpriteAnimator.hasRotation(state, alt) then
                return alt
            end
        end
    end
    
    return "south"
end

return SpriteAnimator
