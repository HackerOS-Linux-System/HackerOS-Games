local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")

local state = {}
local SW, SH = 1280, 720
local t = 0

local mx, my = 0, 0
local mouseDown = false

local TABS = {"AUDIO", "VIDEO", "GAMEPLAY"}
local curTab = 1

function state.enter()
    UI.loadFonts()
    t = 0
end

function state.update(dt)
    t = t + dt
end

function state.draw()
    -- Background
    love.graphics.setColor(UI.colors.bg)
    love.graphics.rectangle("fill", 0, 0, SW, SH)
    UI.drawGrid(t)
    UI.scanlines()

    -- Header bar
    UI.hudBar()
    love.graphics.setFont(UI.fonts.heading)
    love.graphics.setColor(UI.colors.white)
    love.graphics.print("SETTINGS", 40, 10)
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("ESC  Back", SW - 120, 14, 100, "right")

    -- Tabs
    local tabY = 60
    local tabX = 40
    for i, tab in ipairs(TABS) do
        local w = 150
        local selected = curTab == i
        love.graphics.setColor(selected and UI.colors.accent or UI.colors.darkgrey)
        love.graphics.rectangle("fill", tabX, tabY, w, 36, 4, 4)
        love.graphics.setFont(UI.fonts.small)
        love.graphics.setColor(selected and UI.colors.bg or UI.colors.grey)
        love.graphics.printf(tab, tabX, tabY + 10, w, "center")
        tabX = tabX + w + 6
    end

    -- Content area
    local cx = 60
    local cy = 120

    if curTab == 1 then drawAudio(cx, cy)
    elseif curTab == 2 then drawVideo(cx, cy)
    elseif curTab == 3 then drawGameplay(cx, cy)
    end

    -- Save button
    local saved = UI.button({x = SW - 220, y = SH - 70, w = 180, h = 46, label = "SAVE & APPLY"}, mx, my)

    love.graphics.setFont(UI.fonts.tiny)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("Settings saved to ~/.config/HackerOS/parkour-runner/", 0, SH - 22, SW, "center")
end

function drawAudio(cx, cy)
    UI.sectionHeader("Audio", cx, cy, 500)
    cy = cy + 40

    -- Master Volume
    local newMaster, _ = UI.slider({
        x = cx, y = cy, w = 400,
        value = Settings.data.masterVolume,
        label = "Master Volume",
    }, mx, my, mouseDown)
    Settings.data.masterVolume = newMaster
    cy = cy + 70

    local newMusic, _ = UI.slider({
        x = cx, y = cy, w = 400,
        value = Settings.data.musicVolume,
        label = "Music Volume",
    }, mx, my, mouseDown)
    Settings.data.musicVolume = newMusic
    cy = cy + 70

    local newSFX, _ = UI.slider({
        x = cx, y = cy, w = 400,
        value = Settings.data.sfxVolume,
        label = "SFX Volume",
    }, mx, my, mouseDown)
    Settings.data.sfxVolume = newSFX
end

function drawVideo(cx, cy)
    UI.sectionHeader("Video", cx, cy, 500)
    cy = cy + 40

    -- Fullscreen toggle
    local hoverFS = UI.toggle({
        x = cx, y = cy,
        value = Settings.data.fullscreen,
        label = "Fullscreen",
    }, mx, my)
    cy = cy + 56

    -- Show FPS
    local hoverFPS = UI.toggle({
        x = cx, y = cy,
        value = Settings.data.showFPS,
        label = "Show FPS Counter",
    }, mx, my)
end

function drawGameplay(cx, cy)
    UI.sectionHeader("Gameplay", cx, cy, 500)
    cy = cy + 40

    local diffs = {"easy", "normal", "hard"}
    local labels = {"EASY", "NORMAL", "HARD"}
    for i, d in ipairs(diffs) do
        local sel = Settings.data.difficulty == d
        UI.button({
            x = cx + (i-1)*180, y = cy,
            w = 168, h = 46,
            label = labels[i],
            selected = sel,
        }, mx, my)
    end

    cy = cy + 80
    UI.sectionHeader("Player Name", cx, cy, 500)
    cy = cy + 40
    love.graphics.setColor(UI.colors.darkgrey)
    love.graphics.rectangle("fill", cx, cy, 300, 40, 4)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", cx, cy, 300, 40, 4)
    love.graphics.setLineWidth(1)
    love.graphics.setFont(UI.fonts.body)
    love.graphics.setColor(UI.colors.white)
    love.graphics.print(Settings.data.playerName or "Runner", cx + 10, cy + 10)
end

-- ─── Input ───────────────────────────────────────────────────────────────────

function state.keypressed(key)
    if key == "escape" then
        Settings.save()
        SM.switch("menu")
    end
    if key == "tab" then
        curTab = curTab % #TABS + 1
    end
end

function state.mousemoved(x, y)
    mx, my = x, y
end

function state.mousepressed(x, y, button)
    if button == 1 then
        mouseDown = true
        mx, my = x, y

        -- Tab click
        local tabX = 40
        for i = 1, #TABS do
            if x >= tabX and x <= tabX + 150 and y >= 60 and y <= 96 then
                curTab = i
            end
            tabX = tabX + 156
        end

        -- Difficulty
        if curTab == 3 then
            local diffs = {"easy","normal","hard"}
            local cy = 200
            for i, d in ipairs(diffs) do
                local bx = 60 + (i-1)*180
                if x >= bx and x <= bx+168 and y >= cy and y <= cy+46 then
                    Settings.data.difficulty = d
                end
            end
        end

        -- Video toggles
        if curTab == 2 then
            if x >= 60 and x <= 114 and y >= 160 and y <= 188 then
                Settings.data.fullscreen = not Settings.data.fullscreen
                love.window.setFullscreen(Settings.data.fullscreen)
            end
            if x >= 60 and x <= 114 and y >= 216 and y <= 244 then
                Settings.data.showFPS = not Settings.data.showFPS
            end
        end

        -- Save button
        if x >= SW - 220 and x <= SW - 40 and y >= SH - 70 and y <= SH - 24 then
            Settings.save()
        end
    end
end

function state.mousereleased(x, y, button)
    if button == 1 then mouseDown = false end
end

return state
