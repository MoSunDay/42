-- conf.lua - Love2D 配置文件

function love.conf(t)
    t.identity = "combat-game-mvp"
    t.version = "11.4"
    t.console = false
    
    t.window.title = "3D 俯瞰视角战斗游戏 - MVP v1"
    t.window.icon = nil
    t.window.width = 1280
    t.window.height = 720
    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.vsync = 1
    t.window.msaa = 0
    
    -- 启用的模块
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
    t.modules.thread = false
end

