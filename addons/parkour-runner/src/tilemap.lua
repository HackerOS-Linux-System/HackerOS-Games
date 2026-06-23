local TileMap = {}
TileMap.__index = TileMap

local TILE = 32

TileMap.TYPES = {
    AIR        = 0,
    SOLID      = 1,
    PLATFORM   = 2,
    SPIKE      = 3,
    BOUNCE     = 4,
    ICE        = 5,
    FINISH     = 6,
    CHECKPOINT = 7,
}

-- Pre-generated background buildings (generated once, not every frame)
local bgBuildings = { {}, {} }  -- layer 1 and 2

local function generateBgBuildings()
    -- Use a fixed sequence so it's deterministic without touching math.randomseed
    local function pseudoRand(seed, min, max)
        local v = (seed * 1664525 + 1013904223) % (2^32)
        return min + v % (max - min + 1)
    end

    bgBuildings[1] = {}
    local bx = -60
    local s  = 1
    while bx < 1280 + 200 do
        local bw = pseudoRand(s,    50, 130)
        local bh = pseudoRand(s+1,  80, 300)
        local seed = (s * 37) % 100 / 100
        table.insert(bgBuildings[1], { x=bx, w=bw, h=bh, seed=seed })
        bx = bx + bw + pseudoRand(s+2, 0, 25)
        s = s + 7
    end

    bgBuildings[2] = {}
    bx = -40
    s  = 500
    while bx < 1280 + 200 do
        local bw = pseudoRand(s,    40, 100)
        local bh = pseudoRand(s+1,  50, 180)
        local seed = (s * 53) % 100 / 100
        table.insert(bgBuildings[2], { x=bx, w=bw, h=bh, seed=seed })
        bx = bx + bw + pseudoRand(s+2, 0, 20)
        s = s + 11
    end
end

generateBgBuildings()

-- Per-tile decoration seeds (deterministic, no randomseed needed)
local function tileSeed(row, col)
    return ((row * 7919 + col * 6271) % 1000) / 1000
end

function TileMap.new(data, offsetX, offsetY)
    local self = setmetatable({}, TileMap)
    self.data  = data or {}
    self.rows  = #data
    self.cols  = data[1] and #data[1] or 0
    self.ox    = offsetX or 0
    self.oy    = offsetY or 0
    self.TILE  = TILE
    self.animT = 0
    return self
end

function TileMap:get(row, col)
    if row < 1 or row > self.rows then return 0 end
    if col < 1 or col > self.cols then return 0 end
    return self.data[row][col] or 0
end

function TileMap:worldToTile(wx, wy)
    local col = math.floor((wx - self.ox) / TILE) + 1
    local row = math.floor((wy - self.oy) / TILE) + 1
    return row, col
end

function TileMap:collideRect(rx, ry, rw, rh)
    local cols = {}
    local T    = TILE
    local ox, oy = self.ox, self.oy

    local c1 = math.floor((rx - ox)      / T) + 1
    local c2 = math.floor((rx - ox + rw) / T) + 1
    local r1 = math.floor((ry - oy)      / T) + 1
    local r2 = math.floor((ry - oy + rh) / T) + 1

    for row = r1, r2 do
        for col = c1, c2 do
            local tt = self:get(row, col)
            if tt == TileMap.TYPES.SOLID
            or tt == TileMap.TYPES.ICE
            or tt == TileMap.TYPES.BOUNCE
            or tt == TileMap.TYPES.CHECKPOINT then
                local tx = (col - 1) * T + ox
                local ty = (row - 1) * T + oy
                local overlapX = math.min(rx + rw, tx + T) - math.max(rx, tx)
                local overlapY = math.min(ry + rh, ty + T) - math.max(ry, ty)
                if overlapX > 0 and overlapY > 0 then
                    local nx, ny, pen
                    if overlapX < overlapY then
                        pen = overlapX
                        nx  = (rx + rw/2 < tx + T/2) and -1 or 1
                        ny  = 0
                    else
                        pen = overlapY
                        nx  = 0
                        ny  = (ry + rh/2 < ty + T/2) and -1 or 1
                    end
                    table.insert(cols, {
                        nx=nx, ny=ny, penetration=pen,
                        tileType=tt, tx=tx, ty=ty,
                    })
                end
            elseif tt == TileMap.TYPES.PLATFORM then
                local tx = (col - 1) * T + ox
                local ty = (row - 1) * T + oy
                -- One-way: only collide from above
                local prevBottom = ry + rh - 4
                if prevBottom <= ty + 4 then
                    local overlapY = math.min(ry + rh, ty + 10) - math.max(ry, ty)
                    if overlapY > 0 and overlapY < 12 then
                        table.insert(cols, {
                            nx=0, ny=1, penetration=overlapY,
                            tileType=tt,
                        })
                    end
                end
            end
        end
    end
    return cols
