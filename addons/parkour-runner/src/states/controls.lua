local UI       = require("src.ui")
local SM       = require("src.state_manager")
local Settings = require("src.settings")

local state = {}
local SW, SH = 1280, 720
local t = 0
local mx, my = 0, 0

local BINDS = {
    { id = "left",  label = "Move Left"  },
    { id = "right", label = "Move Right" },
    { id = "jump",  label = "Jump"       },
    { id = "slide", label = "Slide / Wall-hug" },
    { id = "pause", label = "Pause"      },
}

local rebinding = nil  -- id of bind being changed
local rebindTimer = 0

function state.enter()
    UI.loadFonts()
    t = 0
    rebinding = nil
end

function state.update(dt)
    t = t + dt
    if rebinding then
        rebindTimer = rebindTimer + dt
    end
end

function state.draw()
    love.graphics.setColor(UI.colors.bg)
    love.graphics.rectangle("fill", 0, 0, SW, SH)
    UI.drawGrid(t)
    UI.scanlines()

    UI.hudBar()
    love.graphics.setFont(UI.fonts.heading)
    love.graphics.setColor(UI.colors.white)
    love.graphics.print("CONTROLS", 40, 10)
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("ESC  Back", SW - 120, 14, 100, "right")

    local cy = 100
    UI.sectionHeader("Key Bindings  (click to rebind)", 60, cy, SW - 120)
    cy = cy + 50

    for _, bind in ipairs(BINDS) do
        local isRebinding = rebinding == bind.id
        local key = Settings.data.keybinds[bind.id] or "?"

        -- Row BG
        love.graphics.setColor(isRebinding and {0.15, 0.10, 0.05, 1} or UI.colors.panel)
        love.graphics.rectangle("fill", 60, cy, SW - 120, 50, 4, 4)
        if isRebinding then
            love.graphics.setColor(UI.colors.accent)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", 60, cy, SW - 120, 50, 4, 4)
            love.graphics.setLineWidth(1)
        end

        -- Action label
        love.graphics.setFont(UI.fonts.body)
        love.graphics.setColor(UI.colors.white)
        love.graphics.print(bind.label, 90, cy + 14)

        -- Key badge
        local badgeX = SW - 260
        love.graphics.setColor(isRebinding and UI.colors.accent or UI.colors.darkgrey)
        love.graphics.rectangle("fill", badgeX, cy + 10, 140, 30, 6, 6)
        love.graphics.setFont(UI.fonts.body)
        love.graphics.setColor(isRebinding and UI.colors.bg or UI.colors.white)

        local display = isRebinding and ("PRESS KEY..." ) or key:upper()
        love.graphics.printf(display, badgeX, cy + 18, 140, "center")

        bind._y = cy
        cy = cy + 62
    end

    -- Gamepad hint
    cy = cy + 20
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf("Gamepad support coming in a future update", 0, cy, SW, "center")

    -- Reset button
    UI.button({x = 60, y = SH - 70, w = 200, h = 46, label = "RESET DEFAULTS"}, mx, my)
end

function state.keypressed(key)
    if rebinding then
        if key ~= "escape" then
            Settings.data.keybinds[rebinding] = key
            Settings.save()
        end
        rebinding = nil
        rebindTimer = 0
        return
    end
    if key == "escape" then SM.switch("menu") end
end

function state.mousemoved(x, y) mx, my = x, y end

function state.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- Check bind rows
    for _, bind in ipairs(BINDS) do
        if bind._y and x >= 60 and x <= SW - 60 and y >= bind._y and y <= bind._y + 50 then
            rebinding = bind.id
            rebindTimer = 0
            return
        end
    end

    -- Reset
    if x >= 60 and x <= 260 and y >= SH - 70 and y <= SH - 24 then
        Settings.data.keybinds = {
            left  = "a",
            right = "d",
            jump  = "space",
            slide = "lshift",
            pause = "escape",
        }
        Settings.save()
    end

    -- Back area
    if x >= SW - 120 and y >= 0 and y <= 44 then
        SM.switch("menu")
    end
end

return state
