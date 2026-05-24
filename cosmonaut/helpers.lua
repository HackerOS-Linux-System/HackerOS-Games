local lg = love.graphics

-- ── Color helpers ─────────────────────────────────────────────────────────────

function setColor(col, alpha)
    alpha = alpha or col[4] or 1
    lg.setColor(col[1], col[2], col[3], alpha)
end

function colorWithAlpha(col, a)
    return {col[1], col[2], col[3], a}
end

function colorDarken(col, factor)
    return {col[1]*factor, col[2]*factor, col[3]*factor, col[4] or 1}
end

-- ── Text helpers ──────────────────────────────────────────────────────────────

function drawText(text, x, y, size, col, alpha)
    setColor(col, alpha)
    local font = getFont(size)
    lg.setFont(font)
    lg.print(tostring(text), x, y)
end

function drawTextCentered(text, x, y, w, size, col)
    setColor(col)
    local font = getFont(size)
    lg.setFont(font)
    local tw = font:getWidth(tostring(text))
    lg.print(tostring(text), x + (w - tw)/2, y)
end

function measureText(text, size)
    local font = getFont(size)
    return font:getWidth(tostring(text))
end

-- ── Font cache ────────────────────────────────────────────────────────────────

local fontCache = {}
local monoCache = {}

function getFont(size)
    if not fontCache[size] then
        fontCache[size] = lg.newFont(size)
    end
    return fontCache[size]
end

-- ── Drawing primitives ────────────────────────────────────────────────────────

function drawRect(x, y, w, h, col, alpha)
    setColor(col, alpha)
    lg.rectangle("fill", x, y, w, h)
end

function drawRectLines(x, y, w, h, col, alpha)
    setColor(col, alpha)
    lg.rectangle("line", x, y, w, h)
end

function drawRectRounded(x, y, w, h, r, col, alpha)
    setColor(col, alpha)
    lg.rectangle("fill", x, y, w, h, r, r)
end

function drawRectRoundedLines(x, y, w, h, r, col, alpha)
    setColor(col, alpha)
    lg.rectangle("line", x, y, w, h, r, r)
end

function drawLine(x1, y1, x2, y2, col, alpha)
    setColor(col, alpha)
    lg.line(x1, y1, x2, y2)
end

function drawCircle(x, y, r, col, alpha)
    setColor(col, alpha)
    lg.circle("fill", x, y, r)
end

function drawCircleLines(x, y, r, col, alpha)
    setColor(col, alpha)
    lg.circle("line", x, y, r)
end

function drawEllipseLines(x, y, rx, ry, col, alpha)
    setColor(col, alpha)
    lg.ellipse("line", x, y, rx, ry, 64)
end

-- ── Panel ────────────────────────────────────────────────────────────────────

function panel(x, y, w, h, col)
    drawRect(x, y, w, h, col or COL_PANEL)
    drawRectLines(x, y, w, h, COL_BORDER)
end

function panelRounded(x, y, w, h, r, col)
    drawRectRounded(x, y, w, h, r, col or COL_PANEL)
    drawRectRoundedLines(x, y, w, h, r, COL_BORDER)
end

-- ── Section divider ───────────────────────────────────────────────────────────

function sectionLine(title, y)
    drawLine(20, y, SCREEN_W-20, y, COL_BORDER)
    local tw = measureText(title, 14)
    local cx = SCREEN_W/2 - tw/2
    drawRect(cx-8, y-9, tw+16, 18, COL_BG)
    drawText(title, cx, y-8, 14, COL_DIM)
end

-- ── Stat bar ──────────────────────────────────────────────────────────────────

function statBar(lbl, val, maxVal, x, y, w, col)
    drawText(lbl, x, y, 12, COL_DIM)
    local bx = x + 110
    local bw = w - 120
    drawRect(bx, y, bw, 11, COL_PANEL2)
    local fill = bw * math.max(0, math.min(1, val / math.max(maxVal, 1)))
    drawRect(bx, y, fill, 11, col)
    drawRectLines(bx, y, bw, 11, COL_BORDER)
    drawText(string.format("%d", math.floor(val)), bx+bw+4, y, 12, COL_TEXT)
end

-- ── Button ────────────────────────────────────────────────────────────────────

function button(text, x, y, w, h, col, disabled)
    local mx, my = love.mouse.getPosition()
    local hover = not disabled and mx >= x and mx <= x+w and my >= y and my <= y+h
    local clicked = hover and love.mouse.isDown(1) and gs_mouseJustPressed

    local bg
    if disabled then
        bg = {20/255, 22/255, 28/255, 200/255}
    elseif hover then
        bg = colorWithAlpha(col, 220/255)
        bg = {col[1]/3, col[2]/3, col[3]/3, 220/255}
    else
        bg = {col[1]/5, col[2]/5, col[3]/5, 200/255}
    end

    drawRectRounded(x, y, w, h, 3, bg)

    local borderCol
    if disabled then
        borderCol = COL_BORDER
    elseif hover then
        borderCol = col
    else
        borderCol = {col[1]/3, col[2]/3, col[3]/3, 200/255}
    end
    drawRectRoundedLines(x, y, w, h, 3, borderCol)

    -- Glow on hover
    if hover and not disabled then
        setColor(col, 0.08)
        lg.rectangle("fill", x+1, y+1, w-2, h-2, 3, 3)
    end

    local tw = measureText(text, 15)
    local tx = x + (w - tw)/2
    local ty = y + h/2 - 8
    local tcol = disabled and COL_DIM or (hover and col or COL_TEXT)
    drawText(text, tx, ty, 15, tcol)

    return hover and gs_mouseJustPressed
