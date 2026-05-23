local Settings = require("src.settings")

local Player = {}
Player.__index = Player

-- Constants
local GRAVITY       = 900
local JUMP_VEL      = -420
local DJUMP_VEL     = -370
local MOVE_SPEED    = 280
local RUN_ACCEL     = 1800
local RUN_DECEL     = 1400
local SLIDE_SPEED   = 400
local SLIDE_DUR     = 0.45
local WALLJUMP_VX   = 320
local WALLJUMP_VY   = -400
local COYOTE_TIME   = 0.10
local JUMP_BUFFER   = 0.12

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x  = x
    self.y  = y
    self.vx = 0
    self.vy = 0
    self.w  = 28
    self.h  = 48

    self.onGround      = false
    self.onWall        = 0     -- -1 left, 0 none, 1 right
    self.canDoubleJump = true
    self.coyoteTimer   = 0
    self.jumpBuffer    = 0
    self.slideTimer    = 0
    self.sliding       = false
    self.facingRight   = true
    self.alive         = true
    self.animTimer     = 0
    self.animFrame     = 1
    self.trail         = {}   -- visual motion trail

    -- State: idle, run, jump, fall, slide, walljump
    self.state = "idle"
    return self
end

function Player:getRect()
    local h = self.sliding and 28 or self.h
    return self.x, self.y + (self.h - h), self.w, h
end

function Player:update(dt, tileMap)
    local kb = Settings.data.keybinds

    -- Input
    local left  = love.keyboard.isDown(kb.left)
    local right = love.keyboard.isDown(kb.right)
    local slide = love.keyboard.isDown(kb.slide)

    -- Slide
    if slide and self.onGround and not self.sliding then
        self.sliding   = true
        self.slideTimer = SLIDE_DUR
        self.vx = self.facingRight and SLIDE_SPEED or -SLIDE_SPEED
    end
    if self.sliding then
        self.slideTimer = self.slideTimer - dt
        if self.slideTimer <= 0 then self.sliding = false end
    end

    -- Horizontal movement
    if not self.sliding then
        local targetVX = 0
        if left  then targetVX = -MOVE_SPEED end
        if right then targetVX =  MOVE_SPEED end

        if targetVX ~= 0 then
            self.vx = self.vx + (targetVX - self.vx) * math.min(1, RUN_ACCEL * dt / MOVE_SPEED)
            self.facingRight = targetVX > 0
        else
            local decel = RUN_DECEL * dt
            if math.abs(self.vx) < decel then
                self.vx = 0
            else
                self.vx = self.vx - decel * (self.vx > 0 and 1 or -1)
            end
        end
    end

    -- Gravity
    self.vy = self.vy + GRAVITY * dt
    if self.vy > 1200 then self.vy = 1200 end

    -- Coyote time
    if self.onGround then
        self.coyoteTimer = COYOTE_TIME
        self.canDoubleJump = true
    else
        self.coyoteTimer = math.max(0, self.coyoteTimer - dt)
    end

    -- Jump buffer
    self.jumpBuffer = math.max(0, self.jumpBuffer - dt)

    -- Jump execution
    if self.jumpBuffer > 0 then
        if self.coyoteTimer > 0 then
            self.vy = JUMP_VEL
            self.coyoteTimer = 0
            self.jumpBuffer   = 0
        elseif self.onWall ~= 0 then
            self.vy = WALLJUMP_VY
            self.vx = -self.onWall * WALLJUMP_VX
            self.jumpBuffer = 0
            self.canDoubleJump = true
        elseif self.canDoubleJump then
            self.vy = DJUMP_VEL
            self.canDoubleJump = false
            self.jumpBuffer = 0
        end
    end

    -- Apply velocity + collision
    self:move(dt, tileMap)

    -- State machine
    self:updateState()

    -- Animation
    self.animTimer = self.animTimer + dt
    if self.animTimer > 0.1 then
        self.animTimer = 0
        self.animFrame = self.animFrame % 4 + 1
    end

    -- Trail
    table.insert(self.trail, 1, {x = self.x, y = self.y, a = 0.35})
    while #self.trail > 8 do table.remove(self.trail) end
    for _, tr in ipairs(self.trail) do tr.a = tr.a - dt * 1.2 end

    -- Death (fall out of world)
    if self.y > 2000 then self.alive = false end
end

function Player:move(dt, tileMap)
    -- X
    self.x = self.x + self.vx * dt
    if tileMap then
        local cols = tileMap:collideRect(self:getRect())
        self.onWall = 0
        for _, col in ipairs(cols) do
            if col.nx ~= 0 then
                self.x = self.x - col.penetration * col.nx
                if self.vx * col.nx > 0 then
                    self.onWall = col.nx
                    self.vx = 0
                end
            end
        end
    end

    -- Y
    self.y = self.y + self.vy * dt
    self.onGround = false
    if tileMap then
        local cols = tileMap:collideRect(self:getRect())
        for _, col in ipairs(cols) do
            if col.ny ~= 0 then
                self.y = self.y - col.penetration * col.ny
                if col.ny < 0 then
                    self.onGround = true
                end
                self.vy = 0
            end
        end
    end
end

function Player:updateState()
    if self.sliding then self.state = "slide"
    elseif not self.onGround and self.onWall ~= 0 then self.state = "walljump"
    elseif self.vy < -50 then self.state = "jump"
    elseif self.vy > 80 then self.state = "fall"
    elseif math.abs(self.vx) > 30 then self.state = "run"
    else self.state = "idle"
    end
end

function Player:onJump()
    self.jumpBuffer = JUMP_BUFFER
end

function Player:draw(camX, camY)
    local sx = self.x - (camX or 0)
    local sy = self.y - (camY or 0)

    -- Trail
    for i, tr in ipairs(self.trail) do
        if tr.a > 0 then
            love.graphics.setColor(0.96, 0.42, 0.10, tr.a * 0.5)
            local scale = 1 - i * 0.08
            local tw = self.w * scale
            local th = self.h * scale
            love.graphics.rectangle("fill",
                sx + (self.x - tr.x) + (self.w - tw)/2,
                sy + (self.y - tr.y) + (self.h - th)/2,
                tw, th, 3)
        end
    end

    local px, py, pw, ph = self:getRect()
    px = px - (camX or 0)
    py = py - (camY or 0)

    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.ellipse("fill", px + pw/2, py + ph + 3, pw/2 - 2, 5)

    -- Body
    local bodyColor = {0.96, 0.42, 0.10}
    if self.state == "walljump" then bodyColor = {0.20, 0.70, 1.00} end
    if self.sliding then bodyColor = {0.80, 0.30, 0.08} end
    love.graphics.setColor(bodyColor)
    love.graphics.rectangle("fill", px, py, pw, ph, 5, 5)

    -- Head
    love.graphics.setColor(0.92, 0.78, 0.62)
    love.graphics.circle("fill", px + pw/2, py + 8, 10)

    -- Eyes (direction)
    love.graphics.setColor(0.1, 0.1, 0.1)
    local eyeOff = self.facingRight and 3 or -3
    love.graphics.circle("fill", px + pw/2 + eyeOff, py + 7, 2.5)

    -- Double-jump indicator
    if not self.canDoubleJump and not self.onGround then
        love.graphics.setColor(1, 0.3, 0.1, 0.7)
        love.graphics.circle("line", px + pw/2, py - 8, 5)
    end
end

function Player:drawHUD()
    -- State badge
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.setColor(0.4, 0.4, 0.5, 0.8)
    love.graphics.print(self.state:upper(), 10, 52)
end

return Player
