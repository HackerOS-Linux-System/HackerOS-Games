local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")
local Player   = require("src.player")

local state = {}
local SW, SH = 1280, 720
local TILE    = 32

-- ─── Difficulty presets ───────────────────────────────────────────────────--
local DIFFICULTY = {
    easy   = { speed=220, gapMin=2, gapMax=4, spikeChance=0.08, platformDrop=60 },
    normal = { speed=290, gapMin=2, gapMax=5, spikeChance=0.18, platformDrop=80 },
    hard   = { speed=370, gapMin=3, gapMax=6, spikeChance=0.30, platformDrop=100 },
}

-- ─── Chunk types ─────────────────────────────────────────────────────────────
-- Each chunk is a function that builds a segment and returns width (in tiles)
local ChunkBuilders = {}

local function makeFlat(len, hasSpikes)
    local chunk = {}
    -- ground row
    chunk.ground = {}
    for i = 1, len do
        chunk.ground[i] = (hasSpikes and i >= 2 and i <= len-1 and math.random() < 0.3) and 3 or 1
    end
    chunk.w = len
    chunk.h = 1
    return chunk
end

local function makeGap(before, after)
    local chunk = {}
    chunk.ground = {}
    for i = 1, before do chunk.ground[i] = 1 end
    for i = before+1, before+2 do chunk.ground[i] = 0 end -- gap
    for i = before+3, before+3+after do chunk.ground[i] = 1 end
    chunk.w = before + 3 + after
    chunk.h = 1
    return chunk
end

-- ─── World state ─────────────────────────────────────────────────────────────
local segments   = {}  -- array of {x, tiles=[row][col], w, h, pixy}
local player
local camX, camY_f
local scrollX    = 0
local speed, baseSpeed
local score      = 0
local dead       = false
local paused     = false
local deadTime   = 0
local t          = 0
local mx, my     = 0, 0
local pauseOpts

-- Ground y in screen coords (we keep player on a fixed height band)
local GROUND_Y   = 500
local SEG_HEIGHT = 4  -- tile rows per segment

-- ─── Segment generator ───────────────────────────────────────────────────────
local nextSegX = 0
local diff

local function tileColor(tt)
    local c = {
        [1] = {0.22, 0.24, 0.30},
        [2] = {0.18, 0.50, 0.30},
        [3] = {0.80, 0.15, 0.15},
        [4] = {0.90, 0.60, 0.15},
        [5] = {0.55, 0.85, 0.95},
        [6] = {0.10, 0.85, 0.45},
    }
    return c[tt] or {0.5,0.5,0.5}
end

local function buildSegment(worldX)
    local seg = {}
    seg.x = worldX
    seg.pixy = GROUND_Y
    seg.cols = {}

    local W = math.random(10, 18)
    seg.w = W * TILE
    seg.h = SEG_HEIGHT * TILE

    -- Random type
    local r = math.random()
    local gapTiles = math.random(diff.gapMin, diff.gapMax)

    if r < 0.35 then
        -- Flat with optional spikes
        for col = 1, W do
            seg.cols[col] = {}
            for row = 1, SEG_HEIGHT do
                if row == 1 then
                    local isSpike = col >= 2 and col <= W-1 and math.random() < diff.spikeChance
                    seg.cols[col][row] = isSpike and 3 or 1
                else
                    seg.cols[col][row] = 1
                end
            end
        end
    elseif r < 0.65 then
        -- Gap (no tiles for gapTiles cols in middle)
        local gapStart = math.random(3, W - gapTiles - 2)
        for col = 1, W do
            seg.cols[col] = {}
            local isGap = col >= gapStart and col < gapStart + gapTiles
            for row = 1, SEG_HEIGHT do
                seg.cols[col][row] = isGap and 0 or 1
            end
        end
    elseif r < 0.80 then
        -- Platforms above gaps
        for col = 1, W do
            seg.cols[col] = {}
            for row = 1, SEG_HEIGHT do
                seg.cols[col][row] = 1
            end
        end
        -- Add floating platform
        local pfStart = math.random(2, W-4)
        local pfLen   = math.random(3, 5)
        for col = pfStart, pfStart+pfLen do
            if col <= W then
                -- gap below, platform above
                seg.cols[col][1] = 0
                seg.cols[col][2] = 2
            end
        end
    else
        -- All solid (rest)
        for col = 1, W do
            seg.cols[col] = {}
            for row = 1, SEG_HEIGHT do
                seg.cols[col][row] = 1
            end
        end
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

