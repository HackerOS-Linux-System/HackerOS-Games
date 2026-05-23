local UI      = require("src.ui")
local SM      = require("src.state_manager")
local Settings = require("src.settings")

local menu = {}

local SW, SH = 1280, 720
local t = 0

-- Navigation items
local NAV_ITEMS = {
    { id = "play",      label = "PLAY",        sub = true  },
    { id = "settings",  label = "SETTINGS"               },
    { id = "controls",  label = "CONTROLS"               },
    { id = "highscores",label = "LEADERBOARD"             },
    { id = "quit",      label = "QUIT"                    },
}

local sel = 1
local showModes = false  -- are we showing mode selection?

local MODE_CARDS = {
    {
        id    = "time_attack",
        title = "TIME ATTACK",
        icon  = "⏱",
        color = {0.96, 0.42, 0.10, 1},
        desc  = "Race to the finish line as fast as possible. Every millisecond counts.",
        state = "time_attack",
    },
    {
        id    = "hunter",
        title = "HUNTER MODE",
        icon  = "👁",
        color = {0.20, 0.70, 1.00, 1},
        desc  = "Chase or be chased across massive, varied maps. Survive or dominate.",
        state = "hunter",
    },
    {
        id    = "endless",
        title = "ENDLESS RUN",
        icon  = "∞",
        color = {0.10, 0.85, 0.45, 1},
        desc  = "Procedurally generated obstacles, infinite run. Survive as long as you can.",
        state = "endless",
    },
}

local mx, my = 0, 0
local particles = {}

local function spawnParticles()
    for _ = 1, 40 do
        table.insert(particles, {
            x  = math.random(0, SW),
            y  = math.random(0, SH),
            vx = math.random(-20, 20) * 0.1,
            vy = math.random(-30, -10) * 0.1,
            a  = math.random() * 0.4 + 0.1,
            s  = math.random(1, 3),
        })
    end
end

function menu.enter()
    UI.loadFonts()
    showModes = false
    sel = 1
    spawnParticles()
end

function menu.update(dt)
    t = t + dt
    -- Update particles
    for _, p in ipairs(particles) do
        p.x = p.x + p.vx * dt * 60
        p.y = p.y + p.vy * dt * 60
        if p.y < -10 then
            p.y = SH + 10
            p.x = math.random(0, SW)
        end
    end
end

function menu.draw()
    -- Background
    love.graphics.setColor(UI.colors.bg)
    love.graphics.rectangle("fill", 0, 0, SW, SH)
    UI.drawGrid(t)

    -- Particles
    for _, p in ipairs(particles) do
        love.graphics.setColor(UI.colors.accent[1], UI.colors.accent[2], UI.colors.accent[3], p.a)
        love.graphics.rectangle("fill", p.x, p.y, p.s, p.s)
    end

    -- Diagonal accent stripe
    love.graphics.setColor(UI.colors.accent[1], UI.colors.accent[2], UI.colors.accent[3], 0.07)
    love.graphics.polygon("fill",
        SW * 0.55, 0,
        SW,        0,
        SW,        SH,
        SW * 0.75, SH
    )

    UI.scanlines()

    if showModes then
        drawModeSelect()
    else
        drawMainNav()
    end

    -- Version tag
    love.graphics.setFont(UI.fonts.tiny)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("v0.1.0-alpha  |  Linux Build", 0, SH - 20, SW - 10, "right")

    -- FPS
    if Settings.data.showFPS then
        love.graphics.setFont(UI.fonts.tiny)
        love.graphics.setColor(UI.colors.grey)
        love.graphics.print("FPS " .. love.timer.getFPS(), 10, SH - 20)
    end
end

function drawMainNav()
    -- Logo
    UI.drawLogo(80, 60)

    -- Tagline
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("URBAN FREERUNNING  |  MULTIPLE MODES  |  LINUX EXCLUSIVE", 80, 168)

    -- Nav buttons (left sidebar)
    local btnY = 240
    for i, item in ipairs(NAV_ITEMS) do
        UI.button({
            x = 80, y = btnY,
            w = 340, h = 54,
            label = item.label,
            selected = (sel == i),
        }, mx, my)
        btnY = btnY + 66
    end

    -- Hint
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("↑↓ Navigate   ENTER / CLICK Select   ESC Back", 80, SH - 50)
end

function drawModeSelect()
    -- Back hint
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("← BACK", 80, 40)

    -- Title
    love.graphics.setFont(UI.fonts.title)
    love.graphics.setColor(UI.colors.white)
    love.graphics.print("SELECT MODE", 80, 80)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill", 80, 140, 360, 3)

    -- Mode cards
    local cardW = 360
    local totalW = cardW * 3 + 30 * 2
    local startX = (SW - totalW) / 2

    for i, card in ipairs(MODE_CARDS) do
        local cx = startX + (i - 1) * (cardW + 30)
        local cy = 180
        local hover = UI.modeCard({
            x = cx, y = cy,
            w = cardW, h = 280,
            title = card.title,
            icon  = card.icon,
            color = card.color,
            desc  = card.desc,
        }, mx, my)
        card._hover = hover
        card._x, card._y = cx, cy
        card._w, card._h = cardW, 280
    end

    -- Hint
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("Click a mode to start  |  ESC to go back", 0, SH - 50, SW, "center")
end

-- ─── Input ───────────────────────────────────────────────────────────────────

function menu.keypressed(key)
    if showModes then
        if key == "escape" or key == "backspace" then
            showModes = false
        end
        return
    end

    if key == "up"    then sel = math.max(1, sel - 1) end
    if key == "down"  then sel = math.min(#NAV_ITEMS, sel + 1) end
    if key == "return" or key == "kpenter" then
        activateNav(sel)
    end
    if key == "escape" then love.event.quit() end
end

function menu.mousemoved(x, y)
    mx, my = x, y
end

function menu.mousepressed(x, y, button)
    if button ~= 1 then return end
    mx, my = x, y

    if showModes then
        -- Check mode cards
        for _, card in ipairs(MODE_CARDS) do
            if card._x and x >= card._x and x <= card._x + card._w and
               y >= card._y and y <= card._y + card._h then
                SM.switch(card.state)
                return
            end
        end
        -- Back region
        if x >= 60 and x <= 160 and y >= 30 and y <= 60 then
            showModes = false
        end
        return
    end

    -- Check nav buttons
    local btnY = 240
    for i, _ in ipairs(NAV_ITEMS) do
        if x >= 80 and x <= 420 and y >= btnY and y <= btnY + 54 then
            sel = i
            activateNav(i)
            return
        end
        btnY = btnY + 66
    end
end

function activateNav(i)
    local item = NAV_ITEMS[i]
    if item.id == "play"       then showModes = true
    elseif item.id == "settings"   then SM.switch("settings")
    elseif item.id == "controls"   then SM.switch("controls")
    elseif item.id == "highscores" then SM.switch("highscores")
    elseif item.id == "quit"       then love.event.quit()
    end
end

return menu
