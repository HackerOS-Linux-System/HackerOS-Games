local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")
local Player   = require("src.player")
local TileMap  = require("src.tilemap")

local state = {}
local SW, SH = 1280, 720

-- TILE=32. Floor at row 14 (1-based) = (14-1)*32 = 416. spawnY = 416-48 = 368
-- But we must verify per-map. Rule: spawnY = (floorRow-1)*32 - playerH
-- Level 1 floor: row 14 (last solid strip, 1-based) -> y=(13)*32=416, spawnY=416-48=368
-- Level 2 floor: row 12 -> y=(11)*32=352, spawnY=352-48=304
-- Level 3 floor: row 13 -> y=(12)*32=384, spawnY=384-48=336

local LEVELS = {
    -- LEVEL 1: Urban Sprint
    {
        name   = "Urban Sprint",
        par    = 35,
        spawnX = 64, spawnY = 368,
        map = {
            -- 16 rows x 40 cols
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,2,2,2,2,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,2,2,2,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            -- row 14: main ground (index 13, zero-based 13 -> y=13*32=416)
            {1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,0,0,3,3,0,0,1,1,1,1,0,0,0,0,1,1,1,0,0,0,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        }
    },
    -- LEVEL 2: Neon District
    {
        name   = "Neon District",
        par    = 45,
        spawnX = 64, spawnY = 304,
        map = {
            -- 14 rows x 44 cols  (floor at row 12, y=(11)*32=352, spawnY=352-48=304)
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,2,2,2,2,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            -- row 12: floor (index 11, y=11*32=352)
            {1,1,1,1,1,0,0,0,1,1,1,1,0,0,3,3,0,1,1,1,1,0,0,0,0,1,1,1,5,5,5,1,0,0,0,1,1,0,0,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        }
    },
    -- LEVEL 3: Rooftop Gauntlet
    {
        name   = "Rooftop Gauntlet",
        par    = 60,
        spawnX = 64, spawnY = 336,
        map = {
            -- 15 rows x 48 cols  (floor row 13, y=12*32=384, spawnY=384-48=336)
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            -- row 13: floor (index 12, y=12*32=384)
            {1,1,1,1,1,0,0,0,1,1,1,0,0,3,3,1,1,1,0,0,0,1,1,1,1,0,0,3,0,1,1,1,5,5,1,0,0,0,0,1,1,1,0,0,3,3,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        }
    },
}

-- ─── State vars ───────────────────────────────────────────────────────────────
local player, tileMap, camX, camY
local timer, finished, dead, deadTime
local levelIdx, currentLevel
local flashMsg, flashTimer
local paused, pauseOpts
local checkpointX, checkpointY
local t, mx, my = 0, 0, 0
local particles = {}

local function spawnParticles(x, y, color, count)
    for _ = 1, count do
        table.insert(particles, {
            x=x, y=y,
            vx=math.random(-60,60), vy=math.random(-120,-20),
            color=color or {1,1,1}, a=1.0,
            size=math.random(2,6), life=math.random(25,55)/100,
        })
    end
end

local function updateParticles(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx*dt; p.y = p.y + p.vy*dt
        p.vy = p.vy + 300*dt; p.a = p.a - dt/p.life
        if p.a <= 0 then table.remove(particles, i) end
    end
end

local function drawParticles(cx, cy)
    for _, p in ipairs(particles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.a)
        love.graphics.rectangle("fill", p.x-cx-p.size/2, p.y-cy-p.size/2, p.size, p.size, 1)
    end
end

local function updateCamera()
    local tx = player.x - SW/2
    local ty = player.y - SH*0.55
    local mw = tileMap:pixelWidth()
    local mh = tileMap:pixelHeight()
    tx = math.max(0, math.min(tx, mw - SW))
    ty = math.max(0, math.min(ty, mh - SH))
    camX = camX + (tx - camX) * 0.10
    camY = camY + (ty - camY) * 0.10
end

local function loadLevel(idx)
    levelIdx     = idx or 1
    currentLevel = LEVELS[levelIdx]
    tileMap      = TileMap.new(currentLevel.map, 0, 0)
    player       = Player.new(currentLevel.spawnX, currentLevel.spawnY)
    camX, camY   = 0, 0
    timer        = 0; finished = false; dead = false
    paused       = false; pauseOpts = nil
    flashMsg     = nil; flashTimer = 0; deadTime = 0
    checkpointX  = currentLevel.spawnX
    checkpointY  = currentLevel.spawnY
    particles    = {}; t = 0
end

function state.enter() UI.loadFonts(); loadLevel(1) end

function state.update(dt)
    t = t + dt
    tileMap:update(dt)
    updateParticles(dt)
    if flashTimer > 0 then flashTimer = flashTimer - dt end
    if paused then return end

    if dead then
        if t - deadTime > 1.8 then
            player = Player.new(checkpointX, checkpointY)
            dead   = false
        end
        return
    end
    if finished then return end

    timer = timer + dt
    player:update(dt, tileMap)

    local px, py, pw, ph = player:getRect()
    local mx2 = px + pw/2
    local bot  = py + ph

    if tileMap:isLethal(mx2, bot-2) or tileMap:isLethal(mx2, py+4) then
        dead=true; deadTime=t; flashMsg="SPIKED!"; flashTimer=1.8
        spawnParticles(player.x, player.y, {0.9,0.2,0.2}, 16)
    end
    if not player.alive then
        dead=true; deadTime=t; flashMsg="FELL!"; flashTimer=1.8
    end
    if tileMap:isCheckpoint(mx2, bot-4) then
        if checkpointX ~= player.x then
            checkpointX=player.x; checkpointY=player.y
            flashMsg="CHECKPOINT!"; flashTimer=1.2
            spawnParticles(player.x, player.y, {0.20,0.70,1.00}, 12)
        end
    end
    if tileMap:isFinish(mx2, bot-4) then
        finished=true; flashMsg="FINISH!"; flashTimer=5
        spawnParticles(player.x, player.y, {0.10,0.85,0.45}, 24)
        Settings.addHighscore("time_attack",{
            name=Settings.data.playerName,
            score=math.floor(timer*100)/100,
            date=os.date("%Y-%m-%d"),
        })
    end
    updateCamera()
end

function state.draw()
    -- Sky
    love.graphics.setColor(0.03, 0.03, 0.06)
    love.graphics.rectangle("fill", 0, 0, SW, SH)
    -- Stars (deterministic, no randomseed)
    love.graphics.setColor(1,1,1,0.35)
    local s = 99
    for _ = 1, 70 do
        s = (s*1664525+1013904223)%(2^32)
        local sx = s % SW
        s = (s*1664525+1013904223)%(2^32)
        local sy = s % math.floor(SH*0.55)
        love.graphics.rectangle("fill", sx, sy, 1, 1)
    end
    -- Moon
    love.graphics.setColor(0.94,0.91,0.78,0.88)
    love.graphics.circle("fill", SW-110, 72, 34)
    love.graphics.setColor(0.03,0.03,0.06)
    love.graphics.circle("fill", SW-98, 64, 28)
    -- Parallax city
    tileMap:drawBackground(camX, camY, SW, SH, 1)
    tileMap:drawBackground(camX, camY, SW, SH, 2)
    -- Ground fog
    love.graphics.setColor(0.04,0.05,0.09,0.5)
    love.graphics.rectangle("fill", 0, SH-70, SW, 70)
    -- Map + player
    tileMap:draw(camX, camY, SW, SH)
    drawParticles(camX, camY)
    player:draw(camX, camY)
    drawHUD()
    if paused then drawPause() end
    if flashTimer > 0 and flashMsg then UI.flash(flashMsg, math.min(1, flashTimer*1.5)) end
    if dead then
        love.graphics.setColor(0.6,0.08,0.08, math.min(0.55,(t-deadTime)*0.5))
        love.graphics.rectangle("fill",0,0,SW,SH)
        love.graphics.setFont(UI.fonts.title); love.graphics.setColor(1,1,1)
        love.graphics.printf("DEAD",0,SH/2-50,SW,"center")
        love.graphics.setFont(UI.fonts.body); love.graphics.setColor(UI.colors.grey)
        love.graphics.printf("Respawning at checkpoint...",0,SH/2+10,SW,"center")
    end
    if finished then
        love.graphics.setColor(0,0.28,0.14,0.55)
        love.graphics.rectangle("fill",0,0,SW,SH)
        love.graphics.setFont(UI.fonts.huge); love.graphics.setColor(UI.colors.success)
        love.graphics.printf("FINISH!",0,SH/2-80,SW,"center")
        love.graphics.setFont(UI.fonts.heading); love.graphics.setColor(UI.colors.white)
        love.graphics.printf("Time: "..UI.fmt_time(timer),0,SH/2+10,SW,"center")
        local par = currentLevel.par or 999
        local dc = timer <= par and UI.colors.success or UI.colors.danger
        love.graphics.setColor(dc)
        local diff2 = math.abs(timer-par)
        local pstr = timer<=par and ("PAR BEATEN by "..UI.fmt_time(diff2)) or ("PAR missed by "..UI.fmt_time(diff2))
        love.graphics.printf(pstr,0,SH/2+56,SW,"center")
        love.graphics.setFont(UI.fonts.small); love.graphics.setColor(UI.colors.grey)
        local hint = levelIdx < #LEVELS
            and "N  Next level    R  Retry    ESC  Menu"
            or  "All levels done!    R  Retry    ESC  Menu"
        love.graphics.printf(hint,0,SH/2+106,SW,"center")
    end
end

function drawHUD()
    love.graphics.setColor(0,0,0,0.72)
    love.graphics.rectangle("fill",0,0,SW,46)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill",0,44,SW,2)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill",0,0,4,46)
    love.graphics.setFont(UI.fonts.heading)
    local tc = (timer > (currentLevel.par or 999)) and UI.colors.danger or UI.colors.white
    love.graphics.setColor(tc)
    love.graphics.printf(UI.fmt_time(timer),0,10,SW,"center")
    love.graphics.setFont(UI.fonts.small); love.graphics.setColor(UI.colors.grey)
    love.graphics.print("TIME ATTACK  |  "..(currentLevel.name or "").."  ["..levelIdx.."/"..#LEVELS.."]",14,15)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.printf("PAR "..UI.fmt_time(currentLevel.par),SW-180,15,160,"right")
    if Settings.data.showFPS then
        love.graphics.setFont(UI.fonts.tiny); love.graphics.setColor(UI.colors.grey)
        love.graphics.print("FPS "..love.timer.getFPS(),14,SH-18)
    end
    if t < 8 then
        local alpha = math.min(1,(8-t)*0.55)
        love.graphics.setFont(UI.fonts.tiny); love.graphics.setColor(0.6,0.6,0.65,alpha)
        love.graphics.printf("A/D  Move    SPACE  Jump (x2)    LSHIFT  Slide    ESC  Pause",0,SH-28,SW,"center")
    end
    player:drawHUD()
end

function drawPause()
    love.graphics.setColor(0,0,0,0.70); love.graphics.rectangle("fill",0,0,SW,SH)
    love.graphics.setColor(0.07,0.07,0.10,0.95)
    love.graphics.rectangle("fill",SW/2-200,200,400,320,8,8)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill",SW/2-200,200,400,4,4,4)
    love.graphics.setFont(UI.fonts.title); love.graphics.setColor(UI.colors.white)
    love.graphics.printf("PAUSED",0,218,SW,"center")
    local opts = {
        {label="RESUME",    action=function() paused=false end},
        {label="RESTART",   action=function() loadLevel(levelIdx) end},
        {label="MAIN MENU", action=function() SM.switch("menu") end},
    }
    for i,opt in ipairs(opts) do
        UI.button({x=SW/2-160,y=296+i*66,w=320,h=54,label=opt.label},mx,my)
        opt._y = 296+i*66
    end
    pauseOpts = opts
end

function state.keypressed(key)
    local kb = Settings.data.keybinds
    if key==(kb.pause or "escape") or key=="escape" then
        if finished or dead then SM.switch("menu") return end
        paused = not paused
    end
    if key==(kb.jump or "space") and not paused and not dead and not finished then player:onJump() end
    if key=="r" then loadLevel(levelIdx) end
    if key=="n" and finished and levelIdx<#LEVELS then loadLevel(levelIdx+1) end
end

function state.mousemoved(x,y) mx,my=x,y end
function state.mousepressed(x,y,button)
    if button~=1 then return end
    if paused and pauseOpts then
        for _,opt in ipairs(pauseOpts) do
            if opt._y and x>=SW/2-160 and x<=SW/2+160 and y>=opt._y and y<=opt._y+54 then
                opt.action(); return
            end
        end
    end
end

return state
