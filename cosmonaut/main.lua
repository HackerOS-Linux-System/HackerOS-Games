require("constants")
require("helpers")
require("init")
require("simulation")
require("ui_shared")
require("ui_screens")

-- Global mouse click state (reset each frame after draw)
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
    -- Create initial game state
    gs = newGameState()
end

-- ── Update ────────────────────────────────────────────────────────────────────

function love.update(dt)
    if gs.notifTimer > 0 then gs.notifTimer = gs.notifTimer - dt end
    gs.starAnim = gs.starAnim + dt * 0.8

    -- Space = advance month on dashboard
    if love.keyboard.isDown("space") then
        -- handled in keypressed to avoid repeated firing
    end
end

-- ── Draw ──────────────────────────────────────────────────────────────────────

function love.draw()
    -- Background
    setColor(COL_BG)
    love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)

    -- Stars
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
        drawStarMap(gs)
    elseif s == SCREENS.FACILITIES then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawFacilities(gs)
    elseif s == SCREENS.RIVALRIES then
        drawTopbar(gs)
        drawBottomNav(gs)
        drawRivalries(gs)
    end

    drawNotification(gs)

    -- Reset per-frame click state
    gs_mouseJustPressed = false

    -- FPS debug (comment out for release)
    -- setColor(COL_DIM, 0.5)
    -- love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 4, 4, 0, 0.9)
end

-- ── Mouse ─────────────────────────────────────────────────────────────────────

function love.mousepressed(x, y, button2)
    if button2 == 1 then
        gs_mouseJustPressed = true
    end
end

-- ── Keyboard ─────────────────────────────────────────────────────────────────

function love.keypressed(key)
    -- Text input for name fields
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

    -- Space to advance month on dashboard
    if key == "space" and gs.screen == SCREENS.DASHBOARD and gs.agency then
        advanceMonth(gs)
    end

    -- Escape navigation
    if key == "escape" then
        if gs.screen == SCREENS.MAIN_MENU then
            -- stay
        elseif gs.screen == SCREENS.DASHBOARD then
            -- stay
        elseif gs.screen == SCREENS.NEW_GAME
            or gs.screen == SCREENS.ROCKET_DESIGN
            or gs.screen == SCREENS.MISSION_PLAN
            or gs.screen == SCREENS.MISSION_LOG then
            gs.screen    = SCREENS.DASHBOARD
            gs.selected  = -1
            gs.selected2 = -1
            gs.inputBuf  = ""
        else
            gs.screen = SCREENS.DASHBOARD
        end
    end

    -- Number shortcuts for bottom nav (1-8)
    if gs.agency then
        local num = tonumber(key)
        if num and num >= 1 and num <= #NAV_TABS then
            gs.screen = NAV_TABS[num].screen
            gs.tab    = 1
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

-- ── Mouse wheel scroll ────────────────────────────────────────────────────────

function love.wheelmoved(x, y)
    gs.scroll = (gs.scroll or 0) - y * 30
    if gs.scroll < 0 then gs.scroll = 0 end
end
