function initStars(gs)
    gs.stars = {}
    for i = 1, 300 do
        table.insert(gs.stars, {
            x          = math.random() * SCREEN_W,
            y          = math.random() * SCREEN_H,
            size       = math.random() * 1.8 + 0.3,
            brightness = math.random() * 0.7 + 0.3,
        })
    end
end

function drawStars(gs, anim)
    for i, s in ipairs(gs.stars) do
        local flicker = 0.7 + 0.3 * math.sin(anim * 1.3 + i * 0.7)
        local alpha   = s.brightness * flicker * 0.78
        setColor({200/255, 210/255, 255/255, alpha})
        love.graphics.circle("fill", s.x, s.y, s.size)
    end
end

-- ── Default rockets ───────────────────────────────────────────────────────────

function defaultRockets(a)
    a.rockets = {}
    table.insert(a.rockets, {
        id=1, name="Vanguard I",
        stages = {
            {name="First Stage",  thrust_kn=130, isp=260, fuel_tons=8.8, dry_mass=1.2, reusable=false},
            {name="Second Stage", thrust_kn=32,  isp=290, fuel_tons=1.8, dry_mass=0.4, reusable=false},
            {name="Third Stage",  thrust_kn=10,  isp=310, fuel_tons=0.5, dry_mass=0.1, reusable=false},
        },
        stage_count=3, payload_kg=22, cost_million=12,
        reliability=0.62, built=true, launches=0, successes=0,
    })
    table.insert(a.rockets, {
        id=2, name="Atlas I",
        stages = {
            {name="Atlas Booster",   thrust_kn=1600, isp=290, fuel_tons=92, dry_mass=8.0, reusable=false},
            {name="Atlas Sustainer", thrust_kn=270,  isp=316, fuel_tons=18, dry_mass=2.5, reusable=false},
            {name="Agena Upper",     thrust_kn=71,   isp=285, fuel_tons=5,  dry_mass=0.7, reusable=false},
        },
        stage_count=2, payload_kg=1360, cost_million=38,
        reliability=0.75, built=true, launches=0, successes=0,
    })
end

-- ── Default astronauts ────────────────────────────────────────────────────────

function defaultAstronauts(a)
    a.astronauts = {}
    local data = {
        {name="John Glenn",      nat="USA", age=32, pil=88, sci=72, eng=80, end_=90},
        {name="Alan Shepard",    nat="USA", age=34, pil=92, sci=68, eng=85, end_=88},
        {name="Gus Grissom",     nat="USA", age=36, pil=85, sci=75, eng=78, end_=85},
        {name="Scott Carpenter", nat="USA", age=38, pil=82, sci=82, eng=70, end_=80},
        {name="Gordon Cooper",   nat="USA", age=40, pil=80, sci=78, eng=82, end_=82},
    }
    for i, d in ipairs(data) do
        table.insert(a.astronauts, {
            id=i, name=d.name, nationality=d.nat, age=d.age,
            piloting=d.pil, science=d.sci, engineering=d.eng, endurance=d.end_,
            experience=0, status="Available", morale=75,
            missions_completed=0, total_flight_months=0,
            specialization=nil, -- unlocked via training
        })
    end
end

-- ── Default research ──────────────────────────────────────────────────────────

function defaultResearch(a)
    a.research = {}
    local projs = {
        {area="PropulsionTech",    name="Kerolox Engine Upgrade",    desc="Improve first-stage thrust and Isp",         cost=8,  dur=6,  unlock="+15% thrust",       prereq=nil},
        {area="LifeSupport",       name="Extended Life Support",     desc="Enable missions beyond 14 days",             cost=6,  dur=4,  unlock="30-day missions",    prereq=nil},
        {area="Navigation",        name="Inertial Guidance Mk.II",   desc="Reduce trajectory errors significantly",     cost=5,  dur=3,  unlock="+10% accuracy",     prereq=nil},
        {area="MaterialScience",   name="Ablative Heat Shield",      desc="Enable reentry from deep-space velocities",  cost=10, dur=8,  unlock="Deep-space reentry", prereq=nil},
        {area="Robotics",          name="Autonomous Lander Systems", desc="Unmanned precision landing capability",      cost=9,  dur=7,  unlock="Robotic landing",    prereq=nil},
        {area="NuclearPropulsion", name="NERVA Prototype",           desc="Nuclear thermal rocket for deep space",      cost=20, dur=14, unlock="Nuclear engine",     prereq="Kerolox Engine Upgrade"},
        {area="ArtificialGravity", name="Rotating Habitat Module",   desc="Eliminate long-term microgravity effects",   cost=15, dur=12, unlock="Art. gravity",       prereq="Extended Life Support"},
        {area="Cryogenics",        name="Cryogenic Fuel Storage",    desc="Enable high-efficiency upper stages",         cost=12, dur=9,  unlock="Cryo upper stage",   prereq=nil},
        {area="AdvancedSensors",   name="Deep Space Antenna Array",  desc="Improve signal quality beyond Mars",         cost=8,  dur=5,  unlock="+15% deep comms",    prereq=nil},
    }
    for _, p in ipairs(projs) do
        table.insert(a.research, {
            area=p.area, name=p.name, description=p.desc,
            cost=p.cost, duration=p.dur, progress=0,
            unlock=p.unlock, completed=false, prereq=p.prereq,
        })
    end
end

-- ── Celestial bodies ──────────────────────────────────────────────────────────

