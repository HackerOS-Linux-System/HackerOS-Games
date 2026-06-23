local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")

local menu = {}
local SW, SH = 1280, 720
local t = 0
local mx, my = 0, 0
local sel = 1
local showModes = false

local NAV_ITEMS = {
    { id="play",       label="PLAY",        sub=true },
    { id="settings",   label="SETTINGS"              },
    { id="controls",   label="CONTROLS"              },
    { id="highscores", label="LEADERBOARD"            },
    { id="quit",       label="QUIT"                  },
}

local MODE_CARDS = {
    { id="time_attack", title="TIME ATTACK", icon="⏱", color={0.96,0.42,0.10,1},
      desc="Race through city rooftops. 3 levels. Beat the par time.", state="time_attack" },
    { id="hunter",      title="HUNTER MODE", icon="👁", color={0.20,0.70,1.00,1},
      desc="A relentless hunter chases you. Reach the goal before it catches you.", state="hunter" },
    { id="endless",     title="ENDLESS RUN", icon="∞", color={0.10,0.85,0.45,1},
      desc="Procedurally generated city. Survive as long as you can.", state="endless" },
}

-- Particles (ember sparks rising up)
local particles = {}
local function initParticles()
    particles = {}
    for _ = 1, 55 do
        table.insert(particles, {
            x  = ((_ * 1664525 + 1013904223) % (2^32)) % SW,
            y  = ((_ * 22695477 + 1)         % (2^32)) % SH,
            vx = (((_ * 6364136 + 1442695)   % (2^32)) % 100 - 50) * 0.008,
            vy = -((((_ * 214013 + 2531011)  % (2^32)) % 20) + 5) * 0.08,
            a  = ((_ * 1103515245 + 12345)   % 100) / 100 * 0.35 + 0.05,
            s  = (_ % 3) + 1,
        })
    end
end

-- Deterministic background buildings (no math.randomseed)
local bgBuilds = {}
local function initBg()
    bgBuilds = {}
    local s = 42
    local bx = -80
    while bx < SW + 200 do
        s = (s * 1664525 + 1013904223) % (2^32)
        local bw = s % 90 + 45
        s = (s * 1664525 + 1013904223) % (2^32)
        local bh = s % 280 + 70
        s = (s * 1664525 + 1013904223) % (2^32)
        local layer = (s % 2) + 1
        s = (s * 1664525 + 1013904223) % (2^32)
        local seed = (s % 100) / 100
        table.insert(bgBuilds, { x=bx, w=bw, h=bh, layer=layer, seed=seed })
        s = (s * 1664525 + 1013904223) % (2^32)
        bx = bx + bw + s % 18
    end
end

function menu.enter()
    UI.loadFonts()
    showModes = false
    sel = 1
    if #particles == 0 then initParticles() end
    if #bgBuilds  == 0 then initBg() end
end

function menu.update(dt)
    t = t + dt
    for _, p in ipairs(particles) do
        p.x = p.x + p.vx * dt * 60
        p.y = p.y + p.vy * dt * 60
        if p.y < -8 then
            p.y = SH + 8
            p.x = (p.x + 137) % SW
        end
    end
end

