local RIVAL_NAMES = {
    "Cosmosphere Institute", "Stellar Dynamics Corp", "Nova Space Bureau",
    "AeroVox International", "Apex Launch Systems", "Vega Space Alliance",
}
local RIVAL_FLAGS = {"🇷🇺","🇨🇳","🇯🇵","🇪🇺","🇮🇳","🇰🇷"}

function newRival(i)
    return {
        name         = RIVAL_NAMES[i] or ("Rival Agency " .. i),
        flag         = RIVAL_FLAGS[i] or "🌍",
        prestige     = math.random(5, 30),
        aggression   = math.random(40, 85) / 100,
        budget       = math.random(80, 200),
        event_timer  = math.random(3, 8),
        milestones   = {orbit=false, moon_orbit=false, moon_landing=false, mars=false},
        recent       = nil,
    }
end

function updateRivals(gs)
    if not gs.rivals then return end
    if not gs.agency then return end
    local a = gs.agency
    for _, rv in ipairs(gs.rivals) do
        rv.event_timer = rv.event_timer - 1
        rv.budget = rv.budget + math.random(5, 15)
        if rv.event_timer <= 0 then
            rv.event_timer = math.random(3, 10)
            local roll = math.random()
            if roll < rv.aggression * 0.14 then
                attemptRivalMilestone(gs, rv, a)
            end
        end
    end
    -- Decay rival news
    if gs.rivalNews then
        local keep = {}
        for _, n in ipairs(gs.rivalNews) do
            n.timer = n.timer - (1/60)
            if n.timer > 0 then table.insert(keep, n) end
        end
        gs.rivalNews = keep
    end
end

function attemptRivalMilestone(gs, rv, a)
    local msg = nil
    if not rv.milestones.orbit then
        rv.milestones.orbit = true
        rv.prestige = rv.prestige + 20
        msg = rv.name .. " achieved Earth orbit!"
    elseif not rv.milestones.moon_orbit and a.milestones and a.milestones.orbit then
        rv.milestones.moon_orbit = true
        rv.prestige = rv.prestige + 40
        msg = rv.name .. " entered lunar orbit!"
    elseif not rv.milestones.moon_landing and rv.milestones.moon_orbit and math.random() < 0.4 then
        rv.milestones.moon_landing = true
        rv.prestige = rv.prestige + 100
        msg = rv.name .. " landed on the Moon!"
    elseif not rv.milestones.mars and rv.milestones.moon_landing and math.random() < 0.2 then
        rv.milestones.mars = true
        rv.prestige = rv.prestige + 150
        msg = rv.name .. " reached Mars!"
    end
    if msg then
        rv.recent = msg
        if not gs.rivalNews then gs.rivalNews = {} end
        table.insert(gs.rivalNews, 1, {msg=msg, col=COL_RED, timer=8})
        pushNotification(gs, "RIVAL: " .. msg)
    end
end

function rivalLeaderboard(gs)
    if not gs.rivals then return {} end
    local a = gs.agency
    local list = {}
    table.insert(list, {name=a.name, prestige=a.prestige, flag="🚀", player=true})
    for _, rv in ipairs(gs.rivals) do
        table.insert(list, {name=rv.name, prestige=rv.prestige, flag=rv.flag, player=false})
    end
    table.sort(list, function(x, y) return x.prestige > y.prestige end)
    return list
end
