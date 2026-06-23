local Settings = require("src.settings")

local Player = {}
Player.__index = Player

local GRAVITY      = 900
local JUMP_VEL     = -430
local DJUMP_VEL    = -370
local MOVE_SPEED   = 285
local RUN_ACCEL    = 2000
local RUN_DECEL    = 1500
local SLIDE_SPEED  = 400
local SLIDE_DUR    = 0.42
local WALLJUMP_VX  = 300
local WALLJUMP_VY  = -400
local COYOTE_TIME  = 0.12
local JUMP_BUFFER  = 0.14

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x, self.y   = x, y
    self.vx, self.vy = 0, 0
    self.w, self.h   = 28, 48

    self.onGround      = false
    self.onWall        = 0
    self.canDoubleJump = true
    self.coyoteTimer   = 0
    self.jumpBuffer    = 0
    self.slideTimer    = 0
    self.sliding       = false
    self.facingRight   = true
    self.alive         = true
    self.animTimer     = 0
    self.animFrame     = 1
    self.trail         = {}
    self.landEffect    = 0
    self.jumpEffect    = 0
    self.wallSlide     = false
    self.state         = "idle"
    return self
end

function Player:getRect()
    local h = self.sliding and 28 or self.h
    return self.x, self.y + (self.h - h), self.w, h
end

function Player:update(dt, tileMap)
    local kb    = Settings.data.keybinds
    local left  = love.keyboard.isDown(kb.left  or "a")
    local right = love.keyboard.isDown(kb.right or "d")
    local slide = love.keyboard.isDown(kb.slide or "lshift")

    -- Slide
    if slide and self.onGround and not self.sliding and math.abs(self.vx) > 40 then
        self.sliding    = true
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
            local dec = RUN_DECEL * dt
            if math.abs(self.vx) < dec then self.vx = 0
            else self.vx = self.vx - dec * (self.vx > 0 and 1 or -1) end
        end
    end

    -- Wall slide
    self.wallSlide = false
    if self.onWall ~= 0 and not self.onGround and self.vy > 0 then
        local pressingInto = (self.onWall > 0 and right) or (self.onWall < 0 and left)
        if pressingInto then
            self.wallSlide = true
            self.vy = math.min(self.vy, 110)
        end
    end

    -- Gravity
    self.vy = math.min(self.vy + GRAVITY * dt, 1200)

    -- Coyote time
    if self.onGround then
        self.coyoteTimer   = COYOTE_TIME
        self.canDoubleJump = true
        if self.landEffect <= 0 and self.vy > 150 then self.landEffect = 0.22 end
    else
        self.coyoteTimer = math.max(0, self.coyoteTimer - dt)
    end

    -- Jump buffer
    self.jumpBuffer = math.max(0, self.jumpBuffer - dt)

    -- Execute jump
    if self.jumpBuffer > 0 then
        if self.coyoteTimer > 0 then
            self.vy          = JUMP_VEL
            self.coyoteTimer = 0
            self.jumpBuffer  = 0
            self.jumpEffect  = 0.18
        elseif self.onWall ~= 0 or self.wallSlide then
            self.vy            = WALLJUMP_VY
            self.vx            = -self.onWall * WALLJUMP_VX
            self.jumpBuffer    = 0
            self.canDoubleJump = true
            self.jumpEffect    = 0.18
        elseif self.canDoubleJump then
            self.vy            = DJUMP_VEL
            self.canDoubleJump = false
            self.jumpBuffer    = 0
            self.jumpEffect    = 0.18
        end
    end

    -- Move + collide
    self:move(dt, tileMap)
    self:updateState()

    -- Animation
    self.animTimer = self.animTimer + dt
    local animSpeed = (self.state == "run") and 0.08 or 0.12
    if self.animTimer > animSpeed then
        self.animTimer = 0
        self.animFrame = self.animFrame % 4 + 1
    end

    -- Trail
    table.insert(self.trail, 1, {x=self.x, y=self.y, a=0.35, state=self.state})
    while #self.trail > 8 do table.remove(self.trail) end
    for _, tr in ipairs(self.trail) do tr.a = tr.a - dt * 1.5 end

    self.landEffect = math.max(0, self.landEffect - dt)
    self.jumpEffect = math.max(0, self.jumpEffect - dt)

    if self.y > 3000 then self.alive = false end
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
                if col.ny < 0 then self.onGround = true end
                self.vy = 0
            end
        end
    end
end

function Player:updateState()
    if     self.sliding   then self.state = "slide"
    elseif self.wallSlide then self.state = "wallslide"
    elseif not self.onGround and self.onWall ~= 0 then self.state = "walljump"
    elseif self.vy < -50  then self.state = "jump"
    elseif self.vy > 80   then self.state = "fall"
    elseif math.abs(self.vx) > 30 then self.state = "run"
    else   self.state = "idle"
    end
end

function Player:onJump()
    self.jumpBuffer = JUMP_BUFFER
end