-- ─── Collision against segments ───────────────────────────────────────────--
local function segmentCollide(px, py, pw, ph)
    local cols = {}
    for _, seg in ipairs(segments) do
        -- Quick AABB skip
        if px + pw > seg.x and px < seg.x + seg.w then
            for col = 1, #seg.cols do
                local tx = seg.x + (col - 1) * TILE
                if tx + TILE > px and tx < px + pw then
                    for row = 1, SEG_HEIGHT do
                        local tt = seg.cols[col] and seg.cols[col][row] or 0
                        if tt == 1 or tt == 3 or tt == 2 then
                            local ty = seg.pixy + (row - 1) * TILE
                            if ty + TILE > py and ty < py + ph then
                                local ox = math.min(px+pw, tx+TILE) - math.max(px, tx)
                                local oy = math.min(py+ph, ty+TILE) - math.max(py, ty)
                                if ox > 0 and oy > 0 then
                                    local nx, ny, pen
                                    if ox < oy then
                                        pen=ox; nx=(px+pw/2 < tx+TILE/2) and -1 or 1; ny=0
                                    else
                                        pen=oy; nx=0; ny=(py+ph/2 < ty+TILE/2) and -1 or 1
                                    end
                                    if tt == 2 and ny ~= 1 then
                                        -- Platform only from above
                                    elseif tt == 3 then
                                        table.insert(cols, {nx=nx,ny=ny,penetration=pen,lethal=true})
                                    else
                                        table.insert(cols, {nx=nx,ny=ny,penetration=pen})
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

-- Patch player move to use segment collider
local function patchedMove(pl, dt)
    pl.x = pl.x + pl.vx * dt
    local cols = segmentCollide(pl.x, pl.y, pl.w, pl.h)
    pl.onWall = 0
    for _, col in ipairs(cols) do
        if col.nx ~= 0 then
            pl.x = pl.x - col.penetration * col.nx
            if pl.vx * col.nx > 0 then pl.onWall = col.nx; pl.vx = 0 end
        end
        if col.lethal then pl.alive = false end
    end

    pl.y = pl.y + pl.vy * dt
    pl.onGround = false
    cols = segmentCollide(pl.x, pl.y, pl.w, pl.h)
    for _, col in ipairs(cols) do
        if col.ny ~= 0 then
            pl.y = pl.y - col.penetration * col.ny
            if col.ny < 0 then pl.onGround = true end
            pl.vy = 0
        end
        if col.lethal then pl.alive = false end
    end
end

local function loadGame()
    local diffKey = Settings.data.difficulty or "normal"
    diff      = DIFFICULTY[diffKey]
    speed     = diff.speed
    baseSpeed = diff.speed

    segments  = {}
    nextSegX  = 0
    scrollX   = 0

    -- Pre-generate first screen + buffer
    generateUntil(SW * 3)

    player = Player.new(120, GROUND_Y - 100)
    player.move = patchedMove  -- monkey-patch

    camX, camY_f = 0, 0
    score    = 0
    dead     = false
    paused   = false
    t        = 0
end

-- ─── Main lifecycle ───────────────────────────────────────────────────────────
function state.enter()
    UI.loadFonts()
    loadGame()
end

function state.update(dt)
    t = t + dt
    if paused then return end

    if dead then
        if t - deadTime > 2.5 then
            -- Save score & return
            Settings.addHighscore("endless", {
                name  = Settings.data.playerName,
                score = math.floor(score),
                date  = os.date("%Y-%m-%d"),
            })
            SM.switch("menu")
        end
        return
    end

    -- Ramp speed over time
    speed = baseSpeed + score * 0.05
    if speed > 700 then speed = 700 end

    -- Scroll world
    scrollX = scrollX + speed * dt
    score   = score + speed * dt * 0.01

    -- Sync player world-x with scroll (endless = player stays left, world moves)
    player.x = player.x + speed * dt * 0.05
    if player.x > 200 then player.x = 200 end

    -- Override player update move with segment collider
    local origMove = player.move
    player.move = patchedMove

    -- Manual player physics (simplified to avoid tilemap ref)
    local kb = Settings.data.keybinds
    local sl = love.keyboard.isDown(kb.slide)
    if sl and player.onGround and not player.sliding then
        player.sliding = true; player.slideTimer = 0.45
        player.vx = player.facingRight and 400 or -400
    end
    if player.sliding then
        player.slideTimer = player.slideTimer - dt
        if player.slideTimer <= 0 then player.sliding = false end
    end

    -- Gravity
    player.vy = math.min(player.vy + 900 * dt, 1200)

    -- Coyote / jump buffer
    if player.onGround then
        player.coyoteTimer = 0.10
        player.canDoubleJump = true
    else
        player.coyoteTimer = math.max(0, player.coyoteTimer - dt)
    end
    player.jumpBuffer = math.max(0, player.jumpBuffer - dt)
    if player.jumpBuffer > 0 then
        if player.coyoteTimer > 0 then
            player.vy = -420; player.coyoteTimer = 0; player.jumpBuffer = 0
        elseif player.canDoubleJump then
            player.vy = -370; player.canDoubleJump = false; player.jumpBuffer = 0
        end
    end

    patchedMove(player, dt)
    player:updateState()
    player.animTimer = player.animTimer + dt
    if player.animTimer > 0.1 then
        player.animTimer = 0
        player.animFrame = player.animFrame % 4 + 1
    end

    -- Death check
    if not player.alive or player.y > GROUND_Y + 400 then
        dead = true
        deadTime = t
    end

    -- Generate new segments ahead
    generateUntil(player.x + scrollX + SW * 2)

    -- Trim old segments
    while #segments > 0 and segments[1].x + segments[1].w < player.x + scrollX - SW do
        table.remove(segments, 1)
    end
