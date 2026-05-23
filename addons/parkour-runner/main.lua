local StateManager = require("src.state_manager")
local Settings     = require("src.settings")

function love.load()
    -- Window setup
    love.window.setTitle("Parkour Runner")
    love.window.setMode(1280, 720, {
        resizable   = false,
        vsync       = true,
        msaa        = 4,
        fullscreen  = false,
    })
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Load global settings first
    Settings.load()

    -- Apply settings
    love.window.setFullscreen(Settings.data.fullscreen)
    if Settings.data.fullscreen then
        local w, h = love.window.getDesktopDimensions()
        love.window.setMode(w, h, { fullscreen = true, vsync = true })
    end

    -- Seed random
    math.randomseed(os.time())

    -- Boot into menu
    StateManager.switch("menu")
end

function love.update(dt)
    StateManager.update(dt)
end

function love.draw()
    StateManager.draw()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "f11" then
        local fs = not love.window.getFullscreen()
        love.window.setFullscreen(fs)
        Settings.data.fullscreen = fs
        Settings.save()
    end
    StateManager.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key)
    StateManager.keyreleased(key)
end

function love.mousepressed(x, y, button)
    StateManager.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    StateManager.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    StateManager.mousemoved(x, y, dx, dy)
end

function love.quit()
    Settings.save()
end
