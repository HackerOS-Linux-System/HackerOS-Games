SCREEN_W   = 1280
SCREEN_H   = 800
TARGET_FPS = 60

-- Colors (r, g, b, a) as tables used with love.graphics.setColor
COL_BG      = {4/255,   6/255,   14/255,  1}
COL_PANEL   = {10/255,  14/255,  26/255,  1}
COL_PANEL2  = {16/255,  22/255,  40/255,  1}
COL_BORDER  = {28/255,  38/255,  62/255,  1}
COL_TEXT    = {210/255, 220/255, 240/255, 1}
COL_DIM     = {90/255,  105/255, 130/255, 1}
COL_ACCENT  = {50/255,  150/255, 255/255, 1}
COL_GREEN   = {40/255,  220/255, 100/255, 1}
COL_RED     = {255/255,  60/255,  60/255, 1}
COL_GOLD    = {255/255, 200/255,  30/255, 1}
COL_ORANGE  = {255/255, 130/255,  30/255, 1}
COL_PURPLE  = {160/255,  80/255, 220/255, 1}
COL_CYAN    = {30/255,  220/255, 220/255, 1}
COL_WHITE   = {1, 1, 1, 1}

-- Screen enum (strings)
SCREENS = {
    MAIN_MENU    = "MainMenu",
    NEW_GAME     = "NewGame",
    DASHBOARD    = "Dashboard",
    ROCKETS      = "Rockets",
    ROCKET_DESIGN = "RocketDesign",
    ASTRONAUTS   = "Astronauts",
    MISSIONS     = "Missions",
    MISSION_PLAN = "MissionPlan",
    RESEARCH     = "Research",
    STAR_MAP     = "StarMap",
    FACILITIES   = "Facilities",
    MISSION_LOG  = "MissionLog",
    TECH_TREE    = "TechTree",
    RIVALRIES    = "Rivalries",
}

-- Nav tabs  {label, screen, col}
NAV_TABS = {
    {label="CONTROL",  screen=SCREENS.DASHBOARD,  col=COL_ACCENT},
    {label="ROCKETS",  screen=SCREENS.ROCKETS,    col=COL_ORANGE},
    {label="CREW",     screen=SCREENS.ASTRONAUTS, col=COL_GREEN},
    {label="MISSIONS", screen=SCREENS.MISSIONS,   col=COL_GOLD},
    {label="RESEARCH", screen=SCREENS.RESEARCH,   col=COL_PURPLE},
    {label="STAR MAP", screen=SCREENS.STAR_MAP,   col=COL_CYAN},
    {label="BASE",     screen=SCREENS.FACILITIES, col=COL_DIM},
    {label="RIVALS",   screen=SCREENS.RIVALRIES,  col=COL_RED},
}

-- Mission types
MISSION_TYPES = {
    "OrbitalTest", "SatelliteNetwork", "CrewedOrbit",
    "LunarFlyby",  "LunarOrbit",       "LunarLanding",
    "MarsProbe",   "MarsOrbiter",      "MarsSurface",
    "AsteroidProbe","SpaceStation",    "DeepSpaceProbe",
    "VenusProbe",  "JupiterFlyby",     "SaturnFlyby",
}

-- Astronaut statuses
ASTRO_STATUS = {
    AVAILABLE = "Available",
    TRAINING  = "Training",
    IN_FLIGHT = "InFlight",
    RETIRED   = "Retired",
    LOST      = "Lost",
}

-- Mission statuses
MISSION_STATUS = {
    PLANNING       = "Planning",
    BUILDING       = "Building",
    READY_TO_LAUNCH= "ReadyToLaunch",
    IN_FLIGHT      = "InFlight",
    SUCCESS        = "Success",
    FAILURE        = "Failure",
    ABORTED        = "Aborted",
}

-- Research areas
RESEARCH_AREAS = {
    "PropulsionTech", "LifeSupport",   "Navigation",
    "MaterialScience","Robotics",      "NuclearPropulsion",
    "ArtificialGravity","Cryogenics",  "AdvancedSensors",
}

-- New screens added in v0.2
SCREENS.CONTRACTS = "Contracts"
SCREENS.TECH_TREE = "TechTree"

-- Extended nav tabs (now 10 items, bound to keys 1-0)
NAV_TABS = {
    {label="CONTROL",    screen=SCREENS.DASHBOARD,   col=COL_ACCENT},
    {label="ROCKETS",    screen=SCREENS.ROCKETS,     col=COL_ORANGE},
    {label="CREW",       screen=SCREENS.ASTRONAUTS,  col=COL_GREEN},
    {label="MISSIONS",   screen=SCREENS.MISSIONS,    col=COL_GOLD},
    {label="R&D",        screen=SCREENS.RESEARCH,    col=COL_PURPLE},
    {label="TECH",       screen=SCREENS.TECH_TREE,   col=COL_CYAN},
    {label="STAR MAP",   screen=SCREENS.STAR_MAP,    col=COL_ACCENT},
    {label="BASE",       screen=SCREENS.FACILITIES,  col=COL_DIM},
    {label="CONTRACTS",  screen=SCREENS.CONTRACTS,   col=COL_GOLD},
    {label="RIVALS",     screen=SCREENS.RIVALRIES,   col=COL_RED},
}
