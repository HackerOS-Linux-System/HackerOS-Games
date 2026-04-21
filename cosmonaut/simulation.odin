package cosmonaut

import "core:fmt"
import "core:math/rand"
import "core:strings"

// ── Mission helpers ───────────────────────────────────────────────────────────

mission_base_chance :: proc(t: MissionType, r: ^RocketDesign, a: ^Agency) -> f32 {
    base: f32
    switch t {
    case .OrbitalTest:      base = 0.92
    case .SatelliteNetwork: base = 0.88
    case .CrewedOrbit:      base = 0.84
    case .LunarFlyby:       base = 0.80
    case .LunarOrbit:       base = 0.74
    case .LunarLanding:     base = 0.60
    case .MarsProbe:        base = 0.72
    case .MarsOrbiter:      base = 0.62
    case .MarsSurface:      base = 0.46
    case .AsteroidProbe:    base = 0.66
    case .SpaceStation:     base = 0.76
    case .DeepSpaceProbe:   base = 0.64
    }
    base *= r.reliability
    base += f32(a.facilities.tracking_level - 1) * 0.02
    base += f32(a.facilities.vab_level - 1) * 0.01
    if base < 0.05 { base = 0.05 }
    if base > 0.98 { base = 0.98 }
    return base
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

mission_cost :: proc(t: MissionType, r: ^RocketDesign) -> int {
    base := r.cost_million
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

mission_destination :: proc(t: MissionType) -> string {
    switch t {
    case .OrbitalTest:      return "Earth Orbit"
    case .SatelliteNetwork: return "Earth Orbit"
    case .CrewedOrbit:      return "Earth Orbit"
    case .LunarFlyby:       return "Moon"
    case .LunarOrbit:       return "Moon"
    case .LunarLanding:     return "Moon"
    case .MarsProbe:        return "Mars"
    case .MarsOrbiter:      return "Mars"
    case .MarsSurface:      return "Mars"
    case .AsteroidProbe:    return "Ceres"
    case .SpaceStation:     return "Earth Orbit"
    case .DeepSpaceProbe:   return "Neptune"
    }
    return "Space"
}

mission_needs_crew :: proc(t: MissionType) -> bool {
    #partial switch t {
    case .CrewedOrbit, .LunarOrbit, .LunarLanding, .MarsSurface, .SpaceStation:
        return true
    }
    return false
}

// ── Body exploration update ───────────────────────────────────────────────────

update_body_exploration :: proc(gs: ^GameState, m: ^Mission) {
    for i in 0..<gs.body_count {
        b := &gs.bodies[i]
        if !strings.contains(m.destination, b.name) { continue }
        #partial switch m.mission_type {
        case .LunarFlyby, .MarsProbe, .AsteroidProbe, .DeepSpaceProbe:
            b.probed = true
        case .LunarOrbit, .MarsOrbiter, .SpaceStation:
            b.probed  = true
            b.orbited = true
        case .LunarLanding, .MarsSurface:
            b.probed   = true
            b.orbited  = true
            b.landed   = true
            b.explored = true
        case .OrbitalTest, .CrewedOrbit, .SatelliteNetwork:
            // Earth-only
        }
    }
}

// ── Events ────────────────────────────────────────────────────────────────────

EventDef :: struct {
    msg:        string,
    budget_d:   int,
    rep_d:      int,
}

EVENTS := [8]EventDef{
    {"Solar flare disrupts communications",                   -5,  -5},
    {"Congressional hearing: additional funding approved!",   30,   5},
    {"Public excitement surges — reputation boost",            0,  10},
    {"Equipment supplier delays delivery",                     0,  -3},
    {"International collaboration offer: $20M grant",         20,   8},
    {"Budget review: efficiency bonus awarded",               15,   3},
    {"Lab breakthrough accelerates R&D",                       0,   5},
    {"Astronaut training accident — morale drops",             0,  -8},
}

generate_event :: proc(gs: ^GameState) {
    a := &gs.agency
    idx := int(rand.float32() * 8) % 8
    ev := EVENTS[idx]

    if a.event_count < 8 {
        a.events[a.event_count] = ev.msg
        a.event_count += 1
    } else {
        for i in 0..<7 { a.events[i] = a.events[i+1] }
        a.events[7] = ev.msg
    }

    a.budget += ev.budget_d
    a.reputation += ev.rep_d
    if a.reputation < 0   { a.reputation = 0 }
    if a.reputation > 100 { a.reputation = 100 }
    push_notification(gs, ev.msg)
}

// ── Main simulation tick ──────────────────────────────────────────────────────

advance_month :: proc(gs: ^GameState) {
    a := &gs.agency
    a.month += 1
    if a.month > 12 { a.month = 1; a.year += 1 }

    // Income
    income := a.monthly_income + (a.reputation - 50) / 5
    a.budget += income

    // Upkeep
    upkeep := 10 + a.facilities.vab_level*3 + a.facilities.launch_pads*5
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
                a.prestige    += 5
            }
        }
    }

    // Mission progress
    for i in 0..<a.mission_count {
        m := &a.missions[i]
        if m.status != .InFlight { continue }
        m.elapsed += 1

        append_mission_log(m, fmt.tprintf("Month %d/%d: Nominal", m.elapsed, m.duration))

        // Random in-flight events
        roll := rand.float32()
        if roll < 0.04 {
            append_mission_log(m, "Minor anomaly — crew responding")
        } else if roll < 0.015 {
            m.success_chance *= 0.75
            append_mission_log(m, "CRITICAL: System failure")
        }

        if m.elapsed < m.duration { continue }

        // Mission outcome
        if rand.float32() < m.success_chance {
            m.status       = .Success
            a.prestige    += m.prestige
            a.science_pts += m.science
            a.budget      += m.cost / 4
            push_notification(gs, fmt.tprintf("SUCCESS: %s returned!", m.name))
            update_body_exploration(gs, m)
            // Restore crew
            for j in 0..<m.crew_count {
                aid := m.crew[j]
                for k in 0..<a.astronaut_count {
                    if a.astronauts[k].id == aid {
                        a.astronauts[k].status = .Available
                        a.astronauts[k].experience += 1
                        a.astronauts[k].morale = min(100, a.astronauts[k].morale + 15)
                    }
                }
            }
        } else {
            m.status       = .Failure
            a.prestige     = max(0, a.prestige - m.prestige/2)
            a.reputation   = max(0, a.reputation - 10)
            push_notification(gs, fmt.tprintf("FAILURE: %s lost contact", m.name))
            // Crew fate
            if m.crew_count > 0 && rand.float32() < 0.4 {
                for j in 0..<m.crew_count {
                    aid := m.crew[j]
                    for k in 0..<a.astronaut_count {
                        if a.astronauts[k].id == aid { a.astronauts[k].status = .Lost }
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

    // Random world event
    if rand.float32() < 0.12 { generate_event(gs) }

    // Reputation drift towards 50
    if a.reputation > 50 { a.reputation -= 1 }
    if a.reputation < 50 { a.reputation += 1 }
}