end

function TileMap:isLethal(wx, wy)
    local row, col = self:worldToTile(wx, wy)
    return self:get(row, col) == TileMap.TYPES.SPIKE
end

function TileMap:isFinish(wx, wy)
    local row, col = self:worldToTile(wx, wy)
    return self:get(row, col) == TileMap.TYPES.FINISH
end

function TileMap:isCheckpoint(wx, wy)
    local row, col = self:worldToTile(wx, wy)
    return self:get(row, col) == TileMap.TYPES.CHECKPOINT
end

function TileMap:update(dt)
    self.animT = (self.animT or 0) + dt
end

-- ─── Draw background city (no math.randomseed!) ──────────────────────────────
function TileMap:drawBackground(camX, camY, screenW, screenH, layer)
    layer = layer or 1
    local parallax = layer == 1 and 0.18 or 0.42
    local offX = -camX * parallax
    local SH   = screenH
    local animT = self.animT or 0

    local buildings = bgBuildings[layer] or {}
    for _, b in ipairs(buildings) do
        local rx = b.x + offX
        if rx + b.w > -10 and rx < screenW + 10 then
            if layer == 1 then
                love.graphics.setColor(0.06, 0.06, 0.10, 1)
                love.graphics.rectangle("fill", rx, SH - b.h, b.w, b.h)
                -- sparse windows (deterministic)
                for wr = 0, math.floor(b.h / 22) do
                    for wc = 0, math.floor(b.w / 18) do
                        local ws = (wr * 13 + wc * 7 + math.floor(b.x)) % 10
                        if ws > 7 then
                            local wt = (ws + animT * 0.08 + b.seed * 8) % 10
                            if wt > 2 then
                                love.graphics.setColor(0.92, 0.82, 0.42, 0.10)
                                love.graphics.rectangle("fill", rx+5+wc*18, SH-b.h+8+wr*22, 8, 10)
                            end
                        end
                    end
                end
            else
                love.graphics.setColor(0.09, 0.10, 0.14, 1)
                love.graphics.rectangle("fill", rx, SH - b.h + 30, b.w, b.h - 30)
                for wr = 0, math.floor((b.h-30) / 16) do
                    for wc = 0, math.floor(b.w / 14) do
                        local ws = (wr * 17 + wc * 11 + math.floor(b.x)) % 10
                        if ws > 5 then
                            local wt = (ws + animT * 0.12 + b.seed * 12) % 10
                            local alpha = wt > 4 and 0.20 or 0.05
                            love.graphics.setColor(0.88, 0.78, 0.38, alpha)
                            love.graphics.rectangle("fill", rx+3+wc*14, SH-(b.h-30)+5+wr*16, 7, 9)
                        end
                    end
                end
                -- neon strip on some buildings
                if b.seed > 0.72 then
                    local nc = b.seed > 0.86
                        and {0.96, 0.42, 0.10}
                        or  {0.20, 0.70, 1.00}
                    local pulse = math.sin(animT * 2.2 + b.seed * 8) * 0.35 + 0.65
                    love.graphics.setColor(nc[1], nc[2], nc[3], 0.55 * pulse)
                    love.graphics.rectangle("fill", rx + b.w - 3, SH - (b.h - 30), 3, b.h - 30)
                end
            end
        end
    end
end

