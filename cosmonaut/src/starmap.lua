local TAU = math.pi * 2

-- Fixed star positions for background nebula effect
local BG_STARS = {}
for i = 1, 300 do
    BG_STARS[i] = {
        x     = math.random(0, 1280),
        y     = math.random(0, 720),
        size  = math.random() * 1.8 + 0.3,
        alpha = math.random() * 0.7 + 0.2,
        drift = math.random() * 0.15,
    }
end

-- Orbital body definitions
local BODIES = {
    {name="Sun",      dist=0,    size=28, col={1.0,0.85,0.2,1}, period=0},
    {name="Mercury",  dist=60,   size=5,  col={0.7,0.65,0.6,1}, period=2.4},
    {name="Venus",    dist=90,   size=8,  col={0.9,0.7,0.4,1},  period=6.2},
    {name="Earth",    dist=130,  size=10, col={0.2,0.6,1.0,1},  period=10.0},
    {name="Moon",     dist=145,  size=4,  col={0.8,0.8,0.8,1},  period=10.8, parent="Earth"},
    {name="Mars",     dist=190,  size=8,  col={0.8,0.4,0.2,1},  period=18.8},
    {name="Ceres",    dist=245,  size=4,  col={0.6,0.6,0.5,1},  period=56.7},
    {name="Jupiter",  dist=310,  size=18, col={0.8,0.7,0.55,1}, period=118.6},
    {name="Saturn",   dist=400,  size=14, col={0.85,0.75,0.5,1},period=294.0},
    {name="Uranus",   dist=480,  size=11, col={0.5,0.85,0.9,1}, period=840.0},
    {name="Neptune",  dist=545,  size=10, col={0.3,0.4,0.9,1},  period=1650.0},
}

function drawStarmap(gs, cx, cy, t, zoom)
    zoom = zoom or 1.0
    t    = t    or (gs.starAnim or 0)

    -- Background stars
    love.graphics.setColor(0.6, 0.65, 0.8, 0.35)
    for _, s in ipairs(BG_STARS) do
        local px = cx + (s.x - 640) * zoom
        local py = cy + (s.y - 400) * zoom
        if px >= 0 and px <= 1280 and py >= 0 and py <= 720 then
            love.graphics.circle("fill", px, py, s.size * zoom)
        end
    end

    -- Orbit rings
    for _, b in ipairs(BODIES) do
        if b.dist > 0 and not b.parent then
            love.graphics.setColor(0.2, 0.3, 0.5, 0.22)
            love.graphics.circle("line", cx, cy, b.dist * zoom)
        end
    end

    -- Moon orbit ring (around Earth)
    local ex, ey = bodyPos("Earth", t, cx, cy, zoom)
    love.graphics.setColor(0.2, 0.3, 0.5, 0.15)
    love.graphics.circle("line", ex, ey, 15 * zoom)

    -- Bodies
    for _, b in ipairs(BODIES) do
        local bx, by = bodyPos(b.name, t, cx, cy, zoom)
        -- Glow
        love.graphics.setColor(b.col[1], b.col[2], b.col[3], 0.12)
        love.graphics.circle("fill", bx, by, b.size * zoom * 2.2)
        -- Body
        love.graphics.setColor(b.col[1], b.col[2], b.col[3], 1)
        love.graphics.circle("fill", bx, by, b.size * zoom)

        -- Saturn rings
        if b.name == "Saturn" then
            love.graphics.setColor(0.85, 0.75, 0.5, 0.4)
            love.graphics.ellipse("line", bx, by, b.size * zoom * 2.2, b.size * zoom * 0.55)
        end

        -- Exploration badge from agency data
        local explored = false
        if gs.agency then
            for _, ab in ipairs(gs.agency.bodies or {}) do
                if ab.name and b.name:find(ab.name) then
                    if ab.landed   then love.graphics.setColor(0.2, 1.0, 0.4, 0.9)
                    elseif ab.orbited then love.graphics.setColor(0.2, 0.7, 1.0, 0.9)
                    elseif ab.probed  then love.graphics.setColor(1.0, 0.8, 0.2, 0.9)
                    end
                    if ab.probed then
                        love.graphics.circle("line", bx, by, b.size * zoom + 5)
                        explored = true
                    end
                    break
                end
            end
        end

        -- Label
        love.graphics.setColor(0.75, 0.8, 0.9, 0.80)
        love.graphics.print(b.name, bx + b.size * zoom + 3, by - 7, 0, 0.78)
    end
end

function bodyPos(name, t, cx, cy, zoom)
    zoom = zoom or 1.0
    for _, b in ipairs(BODIES) do
        if b.name == name then
            if b.dist == 0 then return cx, cy end
            if b.parent == "Earth" then
                -- Moon orbits Earth
                local ex, ey = bodyPos("Earth", t, cx, cy, zoom)
                local angle = t * TAU / b.period
                return ex + math.cos(angle) * 15 * zoom,
                       ey + math.sin(angle) * 15 * zoom
            end
            local angle = (b.name == "Earth" and 0 or 0)
                + t * TAU / (b.period > 0 and b.period or 1000)
            return cx + math.cos(angle) * b.dist * zoom,
                   cy + math.sin(angle) * b.dist * zoom
        end
    end
    return cx, cy
end

-- Highlighted tooltip on hover
function starmapTooltip(gs, mx, my, cx, cy, t, zoom)
    zoom = zoom or 1.0
    for _, b in ipairs(BODIES) do
        local bx, by = bodyPos(b.name, t, cx, cy, zoom)
        local d = math.sqrt((mx-bx)^2 + (my-by)^2)
        if d < b.size * zoom + 10 then
            -- Draw tooltip
            local tx = math.min(bx + 16, 1180)
            local ty = by - 30
            love.graphics.setColor(0.05, 0.08, 0.18, 0.92)
            love.graphics.rectangle("fill", tx, ty, 160, 56, 3, 3)
            love.graphics.setColor(0.2, 0.4, 0.7, 0.6)
            love.graphics.rectangle("line", tx, ty, 160, 56, 3, 3)
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(b.name, tx+8, ty+6, 0, 0.92)
            -- Status from agency
            local status = "Unexplored"
            if gs.agency then
                for _, ab in ipairs(gs.agency.bodies or {}) do
                    if ab.name and b.name:find(ab.name) then
                        if ab.landed then status = "Landed"
                        elseif ab.orbited then status = "Orbited"
                        elseif ab.probed  then status = "Probed" end
                    end
                end
            end
            love.graphics.setColor(0.5, 0.75, 1.0, 0.9)
            love.graphics.print(status, tx+8, ty+26, 0, 0.82)
            if b.period > 0 then
                love.graphics.setColor(0.5, 0.55, 0.65, 0.7)
                love.graphics.print(string.format("Period: %.1f mo", b.period), tx+8, ty+40, 0, 0.72)
            end
            return
        end
    end
end