function menu.draw()
    -- Night sky
    love.graphics.setColor(0.03, 0.03, 0.06)
    love.graphics.rectangle("fill", 0, 0, SW, SH)

    -- Stars (deterministic)
    love.graphics.setColor(1, 1, 1, 0.28)
    local s = 99
    for _ = 1, 75 do
        s = (s * 1664525 + 1013904223) % (2^32)
        local sx = s % SW
        s = (s * 1664525 + 1013904223) % (2^32)
        local sy = s % math.floor(SH * 0.55)
        local ss = (_ % 8 == 0) and 2 or 1
        love.graphics.rectangle("fill", sx, sy, ss, ss)
    end

    -- Moon
    love.graphics.setColor(0.93, 0.90, 0.76, 0.88)
    love.graphics.circle("fill", SW - 105, 68, 34)
    love.graphics.setColor(0.03, 0.03, 0.06)
    love.graphics.circle("fill", SW - 93, 60, 28)

    -- Background city (layer 1: far, no parallax since menu is static)
    for _, b in ipairs(bgBuilds) do
        if b.layer == 1 then
            love.graphics.setColor(0.06, 0.06, 0.10)
            love.graphics.rectangle("fill", b.x, SH - b.h, b.w, b.h)
            -- windows
            for wr = 0, math.floor(b.h / 22) do
                for wc = 0, math.floor(b.w / 18) do
                    local ws = (wr * 13 + wc * 7 + math.floor(b.x)) % 10
                    if ws > 7 then
                        local wlit = (ws + t * 0.07 + b.seed * 8) % 10 > 2
                        if wlit then
                            love.graphics.setColor(0.92, 0.82, 0.42, 0.10)
                            love.graphics.rectangle("fill", b.x+5+wc*18, SH-b.h+8+wr*22, 8, 10)
                        end
                    end
                end
            end
        end
    end

    -- Background city (layer 2: mid)
    for _, b in ipairs(bgBuilds) do
        if b.layer == 2 then
            love.graphics.setColor(0.09, 0.10, 0.14)
            love.graphics.rectangle("fill", b.x, SH - b.h + 40, b.w, b.h - 40)
            for wr = 0, math.floor((b.h-40) / 16) do
                for wc = 0, math.floor(b.w / 14) do
                    local ws = (wr * 17 + wc * 11 + math.floor(b.x)) % 10
                    if ws > 5 then
                        local alpha = ((ws + t*0.10 + b.seed*12) % 10 > 4) and 0.20 or 0.05
                        love.graphics.setColor(0.88, 0.78, 0.38, alpha)
                        love.graphics.rectangle("fill", b.x+3+wc*14, SH-(b.h-40)+5+wr*16, 7, 9)
                    end
                end
            end
            -- Neon strip
            if b.seed > 0.70 then
                local nc = b.seed > 0.86 and {0.96,0.42,0.10} or {0.20,0.70,1.00}
                local pulse = math.sin(t * 2.2 + b.seed * 8) * 0.35 + 0.65
                love.graphics.setColor(nc[1], nc[2], nc[3], 0.55 * pulse)
                love.graphics.rectangle("fill", b.x + b.w - 3, SH-(b.h-40), 3, b.h-40)
            end
        end
    end

    -- Ground fog
    love.graphics.setColor(0.04, 0.05, 0.09, 0.65)
    love.graphics.rectangle("fill", 0, SH - 75, SW, 75)

    -- Grid
    UI.drawGrid(t)

    -- Ember particles
    for _, p in ipairs(particles) do
        love.graphics.setColor(UI.colors.accent[1], UI.colors.accent[2], UI.colors.accent[3], p.a)
        love.graphics.rectangle("fill", p.x, p.y, p.s, p.s)
    end

    -- Diagonal accent stripe
    love.graphics.setColor(UI.colors.accent[1], UI.colors.accent[2], UI.colors.accent[3], 0.05)
    love.graphics.polygon("fill", SW*0.56, 0, SW, 0, SW, SH, SW*0.76, SH)

    UI.scanlines()

    if showModes then
        drawModeSelect()
    else
        drawMainNav()
    end

    -- Version tag
    love.graphics.setFont(UI.fonts.tiny)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("v0.2.0  |  Parkour Runner", 0, SH - 20, SW - 12, "right")

    if Settings.data.showFPS then
        love.graphics.setFont(UI.fonts.tiny)
        love.graphics.setColor(UI.colors.grey)
        love.graphics.print("FPS " .. love.timer.getFPS(), 10, SH - 20)
    end
end

function drawMainNav()
    UI.drawLogo(80, 54)

    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("CITY PARKOUR  ·  3 GAME MODES  ·  DOUBLE JUMP  ·  WALL SLIDE", 80, 160)

    local btnY = 228
    for i, item in ipairs(NAV_ITEMS) do
        UI.button({
            x=80, y=btnY, w=340, h=54,
            label=item.label, selected=(sel==i),
        }, mx, my)
        item._y = btnY
        btnY = btnY + 66
    end

    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("↑↓  Navigate    ENTER / Click  Select    ESC  Quit", 80, SH - 48)
end

function drawModeSelect()
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("← BACK", 80, 36)

    love.graphics.setFont(UI.fonts.title)
    love.graphics.setColor(UI.colors.white)
    love.graphics.print("SELECT MODE", 80, 76)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill", 80, 136, 380, 3)

    local cardW  = 350
    local gap    = 28
    local totalW = cardW * 3 + gap * 2
    local startX = (SW - totalW) / 2

    for i, card in ipairs(MODE_CARDS) do
        local cx = startX + (i-1) * (cardW + gap)
        local cy = 168
        local hover = UI.modeCard({
            x=cx, y=cy, w=cardW, h=292,
            title=card.title, icon=card.icon,
            color=card.color, desc=card.desc,
        }, mx, my)
        card._hover = hover
        card._x, card._y = cx, cy
        card._w, card._h = cardW, 292
    end

    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("Click a mode to begin  ·  ESC to go back", 0, SH - 48, SW, "center")
end

-- ─── Input ────────────────────────────────────────────────────────────────────
function menu.keypressed(key)
    if showModes then
        if key == "escape" or key == "backspace" then showModes = false end
        return
    end
    if key == "up"    then sel = math.max(1, sel - 1) end
    if key == "down"  then sel = math.min(#NAV_ITEMS, sel + 1) end
    if key == "return" or key == "kpenter" then activateNav(sel) end
    if key == "escape" then love.event.quit() end
end

function menu.mousemoved(x, y) mx, my = x, y end

function menu.mousepressed(x, y, button)
    if button ~= 1 then return end
    mx, my = x, y
    if showModes then
        for _, card in ipairs(MODE_CARDS) do
            if card._x and x >= card._x and x <= card._x + card._w
               and y >= card._y and y <= card._y + card._h then
                SM.switch(card.state); return
            end
        end
        if x >= 60 and x <= 180 and y >= 22 and y <= 56 then
            showModes = false
        end
        return
    end
    local btnY = 228
    for i = 1, #NAV_ITEMS do
        if x >= 80 and x <= 420 and y >= btnY and y <= btnY + 54 then
            sel = i; activateNav(i); return
        end
        btnY = btnY + 66
    end
end

function activateNav(i)
    local item = NAV_ITEMS[i]
    if     item.id == "play"       then showModes = true
    elseif item.id == "settings"   then SM.switch("settings")
    elseif item.id == "controls"   then SM.switch("controls")
    elseif item.id == "highscores" then SM.switch("highscores")
    elseif item.id == "quit"       then love.event.quit()
    end
end

return menu
