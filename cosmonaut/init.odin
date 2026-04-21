package cosmonaut

import "core:math"
import "core:math/rand"
import "core:strings"
import rl "vendor:raylib"

// ── Stars ─────────────────────────────────────────────────────────────────────

stars:      [300]Star
star_count: int

init_stars :: proc() {
    star_count = 300
    for i in 0..<star_count {
        s := &stars[i]
        s.x          = rand.float32() * f32(SCREEN_W)
        s.y          = rand.float32() * f32(SCREEN_H)
        s.size       = rand.float32() * 1.8 + 0.3
        s.brightness = rand.float32() * 0.7 + 0.3
    }
}

draw_stars :: proc(anim: f32) {
    for i in 0..<star_count {
        s := &stars[i]
        flicker := f32(0.7) + f32(0.3) * math.sin_f32(anim*1.3 + f32(i)*0.7)
        alpha := u8(s.brightness * flicker * 200)
        rl.DrawCircle(i32(s.x), i32(s.y), s.size, rl.Color{200, 210, 255, alpha})
    }
}

// ── Default data ──────────────────────────────────────────────────────────────

default_rockets :: proc(a: ^Agency) {
    a.rockets[0] = RocketDesign{
        id = 1, name = "Vanguard I",
        stages = {
            RocketStage{"First Stage",  130, 260, 8.8, 1.2, false},
            RocketStage{"Second Stage",  32, 290, 1.8, 0.4, false},
            RocketStage{"Third Stage",   10, 310, 0.5, 0.1, false},
        },
        stage_count = 3, payload_kg = 22,
        cost_million = 12, reliability = 0.62, built = true,
    }
    a.rockets[1] = RocketDesign{
        id = 2, name = "Atlas I",
        stages = {
            RocketStage{"Atlas Booster",  1600, 290, 92,  8.0, false},
            RocketStage{"Atlas Sustainer", 270, 316, 18,  2.5, false},
            RocketStage{"Agena Upper",      71, 285,  5,  0.7, false},
        },
        stage_count = 2, payload_kg = 1360,
        cost_million = 38, reliability = 0.75, built = true,
    }
    a.rocket_count = 2
}

default_astronauts :: proc(a: ^Agency) {
    names := [5]string{"John Glenn","Alan Shepard","Gus Grissom","Scott Carpenter","Gordon Cooper"}
    nats  := [5]string{"USA","USA","USA","USA","USA"}
    pil   := [5]int{88, 92, 85, 82, 80}
    sci   := [5]int{72, 68, 75, 82, 78}
    eng   := [5]int{80, 85, 78, 70, 82}
    end_  := [5]int{90, 88, 85, 80, 82}
    for i in 0..<5 {
        a.astronauts[i] = Astronaut{
            id = i+1, name = names[i], nationality = nats[i],
            age = 32 + i*2,
            piloting = pil[i], science = sci[i],
            engineering = eng[i], endurance = end_[i],
            experience = 0, status = .Available, morale = 75,
        }
    }
    a.astronaut_count = 5
}

default_research :: proc(a: ^Agency) {
    projs := [7]ResearchProject{
        {.PropulsionTech,   "Kerolox Engine Upgrade",   "Improve first-stage thrust and Isp",        8,  6,0,"+ 15% thrust",     false},
        {.LifeSupport,      "Extended Life Support",    "Enable missions beyond 14 days",             6,  4,0,"30-day missions",   false},
        {.Navigation,       "Inertial Guidance Mk.II",  "Reduce trajectory errors significantly",     5,  3,0,"+10% accuracy",     false},
        {.MaterialScience,  "Ablative Heat Shield",     "Enable reentry from deep-space velocities",  10, 8,0,"Deep-space reentry",false},
        {.Robotics,         "Autonomous Lander Systems","Unmanned precision landing capability",       9,  7,0,"Robotic landing",   false},
        {.NuclearPropulsion,"NERVA Prototype",          "Nuclear thermal rocket for deep space",       20,14,0,"Nuclear engine",    false},
        {.ArtificialGravity,"Rotating Habitat Module", "Eliminate long-term microgravity effects",    15,12,0,"Artif. gravity",    false},
    }
    for i in 0..<7 { a.research[i] = projs[i] }
    a.research_count = 7
}

default_bodies :: proc(gs: ^GameState) {
    gs.bodies[0]  = CelestialBody{"Mercury", 0.39,  4879, 0.38,false,false,false,false,rl.Color{180,150,120,255},0.06,0.3}
    gs.bodies[1]  = CelestialBody{"Venus",   0.72, 12104, 0.90,false,false,false,false,rl.Color{220,190, 80,255},0.10,1.1}
    gs.bodies[2]  = CelestialBody{"Earth",   1.00, 12742, 1.00,true, true, true, true, rl.Color{ 60,140,220,255},0.16,2.0}
    gs.bodies[3]  = CelestialBody{"Moon",    1.00,  3474, 0.17,false,false,false,false,rl.Color{200,200,190,255},0.17,2.4}
    gs.bodies[4]  = CelestialBody{"Mars",    1.52,  6779, 0.38,false,false,false,false,rl.Color{200, 80, 40,255},0.28,0.8}
    gs.bodies[5]  = CelestialBody{"Phobos",  1.52,    22, 0.01,false,false,false,false,rl.Color{160,120, 80,255},0.29,0.9}
    gs.bodies[6]  = CelestialBody{"Jupiter", 5.20,139820, 2.53,false,false,false,false,rl.Color{200,160, 90,255},0.42,1.6}
    gs.bodies[7]  = CelestialBody{"Saturn",  9.58,116460, 1.07,false,false,false,false,rl.Color{220,195,130,255},0.58,2.2}
    gs.bodies[8]  = CelestialBody{"Uranus", 19.22, 50724, 0.89,false,false,false,false,rl.Color{120,200,220,255},0.72,0.5}
    gs.bodies[9]  = CelestialBody{"Neptune",30.05, 49244, 1.14,false,false,false,false,rl.Color{ 40, 80,220,255},0.84,1.3}
    gs.bodies[10] = CelestialBody{"Pluto",  39.48,  2377, 0.06,false,false,false,false,rl.Color{160,130,110,255},0.92,0.7}
    gs.bodies[11] = CelestialBody{"Ceres",   2.77,   945, 0.03,false,false,false,false,rl.Color{140,140,130,255},0.31,2.8}
    gs.body_count = 12
}

new_agency :: proc(name: string) -> Agency {
    a := Agency{
        name           = name,
        budget         = 500,
        prestige       = 10,
        month          = 1,
        year           = 1957,
        monthly_income = 40,
        reputation     = 50,
        facilities     = Facilities{1,1,1,1,1},
    }
    default_rockets(&a)
    default_astronauts(&a)
    default_research(&a)
    return a
}
