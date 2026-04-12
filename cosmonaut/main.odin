package cosmonaut

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:encoding/json"
import rl "vendor:raylib"

// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

SCREEN_W :: 1280
SCREEN_H :: 800
TARGET_FPS :: 60
SAVE_PATH :: "cosmonaut_save.json"

// Colors
COL_BG       :: rl.Color{4,   6,  14, 255}
COL_PANEL    :: rl.Color{10,  14,  26, 255}
COL_PANEL2   :: rl.Color{16,  22,  40, 255}
COL_BORDER   :: rl.Color{28,  38,  62, 255}
COL_TEXT     :: rl.Color{210, 220, 240, 255}
COL_DIM      :: rl.Color{90, 105, 130, 255}
COL_ACCENT   :: rl.Color{50,  150, 255, 255}  // NASA blue
COL_GREEN    :: rl.Color{40,  220, 100, 255}
COL_RED      :: rl.Color{255,  60,  60, 255}
COL_GOLD     :: rl.Color{255, 200,  30, 255}
COL_ORANGE   :: rl.Color{255, 130,  30, 255}
COL_PURPLE   :: rl.Color{160,  80, 220, 255}
COL_CYAN     :: rl.Color{ 30, 220, 220, 255}
COL_WHITE    :: rl.Color{255, 255, 255, 255}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA TYPES
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

RocketStage :: struct {
    name:       string,
    thrust_kn:  f32,
    isp:        f32,   // specific impulse
    fuel_tons:  f32,
    dry_mass:   f32,
    reusable:   bool,
}

RocketDesign :: struct {
    id:           int,
    name:         string,
    stages:       [3]RocketStage,
    stage_count:  int,
    payload_kg:   f32,
    cost_million: f32,
    reliability:  f32,  // 0..1
    built:        bool,
    launches:     int,
    successes:    int,
}

