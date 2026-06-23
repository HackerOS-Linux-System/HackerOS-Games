local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")
local Player   = require("src.player")
local TileMap  = require("src.tilemap")

local state = {}
local SW, SH = 1280, 720

-- Floor at row 13 (1-based) in 14-row maps -> y = 12*32 = 384, spawnY = 384-48 = 336
-- Hunter starts 400px to the RIGHT (not behind player) so it has to chase
local MAPS = {
    {
        name         = "Rooftop Chase",
        timeLimit    = 60,
        spawnX       = 64,  spawnY = 336,
        goalX        = 1216, goalY = 288,
        hunterStartX = 460, hunterStartY = 336,
        hunterSpeed  = 210,
        map = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,2,2,2,2,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            -- row 13 = floor (index 12, y=12*32=384)
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        }
    },
    {
        name         = "Alley Escape",
        timeLimit    = 75,
        spawnX       = 64,  spawnY = 304,
        goalX        = 1200, goalY = 64,
        hunterStartX = 500, hunterStartY = 304,
        hunterSpeed  = 230,
        map = {
            -- 13 rows, floor row 12 (index 11, y=11*32=352, spawnY=352-48=304)
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6,6,6,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0},
            {0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {1,1,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1,1,1,1,1,1},
            -- row 12 = floor (index 11, y=11*32=352)
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        }
    },
}

-- ─── AI Hunter ────────────────────────────────────────────────────────────────
local Hunter = {}
Hunter.__index = Hunter

function Hunter.new(x, y, spd)
    local self = setmetatable({}, Hunter)
    self.x, self.y   = x, y
    self.vx, self.vy = 0, 0
    self.w, self.h   = 28, 48
    self.speed       = spd or 200
    self.onGround    = false
    self.jumpCooldown = 0
    self.facingRight  = true
    self.animT        = 0
    self.trail        = {}
    return self
end

function Hunter:update(dt, tileMap, tx, ty)
    local dx = tx - self.x

    -- Chase horizontal
    if dx > 10 then
        self.vx = self.vx + (self.speed - self.vx) * math.min(1, 9*dt)
        self.facingRight = true
    elseif dx < -10 then
        self.vx = self.vx + (-self.speed - self.vx) * math.min(1, 9*dt)
        self.facingRight = false
    else
        self.vx = self.vx * (1 - 7*dt)
    end

    -- Jump to reach target
    self.jumpCooldown = math.max(0, self.jumpCooldown - dt)
    if self.onGround and ty < self.y - 30 and self.jumpCooldown <= 0 then
        self.vy = -420; self.jumpCooldown = 0.75
    end
    -- Unstick if pressed into wall while airborne
    if not self.onGround and math.abs(self.vx) < 8 and self.jumpCooldown <= 0 then
        self.vy = -380
        self.vx = dx > 0 and 280 or -280
        self.jumpCooldown = 0.5
    end

    self.vy = math.min(self.vy + 900*dt, 1200)

    -- Move X
    self.x = self.x + self.vx*dt
    if tileMap then
        for _, col in ipairs(tileMap:collideRect(self.x, self.y, self.w, self.h)) do
            if col.nx ~= 0 then self.x = self.x - col.penetration*col.nx; self.vx = 0 end
        end
    end
    -- Move Y
    self.y = self.y + self.vy*dt
    self.onGround = false
    if tileMap then
        for _, col in ipairs(tileMap:collideRect(self.x, self.y, self.w, self.h)) do
            if col.ny ~= 0 then
                self.y = self.y - col.penetration*col.ny
                if col.ny < 0 then self.onGround = true end
                self.vy = 0
            end
        end
    end

    -- Trail
    table.insert(self.trail, 1, {x=self.x, y=self.y, a=0.28})
    while #self.trail > 6 do table.remove(self.trail) end
    for _, tr in ipairs(self.trail) do tr.a = tr.a - dt*1.6 end
    self.animT = self.animT + dt
end

