local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")
local Player   = require("src.player")

local state = {}
local SW, SH = 1280, 720
local TILE   = 32

local DIFFICULTY = {
    easy   = { speed=220, gapMin=1, gapMax=3, spikeChance=0.06, bounceChance=0.05 },
    normal = { speed=285, gapMin=2, gapMax=4, spikeChance=0.13, bounceChance=0.07 },
    hard   = { speed=360, gapMin=2, gapMax=5, spikeChance=0.22, bounceChance=0.05 },
}

-- GROUND_Y: the Y world coordinate of the top of the ground row
-- Player spawns above it: spawnY = GROUND_Y - player.h
local GROUND_Y   = 448   -- top of ground tiles in world coords
local SEG_ROWS   = 5     -- how many tile rows per segment (ground + 4 below)
local PLAYER_SCREEN_X = 220  -- fixed screen X where player appears

local segments   = {}
local player
local worldOffX  = 0     -- how far the world has scrolled (increases with speed)
local speed, baseSpeed
local score      = 0
local dead       = false
local paused     = false
local pauseOpts  = nil
local deadTime   = 0
local t          = 0
local mx, my     = 0, 0
local nextSegX   = 0
local diff

local particles = {}
local function spawnParticles(x, y, color, count)
    for _ = 1, count do
        table.insert(particles, {
            x=x, y=y, vx=math.random(-60,60), vy=math.random(-120,-20),
            color=color or {1,1,1}, a=1.0,
            size=math.random(2,5), life=math.random(25,55)/100,
        })
    end
end

-- Deterministic tile colour
local function tileColor(tt)
    if tt==1 then return {0.20,0.22,0.28}
    elseif tt==2 then return {0.15,0.45,0.28}
    elseif tt==3 then return {0.80,0.15,0.15}
    elseif tt==4 then return {0.90,0.60,0.15}
    end
    return {0.5,0.5,0.5}
end

-- Build one segment starting at worldX
local function buildSegment(worldX)
    local seg = {x=worldX, pixy=GROUND_Y, cols={}, buildingH={}}
    local W   = math.random(10, 20)
    seg.w = W * TILE

    local r = math.random()
    if r < 0.30 then
        -- Flat + optional spikes/bounces
        for col = 1, W do
            seg.cols[col] = {}
            for row = 1, SEG_ROWS do
                if row == 1 then
                    local rv = math.random()
                    if col>=2 and col<=W-1 and rv < diff.spikeChance then
                        seg.cols[col][row] = 3
                    elseif col>=2 and col<=W-1 and rv < diff.spikeChance+diff.bounceChance then
                        seg.cols[col][row] = 4
                    else
                        seg.cols[col][row] = 1
                    end
                else
                    seg.cols[col][row] = 1
                end
            end
        end
    elseif r < 0.55 then
        -- Gap
        local gapLen   = math.random(diff.gapMin, diff.gapMax)
        local gapStart = math.random(3, math.max(3, W-gapLen-2))
        for col = 1, W do
            seg.cols[col] = {}
            local isGap = col>=gapStart and col<gapStart+gapLen
            for row = 1, SEG_ROWS do seg.cols[col][row] = isGap and 0 or 1 end
        end
    elseif r < 0.70 then
        -- Gap + floating platform above
        local gapLen   = math.random(diff.gapMin, diff.gapMax)
        local gapStart = math.random(3, math.max(3, W-gapLen-2))
        for col = 1, W do
            seg.cols[col] = {}
            local isGap = col>=gapStart and col<gapStart+gapLen
            for row = 1, SEG_ROWS do seg.cols[col][row] = isGap and 0 or 1 end
        end
        local pfStart = math.max(1, gapStart-1)
        local pfEnd   = math.min(W, gapStart+gapLen)
        local pfRow   = math.random(3, 4)
        for col = pfStart, pfEnd do
            if seg.cols[col] then seg.cols[col][pfRow] = 2 end
        end
    elseif r < 0.82 then
        -- Staircase
        for col = 1, W do
            seg.cols[col] = {}
            local groundRow = math.max(1, SEG_ROWS - math.floor((col/W)*2))
            for row = 1, SEG_ROWS do seg.cols[col][row] = (row>=groundRow) and 1 or 0 end
        end
    else
        -- Solid safe
        for col = 1, W do
            seg.cols[col] = {}
            for row = 1, SEG_ROWS do seg.cols[col][row] = 1 end
            if math.random()<diff.spikeChance*0.4 and col>1 and col<W then
                seg.cols[col][1] = 3
            end
        end
    end

    -- Background building heights for this segment (for drawing only)
    for col = 1, W do
        seg.buildingH[col] = math.floor(((col*7919+worldX*31)%200)+60)
    end

    return seg