function Player:draw(camX, camY)
    local cx = camX or 0
    local cy = camY or 0

    -- Trail
    for i, tr in ipairs(self.trail) do
        if tr.a > 0 then
            local tc = {0.96, 0.42, 0.10}
            if tr.state == "wallslide" or tr.state == "walljump" then tc = {0.20, 0.70, 1.00} end
            if tr.state == "slide" then tc = {0.80, 0.30, 0.08} end
            love.graphics.setColor(tc[1], tc[2], tc[3], tr.a * 0.38)
            local sc = 1 - i * 0.07
            local tw, th = self.w * sc, self.h * sc
            love.graphics.rectangle("fill",
                self.x - cx + (self.w - tw)/2,
                self.y - cy + (self.h - th)/2,
                tw, th, 4)
        end
    end

    local px, py, pw, ph = self:getRect()
    px = px - cx
    py = py - cy

    -- Land dust
    if self.landEffect > 0 then
        local a = self.landEffect / 0.22
        love.graphics.setColor(0.65, 0.65, 0.65, a * 0.45)
        local spread = (1 - a) * 22
        love.graphics.ellipse("fill", px+pw/2, py+ph+2, pw/2+spread, 5)
    end

    -- Jump puff
    if self.jumpEffect > 0 then
        local a = self.jumpEffect / 0.18
        love.graphics.setColor(0.96, 0.42, 0.10, a * 0.55)
        love.graphics.ellipse("fill", px+pw/2, py+ph, pw/2+(1-a)*18, 7*a)
    end

    -- Shadow
    love.graphics.setColor(0, 0, 0, self.onGround and 0.32 or 0.12)
    love.graphics.ellipse("fill", px+pw/2, py+ph+3, pw/2-2, 5)

    -- Body colour
    local bc
    if self.wallSlide or self.state == "walljump" then bc = {0.20, 0.70, 1.00}
    elseif self.sliding    then bc = {0.80, 0.30, 0.08}
    elseif self.state == "jump" then bc = {1.00, 0.55, 0.10}
    else   bc = {0.96, 0.42, 0.10} end

    -- Glow for wall/double states
    if self.wallSlide then
        love.graphics.setColor(0.20, 0.70, 1.00, 0.22)
        love.graphics.rectangle("fill", px-5, py-5, pw+10, ph+10, 8)
    end
    if not self.canDoubleJump and not self.onGround then
        love.graphics.setColor(1, 0.3, 0.1, 0.12)
        love.graphics.rectangle("fill", px-4, py-4, pw+8, ph+8, 8)
    end

    -- Body
    love.graphics.setColor(bc)
    love.graphics.rectangle("fill", px, py, pw, ph, 6, 6)
    -- Shading
    love.graphics.setColor(bc[1]*0.65, bc[2]*0.65, bc[3]*0.65, 0.5)
    love.graphics.rectangle("fill", px+pw*0.5, py, pw*0.5, ph, 0, 6, 6, 0)
    -- Shine
    love.graphics.setColor(1,1,1,0.11)
    love.graphics.rectangle("fill", px+3, py+3, pw-6, 7, 3)

    -- Head
    love.graphics.setColor(0.95, 0.80, 0.64)
    love.graphics.circle("fill", px+pw/2, py+7, 11)
    love.graphics.setColor(0.78, 0.63, 0.48, 0.38)
    love.graphics.arc("fill", px+pw/2, py+7, 11, math.pi*0.2, math.pi*0.8)

    -- Eye
    love.graphics.setColor(0.10, 0.10, 0.15)
    local eyeOff = self.facingRight and 4 or -4
    love.graphics.circle("fill", px+pw/2+eyeOff, py+6, 2.8)
    love.graphics.setColor(1,1,1,0.9)
    love.graphics.circle("fill", px+pw/2+eyeOff+0.7, py+5.2, 1)

    -- Scarf
    local sc2 = self.wallSlide and {0.20, 0.70, 1.00} or {0.96, 0.42, 0.10}
    love.graphics.setColor(sc2[1], sc2[2], sc2[3], 0.88)
    local sdir = self.facingRight and -1 or 1
    local wave = math.sin(love.timer.getTime() * 7 + self.animFrame) * 2.5
    love.graphics.polygon("fill",
        px+pw/2-3, py+14,
        px+pw/2+3, py+14,
        px+pw/2+sdir*11+wave, py+22,
        px+pw/2+sdir*7+wave,  py+24)

    -- Double-jump indicator
    if not self.canDoubleJump and not self.onGround then
        local pulse = math.sin(love.timer.getTime()*10)*0.3+0.7
        love.graphics.setColor(1, 0.3, 0.1, pulse*0.85)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", px+pw/2, py-10, 6)
        love.graphics.setLineWidth(1)
    end
end

function Player:drawHUD()
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.setColor(0.4, 0.4, 0.5, 0.8)
    love.graphics.print(self.state:upper(), 10, 52)
end

return Player
