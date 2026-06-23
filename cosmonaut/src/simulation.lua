local MISSION_DATA = {
    OrbitalTest      = {base=0.92, prestige=5,   dur=1,  mult=1.0, dest="Earth Orbit",  crew=false},
    SatelliteNetwork = {base=0.88, prestige=8,   dur=2,  mult=1.2, dest="Earth Orbit",  crew=false},
    CrewedOrbit      = {base=0.84, prestige=20,  dur=1,  mult=2.0, dest="Earth Orbit",  crew=true},
    LunarFlyby       = {base=0.80, prestige=25,  dur=3,  mult=2.5, dest="Moon",         crew=false},
    LunarOrbit       = {base=0.74, prestige=40,  dur=5,  mult=3.5, dest="Moon",         crew=true},
    LunarLanding     = {base=0.60, prestige=100, dur=8,  mult=6.0, dest="Moon",         crew=true},
    MarsProbe        = {base=0.72, prestige=30,  dur=9,  mult=3.0, dest="Mars",         crew=false},
    MarsOrbiter      = {base=0.62, prestige=50,  dur=12, mult=5.0, dest="Mars",         crew=false},
    MarsSurface      = {base=0.46, prestige=120, dur=24, mult=9.0, dest="Mars",         crew=true},
    AsteroidProbe    = {base=0.66, prestige=25,  dur=18, mult=4.0, dest="Ceres",        crew=false},
    SpaceStation     = {base=0.76, prestige=60,  dur=36, mult=8.0, dest="Earth Orbit",  crew=true},
    DeepSpaceProbe   = {base=0.64, prestige=35,  dur=48, mult=5.0, dest="Neptune",      crew=false},
    VenusProbe       = {base=0.70, prestige=28,  dur=7,  mult=2.8, dest="Venus",        crew=false},
    JupiterFlyby     = {base=0.58, prestige=45,  dur=30, mult=6.5, dest="Jupiter",      crew=false},
    SaturnFlyby      = {base=0.52, prestige=55,  dur=42, mult=7.5, dest="Saturn",       crew=false},
}

function missionBaseChance(mtype, rocket, agency)
    local d = MISSION_DATA[mtype]
    if not d then return 0.5 end
    local base = d.base * rocket.reliability
    base = base + (agency.facilities.tracking_level - 1) * 0.02
    base = base + (agency.facilities.vab_level - 1) * 0.01
    -- Research bonuses
    if agency.unlocks then
        if agency.unlocks["nav_accuracy"] then base = base + 0.10 end
        if agency.unlocks["propulsion"]   then base = base + 0.05 end
    end
    return clamp(base, 0.05, 0.98)
end

function missionPrestige(mtype)
    local d = MISSION_DATA[mtype]
    return d and d.prestige or 10
end

function missionDuration(mtype)
    local d = MISSION_DATA[mtype]
    return d and d.dur or 3
end

function missionCost(mtype, rocket)
    local d = MISSION_DATA[mtype]
    if not d then return rocket.cost_million end
    return math.floor(rocket.cost_million * d.mult)
end

function missionDestination(mtype)
    local d = MISSION_DATA[mtype]
    return d and d.dest or "Space"
end

function missionNeedsCrew(mtype)
    local d = MISSION_DATA[mtype]
    return d and d.crew or false
end

-- ── Body exploration ──────────────────────────────────────────────────────────

function updateBodyExploration(gs, m)
    for _, b in ipairs(gs.bodies) do
        if b.name and m.destination and m.destination:find(b.name) then
            local t = m.mission_type
            if t == "LunarFlyby" or t == "MarsProbe" or t == "AsteroidProbe"
            or t == "DeepSpaceProbe" or t == "VenusProbe"
            or t == "JupiterFlyby"  or t == "SaturnFlyby" then
                b.probed = true
            elseif t == "LunarOrbit" or t == "MarsOrbiter" or t == "SpaceStation" then
                b.probed  = true
                b.orbited = true
            elseif t == "LunarLanding" or t == "MarsSurface" then
                b.probed   = true
                b.orbited  = true
                b.landed   = true
                b.explored = true
            end
        end
    end
end

-- ── Random events ─────────────────────────────────────────────────────────────