end

local function generateUntil(targetX)
    while nextSegX < targetX do
        local seg = buildSegment(nextSegX)
        table.insert(segments, seg)
        nextSegX = nextSegX + seg.w
    end
end

-- Collision against infinite segments (world coords)
local function segCollide(px, py, pw, ph)
    local cols = {}
    for _, seg in ipairs(segments) do
        if px+pw > seg.x and px < seg.x+seg.w then
            for col = 1, #seg.cols do
                local tx = seg.x + (col-1)*TILE
                if tx+TILE>px and tx<px+pw then
                    for row = 1, SEG_ROWS do
                        local tt = seg.cols[col] and seg.cols[col][row] or 0
                        if tt >= 1 then
                            local ty = seg.pixy + (row-1)*TILE
                            if ty+TILE>py and ty<py+ph then
                                local ox2=math.min(px+pw,tx+TILE)-math.max(px,tx)
                                local oy2=math.min(py+ph,ty+TILE)-math.max(py,ty)
                                if ox2>0 and oy2>0 then
                                    local nx,ny,pen
                                    if ox2<oy2 then
                                        pen=ox2; nx=(px+pw/2<tx+TILE/2)and -1 or 1; ny=0
                                    else
                                        pen=oy2; nx=0; ny=(py+ph/2<ty+TILE/2)and -1 or 1
                                    end
                                    local lethal=(tt==3)
                                    local bounce=(tt==4 and ny==1)
                                    if tt==2 and ny~=1 then
                                        -- one-way: skip
                                    elseif bounce then
                                        table.insert(cols,{nx=0,ny=1,penetration=pen,bounce=true})
                                    else
                                        table.insert(cols,{nx=nx,ny=ny,penetration=pen,lethal=lethal})
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return cols
end

-- Patched move: uses segCollide instead of tilemap
local function patchedMove(pl, dt)
    pl.x = pl.x + pl.vx*dt
    local cols = segCollide(pl.x, pl.y, pl.w, pl.h)
    pl.onWall = 0
    for _, col in ipairs(cols) do
        if col.nx~=0 then
            pl.x = pl.x - col.penetration*col.nx
            if pl.vx*col.nx>0 then pl.onWall=col.nx; pl.vx=0 end
        end
        if col.lethal then pl.alive=false end
    end
    pl.y = pl.y + pl.vy*dt
    pl.onGround = false
    cols = segCollide(pl.x, pl.y, pl.w, pl.h)
    for _, col in ipairs(cols) do
        if col.ny~=0 then
            pl.y = pl.y - col.penetration*col.ny
            if col.ny<0 then pl.onGround=true end
            if col.bounce then pl.vy=-520 else pl.vy=0 end
        end
        if col.lethal then pl.alive=false end
    end
end

local function loadGame()
    local diffKey = Settings.data.difficulty or "normal"
    diff      = DIFFICULTY[diffKey]
    speed     = diff.speed
    baseSpeed = diff.speed
    segments  = {}
    nextSegX  = 0
    worldOffX = 0
    particles = {}

    -- Generate enough ahead
    generateUntil(SW * 4)

    -- Player world position: PLAYER_SCREEN_X + worldOffX = world x at start
    -- So player.x = PLAYER_SCREEN_X (world=screen at start when worldOffX=0)
    player = Player.new(PLAYER_SCREEN_X, GROUND_Y - 48)
    player.move = patchedMove

    score=0; dead=false; paused=false; deadTime=0; t=0
end

function state.enter() UI.loadFonts(); loadGame() end