function Hunter:draw(camX, camY)
    local cx, cy = camX or 0, camY or 0
    -- Trail
    for i, tr in ipairs(self.trail) do
        if tr.a > 0 then
            love.graphics.setColor(0.75, 0.08, 0.08, tr.a*0.32)
            local sc = 1 - i*0.07
            love.graphics.rectangle("fill",
                tr.x-cx+(self.w*(1-sc))/2, tr.y-cy+(self.h*(1-sc))/2,
                self.w*sc, self.h*sc, 3)
        end
    end
    local sx, sy = self.x-cx, self.y-cy
    -- Glow
    local pulse = math.sin(love.timer.getTime()*6)*0.3+0.7
    love.graphics.setColor(0.8,0.06,0.06,0.18*pulse)
    love.graphics.rectangle("fill",sx-8,sy-8,self.w+16,self.h+16,10)
    -- Shadow
    love.graphics.setColor(0,0,0,0.28)
    love.graphics.ellipse("fill",sx+self.w/2,sy+self.h+3,self.w/2-2,5)
    -- Body
    love.graphics.setColor(0.58,0.07,0.07)
    love.graphics.rectangle("fill",sx,sy,self.w,self.h,5,5)
    love.graphics.setColor(0.32,0.03,0.03,0.55)
    love.graphics.rectangle("fill",sx+self.w*0.5,sy,self.w*0.5,self.h,0,5,5,0)
    -- Eyes
    love.graphics.setColor(1.0,0.88,0.10,pulse)
    love.graphics.circle("fill",sx+7,sy+14,5)
    love.graphics.circle("fill",sx+self.w-7,sy+14,5)
    love.graphics.setColor(0.15,0.03,0.03)
    love.graphics.circle("fill",sx+8,sy+14,2.5)
    love.graphics.circle("fill",sx+self.w-6,sy+14,2.5)
    -- Head
    love.graphics.setColor(0.48,0.05,0.05)
    love.graphics.rectangle("fill",sx+3,sy-2,self.w-6,16,4,4)
    -- Horns
    love.graphics.setColor(0.75,0.18,0.08)
    love.graphics.polygon("fill",sx+5,sy-1,sx+3,sy-14,sx+10,sy-1)
    love.graphics.polygon("fill",sx+self.w-5,sy-1,sx+self.w-3,sy-14,sx+self.w-10,sy-1)
end

-- ─── State vars ───────────────────────────────────────────────────────────────
local player, hunter, tileMap, camX, camY
local currentMap, mapIdx, timer
local paused, dead, won, deadTime, wonTime
local pauseOpts, t, mx, my = nil, 0, 0, 0
local dangerAlpha = 0
local particles = {}

local function dist(ax,ay,bx,by)
    local dx,dy=ax-bx,ay-by; return math.sqrt(dx*dx+dy*dy)
end
local function spawnParticles(x,y,color,count)
    for _ = 1,count do
        table.insert(particles,{x=x,y=y,vx=math.random(-70,70),vy=math.random(-130,-25),
            color=color or {1,1,1},a=1.0,size=math.random(3,7),life=math.random(30,60)/100})
    end
end

local function loadMap(idx)
    mapIdx     = idx or 1
    currentMap = MAPS[mapIdx]
    tileMap    = TileMap.new(currentMap.map, 0, 0)
    player     = Player.new(currentMap.spawnX, currentMap.spawnY)
    hunter     = Hunter.new(currentMap.hunterStartX, currentMap.hunterStartY, currentMap.hunterSpeed)
    camX,camY  = 0,0
    timer      = currentMap.timeLimit or 60
    paused=false; dead=false; won=false; t=0; dangerAlpha=0; particles={}
end

function state.enter() UI.loadFonts(); loadMap(1) end

