package cosmonaut

import rl "vendor:raylib"

// ═══════════════════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════════════════

MissionType :: enum {
    OrbitalTest,
    CrewedOrbit,
    LunarFlyby,
    LunarOrbit,
    LunarLanding,
    MarsProbe,
    MarsOrbiter,
    MarsSurface,
    AsteroidProbe,
    SpaceStation,
    DeepSpaceProbe,
    SatelliteNetwork,
}

MissionStatus :: enum {
    Planning,
    Building,
    ReadyToLaunch,
    InFlight,
    Success,
    Failure,
    Aborted,
}

AstronautStatus :: enum {
    Available,
    Training,
    InFlight,
    Retired,
    Lost,
}

ResearchArea :: enum {
    PropulsionTech,
    LifeSupport,
    Navigation,
    MaterialScience,
    Robotics,
    NuclearPropulsion,
    ArtificialGravity,
}

Screen :: enum {
    MainMenu,
    NewGame,
    Dashboard,
    Rockets,
    RocketDesign,
    Astronauts,
    Missions,
    MissionPlan,
    Research,
    StarMap,
    Facilities,
    MissionLog,
}

// ═══════════════════════════════════════════════════════════════════════════════
// STRUCTS
// ═══════════════════════════════════════════════════════════════════════════════

RocketStage :: struct {
    name:      string,
    thrust_kn: f32,
    isp:       f32,
    fuel_tons: f32,
    dry_mass:  f32,
    reusable:  bool,
}

RocketDesign :: struct {
    id:           int,
    name:         string,
    stages:       [3]RocketStage,
    stage_count:  int,
    payload_kg:   f32,
    cost_million: f32,
    reliability:  f32,
    built:        bool,
    launches:     int,
    successes:    int,
}

Astronaut :: struct {
    id:          int,
    name:        string,
    nationality: string,
    age:         int,
    piloting:    int,
    science:     int,
    engineering: int,
    endurance:   int,
    experience:  int,
    status:      AstronautStatus,
    morale:      int,
}

ResearchProject :: struct {
    area:        ResearchArea,
    name:        string,
    description: string,
    cost:        int,
    duration:    int,
    progress:    int,
    unlock:      string,
    completed:   bool,
}

Mission :: struct {
    id:             int,
    name:           string,
    mission_type:   MissionType,
    status:         MissionStatus,
    rocket_id:      int,
    crew:           [4]int,
    crew_count:     int,
    launch_month:   int,
    duration:       int,
    elapsed:        int,
    success_chance: f32,
    prestige:       int,
    science:        int,
    cost:           int,
    log:            [32]string,
    log_count:      int,
    destination:    string,
}

CelestialBody :: struct {
    name:        string,
    distance_au: f32,
    diameter_km: f32,
    gravity_g:   f32,
    explored:    bool,
    probed:      bool,
    orbited:     bool,
    landed:      bool,
    color:       rl.Color,
    orbit_r:     f32,
    orbit_angle: f32,
}

Facilities :: struct {
    launch_pads:    int,
    vab_level:      int,
    tracking_level: int,
    lab_level:      int,
    hab_level:      int,
}

Agency :: struct {
    name:            string,
    budget:          int,
    prestige:        int,
    science_pts:     int,
    month:           int,
    year:            int,
    rockets:         [8]RocketDesign,
    rocket_count:    int,
    astronauts:      [16]Astronaut,
    astronaut_count: int,
    missions:        [32]Mission,
    mission_count:   int,
    research:        [8]ResearchProject,
    research_count:  int,
    monthly_income:  int,
    reputation:      int,
    facilities:      Facilities,
    events:          [8]string,
    event_count:     int,
}

Star :: struct {
    x:          f32,
    y:          f32,
    size:       f32,
    brightness: f32,
}

NavTab :: struct {
    label:  cstring,
    screen: Screen,
    col:    rl.Color,
}

FacilityDef :: struct {
    name:         string,
    level:        ^int,
    max_level:    int,
    desc:         string,
    upgrade_cost: int,
    col:          rl.Color,
}

RocketConfig :: struct {
    name:    string,
    payload: f32,
    cost:    f32,
    rel:     f32,
    stages:  int,
    desc:    string,
}

GameState :: struct {
    screen:       Screen,
    agency:       Agency,
    bodies:       [12]CelestialBody,
    body_count:   int,
    prev_screen:  Screen,
    tab:          int,
    scroll:       f32,
    selected:     int,
    selected2:    int,
    input_buf:    [64]u8,
    input_len:    int,
    setup_step:   int,
    star_anim:    f32,
    notification: [128]u8,
    notif_len:    int,
    notif_timer:  f32,
}
