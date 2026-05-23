local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")
local Player   = require("src.player")
local TileMap  = require("src.tilemap")

local state = {}
local SW, SH = 1280, 720

-- ─── Maps (hunter mode uses larger, varied maps) ──────────────────────────--
local MAPS = {
    -- Map 1: Rooftop Chase
    {
        name     = "Rooftop Chase",
        variant  = "chase",  -- player flees hunter
        timeLimit = 60,
        spawnX   = 80,  spawnY = 200,
        goalX    = 1200, goalY  = 200,
        hunterStartX = 80, hunterStartY = 200,
        hunterSpeed  = 230,
        map = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,6},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,2,2,2,2,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        }
    },
}

-- ─── AI Hunter ───────────────────────────────────────────────────────────────
local Hunter = {}
Hunter.__index = Hunter

function Hunter.new(x, y, speed)
    local self = setmetatable({}, Hunter)
    self.x, self.y = x, y
    self.vx, self.vy = 0, 0
    self.w, self.h = 28, 48
    self.speed = speed or 200
    self.onGround = false
    self.jumpCooldown = 0
    self.alive = true
    return self
end

function Hunter:update(dt, tileMap, targetX, targetY)
    -- Simple AI: chase target
    local dx = targetX - self.x
    if dx > 10 then
        self.vx = self.vx + (self.speed - self.vx) * math.min(1, 8 * dt)
    elseif dx < -10 then
        self.vx = self.vx + (-self.speed - self.vx) * math.min(1, 8 * dt)
    else
        self.vx = self.vx * (1 - 6 * dt)
    end

    -- Jump when on ground and target is above
    self.jumpCooldown = math.max(0, self.jumpCooldown - dt)
    if self.onGround and targetY < self.y - 40 and self.jumpCooldown <= 0 then
        self.vy = -400
        self.jumpCooldown = 0.8
    end

    -- Gravity
    self.vy = math.min(self.vy + 900 * dt, 1200)

    -- Move X
    self.x = self.x + self.vx * dt
    if tileMap then
        local cols = tileMap:collideRect(self.x, self.y, self.w, self.h)
        for _, col in ipairs(cols) do
            if col.nx ~= 0 then
                self.x = self.x - col.penetration * col.nx
                self.vx = 0
            end
        end
    end

    -- Move Y
    self.y = self.y + self.vy * dt
    self.onGround = false
    if tileMap then
        local cols = tileMap:collideRect(self.x, self.y, self.w, self.h)
        for _, col in ipairs(cols) do
            if col.ny ~= 0 then
                self.y = self.y - col.penetration * col.ny
                if col.ny < 0 then self.onGround = true end
                self.vy = 0
            end
        end
    end
end

function Hunter:draw(camX, camY)
    local sx = self.x - camX
    local sy = self.y - camY
    -- Red glow
    love.graphics.setColor(0.8, 0.1, 0.1, 0.2)
    love.graphics.rectangle("fill", sx - 6, sy - 6, self.w + 12, self.h + 12, 8)
    -- Body
    love.graphics.setColor(0.75, 0.10, 0.10)
    love.graphics.rectangle("fill", sx, sy, self.w, self.h, 4)
    -- Eyes
    love.graphics.setColor(1, 0.9, 0.1)
    love.graphics.circle("fill", sx + 8, sy + 12, 4)
    love.graphics.circle("fill", sx + 20, sy + 12, 4)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.circle("fill", sx + 9, sy + 12, 2)
    love.graphics.circle("fill", sx + 21, sy + 12, 2)
end

-- ─── State ───────────────────────────────────────────────────────────────────
local player, hunter, tileMap
local camX, camY
local currentMap, mapIdx
local timer, paused, dead, won
local t = 0
local mx, my = 0, 0
local deadTime, wonTime
local pauseOpts

local function dist2(ax, ay, bx, by)
    local dx, dy = ax-bx, ay-by
    return dx*dx + dy*dy
end

local function loadMap(idx)
    mapIdx     = idx or 1
    currentMap = MAPS[mapIdx]
    tileMap  = TileMap.new(currentMap.map, 0, 0)
    player   = Player.new(currentMap.spawnX, currentMap.spawnY)
    hunter   = Hunter.new(currentMap.hunterStartX + 120, currentMap.hunterStartY,
                          currentMap.hunterSpeed)
    camX, camY = 0, 0
    timer    = currentMap.timeLimit or 60
    paused   = false
    dead     = false
    won      = false
    t        = 0
end

function state.enter()
    UI.loadFonts()
    loadMap(1)
end

