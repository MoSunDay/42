local LoveMock = {}

LoveMock.graphics = {
    getWidth = function() return 1280 end,
    getHeight = function() return 720 end,
    newFont = function(size) return {size = size} end,
    newCanvas = function(w, h)
        return {
            newImageData = function()
                return { encode = function() end }
            end
        }
    end,
    setCanvas = function() end,
    clear = function() end,
    setColor = function() end,
    circle = function() end,
    rectangle = function() end,
    line = function() end,
    print = function() end,
    draw = function() end,
    newImage = function() return {getWidth = function() return 32 end, getHeight = function() return 32 end} end,
    newQuad = function() return {} end,
    push = function() end,
    pop = function() end,
    scale = function() end,
    translate = function() end,
    setLineWidth = function() end,
    getBackgroundColor = function() return 0, 0, 0, 1 end,
    setBackgroundColor = function() end,
}

LoveMock.timer = {
    getDelta = function() return 0.016 end,
    getFPS = function() return 60 end,
    getTime = function() return os.time() end,
}

LoveMock.filesystem = {
    getInfo = function() return nil end,
    read = function() return nil end,
    write = function() return true end,
    exists = function() return false end,
    createDirectory = function() return true end,
    getDirectoryItems = function() return {} end,
}

LoveMock.audio = {
    newSource = function() return {play = function() end, stop = function() end, setVolume = function() end} end,
    play = function() end,
    stop = function() end,
}

LoveMock.keyboard = {
    isDown = function() return false end,
    setKeyRepeat = function() end,
}

LoveMock.mouse = {
    getPosition = function() return 0, 0 end,
    isDown = function() return false end,
    setVisible = function() end,
}

LoveMock.window = {
    setTitle = function() end,
    setMode = function() end,
    getWidth = function() return 1280 end,
    getHeight = function() return 720 end,
}

LoveMock.event = {
    quit = function() end,
    push = function() end,
}

LoveMock.image = {
    newImageData = function() return {} end,
}

function LoveMock.install()
    _G.love = LoveMock
end

function LoveMock.reset()
    LoveMock.graphics.getWidth = function() return 1280 end
    LoveMock.graphics.getHeight = function() return 720 end
end

return LoveMock
