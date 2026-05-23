function love.conf(t)
    t.identity    = "parkour-runner"
    t.version     = "11.5"
    t.console     = false

    t.window.title   = "Parkour Runner"
    t.window.icon    = nil
    t.window.width   = 1280
    t.window.height  = 720
    t.window.resizable = false
    t.window.vsync   = 1
    t.window.msaa    = 4
    t.window.fullscreen      = false
    t.window.fullscreentype  = "desktop"

    t.modules.audio    = true
    t.modules.data     = true
    t.modules.event    = true
    t.modules.font     = true
    t.modules.graphics = true
    t.modules.image    = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math     = true
    t.modules.mouse    = true
    t.modules.physics  = false   -- we handle physics manually
    t.modules.sound    = true
    t.modules.system   = true
    t.modules.thread   = false
    t.modules.timer    = true
    t.modules.touch    = false
    t.modules.video    = false
    t.modules.window   = true
end
