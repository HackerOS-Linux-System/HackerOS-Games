package cosmonaut

import "core:fmt"
import "core:math"
import "core:strings"
import rl "vendor:raylib"

// ── Text helpers ──────────────────────────────────────────────────────────────

label :: proc(text: cstring, x, y: f32, size: i32, col: rl.Color) {
    rl.DrawText(text, i32(x), i32(y), size, col)
}

label_str :: proc(text: string, x, y: f32, size: i32, col: rl.Color) {
    cs := strings.clone_to_cstring(text)
    defer delete(cs)
    rl.DrawText(cs, i32(x), i32(y), size, col)
}

tprint :: proc(fmt_str: string, args: ..any) -> cstring {
    s := fmt.tprintf(fmt_str, ..args)
    return strings.clone_to_cstring(s)
}

// ── Drawing helpers ───────────────────────────────────────────────────────────

panel :: proc(x, y, w, h: f32, col: rl.Color) {
    rl.DrawRectangle(i32(x), i32(y), i32(w), i32(h), col)
    rl.DrawRectangleLines(i32(x), i32(y), i32(w), i32(h), COL_BORDER)
}

section_line :: proc(title: cstring, y: f32) {
    rl.DrawLine(20, i32(y), SCREEN_W-20, i32(y), COL_BORDER)
    tw := rl.MeasureText(title, 16)
    cx := f32(SCREEN_W)/2 - f32(tw)/2
    rl.DrawRectangle(i32(cx)-8, i32(y)-10, tw+16, 20, COL_BG)
    rl.DrawText(title, i32(cx), i32(y)-6, 16, COL_DIM)
}

stat_bar :: proc(lbl: cstring, val, max_val: f32, x, y, w: f32, col: rl.Color) {
    rl.DrawText(lbl, i32(x), i32(y), 13, COL_DIM)
    bx := x + 110
    bw := w - 120
    rl.DrawRectangle(i32(bx), i32(y), i32(bw), 12, COL_PANEL2)
    fill := bw * math.clamp(val/max_val, 0, 1)
    rl.DrawRectangle(i32(bx), i32(y), i32(fill), 12, col)
    rl.DrawRectangleLines(i32(bx), i32(y), i32(bw), 12, COL_BORDER)
    rl.DrawText(tprint("%d", int(val)), i32(bx+bw+5), i32(y), 13, COL_TEXT)
}

button :: proc(text: cstring, x, y, w, h: f32, col: rl.Color, disabled := false) -> bool {
    mx := f32(rl.GetMouseX())
    my := f32(rl.GetMouseY())
    hover := !disabled && mx >= x && mx <= x+w && my >= y && my <= y+h
    bg_r := col.r / 5
    bg_g := col.g / 5
    bg_b := col.b / 5
    bg := rl.Color{bg_r, bg_g, bg_b, 200}
    if hover    { bg = rl.Color{col.r/3, col.g/3, col.b/3, 220} }
    if disabled { bg = rl.Color{20, 22, 28, 180} }
    rl.DrawRectangle(i32(x), i32(y), i32(w), i32(h), bg)
    border_col: rl.Color
    if disabled    { border_col = COL_BORDER }
    else if hover  { border_col = col }
    else           { border_col = rl.Color{col.r/3, col.g/3, col.b/3, 200} }
    rl.DrawRectangleLines(i32(x), i32(y), i32(w), i32(h), border_col)
    tw := rl.MeasureText(text, 17)
    tx := x + (w - f32(tw)) / 2
    ty := y + h/2 - 9
    tcol := disabled ? COL_DIM : (hover ? col : COL_TEXT)
    rl.DrawText(text, i32(tx), i32(ty), 17, tcol)
    return hover && rl.IsMouseButtonPressed(.LEFT)
}

// ── Name helpers ──────────────────────────────────────────────────────────────

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

mission_status_str :: proc(s: MissionStatus) -> string {
    switch s {
    case .Planning:      return "PLANNING"
    case .Building:      return "BUILDING"
    case .ReadyToLaunch: return "READY"
    case .InFlight:      return "IN FLIGHT"
    case .Success:       return "SUCCESS"
    case .Failure:       return "FAILURE"
    case .Aborted:       return "ABORTED"
    }
    return ""
}

mission_status_col :: proc(s: MissionStatus) -> rl.Color {
    switch s {
    case .Planning:      return COL_DIM
    case .Building:      return COL_ORANGE
    case .ReadyToLaunch: return COL_CYAN
    case .InFlight:      return COL_ACCENT
    case .Success:       return COL_GREEN
    case .Failure:       return COL_RED
    case .Aborted:       return COL_RED
    }
    return COL_TEXT
}

astronaut_status_col :: proc(s: AstronautStatus) -> rl.Color {
    switch s {
    case .Available: return COL_GREEN
    case .Training:  return COL_GOLD
    case .InFlight:  return COL_ACCENT
    case .Retired:   return COL_DIM
    case .Lost:      return COL_RED
    }
    return COL_TEXT
}

astronaut_status_str :: proc(s: AstronautStatus) -> string {
    switch s {
    case .Available: return "AVAILABLE"
    case .Training:  return "IN TRAINING"
    case .InFlight:  return "IN FLIGHT"
    case .Retired:   return "RETIRED"
    case .Lost:      return "LOST IN SPACE"
    }
    return ""
}

research_area_name :: proc(a: ResearchArea) -> string {
    switch a {
    case .PropulsionTech:    return "Propulsion"
    case .LifeSupport:       return "Life Support"
    case .Navigation:        return "Navigation"
    case .MaterialScience:   return "Materials"
    case .Robotics:          return "Robotics"
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
    names := [12]string{"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
    return names[(m-1) % 12]
}

push_notification :: proc(gs: ^GameState, msg: string) {
    n := min(len(msg), 127)
    gs.notif_len = n
    for i in 0..<n { gs.notification[i] = msg[i] }
    gs.notif_timer = 4.0
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
