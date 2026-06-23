local lg = love.graphics

-- ═══════════════════════════════════════════════════════════════════════════════
-- MAIN MENU
-- ═══════════════════════════════════════════════════════════════════════════════

function drawMainMenu(gs)
    -- Title
    local title = "COSMONAUT"
    local tw = measureText(title, 72)
    drawText(title, SCREEN_W/2 - tw/2, SCREEN_H * 0.16, 72, COL_ACCENT)

    local sub = "SPACE AGENCY MANAGEMENT"
    local sw = measureText(sub, 18)
    drawText(sub, SCREEN_W/2 - sw/2, SCREEN_H * 0.16 + 80, 18, COL_DIM)

    -- Decorative orbit rings
    drawEllipseLines(SCREEN_W/2, SCREEN_H/2 + 40, 280, 100, COL_BORDER, 0.1)
    drawEllipseLines(SCREEN_W/2, SCREEN_H/2 + 40, 200, 72,  COL_BORDER, 0.07)
    drawEllipseLines(SCREEN_W/2, SCREEN_H/2 + 40, 360, 130, COL_BORDER, 0.05)

    -- Animated dot on orbit
    local angle = gs.starAnim * 0.4
    local dx = SCREEN_W/2 + 280 * math.cos(angle)
    local dy = SCREEN_H/2 + 40 + 100 * math.sin(angle)
    drawCircle(dx, dy, 5, COL_ACCENT, 0.8)

    drawLine(SCREEN_W/2 - 180, SCREEN_H * 0.38, SCREEN_W/2 + 180, SCREEN_H * 0.38, COL_BORDER)

    local bw = 260
    local bh = 48
    local bx = SCREEN_W/2 - bw/2

    if button("NEW AGENCY",   bx, SCREEN_H * 0.42,      bw, bh, COL_ACCENT) then
        gs.screen     = SCREENS.NEW_GAME
        gs.setupStep  = 0
        gs.inputBuf   = ""
        gs.selected   = 1
    end
    if button("ABOUT / HELP", bx, SCREEN_H * 0.42 + 62, bw, bh, COL_DIM) then
        pushNotification(gs, "Cosmonaut v2.0 — A space agency management game written in Lua/LÖVE")
    end

    drawText("v2.0 — LÖVE Edition", SCREEN_W - 200, SCREEN_H - 22, 13, COL_DIM)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- NEW GAME
-- ═══════════════════════════════════════════════════════════════════════════════

local ERAS = {
    {name="Space Race (1957)", year=1957, budget=300,  income=30, desc="Humble beginnings. Limited technology."},
    {name="Apollo Era (1960)", year=1960, budget=500,  income=45, desc="Lunar ambitions. Improved rockets."},
    {name="Shuttle Era (1975)",year=1975, budget=800,  income=65, desc="Reusability focus. Larger budgets."},
    {name="Modern Era (1995)", year=1995, budget=1200, income=90, desc="Advanced tech. Commercial partnerships."},
}

function drawNewGame(gs)
    drawText("ESTABLISH YOUR SPACE AGENCY", 30, 34, 26, COL_TEXT)
    drawLine(30, 68, SCREEN_W - 30, 68, COL_BORDER)

    drawText("Agency Name:", 80, 108, 18, COL_DIM)
    drawRect(80, 132, 500, 42, COL_PANEL2)
    drawRectLines(80, 132, 500, 42, COL_ACCENT)
    drawText(gs.inputBuf .. "|", 92, 143, 20, COL_TEXT)

    drawText("Starting Era:", 80, 196, 18, COL_DIM)
    for i, e in ipairs(ERAS) do
        local ey  = 216 + (i-1) * 76
        local sel = gs.selected == i
        drawRect(80, ey, 500, 68, sel and {20/255,40/255,80/255,0.78} or COL_PANEL)
        drawRectLines(80, ey, 500, 68, sel and COL_ACCENT or COL_BORDER)
        drawText(e.name, 96, ey + 10, 18, sel and COL_ACCENT or COL_TEXT)
        drawText(e.desc, 96, ey + 32, 13, COL_DIM)
        drawText(string.format("$%dM start  |  $%dM/mo", e.budget, e.income), 96, ey + 50, 12, COL_DIM)
        if mouseInAndClicked(80, ey, 500, 68) then gs.selected = i end
    end

    local canStart = #gs.inputBuf > 0
    if button("FOUND AGENCY ->", SCREEN_W/2 - 140, SCREEN_H - 82, 280, 48, COL_ACCENT, not canStart) then
        local e       = ERAS[gs.selected or 1]
        gs.agency     = newAgency(gs.inputBuf)
        gs.agency.year           = e.year
        gs.agency.budget         = e.budget
        gs.agency.monthly_income = e.income
        gs.screen   = SCREENS.DASHBOARD
        gs.selected = -1
    end
    if button("<- BACK", 30, SCREEN_H - 82, 120, 42, COL_DIM) then
        gs.screen = SCREENS.MAIN_MENU
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DASHBOARD
-- ═══════════════════════════════════════════════════════════════════════════════

