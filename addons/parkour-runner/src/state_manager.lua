local StateManager = {}

local states = {}
local current = nil
local currentName = ""

local function loadState(name)
    if not states[name] then
        states[name] = require("src.states." .. name)
    end
    return states[name]
end

function StateManager.switch(name, ...)
    if current and current.leave then
        current.leave()
    end
    currentName = name
    current = loadState(name)
    if current.enter then
        current.enter(...)
    end
end

function StateManager.update(dt)
    if current and current.update then current.update(dt) end
end

function StateManager.draw()
    if current and current.draw then current.draw() end
end

function StateManager.keypressed(key, scancode, isrepeat)
    if current and current.keypressed then current.keypressed(key, scancode, isrepeat) end
end

function StateManager.keyreleased(key)
    if current and current.keyreleased then current.keyreleased(key) end
end

function StateManager.mousepressed(x, y, button)
    if current and current.mousepressed then current.mousepressed(x, y, button) end
end

function StateManager.mousereleased(x, y, button)
    if current and current.mousereleased then current.mousereleased(x, y, button) end
end

function StateManager.mousemoved(x, y, dx, dy)
    if current and current.mousemoved then current.mousemoved(x, y, dx, dy) end
end

return StateManager
