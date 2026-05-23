local TileMap = {}
TileMap.__index = TileMap

local TILE  = 32  -- tile size in pixels

-- Tile types
TileMap.TYPES = {
    AIR       = 0,
    SOLID     = 1,
    PLATFORM  = 2,   -- one-way (stand on top)
    SPIKE     = 3,   -- instant death
    BOUNCE    = 4,   -- bouncy
    ICE       = 5,   -- low friction
    FINISH    = 6,   -- goal
    CHECKPOINT= 7,
}

-- Colours
local TILE_COLORS = {
    [1] = {0.22, 0.24, 0.30, 1},
    [2] = {0.18, 0.50, 0.30, 1},
    [3] = {0.80, 0.15, 0.15, 1},
    [4] = {0.90, 0.60, 0.15, 1},
    [5] = {0.55, 0.85, 0.95, 1},
    [6] = {0.10, 0.85, 0.45, 1},
    [7] = {0.20, 0.70, 1.00, 1},
}

function TileMap.new(data, offsetX, offsetY)
    local self  = setmetatable({}, TileMap)
    self.data   = data or {}   -- 2D array [row][col] = type
    self.rows   = #data
    self.cols   = data[1] and #data[1] or 0
    self.ox     = offsetX or 0
    self.oy     = offsetY or 0
    self.TILE   = TILE
    return self
end

function TileMap:get(row, col)
    if row < 1 or row > self.rows then return 0 end
    if col < 1 or col > self.cols then return 0 end
    return self.data[row][col] or 0
end

-- Convert world pos → tile index
function TileMap:worldToTile(wx, wy)
    local col = math.floor((wx - self.ox) / TILE) + 1
    local row = math.floor((wy - self.oy) / TILE) + 1
    return row, col
end

-- AABB rectangle collision with map tiles
-- Returns array of { nx, ny, penetration, tileType }
function TileMap:collideRect(rx, ry, rw, rh)
    local cols = {}
    local T  = TILE
    local ox, oy = self.ox, self.oy

    -- Broad phase: find tile range
    local c1 = math.floor((rx - ox)       / T) + 1
    local c2 = math.floor((rx - ox + rw)  / T) + 1
    local r1 = math.floor((ry - oy)       / T) + 1
    local r2 = math.floor((ry - oy + rh)  / T) + 1

    for row = r1, r2 do
        for col = c1, c2 do
            local tt = self:get(row, col)
            if tt == TileMap.TYPES.SOLID or tt == TileMap.TYPES.ICE or tt == TileMap.TYPES.BOUNCE then
                local tx = (col - 1) * T + ox
                local ty = (row - 1) * T + oy

                -- Overlap
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
                        nx          = nx,
                        ny          = ny,
                        penetration = pen,
                        tileType    = tt,
                        tx = tx, ty = ty,
                    })
                end
            elseif tt == TileMap.TYPES.PLATFORM then
                -- One-way: only from above
                local tx = (col - 1) * T + ox
                local ty = (row - 1) * T + oy
                local prevBottom = ry + rh - 4  -- approximate prev frame
                if prevBottom <= ty + 2 then
                    local overlapY = math.min(ry + rh, ty + 8) - math.max(ry, ty)
                    if overlapY > 0 then
                        table.insert(cols, {
                            nx = 0, ny = 1, penetration = overlapY,
                            tileType = tt,
                        })
                    end
                end
            end
        end
    end
    return cols
end

-- Check if a tile at world pos is lethal
function TileMap:isLethal(wx, wy)
    local row, col = self:worldToTile(wx, wy)
    return self:get(row, col) == TileMap.TYPES.SPIKE
end

-- Check finish
function TileMap:isFinish(wx, wy)
    local row, col = self:worldToTile(wx, wy)
    return self:get(row, col) == TileMap.TYPES.FINISH
end

function TileMap:draw(camX, camY, screenW, screenH)
    local T  = TILE
    local ox, oy = self.ox - camX, self.oy - camY

    -- Visible tile range
    local c1 = math.max(1, math.floor(camX / T))
    local c2 = math.min(self.cols, math.ceil((camX + screenW) / T) + 1)
    local r1 = math.max(1, math.floor(camY / T))
    local r2 = math.min(self.rows, math.ceil((camY + screenH) / T) + 1)

    for row = r1, r2 do
        for col = c1, c2 do
            local tt = self.data[row] and self.data[row][col] or 0
            if tt ~= TileMap.TYPES.AIR then
                local tx = (col - 1) * T + ox
                local ty = (row - 1) * T + oy
                local color = TILE_COLORS[tt] or {0.5, 0.5, 0.5, 1}

                -- Tile fill
                love.graphics.setColor(color)
                love.graphics.rectangle("fill", tx, ty, T, T)

                -- Edge highlight
                love.graphics.setColor(color[1]*1.3, color[2]*1.3, color[3]*1.3, 0.6)
                love.graphics.line(tx, ty, tx + T, ty)
                love.graphics.line(tx, ty, tx, ty + T)

                -- Spike visuals
                if tt == TileMap.TYPES.SPIKE then
                    love.graphics.setColor(0.95, 0.25, 0.25)
                    for i = 0, 3 do
                        local sx = tx + i * 8 + 4
                        love.graphics.polygon("fill",
                            sx - 3, ty + T,
                            sx + 3, ty + T,
                            sx,     ty + 6)
                    end
                end

                -- Finish line
                if tt == TileMap.TYPES.FINISH then
                    love.graphics.setColor(0.10, 0.85, 0.45, 0.4)
                    love.graphics.rectangle("fill", tx, ty, T, T)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setFont(love.graphics.newFont(10))
                    love.graphics.printf("▶|", tx, ty + T/2 - 8, T, "center")
                end

                -- Checkpoint
                if tt == TileMap.TYPES.CHECKPOINT then
                    love.graphics.setColor(0.20, 0.70, 1.00, 0.5 + 0.3 * math.sin(love.timer.getTime() * 4))
                    love.graphics.rectangle("fill", tx + 6, ty, 4, T)
                end
            end
        end
    end
end

function TileMap:pixelWidth()  return self.cols * TILE end
function TileMap:pixelHeight() return self.rows * TILE end

return TileMap