function state.update(dt)
    t = t+dt
    tileMap:update(dt)
    for i=#particles,1,-1 do
        local p=particles[i]
        p.x=p.x+p.vx*dt; p.y=p.y+p.vy*dt
        p.vy=p.vy+300*dt; p.a=p.a-dt*2.2
        if p.a<=0 then table.remove(particles,i) end
    end
    if paused then return end
    if dead then if t-deadTime>2.0 then loadMap(mapIdx) end; return end
    if won  then
        if t-wonTime>3.2 then
            if mapIdx<#MAPS then loadMap(mapIdx+1) else SM.switch("menu") end
        end
        return
    end

    timer = timer - dt
    player:update(dt, tileMap)
    hunter:update(dt, tileMap, player.x, player.y)

    local d = dist(player.x,player.y,hunter.x,hunter.y)
    dangerAlpha = dangerAlpha + (math.max(0,1-d/360)*0.22 - dangerAlpha)*math.min(1,dt*3)

    if d < 30 then dead=true; deadTime=t; spawnParticles(player.x,player.y,{0.9,0.2,0.2},20) end
    if timer <= 0 then dead=true; deadTime=t end

    local gd = dist(player.x,player.y,currentMap.goalX,currentMap.goalY)
    if gd < 50 then won=true; wonTime=t; spawnParticles(player.x,player.y,{0.10,0.85,0.45},26) end

    local tx2 = math.max(0, math.min(player.x-SW/2, tileMap:pixelWidth()-SW))
    local ty2 = math.max(0, math.min(player.y-SH*0.52, tileMap:pixelHeight()-SH))
    camX = camX+(tx2-camX)*0.11; camY = camY+(ty2-camY)*0.11
end

function state.draw()
    love.graphics.setColor(0.03,0.03,0.07); love.graphics.rectangle("fill",0,0,SW,SH)
    -- stars (deterministic)
    love.graphics.setColor(1,1,1,0.28)
    local s=currentMap.bgSeed or 11
    for _ = 1,50 do
        s=(s*1664525+1013904223)%(2^32)
        local sx2=s%SW; s=(s*1664525+1013904223)%(2^32)
        local sy2=s%math.floor(SH*0.5)
        love.graphics.rectangle("fill",sx2,sy2,1,1)
    end
    if dangerAlpha>0.01 then
        love.graphics.setColor(0.60,0.04,0.04,dangerAlpha)
        love.graphics.rectangle("fill",0,0,SW,SH)
    end
    tileMap:drawBackground(camX,camY,SW,SH,1)
    tileMap:drawBackground(camX,camY,SW,SH,2)
    love.graphics.setColor(0.04,0.05,0.09,0.5)
    love.graphics.rectangle("fill",0,SH-60,SW,60)
    tileMap:draw(camX,camY,SW,SH)
    for _,p in ipairs(particles) do
        love.graphics.setColor(p.color[1],p.color[2],p.color[3],p.a)
        love.graphics.rectangle("fill",p.x-camX-p.size/2,p.y-camY-p.size/2,p.size,p.size,1)
    end
    -- Goal
    local gsx=currentMap.goalX-camX; local gsy=currentMap.goalY-camY
    local gp=math.sin(t*4)*0.4+0.6
    love.graphics.setColor(0.10,0.85,0.45,0.16*gp); love.graphics.circle("fill",gsx,gsy,38+gp*5)
    love.graphics.setColor(0.10,0.85,0.45,0.68*gp)
    love.graphics.setLineWidth(3); love.graphics.circle("line",gsx,gsy,22); love.graphics.setLineWidth(1)
    love.graphics.setColor(0.10,0.85,0.45,0.9); love.graphics.circle("fill",gsx,gsy,10)
    love.graphics.setFont(UI.fonts.small); love.graphics.setColor(1,1,1,0.9)
    love.graphics.printf("GOAL",gsx-30,gsy-8,60,"center")
    hunter:draw(camX,camY); player:draw(camX,camY)
    drawHUD()
    if paused then drawPause() end
    if dead and not paused then
        love.graphics.setColor(0.65,0.04,0.04,math.min(0.62,(t-deadTime)*0.45))
        love.graphics.rectangle("fill",0,0,SW,SH)
        love.graphics.setFont(UI.fonts.title); love.graphics.setColor(1,1,1)
        love.graphics.printf("CAUGHT!",0,SH/2-50,SW,"center")
        love.graphics.setFont(UI.fonts.body); love.graphics.setColor(UI.colors.grey)
        love.graphics.printf("Restarting...",0,SH/2+20,SW,"center")
    end
    if won then
        love.graphics.setColor(0,0.32,0.16,0.52); love.graphics.rectangle("fill",0,0,SW,SH)
        love.graphics.setFont(UI.fonts.huge); love.graphics.setColor(UI.colors.success)
        love.graphics.printf("ESCAPED!",0,SH/2-80,SW,"center")
        love.graphics.setFont(UI.fonts.body); love.graphics.setColor(UI.colors.white)
        love.graphics.printf("Time left: "..string.format("%.1f",math.max(0,timer)).."s",0,SH/2+10,SW,"center")
    end
