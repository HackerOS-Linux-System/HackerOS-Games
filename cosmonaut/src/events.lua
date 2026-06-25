local EVENTS = {
    {msg="Solar flare disrupts communications",               budget=-5,  rep=-5,  science=0},
    {msg="Congressional hearing: additional funding approved!", budget=30, rep=5,   science=0},
    {msg="Public excitement surges — reputation boost",        budget=0,  rep=10,  science=0},
    {msg="Equipment supplier delays delivery",                 budget=0,  rep=-3,  science=0},
    {msg="International collaboration: $20M grant",            budget=20, rep=8,   science=5},
    {msg="Budget review: efficiency bonus awarded",            budget=15, rep=3,   science=0},
    {msg="Lab breakthrough accelerates R&D",                   budget=0,  rep=5,   science=10},
    {msg="Astronaut training accident — morale drops",         budget=0,  rep=-8,  science=0},
    {msg="Private investment: $25M injection",                 budget=25, rep=4,   science=0},
    {msg="Government audit — funds frozen temporarily",        budget=-20,rep=-2,  science=0},
    {msg="Media special: public fascination with space",       budget=5,  rep=12,  science=2},
    {msg="Launch facility fire — minor setback",               budget=-10,rep=-6,  science=0},
    {msg="University partnership: science data shared",        budget=5,  rep=4,   science=15},
    {msg="Foreign dignitary visits HQ — prestige boost",       budget=0,  rep=6,   science=0},
    {msg="Debris impact: insurance pays out $10M",             budget=10, rep=-2,  science=0},
    {msg="Drone footage goes viral — social media buzz",       budget=0,  rep=8,   science=0},
    {msg="Engineer walkout — project delay",                   budget=-8, rep=-4,  science=0},
    {msg="Unexpected asteroid close-call: science windfall",   budget=0,  rep=3,   science=20},
    {msg="Neighboring nation copies designs — IP theft",       budget=-15,rep=-5,  science=0},
    {msg="Record-breaking launch stream viewership",           budget=8,  rep=10,  science=0},
}

-- Milestone events — triggered once
local MILESTONE_EVENTS = {
    orbit        = {msg="First orbit achieved! Historic moment for the agency.", budget=20, rep=15},
    moon_orbit   = {msg="Lunar orbit attained — the Moon within reach!",         budget=15, rep=12},
    moon_landing = {msg="First crewed lunar landing! Humanity reaches the Moon.", budget=50, rep=30},
    mars_probe   = {msg="Mars probe successful — the Red Planet calls!",          budget=10, rep=10},
    mars_surface = {msg="Mars surface mission complete — humanity is multiplanetary!", budget=80, rep=40},
    station      = {msg="Space station fully operational!",                       budget=30, rep=20},
}

function generateEvent(gs)
    local a  = gs.agency
    local ev = EVENTS[math.random(#EVENTS)]
    table.insert(a.events, 1, string.format("[Y%d M%02d] %s", a.year, a.month, ev.msg))
    if #a.events > 12 then table.remove(a.events) end
    a.budget      = a.budget + ev.budget
    a.reputation  = clamp(a.reputation + ev.rep, 0, 100)
    a.science_pts = (a.science_pts or 0) + ev.science
    pushNotification(gs, ev.msg)
end

function triggerMilestoneEvent(gs, key)
    local ev = MILESTONE_EVENTS[key]
    if not ev then return end
    local a = gs.agency
    table.insert(a.events, 1, string.format("[MILESTONE] %s", ev.msg))
    a.budget     = a.budget + ev.budget
    a.reputation = clamp(a.reputation + ev.rep, 0, 100)
    pushNotification(gs, ev.msg)
end

-- Disaster: random rocket explosion during integration
function maybeTriggerDisaster(gs)
    local a = gs.agency
    if math.random() > 0.02 then return end
    local msg = "VAB explosion during rocket integration — investigation underway"
    table.insert(a.events, 1, string.format("[CRISIS] %s", msg))
    a.budget     = a.budget - 20
    a.reputation = clamp(a.reputation - 15, 0, 100)
    pushNotification(gs, msg)
end
