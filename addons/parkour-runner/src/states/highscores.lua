local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")

local state = {}
local SW, SH = 1280, 720
local t = 0
local mx, my = 0, 0
local curTab = 1

local TABS = {"TIME ATTACK", "ENDLESS RUN"}
local MODES = {"time_attack", "endless"}

function state.enter()
    UI.loadFonts()
    t = 0
end

function state.update(dt)
    t = t + dt
end

function state.draw()
    love.graphics.setColor(UI.colors.bg)
    love.graphics.rectangle("fill", 0, 0, SW, SH)
    UI.drawGrid(t)
    UI.scanlines()

    UI.hudBar()
    love.graphics.setFont(UI.fonts.heading)
    love.graphics.setColor(UI.colors.white)
    love.graphics.print("LEADERBOARD", 40, 10)
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("ESC  Back", SW - 120, 14, 100, "right")

    -- Tabs
    local tabX = 60
    for i, tab in ipairs(TABS) do
        local sel = curTab == i
        love.graphics.setColor(sel and UI.colors.accent or UI.colors.darkgrey)
        love.graphics.rectangle("fill", tabX, 60, 200, 36, 4, 4)
        love.graphics.setFont(UI.fonts.small)
        love.graphics.setColor(sel and UI.colors.bg or UI.colors.grey)
        love.graphics.printf(tab, tabX, 70, 200, "center")
        tabX = tabX + 210
    end

    -- Table header
    local cy = 120
    love.graphics.setColor(UI.colors.darkgrey)
    love.graphics.rectangle("fill", 60, cy, SW - 120, 36)
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.print("#", 80, cy + 10)
    love.graphics.print("PLAYER", 130, cy + 10)
    love.graphics.print("SCORE", 500, cy + 10)
    love.graphics.print("DATE", 700, cy + 10)
    cy = cy + 46

    -- Scores
    local mode  = MODES[curTab]
    local list  = Settings.data.highscores[mode] or {}

    if #list == 0 then
        love.graphics.setFont(UI.fonts.body)
        love.graphics.setColor(UI.colors.grey)
        love.graphics.printf("No records yet. Start playing!", 0, cy + 60, SW, "center")
    else
        for i, entry in ipairs(list) do
            -- Alternating rows
            love.graphics.setColor(i % 2 == 0 and UI.colors.panel or {0.06, 0.06, 0.09, 1})
            love.graphics.rectangle("fill", 60, cy, SW - 120, 44)

            -- Rank highlight
            if i == 1 then
                love.graphics.setColor(UI.colors.accent[1], UI.colors.accent[2], UI.colors.accent[3], 0.15)
                love.graphics.rectangle("fill", 60, cy, SW - 120, 44)
                love.graphics.setColor(UI.colors.accent)
                love.graphics.rectangle("fill", 60, cy, 4, 44)
            end

            love.graphics.setFont(UI.fonts.body)
            love.graphics.setColor(i == 1 and UI.colors.accent or UI.colors.grey)
            love.graphics.print(i == 1 and "👑" or tostring(i), 80, cy + 12)
            love.graphics.setColor(UI.colors.white)
            love.graphics.print(entry.name or "Unknown", 130, cy + 12)

            -- Format score
            local scoreStr
            if mode == "time_attack" then
                scoreStr = UI.fmt_time(entry.score)
            else
                scoreStr = tostring(entry.score) .. " pts"
            end
            love.graphics.setColor(i == 1 and UI.colors.accent or UI.colors.white)
            love.graphics.print(scoreStr, 500, cy + 12)
            love.graphics.setColor(UI.colors.grey)
            love.graphics.print(entry.date or "-", 700, cy + 12)
            cy = cy + 44
        end
    end
end

function state.keypressed(key)
    if key == "escape" then SM.switch("menu") end
    if key == "left"  then curTab = math.max(1, curTab - 1) end
    if key == "right" then curTab = math.min(#TABS, curTab + 1) end
end

function state.mousemoved(x, y) mx, my = x, y end

function state.mousepressed(x, y, button)
    if button ~= 1 then return end
    local tabX = 60
    for i = 1, #TABS do
        if x >= tabX and x <= tabX + 200 and y >= 60 and y <= 96 then
            curTab = i
        end
        tabX = tabX + 210
    end
end

return state