end

function state.draw()
    -- Background
    love.graphics.setColor(0.04, 0.04, 0.07)
    love.graphics.rectangle("fill", 0, 0, SW, SH)

    -- Speed lines
    local lineAlpha = math.min(0.4, (speed - baseSpeed) / 300)
    love.graphics.setColor(0.96, 0.42, 0.10, lineAlpha)
    for i = 1, 20 do
        local y = math.random(0, SH)
        local len = math.random(30, 120)
        love.graphics.line(math.random(0, SW), y, math.random(0, SW) + len, y)
    end

    -- Draw segments
    local offX = -(player.x + scrollX - 200)  -- camera offset so player is at x=200
    for _, seg in ipairs(segments) do
        for col = 1, #seg.cols do
            local tx = seg.x + (col - 1) * TILE + offX
            if tx + TILE > 0 and tx < SW then
                for row = 1, SEG_HEIGHT do
                    local tt = seg.cols[col] and seg.cols[col][row] or 0
                    if tt ~= 0 then
                        local ty = seg.pixy + (row - 1) * TILE
                        local c = tileColor(tt)
                        love.graphics.setColor(c)
                        love.graphics.rectangle("fill", tx, ty, TILE, TILE)
                        love.graphics.setColor(c[1]*1.3, c[2]*1.3, c[3]*1.3, 0.5)
                        love.graphics.line(tx, ty, tx+TILE, ty)
                        love.graphics.line(tx, ty, tx, ty+TILE)

                        if tt == 3 then
                            love.graphics.setColor(0.95, 0.25, 0.25)
                            for i = 0, 3 do
                                local sx = tx + i*8 + 4
                                love.graphics.polygon("fill", sx-3,ty+TILE, sx+3,ty+TILE, sx,ty+8)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Player (fixed at x=200 on screen)
    player:draw(player.x - 200, 0)

    -- HUD
    drawHUD()

    if paused then drawPause() end

    if dead then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, SW, SH)
        love.graphics.setFont(UI.fonts.title)
        love.graphics.setColor(UI.colors.danger)
        love.graphics.printf("GAME OVER", 0, SH/2-60, SW, "center")
        love.graphics.setFont(UI.fonts.heading)
        love.graphics.setColor(UI.colors.white)
        love.graphics.printf("Score: " .. math.floor(score), 0, SH/2, SW, "center")
        love.graphics.setFont(UI.fonts.small)
        love.graphics.setColor(UI.colors.grey)
        love.graphics.printf("Returning to menu...", 0, SH/2+60, SW, "center")
    end
end

function drawHUD()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, SW, 44)
    love.graphics.setColor(UI.colors.success)
    love.graphics.rectangle("fill", 0, 43, SW, 2)
    love.graphics.setColor(UI.colors.success)
    love.graphics.rectangle("fill", 0, 0, 4, 44)

    love.graphics.setFont(UI.fonts.heading)
    love.graphics.setColor(UI.colors.white)
    love.graphics.printf(string.format("%.0f", score), 0, 9, SW, "center")

    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    local diffKey = Settings.data.difficulty or "normal"
    love.graphics.print("ENDLESS  |  " .. diffKey:upper(), 10, 14)
    love.graphics.setColor(UI.colors.success)
    love.graphics.printf(string.format("%.0f km/h", speed * 0.036), SW-160, 14, 140, "right")

    -- Speed bar
    local speedRatio = math.min(1, (speed - baseSpeed) / 400)
    love.graphics.setColor(UI.colors.darkgrey)
    love.graphics.rectangle("fill", 10, SH-18, 200, 6, 3)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill", 10, SH-18, 200 * speedRatio, 6, 3)
    love.graphics.setFont(UI.fonts.tiny)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("SPEED", 215, SH-20)
end

function drawPause()
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, SW, SH)
    love.graphics.setFont(UI.fonts.title)
    love.graphics.setColor(UI.colors.white)
    love.graphics.printf("PAUSED", 0, 240, SW, "center")

    local opts = {
        {label="RESUME",    action=function() paused=false end},
        {label="RESTART",   action=function() loadGame() end},
        {label="MAIN MENU", action=function() SM.switch("menu") end},
    }
    for i, opt in ipairs(opts) do
        UI.button({x=SW/2-160, y=320+i*66, w=320, h=54, label=opt.label}, mx, my)
        opt._y = 320 + i*66
    end
    pauseOpts = opts
end

function state.keypressed(key)
    local kb = Settings.data.keybinds
    if key == kb.pause or key == "escape" then
        if dead then SM.switch("menu") return end
        paused = not paused
    end
    if key == kb.jump and not paused and not dead then
        player:onJump()
    end
end

function state.mousemoved(x, y) mx, my = x, y end
function state.mousepressed(x, y, button)
    if button ~= 1 then return end
    if paused and pauseOpts then
        for _, opt in ipairs(pauseOpts) do
            if opt._y and x >= SW/2-160 and x <= SW/2+160 and y >= opt._y and y <= opt._y+54 then
                opt.action()
            end
        end
    end
end

return state