local EVENTS = {
    {msg="Solar flare disrupts communications",               budget=-5,  rep=-5},
    {msg="Congressional hearing: additional funding approved!",budget=30,  rep=5},
    {msg="Public excitement surges — reputation boost",        budget=0,   rep=10},
    {msg="Equipment supplier delays delivery",                 budget=0,   rep=-3},
    {msg="International collaboration offer: $20M grant",      budget=20,  rep=8},
    {msg="Budget review: efficiency bonus awarded",            budget=15,  rep=3},
    {msg="Lab breakthrough accelerates R&D",                   budget=0,   rep=5},
    {msg="Astronaut training accident — morale drops",         budget=0,   rep=-8},
    {msg="Private investment interest: $25M injection",        budget=25,  rep=4},
    {msg="Government audit — funds frozen temporarily",        budget=-20, rep=-2},
    {msg="Media special: public fascination with space",       budget=5,   rep=12},
    {msg="Launch facility fire — minor setback",               budget=-10, rep=-6},
}

function generateEvent(gs)
    local a    = gs.agency
    local ev   = EVENTS[math.random(#EVENTS)]
    table.insert(a.events, 1, ev.msg)
    if #a.events > 8 then table.remove(a.events) end
    a.budget     = a.budget + ev.budget
    a.reputation = clamp(a.reputation + ev.rep, 0, 100)
    pushNotification(gs, ev.msg)
end

-- ── Rival simulation ──────────────────────────────────────────────────────────

function updateRivals(gs)
    if not gs.rivals then return end
    local a = gs.agency
    for _, rv in ipairs(gs.rivals) do
        rv.event_timer = rv.event_timer - 1
        if rv.event_timer <= 0 then
            rv.event_timer = math.random(4, 12)
            -- Rivals try to complete milestones based on aggression
            local roll = math.random()
            if roll < rv.aggression * 0.15 then
                -- Rival completes a mission milestone
                if not rv.milestones.orbit then
                    rv.milestones.orbit = true
                    rv.prestige = rv.prestige + 20
                    local msg = rv.name .. " achieved Earth orbit!"
                    table.insert(gs.rivalNews, 1, {msg=msg, col=COL_RED, timer=6})
                    pushNotification(gs, "RIVAL: " .. msg)
                elseif not rv.milestones.moon_orbit and a.milestones and a.milestones.orbit then
                    rv.milestones.moon_orbit = true
                    rv.prestige = rv.prestige + 40
                    local msg = rv.name .. " reached lunar orbit!"
                    table.insert(gs.rivalNews, 1, {msg=msg, col=COL_RED, timer=6})
                    pushNotification(gs, "RIVAL: " .. msg)
                end
            end
        end
    end
    -- Cull old rival news
    local keep = {}
    for _, n in ipairs(gs.rivalNews or {}) do
        n.timer = n.timer - (1/60)
        if n.timer > 0 then table.insert(keep, n) end
    end
    gs.rivalNews = keep
end

-- ── Main simulation tick ──────────────────────────────────────────────────────

function advanceMonth(gs)
    local a = gs.agency

    -- Track milestones
    if not a.milestones then
        a.milestones = {orbit=false, moon_orbit=false, moon_landing=false, mars=false}
    end

    a.month = a.month + 1
    if a.month > 12 then a.month = 1; a.year = a.year + 1 end

    -- Income
    local income = a.monthly_income + math.floor((a.reputation - 50) / 5)
    a.budget = a.budget + income

    -- Upkeep
    local upkeep = 10 + a.facilities.vab_level * 3 + a.facilities.launch_pads * 5
    a.budget = a.budget - upkeep

    -- Astronaut aging & retirement
    for _, ast in ipairs(a.astronauts) do
        if ast.status == "Available" then
            -- Small morale recovery per month
            ast.morale = math.min(100, ast.morale + 2)
        end
        -- Age every 12 months
        if a.month == 1 then
            ast.age = ast.age + 1
            if ast.age >= 60 and ast.status == "Available" and math.random() < 0.3 then
                ast.status = "Retired"
                pushNotification(gs, ast.name .. " has retired from the astronaut corps.")
            end
        end
    end

    -- Research progress
    for _, r in ipairs(a.research) do
        if not r.completed and r.progress > 0 and r.progress < r.duration then
            -- Lab level speeds research
            local speed = 1 + (a.facilities.lab_level - 1) * 0.2
            r.progress = r.progress + speed
            if r.progress >= r.duration then
                r.progress   = r.duration
                r.completed  = true
                -- Apply unlock
                applyResearchUnlock(a, r)
                pushNotification(gs, "Research complete: " .. r.name)
                a.science_pts = a.science_pts + 15
                a.prestige    = a.prestige + 5
            end
        end
    end

    -- Mission progress
    for _, m in ipairs(a.missions) do
        if m.status ~= "InFlight" then goto continue end
        m.elapsed = m.elapsed + 1
        appendMissionLog(m, string.format("Month %d/%d: Nominal", m.elapsed, m.duration))

        -- In-flight events
        local roll = math.random()
        if roll < 0.04 then
            appendMissionLog(m, "Minor anomaly — crew responding")
        elseif roll < 0.015 then
            m.success_chance = m.success_chance * 0.75
            appendMissionLog(m, "CRITICAL: System failure detected")
        end

        if m.elapsed < m.duration then goto continue end

        -- Outcome
        if math.random() < m.success_chance then
            m.status      = "Success"
            a.prestige    = a.prestige + m.prestige
            a.science_pts = a.science_pts + m.science
            a.budget      = a.budget + math.floor(m.cost / 4)
            a.reputation  = math.min(100, a.reputation + 3)
            pushNotification(gs, "SUCCESS: " .. m.name .. " returned!")
            updateBodyExploration(gs, m)
            -- Milestones
            if m.destination == "Earth Orbit" and not a.milestones.orbit then
                a.milestones.orbit = true
            end
            if m.destination == "Moon" and m.mission_type == "LunarLanding" and not a.milestones.moon_landing then
                a.milestones.moon_landing = true
                a.prestige = a.prestige + 50 -- bonus
                pushNotification(gs, "HISTORIC: First Lunar Landing achieved!")
            end
            -- Restore crew
            for _, aid in ipairs(m.crew or {}) do
                for _, ast in ipairs(a.astronauts) do
                    if ast.id == aid then
                        ast.status = "Available"
                        ast.experience = ast.experience + 1
                        ast.missions_completed = (ast.missions_completed or 0) + 1
                        ast.total_flight_months = (ast.total_flight_months or 0) + m.duration
                        ast.morale = math.min(100, ast.morale + 15)
                    end
                end
            end
            -- Update rocket stats
            for _, rk in ipairs(a.rockets) do
                if rk.id == m.rocket_id then
                    rk.successes = rk.successes + 1
                    -- Slight reliability improvement from experience
                    rk.reliability = math.min(0.99, rk.reliability + 0.002)
                end
            end
        else
            m.status     = "Failure"
            a.prestige   = math.max(0, a.prestige - math.floor(m.prestige / 2))
            a.reputation = math.max(0, a.reputation - 10)
            pushNotification(gs, "FAILURE: " .. m.name .. " lost contact")
            -- Crew fate
            if #(m.crew or {}) > 0 and math.random() < 0.4 then
                for _, aid in ipairs(m.crew) do
                    for _, ast in ipairs(a.astronauts) do
                        if ast.id == aid then ast.status = "Lost" end
                    end
                end
                pushNotification(gs, "Crew lost in mission failure")
            else
                for _, aid in ipairs(m.crew or {}) do
                    for _, ast in ipairs(a.astronauts) do
                        if ast.id == aid and ast.status == "InFlight" then
                            ast.status = "Available"
                            ast.morale = math.max(0, ast.morale - 30)
                        end
                    end
                end
            end
        end
        ::continue::
    end

    -- Random event
    if math.random() < 0.12 then generateEvent(gs) end

    -- Reputation drift
    if a.reputation > 50 then a.reputation = a.reputation - 1 end
    if a.reputation < 50 then a.reputation = a.reputation + 1 end

    -- Rivals
    updateRivals(gs)

    -- Orbit angle animation
    for _, b in ipairs(gs.bodies) do
        b.orbit_angle = b.orbit_angle + 0.05 / (b.dist or 1)
    end
end

-- ── Apply research unlock ──────────────────────────────────────────────────────

function applyResearchUnlock(a, r)
    if not a.unlocks then a.unlocks = {} end
    if r.area == "Navigation"        then a.unlocks["nav_accuracy"]   = true end
    if r.area == "PropulsionTech"    then a.unlocks["propulsion"]     = true end
    if r.area == "LifeSupport"       then a.unlocks["long_duration"]  = true end
    if r.area == "NuclearPropulsion" then a.unlocks["nuclear_engine"] = true end
    if r.area == "Cryogenics"        then a.unlocks["cryo_stage"]     = true end
    if r.area == "ArtificialGravity" then a.unlocks["art_gravity"]    = true end
    if r.area == "AdvancedSensors"   then a.unlocks["deep_comms"]     = true end
    table.insert(a.completed_research or {}, r.name)
end
