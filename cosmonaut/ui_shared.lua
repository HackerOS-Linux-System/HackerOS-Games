local lg = love.graphics

-- ── Top bar ───────────────────────────────────────────────────────────────────

function drawTopbar(gs)
    local a = gs.agency

    -- Background
    setColor({5/255, 8/255, 18/255, 245/255})
    lg.rectangle("fill", 0, 0, SCREEN_W, 48)
    drawLine(0, 48, SCREEN_W, 48, COL_BORDER)

    -- Agency name
    drawText(a.name, 14, 14, 18, COL_ACCENT)

    -- Date centered
    local dateStr = monthName(a.month) .. " " .. a.year
    local dtw = measureText(dateStr, 16)
    drawText(dateStr, SCREEN_W/2 - dtw/2, 15, 16, COL_DIM)

    -- Budget
    local budStr = string.format("$%dM", a.budget)
    local bw2    = measureText(budStr, 16)
    local bcol   = a.budget > 50 and COL_GREEN or COL_RED
    drawText(budStr, SCREEN_W - bw2 - 220, 15, 16, bcol)

    -- Prestige
    drawText(string.format("* %d", a.prestige), SCREEN_W - 160, 15, 16, COL_GOLD)

    -- Science
    drawText(string.format("S %d", a.science_pts), SCREEN_W - 72, 15, 16, COL_CYAN)
end

-- ── Bottom nav ────────────────────────────────────────────────────────────────

function drawBottomNav(gs)
    local by = SCREEN_H - 42
    setColor({5/255, 8/255, 18/255, 245/255})
    lg.rectangle("fill", 0, by, SCREEN_W, 42)
    drawLine(0, by, SCREEN_W, by, COL_BORDER)

    local tw = math.floor(SCREEN_W / #NAV_TABS)
    for i, tab in ipairs(NAV_TABS) do
        local tx     = (i-1) * tw
        local active = gs.screen == tab.screen
        local col    = tab.col

        if active then
            setColor(colorWithAlpha(col, 0.12))
            lg.rectangle("fill", tx, by, tw, 42)
            setColor(col)
            lg.rectangle("fill", tx, by, tw, 2)
        end

        local lw2 = measureText(tab.label, 13)
        local lx  = tx + (tw - lw2) / 2
        drawText(tab.label, lx, by + 15, 13, active and col or COL_DIM)

        if mouseInAndClicked(tx, by, tw, 42) then
            gs.screen = tab.screen
            gs.tab    = 1
            gs.scroll = 0
        end
    end
end

-- ── Notification toast ────────────────────────────────────────────────────────

function drawNotification(gs)
    if gs.notifTimer <= 0 or gs.notification == "" then return end
    local alpha = clamp(gs.notifTimer / 0.5, 0, 1) * 0.86
    local tw2   = measureText(gs.notification, 14)
    local nx    = SCREEN_W/2 - tw2/2 - 16

    setColor(colorWithAlpha(COL_PANEL, alpha))
    lg.rectangle("fill", nx, SCREEN_H - 76, tw2 + 32, 28, 4, 4)
    setColor(colorWithAlpha(COL_ACCENT, alpha))
    lg.rectangle("line", nx, SCREEN_H - 76, tw2 + 32, 28, 4, 4)
    drawText(gs.notification, nx + 16, SCREEN_H - 68, 14, COL_TEXT, alpha)
end
