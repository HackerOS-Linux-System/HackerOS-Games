require("src/constants")
require("src/helpers")
require("src/init")
require("src/events")
require("src/rivals")
require("src/research")
require("src/contracts")
require("src/simulation")
require("src/starmap")
require("src/ui_shared")
require("src/ui_screens")

-- Per-frame click flag consumed by UI widgets
gs_mouseJustPressed = false

-- ── Load ──────────────────────────────────────────────────────────────────────

function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Cosmonaut — Space Agency Management")
    love.window.setMode(SCREEN_W, SCREEN_H, {
        resizable = false,
        vsync     = true,
        msaa      = 4,
    })
    love.graphics.setDefaultFilter("linear", "linear")
    gs = newGameState()
end

-- ── Update ────────────────────────────────────────────────────────────────────

function love.update(dt)
    if gs.notifTimer  and gs.notifTimer  > 0 then gs.notifTimer  = gs.notifTimer  - dt end
    if gs.starAnim   ~= nil                   then gs.starAnim    = gs.starAnim + dt * 0.8 end
    -- Animate rival news timers (only when in-game)
    if gs.rivalNews and gs.agency then updateRivals(gs) end
end

-- ── Draw ──────────────────────────────────────────────────────────────────────

function love.draw()
    setColor(COL_BG)
    love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)

    drawStars(gs, gs.starAnim)

    local s = gs.screen

    if s == SCREENS.MAIN_MENU then
        drawMainMenu(gs)

    elseif s == SCREENS.NEW_GAME then
        drawNewGame(gs)

    elseif s == SCREENS.DASHBOARD then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawDashboard(gs)

    elseif s == SCREENS.ROCKETS then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawRockets(gs)

    elseif s == SCREENS.ROCKET_DESIGN then
        drawTopbar(gs)
        drawRocketDesign(gs)

    elseif s == SCREENS.ASTRONAUTS then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawAstronauts(gs)

    elseif s == SCREENS.MISSIONS then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawMissions(gs)

    elseif s == SCREENS.MISSION_PLAN then
        drawTopbar(gs)
        drawMissionPlan(gs)

    elseif s == SCREENS.MISSION_LOG then
        drawTopbar(gs)
        drawMissionLog(gs)

    elseif s == SCREENS.RESEARCH then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawResearch(gs)

    elseif s == SCREENS.STAR_MAP then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawStarMapScreen(gs)   -- uses starmap.lua

    elseif s == SCREENS.FACILITIES then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawFacilities(gs)

    elseif s == SCREENS.RIVALRIES then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawRivalries(gs)

    elseif s == SCREENS.CONTRACTS then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawContracts(gs)       -- new contracts screen

    elseif s == SCREENS.TECH_TREE then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawTechTree(gs)        -- new tech tree screen

    end

    drawNotification(gs)
    gs_mouseJustPressed = false

    -- DEV: uncomment to show FPS
    -- setColor(COL_DIM)
    -- love.graphics.print("FPS: " .. love.timer.getFPS(), 4, 4, 0, 0.85)
end

-- ── Mouse ─────────────────────────────────────────────────────────────────────

function love.mousepressed(x, y, btn)
    if btn == 1 then
        gs_mouseJustPressed = true
        -- Star map zoom click
        if gs.screen == SCREENS.STAR_MAP and gs.agency then
            -- handled inside drawStarMapScreen via gs_mouseJustPressed
        end
    end
    if btn == 2 then
        -- Right-click resets star map zoom
        if gs.screen == SCREENS.STAR_MAP then
            gs.smapZoom = 1.0
        end
    end
end

-- ── Keyboard ─────────────────────────────────────────────────────────────────

function love.keypressed(key)
    local textScreens = {
        [SCREENS.NEW_GAME]      = true,
        [SCREENS.ROCKET_DESIGN] = true,
        [SCREENS.MISSION_PLAN]  = true,
    }
    if textScreens[gs.screen] then
        if key == "backspace" and #gs.inputBuf > 0 then
            gs.inputBuf = gs.inputBuf:sub(1, -2)
        end
    end

    -- Space → advance month on dashboard
    if key == "space" and gs.screen == SCREENS.DASHBOARD and gs.agency then
        advanceMonth(gs)
    end

    -- Star map zoom
    if gs.screen == SCREENS.STAR_MAP then
        if key == "=" or key == "+" then gs.smapZoom = math.min((gs.smapZoom or 1.0) + 0.1, 2.5)
        elseif key == "-"            then gs.smapZoom = math.max((gs.smapZoom or 1.0) - 0.1, 0.4) end
    end

    -- ESC navigation
    if key == "escape" then
        if gs.screen == SCREENS.MAIN_MENU then
            -- stay
        elseif gs.screen == SCREENS.DASHBOARD then
            -- stay
        elseif gs.screen == SCREENS.NEW_GAME
            or gs.screen == SCREENS.ROCKET_DESIGN
            or gs.screen == SCREENS.MISSION_PLAN
            or gs.screen == SCREENS.MISSION_LOG then
            gs.screen   = SCREENS.DASHBOARD
            gs.selected = -1; gs.selected2 = -1; gs.inputBuf = ""
        else
            gs.screen = SCREENS.DASHBOARD
        end
    end

    -- Number shortcuts for bottom nav (1-9)
    if gs.agency then
        local num = tonumber(key)
        if num and num >= 1 and num <= #NAV_TABS then
            gs.screen = NAV_TABS[num].screen
            gs.tab    = 1
            gs.scroll = 0
        end
    end
end

-- ── Text input ────────────────────────────────────────────────────────────────

function love.textinput(t)
    local textScreens = {
        [SCREENS.NEW_GAME]      = true,
        [SCREENS.ROCKET_DESIGN] = true,
        [SCREENS.MISSION_PLAN]  = true,
    }
    if textScreens[gs.screen] and #gs.inputBuf < 42 then
        gs.inputBuf = gs.inputBuf .. t
    end
end

-- ── Mouse wheel ───────────────────────────────────────────────────────────────

function love.wheelmoved(x, y)
    if gs.screen == SCREENS.STAR_MAP then
        -- Zoom star map
        gs.smapZoom = clamp((gs.smapZoom or 1.0) + y * 0.1, 0.35, 2.8)
    else
        gs.scroll = math.max(0, (gs.scroll or 0) - y * 30)
    end
end