end

function drawHUD()
    love.graphics.setColor(0,0,0,0.72); love.graphics.rectangle("fill",0,0,SW,46)
    love.graphics.setColor(0.20,0.70,1.00); love.graphics.rectangle("fill",0,44,SW,2)
    love.graphics.setColor(0.20,0.70,1.00); love.graphics.rectangle("fill",0,0,4,46)
    love.graphics.setFont(UI.fonts.heading)
    love.graphics.setColor(timer<10 and UI.colors.danger or UI.colors.white)
    love.graphics.printf(string.format("%.1f",math.max(0,timer)),0,10,SW,"center")
    love.graphics.setFont(UI.fonts.small); love.graphics.setColor(UI.colors.grey)
    love.graphics.print("HUNTER  |  "..(currentMap.name or "").."  ["..mapIdx.."/"..#MAPS.."]",14,15)
    love.graphics.setColor(0.20,0.70,1.00)
    love.graphics.printf("FLEE TO GOAL!",SW-180,15,160,"right")
    local d=dist(player.x,player.y,hunter.x,hunter.y)
    local prox=math.max(0,math.min(1,1-d/380))
    love.graphics.setColor(UI.colors.darkgrey); love.graphics.rectangle("fill",14,SH-20,180,6,3)
    love.graphics.setColor(prox>0.7 and UI.colors.danger or {0.8,0.5,0.1,1})
    love.graphics.rectangle("fill",14,SH-20,180*prox,6,3)
    love.graphics.setFont(UI.fonts.tiny); love.graphics.setColor(UI.colors.grey)
    love.graphics.print("PROXIMITY",200,SH-22)
    if d<180 then
        local wa=math.sin(t*8)*0.5+0.5
        love.graphics.setFont(UI.fonts.small); love.graphics.setColor(0.95,0.12,0.12,wa)
        love.graphics.printf("⚠  HUNTER CLOSE  ⚠",0,54,SW,"center")
    end
    if t<6 then
        local alpha=math.min(1,(6-t)*0.7)
        love.graphics.setFont(UI.fonts.tiny); love.graphics.setColor(0.6,0.6,0.65,alpha)
        love.graphics.printf("A/D  Move    SPACE  Jump    LSHIFT  Slide    ESC  Pause",0,SH-38,SW,"center")
    end
end

function drawPause()
    love.graphics.setColor(0,0,0,0.70); love.graphics.rectangle("fill",0,0,SW,SH)
    love.graphics.setColor(0.07,0.07,0.10,0.95)
    love.graphics.rectangle("fill",SW/2-200,200,400,320,8,8)
    love.graphics.setColor(0.20,0.70,1.00)
    love.graphics.rectangle("fill",SW/2-200,200,400,4,4,4)
    love.graphics.setFont(UI.fonts.title); love.graphics.setColor(UI.colors.white)
    love.graphics.printf("PAUSED",0,218,SW,"center")
    local opts={
        {label="RESUME",    action=function() paused=false end},
        {label="RESTART",   action=function() loadMap(mapIdx) end},
        {label="MAIN MENU", action=function() SM.switch("menu") end},
    }
    for i,opt in ipairs(opts) do
        UI.button({x=SW/2-160,y=296+i*66,w=320,h=54,label=opt.label},mx,my)
        opt._y=296+i*66
    end
    pauseOpts=opts
end

function state.keypressed(key)
    local kb=Settings.data.keybinds
    if key==(kb.pause or "escape") or key=="escape" then
        if dead or won then SM.switch("menu") return end
        paused=not paused
    end
    if key==(kb.jump or "space") and not paused and not dead and not won then player:onJump() end
end
function state.mousemoved(x,y) mx,my=x,y end
function state.mousepressed(x,y,button)
    if button~=1 then return end
    if paused and pauseOpts then
        for _,opt in ipairs(pauseOpts) do
            if opt._y and x>=SW/2-160 and x<=SW/2+160 and y>=opt._y and y<=opt._y+54 then opt.action() end
        end
    end
end

return state
