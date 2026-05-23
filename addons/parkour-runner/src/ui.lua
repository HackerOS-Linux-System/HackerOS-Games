local UI = {}

local SW, SH = 1280, 720

-- ─── Colours ────────────────────────────────────────────────────────────────
UI.colors = {
    bg          = {0.04, 0.04, 0.06, 1},
    panel       = {0.07, 0.07, 0.10, 0.95},
    accent      = {0.96, 0.42, 0.10, 1},     -- orange
    accent2     = {0.20, 0.70, 1.00, 1},     -- cyan
    white       = {1, 1, 1, 1},
    grey        = {0.55, 0.55, 0.60, 1},
    darkgrey    = {0.18, 0.18, 0.22, 1},
    danger      = {0.90, 0.15, 0.15, 1},
    success     = {0.10, 0.85, 0.45, 1},
    overlay     = {0, 0, 0, 0.65},
}

-- ─── Fonts ──────────────────────────────────────────────────────────────────
UI.fonts = {}

function UI.loadFonts()
    UI.fonts.huge    = love.graphics.newFont(72)
    UI.fonts.title   = love.graphics.newFont(48)
    UI.fonts.heading = love.graphics.newFont(28)
    UI.fonts.body    = love.graphics.newFont(20)
    UI.fonts.small   = love.graphics.newFont(14)
    UI.fonts.tiny    = love.graphics.newFont(11)
end

-- ─── Button ─────────────────────────────────────────────────────────────────
--  opts: x,y,w,h, label, selected, disabled, icon(string)
function UI.button(opts, mx, my)
    local x, y, w, h = opts.x, opts.y, opts.w or 320, opts.h or 54
    local hover = mx >= x and mx <= x+w and my >= y and my <= y+h and not opts.disabled

    -- Background
    if opts.disabled then
        love.graphics.setColor(0.12, 0.12, 0.15, 0.8)
    elseif opts.selected then
        love.graphics.setColor(UI.colors.accent)
    elseif hover then
        love.graphics.setColor(0.14, 0.14, 0.18, 1)
    else
        love.graphics.setColor(UI.colors.panel)
    end
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    -- Left accent bar
    if opts.selected or hover then
        love.graphics.setColor(UI.colors.accent)
        love.graphics.rectangle("fill", x, y, 4, h, 2, 2)
    end

    -- Label
    love.graphics.setFont(UI.fonts.body)
    if opts.disabled then
        love.graphics.setColor(UI.colors.grey)
    elseif opts.selected then
        love.graphics.setColor(UI.colors.bg)
    else
        love.graphics.setColor(UI.colors.white)
    end
    love.graphics.printf(opts.label or "", x + 18, y + h/2 - 10, w - 36, "left")

    -- Right chevron
    if not opts.disabled and (hover or opts.selected) then
        love.graphics.setColor(opts.selected and UI.colors.bg or UI.colors.accent)
        love.graphics.printf("›", x + w - 32, y + h/2 - 11, 24, "right")
    end

    return hover
end

-- ─── Slider ─────────────────────────────────────────────────────────────────
function UI.slider(opts, mx, my, pressed)
    local x, y, w = opts.x, opts.y, opts.w or 300
    local h = 6
    local val = opts.value  -- 0..1

    -- Track
    love.graphics.setColor(UI.colors.darkgrey)
    love.graphics.rectangle("fill", x, y + h/2 - 1, w, h, 3, 3)

    -- Fill
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill", x, y + h/2 - 1, w * val, h, 3, 3)

    -- Handle
    local hx = x + w * val
    local hy = y + h/2
    love.graphics.setColor(UI.colors.white)
    love.graphics.circle("fill", hx, hy, 10)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.circle("fill", hx, hy, 6)

    -- Label
    if opts.label then
        love.graphics.setFont(UI.fonts.small)
        love.graphics.setColor(UI.colors.grey)
        love.graphics.print(opts.label, x, y - 20)
        love.graphics.setColor(UI.colors.white)
        love.graphics.printf(string.format("%.0f%%", val * 100), x + w - 40, y - 20, 40, "right")
    end

    -- Drag logic
    local dragging = pressed and mx >= x - 12 and mx <= x + w + 12 and my >= hy - 14 and my <= hy + 14
    if dragging then
        return math.max(0, math.min(1, (mx - x) / w)), true
    end
    return val, false
end