function state.update(dt)
    t = t+dt
    for i=#particles,1,-1 do
        local p=particles[i]
        p.x=p.x+p.vx*dt; p.y=p.y+p.vy*dt
        p.vy=p.vy+280*dt; p.a=p.a-dt*2
        if p.a<=0 then table.remove(particles,i) end
    end
    if paused then return end
    if dead then
        if t-deadTime>2.8 then
            Settings.addHighscore("endless",{
                name=Settings.data.playerName,
                score=math.floor(score),
                date=os.date("%Y-%m-%d"),
            })
            SM.switch("menu")
        end
        return
    end

    speed = math.min(baseSpeed + score*0.07, 720)
    worldOffX = worldOffX + speed*dt
    score     = score + speed*dt*0.011

    -- KEY FIX: patch move, then call full player:update(dt, nil)
    -- player.move is already patched, nil tilemap means move() uses segCollide
    player.move = patchedMove
    player:update(dt, nil)

    -- Keep player from drifting too far right on screen
    -- world x of player's screen position = player.x - worldOffX + (worldOffX at start)
    -- screen x = player.x - worldOffX + worldOffX_initial... simpler:
    -- screenX = player.x - (worldOffX - PLAYER_SCREEN_X_initial)
    -- At start worldOffX=0, player.x=PLAYER_SCREEN_X, so screenX=PLAYER_SCREEN_X. Good.
    -- As world scrolls: screenX = player.x - worldOffX + PLAYER_SCREEN_X... no.
    -- Camera offset = worldOffX - PLAYER_SCREEN_X, so screenX = player.x - camOffset
    local camOff = worldOffX - PLAYER_SCREEN_X
    local screenX = player.x - camOff
    -- Cap screen position so player doesn't run off right
    if screenX > PLAYER_SCREEN_X + 80 then
        player.x = player.x - (screenX - (PLAYER_SCREEN_X+80))
    end
    -- Kill if off left edge
    if screenX < -80 then player.alive = false end

    if not player.alive or player.y > GROUND_Y + 600 then
        if not dead then
            dead=true; deadTime=t
            spawnParticles(player.x, player.y, {0.9,0.2,0.2}, 20)
        end
    end

    local camOff2 = worldOffX - PLAYER_SCREEN_X
    generateUntil(camOff2 + SW*3)
    -- Cull
    while #segments>0 and (segments[1].x + segments[1].w) < (camOff2 - SW) do
        table.remove(segments, 1)
    end
end