function state.update(dt)
    t = t + dt
    if paused then return end

    if dead then
        if t - deadTime > 2 then loadMap(mapIdx) end
        return
    end
    if won then
        if t - wonTime > 3 then SM.switch("menu") end
        return
    end

    timer = timer - dt

    player:update(dt, tileMap)
    hunter:update(dt, tileMap, player.x, player.y)

    -- Caught check
    local d2 = dist2(player.x, player.y, hunter.x, hunter.y)
    if d2 < 30*30 then
        dead = true
        deadTime = t
    end

    -- Timer ran out
    if timer <= 0 then
        dead = true
        deadTime = t
    end

    -- Reached goal
    local gx, gy = currentMap.goalX, currentMap.goalY
    if dist2(player.x, player.y, gx, gy) < 50*50 then
        won = true
        wonTime = t
    end

    -- Camera
    local targetX = player.x - SW/2
    local targetY = player.y - SH*0.55
    local mapW = tileMap:pixelWidth()
    local mapH = tileMap:pixelHeight()
    targetX = math.max(0, math.min(targetX, mapW - SW))
    targetY = math.max(0, math.min(targetY, mapH - SH))
    camX = camX + (targetX - camX) * 0.12
    camY = camY + (targetY - camY) * 0.12
end

function state.draw()
    love.graphics.setColor(0.05, 0.05, 0.08)
    love.graphics.rectangle("fill", 0, 0, SW, SH)

    -- Ominous red tint when hunter close
    local px, py = player.x, player.y
    local hx, hy = hunter.x, hunter.y
    local danger = math.max(0, 1 - math.sqrt((px-hx)^2+(py-hy)^2) / 400)
    if danger > 0 then
        love.graphics.setColor(0.6, 0.05, 0.05, danger * 0.18)
        love.graphics.rectangle("fill", 0, 0, SW, SH)
    end

    tileMap:draw(camX, camY, SW, SH)
    hunter:draw(camX, camY)
    player:draw(camX, camY)

    -- Goal marker
    local gsx = currentMap.goalX - camX
    local gsy = currentMap.goalY - camY
    love.graphics.setColor(0.10, 0.85, 0.45, 0.5 + 0.3*math.sin(t*4))
    love.graphics.circle("fill", gsx, gsy, 20)
    love.graphics.setColor(1,1,1,0.9)
    love.graphics.setFont(UI.fonts.small)
    love.graphics.printf("GOAL", gsx-30, gsy-8, 60, "center")

    drawHUD()

    if paused then drawPause() end

    if dead and not paused then
        love.graphics.setColor(0.8, 0.1, 0.1, 0.7)
        love.graphics.rectangle("fill", 0, 0, SW, SH)
        love.graphics.setFont(UI.fonts.title)
        love.graphics.setColor(1,1,1)
        love.graphics.printf("CAUGHT!", 0, SH/2-40, SW, "center")
        love.graphics.setFont(UI.fonts.body)
        love.graphics.setColor(UI.colors.grey)
        love.graphics.printf("Restarting...", 0, SH/2+20, SW, "center")
    end

    if won then
        love.graphics.setColor(0, 0.5, 0.2, 0.5)
        love.graphics.rectangle("fill", 0, 0, SW, SH)
        love.graphics.setFont(UI.fonts.title)
        love.graphics.setColor(UI.colors.success)
        love.graphics.printf("ESCAPED!", 0, SH/2-40, SW, "center")
    end
end

function drawHUD()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, SW, 44)
    love.graphics.setColor(0.20, 0.70, 1.00)
    love.graphics.rectangle("fill", 0, 43, SW, 2)
    love.graphics.setColor(0.20, 0.70, 1.00)
    love.graphics.rectangle("fill", 0, 0, 4, 44)

    love.graphics.setFont(UI.fonts.heading)
    love.graphics.setColor(timer < 10 and UI.colors.danger or UI.colors.white)
    love.graphics.printf(string.format("%.1f", math.max(0, timer)), 0, 9, SW, "center")

    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("HUNTER MODE  |  " .. currentMap.name, 10, 14)
    love.graphics.setColor(0.20, 0.70, 1.00)
    love.graphics.printf("FLEE TO GOAL!", SW - 160, 14, 140, "right")

    -- Proximity warning
    local px, py = player.x, player.y
    local hx, hy = hunter.x, hunter.y
    local d = math.sqrt((px-hx)^2+(py-hy)^2)
    if d < 200 then
        love.graphics.setFont(UI.fonts.small)
        love.graphics.setColor(0.9, 0.1, 0.1, 1)
        love.graphics.printf("⚠ HUNTER CLOSE", 0, 50, SW, "center")
    end
end

function drawPause()
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, SW, SH)
    love.graphics.setFont(UI.fonts.title)
    love.graphics.setColor(UI.colors.white)
    love.graphics.printf("PAUSED", 0, 240, SW, "center")

    local opts = {
        {label="RESUME",    action=function() paused=false end},
        {label="RESTART",   action=function() loadMap(mapIdx) end},
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
        if dead or won then SM.switch("menu") return end
        paused = not paused
    end
    if key == kb.jump and not paused and not dead and not won then
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
