local SpriteAnimator = {}
SpriteAnimator.__index = SpriteAnimator

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
    local self = setmetatable({}, SpriteAnimator)
    
    config = config or {}
    self.frameWidth = config.frameWidth or 48
    self.frameHeight = config.frameHeight or 48
    self.frameDuration = config.frameDuration or 0.12
    
    self.animations = {}
    self.rotations = {}
    self.currentDirection = "south"
    self.currentAnimation = "breathing-idle"
    self.currentFrame = 1
    self.animationTime = 0
    self.isPlaying = true
    
    return self
end

function SpriteAnimator:loadFromAssetManager(assetManager, characterId)
    if not assetManager or not characterId then return end
    
    for _, dir in ipairs(ALL_DIRECTIONS) do
        local rotation = assetManager:getCharacterSprite(characterId, dir)
        if rotation then
            self.rotations[dir] = rotation
        end
    end
    
    local animNames = {"walking", "breathing-idle"}
    for _, animName in ipairs(animNames) do
        if assetManager:hasCharacterAnimation(characterId, animName) then
            self.animations[animName] = {}
            for _, dir in ipairs(ALL_DIRECTIONS) do
                local frames = assetManager:getCharacterAnimation(characterId, animName, dir)
                if frames and #frames > 0 then
                    self.animations[animName][dir] = frames
                end
            end
        end
    end
end

function SpriteAnimator:loadDirectionalSprites(basePath, directions)
    directions = directions or ALL_DIRECTIONS
    
    for _, dir in ipairs(directions) do
        local path = basePath .. "/" .. dir .. ".png"
        if love.filesystem.getInfo(path) then
            self.rotations[dir] = love.graphics.newImage(path)
        end
    end
end

function SpriteAnimator:loadAnimationFrames(basePath, animName, direction, frameCount)
    frameCount = frameCount or 6
    self.animations[animName] = self.animations[animName] or {}
    self.animations[animName][direction] = {}
    
    for i = 0, frameCount - 1 do
        local framePath = string.format("%s/%s/frame_%03d.png", basePath, direction, i)
        if love.filesystem.getInfo(framePath) then
            table.insert(self.animations[animName][direction], love.graphics.newImage(framePath))
        end
    end
end

function SpriteAnimator:setDirection(direction)
    local normalizedDir = DIRECTION_TO_INDEX[direction] and direction or nil
    if normalizedDir then
        self.currentDirection = normalizedDir
    elseif DIRECTION_TO_INDEX[direction] then
        self.currentDirection = direction
    end
end

function SpriteAnimator:setAnimation(name)
    if self.currentAnimation ~= name then
        self.currentAnimation = name
        self.currentFrame = 1
        self.animationTime = 0
    end
end

function SpriteAnimator:setAnimationState(isMoving)
    if isMoving then
        self:setAnimation("walking")
    else
        self:setAnimation("breathing-idle")
    end
end

function SpriteAnimator:play()
    self.isPlaying = true
end

function SpriteAnimator:pause()
    self.isPlaying = false
end

function SpriteAnimator:reset()
    self.currentFrame = 1
    self.animationTime = 0
end

function SpriteAnimator:update(dt)
    if not self.isPlaying then
        return
    end
    
    self.animationTime = self.animationTime + dt
    
    local frameCount = self:getFrameCount()
    if frameCount <= 1 then return end
    
    local currentDuration = self.frameDuration
    if self.currentAnimation == "walking" then
        currentDuration = 0.1
    elseif self.currentAnimation == "breathing-idle" then
        currentDuration = 0.2
    end
    
    while self.animationTime >= currentDuration do
        self.animationTime = self.animationTime - currentDuration
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > frameCount then
            self.currentFrame = 1
        end
    end
end

function SpriteAnimator:getFrameCount()
    local anim = self.animations[self.currentAnimation]
    if anim then
        local frames = anim[self.currentDirection]
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

function SpriteAnimator:getCurrentFrameImage()
    local anim = self.animations[self.currentAnimation]
    if anim then
        local frames = anim[self.currentDirection]
        if frames and frames[self.currentFrame] then
            return frames[self.currentFrame]
        end
        if frames and #frames > 0 then
            return frames[math.min(self.currentFrame, #frames)]
        end
        for _, dirFrames in pairs(anim) do
            if dirFrames and #dirFrames > 0 then
                return dirFrames[math.min(self.currentFrame, #dirFrames)]
            end
        end
    end
    
    return self.rotations[self.currentDirection] or self.rotations["south"]
end

function SpriteAnimator:draw(x, y, scale, offsetX, offsetY)
    scale = scale or 1
    offsetX = offsetX or 0
    offsetY = offsetY or 0
    
    local image = self:getCurrentFrameImage()
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

function SpriteAnimator:getCurrentDirection()
    return self.currentDirection
end

function SpriteAnimator:getCurrentFrame()
    return self.currentFrame
end

function SpriteAnimator:getSize()
    return self.frameWidth, self.frameHeight
end

function SpriteAnimator:hasAnimation(animName)
    return self.animations[animName] ~= nil
end

function SpriteAnimator:hasDirectionForAnimation(animName, direction)
    if not self.animations[animName] then return false end
    local frames = self.animations[animName][direction]
    return frames ~= nil and #frames > 0
end

function SpriteAnimator:hasRotation(direction)
    return self.rotations[direction] ~= nil
end

function SpriteAnimator:getAvailableDirections()
    local dirs = {}
    for dir, _ in pairs(self.rotations) do
        table.insert(dirs, dir)
    end
    return dirs
end

function SpriteAnimator:getClosestDirection(targetDir)
    if self:hasDirectionForAnimation(self.currentAnimation, targetDir) then
        return targetDir
    end
    
    if self:hasRotation(targetDir) then
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
            if self:hasDirectionForAnimation(self.currentAnimation, alt) or self:hasRotation(alt) then
                return alt
            end
        end
    end
    
    return "south"
end

return SpriteAnimator