function state.draw()
    love.graphics.setColor(0.03,0.03,0.06)
    love.graphics.rectangle("fill",0,0,SW,SH)

    local camOff = worldOffX - PLAYER_SCREEN_X

    -- Stars (deterministic)
    love.graphics.setColor(1,1,1,0.32)
    local s=77
    for _ = 1,55 do
        s=(s*1664525+1013904223)%(2^32); local sx2=s%SW
        s=(s*1664525+1013904223)%(2^32); local sy2=s%math.floor(SH*0.52)
        love.graphics.rectangle("fill",sx2,sy2,1,1)
    end

    -- Background buildings layer 1 (far, parallax 0.12)
    local par1 = camOff * 0.12
    love.graphics.setColor(0.06,0.06,0.10)
    local bseed = 55
    local bx2 = -((par1)%220)-220
    while bx2 < SW+220 do
        bseed=(bseed*1664525+1013904223)%(2^32)
        local bw=(bseed%80)+50
        bseed=(bseed*1664525+1013904223)%(2^32)
        local bh=(bseed%220)+80
        love.graphics.rectangle("fill",bx2,SH-bh,bw,bh)
        bx2 = bx2+bw+(bseed%25)
    end

    -- Background buildings layer 2 (mid, parallax 0.35)
    local par2 = camOff * 0.35
    love.graphics.setColor(0.09,0.10,0.14)
    bseed=33
    bx2 = -((par2)%160)-160
    while bx2 < SW+160 do
        bseed=(bseed*1664525+1013904223)%(2^32)
        local bw=(bseed%60)+40
        bseed=(bseed*1664525+1013904223)%(2^32)
        local bh=(bseed%140)+50
        love.graphics.rectangle("fill",bx2,SH-bh+20,bw,bh-20)
        -- windows
        love.graphics.setColor(0.88,0.78,0.38,0.14)
        for wr=0,math.floor((bh-20)/15) do
            for wc=0,math.floor(bw/13) do
                local ws=(wr*17+wc*11+math.floor(bx2+par2))%10
                if ws>5 then love.graphics.rectangle("fill",bx2+3+wc*13,SH-(bh-20)+4+wr*15,6,8) end
            end
        end
        love.graphics.setColor(0.09,0.10,0.14)
        bx2 = bx2+bw+(bseed%20)
    end

    -- Speed lines
    local speedRatio = math.min(1.0,(speed-baseSpeed)/(720-baseSpeed))
    if speedRatio>0.05 then
        love.graphics.setColor(0.96,0.42,0.10,speedRatio*0.22)
        local ls=math.floor(t*30)%10000
        for i=1,math.floor(speedRatio*16) do
            ls=(ls*1664525+1013904223)%(2^32)
            local ly=ls%SH; ls=(ls*1664525+1013904223)%(2^32)
            local lx=ls%SW; ls=(ls*1664525+1013904223)%(2^32)
            local ll=(ls%120+40)*speedRatio
            love.graphics.setLineWidth(1)
            love.graphics.line(lx,ly,lx+ll,ly)
        end
        love.graphics.setLineWidth(1)
    end

    -- Draw segments
    for _, seg in ipairs(segments) do
        local segSX = seg.x - camOff  -- segment's screen X

        -- Background buildings behind segment
        for col = 1, #seg.buildingH do
            local bsx = segSX + (col-1)*TILE
            if bsx+TILE>-10 and bsx<SW+10 then
                local bh = seg.buildingH[col] or 80
                love.graphics.setColor(0.10,0.11,0.16)
                love.graphics.rectangle("fill",bsx,seg.pixy-bh,TILE,bh)
                local ws=(col*11+(seg.x//TILE)*7)%10
                if ws>5 then
                    love.graphics.setColor(0.88,0.78,0.38,0.15)
                    love.graphics.rectangle("fill",bsx+3,seg.pixy-bh+5,TILE-6,8)
                    if bh>50 then
                        love.graphics.rectangle("fill",bsx+3,seg.pixy-bh+22,TILE-6,8)
                    end
                end
            end
        end

        -- Tiles
        for col = 1, #seg.cols do
            local tx = segSX + (col-1)*TILE
            if tx+TILE>0 and tx<SW then
                for row = 1, SEG_ROWS do
                    local tt = seg.cols[col] and seg.cols[col][row] or 0
                    if tt~=0 then
                        local ty = seg.pixy + (row-1)*TILE
                        local prevRowAir = row<=1 or (seg.cols[col][row-1] or 0)==0

                        if tt==1 then
                            local shade=0.20+((col*7919+row*6271)%100)/100*0.07
                            love.graphics.setColor(shade,shade+0.02,shade+0.06)
                            love.graphics.rectangle("fill",tx,ty,TILE,TILE)
                            love.graphics.setColor(0.11,0.12,0.16,0.75)
                            love.graphics.rectangle("fill",tx,ty+TILE/2-1,TILE,2)
                            if prevRowAir then
                                love.graphics.setColor(0.30,0.32,0.38)
                                love.graphics.rectangle("fill",tx,ty,TILE,5)
                                love.graphics.setColor(0.44,0.46,0.54)
                                love.graphics.line(tx,ty,tx+TILE,ty)
                            else
                                love.graphics.setColor(1,1,1,0.04)
                                love.graphics.line(tx,ty,tx+TILE,ty)
                            end
                        elseif tt==2 then
                            love.graphics.setColor(0.18,0.48,0.28)
                            love.graphics.rectangle("fill",tx,ty+TILE-10,TILE,10)
                            love.graphics.setColor(0.28,0.62,0.38)
                            love.graphics.line(tx,ty+TILE-10,tx+TILE,ty+TILE-10)
                            love.graphics.setColor(0.13,0.38,0.22,0.65)
                            for gi=0,3 do love.graphics.line(tx+gi*8+4,ty+TILE-9,tx+gi*8+4,ty+TILE-1) end
                        elseif tt==3 then
                            love.graphics.setColor(0.16,0.18,0.23)
                            love.graphics.rectangle("fill",tx,ty+TILE-8,TILE,8)
                            love.graphics.setColor(0.75,0.14,0.14)
                            for si=0,3 do
                                local sx2=tx+si*8+4
                                love.graphics.polygon("fill",sx2-3,ty+TILE,sx2+3,ty+TILE,sx2,ty+5)
                            end
                            love.graphics.setColor(1,0.45,0.45,0.45)
                            for si=0,3 do love.graphics.line(tx+si*8+4,ty+5,tx+si*8+6,ty+TILE-3) end
                        elseif tt==4 then
                            love.graphics.setColor(0.85,0.55,0.10)
                            love.graphics.rectangle("fill",tx,ty,TILE,TILE,3)
                            love.graphics.setColor(1.0,0.75,0.20)
                            love.graphics.rectangle("fill",tx+2,ty+2,TILE-4,8,3)
                            love.graphics.setColor(1,1,1,0.7)
                            love.graphics.setFont(love.graphics.newFont(10))
                            love.graphics.printf("↑",tx,ty+TILE/2-7,TILE,"center")
                        end
                    end
                end
            end
        end
    end

    -- Ground fog
    love.graphics.setColor(0.04,0.05,0.08,0.52)
    love.graphics.rectangle("fill",0,SH-50,SW,50)

    -- Particles
    for _,p in ipairs(particles) do
        love.graphics.setColor(p.color[1],p.color[2],p.color[3],p.a)
        love.graphics.rectangle("fill",p.x-camOff-p.size/2,p.y-p.size/2,p.size,p.size)
    end

    -- Player: screen x = player.x - camOff
    player:draw(camOff, 0)

    drawHUD()
    if paused then drawPause() end
    if dead then
        love.graphics.setColor(0,0,0,math.min(0.72,(t-deadTime)*0.38))
        love.graphics.rectangle("fill",0,0,SW,SH)
        love.graphics.setFont(UI.fonts.title); love.graphics.setColor(UI.colors.danger)
        love.graphics.printf("GAME OVER",0,SH/2-70,SW,"center")
        love.graphics.setFont(UI.fonts.heading); love.graphics.setColor(UI.colors.white)
        love.graphics.printf("Score: "..math.floor(score),0,SH/2,SW,"center")
        love.graphics.setFont(UI.fonts.small); love.graphics.setColor(UI.colors.grey)
        love.graphics.printf("Returning to menu...",0,SH/2+58,SW,"center")
    end
end

function drawHUD()
    love.graphics.setColor(0,0,0,0.72); love.graphics.rectangle("fill",0,0,SW,46)
    love.graphics.setColor(UI.colors.success); love.graphics.rectangle("fill",0,44,SW,2)
    love.graphics.setColor(UI.colors.success); love.graphics.rectangle("fill",0,0,4,46)
    love.graphics.setFont(UI.fonts.heading); love.graphics.setColor(UI.colors.white)
    love.graphics.printf(string.format("%.0f",score),0,10,SW,"center")
    love.graphics.setFont(UI.fonts.small); love.graphics.setColor(UI.colors.grey)
    love.graphics.print("ENDLESS  |  "..(Settings.data.difficulty or "normal"):upper(),14,15)
    love.graphics.setColor(UI.colors.success)
    love.graphics.printf(string.format("%.0f km/h",speed*0.036),SW-170,15,148,"right")
    local speedR=math.min(1,(speed-baseSpeed)/math.max(1,720-baseSpeed))
    love.graphics.setColor(UI.colors.darkgrey); love.graphics.rectangle("fill",14,SH-20,180,6,3)
    love.graphics.setColor(speedR>0.75 and UI.colors.danger or UI.colors.accent)
    love.graphics.rectangle("fill",14,SH-20,180*speedR,6,3)
    love.graphics.setFont(UI.fonts.tiny); love.graphics.setColor(UI.colors.grey)
    love.graphics.print("SPEED",200,SH-22)
    if t<6 then
        local a=math.min(1,(6-t)*0.7)
        love.graphics.setFont(UI.fonts.tiny); love.graphics.setColor(0.6,0.6,0.65,a)
        love.graphics.printf("A/D  Move    SPACE  Jump    LSHIFT  Slide    ESC  Pause",0,SH-38,SW,"center")
    end
    if Settings.data.showFPS then
        love.graphics.setFont(UI.fonts.tiny); love.graphics.setColor(UI.colors.grey)
        love.graphics.print("FPS "..love.timer.getFPS(),SW-70,SH-22)
    end
end

function drawPause()
    love.graphics.setColor(0,0,0,0.70); love.graphics.rectangle("fill",0,0,SW,SH)
    love.graphics.setColor(0.07,0.07,0.10,0.95)
    love.graphics.rectangle("fill",SW/2-200,200,400,320,8,8)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill",SW/2-200,200,400,4,4,4)
    love.graphics.setFont(UI.fonts.title); love.graphics.setColor(UI.colors.white)
    love.graphics.printf("PAUSED",0,218,SW,"center")
    local opts={
        {label="RESUME",    action=function() paused=false end},
        {label="RESTART",   action=function() loadGame() end},
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
        if dead then SM.switch("menu") return end
        paused=not paused
    end
    if key==(kb.jump or "space") and not paused and not dead then player:onJump() end
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
