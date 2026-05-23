local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")
local Player   = require("src.player")
local TileMap  = require("src.tilemap")

local state = {}
local SW, SH = 1280, 720

-- ─── Level definitions ───────────────────────────────────────────────────────
-- 0=air 1=solid 2=platform 3=spike 4=bounce 5=ice 6=finish 7=checkpoint
local LEVELS = {
    -- LEVEL 1 - Tutorial Run
    {
        name = "Urban Sprint",
        par  = 30,
        spawnX = 80, spawnY = 480,
        map = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,0,0,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
            {1,1,1,1,1,1,1,1,0,0,0,1,1,1,1,0,0,0,0,1,1,0,0,0,0,1,1,1,1,0,0,0,3,3,0,0,0,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        }
    },
}

-- ─── State variables ─────────────────────────────────────────────────────────
local player, tileMap, camX, camY
local timer, finished, dead
local levelIdx, currentLevel
local flashMsg, flashTimer
local bestTime
local paused

local t = 0
local mx, my = 0, 0

-- ─── Camera ──────────────────────────────────────────────────────────────────
local function updateCamera()
    local targetX = player.x - SW / 2
    local targetY = player.y - SH * 0.55
    local mapW = tileMap:pixelWidth()
    local mapH = tileMap:pixelHeight()
    targetX = math.max(0, math.min(targetX, mapW - SW))
    targetY = math.max(0, math.min(targetY, mapH - SH))
    camX = camX + (targetX - camX) * 0.12
    camY = camY + (targetY - camY) * 0.12
end

local function loadLevel(idx)
    levelIdx     = idx or 1
    currentLevel = LEVELS[levelIdx]
    tileMap  = TileMap.new(currentLevel.map, 0, 0)
    player   = Player.new(currentLevel.spawnX, currentLevel.spawnY)
    camX, camY   = 0, 0
    timer    = 0
    finished = false
    dead     = false
    paused   = false
    flashMsg = nil
    flashTimer = 0
    bestTime = nil  -- could load from highscores
end

function state.enter()
    UI.loadFonts()
    t = 0
    loadLevel(1)
end

function state.update(dt)
    t = t + dt
    if flashTimer > 0 then flashTimer = flashTimer - dt end

    if paused then return end

    if dead then
        -- Respawn after 1.5 sec
        if t - deadTime > 1.5 then
            loadLevel(levelIdx)
        end
        return
    end

    if finished then return end

    timer = timer + dt

    player:update(dt, tileMap)

    -- Check death tiles
    local px, py, pw, ph = player:getRect()
    local cx2 = px + pw/2
    local cy2 = py + ph

    -- Spikes
    if tileMap:isLethal(cx2, cy2 - 2) or tileMap:isLethal(cx2, py + 2) then
        dead    = true
        deadTime = t
        flashMsg   = "DEAD"
        flashTimer = 1.5
    end

    -- Player fell out
    if not player.alive then
        dead    = true
        deadTime = t
        flashMsg = "FELL"
        flashTimer = 1.5
    end

    -- Finish
    if tileMap:isFinish(cx2, cy2 - 4) then
        finished = true
        flashMsg = "FINISH!"
        flashTimer = 5

        -- Save score
        Settings.addHighscore("time_attack", {
            name  = Settings.data.playerName,
            score = math.floor(timer * 100) / 100,
            date  = os.date("%Y-%m-%d"),
        })
    end

    updateCamera()
end

function state.draw()
    -- Sky gradient
    love.graphics.setColor(0.06, 0.06, 0.10)
    love.graphics.rectangle("fill", 0, 0, SW, SH)

    -- Parallax bg stripes
    love.graphics.setColor(0.08, 0.08, 0.12)
    for i = 0, 20 do
        local x = (i * 80 - camX * 0.3) % (SW + 80) - 40
        love.graphics.rectangle("fill", x, 0, 2, SH)
    end

    -- Map
    tileMap:draw(camX, camY, SW, SH)

    -- Player
    player:draw(camX, camY)

    -- HUD
    drawHUD()

    -- Pause overlay
    if paused then drawPause() end

    -- Flash message
    if flashTimer > 0 and flashMsg then
        local alpha = math.min(1, flashTimer)
        UI.flash(flashMsg, alpha)
    end
end

function drawHUD()
    -- Top bar
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, SW, 44)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill", 0, 43, SW, 2)

    -- Timer
    love.graphics.setFont(UI.fonts.heading)
    love.graphics.setColor(UI.colors.white)
    love.graphics.printf(UI.fmt_time(timer), 0, 9, SW, "center")

    -- Level name
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("TIME ATTACK  |  " .. (currentLevel.name or ""), 10, 14)

    -- PAR time
    love.graphics.setColor(UI.colors.accent)
    love.graphics.printf("PAR " .. UI.fmt_time(currentLevel.par), SW - 160, 14, 140, "right")

    -- Mode badge
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill", 0, 0, 4, 44)

    -- FPS
    if Settings.data.showFPS then
        love.graphics.setFont(UI.fonts.tiny)
        love.graphics.setColor(UI.colors.grey)
        love.graphics.print("FPS " .. love.timer.getFPS(), 10, SH - 18)
    end

    -- Player state debug
    player:drawHUD()

    -- Controls reminder (bottom, fades after 5s)
    if t < 8 then
        local alpha = math.min(1, (8 - t) * 0.5)
        love.graphics.setFont(UI.fonts.tiny)
        love.graphics.setColor(0.6, 0.6, 0.6, alpha)
        love.graphics.printf(
            "A/D Move   SPACE Jump (x2)   LSHIFT Slide   ESC Pause",
            0, SH - 30, SW, "center")
    end
end

function drawPause()
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, SW, SH)

    love.graphics.setFont(UI.fonts.title)
    love.graphics.setColor(UI.colors.white)
    love.graphics.printf("PAUSED", 0, 240, SW, "center")

    local opts = {
        {label="RESUME",      action=function() paused=false end},
        {label="RESTART",     action=function() loadLevel(levelIdx) end},
        {label="MAIN MENU",   action=function() SM.switch("menu") end},
    }
    for i, opt in ipairs(opts) do
        UI.button({x=SW/2-160, y=320+i*66, w=320, h=54, label=opt.label}, mx, my)
        opt._y = 320 + i * 66
    end
    pauseOpts = opts
end

function state.keypressed(key)
    local kb = Settings.data.keybinds
    if key == kb.pause or key == "escape" then
        if finished or dead then SM.switch("menu") return end
        paused = not paused
    end
    if key == kb.jump then
        if not paused and not dead and not finished then
            player:onJump()
        end
    end
    if key == "r" and (dead or finished) then
        loadLevel(levelIdx)
    end
end

function state.mousemoved(x, y) mx, my = x, y end

function state.mousepressed(x, y, button)
    if button ~= 1 then return end
    if paused and pauseOpts then
        for _, opt in ipairs(pauseOpts) do
            if opt._y and x >= SW/2-160 and x <= SW/2+160 and y >= opt._y and y <= opt._y+54 then
                opt.action()
                return
            end
        end
    end
end

return state