Astronaut :: struct {
    id:           int,
    name:         string,
    nationality:  string,
    age:          int,
    piloting:     int,   // 0-99
    science:      int,
    engineering:  int,
    endurance:    int,
    experience:   int,   // missions flown
    status:       AstronautStatus,
    morale:       int,   // 0-100
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

ResearchProject :: struct {
    area:         ResearchArea,
    name:         string,
    description:  string,
    cost:         int,
    duration:     int,   // months
    progress:     int,   // months completed
    unlock:       string,
    completed:    bool,
}

Mission :: struct {
    id:            int,
    name:          string,
    mission_type:  MissionType,
    status:        MissionStatus,
    rocket_id:     int,
    crew:          [4]int,   // astronaut IDs, -1 = empty
    crew_count:    int,
    launch_month:  int,
    duration:      int,   // months
    elapsed:       int,
    success_chance: f32,
    prestige:      int,
    science:       int,
    cost:          int,
    log:           [32]string,
    log_count:     int,
    destination:   string,
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
    x, y:        f32,   // position on star map (normalized)
}

Technology :: struct {
    id:        string,
    name:      string,
    unlocked:  bool,
    bonus:     string,
}

Agency :: struct {
    name:           string,
    budget:         int,      // millions USD
    prestige:       int,      // 0-1000
    science_pts:    int,
    month:          int,      // 1 = Jan 1957
    year:           int,
    rockets:        [8]RocketDesign,
    rocket_count:   int,
    astronauts:     [16]Astronaut,
    astronaut_count: int,
    missions:       [32]Mission,
    mission_count:  int,
    research:       [8]ResearchProject,
    research_count: int,
    techs:          [16]Technology,
    tech_count:     int,
    monthly_income: int,
    reputation:     int,      // 0-100, affects funding
    facilities:     Facilities,
    events:         [8]string,
    event_count:    int,
}

Facilities :: struct {
    launch_pads:    int,    // 1-4
    vab_level:      int,    // Vehicle Assembly Building 1-5
    tracking_level: int,    // 1-5
    lab_level:      int,    // 1-5
    hab_level:      int,    // astronaut training 1-5
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
    Settings,
}

GameState :: struct {
    screen:         Screen,
    agency:         Agency,
    bodies:         [12]CelestialBody,
    body_count:     int,
    prev_screen:    Screen,
    tab:            int,
    scroll:         f32,
    selected:       int,
    selected2:      int,
    input_buf:      [64]u8,
    input_len:      int,
    input_active:   bool,
    setup_step:     int,
    msg:            [128]u8,
    msg_len:        int,
    msg_timer:      f32,
    paused:         bool,
    confirm_action: int,   // 0=none, 1=launch, 2=retire astronaut
    star_anim:      f32,
    notification:   [64]u8,
    notif_len:      int,
    notif_timer:    f32,
}

// ═══════════════════════════════════════════════════════════════════════════════
// STAR FIELD
// ═══════════════════════════════════════════════════════════════════════════════

Star :: struct { x, y, size, brightness: f32 }

stars: [300]Star
star_count := 0

init_stars :: proc() {
    star_count = 300
    for i in 0..<star_count {
        stars[i] = Star{
            x:          rand.float32() * SCREEN_W,
            y:          rand.float32() * SCREEN_H,
            size:       rand.float32() * 1.8 + 0.3,
            brightness: rand.float32() * 0.7 + 0.3,
        }
    }
}

draw_stars :: proc(anim: f32) {
    for i in 0..<star_count {
        s := &stars[i]
        flicker := 0.7 + 0.3 * math.sin_f32(anim * 1.3 + f32(i) * 0.7)
        alpha := u8(s.brightness * flicker * 200)
        rl.DrawCircle(i32(s.x), i32(s.y), s.size, rl.Color{200, 210, 255, alpha})
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

panel :: proc(x, y, w, h: f32, col: rl.Color) {
    rl.DrawRectangle(i32(x), i32(y), i32(w), i32(h), col)
    rl.DrawRectangleLines(i32(x), i32(y), i32(w), i32(h), COL_BORDER)
}

label :: proc(text: cstring, x, y: f32, size: i32, col: rl.Color) {
    rl.DrawText(text, i32(x), i32(y), size, col)
}

label_str :: proc(text: string, x, y: f32, size: i32, col: rl.Color) {
    cstr := strings.clone_to_cstring(text)
    defer delete(cstr)
    rl.DrawText(cstr, i32(x), i32(y), size, col)
}

button :: proc(text: cstring, x, y, w, h: f32, col: rl.Color, disabled := false) -> bool {
    mx := f32(rl.GetMouseX())
    my := f32(rl.GetMouseY())
    hover := !disabled && mx >= x && mx <= x+w && my >= y && my <= y+h
    bg := rl.Color{col.r/5, col.g/5, col.b/5, 200}
    if hover { bg = rl.Color{col.r/3, col.g/3, col.b/3, 220} }
    if disabled { bg = rl.Color{20, 22, 28, 180} }
    rl.DrawRectangle(i32(x), i32(y), i32(w), i32(h), bg)
    border := disabled ? COL_BORDER : (hover ? col : rl.Color{col.r/3, col.g/3, col.b/3, 200})
    rl.DrawRectangleLines(i32(x), i32(y), i32(w), i32(h), border)
    tw := rl.MeasureText(text, 17)
    tx := x + (w - f32(tw)) / 2
    ty := y + h/2 - 9
    tcol := disabled ? COL_DIM : (hover ? col : COL_TEXT)
    rl.DrawText(text, i32(tx), i32(ty), 17, tcol)
    return hover && rl.IsMouseButtonPressed(.LEFT)
}

stat_bar :: proc(lbl: cstring, val, max_val: f32, x, y, w: f32, col: rl.Color) {
    rl.DrawText(lbl, i32(x), i32(y), 13, COL_DIM)
    bx := x + 110
    bw := w - 120
    rl.DrawRectangle(i32(bx), i32(y), i32(bw), 12, COL_PANEL2)
    fill := bw * math.clamp(val/max_val, 0, 1)
    rl.DrawRectangle(i32(bx), i32(y), i32(fill), 12, col)
    rl.DrawRectangleLines(i32(bx), i32(y), i32(bw), 12, COL_BORDER)
    val_str := fmt.tprintf("%d", int(val))
    rl.DrawText(strings.clone_to_cstring(val_str), i32(bx + bw + 5), i32(y), 13, COL_TEXT)
}

section_line :: proc(title: cstring, y: f32) {
    rl.DrawLine(20, i32(y), SCREEN_W-20, i32(y), COL_BORDER)
    tw := rl.MeasureText(title, 16)
    cx := f32(SCREEN_W)/2 - f32(tw)/2
    rl.DrawRectangle(i32(cx)-8, i32(y)-10, tw+16, 20, COL_BG)
    rl.DrawText(title, i32(cx), i32(y)-6, 16, COL_DIM)
}

mission_type_name :: proc(t: MissionType) -> string {
    switch t {
        case .OrbitalTest:      return "Orbital Test"
        case .CrewedOrbit:      return "Crewed Orbit"
        case .LunarFlyby:       return "Lunar Flyby"
        case .LunarOrbit:       return "Lunar Orbit"
        case .LunarLanding:     return "Lunar Landing"
        case .MarsProbe:        return "Mars Probe"
        case .MarsOrbiter:      return "Mars Orbiter"
        case .MarsSurface:      return "Mars Surface"
        case .AsteroidProbe:    return "Asteroid Probe"
        case .SpaceStation:     return "Space Station"
        case .DeepSpaceProbe:   return "Deep Space"
        case .SatelliteNetwork: return "Satellite Network"
    }
    return "Unknown"
}

mission_status_col :: proc(s: MissionStatus) -> rl.Color {
    switch s {
        case .Planning:       return COL_DIM
        case .Building:       return COL_ORANGE
        case .ReadyToLaunch:  return COL_CYAN
        case .InFlight:       return COL_ACCENT
        case .Success:        return COL_GREEN
        case .Failure:        return COL_RED
        case .Aborted:        return COL_RED
    }
    return COL_TEXT
}

research_area_name :: proc(a: ResearchArea) -> string {
    switch a {
        case .PropulsionTech:   return "Propulsion"
        case .LifeSupport:      return "Life Support"
        case .Navigation:       return "Navigation"
        case .MaterialScience:  return "Materials"
        case .Robotics:         return "Robotics"
        case .NuclearPropulsion: return "Nuclear Prop."
        case .ArtificialGravity: return "Artif. Gravity"
    }
    return "Research"
}

research_area_col :: proc(a: ResearchArea) -> rl.Color {
    switch a {
        case .PropulsionTech:    return COL_ORANGE
        case .LifeSupport:       return COL_GREEN
        case .Navigation:        return COL_ACCENT
        case .MaterialScience:   return COL_CYAN
        case .Robotics:          return COL_PURPLE
        case .NuclearPropulsion: return COL_RED
        case .ArtificialGravity: return COL_GOLD
    }
    return COL_TEXT
}

month_name :: proc(m: int) -> string {
    names := []string{"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return names[(m-1) % 12]
}

// ═══════════════════════════════════════════════════════════════════════════════
// INIT
// ═══════════════════════════════════════════════════════════════════════════════

default_rockets :: proc(agency: ^Agency) {
    agency.rockets[0] = RocketDesign{
        id = 1, name = "Vanguard I",
        stages = {
            RocketStage{"First Stage", 130, 260, 8.8, 1.2, false},
            RocketStage{"Second Stage", 32, 290, 1.8, 0.4, false},
            RocketStage{"Third Stage", 10, 310, 0.5, 0.1, false},
        },
        stage_count = 3,
        payload_kg = 22, cost_million = 12,
        reliability = 0.62, built = true,
    }
    agency.rockets[1] = RocketDesign{
        id = 2, name = "Atlas I",
        stages = {
            RocketStage{"Atlas Booster", 1600, 290, 92, 8, false},
            RocketStage{"Atlas Sustainer", 270, 316, 18, 2.5, false},
            RocketStage{"Agena Upper", 71, 285, 5, 0.7, false},
        },
        stage_count = 2,
        payload_kg = 1360, cost_million = 38,
        reliability = 0.75, built = true,
    }
    agency.rocket_count = 2
}

default_astronauts :: proc(agency: ^Agency) {
    names := []string{
        "John Glenn", "Alan Shepard", "Gus Grissom",
        "Scott Carpenter", "Gordon Cooper",
    }
    nats := []string{"USA","USA","USA","USA","USA"}
    paces := []int{88, 92, 85, 82, 80}
    scs   := []int{72, 68, 75, 82, 78}
    engs  := []int{80, 85, 78, 70, 82}
    ends  := []int{90, 88, 85, 80, 82}

    for i in 0..<5 {
        agency.astronauts[i] = Astronaut{
            id = i+1, name = names[i],
            nationality = nats[i],
            age = 32 + i*2,
            piloting = paces[i], science = scs[i],
            engineering = engs[i], endurance = ends[i],
            experience = 0, status = .Available, morale = 75,
        }
    }
    agency.astronaut_count = 5
}

default_research :: proc(agency: ^Agency) {
    projects := []ResearchProject{
        {.PropulsionTech,   "Kerolox Engine Upgrade",    "Improve first-stage thrust and Isp",         8,  6, 0, "+15% thrust",    false},
        {.LifeSupport,      "Extended Life Support",     "Enable missions beyond 14 days",             6,  4, 0, "30-day missions", false},
        {.Navigation,       "Inertial Guidance Mk.II",   "Reduce trajectory errors significantly",     5,  3, 0, "+10% accuracy",   false},
        {.MaterialScience,  "Ablative Heat Shield",      "Enable reentry from deep-space velocities",  10, 8, 0, "Deep-space reentry",false},
        {.Robotics,         "Autonomous Lander Systems", "Unmanned precision landing capability",      9,  7, 0, "Robotic landing", false},
        {.NuclearPropulsion,"NERVA Prototype",           "Nuclear thermal rocket for deep space",      20, 14,0, "Nuclear engine",  false},
        {.ArtificialGravity,"Rotating Habitat Module",  "Eliminate long-term microgravity effects",   15, 12,0, "Artif. gravity",  false},
    }
    for i in 0..<len(projects) {
        agency.research[i] = projects[i]
    }
    agency.research_count = len(projects)
}

default_bodies :: proc(gs: ^GameState) {
    gs.bodies[0]  = CelestialBody{"Mercury", 0.39, 4879,  0.38, false, false, false, false, rl.Color{180,150,120,255}, 0.20, 0.55}
    gs.bodies[1]  = CelestialBody{"Venus",   0.72, 12104, 0.90, false, false, false, false, rl.Color{220,190, 80,255}, 0.30, 0.48}
    gs.bodies[2]  = CelestialBody{"Earth",   1.00, 12742, 1.00, true,  true,  true,  true,  rl.Color{ 60,140,220,255}, 0.42, 0.50}
    gs.bodies[3]  = CelestialBody{"Moon",    1.00,  3474, 0.17, false, false, false, false, rl.Color{200,200,190,255}, 0.50, 0.50}
    gs.bodies[4]  = CelestialBody{"Mars",    1.52,  6779, 0.38, false, false, false, false, rl.Color{200, 80, 40,255}, 0.60, 0.52}
    gs.bodies[5]  = CelestialBody{"Phobos",  1.52,    22, 0.01, false, false, false, false, rl.Color{160,120, 80,255}, 0.63, 0.49}
    gs.bodies[6]  = CelestialBody{"Jupiter", 5.20, 139820,2.53, false, false, false, false, rl.Color{200,160, 90,255}, 0.72, 0.44}
    gs.bodies[7]  = CelestialBody{"Saturn",  9.58, 116460,1.07, false, false, false, false, rl.Color{220,195,130,255}, 0.80, 0.56}
    gs.bodies[8]  = CelestialBody{"Uranus", 19.22,  50724,0.89, false, false, false, false, rl.Color{120,200,220,255}, 0.87, 0.42}
    gs.bodies[9]  = CelestialBody{"Neptune",30.05,  49244,1.14, false, false, false, false, rl.Color{ 40, 80,220,255}, 0.92, 0.58}
    gs.bodies[10] = CelestialBody{"Pluto",  39.48,   2377,0.06, false, false, false, false, rl.Color{160,130,110,255}, 0.95, 0.52}
    gs.bodies[11] = CelestialBody{"Ceres",   2.77,    945,0.03, false, false, false, false, rl.Color{140,140,130,255}, 0.65, 0.60}
    gs.body_count = 12
}

new_agency :: proc(name: string) -> Agency {
    a := Agency{
        name         = name,
        budget       = 500,
        prestige     = 10,
        science_pts  = 0,
        month        = 1,
        year         = 1957,
        monthly_income = 40,
        reputation   = 50,
        facilities   = Facilities{1, 1, 1, 1, 1},
    }
    default_rockets(&a)
    default_astronauts(&a)
    default_research(&a)
    return a
}

// ═══════════════════════════════════════════════════════════════════════════════
// SIMULATION
// ═══════════════════════════════════════════════════════════════════════════════

advance_month :: proc(gs: ^GameState) {
    a := &gs.agency
    a.month += 1
    if a.month > 12 {
        a.month = 1
        a.year += 1
    }

    // Income (modified by reputation)
    income := a.monthly_income + (a.reputation - 50) / 5
    a.budget += income

    // Upkeep
    upkeep := 10 + a.facilities.vab_level * 3 + a.facilities.launch_pads * 5
    a.budget -= upkeep

    // Research progress
    for i in 0..<a.research_count {
        r := &a.research[i]
        if !r.completed && r.progress > 0 && r.progress < r.duration {
            r.progress += 1
            if r.progress >= r.duration {
                r.completed = true
                push_notification(gs, fmt.tprintf("Research complete: %s", r.name))
                a.science_pts += 15
                a.prestige += 5
            }
        }
    }

    // Mission progress
    for i in 0..<a.mission_count {
        m := &a.missions[i]
        if m.status == .InFlight {
            m.elapsed += 1
            append_mission_log(m, fmt.tprintf("Month %d: Mission nominal", m.elapsed))

            // Random events
            roll := rand.float32()
            if roll < 0.05 {
                // Minor anomaly
                append_mission_log(m, "Anomaly detected — crew responding")
            } else if roll < 0.02 {
                // Critical failure
                m.success_chance *= 0.7
                append_mission_log(m, "CRITICAL: System failure — abort considerations")
            }

            if m.elapsed >= m.duration {
                // Mission complete
                final_roll := rand.float32()
                if final_roll < m.success_chance {
                    m.status = .Success
                    a.prestige    += m.prestige
                    a.science_pts += m.science
                    a.budget      += m.cost / 4  // recovery bonus
                    push_notification(gs, fmt.tprintf("SUCCESS: %s returned!", m.name))
                    // Update bodies
                    update_body_exploration(gs, m)
                    // Update astronaut experience
                    for j in 0..<m.crew_count {
                        aid := m.crew[j]
                        for k in 0..<a.astronaut_count {
                            if a.astronauts[k].id == aid {
                                a.astronauts[k].experience += 1
                                a.astronauts[k].status = .Available
                                a.astronauts[k].morale = min(100, a.astronauts[k].morale + 15)
                            }
                        }
                    }
                } else {
                    m.status = .Failure
                    a.prestige    = max(0, a.prestige - m.prestige/2)
                    a.reputation  = max(0, a.reputation - 10)
                    push_notification(gs, fmt.tprintf("FAILURE: %s lost contact", m.name))
                    // Crew loss on crewed missions
                    if m.crew_count > 0 && rand.float32() < 0.4 {
                        for j in 0..<m.crew_count {
                            aid := m.crew[j]
                            for k in 0..<a.astronaut_count {
                                if a.astronauts[k].id == aid {
                                    a.astronauts[k].status = .Lost
                                }
                            }
                        }
                        push_notification(gs, "Crew lost in mission failure")
                    } else {
                        for j in 0..<m.crew_count {
                            aid := m.crew[j]
                            for k in 0..<a.astronaut_count {
                                if a.astronauts[k].id == aid && a.astronauts[k].status == .InFlight {
                                    a.astronauts[k].status = .Available
                                    a.astronauts[k].morale = max(0, a.astronauts[k].morale - 30)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Random events
    if rand.float32() < 0.12 {
        generate_event(gs)
    }

    // Reputation decay towards 50
    if a.reputation > 50 { a.reputation -= 1 }
    if a.reputation < 50 { a.reputation += 1 }
}

update_body_exploration :: proc(gs: ^GameState, m: ^Mission) {
    target := m.destination
    for i in 0..<gs.body_count {
        b := &gs.bodies[i]
        if strings.contains(target, b.name) {
            switch m.mission_type {
                case .LunarFlyby, .MarsProbe, .AsteroidProbe, .DeepSpaceProbe:
                    b.probed = true
                case .LunarOrbit, .MarsOrbiter, .SpaceStation:
                    b.orbited = true
                    b.probed  = true
                case .LunarLanding, .MarsSurface:
                    b.landed  = true
                    b.orbited = true
                    b.probed  = true
                    b.explored = true
                case .OrbitalTest, .CrewedOrbit, .SatelliteNetwork:
                    // Earth missions
            }
        }
    }
}

generate_event :: proc(gs: ^GameState) {
    a := &gs.agency
    events := []string{
        "Solar flare disrupts communications — tracking delayed",
        "Congressional hearing: additional funding approved!",
        "Public excitement surges — reputation +5",
        "Equipment supplier delays delivery — mission delayed",
        "International collaboration offer received",
        "Budget review: efficiency bonus awarded",
        "Technical breakthrough in lab",
        "Astronaut training accident — morale drops",
    }
    bonuses := []int{-5, 30, 0, 0, 20, 15, 0, 0}
    rep_bonus := []int{-5, 5, 10, -3, 8, 3, 5, -8}

    idx := int(rand.float32() * f32(len(events)))
    if a.event_count < 8 {
        a.events[a.event_count] = events[idx]
        a.event_count += 1
    } else {
        // Shift
        for i in 0..<7 { a.events[i] = a.events[i+1] }
        a.events[7] = events[idx]
    }
    a.budget += bonuses[idx]
    a.reputation = clamp(a.reputation + rep_bonus[idx], 0, 100)
    push_notification(gs, events[idx])
}

append_mission_log :: proc(m: ^Mission, entry: string) {
    if m.log_count < 32 {
        m.log[m.log_count] = entry
        m.log_count += 1
    } else {
        for i in 0..<31 { m.log[i] = m.log[i+1] }
        m.log[31] = entry
    }
}

push_notification :: proc(gs: ^GameState, msg: string) {
    n := min(len(msg), 63)
    gs.notif_len = n
    for i in 0..<n { gs.notification[i] = msg[i] }
    gs.notif_timer = 4.0
}

// ═══════════════════════════════════════════════════════════════════════════════
// MISSION PLANNING HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

mission_base_chance :: proc(t: MissionType, rocket: ^RocketDesign, agency: ^Agency) -> f32 {
    base: f32
    switch t {
        case .OrbitalTest:      base = 0.90
        case .SatelliteNetwork: base = 0.85
        case .CrewedOrbit:      base = 0.82
        case .LunarFlyby:       base = 0.78
        case .LunarOrbit:       base = 0.72
        case .LunarLanding:     base = 0.58
        case .MarsProbe:        base = 0.70
        case .MarsOrbiter:      base = 0.60
        case .MarsSurface:      base = 0.45
        case .AsteroidProbe:    base = 0.65
        case .SpaceStation:     base = 0.75
        case .DeepSpaceProbe:   base = 0.62
    }
    // Modifiers
    base *= rocket.reliability
    base += f32(agency.facilities.tracking_level - 1) * 0.02
    base += f32(agency.facilities.vab_level - 1) * 0.01
    return math.clamp(base, 0.05, 0.98)
}

mission_prestige :: proc(t: MissionType) -> int {
    switch t {
        case .OrbitalTest:      return 5
        case .SatelliteNetwork: return 8
        case .CrewedOrbit:      return 20
        case .LunarFlyby:       return 25
        case .LunarOrbit:       return 40
        case .LunarLanding:     return 100
        case .MarsProbe:        return 30
        case .MarsOrbiter:      return 50
        case .MarsSurface:      return 120
        case .AsteroidProbe:    return 25
        case .SpaceStation:     return 60
        case .DeepSpaceProbe:   return 35
    }
    return 10
}

mission_duration :: proc(t: MissionType) -> int {
    switch t {
        case .OrbitalTest:      return 1
        case .SatelliteNetwork: return 2
        case .CrewedOrbit:      return 1
        case .LunarFlyby:       return 3
        case .LunarOrbit:       return 5
        case .LunarLanding:     return 8
        case .MarsProbe:        return 9
        case .MarsOrbiter:      return 12
        case .MarsSurface:      return 24
        case .AsteroidProbe:    return 18
        case .SpaceStation:     return 36
        case .DeepSpaceProbe:   return 48
    }
    return 3
}

mission_cost :: proc(t: MissionType, rocket: ^RocketDesign) -> int {
    base := rocket.cost_million
    mult: f32
    switch t {
        case .OrbitalTest:      mult = 1.0
        case .SatelliteNetwork: mult = 1.2
        case .CrewedOrbit:      mult = 2.0
        case .LunarFlyby:       mult = 2.5
        case .LunarOrbit:       mult = 3.5
        case .LunarLanding:     mult = 6.0
        case .MarsProbe:        mult = 3.0
        case .MarsOrbiter:      mult = 5.0
        case .MarsSurface:      mult = 9.0
        case .AsteroidProbe:    mult = 4.0
        case .SpaceStation:     mult = 8.0
        case .DeepSpaceProbe:   mult = 5.0
    }
    return int(base * mult)
}

mission_needs_crew :: proc(t: MissionType) -> bool {
    switch t {
        case .CrewedOrbit, .LunarOrbit, .LunarLanding, .MarsSurface, .SpaceStation:
            return true
    }
    return false
}

mission_destination :: proc(t: MissionType) -> string {
    switch t {
        case .OrbitalTest:      return "Earth Orbit"
        case .SatelliteNetwork: return "Earth Orbit"
        case .CrewedOrbit:      return "Earth Orbit"
        case .LunarFlyby:       return "Moon Flyby"
        case .LunarOrbit:       return "Moon Orbit"
        case .LunarLanding:     return "Moon Surface"
        case .MarsProbe:        return "Mars"
        case .MarsOrbiter:      return "Mars Orbit"
        case .MarsSurface:      return "Mars Surface"
        case .AsteroidProbe:    return "Ceres"
        case .SpaceStation:     return "Earth Orbit"
        case .DeepSpaceProbe:   return "Neptune"
    }
    return "Space"
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: TOPBAR
// ═══════════════════════════════════════════════════════════════════════════════

draw_topbar :: proc(gs: ^GameState) {
    a := &gs.agency
    rl.DrawRectangle(0, 0, SCREEN_W, 44, rl.Color{5, 8, 18, 245})
    rl.DrawLine(0, 44, SCREEN_W, 44, COL_BORDER)

    // Agency name
    name_cstr := strings.clone_to_cstring(a.name)
    defer delete(name_cstr)
    rl.DrawText(name_cstr, 14, 12, 20, COL_ACCENT)

    // Date
    date_str := fmt.tprintf("%s %d", month_name(a.month), a.year)
    rl.DrawText(strings.clone_to_cstring(date_str), SCREEN_W/2 - 40, 12, 18, COL_DIM)

    // Budget
    budget_str := fmt.tprintf("$%dM", a.budget)
    bw := rl.MeasureText(strings.clone_to_cstring(budget_str), 18)
    bcol := a.budget > 50 ? COL_GREEN : COL_RED
    rl.DrawText(strings.clone_to_cstring(budget_str), SCREEN_W - i32(bw) - 200, 13, 18, bcol)

    // Prestige
    pstr := fmt.tprintf("★ %d", a.prestige)
    rl.DrawText(strings.clone_to_cstring(pstr), SCREEN_W - 130, 13, 18, COL_GOLD)

    // Science
    sstr := fmt.tprintf("⚗ %d", a.science_pts)
    rl.DrawText(strings.clone_to_cstring(sstr), SCREEN_W - 65, 13, 18, COL_CYAN)
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: BOTTOM NAV
// ═══════════════════════════════════════════════════════════════════════════════

NavTab :: struct { label: cstring; screen: Screen; col: rl.Color }

nav_tabs := []NavTab{
    {"CONTROL", .Dashboard,   COL_ACCENT},
    {"ROCKETS",  .Rockets,    COL_ORANGE},
    {"CREW",     .Astronauts, COL_GREEN},
    {"MISSIONS", .Missions,   COL_GOLD},
    {"RESEARCH", .Research,   COL_PURPLE},
    {"STAR MAP", .StarMap,    COL_CYAN},
    {"BASE",     .Facilities, COL_DIM},
}

draw_bottom_nav :: proc(gs: ^GameState) {
    by := i32(SCREEN_H - 42)
    rl.DrawRectangle(0, by, SCREEN_W, 42, rl.Color{5, 8, 18, 245})
    rl.DrawLine(0, by, SCREEN_W, by, COL_BORDER)

    tw := i32(SCREEN_W) / i32(len(nav_tabs))
    for i in 0..<len(nav_tabs) {
        tab := nav_tabs[i]
        tx := i32(i) * tw
        active := gs.screen == tab.screen
        col := tab.col
        if active {
            rl.DrawRectangle(tx, by, tw, 42, rl.Color{col.r/6, col.g/6, col.b/6, 200})
            rl.DrawLine(tx, by, tx+tw, by, col)
        }
        lw := rl.MeasureText(tab.label, 14)
        lx := tx + (tw - lw) / 2
        tcol := active ? col : COL_DIM
        rl.DrawText(tab.label, lx, by+14, 14, tcol)

        mx := i32(rl.GetMouseX())
        my := i32(rl.GetMouseY())
        if mx >= tx && mx < tx+tw && my >= by && my < by+42 && rl.IsMouseButtonPressed(.LEFT) {
            gs.screen = tab.screen
            gs.tab = 0
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: MAIN MENU
// ═══════════════════════════════════════════════════════════════════════════════

draw_main_menu :: proc(gs: ^GameState) {
    // Title
    title := "COSMONAUT"
    tw := rl.MeasureText(title, 80)
    rl.DrawText(title, SCREEN_W/2 - tw/2, i32(SCREEN_H*0.20), 80, COL_ACCENT)

    sub := "SPACE AGENCY MANAGEMENT"
    sw2 := rl.MeasureText(sub, 20)
    rl.DrawText(sub, SCREEN_W/2 - sw2/2, i32(SCREEN_H*0.20)+90, 20, COL_DIM)

    // Divider
    rl.DrawLine(SCREEN_W/2-180, i32(SCREEN_H*0.40), SCREEN_W/2+180, i32(SCREEN_H*0.40), COL_BORDER)

    bw :: f32(260)
    bh :: f32(48)
    bx := f32(SCREEN_W)/2 - bw/2

    if button("NEW AGENCY",  bx, f32(SCREEN_H)*0.42,       bw, bh, COL_ACCENT) { gs.screen = .NewGame; gs.setup_step = 0; gs.input_len = 0 }
    if button("CONTINUE",    bx, f32(SCREEN_H)*0.42+62,    bw, bh, COL_GREEN)  { /* load */ }
    if button("EXIT",        bx, f32(SCREEN_H)*0.42+124,   bw, bh, COL_DIM)    { os.exit(0) }

    // Earth orbit decoration
    rl.DrawCircleLines(SCREEN_W/2, SCREEN_H/2+40, 280, rl.Color{40, 80, 160, 30})
    rl.DrawCircleLines(SCREEN_W/2, SCREEN_H/2+40, 200, rl.Color{30, 60, 120, 20})

    ver := "v0.1.0 — Alpha"
    vw := rl.MeasureText(ver, 14)
    rl.DrawText(ver, SCREEN_W - vw - 12, SCREEN_H - 22, 14, COL_DIM)
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: NEW GAME SETUP
// ═══════════════════════════════════════════════════════════════════════════════

draw_new_game :: proc(gs: ^GameState) {
    label("ESTABLISH YOUR SPACE AGENCY", 30, 30, 28, COL_TEXT)
    rl.DrawLine(30, 66, SCREEN_W-30, 66, COL_BORDER)

    label("Agency Name:", 80, 110, 20, COL_DIM)

    // Input box
    active := gs.input_active || gs.setup_step == 0
    box_col := active ? COL_ACCENT : COL_BORDER
    rl.DrawRectangle(80, 138, 500, 44, COL_PANEL2)
    rl.DrawRectangleLines(80, 138, 500, 44, box_col)

    display := string(gs.input_buf[:gs.input_len])
    cursor_str := active ? fmt.tprintf("%s|", display) : display
    rl.DrawText(strings.clone_to_cstring(cursor_str), 92, 150, 22, COL_TEXT)

    // Handle keyboard input
    if gs.setup_step == 0 {
        char := rl.GetCharPressed()
        for char != 0 {
            if gs.input_len < 40 && char >= 32 {
                gs.input_buf[gs.input_len] = u8(char)
                gs.input_len += 1
            }
            char = rl.GetCharPressed()
        }
        if rl.IsKeyPressed(.BACKSPACE) && gs.input_len > 0 { gs.input_len -= 1 }
        if rl.IsKeyPressed(.ENTER) && gs.input_len > 0 { gs.setup_step = 1 }
    }

    // Starting year
    label("Starting Era:", 80, 210, 20, COL_DIM)
    eras := []string{"Space Race (1957)", "Apollo Era (1960)", "Shuttle Era (1975)", "Modern Era (1995)"}
    era_years := []int{1957, 1960, 1975, 1995}
    era_budgets := []int{300, 500, 800, 1200}

    for i in 0..<len(eras) {
        ey := f32(240 + i*70)
        selected := gs.selected == i
        bcol := selected ? COL_ACCENT : COL_BORDER
        rl.DrawRectangle(80, i32(ey), 500, 58, selected ? rl.Color{20,40,80,200} : COL_PANEL)
        rl.DrawRectangleLines(80, i32(ey), 500, 58, bcol)
        rl.DrawText(strings.clone_to_cstring(eras[i]), 96, i32(ey)+12, 20, selected ? COL_ACCENT : COL_TEXT)
        budget_info := fmt.tprintf("Starting budget: $%dM/month income: $%dM", era_budgets[i], 20+i*15)
        rl.DrawText(strings.clone_to_cstring(budget_info), 96, i32(ey)+36, 14, COL_DIM)

        mx := i32(rl.GetMouseX())
        my := i32(rl.GetMouseY())
        if mx >= 80 && mx <= 580 && my >= i32(ey) && my <= i32(ey)+58 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    can_start := gs.input_len > 0
    if button("FOUND AGENCY →", f32(SCREEN_W)/2 - 140, f32(SCREEN_H)-80, 280, 50, COL_ACCENT, !can_start) {
        name := string(gs.input_buf[:gs.input_len])
        gs.agency = new_agency(strings.clone(name))
        gs.agency.year = era_years[gs.selected]
        gs.agency.budget = era_budgets[gs.selected]
        gs.agency.monthly_income = 20 + gs.selected*15
        gs.screen = .Dashboard
    }
    if button("← BACK", 30, f32(SCREEN_H)-80, 120, 44, COL_DIM) { gs.screen = .MainMenu }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

draw_dashboard :: proc(gs: ^GameState) {
    a := &gs.agency

    label("MISSION CONTROL", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    // Stats row
    stats := []struct{lbl:string; val:string; col:rl.Color}{
        {"BUDGET",     fmt.tprintf("$%dM", a.budget),       COL_GREEN},
        {"PRESTIGE",   fmt.tprintf("%d / 1000", a.prestige), COL_GOLD},
        {"SCIENCE",    fmt.tprintf("%d pts", a.science_pts), COL_CYAN},
        {"REPUTATION", fmt.tprintf("%d%%", a.reputation),   COL_ACCENT},
        {"INCOME",     fmt.tprintf("+$%dM/mo", a.monthly_income), COL_GREEN},
    }
    sw3 := f32(SCREEN_W-40) / f32(len(stats))
    for i in 0..<len(stats) {
        sx := f32(20) + f32(i)*sw3
        rl.DrawRectangle(i32(sx), 94, i32(sw3)-4, 60, COL_PANEL)
        rl.DrawRectangleLines(i32(sx), 94, i32(sw3)-4, 60, COL_BORDER)
        rl.DrawText(strings.clone_to_cstring(stats[i].lbl), i32(sx)+10, 104, 13, COL_DIM)
        rl.DrawText(strings.clone_to_cstring(stats[i].val), i32(sx)+10, 122, 20, stats[i].col)
    }

    // Active missions
    section_line("ACTIVE MISSIONS", 168)
    active_count := 0
    for i in 0..<a.mission_count {
        m := &a.missions[i]
        if m.status == .InFlight || m.status == .ReadyToLaunch {
            my := f32(182 + active_count * 52)
            if my > f32(SCREEN_H) - 220 { break }
            panel(20, my, f32(SCREEN_W)-40, 46, COL_PANEL)
            scol := mission_status_col(m.status)
            rl.DrawRectangle(20, i32(my), 4, 46, scol)
            rl.DrawText(strings.clone_to_cstring(m.name), 32, i32(my)+8, 18, COL_TEXT)
            rl.DrawText(strings.clone_to_cstring(mission_type_name(m.mission_type)), 32, i32(my)+30, 13, COL_DIM)
            // Progress bar
            progress := f32(m.elapsed) / f32(max(m.duration, 1))
            rl.DrawRectangle(300, i32(my)+16, 300, 14, COL_PANEL2)
            rl.DrawRectangle(300, i32(my)+16, i32(300*progress), 14, scol)
            rl.DrawRectangleLines(300, i32(my)+16, 300, 14, COL_BORDER)
            prog_txt := fmt.tprintf("Month %d / %d", m.elapsed, m.duration)
            rl.DrawText(strings.clone_to_cstring(prog_txt), 608, i32(my)+18, 14, COL_DIM)
            dest_txt := fmt.tprintf("→ %s", m.destination)
            rl.DrawText(strings.clone_to_cstring(dest_txt), SCREEN_W-200, i32(my)+18, 14, COL_ACCENT)
            active_count += 1
        }
    }
    if active_count == 0 {
        rl.DrawText("No active missions — plan one in MISSIONS", 40, 196, 16, COL_DIM)
    }

    // Events log
    ey := f32(182 + max(active_count, 1)*52 + 20)
    section_line("RECENT EVENTS", ey)
    for i in 0..<a.event_count {
        idx := a.event_count - 1 - i
        if idx < 0 { break }
        line_y := ey + 18 + f32(i)*22
        if line_y > f32(SCREEN_H)-100 { break }
        rl.DrawText(strings.clone_to_cstring(a.events[idx]), 28, i32(line_y), 14, COL_DIM)
    }
    if a.event_count == 0 {
        rl.DrawText("No events yet.", 28, i32(ey)+18, 14, COL_DIM)
    }

    // Advance time button
    if button("ADVANCE MONTH ▶", f32(SCREEN_W)-200, f32(SCREEN_H)-90, 185, 42, COL_ACCENT) {
        advance_month(gs)
    }
    label("(Space to advance)", SCREEN_W-195, SCREEN_H-44, 13, COL_DIM)
    if rl.IsKeyPressed(.SPACE) { advance_month(gs) }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: ROCKETS
// ═══════════════════════════════════════════════════════════════════════════════

draw_rockets :: proc(gs: ^GameState) {
    a := &gs.agency
    label("ROCKET FLEET", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    for i in 0..<a.rocket_count {
        r := &a.rockets[i]
        ry := f32(96 + i * 160)
        selected := gs.selected == i
        bg := selected ? rl.Color{15, 25, 50, 220} : COL_PANEL
        rl.DrawRectangle(20, i32(ry), SCREEN_W-40, 150, bg)
        rl.DrawRectangleLines(20, i32(ry), SCREEN_W-40, 150, selected ? COL_ACCENT : COL_BORDER)

        // Rocket name + ID
        rl.DrawText(strings.clone_to_cstring(r.name), 36, i32(ry)+12, 24, COL_ACCENT)
        id_str := fmt.tprintf("VEHICLE #%02d", r.id)
        rl.DrawText(strings.clone_to_cstring(id_str), 36, i32(ry)+40, 14, COL_DIM)

        // Stats
        stats_x := f32(300)
        stat_bar("RELIABILITY", r.reliability*99, 99, stats_x, ry+14, 340, COL_GREEN)
        stat_bar("PAYLOAD kg",  r.payload_kg, 50000, stats_x, ry+36, 340, COL_ACCENT)

        // Stage info
        for si in 0..<r.stage_count {
            s := r.stages[si]
            sx := f32(660 + si * 200)
            rl.DrawRectangle(i32(sx), i32(ry)+10, 185, 90, COL_PANEL2)
            rl.DrawRectangleLines(i32(sx), i32(ry)+10, 185, 90, COL_BORDER)
            stage_lbl := fmt.tprintf("Stage %d: %s", si+1, s.name)
            rl.DrawText(strings.clone_to_cstring(stage_lbl), i32(sx)+8, i32(ry)+20, 13, COL_DIM)
            thrust_str := fmt.tprintf("Thrust: %.0f kN", s.thrust_kn)
            rl.DrawText(strings.clone_to_cstring(thrust_str), i32(sx)+8, i32(ry)+38, 13, COL_TEXT)
            isp_str := fmt.tprintf("Isp: %.0f s", s.isp)
            rl.DrawText(strings.clone_to_cstring(isp_str), i32(sx)+8, i32(ry)+54, 13, COL_TEXT)
            if s.reusable { rl.DrawText("REUSABLE", i32(sx)+8, i32(ry)+72, 12, COL_GREEN) }
        }

        // Launch record
        rec_str := fmt.tprintf("Launches: %d  |  Successes: %d  |  Cost: $%.0fM", r.launches, r.successes, r.cost_million)
        rl.DrawText(strings.clone_to_cstring(rec_str), 36, i32(ry)+118, 14, COL_DIM)

        rel_pct := fmt.tprintf("%.0f%% reliability", r.reliability*100)
        rel_col := r.reliability > 0.85 ? COL_GREEN : (r.reliability > 0.70 ? COL_GOLD : COL_RED)
        rl.DrawText(strings.clone_to_cstring(rel_pct), 36, i32(ry)+136, 15, rel_col)

        mx := i32(rl.GetMouseX())
        my2 := i32(rl.GetMouseY())
        if mx >= 20 && mx <= SCREEN_W-20 && my2 >= i32(ry) && my2 <= i32(ry)+150 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    // New rocket button
    if button("+ DESIGN NEW ROCKET", 20, f32(SCREEN_H)-90, 220, 44, COL_ORANGE) {
        gs.screen = .RocketDesign
        gs.selected = -1
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: ROCKET DESIGN
// ═══════════════════════════════════════════════════════════════════════════════

draw_rocket_design :: proc(gs: ^GameState) {
    label("ROCKET DESIGN LAB", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    a := &gs.agency
    label("Select base configuration:", 30, 100, 18, COL_DIM)

    configs := []struct{name:string; payload:f32; cost:f32; rel:f32; stages:int; desc:string}{
        {"Light Scout",    500,   25, 0.88, 2, "Small payload, low cost. Good for probes."},
        {"Medium Lifter", 3500,   65, 0.82, 2, "Balanced workhorse. Most mission types."},
        {"Heavy Lift",   15000,  140, 0.76, 3, "Large payloads. Space stations, landers."},
        {"Super Heavy",  50000,  320, 0.68, 3, "Mars and beyond. Extremely expensive."},
        {"Crewed Rocket", 8000,  120, 0.85, 3, "Optimized for crew safety. Abort system."},
    }

    for i in 0..<len(configs) {
        c := configs[i]
        cy := f32(124 + i*84)
        selected := gs.selected == i
        rl.DrawRectangle(30, i32(cy), SCREEN_W-260, 76, selected ? rl.Color{15,30,60,220} : COL_PANEL)
        rl.DrawRectangleLines(30, i32(cy), SCREEN_W-260, 76, selected ? COL_ACCENT : COL_BORDER)
        rl.DrawText(strings.clone_to_cstring(c.name), 46, i32(cy)+10, 20, selected ? COL_ACCENT : COL_TEXT)
        rl.DrawText(strings.clone_to_cstring(c.desc), 46, i32(cy)+34, 14, COL_DIM)
        info := fmt.tprintf("Payload: %.0f kg  |  Cost: $%.0fM  |  Reliability: %.0f%%  |  Stages: %d",
                            c.payload, c.cost, c.rel*100, c.stages)
        rl.DrawText(strings.clone_to_cstring(info), 46, i32(cy)+54, 13, COL_DIM)

        mx := i32(rl.GetMouseX())
        my2 := i32(rl.GetMouseY())
        if mx >= 30 && mx <= SCREEN_W-230 && my2 >= i32(cy) && my2 <= i32(cy)+76 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    // Name input
    label("Rocket Name:", 30, f32(SCREEN_H)-170, 18, COL_DIM)
    rl.DrawRectangle(30, i32(SCREEN_H)-146, 400, 38, COL_PANEL2)
    rl.DrawRectangleLines(30, i32(SCREEN_H)-146, 400, 38, COL_ACCENT)
    disp := fmt.tprintf("%s|", string(gs.input_buf[:gs.input_len]))
    rl.DrawText(strings.clone_to_cstring(disp), 42, i32(SCREEN_H)-136, 20, COL_TEXT)

    char := rl.GetCharPressed()
    for char != 0 {
        if gs.input_len < 30 && char >= 32 {
            gs.input_buf[gs.input_len] = u8(char)
            gs.input_len += 1
        }
        char = rl.GetCharPressed()
    }
    if rl.IsKeyPressed(.BACKSPACE) && gs.input_len > 0 { gs.input_len -= 1 }

    can_build := gs.selected >= 0 && gs.input_len > 0 && a.rocket_count < 8
    if gs.selected >= 0 {
        c := configs[gs.selected]
        cost_str := fmt.tprintf("Build cost: $%.0fM", c.cost)
        ccol := a.budget >= int(c.cost) ? COL_GREEN : COL_RED
        rl.DrawText(strings.clone_to_cstring(cost_str), 450, i32(SCREEN_H)-136, 18, ccol)
        can_build = can_build && a.budget >= int(c.cost)
    }

    if button("BUILD ROCKET", 30, f32(SCREEN_H)-90, 200, 44, COL_ORANGE, !can_build) {
        c := configs[gs.selected]
        a.budget -= int(c.cost)
        r := RocketDesign{
            id   = a.rocket_count + 1,
            name = strings.clone(string(gs.input_buf[:gs.input_len])),
            stages = {
                RocketStage{"First Stage",  800, 290, 60, 6, false},
                RocketStage{"Upper Stage",  100, 320, 12, 1.5, false},
                RocketStage{"Third Stage",   20, 340,  3, 0.4, false},
            },
            stage_count  = c.stages,
            payload_kg   = c.payload,
            cost_million = c.cost,
            reliability  = c.rel,
            built        = true,
        }
        a.rockets[a.rocket_count] = r
        a.rocket_count += 1
        gs.screen = .Rockets
        gs.input_len = 0
        gs.selected = -1
        push_notification(gs, fmt.tprintf("Rocket built: %s", r.name))
    }
    if button("← CANCEL", 250, f32(SCREEN_H)-90, 130, 44, COL_DIM) {
        gs.screen = .Rockets
        gs.input_len = 0
        gs.selected = -1
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: ASTRONAUTS
// ═══════════════════════════════════════════════════════════════════════════════

draw_astronauts :: proc(gs: ^GameState) {
    a := &gs.agency
    label("ASTRONAUT CORPS", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    // Summary
    available := 0
    for i in 0..<a.astronaut_count {
        if a.astronauts[i].status == .Available { available += 1 }
    }
    summary := fmt.tprintf("Astronauts: %d  |  Available: %d", a.astronaut_count, available)
    rl.DrawText(strings.clone_to_cstring(summary), 20, 96, 16, COL_DIM)

    for i in 0..<a.astronaut_count {
        ast := &a.astronauts[i]
        ay := f32(116 + i*110)
        if ay > f32(SCREEN_H)-100 { break }

        selected := gs.selected == i
        bg := selected ? rl.Color{10, 20, 40, 220} : COL_PANEL
        rl.DrawRectangle(20, i32(ay), SCREEN_W-40, 100, bg)
        rl.DrawRectangleLines(20, i32(ay), SCREEN_W-40, 100, selected ? COL_GREEN : COL_BORDER)

        // Status indicator strip
        scol := map[AstronautStatus]rl.Color{
            .Available = COL_GREEN,
            .Training  = COL_GOLD,
            .InFlight  = COL_ACCENT,
            .Retired   = COL_DIM,
            .Lost      = COL_RED,
        }
        rl.DrawRectangle(20, i32(ay), 4, 100, scol[ast.status])

        // Name + info
        rl.DrawText(strings.clone_to_cstring(ast.name), 34, i32(ay)+10, 22, COL_TEXT)
        info_str := fmt.tprintf("%s  •  Age %d  •  %d missions", ast.nationality, ast.age, ast.experience)
        rl.DrawText(strings.clone_to_cstring(info_str), 34, i32(ay)+36, 14, COL_DIM)

        status_str: string
        switch ast.status {
            case .Available: status_str = "AVAILABLE"
            case .Training:  status_str = "IN TRAINING"
            case .InFlight:  status_str = "IN FLIGHT"
            case .Retired:   status_str = "RETIRED"
            case .Lost:      status_str = "LOST IN SPACE"
        }
        rl.DrawText(strings.clone_to_cstring(status_str), 34, i32(ay)+56, 14, scol[ast.status])

        // Stats bars (compact)
        hw := f32(SCREEN_W-40) / 4.5
        stat_bar("PILOT",   f32(ast.piloting),   99, 300, ay+14, hw, COL_ACCENT)
        stat_bar("SCIENCE", f32(ast.science),     99, 300, ay+34, hw, COL_CYAN)
        stat_bar("ENG",     f32(ast.engineering), 99, 300, ay+54, hw, COL_ORANGE)
        stat_bar("ENDUR.",  f32(ast.endurance),   99, 300, ay+74, hw, COL_GREEN)

        // OVR
        ovr := (ast.piloting + ast.science + ast.engineering + ast.endurance) / 4
        ovr_str := fmt.tprintf("OVR %d", ovr)
        rl.DrawText(strings.clone_to_cstring(ovr_str), SCREEN_W-120, i32(ay)+30, 22, COL_GOLD)

        morale_str := fmt.tprintf("Morale %d%%", ast.morale)
        mcol := ast.morale > 60 ? COL_GREEN : (ast.morale > 30 ? COL_GOLD : COL_RED)
        rl.DrawText(strings.clone_to_cstring(morale_str), SCREEN_W-120, i32(ay)+60, 14, mcol)

        mx := i32(rl.GetMouseX())
        my2 := i32(rl.GetMouseY())
        if mx >= 20 && mx <= SCREEN_W-20 && my2 >= i32(ay) && my2 <= i32(ay)+100 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    if button("+ RECRUIT ASTRONAUT ($30M)", 20, f32(SCREEN_H)-90, 300, 44, COL_GREEN,
        a.budget < 30 || a.astronaut_count >= 16) {
        if a.budget >= 30 {
            a.budget -= 30
            recruit_names := []string{"Elena Sorokina","Kwame Mensah","Yuki Tanaka","Lars Eriksson","Priya Sharma"}
            nats := []string{"RUS","GHA","JPN","SWE","IND"}
            idx := a.astronaut_count % len(recruit_names)
            ast := Astronaut{
                id          = a.astronaut_count + 1,
                name        = recruit_names[idx],
                nationality = nats[idx],
                age         = 28 + int(rand.float32()*10),
                piloting    = 55 + int(rand.float32()*30),
                science     = 55 + int(rand.float32()*30),
                engineering = 55 + int(rand.float32()*30),
                endurance   = 55 + int(rand.float32()*30),
                experience  = 0, status = .Available, morale = 80,
            }
            a.astronauts[a.astronaut_count] = ast
            a.astronaut_count += 1
            push_notification(gs, fmt.tprintf("Recruited: %s", ast.name))
        }
        }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: MISSIONS
// ═══════════════════════════════════════════════════════════════════════════════

draw_missions :: proc(gs: ^GameState) {
    a := &gs.agency
    label("MISSION MANIFEST", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    // Filter tabs
    tabs := []string{"ALL", "ACTIVE", "COMPLETED", "FAILED"}
    for i in 0..<len(tabs) {
        tx := f32(20 + i*110)
        active := gs.tab == i
        tcol := active ? COL_GOLD : COL_DIM
        rl.DrawRectangle(i32(tx), 94, 104, 24, active ? rl.Color{40,30,5,200} : COL_PANEL)
        rl.DrawRectangleLines(i32(tx), 94, 104, 24, active ? COL_GOLD : COL_BORDER)
        tw := rl.MeasureText(strings.clone_to_cstring(tabs[i]), 14)
        rl.DrawText(strings.clone_to_cstring(tabs[i]), i32(tx) + (104-tw)/2, 101, 14, tcol)
        mx := i32(rl.GetMouseX())
        my2 := i32(rl.GetMouseY())
        if mx >= i32(tx) && mx <= i32(tx)+104 && my2 >= 94 && my2 <= 118 && rl.IsMouseButtonPressed(.LEFT) {
            gs.tab = i
        }
    }

    row := 0
    for i in 0..<a.mission_count {
        m := &a.missions[i]
        // Filter
        show := false
        switch gs.tab {
            case 0: show = true
            case 1: show = m.status == .InFlight || m.status == .ReadyToLaunch || m.status == .Planning || m.status == .Building
            case 2: show = m.status == .Success
            case 3: show = m.status == .Failure || m.status == .Aborted
        }
        if !show { continue }

        my2 := f32(126 + row * 68)
        if my2 > f32(SCREEN_H) - 100 { break }

        selected := gs.selected == i
        rl.DrawRectangle(20, i32(my2), SCREEN_W-40, 62, selected ? rl.Color{10,18,36,220} : COL_PANEL)
        rl.DrawRectangleLines(20, i32(my2), SCREEN_W-40, 62, selected ? mission_status_col(m.status) : COL_BORDER)

        scol := mission_status_col(m.status)
        rl.DrawRectangle(20, i32(my2), 4, 62, scol)

        // Name + type
        rl.DrawText(strings.clone_to_cstring(m.name), 32, i32(my2)+8, 20, COL_TEXT)
        type_str := mission_type_name(m.mission_type)
        rl.DrawText(strings.clone_to_cstring(type_str), 32, i32(my2)+32, 14, COL_DIM)

        // Status
        status_strs := map[MissionStatus]string{
            .Planning      = "PLANNING",
            .Building      = "BUILDING",
            .ReadyToLaunch = "READY",
            .InFlight      = "IN FLIGHT",
            .Success       = "SUCCESS",
            .Failure       = "FAILURE",
            .Aborted       = "ABORTED",
        }
        rl.DrawText(strings.clone_to_cstring(status_strs[m.status]), 280, i32(my2)+20, 16, scol)

        // Progress
        if m.status == .InFlight {
            progress := f32(m.elapsed) / f32(max(m.duration, 1))
            rl.DrawRectangle(420, i32(my2)+20, 240, 14, COL_PANEL2)
            rl.DrawRectangle(420, i32(my2)+20, i32(240*progress), 14, COL_ACCENT)
            rl.DrawRectangleLines(420, i32(my2)+20, 240, 14, COL_BORDER)
            prog_str := fmt.tprintf("Mo %d/%d", m.elapsed, m.duration)
            rl.DrawText(strings.clone_to_cstring(prog_str), 668, i32(my2)+22, 13, COL_DIM)
        }

        // Prestige / Science
        pts_str := fmt.tprintf("★%d  ⚗%d  $%dM", m.prestige, m.science, m.cost)
        rl.DrawText(strings.clone_to_cstring(pts_str), SCREEN_W-200, i32(my2)+20, 14, COL_GOLD)

        // Destination
        rl.DrawText(strings.clone_to_cstring(m.destination), SCREEN_W-200, i32(my2)+38, 13, COL_ACCENT)

        mx3 := i32(rl.GetMouseX())
        my3 := i32(rl.GetMouseY())
        if mx3 >= 20 && mx3 <= SCREEN_W-20 && my3 >= i32(my2) && my3 <= i32(my2)+62 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
            gs.screen = .MissionLog
        }
        row += 1
    }

    if button("+ PLAN MISSION", 20, f32(SCREEN_H)-90, 200, 44, COL_GOLD) {
        gs.screen = .MissionPlan
        gs.selected  = -1
        gs.selected2 = -1
        gs.input_len = 0
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: MISSION PLAN
// ═══════════════════════════════════════════════════════════════════════════════

draw_mission_plan :: proc(gs: ^GameState) {
    a := &gs.agency
    label("PLAN NEW MISSION", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    // Mission type grid
    section_line("MISSION TYPE", 95)
    mission_types := []MissionType{
        .OrbitalTest, .SatelliteNetwork, .CrewedOrbit,
        .LunarFlyby, .LunarOrbit, .LunarLanding,
        .MarsProbe, .MarsOrbiter, .MarsSurface,
        .AsteroidProbe, .SpaceStation, .DeepSpaceProbe,
    }
    cols := 4
    mt_w := f32(SCREEN_W-40) / f32(cols)
    mt_h := f32(56)
    for i in 0..<len(mission_types) {
        t := mission_types[i]
        tx := f32(20) + f32(i%cols)*mt_w
        ty := f32(108) + f32(i/cols)*mt_h
        selected := gs.selected == i

        tcol := COL_ACCENT
        switch t {
            case .LunarFlyby, .LunarOrbit, .LunarLanding: tcol = COL_GOLD
            case .MarsProbe, .MarsOrbiter, .MarsSurface:   tcol = COL_RED
            case .CrewedOrbit, .SpaceStation:               tcol = COL_GREEN
            case .DeepSpaceProbe, .AsteroidProbe:           tcol = COL_PURPLE
        }
        bg := selected ? rl.Color{tcol.r/5, tcol.g/5, tcol.b/5, 220} : COL_PANEL
        rl.DrawRectangle(i32(tx), i32(ty), i32(mt_w)-4, i32(mt_h)-4, bg)
        rl.DrawRectangleLines(i32(tx), i32(ty), i32(mt_w)-4, i32(mt_h)-4, selected ? tcol : COL_BORDER)
        name := mission_type_name(t)
        nw := rl.MeasureText(strings.clone_to_cstring(name), 15)
        rl.DrawText(strings.clone_to_cstring(name), i32(tx) + (i32(mt_w)-4-nw)/2, i32(ty)+10, 15, selected ? tcol : COL_TEXT)
        prest_str := fmt.tprintf("★%d", mission_prestige(t))
        rl.DrawText(strings.clone_to_cstring(prest_str), i32(tx)+6, i32(ty)+30, 13, COL_GOLD)
        dur_str := fmt.tprintf("%dmo", mission_duration(t))
        rl.DrawText(strings.clone_to_cstring(dur_str), i32(tx)+i32(mt_w)-40, i32(ty)+30, 13, COL_DIM)

        mx := i32(rl.GetMouseX())
        my2 := i32(rl.GetMouseY())
        if mx >= i32(tx) && mx <= i32(tx)+i32(mt_w)-4 && my2 >= i32(ty) && my2 <= i32(ty)+i32(mt_h)-4 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    bottom_y := f32(108) + f32(3)*mt_h + 12

    // Rocket selector
    section_line("ROCKET", bottom_y)
    rocket_y := bottom_y + 14
    for i in 0..<a.rocket_count {
        r := &a.rockets[i]
        rx := f32(20 + i*220)
        if rx > f32(SCREEN_W)-220 { break }
        selected := gs.selected2 == i
        rl.DrawRectangle(i32(rx), i32(rocket_y), 214, 52, selected ? rl.Color{15,30,60,220} : COL_PANEL)
        rl.DrawRectangleLines(i32(rx), i32(rocket_y), 214, 52, selected ? COL_ACCENT : COL_BORDER)
        rl.DrawText(strings.clone_to_cstring(r.name), i32(rx)+8, i32(rocket_y)+8, 16, selected ? COL_ACCENT : COL_TEXT)
        rel_str := fmt.tprintf("%.0f%% rel  %.0fkg PL", r.reliability*100, r.payload_kg)
        rl.DrawText(strings.clone_to_cstring(rel_str), i32(rx)+8, i32(rocket_y)+30, 13, COL_DIM)
        mx := i32(rl.GetMouseX())
        my2 := i32(rl.GetMouseY())
        if mx >= i32(rx) && mx <= i32(rx)+214 && my2 >= i32(rocket_y) && my2 <= i32(rocket_y)+52 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected2 = i
        }
    }

    // Mission name input
    name_y := rocket_y + 62
    section_line("MISSION NAME", name_y)
    rl.DrawRectangle(20, i32(name_y)+14, 400, 36, COL_PANEL2)
    rl.DrawRectangleLines(20, i32(name_y)+14, 400, 36, COL_ACCENT)
    disp := fmt.tprintf("%s|", string(gs.input_buf[:gs.input_len]))
    rl.DrawText(strings.clone_to_cstring(disp), 30, i32(name_y)+22, 18, COL_TEXT)
    char := rl.GetCharPressed()
    for char != 0 {
        if gs.input_len < 32 && char >= 32 { gs.input_buf[gs.input_len] = u8(char); gs.input_len += 1 }
        char = rl.GetCharPressed()
    }
    if rl.IsKeyPressed(.BACKSPACE) && gs.input_len > 0 { gs.input_len -= 1 }

    // Cost / chance preview
    if gs.selected >= 0 && gs.selected2 >= 0 {
        t := mission_types[gs.selected]
        r := &a.rockets[gs.selected2]
        cost := mission_cost(t, r)
        chance := mission_base_chance(t, r, a)
        prev_str := fmt.tprintf("Cost: $%dM  |  Success chance: %.0f%%  |  Duration: %d months  |  Prestige: ★%d",
                                cost, chance*100, mission_duration(t), mission_prestige(t))
        ccol := a.budget >= cost ? COL_GREEN : COL_RED
        rl.DrawText(strings.clone_to_cstring(prev_str), 430, i32(name_y)+22, 14, ccol)
    }

    can_plan := gs.selected >= 0 && gs.selected2 >= 0 && gs.input_len > 0
    if gs.selected >= 0 && gs.selected2 >= 0 {
        t := mission_types[gs.selected]
        r := &a.rockets[gs.selected2]
        can_plan = can_plan && a.budget >= mission_cost(t, r) && a.mission_count < 32
    }

    if button("APPROVE MISSION ✓", 20, f32(SCREEN_H)-90, 240, 44, COL_GOLD, !can_plan) {
        t := mission_types[gs.selected]
        r := &a.rockets[gs.selected2]
        cost := mission_cost(t, r)
        a.budget -= cost
        r.launches += 1

        m := Mission{
            id           = a.mission_count + 1,
            name         = strings.clone(string(gs.input_buf[:gs.input_len])),
            mission_type = t,
            status       = .InFlight,
            rocket_id    = r.id,
            launch_month = a.month,
            duration     = mission_duration(t),
            elapsed      = 0,
            success_chance = mission_base_chance(t, r, a),
            prestige     = mission_prestige(t),
            science      = mission_prestige(t) / 2,
            cost         = cost,
            destination  = mission_destination(t),
        }
        append_mission_log(&m, fmt.tprintf("Mission approved. Launch: %s %d", month_name(a.month), a.year))
        append_mission_log(&m, fmt.tprintf("Rocket: %s  |  Success probability: %.0f%%", r.name, m.success_chance*100))
        a.missions[a.mission_count] = m
        a.mission_count += 1
        a.prestige += 2
        push_notification(gs, fmt.tprintf("Mission launched: %s", m.name))
        gs.screen = .Missions
        gs.selected = -1
        gs.selected2 = -1
        gs.input_len = 0
    }

    if button("← CANCEL", 280, f32(SCREEN_H)-90, 130, 44, COL_DIM) {
        gs.screen = .Missions
        gs.selected = -1
        gs.selected2 = -1
        gs.input_len = 0
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: MISSION LOG
// ═══════════════════════════════════════════════════════════════════════════════

draw_mission_log :: proc(gs: ^GameState) {
    a := &gs.agency
    if gs.selected < 0 || gs.selected >= a.mission_count {
        gs.screen = .Missions
        return
    }
    m := &a.missions[gs.selected]

    label("MISSION LOG", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    // Mission header
    rl.DrawText(strings.clone_to_cstring(m.name), 20, 96, 26, mission_status_col(m.status))
    type_dest := fmt.tprintf("%s  →  %s", mission_type_name(m.mission_type), m.destination)
    rl.DrawText(strings.clone_to_cstring(type_dest), 20, 126, 16, COL_DIM)

    // Stats
    stats := []struct{l:string; v:string; c:rl.Color}{
        {"Status",   map[MissionStatus]string{.Planning="PLANNING",.Building="BUILDING",.ReadyToLaunch="READY",.InFlight="IN FLIGHT",.Success="SUCCESS",.Failure="FAILURE",.Aborted="ABORTED"}[m.status], mission_status_col(m.status)},
        {"Elapsed",  fmt.tprintf("%d / %d months", m.elapsed, m.duration), COL_TEXT},
        {"Chance",   fmt.tprintf("%.0f%%", m.success_chance*100), COL_ACCENT},
        {"Prestige", fmt.tprintf("★ %d", m.prestige), COL_GOLD},
        {"Science",  fmt.tprintf("⚗ %d", m.science), COL_CYAN},
        {"Cost",     fmt.tprintf("$%dM", m.cost), COL_RED},
    }
    for i in 0..<len(stats) {
        sx := f32(20 + i*(SCREEN_W-40)/len(stats))
        rl.DrawRectangle(i32(sx), 150, i32(f32(SCREEN_W-40)/f32(len(stats)))-4, 54, COL_PANEL)
        rl.DrawRectangleLines(i32(sx), 150, i32(f32(SCREEN_W-40)/f32(len(stats)))-4, 54, COL_BORDER)
        rl.DrawText(strings.clone_to_cstring(stats[i].l), i32(sx)+8, 160, 13, COL_DIM)
        rl.DrawText(strings.clone_to_cstring(stats[i].v), i32(sx)+8, 178, 18, stats[i].c)
    }

    // Progress bar
    if m.status == .InFlight {
        progress := f32(m.elapsed) / f32(max(m.duration,1))
        rl.DrawRectangle(20, 212, SCREEN_W-40, 18, COL_PANEL2)
        rl.DrawRectangle(20, 212, i32(f32(SCREEN_W-40)*progress), 18, COL_ACCENT)
        rl.DrawRectangleLines(20, 212, SCREEN_W-40, 18, COL_BORDER)
    }

    // Log entries
    section_line("FLIGHT LOG", 240)
    for i in 0..<m.log_count {
        idx := m.log_count - 1 - i
        ly := f32(256 + i*22)
        if ly > f32(SCREEN_H)-100 { break }
        lcol := COL_DIM
        if strings.contains(m.log[idx], "CRITICAL") || strings.contains(m.log[idx], "lost") { lcol = COL_RED }
        if strings.contains(m.log[idx], "SUCCESS") || strings.contains(m.log[idx], "returned") { lcol = COL_GREEN }
        rl.DrawText(strings.clone_to_cstring(m.log[idx]), 28, i32(ly), 14, lcol)
    }

    if button("← BACK TO MISSIONS", 20, f32(SCREEN_H)-90, 230, 44, COL_DIM) {
        gs.screen = .Missions
    }

    // Abort button
    if m.status == .InFlight || m.status == .ReadyToLaunch {
        if button("⚠ ABORT MISSION", f32(SCREEN_W)-220, f32(SCREEN_H)-90, 200, 44, COL_RED) {
            m.status = .Aborted
            for j in 0..<m.crew_count {
                aid := m.crew[j]
                for k in 0..<a.astronaut_count {
                    if a.astronauts[k].id == aid { a.astronauts[k].status = .Available }
                }
            }
            push_notification(gs, fmt.tprintf("Mission aborted: %s", m.name))
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: RESEARCH
// ═══════════════════════════════════════════════════════════════════════════════

draw_research :: proc(gs: ^GameState) {
    a := &gs.agency
    label("RESEARCH & DEVELOPMENT", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    sci_str := fmt.tprintf("Science Points: %d", a.science_pts)
    rl.DrawText(strings.clone_to_cstring(sci_str), 20, 96, 18, COL_CYAN)

    for i in 0..<a.research_count {
        r := &a.research[i]
        ry := f32(118 + i*86)
        if ry > f32(SCREEN_H)-100 { break }

        in_progress := !r.completed && r.progress > 0
        bg := r.completed ? rl.Color{5,20,10,200} : (in_progress ? rl.Color{15,15,30,200} : COL_PANEL)
        rl.DrawRectangle(20, i32(ry), SCREEN_W-40, 78, bg)
        rl.DrawRectangleLines(20, i32(ry), SCREEN_W-40, 78, r.completed ? COL_GREEN : (in_progress ? COL_ACCENT : COL_BORDER))

        acol := research_area_col(r.area)
        rl.DrawRectangle(20, i32(ry), 6, 78, acol)

        // Area badge
        area_str := research_area_name(r.area)
        rl.DrawText(strings.clone_to_cstring(area_str), 36, i32(ry)+8, 13, acol)

        // Name + desc
        rl.DrawText(strings.clone_to_cstring(r.name), 36, i32(ry)+26, 20, r.completed ? COL_GREEN : COL_TEXT)
        rl.DrawText(strings.clone_to_cstring(r.description), 36, i32(ry)+50, 14, COL_DIM)

        // Progress bar
        if in_progress {
            prog := f32(r.progress) / f32(r.duration)
            rl.DrawRectangle(500, i32(ry)+20, 300, 14, COL_PANEL2)
            rl.DrawRectangle(500, i32(ry)+20, i32(300*prog), 14, acol)
            rl.DrawRectangleLines(500, i32(ry)+20, 300, 14, COL_BORDER)
            prog_str := fmt.tprintf("Month %d / %d", r.progress, r.duration)
            rl.DrawText(strings.clone_to_cstring(prog_str), 808, i32(ry)+22, 13, COL_DIM)
        }

        // Unlock text
        unlock_str := fmt.tprintf("Unlocks: %s", r.unlock)
        rl.DrawText(strings.clone_to_cstring(unlock_str), SCREEN_W-280, i32(ry)+28, 14, acol)

        cost_str := fmt.tprintf("$%dM  |  %d months", r.cost, r.duration)
        rl.DrawText(strings.clone_to_cstring(cost_str), SCREEN_W-280, i32(ry)+52, 13, COL_DIM)

        // Button
        if r.completed {
            rl.DrawText("✓ COMPLETE", SCREEN_W-110, i32(ry)+30, 16, COL_GREEN)
        } else if in_progress {
            rl.DrawText("IN PROGRESS", SCREEN_W-115, i32(ry)+30, 15, COL_ACCENT)
        } else {
            can_start := a.budget >= r.cost
            if button("FUND", f32(SCREEN_W)-110, ry+18, 80, 34, acol, !can_start) {
                if can_start {
                    a.budget -= r.cost
                    r.progress = 1
                    push_notification(gs, fmt.tprintf("Research started: %s", r.name))
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: STAR MAP
// ═══════════════════════════════════════════════════════════════════════════════

draw_star_map :: proc(gs: ^GameState) {
    label("SOLAR SYSTEM MAP", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    // Map viewport
    vx := f32(20)
    vy := f32(96)
    vw := f32(SCREEN_W) * 0.62
    vh := f32(SCREEN_H) - 200

    rl.DrawRectangle(i32(vx), i32(vy), i32(vw), i32(vh), rl.Color{4, 6, 14, 255})
    rl.DrawRectangleLines(i32(vx), i32(vy), i32(vw), i32(vh), COL_BORDER)

    // Draw orbits (concentric ellipses)
    orbit_radii := []f32{0.06, 0.10, 0.16, 0.17, 0.28, 0.42, 0.58, 0.72, 0.84, 0.92, 0.96, 0.31}
    for i in 0..<gs.body_count {
        if i >= len(orbit_radii) { break }
        or := orbit_radii[i]
        cx := vx + vw * 0.12  // Sun near left
        cy := vy + vh * 0.50
        ell_w := vw * or * 1.8
        ell_h := vh * or * 0.7
        rl.DrawEllipseLines(i32(cx), i32(cy), ell_w/2, ell_h/2, rl.Color{30, 40, 60, 80})
    }

    // Sun
    sun_x := vx + vw * 0.12
    sun_y := vy + vh * 0.50
    rl.DrawCircle(i32(sun_x), i32(sun_y), 18, rl.Color{255, 200, 50, 255})
    rl.DrawCircle(i32(sun_x), i32(sun_y), 26, rl.Color{255, 150, 30, 60})
    rl.DrawText("SOL", i32(sun_x)-14, i32(sun_y)+22, 13, COL_GOLD)

    // Bodies
    orbit_angles := []f32{0.3, 1.1, 2.0, 2.4, 0.8, 0.9, 1.6, 2.2, 0.5, 1.3, 0.7, 2.8}
    for i in 0..<gs.body_count {
        b := &gs.bodies[i]
        or := orbit_radii[i] if i < len(orbit_radii) else 0.5
        angle := orbit_angles[i] if i < len(orbit_angles) else f32(i)
        cx := vx + vw * 0.12
        cy := vy + vh * 0.50
        bx := cx + math.cos_f32(angle) * (vw * or * 0.9)
        by := cy + math.sin_f32(angle) * (vh * or * 0.35)

        // Size
        size := f32(6)
        if b.name == "Jupiter" { size = 14 }
        else if b.name == "Saturn" { size = 12 }
        else if b.name == "Earth" || b.name == "Venus" { size = 8 }
        else if b.name == "Moon" || b.name == "Phobos" || b.name == "Ceres" { size = 4 }

        col := b.color
        if b.landed { col = COL_GREEN }
        else if b.orbited { col = COL_CYAN }
        else if b.probed { col = COL_GOLD }

        rl.DrawCircle(i32(bx), i32(by), size, col)

        // Glow for explored bodies
        if b.explored { rl.DrawCircle(i32(bx), i32(by), size+6, rl.Color{col.r, col.g, col.b, 50}) }

        // Name (only if selected or close to mouse)
        mx := i32(rl.GetMouseX())
        my2 := i32(rl.GetMouseY())
        dist := math.sqrt_f32((f32(mx)-bx)*(f32(mx)-bx) + (f32(my2)-by)*(f32(my2)-by))
        if dist < 20 || gs.selected == i {
            rl.DrawText(strings.clone_to_cstring(b.name), i32(bx)+i32(size)+3, i32(by)-7, 13,
                        gs.selected == i ? COL_WHITE : COL_DIM)
            if rl.IsMouseButtonPressed(.LEFT) && dist < 20 { gs.selected = i }
        }
    }

    // Legend
    legend_items := []struct{col:rl.Color; lbl:string}{
        {COL_GREEN, "Landed"},
        {COL_CYAN,  "Orbited"},
        {COL_GOLD,  "Probed"},
        {COL_DIM,   "Unexplored"},
    }
    for i in 0..<len(legend_items) {
        lx := vx + 10
        ly := vy + vh - 22 - f32(i)*18
        rl.DrawCircle(i32(lx)+5, i32(ly)+5, 5, legend_items[i].col)
        rl.DrawText(strings.clone_to_cstring(legend_items[i].lbl), i32(lx)+14, i32(ly)-2, 13, COL_DIM)
    }

    // Info panel for selected body
    if gs.selected >= 0 && gs.selected < gs.body_count {
        b := &gs.bodies[gs.selected]
        px := vx + vw + 8
        pw := f32(SCREEN_W) - px - 8
        panel(px, vy, pw, vh, COL_PANEL)

        rl.DrawText(strings.clone_to_cstring(b.name), i32(px)+12, i32(vy)+14, 26, b.color)

        info_rows := []struct{l:string; v:string}{
            {"Distance", fmt.tprintf("%.2f AU", b.distance_au)},
            {"Diameter", fmt.tprintf("%.0f km", b.diameter_km)},
            {"Gravity",  fmt.tprintf("%.2f g", b.gravity_g)},
        }
        for i in 0..<len(info_rows) {
            ry := f32(i32(vy)+50 + i*28)
            rl.DrawText(strings.clone_to_cstring(info_rows[i].l), i32(px)+12, i32(ry), 14, COL_DIM)
            rl.DrawText(strings.clone_to_cstring(info_rows[i].v), i32(px)+100, i32(ry), 14, COL_TEXT)
        }

        // Exploration status
        section_line("EXPLORATION", f32(vy)+142)
        statuses := []struct{l:string; done:bool}{
            {"Probed",   b.probed},
            {"Orbited",  b.orbited},
            {"Landed",   b.landed},
            {"Explored", b.explored},
        }
        for i in 0..<len(statuses) {
            sy := f32(i32(vy)+152 + i*26)
            icon := statuses[i].done ? "✓" : "○"
            icol := statuses[i].done ? COL_GREEN : COL_DIM
            rl.DrawText(strings.clone_to_cstring(icon), i32(px)+12, i32(sy), 18, icol)
            rl.DrawText(strings.clone_to_cstring(statuses[i].l), i32(px)+30, i32(sy)+2, 15, statuses[i].done ? COL_GREEN : COL_DIM)
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: FACILITIES
// ═══════════════════════════════════════════════════════════════════════════════

draw_facilities :: proc(gs: ^GameState) {
    a := &gs.agency
    label("SPACE CENTRE FACILITIES", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    type Facility :: struct { name: string; level: ^int; max: int; desc: string; upgrade_cost: int; col: rl.Color }
    facs := []Facility{
        {"Launch Pads",       &a.facilities.launch_pads,    4, "Simultaneous launch capacity",     150, COL_ORANGE},
        {"VAB",               &a.facilities.vab_level,      5, "Vehicle assembly — larger rockets", 200, COL_ACCENT},
        {"Tracking Network",  &a.facilities.tracking_level, 5, "+2% mission success per level",     120, COL_CYAN},
        {"Research Lab",      &a.facilities.lab_level,      5, "Accelerate R&D projects",           180, COL_PURPLE},
        {"Astronaut Complex", &a.facilities.hab_level,      5, "Astronaut training & morale",        100, COL_GREEN},
    }

    for i in 0..<len(facs) {
        f := facs[i]
        fy := f32(96 + i*106)
        panel(20, fy, f32(SCREEN_W)-40, 98, COL_PANEL)

        rl.DrawText(strings.clone_to_cstring(f.name), 36, i32(fy)+10, 22, COL_TEXT)
        level_str := fmt.tprintf("Level %d / %d", f.level^, f.max)
        rl.DrawText(strings.clone_to_cstring(level_str), 36, i32(fy)+36, 16, f.col)
        rl.DrawText(strings.clone_to_cstring(f.desc), 36, i32(fy)+58, 14, COL_DIM)

        // Level indicators
        for l in 0..<f.max {
            lx := f32(300 + l*36)
            filled := l < f.level^
            rl.DrawRectangle(i32(lx), i32(fy)+30, 30, 20, filled ? rl.Color{f.col.r/3, f.col.g/3, f.col.b/3, 200} : COL_PANEL2)
            rl.DrawRectangleLines(i32(lx), i32(fy)+30, 30, 20, filled ? f.col : COL_BORDER)
            if filled { rl.DrawRectangle(i32(lx)+4, i32(fy)+34, 22, 12, f.col) }
        }

        // Upgrade button
        can_upgrade := f.level^ < f.max && a.budget >= f.upgrade_cost
        cost_str := f.level^ >= f.max ? "MAX" : fmt.tprintf("$%dM", f.upgrade_cost)
        if button(strings.clone_to_cstring(fmt.tprintf("UPGRADE  %s", cost_str)),
            f32(SCREEN_W)-220, fy+28, 200, 40, f.col, !can_upgrade) {
            if can_upgrade {
                a.budget -= f.upgrade_cost
                f.level^ += 1
                a.monthly_income += 3
                push_notification(gs, fmt.tprintf("%s upgraded to Level %d", f.name, f.level^))
            }
            }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DRAW: NOTIFICATION
// ═══════════════════════════════════════════════════════════════════════════════

draw_notification :: proc(gs: ^GameState) {
    if gs.notif_timer <= 0 { return }
    alpha := u8(math.clamp(gs.notif_timer / 0.5, 0, 1) * 220)
    text := string(gs.notification[:gs.notif_len])
    tw := rl.MeasureText(strings.clone_to_cstring(text), 16)
    nx := SCREEN_W/2 - tw/2 - 16
    rl.DrawRectangle(i32(nx), SCREEN_H - 72, tw+32, 28, rl.Color{10, 20, 40, alpha})
    rl.DrawRectangleLines(i32(nx), SCREEN_H - 72, tw+32, 28, rl.Color{COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b, alpha})
    rl.DrawText(strings.clone_to_cstring(text), i32(nx)+16, SCREEN_H - 64, 16, rl.Color{COL_TEXT.r, COL_TEXT.g, COL_TEXT.b, alpha})
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════════

main :: proc() {
    rl.InitWindow(SCREEN_W, SCREEN_H, "Cosmonaut — Space Agency Management")
    rl.SetTargetFPS(TARGET_FPS)
    defer rl.CloseWindow()

    gs := GameState{screen = .MainMenu, selected = -1, selected2 = -1}
    default_bodies(&gs)
    init_stars()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        gs.star_anim += dt * 0.8
        if gs.notif_timer > 0 { gs.notif_timer -= dt }

        rl.BeginDrawing()
        rl.ClearBackground(COL_BG)

        draw_stars(gs.star_anim)

        switch gs.screen {
            case .MainMenu:
                draw_main_menu(&gs)
            case .NewGame:
                draw_new_game(&gs)
            case .Dashboard:
                draw_topbar(&gs)
                draw_bottom_nav(&gs)
                draw_dashboard(&gs)
            case .Rockets:
                draw_topbar(&gs)
                draw_bottom_nav(&gs)
                draw_rockets(&gs)
            case .RocketDesign:
                draw_topbar(&gs)
                draw_rocket_design(&gs)
            case .Astronauts:
                draw_topbar(&gs)
                draw_bottom_nav(&gs)
                draw_astronauts(&gs)
            case .Missions:
                draw_topbar(&gs)
                draw_bottom_nav(&gs)
                draw_missions(&gs)
            case .MissionPlan:
                draw_topbar(&gs)
                draw_mission_plan(&gs)
            case .MissionLog:
                draw_topbar(&gs)
                draw_mission_log(&gs)
            case .Research:
                draw_topbar(&gs)
                draw_bottom_nav(&gs)
                draw_research(&gs)
            case .StarMap:
                draw_topbar(&gs)
                draw_bottom_nav(&gs)
                draw_star_map(&gs)
            case .Facilities:
                draw_topbar(&gs)
                draw_bottom_nav(&gs)
                draw_facilities(&gs)
            case .Settings:
                draw_topbar(&gs)
        }

        draw_notification(&gs)

        // ESC to go back
        if rl.IsKeyPressed(.ESCAPE) {
            switch gs.screen {
                case .Dashboard, .MainMenu: // do nothing
                case .NewGame, .RocketDesign, .MissionPlan, .MissionLog:
                    gs.screen = gs.prev_screen == .Dashboard ? .Dashboard : .MainMenu
                case:
                    gs.screen = .Dashboard
            }
        }

        rl.DrawFPS(4, 4)
        rl.EndDrawing()
    }
}