function drawDashboard(gs)
    local a = gs.agency
    drawText("MISSION CONTROL", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    -- Stats row
    local statsData = {
        {lbl="BUDGET",     val=string.format("$%dM",  a.budget),         col=COL_GREEN},
        {lbl="PRESTIGE",   val=string.format("%d pts", a.prestige),       col=COL_GOLD},
        {lbl="SCIENCE",    val=string.format("%d pts", a.science_pts),    col=COL_CYAN},
        {lbl="REPUTATION", val=string.format("%d%%",   a.reputation),     col=COL_ACCENT},
        {lbl="INCOME",     val=string.format("+$%dM/mo", a.monthly_income),col=COL_GREEN},
    }
    local sw = (SCREEN_W - 40) / #statsData
    for i, s in ipairs(statsData) do
        local sx = 20 + (i-1) * sw
        drawRect(sx, 92, sw - 4, 58, COL_PANEL)
        drawRectLines(sx, 92, sw - 4, 58, COL_BORDER)
        drawText(s.lbl, sx + 10, 102, 12, COL_DIM)
        drawText(s.val,  sx + 10, 118, 18, s.col)
    end

    -- Milestone ribbon
    if a.milestones then
        local mx2 = 20
        local my2 = 156
        local ms = {
            {key="orbit",         label="ORBIT",         col=COL_CYAN},
            {key="moon_orbit",    label="MOON ORBIT",    col=COL_GOLD},
            {key="moon_landing",  label="MOON LANDING",  col=COL_GREEN},
            {key="mars",          label="MARS",          col=COL_RED},
        }
        for _, milestone in ipairs(ms) do
            local done = a.milestones[milestone.key]
            local c    = done and milestone.col or COL_DIM
            drawRect(mx2, my2, 130, 18, COL_PANEL2)
            drawRectLines(mx2, my2, 130, 18, done and c or COL_BORDER)
            drawTextCentered(milestone.label, mx2, my2 + 2, 130, 12, c)
            mx2 = mx2 + 136
        end
    end

    -- Active missions
    sectionLine("ACTIVE MISSIONS", 182)
    local activeCount = 0
    for _, m in ipairs(a.missions) do
        if m.status == "InFlight" or m.status == "ReadyToLaunch" then
            local my3 = 196 + activeCount * 52
            if my3 > SCREEN_H - 220 then break end
            panel(20, my3, SCREEN_W - 40, 46, COL_PANEL)
            local sc = missionStatusCol(m.status)
            drawRect(20, my3, 4, 46, sc)
            drawText(m.name, 32, my3 + 7, 17, COL_TEXT)
            drawText(missionTypeName(m.mission_type), 32, my3 + 28, 12, COL_DIM)
            local prog = m.elapsed / math.max(m.duration, 1)
            drawRect(300, my3 + 14, 300, 14, COL_PANEL2)
            drawRect(300, my3 + 14, 300 * prog, 14, sc)
            drawRectLines(300, my3 + 14, 300, 14, COL_BORDER)
            drawText(string.format("Mo %d/%d", m.elapsed, m.duration), 608, my3 + 16, 13, COL_DIM)
            drawText("-> " .. m.destination, SCREEN_W - 200, my3 + 16, 13, COL_ACCENT)
            activeCount = activeCount + 1
        end
    end
    if activeCount == 0 then
        drawText("No active missions. Plan one in MISSIONS.", 40, 200, 15, COL_DIM)
    end

    -- Events
    local ey2 = 196 + math.max(activeCount, 1) * 52 + 18
    sectionLine("RECENT EVENTS", ey2)
    for i, ev in ipairs(a.events) do
        local ly = ey2 + 16 + (i-1) * 21
        if ly > SCREEN_H - 110 then break end
        drawText(ev, 28, ly, 13, COL_DIM)
    end
    if #a.events == 0 then drawText("No events yet.", 28, ey2 + 16, 13, COL_DIM) end

    -- Rival news ticker
    for i, rn in ipairs(gs.rivalNews or {}) do
        local ry = SCREEN_H - 120 - i * 18
        drawText("[RIVAL] " .. rn.msg, 20, ry, 13, rn.col or COL_RED)
    end

    -- Advance month button
    if button("ADVANCE MONTH", SCREEN_W - 212, SCREEN_H - 96, 196, 42, COL_ACCENT) then
        advanceMonth(gs)
    end
    drawText("[SPACE]", SCREEN_W - 196, SCREEN_H - 50, 12, COL_DIM)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROCKETS
-- ═══════════════════════════════════════════════════════════════════════════════

function drawRockets(gs)
    local a = gs.agency
    drawText("ROCKET FLEET", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    for i, r in ipairs(a.rockets) do
        local ry = 92 + (i-1) * 160
        if ry > SCREEN_H - 150 then break end
        local sel = gs.selected == i
        drawRect(20, ry, SCREEN_W - 40, 150, sel and {15/255,25/255,50/255,0.86} or COL_PANEL)
        drawRectLines(20, ry, SCREEN_W - 40, 150, sel and COL_ACCENT or COL_BORDER)

        drawText(r.name, 36, ry + 10, 22, COL_ACCENT)
        drawText(string.format("VEHICLE #%02d", r.id), 36, ry + 36, 13, COL_DIM)

        statBar("RELIABILITY", r.reliability * 99, 99, 36, ry + 56, 280, COL_GREEN)
        statBar("PAYLOAD kg",  r.payload_kg,       50000, 36, ry + 76, 280, COL_ACCENT)

        for si, s in ipairs(r.stages) do
            local sx = 420 + (si-1) * 190
            drawRect(sx, ry + 10, 182, 88, COL_PANEL2)
            drawRectLines(sx, ry + 10, 182, 88, COL_BORDER)
            drawText(string.format("Stage %d: %s", si, s.name), sx + 6, ry + 18, 11, COL_DIM)
            drawText(string.format("Thrust: %.0f kN", s.thrust_kn), sx + 6, ry + 34, 12, COL_TEXT)
            drawText(string.format("Isp:    %.0f s",  s.isp),       sx + 6, ry + 50, 12, COL_TEXT)
            if s.reusable then drawText("REUSABLE", sx + 6, ry + 68, 12, COL_GREEN) end
        end

        local rcol = r.reliability > 0.85 and COL_GREEN or (r.reliability > 0.70 and COL_GOLD or COL_RED)
        drawText(string.format("Launches: %d  Successes: %d  Cost: $%.0fM  |  %.0f%% reliability",
            r.launches, r.successes, r.cost_million, r.reliability * 100),
            36, ry + 128, 13, rcol)

        if mouseInAndClicked(20, ry, SCREEN_W - 40, 150) then gs.selected = i end
    end

    if button("+ DESIGN NEW ROCKET", 20, SCREEN_H - 96, 225, 44, COL_ORANGE) then
        gs.screen   = SCREENS.ROCKET_DESIGN
        gs.selected = -1
        gs.inputBuf = ""
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ROCKET DESIGN
-- ═══════════════════════════════════════════════════════════════════════════════

local ROCKET_CONFIGS = {
    {name="Light Scout",    payload=500,   cost=25,  rel=0.88, stages=2, desc="Small payload. Good for probes."},
    {name="Medium Lifter",  payload=3500,  cost=65,  rel=0.82, stages=2, desc="Balanced workhorse. Most missions."},
    {name="Heavy Lift",     payload=15000, cost=140, rel=0.76, stages=3, desc="Large payloads. Stations, landers."},
    {name="Super Heavy",    payload=50000, cost=320, rel=0.68, stages=3, desc="Mars and beyond. Very expensive."},
    {name="Crewed Rocket",  payload=8000,  cost=120, rel=0.85, stages=3, desc="Crew safety optimized."},
    {name="Reusable Booster",payload=6000, cost=90,  rel=0.87, stages=2, desc="First stage recovery. Lower ops cost."},
}

function drawRocketDesign(gs)
    local a = gs.agency
    drawText("ROCKET DESIGN LAB", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)
    drawText("Select base configuration:", 30, 98, 16, COL_DIM)

    for i, c in ipairs(ROCKET_CONFIGS) do
        local cy  = 116 + (i-1) * 78
        local sel = gs.selected == i
        drawRect(30, cy, SCREEN_W - 260, 72, sel and {15/255,30/255,60/255,0.86} or COL_PANEL)
        drawRectLines(30, cy, SCREEN_W - 260, 72, sel and COL_ACCENT or COL_BORDER)
        drawText(c.name, 46, cy + 10, 18, sel and COL_ACCENT or COL_TEXT)
        drawText(c.desc, 46, cy + 32, 13, COL_DIM)
        drawText(string.format("Payload: %.0f kg  |  $%.0fM  |  %.0f%% rel  |  %d stages",
            c.payload, c.cost, c.rel * 100, c.stages), 46, cy + 52, 12, COL_DIM)
        if mouseInAndClicked(30, cy, SCREEN_W - 260, 72) then gs.selected = i end
    end

    -- Name input
    drawText("Rocket Name:", 30, SCREEN_H - 172, 16, COL_DIM)
    drawRect(30, SCREEN_H - 150, 400, 36, COL_PANEL2)
    drawRectLines(30, SCREEN_H - 150, 400, 36, COL_ACCENT)
    drawText(gs.inputBuf .. "|", 42, SCREEN_H - 141, 18, COL_TEXT)

    local canBuild = gs.selected >= 1 and #gs.inputBuf > 0 and #a.rockets < 8
    if gs.selected >= 1 then
        local c    = ROCKET_CONFIGS[gs.selected]
        local ccol = a.budget >= c.cost and COL_GREEN or COL_RED
        drawText(string.format("Cost: $%.0fM", c.cost), 450, SCREEN_H - 141, 16, ccol)
        canBuild = canBuild and a.budget >= c.cost
    end

    if button("BUILD ROCKET", 30, SCREEN_H - 96, 200, 44, COL_ORANGE, not canBuild) then
        local c = ROCKET_CONFIGS[gs.selected]
        a.budget = a.budget - c.cost
        local r = {
            id           = #a.rockets + 1,
            name         = gs.inputBuf,
            stages = {
                {name="First Stage",  thrust_kn=800, isp=290, fuel_tons=60, dry_mass=6.0, reusable=(c.name=="Reusable Booster")},
                {name="Upper Stage",  thrust_kn=100, isp=320, fuel_tons=12, dry_mass=1.5, reusable=false},
                {name="Third Stage",  thrust_kn=20,  isp=340, fuel_tons=3,  dry_mass=0.4, reusable=false},
            },
            stage_count  = c.stages,
            payload_kg   = c.payload,
            cost_million = c.cost,
            reliability  = c.rel,
            built        = true,
            launches     = 0,
            successes    = 0,
        }
        table.insert(a.rockets, r)
        pushNotification(gs, "Rocket built: " .. r.name)
        gs.screen   = SCREENS.ROCKETS
        gs.inputBuf = ""
        gs.selected = -1
    end
    if button("<- CANCEL", 250, SCREEN_H - 96, 130, 44, COL_DIM) then
        gs.screen   = SCREENS.ROCKETS
        gs.inputBuf = ""
        gs.selected = -1
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ASTRONAUTS
-- ═══════════════════════════════════════════════════════════════════════════════

local RECRUIT_POOL = {
    {name="Elena Sorokina",  nat="RUS", pil=72, sci=80, eng=68, end_=75},
    {name="Kwame Mensah",    nat="GHA", pil=65, sci=78, eng=82, end_=80},
    {name="Yuki Tanaka",     nat="JPN", pil=80, sci=85, eng=75, end_=72},
    {name="Lars Eriksson",   nat="SWE", pil=75, sci=70, eng=88, end_=85},
    {name="Priya Sharma",    nat="IND", pil=68, sci=90, eng=72, end_=78},
    {name="Omar Al-Rashid",  nat="UAE", pil=78, sci=74, eng=80, end_=82},
    {name="Mei Lin",         nat="CHN", pil=85, sci=80, eng=77, end_=80},
    {name="Amara Diallo",    nat="SEN", pil=70, sci=82, eng=75, end_=88},
}

function drawAstronauts(gs)
    local a = gs.agency
    drawText("ASTRONAUT CORPS", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    local available = 0
    for _, ast in ipairs(a.astronauts) do
        if ast.status == "Available" then available = available + 1 end
    end
    drawText(string.format("Astronauts: %d  |  Available: %d", #a.astronauts, available), 20, 92, 15, COL_DIM)

    for i, ast in ipairs(a.astronauts) do
        local ay  = 112 + (i-1) * 108
        if ay > SCREEN_H - 110 then break end
        local sel = gs.selected == i
        drawRect(20, ay, SCREEN_W - 40, 100, sel and {10/255,20/255,40/255,0.86} or COL_PANEL)
        drawRectLines(20, ay, SCREEN_W - 40, 100, sel and COL_GREEN or COL_BORDER)

        local sc = astronautStatusCol(ast.status)
        drawRect(20, ay, 4, 100, sc)

        drawText(ast.name, 34, ay + 8, 20, COL_TEXT)
        drawText(string.format("%s  Age %d  %d missions", ast.nationality, ast.age, ast.missions_completed or 0),
            34, ay + 32, 13, COL_DIM)
        drawText(astronautStatusStr(ast.status), 34, ay + 54, 13, sc)
        if ast.specialization then
            drawText("SPEC: " .. ast.specialization, 34, ay + 72, 12, COL_PURPLE)
        end

        local hw = (SCREEN_W - 40) / 4.5
        statBar("PILOT",   ast.piloting,    99, 280, ay + 12, hw, COL_ACCENT)
        statBar("SCIENCE", ast.science,     99, 280, ay + 30, hw, COL_CYAN)
        statBar("ENG",     ast.engineering, 99, 280, ay + 48, hw, COL_ORANGE)
        statBar("ENDUR.",  ast.endurance,   99, 280, ay + 66, hw, COL_GREEN)

        local ovr  = math.floor((ast.piloting + ast.science + ast.engineering + ast.endurance) / 4)
        drawText(string.format("OVR %d", ovr), SCREEN_W - 120, ay + 28, 20, COL_GOLD)
        local mcol = ast.morale > 60 and COL_GREEN or (ast.morale > 30 and COL_GOLD or COL_RED)
        drawText(string.format("Morale %d%%", ast.morale), SCREEN_W - 120, ay + 58, 13, mcol)

        -- Experience stars
        local stars = math.min(ast.experience or 0, 5)
        for si = 1, 5 do
            local scol2 = si <= stars and COL_GOLD or COL_BORDER
            drawText(si <= stars and "*" or ".", SCREEN_W - 200 + (si-1)*16, ay + 28, 18, scol2)
        end

        if mouseInAndClicked(20, ay, SCREEN_W - 40, 100) then gs.selected = i end
    end

    local canRecruit = a.budget >= 30 and #a.astronauts < 16
    if button(string.format("+ RECRUIT ($30M)"), 20, SCREEN_H - 96, 230, 44, COL_GREEN, not canRecruit) then
        if a.budget >= 30 then
            a.budget = a.budget - 30
            local idx  = (#a.astronauts % #RECRUIT_POOL) + 1
            local pool = RECRUIT_POOL[idx]
            local ast  = {
                id          = #a.astronauts + 1,
                name        = pool.name,
                nationality = pool.nat,
                age         = randInt(26, 38),
                piloting    = pool.pil + randInt(-5, 5),
                science     = pool.sci + randInt(-5, 5),
                engineering = pool.eng + randInt(-5, 5),
                endurance   = pool.end_ + randInt(-5, 5),
                experience  = 0,
                status      = "Available",
                morale      = 80,
                missions_completed   = 0,
                total_flight_months  = 0,
            }
            table.insert(a.astronauts, ast)
            pushNotification(gs, "Recruited: " .. ast.name)
        end
    end

    -- Assign specialization button for selected
    if gs.selected >= 1 then
        local ast = a.astronauts[gs.selected]
        if ast and ast.status == "Available" and not ast.specialization and ast.experience >= 2 then
            if button("ASSIGN SPEC", 270, SCREEN_H - 96, 180, 44, COL_PURPLE) then
                -- Determine best stat
                local stats = {
                    {name="Pilot",    v=ast.piloting},
                    {name="Scientist",v=ast.science},
                    {name="Engineer", v=ast.engineering},
                }
                table.sort(stats, function(a2,b2) return a2.v > b2.v end)
                ast.specialization = stats[1].name
                pushNotification(gs, ast.name .. " specialized as " .. ast.specialization)
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MISSIONS
-- ═══════════════════════════════════════════════════════════════════════════════

local MISSION_TABS = {"ALL", "ACTIVE", "COMPLETED", "FAILED"}

function drawMissions(gs)
    local a = gs.agency
    drawText("MISSION MANIFEST", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    for i, lbl in ipairs(MISSION_TABS) do
        local tx     = 20 + (i-1) * 110
        local active = gs.tab == i
        local tcol   = active and COL_GOLD or COL_DIM
        drawRect(tx, 92, 106, 24, active and {40/255,30/255,5/255,0.78} or COL_PANEL)
        drawRectLines(tx, 92, 106, 24, active and COL_GOLD or COL_BORDER)
        drawTextCentered(lbl, tx, 99, 106, 13, tcol)
        if mouseInAndClicked(tx, 92, 106, 24) then gs.tab = i end
    end

    local row = 0
    for i, m in ipairs(a.missions) do
        local show = false
        if gs.tab == 1 then show = true
        elseif gs.tab == 2 then show = m.status == "InFlight" or m.status == "ReadyToLaunch" or m.status == "Planning"
        elseif gs.tab == 3 then show = m.status == "Success"
        elseif gs.tab == 4 then show = m.status == "Failure" or m.status == "Aborted"
        end
        if not show then goto cont end

        local my2 = 124 + row * 66
        if my2 > SCREEN_H - 110 then break end

        local sc  = missionStatusCol(m.status)
        local sel = gs.selected == i
        drawRect(20, my2, SCREEN_W - 40, 60, sel and {10/255,18/255,36/255,0.86} or COL_PANEL)
        drawRectLines(20, my2, SCREEN_W - 40, 60, sel and sc or COL_BORDER)
        drawRect(20, my2, 4, 60, sc)

        drawText(m.name, 32, my2 + 6, 18, COL_TEXT)
        drawText(missionTypeName(m.mission_type), 32, my2 + 30, 13, COL_DIM)
        drawText(missionStatusStr(m.status), 280, my2 + 18, 15, sc)

        if m.status == "InFlight" then
            local prog = m.elapsed / math.max(m.duration, 1)
            drawRect(420, my2 + 18, 240, 14, COL_PANEL2)
            drawRect(420, my2 + 18, 240 * prog, 14, COL_ACCENT)
            drawRectLines(420, my2 + 18, 240, 14, COL_BORDER)
            drawText(string.format("Mo %d/%d", m.elapsed, m.duration), 668, my2 + 20, 12, COL_DIM)
        end

        drawText(string.format("*%d  S%d  $%dM", m.prestige, m.science, m.cost), SCREEN_W - 200, my2 + 18, 13, COL_GOLD)
        drawText("-> " .. m.destination, SCREEN_W - 200, my2 + 36, 12, COL_ACCENT)

        if mouseInAndClicked(20, my2, SCREEN_W - 40, 60) then
            gs.selected    = i
            gs.prevScreen  = SCREENS.MISSIONS
            gs.screen      = SCREENS.MISSION_LOG
        end
        row = row + 1
        ::cont::
    end

    if button("+ PLAN MISSION", 20, SCREEN_H - 96, 200, 44, COL_GOLD) then
        gs.screen    = SCREENS.MISSION_PLAN
        gs.selected  = -1
        gs.selected2 = -1
        gs.inputBuf  = ""
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MISSION PLAN
-- ═══════════════════════════════════════════════════════════════════════════════

function drawMissionPlan(gs)
    local a = gs.agency
    drawText("PLAN NEW MISSION", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    sectionLine("MISSION TYPE", 92)
    local cols = 5
    local mt_w = (SCREEN_W - 40) / cols
    local mt_h = 52

    for i, mtype in ipairs(MISSION_TYPES) do
        local tx = 20 + ((i-1) % cols) * mt_w
        local ty = 102 + math.floor((i-1) / cols) * mt_h
        local sel = gs.selected == i
        local tcol
        if mtype:find("Lunar") then tcol = COL_GOLD
        elseif mtype:find("Mars") then tcol = COL_RED
        elseif mtype == "CrewedOrbit" or mtype == "SpaceStation" then tcol = COL_GREEN
        elseif mtype:find("Deep") or mtype:find("Asteroid") then tcol = COL_PURPLE
        elseif mtype:find("Venus") or mtype:find("Jupiter") or mtype:find("Saturn") then tcol = COL_CYAN
        else tcol = COL_ACCENT end

        drawRect(tx, ty, mt_w - 4, mt_h - 4, sel and colorWithAlpha(tcol, 0.18) or COL_PANEL)
        drawRectLines(tx, ty, mt_w - 4, mt_h - 4, sel and tcol or COL_BORDER)
        drawTextCentered(missionTypeName(mtype), tx, ty + 7, mt_w - 4, 13, sel and tcol or COL_TEXT)
        drawText(string.format("*%d", missionPrestige(mtype)), tx + 4, ty + 28, 11, COL_GOLD)
        drawText(string.format("%dmo", missionDuration(mtype)), tx + mt_w - 36, ty + 28, 11, COL_DIM)
        if mouseInAndClicked(tx, ty, mt_w - 4, mt_h - 4) then gs.selected = i end
    end

    local rowCount = math.ceil(#MISSION_TYPES / cols)
    local bottomY  = 102 + rowCount * mt_h + 10

    -- Rocket selector
    sectionLine("ROCKET", bottomY)
    for i, r in ipairs(a.rockets) do
        local rx  = 20 + (i-1) * 220
        if rx > SCREEN_W - 220 then break end
        local sel = gs.selected2 == i
        drawRect(rx, bottomY + 12, 214, 50, sel and {15/255,30/255,60/255,0.86} or COL_PANEL)
        drawRectLines(rx, bottomY + 12, 214, 50, sel and COL_ACCENT or COL_BORDER)
        drawText(r.name, rx + 6, bottomY + 20, 14, sel and COL_ACCENT or COL_TEXT)
        drawText(string.format("%.0f%% rel  %.0fkg PL", r.reliability*100, r.payload_kg), rx + 6, bottomY + 40, 12, COL_DIM)
        if mouseInAndClicked(rx, bottomY + 12, 214, 50) then gs.selected2 = i end
    end

    -- Mission name
    local nameY = bottomY + 72
    sectionLine("MISSION NAME", nameY)
    drawRect(20, nameY + 12, 400, 34, COL_PANEL2)
    drawRectLines(20, nameY + 12, 400, 34, COL_ACCENT)
    drawText(gs.inputBuf .. "|", 30, nameY + 19, 16, COL_TEXT)

    -- Preview stats
    if gs.selected >= 1 and gs.selected2 >= 1 then
        local mtype = MISSION_TYPES[gs.selected]
        local r     = a.rockets[gs.selected2]
        local cost  = missionCost(mtype, r)
        local chance = missionBaseChance(mtype, r, a)
        local ccol  = a.budget >= cost and COL_GREEN or COL_RED
        drawText(string.format("$%dM  |  %.0f%% success  |  %d months  |  *%d prestige",
            cost, chance*100, missionDuration(mtype), missionPrestige(mtype)),
            430, nameY + 19, 13, ccol)
    end

    -- Crew assignment for crewed missions
    if gs.selected >= 1 then
        local mtype = MISSION_TYPES[gs.selected]
        if missionNeedsCrew(mtype) then
            drawText("CREWED MISSION: Assign astronauts on the Crew tab before launch.", 20, nameY + 54, 13, COL_GOLD)
        end
    end

    local canPlan = gs.selected >= 1 and gs.selected2 >= 1 and #gs.inputBuf > 0 and #a.missions < 32
    if canPlan and gs.selected >= 1 and gs.selected2 >= 1 then
        local mtype = MISSION_TYPES[gs.selected]
        local r     = a.rockets[gs.selected2]
        canPlan = a.budget >= missionCost(mtype, r)
    end

    if button("APPROVE MISSION", 20, SCREEN_H - 96, 220, 44, COL_GOLD, not canPlan) then
        local mtype  = MISSION_TYPES[gs.selected]
        local r      = a.rockets[gs.selected2]
        local cost   = missionCost(mtype, r)
        a.budget     = a.budget - cost
        r.launches   = r.launches + 1

        local m = {
            id             = #a.missions + 1,
            name           = gs.inputBuf,
            mission_type   = mtype,
            status         = "InFlight",
            rocket_id      = r.id,
            crew           = {},
            crew_count     = 0,
            launch_month   = a.month,
            duration       = missionDuration(mtype),
            elapsed        = 0,
            success_chance = missionBaseChance(mtype, r, a),
            prestige       = missionPrestige(mtype),
            science        = math.floor(missionPrestige(mtype) / 2),
            cost           = cost,
            log            = {},
            destination    = missionDestination(mtype),
        }
        appendMissionLog(m, string.format("Launch: %s %d. Rocket: %s. Chance: %.0f%%",
            monthName(a.month), a.year, r.name, m.success_chance * 100))
        table.insert(a.missions, m)
        a.prestige   = a.prestige + 2
        pushNotification(gs, "Mission launched: " .. m.name)
        gs.screen    = SCREENS.MISSIONS
        gs.selected  = -1
        gs.selected2 = -1
        gs.inputBuf  = ""
    end
    if button("<- CANCEL", 260, SCREEN_H - 96, 130, 44, COL_DIM) then
        gs.screen    = SCREENS.MISSIONS
        gs.selected  = -1
        gs.selected2 = -1
        gs.inputBuf  = ""
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MISSION LOG
-- ═══════════════════════════════════════════════════════════════════════════════

function drawMissionLog(gs)
    local a = gs.agency
    if gs.selected < 1 or gs.selected > #a.missions then gs.screen = SCREENS.MISSIONS; return end
    local m = a.missions[gs.selected]

    drawText("MISSION LOG", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    local sc = missionStatusCol(m.status)
    drawText(m.name, 20, 92, 24, sc)
    drawText(missionTypeName(m.mission_type) .. "  ->  " .. m.destination, 20, 120, 15, COL_DIM)

    local statsData = {
        {l="Status",   v=missionStatusStr(m.status),                    c=sc},
        {l="Elapsed",  v=string.format("%d / %d mo", m.elapsed, m.duration), c=COL_TEXT},
        {l="Chance",   v=string.format("%.0f%%", m.success_chance*100), c=COL_ACCENT},
        {l="Prestige", v=string.format("* %d", m.prestige),             c=COL_GOLD},
        {l="Science",  v=string.format("S %d", m.science),              c=COL_CYAN},
        {l="Cost",     v=string.format("$%dM", m.cost),                 c=COL_RED},
    }
    local sw = (SCREEN_W - 40) / 6
    for i, s in ipairs(statsData) do
        local sx = 20 + (i-1) * sw
        drawRect(sx, 146, sw - 4, 52, COL_PANEL)
        drawRectLines(sx, 146, sw - 4, 52, COL_BORDER)
        drawText(s.l, sx + 6, 154, 12, COL_DIM)
        drawText(s.v, sx + 6, 170, 16, s.c)
    end

    if m.status == "InFlight" then
        local prog = m.elapsed / math.max(m.duration, 1)
        drawRect(20, 206, SCREEN_W - 40, 16, COL_PANEL2)
        drawRect(20, 206, (SCREEN_W - 40) * prog, 16, COL_ACCENT)
        drawRectLines(20, 206, SCREEN_W - 40, 16, COL_BORDER)
    end

    sectionLine("FLIGHT LOG", 232)
    for i = 1, #m.log do
        local idx  = #m.log - i + 1
        local ly   = 246 + (i-1) * 20
        if ly > SCREEN_H - 110 then break end
        local entry = m.log[idx]
        local lcol  = COL_DIM
        if entry:find("CRITICAL") or entry:find("lost") then lcol = COL_RED end
        if entry:find("SUCCESS")  or entry:find("returned") then lcol = COL_GREEN end
        drawText(entry, 28, ly, 13, lcol)
    end

    if button("<- MISSIONS", 20, SCREEN_H - 96, 200, 44, COL_DIM) then
        gs.screen = SCREENS.MISSIONS
    end
    if m.status == "InFlight" or m.status == "ReadyToLaunch" then
        if button("ABORT MISSION", SCREEN_W - 222, SCREEN_H - 96, 202, 44, COL_RED) then
            m.status = "Aborted"
            for _, aid in ipairs(m.crew or {}) do
                for _, ast in ipairs(a.astronauts) do
                    if ast.id == aid then ast.status = "Available" end
                end
            end
            pushNotification(gs, "Mission aborted: " .. m.name)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- RESEARCH
-- ═══════════════════════════════════════════════════════════════════════════════

function drawResearch(gs)
    local a = gs.agency
    drawText("RESEARCH & DEVELOPMENT", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)
    drawText(string.format("Science Points: %d", a.science_pts), 20, 92, 16, COL_CYAN)

    for i, r in ipairs(a.research) do
        local ry = 114 + (i-1) * 82
        if ry > SCREEN_H - 110 then break end

        local inProg = not r.completed and r.progress > 0
        local bg
        if r.completed then bg = {5/255, 20/255, 10/255, 0.78}
        elseif inProg   then bg = {15/255, 15/255, 30/255, 0.78}
        else bg = COL_PANEL end

        -- Check prereq
        local prereqMet = true
        if r.prereq then
            prereqMet = false
            for _, cr in ipairs(a.completed_research or {}) do
                if cr == r.prereq then prereqMet = true; break end
            end
        end

        drawRect(20, ry, SCREEN_W - 40, 76, bg)
        local borderC = r.completed and COL_GREEN or (inProg and COL_ACCENT or (prereqMet and COL_BORDER or {40/255,20/255,20/255,1}))
        drawRectLines(20, ry, SCREEN_W - 40, 76, borderC)

        local acol = researchAreaCol(r.area)
        drawRect(20, ry, 6, 76, acol)

        drawText(researchAreaName(r.area), 34, ry + 6,  12, acol)
        drawText(r.name,                   34, ry + 22, 18, r.completed and COL_GREEN or COL_TEXT)
        drawText(r.description,            34, ry + 46, 13, COL_DIM)

        -- Prereq indicator
        if r.prereq and not prereqMet then
            drawText("Requires: " .. r.prereq, 34, ry + 62, 11, COL_RED)
        end

        if inProg then
            local prog = r.progress / r.duration
            drawRect(480, ry + 18, 300, 13, COL_PANEL2)
            drawRect(480, ry + 18, 300 * prog, 13, acol)
            drawRectLines(480, ry + 18, 300, 13, COL_BORDER)
            drawText(string.format("Mo %.0f/%d", r.progress, r.duration), 788, ry + 20, 12, COL_DIM)
        end

        drawText("Unlocks: " .. r.unlock, SCREEN_W - 285, ry + 24, 13, acol)
        drawText(string.format("$%dM  |  %d months", r.cost, r.duration), SCREEN_W - 285, ry + 46, 12, COL_DIM)

        if r.completed then
            drawText("COMPLETE", SCREEN_W - 108, ry + 28, 14, COL_GREEN)
        elseif inProg then
            drawText("IN PROG.", SCREEN_W - 108, ry + 28, 13, COL_ACCENT)
        else
            local canFund = a.budget >= r.cost and prereqMet
            if button("FUND", SCREEN_W - 108, ry + 18, 82, 34, acol, not canFund) then
                if canFund then
                    a.budget     = a.budget - r.cost
                    r.progress   = 1
                    pushNotification(gs, "Research started: " .. r.name)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- STAR MAP
-- ═══════════════════════════════════════════════════════════════════════════════

function drawStarMap(gs)
    drawText("SOLAR SYSTEM MAP", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    local vx = 20
    local vy = 92
    local vw = SCREEN_W * 0.62
    local vh = SCREEN_H - 195

    drawRect(vx, vy, vw, vh, {4/255, 6/255, 14/255, 1})
    drawRectLines(vx, vy, vw, vh, COL_BORDER)

    -- Draw extra star field inside map
    setColor({200/255, 210/255, 255/255, 0.25})
    for i = 1, 60 do
        local sx = vx + (math.sin(i * 7.3) * 0.5 + 0.5) * vw
        local sy = vy + (math.sin(i * 3.7) * 0.5 + 0.5) * vh
        love.graphics.circle("fill", sx, sy, 0.8)
    end

    -- Sun
    local sun_x = vx + vw * 0.10
    local sun_y = vy + vh * 0.50
    -- Sun glow
    for i = 5, 1, -1 do
        setColor({255/255, 180/255, 30/255, 0.04 * i})
        love.graphics.circle("fill", sun_x, sun_y, 16 + i * 8)
    end
    drawCircle(sun_x, sun_y, 16, {255/255, 200/255, 50/255, 1})
    drawText("SOL", sun_x - 12, sun_y + 20, 12, COL_GOLD)

    for i, b in ipairs(gs.bodies) do
        local bx = sun_x + math.cos(b.orbit_angle) * (vw * b.orbit_r * 0.88)
        local by = sun_y + math.sin(b.orbit_angle) * (vh * b.orbit_r * 0.36)

        drawEllipseLines(sun_x, sun_y, vw*b.orbit_r*0.88, vh*b.orbit_r*0.36, {28/255,38/255,58/255,0.31})

        local size = 5
        if b.name == "Jupiter"  then size = 13
        elseif b.name == "Saturn"  then size = 11
        elseif b.name == "Earth" or b.name == "Venus" then size = 7
        elseif b.name == "Moon" or b.name == "Phobos" or b.name == "Ceres" then size = 3
        end

        local col = b.color
        if b.landed       then col = COL_GREEN
        elseif b.orbited  then col = COL_CYAN
        elseif b.probed   then col = COL_GOLD end

        if b.explored then
            setColor(colorWithAlpha(col, 0.2))
            love.graphics.circle("fill", bx, by, size + 6)
        end
        drawCircle(bx, by, size, col)

        local mx, my = love.mouse.getPosition()
        local dist   = math.sqrt((mx-bx)^2 + (my-by)^2)
        local showLabel = dist < 22 or gs.selected == i
        if showLabel then
            drawText(b.name, bx + size + 3, by - 7, 12, gs.selected == i and COL_WHITE or COL_DIM)
            if mouseInAndClicked(bx - size - 2, by - size - 2, size * 2 + 4, size * 2 + 4) then
                gs.selected = i
            end
        end
    end

    -- Legend
    local legendItems = {
        {col=COL_GREEN, lbl="Landed"},
        {col=COL_CYAN,  lbl="Orbited"},
        {col=COL_GOLD,  lbl="Probed"},
        {col=COL_DIM,   lbl="Unexplored"},
    }
    for i, li in ipairs(legendItems) do
        local lx = vx + 8
        local ly = vy + vh - 20 - (i-1) * 17
        drawCircle(lx + 5, ly + 5, 4, li.col)
        drawText(li.lbl, lx + 13, ly, 12, COL_DIM)
    end

    -- Info panel
    if gs.selected >= 1 and gs.selected <= #gs.bodies then
        local b  = gs.bodies[gs.selected]
        local px = vx + vw + 8
        local pw = SCREEN_W - px - 8
        panel(px, vy, pw, vh, COL_PANEL)
        drawText(b.name, px + 10, vy + 12, 24, b.color)

        local rows = {
            {"Distance", string.format("%.2f AU", b.dist)},
            {"Diameter", string.format("%.0f km", b.diam)},
            {"Gravity",  string.format("%.2f g",  b.grav)},
        }
        for i, row in ipairs(rows) do
            local ry = vy + 48 + (i-1) * 26
            drawText(row[1], px + 10, ry, 13, COL_DIM)
            drawText(row[2], px + 96, ry, 13, COL_TEXT)
        end

        sectionLine("EXPLORATION", vy + 138)
        local expls = {
            {"Probed",   b.probed},
            {"Orbited",  b.orbited},
            {"Landed",   b.landed},
            {"Explored", b.explored},
        }
        for i, ex in ipairs(expls) do
            local ey = vy + 148 + (i-1) * 24
            drawText(ex[2] and "OK" or "--", px + 10, ey, 14, ex[2] and COL_GREEN or COL_DIM)
            drawText(ex[1], px + 34, ey + 1, 13, ex[2] and COL_GREEN or COL_DIM)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- FACILITIES
-- ═══════════════════════════════════════════════════════════════════════════════

function drawFacilities(gs)
    local a = gs.agency
    drawText("SPACE CENTRE FACILITIES", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    local facs = {
        {name="Launch Pads",       field="launch_pads",    max=4, desc="Simultaneous launch capacity",       cost=150, col=COL_ORANGE},
        {name="Vehicle Assembly",  field="vab_level",      max=5, desc="Larger rockets. +1% success/level",  cost=200, col=COL_ACCENT},
        {name="Tracking Network",  field="tracking_level", max=5, desc="+2% mission success per level",      cost=120, col=COL_CYAN},
        {name="Research Lab",      field="lab_level",      max=5, desc="Accelerate R&D. Speed x1.2/level",   cost=180, col=COL_PURPLE},
        {name="Astronaut Complex", field="hab_level",      max=5, desc="Training and morale improvement",    cost=100, col=COL_GREEN},
    }

    for i, f in ipairs(facs) do
        local fy = 92 + (i-1) * 102
        panel(20, fy, SCREEN_W - 40, 96, COL_PANEL)
        drawText(f.name,                    34, fy + 10, 20, COL_TEXT)
        drawText(string.format("Level %d / %d", a.facilities[f.field], f.max), 34, fy + 34, 15, f.col)
        drawText(f.desc,                    34, fy + 56, 13, COL_DIM)

        for l = 1, f.max do
            local lx     = 290 + (l-1) * 34
            local filled = l <= a.facilities[f.field]
            drawRect(lx, fy + 30, 28, 18, filled and colorWithAlpha(f.col, 0.3) or COL_PANEL2)
            drawRectLines(lx, fy + 30, 28, 18, filled and f.col or COL_BORDER)
            if filled then
                drawRect(lx + 3, fy + 33, 22, 12, f.col)
            end
        end

        local atMax  = a.facilities[f.field] >= f.max
        local btnTxt = atMax and "MAX" or string.format("UPGRADE $%dM", f.cost)
        local canUp  = not atMax and a.budget >= f.cost
        if button(btnTxt, SCREEN_W - 222, fy + 26, 200, 40, f.col, not canUp) then
            if canUp then
                a.budget                  = a.budget - f.cost
                a.facilities[f.field]     = a.facilities[f.field] + 1
                a.monthly_income          = a.monthly_income + 3
                pushNotification(gs, string.format("%s upgraded to Level %d", f.name, a.facilities[f.field]))
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- RIVALRIES  (new expanded screen)
-- ═══════════════════════════════════════════════════════════════════════════════

function drawRivalries(gs)
    local a = gs.agency
    drawText("SPACE RACE — RIVAL AGENCIES", 20, 58, 22, COL_TEXT)
    drawLine(20, 84, SCREEN_W - 20, 84, COL_BORDER)

    -- Player prestige bar
    sectionLine("YOUR AGENCY", 94)
    drawText(a.name, 28, 104, 18, COL_ACCENT)
    drawText(string.format("Prestige: %d", a.prestige), 200, 106, 16, COL_GOLD)
    -- Progress bar
    local maxP = 300
    drawRect(340, 106, 400, 16, COL_PANEL2)
    drawRect(340, 106, math.min(400, 400 * a.prestige / maxP), 16, COL_ACCENT)
    drawRectLines(340, 106, 400, 16, COL_BORDER)

    -- Rivals
    for i, rv in ipairs(gs.rivals or {}) do
        local ry = 130 + (i-1) * 148
        panel(20, ry, SCREEN_W - 40, 142, COL_PANEL)
        drawRect(20, ry, 4, 142, rv.color)

        drawText(rv.name,   34, ry + 10, 22, COL_TEXT)
        drawText(rv.nation, 34, ry + 36, 14, rv.color)
        drawText(string.format("Prestige: %d", rv.prestige), 200, ry + 36, 14, COL_GOLD)

        -- Prestige bar
        drawRect(340, ry + 36, 400, 14, COL_PANEL2)
        drawRect(340, ry + 36, math.min(400, 400 * rv.prestige / maxP), 14, rv.color)
        drawRectLines(340, ry + 36, 400, 14, COL_BORDER)

        -- Milestone indicators
        local milestoneNames = {
            {key="orbit",        label="ORBIT"},
            {key="moon_orbit",   label="MOON ORBIT"},
            {key="moon_landing", label="MOON LANDING"},
            {key="mars",         label="MARS"},
        }
        local mx2 = 34
        for _, ms in ipairs(milestoneNames) do
            local done  = rv.milestones and rv.milestones[ms.key]
            local mc    = done and COL_GREEN or COL_DIM
            drawRect(mx2, ry + 58, 120, 18, COL_PANEL2)
            drawRectLines(mx2, ry + 58, 120, 18, done and mc or COL_BORDER)
            drawTextCentered(ms.label, mx2, ry + 61, 120, 11, mc)
            mx2 = mx2 + 126
        end

        -- Status
        local lead = rv.prestige > a.prestige
        local statusMsg = lead and "AHEAD OF YOU" or "BEHIND YOU"
        local statusCol = lead and COL_RED or COL_GREEN
        drawText(statusMsg, SCREEN_W - 200, ry + 16, 16, statusCol)

        -- Aggression level
        drawText(string.format("Aggression: %.0f%%", rv.aggression * 100), SCREEN_W - 200, ry + 40, 13, COL_DIM)
    end

    -- Recent rival news
    sectionLine("INTELLIGENCE FEED", SCREEN_H - 165)
    local feedY = SCREEN_H - 150
    if #(gs.rivalNews or {}) == 0 then
        drawText("No rival activity reported.", 28, feedY, 14, COL_DIM)
    end
    for i, rn in ipairs(gs.rivalNews or {}) do
        if i > 6 then break end
        drawText(">> " .. rn.msg, 28, feedY + (i-1) * 18, 13, rn.col or COL_RED)
    end
end