end

-- ── Name helpers ──────────────────────────────────────────────────────────────

function missionTypeName(t)
    local names = {
        OrbitalTest      = "Orbital Test",
        CrewedOrbit      = "Crewed Orbit",
        LunarFlyby       = "Lunar Flyby",
        LunarOrbit       = "Lunar Orbit",
        LunarLanding     = "Lunar Landing",
        MarsProbe        = "Mars Probe",
        MarsOrbiter      = "Mars Orbiter",
        MarsSurface      = "Mars Surface",
        AsteroidProbe    = "Asteroid Probe",
        SpaceStation     = "Space Station",
        DeepSpaceProbe   = "Deep Space",
        SatelliteNetwork = "Satellite Network",
        VenusProbe       = "Venus Probe",
        JupiterFlyby     = "Jupiter Flyby",
        SaturnFlyby      = "Saturn Flyby",
    }
    return names[t] or "Unknown"
end

function missionStatusStr(s)
    local m = {
        Planning="PLANNING", Building="BUILDING",
        ReadyToLaunch="READY", InFlight="IN FLIGHT",
        Success="SUCCESS", Failure="FAILURE", Aborted="ABORTED",
    }
    return m[s] or ""
end

function missionStatusCol(s)
    local m = {
        Planning="dim", Building="orange",
        ReadyToLaunch="cyan", InFlight="accent",
        Success="green", Failure="red", Aborted="red",
    }
    local key = m[s]
    if key == "dim"    then return COL_DIM
    elseif key == "orange" then return COL_ORANGE
    elseif key == "cyan"   then return COL_CYAN
    elseif key == "accent" then return COL_ACCENT
    elseif key == "green"  then return COL_GREEN
    elseif key == "red"    then return COL_RED
    end
    return COL_TEXT
end

function astronautStatusCol(s)
    if s == "Available" then return COL_GREEN
    elseif s == "Training"  then return COL_GOLD
    elseif s == "InFlight"  then return COL_ACCENT
    elseif s == "Retired"   then return COL_DIM
    elseif s == "Lost"      then return COL_RED
    end
    return COL_TEXT
end

function astronautStatusStr(s)
    local m = {
        Available="AVAILABLE", Training="IN TRAINING",
        InFlight="IN FLIGHT", Retired="RETIRED", Lost="LOST IN SPACE",
    }
    return m[s] or ""
end

function researchAreaName(a)
    local m = {
        PropulsionTech="Propulsion",  LifeSupport="Life Support",
        Navigation="Navigation",      MaterialScience="Materials",
        Robotics="Robotics",          NuclearPropulsion="Nuclear Prop.",
        ArtificialGravity="Art. Gravity", Cryogenics="Cryogenics",
        AdvancedSensors="Adv. Sensors",
    }
    return m[a] or "Research"
end

function researchAreaCol(a)
    if a == "PropulsionTech"    then return COL_ORANGE
    elseif a == "LifeSupport"       then return COL_GREEN
    elseif a == "Navigation"        then return COL_ACCENT
    elseif a == "MaterialScience"   then return COL_CYAN
    elseif a == "Robotics"          then return COL_PURPLE
    elseif a == "NuclearPropulsion" then return COL_RED
    elseif a == "ArtificialGravity" then return COL_GOLD
    elseif a == "Cryogenics"        then return COL_CYAN
    elseif a == "AdvancedSensors"   then return COL_ACCENT
    end
    return COL_TEXT
end

function monthName(m)
    local names = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return names[((m-1) % 12) + 1]
end

-- ── Notifications ─────────────────────────────────────────────────────────────

function pushNotification(gs, msg)
    gs.notification = msg
    gs.notifTimer = 4.0
end

function appendMissionLog(m, entry)
    if #m.log < 32 then
        table.insert(m.log, entry)
    else
        table.remove(m.log, 1)
        table.insert(m.log, entry)
    end
end

-- ── Math helpers ──────────────────────────────────────────────────────────────

function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

function lerp(a, b, t) return a + (b - a) * t end

function randInt(lo, hi) return lo + math.floor(math.random() * (hi - lo + 1)) end

-- ── Mouse helper ─────────────────────────────────────────────────────────────

function mouseIn(x, y, w, h)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x+w and my >= y and my <= y+h
end

function mouseInAndClicked(x, y, w, h)
    return mouseIn(x, y, w, h) and gs_mouseJustPressed
end