function defaultBodies(gs)
    gs.bodies = {
        {name="Mercury", dist=0.39,  diam=4879,   grav=0.38, color={180/255,150/255,120/255,1}, orbit_r=0.06, orbit_angle=0.6,  explored=false,probed=false,orbited=false,landed=false},
        {name="Venus",   dist=0.72,  diam=12104,  grav=0.90, color={220/255,190/255,80/255,1},  orbit_r=0.10, orbit_angle=1.1,  explored=false,probed=false,orbited=false,landed=false},
        {name="Earth",   dist=1.00,  diam=12742,  grav=1.00, color={60/255,140/255,220/255,1},  orbit_r=0.16, orbit_angle=2.0,  explored=true, probed=true, orbited=true, landed=true},
        {name="Moon",    dist=1.00,  diam=3474,   grav=0.17, color={200/255,200/255,190/255,1}, orbit_r=0.17, orbit_angle=2.4,  explored=false,probed=false,orbited=false,landed=false},
        {name="Mars",    dist=1.52,  diam=6779,   grav=0.38, color={200/255,80/255,40/255,1},   orbit_r=0.28, orbit_angle=0.8,  explored=false,probed=false,orbited=false,landed=false},
        {name="Phobos",  dist=1.52,  diam=22,     grav=0.01, color={160/255,120/255,80/255,1},  orbit_r=0.29, orbit_angle=0.9,  explored=false,probed=false,orbited=false,landed=false},
        {name="Jupiter", dist=5.20,  diam=139820, grav=2.53, color={200/255,160/255,90/255,1},  orbit_r=0.42, orbit_angle=1.6,  explored=false,probed=false,orbited=false,landed=false},
        {name="Saturn",  dist=9.58,  diam=116460, grav=1.07, color={220/255,195/255,130/255,1}, orbit_r=0.58, orbit_angle=2.2,  explored=false,probed=false,orbited=false,landed=false},
        {name="Uranus",  dist=19.22, diam=50724,  grav=0.89, color={120/255,200/255,220/255,1}, orbit_r=0.72, orbit_angle=0.5,  explored=false,probed=false,orbited=false,landed=false},
        {name="Neptune", dist=30.05, diam=49244,  grav=1.14, color={40/255,80/255,220/255,1},   orbit_r=0.84, orbit_angle=1.3,  explored=false,probed=false,orbited=false,landed=false},
        {name="Pluto",   dist=39.48, diam=2377,   grav=0.06, color={160/255,130/255,110/255,1}, orbit_r=0.92, orbit_angle=0.7,  explored=false,probed=false,orbited=false,landed=false},
        {name="Ceres",   dist=2.77,  diam=945,    grav=0.03, color={140/255,140/255,130/255,1}, orbit_r=0.31, orbit_angle=2.8,  explored=false,probed=false,orbited=false,landed=false},
    }
end

-- ── Default rivals ────────────────────────────────────────────────────────────

function defaultRivals(gs)
    gs.rivals = {
        {
            name="Soviet Space Program",
            nation="USSR",
            color=COL_RED,
            prestige=15,
            budget=600,
            missions_completed=0,
            milestones={orbit=false, moon_orbit=false, moon_landing=false, mars=false},
            aggression=0.8, -- how quickly they try to beat you
            event_timer=6,
        },
        {
            name="British Space Agency",
            nation="GBR",
            color=COL_CYAN,
            prestige=5,
            budget=200,
            missions_completed=0,
            milestones={orbit=false, moon_orbit=false, moon_landing=false, mars=false},
            aggression=0.3,
            event_timer=10,
        },
    }
end

-- ── Create new agency ─────────────────────────────────────────────────────────

function newAgency(name)
    local a = {
        name           = name,
        budget         = 500,
        prestige       = 10,
        science_pts    = 0,
        month          = 1,
        year           = 1957,
        monthly_income = 40,
        reputation     = 50,
        facilities     = {launch_pads=1, vab_level=1, tracking_level=1, lab_level=1, hab_level=1},
        missions       = {},
        events         = {},
        completed_research = {},
        -- Expansion: tracked unlocks from research
        unlocks        = {},
    }
    defaultRockets(a)
    defaultAstronauts(a)
    defaultResearch(a)
    return a
end

-- ── New game state ────────────────────────────────────────────────────────────

function newGameState()
    local gs = {
        screen       = SCREENS.MAIN_MENU,
        agency       = nil,
        bodies       = {},
        rivals       = {},
        prevScreen   = SCREENS.MAIN_MENU,
        tab          = 1,
        scroll       = 0,
        selected     = -1,
        selected2    = -1,
        inputBuf     = "",
        setupStep    = 0,
        starAnim     = 0,
        notification = "",
        notifTimer   = 0,
        stars        = {},
        techTreeScroll = 0,
        -- Expansion: rivalry news feed
        rivalNews    = {},
    }
    defaultBodies(gs)
    defaultRivals(gs)
    initStars(gs)
    return gs
end

-- Patch newGameState to initialise contracts, tech-tree unlocks, rival news
local _origNewGameState = newGameState
function newGameState()
    local s = _origNewGameState()
    s.smapZoom  = 1.0
    s.rivalNews = {}
    return s
end

-- Patch newAgency to add contracts + unlocks
local _origNewAgency = newAgency
function newAgency(name, acronym, flag)
    local a = _origNewAgency(name, acronym, flag)
    a.unlocks            = {}
    a.completed_research = {}
    a.contracts          = {}
    a.science_pts        = a.science_pts or 20
    -- initialise research from tech tree
    a.research = buildResearchList(a.unlocks)
    -- generate initial contracts
    generateContracts(a, 5)
    -- 3 rivals
    a.rivals = nil  -- rivals live on gs, not agency
    return a
end