-- ─── Main tile draw ──────────────────────────────────────────────────────────
function TileMap:draw(camX, camY, screenW, screenH)
    local T     = TILE
    local animT = self.animT or 0
    local ox    = self.ox
    local oy    = self.oy

    local c1 = math.max(1, math.floor(camX / T))
    local c2 = math.min(self.cols, math.ceil((camX + screenW)  / T) + 1)
    local r1 = math.max(1, math.floor(camY / T))
    local r2 = math.min(self.rows, math.ceil((camY + screenH) / T) + 1)

    for row = r1, r2 do
        for col = c1, c2 do
            local tt = self.data[row] and self.data[row][col] or 0
            if tt ~= TileMap.TYPES.AIR then
                local tx = (col - 1) * T + ox - camX
                local ty = (row - 1) * T + oy - camY
                local sd = tileSeed(row, col)

                -- Check if this is a rooftop tile (tile above is air)
                local aboveIsAir = (row <= 1) or (self:get(row-1, col) == TileMap.TYPES.AIR)
                -- Check if tile above is solid (facade / interior wall)
                local aboveIsSolid = (row > 1) and (self:get(row-1, col) == TileMap.TYPES.SOLID)

                if tt == TileMap.TYPES.SOLID then
                    if aboveIsSolid then
                        -- Building facade with windows
                        local shade = 0.16 + sd * 0.06
                        love.graphics.setColor(shade, shade, shade + 0.04, 1)
                        love.graphics.rectangle("fill", tx, ty, T, T)
                        -- Window grid
                        local wpad = 5
                        local ww = (T - wpad*3) / 2
                        local wh = (T - wpad*3) / 2
                        for wr = 0, 1 do
                            for wc = 0, 1 do
                                local wx2 = tx + wpad + wc*(ww+wpad)
                                local wy2 = ty + wpad + wr*(wh+wpad)
                                love.graphics.setColor(0.08, 0.10, 0.14, 1)
                                love.graphics.rectangle("fill", wx2-1, wy2-1, ww+2, wh+2)
                                local wlit = (sd*7 + wr*3 + wc*5 + animT*0.04) % 1 > 0.38
                                if wlit then
                                    love.graphics.setColor(0.88, 0.78, 0.42, 0.85)
                                    love.graphics.rectangle("fill", wx2, wy2, ww, wh)
                                else
                                    love.graphics.setColor(0.05, 0.07, 0.11, 1)
                                    love.graphics.rectangle("fill", wx2, wy2, ww, wh)
                                end
                            end
                        end
                        love.graphics.setColor(1,1,1,0.04)
                        love.graphics.line(tx, ty, tx+T, ty)
                    else
                        -- Concrete / rooftop
                        local shade = 0.20 + sd * 0.08
                        love.graphics.setColor(shade, shade+0.02, shade+0.06, 1)
                        love.graphics.rectangle("fill", tx, ty, T, T)
                        -- Brick mortar
                        love.graphics.setColor(0.11, 0.12, 0.16, 0.8)
                        love.graphics.rectangle("fill", tx, ty+T/2-1, T, 2)
                        local voff = (row % 2 == 0) and 0 or T/2
                        love.graphics.rectangle("fill", tx+(T/2+voff)%T-1, ty, 2, T/2)
                        -- Top ledge cap
                        if aboveIsAir then
                            love.graphics.setColor(0.30, 0.32, 0.38, 1)
                            love.graphics.rectangle("fill", tx, ty, T, 5)
                            love.graphics.setColor(0.44, 0.46, 0.54, 1)
                            love.graphics.line(tx, ty, tx+T, ty)
                            -- Rooftop props
                            if sd > 0.82 then
                                love.graphics.setColor(0.24, 0.26, 0.32, 1)
                                love.graphics.rectangle("fill", tx+4, ty-14, 13, 14)
                                love.graphics.setColor(0.32, 0.34, 0.40, 1)
                                love.graphics.rectangle("fill", tx+3, ty-16, 15, 4, 1)
                            elseif sd > 0.70 then
                                love.graphics.setColor(0.30, 0.32, 0.38, 1)
                                love.graphics.setLineWidth(2)
                                love.graphics.line(tx+16, ty-2, tx+16, ty-18)
                                love.graphics.line(tx+10, ty-12, tx+22, ty-12)
                                love.graphics.setLineWidth(1)
                            end
                        else
                            love.graphics.setColor(1,1,1,0.05)
                            love.graphics.line(tx, ty, tx+T, ty)
                        end
                        -- Cracks on some tiles
                        if sd > 0.90 then
                            love.graphics.setColor(0.08, 0.08, 0.12, 0.55)
                            local cx2 = tx + sd*18 + 4
                            local cy2 = ty + sd*10 + 6
                            love.graphics.line(cx2, cy2, cx2+5, cy2+8, cx2+3, cy2+14)
                        end
                    end

                elseif tt == TileMap.TYPES.PLATFORM then
                    -- Metal fire-escape platform
                    love.graphics.setColor(0.18, 0.48, 0.28, 1)
                    love.graphics.rectangle("fill", tx, ty+T-10, T, 10, 2, 2)
                    love.graphics.setColor(0.28, 0.62, 0.38, 1)
                    love.graphics.line(tx, ty+T-10, tx+T, ty+T-10)
                    love.graphics.setColor(0.13, 0.38, 0.22, 0.7)
                    for gi = 0, 3 do
                        love.graphics.line(tx+gi*8+4, ty+T-9, tx+gi*8+4, ty+T-1)
                    end

                elseif tt == TileMap.TYPES.SPIKE then
                    love.graphics.setColor(0.16, 0.18, 0.23, 1)
                    love.graphics.rectangle("fill", tx, ty+T-8, T, 8)
                    love.graphics.setColor(0.75, 0.14, 0.14, 1)
                    for si = 0, 3 do
                        local sx = tx + si*8 + 4
                        love.graphics.polygon("fill", sx-3, ty+T, sx+3, ty+T, sx, ty+5)
                    end
                    love.graphics.setColor(1, 0.45, 0.45, 0.5)
                    for si = 0, 3 do
                        local sx = tx + si*8 + 4
                        love.graphics.line(sx, ty+5, sx+2, ty+T-3)
                    end

                elseif tt == TileMap.TYPES.BOUNCE then
                    love.graphics.setColor(0.85, 0.55, 0.10, 1)
                    love.graphics.rectangle("fill", tx, ty, T, T, 3, 3)
                    love.graphics.setColor(1.0, 0.75, 0.20, 1)
                    love.graphics.rectangle("fill", tx+2, ty+2, T-4, 8, 3)
                    love.graphics.setColor(0.65, 0.38, 0.05, 1)
                    for ci = 0, 2 do
                        local cx2 = tx + 7 + ci*9
                        love.graphics.setLineWidth(2)
                        love.graphics.line(cx2, ty+10, cx2-3, ty+18, cx2+3, ty+24, cx2, ty+T-4)
                        love.graphics.setLineWidth(1)
                    end
                    love.graphics.setColor(1,1,1,0.75)
                    love.graphics.setFont(love.graphics.newFont(10))
                    love.graphics.printf("↑", tx, ty+T/2-6, T, "center")

                elseif tt == TileMap.TYPES.ICE then
                    love.graphics.setColor(0.52, 0.80, 0.94, 1)
                    love.graphics.rectangle("fill", tx, ty, T, T)
                    love.graphics.setColor(0.72, 0.90, 1.0, 0.45)
                    love.graphics.polygon("fill", tx, ty, tx+T*0.45, ty, tx, ty+T*0.32)
                    love.graphics.setColor(0.88, 0.96, 1.0, 0.28)
                    love.graphics.polygon("fill", tx+T*0.5, ty+T*0.2, tx+T, ty, tx+T, ty+T*0.38)
                    love.graphics.setColor(0.88, 0.96, 1.0, 0.65)
                    love.graphics.line(tx, ty, tx+T, ty)

                elseif tt == TileMap.TYPES.FINISH then
                    local pulse = math.sin(animT * 4) * 0.5 + 0.5
                    love.graphics.setColor(0.06, 0.16, 0.10, 1)
                    love.graphics.rectangle("fill", tx, ty, T, T)
                    love.graphics.setColor(0.10, 0.85, 0.45, 0.28 + pulse*0.28)
                    love.graphics.rectangle("fill", tx-4, ty-4, T+8, T+8, 5)
                    love.graphics.setColor(0.10, 0.85, 0.45, 0.65 + pulse*0.25)
                    love.graphics.setLineWidth(2)
                    love.graphics.rectangle("line", tx+2, ty+2, T-4, T-4, 4)
                    love.graphics.setLineWidth(1)
                    for fr = 0, 1 do
                        for fc = 0, 1 do
                            if (fr+fc)%2 == 0 then
                                love.graphics.setColor(1, 1, 1, 0.45+pulse*0.2)
                            else
                                love.graphics.setColor(0.10, 0.85, 0.45, 0.45)
                            end
                            local hw = (T-12)/2
                            love.graphics.rectangle("fill",
                                tx+6+fc*(hw+2), ty+8+fr*(hw+2), hw, hw)
                        end
                    end

                elseif tt == TileMap.TYPES.CHECKPOINT then
                    local pulse = math.sin(animT * 3 + col*0.5) * 0.5 + 0.5
                    love.graphics.setColor(0.07, 0.09, 0.14, 1)
                    love.graphics.rectangle("fill", tx, ty, T, T)
                    love.graphics.setColor(0.32, 0.38, 0.46, 1)
                    love.graphics.rectangle("fill", tx+T/2-2, ty+4, 4, T-4)
                    love.graphics.setColor(0.20, 0.70, 1.00, 0.65+pulse*0.28)
                    local wave = math.sin(animT*5)*3
                    love.graphics.polygon("fill",
                        tx+T/2+2, ty+5,
                        tx+T/2+14+wave, ty+9,
                        tx+T/2+12+wave, ty+16,
                        tx+T/2+2, ty+18)
                end
            end
        end
    end
end

function TileMap:pixelWidth()  return self.cols * TILE end
function TileMap:pixelHeight() return self.rows * TILE end

return TileMap