-- ─── Toggle ─────────────────────────────────────────────────────────────────
function UI.toggle(opts, mx, my)
    local x, y = opts.x, opts.y
    local w, h = 54, 28
    local val = opts.value
    local hover = mx >= x and mx <= x+w and my >= y and my <= y+h

    -- Track
    love.graphics.setColor(val and UI.colors.accent or UI.colors.darkgrey)
    love.graphics.rectangle("fill", x, y, w, h, h/2, h/2)

    -- Knob
    local kx = val and (x + w - h/2 - 2) or (x + h/2 + 2)
    love.graphics.setColor(UI.colors.white)
    love.graphics.circle("fill", kx, y + h/2, h/2 - 3)

    -- Label
    if opts.label then
        love.graphics.setFont(UI.fonts.body)
        love.graphics.setColor(UI.colors.white)
        love.graphics.print(opts.label, x + w + 14, y + h/2 - 10)
    end

    return hover
end

-- ─── Section header ─────────────────────────────────────────────────────────
function UI.sectionHeader(text, x, y, w)
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.print(text:upper(), x, y)
    love.graphics.setColor(UI.colors.darkgrey)
    love.graphics.rectangle("fill", x, y + 18, w or 300, 1)
end

-- ─── Scanlines overlay ──────────────────────────────────────────────────────
function UI.scanlines(alpha)
    alpha = alpha or 0.04
    love.graphics.setColor(0, 0, 0, alpha)
    for y = 0, SH, 4 do
        love.graphics.rectangle("fill", 0, y, SW, 1)
    end
end

-- ─── Background grid ────────────────────────────────────────────────────────
function UI.drawGrid(t)
    love.graphics.setColor(0.10, 0.10, 0.14, 1)
    local sz = 48
    local off = (t * 20) % sz
    for x = -sz, SW + sz, sz do
        love.graphics.line(x + off, 0, x + off, SH)
    end
    for y = -sz, SH + sz, sz do
        love.graphics.line(0, y + off, SW, y + off)
    end
end

-- ─── HUD bar ────────────────────────────────────────────────────────────────
function UI.hudBar()
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, SW, 44)
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill", 0, 43, SW, 2)
end

-- ─── Notification flash ─────────────────────────────────────────────────────
function UI.flash(text, alpha)
    love.graphics.setColor(UI.colors.accent[1], UI.colors.accent[2], UI.colors.accent[3], alpha)
    love.graphics.setFont(UI.fonts.heading)
    love.graphics.printf(text, 0, SH/2 - 20, SW, "center")
end

-- ─── Logo / title wordmark ──────────────────────────────────────────────────
function UI.drawLogo(x, y)
    -- "PARKOUR" large
    love.graphics.setFont(UI.fonts.huge)
    love.graphics.setColor(UI.colors.white)
    love.graphics.print("PARKOUR", x, y)

    -- "RUNNER" accent
    love.graphics.setColor(UI.colors.accent)
    local pw = UI.fonts.huge:getWidth("PARKOUR")
    love.graphics.print("RUNNER", x + pw + 14, y + 18)

    -- underline
    love.graphics.setColor(UI.colors.accent)
    love.graphics.rectangle("fill", x, y + 76, pw + 14 + UI.fonts.huge:getWidth("RUNNER"), 4)
end

-- ─── Mode card ──────────────────────────────────────────────────────────────
function UI.modeCard(opts, mx, my)
    local x, y, w, h = opts.x, opts.y, opts.w or 360, opts.h or 180
    local hover = mx >= x and mx <= x+w and my >= y and my <= y+h

    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", x+6, y+6, w, h, 8, 8)

    -- Panel
    love.graphics.setColor(hover and {0.10, 0.10, 0.14, 1} or UI.colors.panel)
    love.graphics.rectangle("fill", x, y, w, h, 8, 8)

    -- Colour stripe on top
    love.graphics.setColor(opts.color or UI.colors.accent)
    love.graphics.rectangle("fill", x, y, w, 5, 4, 4)

    -- Icon character (big)
    love.graphics.setFont(UI.fonts.title)
    love.graphics.setColor(opts.color or UI.colors.accent)
    love.graphics.print(opts.icon or "▶", x + 20, y + 24)

    -- Title
    love.graphics.setFont(UI.fonts.heading)
    love.graphics.setColor(UI.colors.white)
    love.graphics.print(opts.title or "", x + 20, y + 82)

    -- Description
    love.graphics.setFont(UI.fonts.small)
    love.graphics.setColor(UI.colors.grey)
    love.graphics.printf(opts.desc or "", x + 20, y + 116, w - 40, "left")

    -- Hover highlight border
    if hover then
        love.graphics.setColor(opts.color or UI.colors.accent)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, w, h, 8, 8)
        love.graphics.setLineWidth(1)
    end

    return hover
end

-- ─── Helpers ────────────────────────────────────────────────────────────────
function UI.setColor(name)
    local c = UI.colors[name]
    if c then love.graphics.setColor(c) end
end

function UI.fmt_time(secs)
    local m = math.floor(secs / 60)
    local s = math.floor(secs % 60)
    local ms = math.floor((secs % 1) * 100)
    return string.format("%02d:%02d.%02d", m, s, ms)
end

return UI
