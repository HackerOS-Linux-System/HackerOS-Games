package cosmonaut

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:os"
import "core:strings"
import rl "vendor:raylib"

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN MENU
// ═══════════════════════════════════════════════════════════════════════════════

draw_main_menu :: proc(gs: ^GameState) {
    title : cstring = "COSMONAUT"
    tw := rl.MeasureText(title, 80)
    rl.DrawText(title, SCREEN_W/2 - tw/2, i32(f32(SCREEN_H)*0.18), 80, COL_ACCENT)

    sub : cstring = "SPACE AGENCY MANAGEMENT"
    sw2 := rl.MeasureText(sub, 20)
    rl.DrawText(sub, SCREEN_W/2 - sw2/2, i32(f32(SCREEN_H)*0.18)+90, 20, COL_DIM)

    rl.DrawLine(SCREEN_W/2-180, i32(f32(SCREEN_H)*0.38), SCREEN_W/2+180, i32(f32(SCREEN_H)*0.38), COL_BORDER)

    bw :: f32(260)
    bh :: f32(48)
    bx := f32(SCREEN_W)/2 - bw/2

    if button("NEW AGENCY",  bx, f32(SCREEN_H)*0.42,      bw, bh, COL_ACCENT) {
        gs.screen = .NewGame
        gs.setup_step = 0
        gs.input_len = 0
        gs.selected = 0
    }
    if button("EXIT", bx, f32(SCREEN_H)*0.42+62, bw, bh, COL_DIM) { os.exit(0) }

    // Decorative orbit circles
    rl.DrawCircleLines(SCREEN_W/2, SCREEN_H/2+40, 280, rl.Color{40, 80, 160, 25})
    rl.DrawCircleLines(SCREEN_W/2, SCREEN_H/2+40, 200, rl.Color{30, 60, 120, 18})

    rl.DrawText("v0.1.0", SCREEN_W-60, SCREEN_H-20, 13, COL_DIM)
}

// ═══════════════════════════════════════════════════════════════════════════════
// NEW GAME
// ═══════════════════════════════════════════════════════════════════════════════

draw_new_game :: proc(gs: ^GameState) {
    label("ESTABLISH YOUR SPACE AGENCY", 30, 30, 28, COL_TEXT)
    rl.DrawLine(30, 66, SCREEN_W-30, 66, COL_BORDER)

    label("Agency Name:", 80, 110, 20, COL_DIM)
    rl.DrawRectangle(80, 138, 500, 44, COL_PANEL2)
    rl.DrawRectangleLines(80, 138, 500, 44, COL_ACCENT)

    display := string(gs.input_buf[:gs.input_len])
    rl.DrawText(tprint("%s|", display), 92, 150, 22, COL_TEXT)

    // Keyboard input
    char := rl.GetCharPressed()
    for char != 0 {
        if gs.input_len < 40 && char >= 32 {
            gs.input_buf[gs.input_len] = u8(char)
            gs.input_len += 1
        }
        char = rl.GetCharPressed()
    }
    if rl.IsKeyPressed(.BACKSPACE) && gs.input_len > 0 { gs.input_len -= 1 }

    label("Starting Era:", 80, 205, 20, COL_DIM)

    Era :: struct { name: string, year: int, budget: int, income: int, desc: string }
    eras := [4]Era{
        {"Space Race (1957)", 1957, 300, 30, "Humble beginnings. Limited technology."},
        {"Apollo Era (1960)", 1960, 500, 45, "Lunar ambitions. Improved rockets."},
        {"Shuttle Era (1975)", 1975, 800, 65, "Reusability focus. Larger budgets."},
        {"Modern Era (1995)", 1995,1200, 90, "Advanced tech. Commercial partnerships."},
    }

    for i in 0..<4 {
        e := eras[i]
        ey := f32(228 + i*78)
        sel := gs.selected == i
        bg := sel ? rl.Color{20,40,80,200} : COL_PANEL
        rl.DrawRectangle(80, i32(ey), 500, 68, bg)
        rl.DrawRectangleLines(80, i32(ey), 500, 68, sel ? COL_ACCENT : COL_BORDER)
        rl.DrawText(tprint("%s", e.name), 96, i32(ey)+10, 20, sel ? COL_ACCENT : COL_TEXT)
        rl.DrawText(tprint("%s", e.desc), 96, i32(ey)+34, 14, COL_DIM)
        rl.DrawText(tprint("$%dM start  |  $%dM/mo income", e.budget, e.income), 96, i32(ey)+52, 13, COL_DIM)

        mx := i32(rl.GetMouseX())
        my := i32(rl.GetMouseY())
        if mx >= 80 && mx <= 580 && my >= i32(ey) && my <= i32(ey)+68 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    can_start := gs.input_len > 0
    if button("FOUND AGENCY ->", f32(SCREEN_W)/2 - 140, f32(SCREEN_H)-80, 280, 50, COL_ACCENT, !can_start) {
        e := eras[gs.selected]
        name := strings.clone(string(gs.input_buf[:gs.input_len]))
        gs.agency = new_agency(name)
        gs.agency.year           = e.year
        gs.agency.budget         = e.budget
        gs.agency.monthly_income = e.income
        gs.screen = .Dashboard
        gs.selected = -1
    }
    if button("<- BACK", 30, f32(SCREEN_H)-80, 120, 44, COL_DIM) {
        gs.screen = .MainMenu
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════

draw_dashboard :: proc(gs: ^GameState) {
    a := &gs.agency
    label("MISSION CONTROL", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    // Stats row
    StatEntry :: struct { lbl: string, val: string, col: rl.Color }
    stats := [5]StatEntry{
        {"BUDGET",     fmt.tprintf("$%dM", a.budget),          COL_GREEN},
        {"PRESTIGE",   fmt.tprintf("%d pts", a.prestige),       COL_GOLD},
        {"SCIENCE",    fmt.tprintf("%d pts", a.science_pts),    COL_CYAN},
        {"REPUTATION", fmt.tprintf("%d%%", a.reputation),       COL_ACCENT},
        {"INCOME",     fmt.tprintf("+$%dM/mo", a.monthly_income),COL_GREEN},
    }
    sw3 := f32(SCREEN_W-40) / 5
    for i in 0..<5 {
        sx := f32(20) + f32(i)*sw3
        rl.DrawRectangle(i32(sx), 94, i32(sw3)-4, 60, COL_PANEL)
        rl.DrawRectangleLines(i32(sx), 94, i32(sw3)-4, 60, COL_BORDER)
        rl.DrawText(tprint("%s", stats[i].lbl), i32(sx)+10, 104, 13, COL_DIM)
        rl.DrawText(tprint("%s", stats[i].val), i32(sx)+10, 122, 20, stats[i].col)
    }

    // Active missions
    section_line("ACTIVE MISSIONS", 168)
    active_count := 0
    for i in 0..<a.mission_count {
        m := &a.missions[i]
        if m.status != .InFlight && m.status != .ReadyToLaunch { continue }
        my2 := f32(182 + active_count*52)
        if my2 > f32(SCREEN_H) - 220 { break }
        panel(20, my2, f32(SCREEN_W)-40, 46, COL_PANEL)
        scol := mission_status_col(m.status)
        rl.DrawRectangle(20, i32(my2), 4, 46, scol)
        rl.DrawText(tprint("%s", m.name), 32, i32(my2)+8, 18, COL_TEXT)
        rl.DrawText(tprint("%s", mission_type_name(m.mission_type)), 32, i32(my2)+30, 13, COL_DIM)
        progress := f32(m.elapsed) / f32(max(m.duration, 1))
        rl.DrawRectangle(300, i32(my2)+16, 300, 14, COL_PANEL2)
        rl.DrawRectangle(300, i32(my2)+16, i32(300*progress), 14, scol)
        rl.DrawRectangleLines(300, i32(my2)+16, 300, 14, COL_BORDER)
        rl.DrawText(tprint("Mo %d/%d", m.elapsed, m.duration), 608, i32(my2)+18, 14, COL_DIM)
        rl.DrawText(tprint("-> %s", m.destination), SCREEN_W-200, i32(my2)+18, 14, COL_ACCENT)
        active_count += 1
    }
    if active_count == 0 {
        rl.DrawText("No active missions. Plan one in MISSIONS.", 40, 196, 16, COL_DIM)
    }

    // Events
    ey := f32(182 + max(active_count,1)*52 + 20)
    section_line("RECENT EVENTS", ey)
    for i in 0..<a.event_count {
        idx := a.event_count - 1 - i
        ly := ey + 18 + f32(i)*22
        if ly > f32(SCREEN_H)-100 { break }
        rl.DrawText(tprint("%s", a.events[idx]), 28, i32(ly), 14, COL_DIM)
    }
    if a.event_count == 0 { rl.DrawText("No events yet.", 28, i32(ey)+18, 14, COL_DIM) }

    // Advance time
    if button("ADVANCE MONTH", f32(SCREEN_W)-210, f32(SCREEN_H)-90, 195, 42, COL_ACCENT) {
        advance_month(gs)
    }
    label("[SPACE]", f32(SCREEN_W-195), f32(SCREEN_H-44), 13, COL_DIM)
    if rl.IsKeyPressed(.SPACE) { advance_month(gs) }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROCKETS
// ═══════════════════════════════════════════════════════════════════════════════

draw_rockets :: proc(gs: ^GameState) {
    a := &gs.agency
    label("ROCKET FLEET", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    for i in 0..<a.rocket_count {
        r := &a.rockets[i]
        ry := f32(96 + i*162)
        sel := gs.selected == i
        bg := sel ? rl.Color{15,25,50,220} : COL_PANEL
        rl.DrawRectangle(20, i32(ry), SCREEN_W-40, 152, bg)
        rl.DrawRectangleLines(20, i32(ry), SCREEN_W-40, 152, sel ? COL_ACCENT : COL_BORDER)

        rl.DrawText(tprint("%s", r.name), 36, i32(ry)+10, 24, COL_ACCENT)
        rl.DrawText(tprint("VEHICLE #%02d", r.id), 36, i32(ry)+38, 14, COL_DIM)

        stat_bar("RELIABILITY", r.reliability*99, 99, 300, ry+14, 340, COL_GREEN)
        stat_bar("PAYLOAD kg",  r.payload_kg, 50000, 300, ry+36, 340, COL_ACCENT)

        for si in 0..<r.stage_count {
            s := r.stages[si]
            sx := f32(660 + si*200)
            rl.DrawRectangle(i32(sx), i32(ry)+10, 185, 90, COL_PANEL2)
            rl.DrawRectangleLines(i32(sx), i32(ry)+10, 185, 90, COL_BORDER)
            rl.DrawText(tprint("Stage %d: %s", si+1, s.name), i32(sx)+8, i32(ry)+20, 12, COL_DIM)
            rl.DrawText(tprint("Thrust: %.0f kN", s.thrust_kn), i32(sx)+8, i32(ry)+36, 13, COL_TEXT)
            rl.DrawText(tprint("Isp:    %.0f s",  s.isp),       i32(sx)+8, i32(ry)+52, 13, COL_TEXT)
            if s.reusable { rl.DrawText("REUSABLE", i32(sx)+8, i32(ry)+70, 12, COL_GREEN) }
        }

        rl.DrawText(tprint("Launches: %d  Successes: %d  Cost: $%.0fM", r.launches, r.successes, r.cost_million),
            36, i32(ry)+118, 14, COL_DIM)
        rel_pct := tprint("%.0f%% reliability", r.reliability*100)
        rcol := r.reliability > 0.85 ? COL_GREEN : (r.reliability > 0.70 ? COL_GOLD : COL_RED)
        rl.DrawText(rel_pct, 36, i32(ry)+136, 15, rcol)

        mx := i32(rl.GetMouseX())
        my := i32(rl.GetMouseY())
        if mx >= 20 && mx <= SCREEN_W-20 && my >= i32(ry) && my <= i32(ry)+152 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    if button("+ DESIGN NEW ROCKET", 20, f32(SCREEN_H)-90, 220, 44, COL_ORANGE) {
        gs.screen = .RocketDesign
        gs.selected = -1
        gs.input_len = 0
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ROCKET DESIGN
// ═══════════════════════════════════════════════════════════════════════════════

draw_rocket_design :: proc(gs: ^GameState) {
    a := &gs.agency
    label("ROCKET DESIGN LAB", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)
    label("Select base configuration:", 30, 100, 18, COL_DIM)

    configs := [5]RocketConfig{
        {"Light Scout",    500,   25, 0.88, 2, "Small payload. Good for probes."},
        {"Medium Lifter", 3500,   65, 0.82, 2, "Balanced workhorse. Most missions."},
        {"Heavy Lift",   15000,  140, 0.76, 3, "Large payloads. Stations, landers."},
        {"Super Heavy",  50000,  320, 0.68, 3, "Mars and beyond. Very expensive."},
        {"Crewed Rocket", 8000,  120, 0.85, 3, "Crew safety optimized."},
    }

    for i in 0..<5 {
        c := configs[i]
        cy := f32(122 + i*84)
        sel := gs.selected == i
        rl.DrawRectangle(30, i32(cy), SCREEN_W-260, 76, sel ? rl.Color{15,30,60,220} : COL_PANEL)
        rl.DrawRectangleLines(30, i32(cy), SCREEN_W-260, 76, sel ? COL_ACCENT : COL_BORDER)
        rl.DrawText(tprint("%s", c.name), 46, i32(cy)+10, 20, sel ? COL_ACCENT : COL_TEXT)
        rl.DrawText(tprint("%s", c.desc), 46, i32(cy)+34, 14, COL_DIM)
        rl.DrawText(tprint("Payload: %.0f kg  |  $%.0fM  |  %.0f%% rel  |  %d stages",
            c.payload, c.cost, c.rel*100, c.stages), 46, i32(cy)+54, 13, COL_DIM)
        mx := i32(rl.GetMouseX())
        my := i32(rl.GetMouseY())
        if mx >= 30 && mx <= SCREEN_W-230 && my >= i32(cy) && my <= i32(cy)+76 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    label("Rocket Name:", 30, f32(SCREEN_H)-168, 18, COL_DIM)
    rl.DrawRectangle(30, i32(SCREEN_H)-144, 400, 38, COL_PANEL2)
    rl.DrawRectangleLines(30, i32(SCREEN_H)-144, 400, 38, COL_ACCENT)
    rl.DrawText(tprint("%s|", string(gs.input_buf[:gs.input_len])), 42, i32(SCREEN_H)-134, 20, COL_TEXT)
    char := rl.GetCharPressed()
    for char != 0 {
        if gs.input_len < 30 && char >= 32 { gs.input_buf[gs.input_len] = u8(char); gs.input_len += 1 }
        char = rl.GetCharPressed()
    }
    if rl.IsKeyPressed(.BACKSPACE) && gs.input_len > 0 { gs.input_len -= 1 }

    can_build := gs.selected >= 0 && gs.input_len > 0 && a.rocket_count < 8
    if gs.selected >= 0 {
        c := configs[gs.selected]
        ccol := a.budget >= int(c.cost) ? COL_GREEN : COL_RED
        rl.DrawText(tprint("Cost: $%.0fM", c.cost), 450, i32(SCREEN_H)-134, 18, ccol)
        can_build = can_build && a.budget >= int(c.cost)
    }

    if button("BUILD ROCKET", 30, f32(SCREEN_H)-90, 200, 44, COL_ORANGE, !can_build) {
        c := configs[gs.selected]
        a.budget -= int(c.cost)
        r := RocketDesign{
            id           = a.rocket_count + 1,
            name         = strings.clone(string(gs.input_buf[:gs.input_len])),
            stages       = {
                RocketStage{"First Stage",  800, 290, 60, 6.0, false},
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
        push_notification(gs, fmt.tprintf("Rocket built: %s", r.name))
        gs.screen = .Rockets
        gs.input_len = 0
        gs.selected = -1
    }
    if button("<- CANCEL", 250, f32(SCREEN_H)-90, 130, 44, COL_DIM) {
        gs.screen = .Rockets
        gs.input_len = 0
        gs.selected = -1
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ASTRONAUTS
// ═══════════════════════════════════════════════════════════════════════════════

draw_astronauts :: proc(gs: ^GameState) {
    a := &gs.agency
    label("ASTRONAUT CORPS", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    available := 0
    for i in 0..<a.astronaut_count { if a.astronauts[i].status == .Available { available += 1 } }
    rl.DrawText(tprint("Astronauts: %d  |  Available: %d", a.astronaut_count, available), 20, 96, 16, COL_DIM)

    for i in 0..<a.astronaut_count {
        ast := &a.astronauts[i]
        ay := f32(116 + i*112)
        if ay > f32(SCREEN_H) - 100 { break }

        sel := gs.selected == i
        bg := sel ? rl.Color{10,20,40,220} : COL_PANEL
        rl.DrawRectangle(20, i32(ay), SCREEN_W-40, 102, bg)
        rl.DrawRectangleLines(20, i32(ay), SCREEN_W-40, 102, sel ? COL_GREEN : COL_BORDER)

        scol := astronaut_status_col(ast.status)
        rl.DrawRectangle(20, i32(ay), 4, 102, scol)

        rl.DrawText(tprint("%s", ast.name), 34, i32(ay)+10, 22, COL_TEXT)
        rl.DrawText(tprint("%s  Age %d  %d missions", ast.nationality, ast.age, ast.experience), 34, i32(ay)+36, 14, COL_DIM)
        rl.DrawText(tprint("%s", astronaut_status_str(ast.status)), 34, i32(ay)+56, 14, scol)

        hw := f32(SCREEN_W-40) / 4.5
        stat_bar("PILOT",   f32(ast.piloting),   99, 300, ay+14, hw, COL_ACCENT)
        stat_bar("SCIENCE", f32(ast.science),     99, 300, ay+34, hw, COL_CYAN)
        stat_bar("ENG",     f32(ast.engineering), 99, 300, ay+54, hw, COL_ORANGE)
        stat_bar("ENDUR.",  f32(ast.endurance),   99, 300, ay+74, hw, COL_GREEN)

        ovr := (ast.piloting + ast.science + ast.engineering + ast.endurance) / 4
        rl.DrawText(tprint("OVR %d", ovr), SCREEN_W-120, i32(ay)+30, 22, COL_GOLD)
        mcol := ast.morale > 60 ? COL_GREEN : (ast.morale > 30 ? COL_GOLD : COL_RED)
        rl.DrawText(tprint("Morale %d%%", ast.morale), SCREEN_W-120, i32(ay)+60, 14, mcol)

        mx := i32(rl.GetMouseX())
        my := i32(rl.GetMouseY())
        if mx >= 20 && mx <= SCREEN_W-20 && my >= i32(ay) && my <= i32(ay)+102 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    recruit_names := [5]string{"Elena Sorokina","Kwame Mensah","Yuki Tanaka","Lars Eriksson","Priya Sharma"}
    recruit_nats  := [5]string{"RUS","GHA","JPN","SWE","IND"}

    if button("+ RECRUIT ($30M)", 20, f32(SCREEN_H)-90, 230, 44, COL_GREEN, a.budget < 30 || a.astronaut_count >= 16) {
        if a.budget >= 30 {
            a.budget -= 30
            idx := a.astronaut_count % 5
            ast := Astronaut{
                id          = a.astronaut_count + 1,
                name        = recruit_names[idx],
                nationality = recruit_nats[idx],
                age         = 28 + int(rand.float32()*10),
                piloting    = 55 + int(rand.float32()*30),
                science     = 55 + int(rand.float32()*30),
                engineering = 55 + int(rand.float32()*30),
                endurance   = 55 + int(rand.float32()*30),
                status      = .Available,
                morale      = 80,
            }
            a.astronauts[a.astronaut_count] = ast
            a.astronaut_count += 1
            push_notification(gs, fmt.tprintf("Recruited: %s", ast.name))
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MISSIONS
// ═══════════════════════════════════════════════════════════════════════════════

draw_missions :: proc(gs: ^GameState) {
    a := &gs.agency
    label("MISSION MANIFEST", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    tab_labels := [4]cstring{"ALL", "ACTIVE", "COMPLETED", "FAILED"}
    for i in 0..<4 {
        tx := f32(20 + i*110)
        active := gs.tab == i
        tcol := active ? COL_GOLD : COL_DIM
        rl.DrawRectangle(i32(tx), 94, 104, 24, active ? rl.Color{40,30,5,200} : COL_PANEL)
        rl.DrawRectangleLines(i32(tx), 94, 104, 24, active ? COL_GOLD : COL_BORDER)
        tw := rl.MeasureText(tab_labels[i], 14)
        rl.DrawText(tab_labels[i], i32(tx)+(104-tw)/2, 101, 14, tcol)
        mx := i32(rl.GetMouseX()); my := i32(rl.GetMouseY())
        if mx >= i32(tx) && mx <= i32(tx)+104 && my >= 94 && my <= 118 && rl.IsMouseButtonPressed(.LEFT) {
            gs.tab = i
        }
    }

    row := 0
    for i in 0..<a.mission_count {
        m := &a.missions[i]
        show := false
        switch gs.tab {
        case 0: show = true
        case 1: show = m.status == .InFlight || m.status == .ReadyToLaunch || m.status == .Planning
        case 2: show = m.status == .Success
        case 3: show = m.status == .Failure || m.status == .Aborted
        }
        if !show { continue }

        my2 := f32(126 + row*68)
        if my2 > f32(SCREEN_H)-100 { break }

        scol := mission_status_col(m.status)
        sel := gs.selected == i
        rl.DrawRectangle(20, i32(my2), SCREEN_W-40, 62, sel ? rl.Color{10,18,36,220} : COL_PANEL)
        rl.DrawRectangleLines(20, i32(my2), SCREEN_W-40, 62, sel ? scol : COL_BORDER)
        rl.DrawRectangle(20, i32(my2), 4, 62, scol)

        rl.DrawText(tprint("%s", m.name), 32, i32(my2)+8, 20, COL_TEXT)
        rl.DrawText(tprint("%s", mission_type_name(m.mission_type)), 32, i32(my2)+32, 14, COL_DIM)
        rl.DrawText(tprint("%s", mission_status_str(m.status)), 280, i32(my2)+20, 16, scol)

        if m.status == .InFlight {
            progress := f32(m.elapsed) / f32(max(m.duration, 1))
            rl.DrawRectangle(420, i32(my2)+20, 240, 14, COL_PANEL2)
            rl.DrawRectangle(420, i32(my2)+20, i32(240*progress), 14, COL_ACCENT)
            rl.DrawRectangleLines(420, i32(my2)+20, 240, 14, COL_BORDER)
            rl.DrawText(tprint("Mo %d/%d", m.elapsed, m.duration), 668, i32(my2)+22, 13, COL_DIM)
        }

        rl.DrawText(tprint("*%d  S%d  $%dM", m.prestige, m.science, m.cost), SCREEN_W-200, i32(my2)+20, 14, COL_GOLD)
        rl.DrawText(tprint("-> %s", m.destination), SCREEN_W-200, i32(my2)+38, 13, COL_ACCENT)

        mx3 := i32(rl.GetMouseX()); my3 := i32(rl.GetMouseY())
        if mx3 >= 20 && mx3 <= SCREEN_W-20 && my3 >= i32(my2) && my3 <= i32(my2)+62 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
            gs.prev_screen = .Missions
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
// MISSION PLAN
// ═══════════════════════════════════════════════════════════════════════════════

draw_mission_plan :: proc(gs: ^GameState) {
    a := &gs.agency
    label("PLAN NEW MISSION", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    section_line("MISSION TYPE", 94)
    all_types := [12]MissionType{
        .OrbitalTest, .SatelliteNetwork, .CrewedOrbit,
        .LunarFlyby, .LunarOrbit, .LunarLanding,
        .MarsProbe, .MarsOrbiter, .MarsSurface,
        .AsteroidProbe, .SpaceStation, .DeepSpaceProbe,
    }
    cols :: 4
    mt_w := f32(SCREEN_W-40) / cols
    mt_h :: f32(56)

    for i in 0..<12 {
        t := all_types[i]
        tx := f32(20) + f32(i%cols)*mt_w
        ty := f32(106) + f32(i/cols)*mt_h
        sel := gs.selected == i

        tcol: rl.Color
        #partial switch t {
        case .LunarFlyby, .LunarOrbit, .LunarLanding:  tcol = COL_GOLD
        case .MarsProbe, .MarsOrbiter, .MarsSurface:    tcol = COL_RED
        case .CrewedOrbit, .SpaceStation:               tcol = COL_GREEN
        case .DeepSpaceProbe, .AsteroidProbe:           tcol = COL_PURPLE
        case:                                            tcol = COL_ACCENT
        }
        bg := sel ? rl.Color{tcol.r/5, tcol.g/5, tcol.b/5, 220} : COL_PANEL
        rl.DrawRectangle(i32(tx), i32(ty), i32(mt_w)-4, i32(mt_h)-4, bg)
        rl.DrawRectangleLines(i32(tx), i32(ty), i32(mt_w)-4, i32(mt_h)-4, sel ? tcol : COL_BORDER)
        name := mission_type_name(t)
        nw := rl.MeasureText(tprint("%s", name), 15)
        rl.DrawText(tprint("%s", name), i32(tx) + (i32(mt_w)-4-nw)/2, i32(ty)+9, 15, sel ? tcol : COL_TEXT)
        rl.DrawText(tprint("*%d", mission_prestige(t)), i32(tx)+6, i32(ty)+29, 13, COL_GOLD)
        rl.DrawText(tprint("%dmo", mission_duration(t)), i32(tx)+i32(mt_w)-44, i32(ty)+29, 13, COL_DIM)

        mx := i32(rl.GetMouseX()); my := i32(rl.GetMouseY())
        if mx >= i32(tx) && mx <= i32(tx)+i32(mt_w)-4 && my >= i32(ty) && my <= i32(ty)+i32(mt_h)-4 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected = i
        }
    }

    bottom_y := f32(106) + f32(3)*mt_h + 12

    // Rocket selector
    section_line("ROCKET", bottom_y)
    for i in 0..<a.rocket_count {
        r := &a.rockets[i]
        rx := f32(20 + i*222)
        if rx > f32(SCREEN_W)-222 { break }
        sel := gs.selected2 == i
        rl.DrawRectangle(i32(rx), i32(bottom_y)+14, 216, 52, sel ? rl.Color{15,30,60,220} : COL_PANEL)
        rl.DrawRectangleLines(i32(rx), i32(bottom_y)+14, 216, 52, sel ? COL_ACCENT : COL_BORDER)
        rl.DrawText(tprint("%s", r.name), i32(rx)+8, i32(bottom_y)+22, 16, sel ? COL_ACCENT : COL_TEXT)
        rl.DrawText(tprint("%.0f%% rel  %.0fkg PL", r.reliability*100, r.payload_kg), i32(rx)+8, i32(bottom_y)+44, 13, COL_DIM)
        mx := i32(rl.GetMouseX()); my := i32(rl.GetMouseY())
        if mx >= i32(rx) && mx <= i32(rx)+216 && my >= i32(bottom_y)+14 && my <= i32(bottom_y)+66 && rl.IsMouseButtonPressed(.LEFT) {
            gs.selected2 = i
        }
    }

    name_y := bottom_y + 78
    section_line("MISSION NAME", name_y)
    rl.DrawRectangle(20, i32(name_y)+14, 400, 36, COL_PANEL2)
    rl.DrawRectangleLines(20, i32(name_y)+14, 400, 36, COL_ACCENT)
    rl.DrawText(tprint("%s|", string(gs.input_buf[:gs.input_len])), 30, i32(name_y)+22, 18, COL_TEXT)
    char := rl.GetCharPressed()
    for char != 0 {
        if gs.input_len < 32 && char >= 32 { gs.input_buf[gs.input_len] = u8(char); gs.input_len += 1 }
        char = rl.GetCharPressed()
    }
    if rl.IsKeyPressed(.BACKSPACE) && gs.input_len > 0 { gs.input_len -= 1 }

    // Preview
    if gs.selected >= 0 && gs.selected2 >= 0 {
        t := all_types[gs.selected]
        r := &a.rockets[gs.selected2]
        cost := mission_cost(t, r)
        chance := mission_base_chance(t, r, a)
        ccol := a.budget >= cost ? COL_GREEN : COL_RED
        rl.DrawText(tprint("$%dM  |  %.0f%% success  |  %d months  |  *%d prestige",
            cost, chance*100, mission_duration(t), mission_prestige(t)),
            430, i32(name_y)+22, 14, ccol)
    }

    can_plan := gs.selected >= 0 && gs.selected2 >= 0 && gs.input_len > 0 && a.mission_count < 32
    if can_plan && gs.selected >= 0 && gs.selected2 >= 0 {
        t := all_types[gs.selected]
        r := &a.rockets[gs.selected2]
        can_plan = a.budget >= mission_cost(t, r)
    }

    if button("APPROVE MISSION", 20, f32(SCREEN_H)-90, 220, 44, COL_GOLD, !can_plan) {
        t := all_types[gs.selected]
        r := &a.rockets[gs.selected2]
        cost := mission_cost(t, r)
        a.budget -= cost
        r.launches += 1

        m := Mission{
            id             = a.mission_count + 1,
            name           = strings.clone(string(gs.input_buf[:gs.input_len])),
            mission_type   = t,
            status         = .InFlight,
            rocket_id      = r.id,
            launch_month   = a.month,
            duration       = mission_duration(t),
            success_chance = mission_base_chance(t, r, a),
            prestige       = mission_prestige(t),
            science        = mission_prestige(t) / 2,
            cost           = cost,
            destination    = mission_destination(t),
        }
        append_mission_log(&m, fmt.tprintf("Launch: %s %d. Rocket: %s. Chance: %.0f%%",
            month_name(a.month), a.year, r.name, m.success_chance*100))
        a.missions[a.mission_count] = m
        a.mission_count += 1
        a.prestige += 2
        push_notification(gs, fmt.tprintf("Mission launched: %s", m.name))
        gs.screen = .Missions
        gs.selected = -1; gs.selected2 = -1; gs.input_len = 0
    }
    if button("<- CANCEL", 260, f32(SCREEN_H)-90, 130, 44, COL_DIM) {
        gs.screen = .Missions
        gs.selected = -1; gs.selected2 = -1; gs.input_len = 0
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MISSION LOG
// ═══════════════════════════════════════════════════════════════════════════════

draw_mission_log :: proc(gs: ^GameState) {
    a := &gs.agency
    if gs.selected < 0 || gs.selected >= a.mission_count { gs.screen = .Missions; return }
    m := &a.missions[gs.selected]

    label("MISSION LOG", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    scol := mission_status_col(m.status)
    rl.DrawText(tprint("%s", m.name), 20, 96, 26, scol)
    rl.DrawText(tprint("%s  ->  %s", mission_type_name(m.mission_type), m.destination), 20, 126, 16, COL_DIM)

    // Stats panels
    StatItem :: struct { l: string, v: string, c: rl.Color }
    stats := [6]StatItem{
        {"Status",   mission_status_str(m.status),                    scol},
        {"Elapsed",  fmt.tprintf("%d / %d mo", m.elapsed, m.duration),COL_TEXT},
        {"Chance",   fmt.tprintf("%.0f%%", m.success_chance*100),     COL_ACCENT},
        {"Prestige", fmt.tprintf("* %d", m.prestige),                 COL_GOLD},
        {"Science",  fmt.tprintf("S %d", m.science),                  COL_CYAN},
        {"Cost",     fmt.tprintf("$%dM", m.cost),                     COL_RED},
    }
    sw3 := f32(SCREEN_W-40) / 6
    for i in 0..<6 {
        sx := f32(20) + f32(i)*sw3
        rl.DrawRectangle(i32(sx), 150, i32(sw3)-4, 54, COL_PANEL)
        rl.DrawRectangleLines(i32(sx), 150, i32(sw3)-4, 54, COL_BORDER)
        rl.DrawText(tprint("%s", stats[i].l), i32(sx)+8, 160, 13, COL_DIM)
        rl.DrawText(tprint("%s", stats[i].v), i32(sx)+8, 178, 18, stats[i].c)
    }

    if m.status == .InFlight {
        progress := f32(m.elapsed) / f32(max(m.duration, 1))
        rl.DrawRectangle(20, 212, SCREEN_W-40, 18, COL_PANEL2)
        rl.DrawRectangle(20, 212, i32(f32(SCREEN_W-40)*progress), 18, COL_ACCENT)
        rl.DrawRectangleLines(20, 212, SCREEN_W-40, 18, COL_BORDER)
    }

    section_line("FLIGHT LOG", 240)
    for i in 0..<m.log_count {
        idx := m.log_count - 1 - i
        ly := f32(256 + i*22)
        if ly > f32(SCREEN_H)-100 { break }
        lcol := COL_DIM
        entry := m.log[idx]
        if strings.contains(entry, "CRITICAL") || strings.contains(entry, "lost") { lcol = COL_RED }
        if strings.contains(entry, "SUCCESS")  || strings.contains(entry, "returned") { lcol = COL_GREEN }
        rl.DrawText(tprint("%s", entry), 28, i32(ly), 14, lcol)
    }

    if button("<- MISSIONS", 20, f32(SCREEN_H)-90, 200, 44, COL_DIM) { gs.screen = .Missions }
    if m.status == .InFlight || m.status == .ReadyToLaunch {
        if button("ABORT MISSION", f32(SCREEN_W)-220, f32(SCREEN_H)-90, 200, 44, COL_RED) {
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
// RESEARCH
// ═══════════════════════════════════════════════════════════════════════════════

draw_research :: proc(gs: ^GameState) {
    a := &gs.agency
    label("RESEARCH & DEVELOPMENT", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)
    rl.DrawText(tprint("Science Points: %d", a.science_pts), 20, 96, 18, COL_CYAN)

    for i in 0..<a.research_count {
        r := &a.research[i]
        ry := f32(118 + i*86)
        if ry > f32(SCREEN_H)-100 { break }

        in_prog := !r.completed && r.progress > 0
        bg := r.completed ? rl.Color{5,20,10,200} : (in_prog ? rl.Color{15,15,30,200} : COL_PANEL)
        rl.DrawRectangle(20, i32(ry), SCREEN_W-40, 78, bg)
        rl.DrawRectangleLines(20, i32(ry), SCREEN_W-40, 78, r.completed ? COL_GREEN : (in_prog ? COL_ACCENT : COL_BORDER))

        acol := research_area_col(r.area)
        rl.DrawRectangle(20, i32(ry), 6, 78, acol)

        rl.DrawText(tprint("%s", research_area_name(r.area)), 36, i32(ry)+8, 13, acol)
        rl.DrawText(tprint("%s", r.name), 36, i32(ry)+26, 20, r.completed ? COL_GREEN : COL_TEXT)
        rl.DrawText(tprint("%s", r.description), 36, i32(ry)+50, 14, COL_DIM)

        if in_prog {
            prog := f32(r.progress) / f32(r.duration)
            rl.DrawRectangle(500, i32(ry)+20, 300, 14, COL_PANEL2)
            rl.DrawRectangle(500, i32(ry)+20, i32(300*prog), 14, acol)
            rl.DrawRectangleLines(500, i32(ry)+20, 300, 14, COL_BORDER)
            rl.DrawText(tprint("Mo %d/%d", r.progress, r.duration), 808, i32(ry)+22, 13, COL_DIM)
        }

        rl.DrawText(tprint("Unlocks: %s", r.unlock), SCREEN_W-280, i32(ry)+28, 14, acol)
        rl.DrawText(tprint("$%dM  |  %d months", r.cost, r.duration), SCREEN_W-280, i32(ry)+50, 13, COL_DIM)

        if r.completed {
            rl.DrawText("COMPLETE", SCREEN_W-110, i32(ry)+30, 15, COL_GREEN)
        } else if in_prog {
            rl.DrawText("IN PROG.", SCREEN_W-110, i32(ry)+30, 14, COL_ACCENT)
        } else {
            can := a.budget >= r.cost
            if button("FUND", f32(SCREEN_W)-110, ry+18, 80, 34, acol, !can) {
                if can {
                    a.budget -= r.cost
                    r.progress = 1
                    push_notification(gs, fmt.tprintf("Research started: %s", r.name))
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STAR MAP
// ═══════════════════════════════════════════════════════════════════════════════

draw_star_map :: proc(gs: ^GameState) {
    label("SOLAR SYSTEM MAP", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    vx := f32(20)
    vy := f32(96)
    vw := f32(SCREEN_W) * 0.62
    vh := f32(SCREEN_H) - 200

    rl.DrawRectangle(i32(vx), i32(vy), i32(vw), i32(vh), rl.Color{4, 6, 14, 255})
    rl.DrawRectangleLines(i32(vx), i32(vy), i32(vw), i32(vh), COL_BORDER)

    // Sun
    sun_x := vx + vw * 0.10
    sun_y := vy + vh * 0.50
    rl.DrawCircle(i32(sun_x), i32(sun_y), 18, rl.Color{255, 200, 50, 255})
    rl.DrawCircle(i32(sun_x), i32(sun_y), 28, rl.Color{255, 150, 30, 50})
    rl.DrawText("SOL", i32(sun_x)-14, i32(sun_y)+22, 13, COL_GOLD)

    // Bodies
    for i in 0..<gs.body_count {
        b := &gs.bodies[i]
        cx := sun_x
        cy := sun_y
        bx := cx + math.cos_f32(b.orbit_angle) * (vw * b.orbit_r * 0.88)
        by := cy + math.sin_f32(b.orbit_angle) * (vh * b.orbit_r * 0.36)

        // Orbit ellipse
        rl.DrawEllipseLines(i32(cx), i32(cy), vw*b.orbit_r*0.88, vh*b.orbit_r*0.36, rl.Color{28,38,58,80})

        size := f32(6)
        switch b.name {
        case "Jupiter": size = 14
        case "Saturn":  size = 12
        case "Earth","Venus": size = 8
        case "Moon","Phobos","Ceres": size = 4
        }

        col := b.color
        if b.landed       { col = COL_GREEN }
        else if b.orbited { col = COL_CYAN  }
        else if b.probed  { col = COL_GOLD  }

        rl.DrawCircle(i32(bx), i32(by), size, col)
        if b.explored { rl.DrawCircle(i32(bx), i32(by), size+6, rl.Color{col.r, col.g, col.b, 50}) }

        mx := i32(rl.GetMouseX()); my := i32(rl.GetMouseY())
        dist := math.sqrt_f32((f32(mx)-bx)*(f32(mx)-bx) + (f32(my)-by)*(f32(my)-by))
        show_label := dist < 22 || gs.selected == i
        if show_label {
            rl.DrawText(tprint("%s", b.name), i32(bx)+i32(size)+3, i32(by)-7, 13,
                gs.selected == i ? COL_WHITE : COL_DIM)
            if rl.IsMouseButtonPressed(.LEFT) && dist < 22 { gs.selected = i }
        }
    }

    // Legend
    LegItem :: struct { col: rl.Color, lbl: string }
    legend := [4]LegItem{
        {COL_GREEN, "Landed"},
        {COL_CYAN,  "Orbited"},
        {COL_GOLD,  "Probed"},
        {COL_DIM,   "Unexplored"},
    }
    for i in 0..<4 {
        lx := vx + 10
        ly := vy + vh - 22 - f32(i)*18
        rl.DrawCircle(i32(lx)+5, i32(ly)+5, 5, legend[i].col)
        rl.DrawText(tprint("%s", legend[i].lbl), i32(lx)+14, i32(ly)-2, 13, COL_DIM)
    }

    // Info panel
    if gs.selected >= 0 && gs.selected < gs.body_count {
        b := &gs.bodies[gs.selected]
        px := vx + vw + 8
        pw := f32(SCREEN_W) - px - 8
        panel(px, vy, pw, vh, COL_PANEL)
        rl.DrawText(tprint("%s", b.name), i32(px)+12, i32(vy)+14, 26, b.color)

        InfoRow :: struct { l: string, v: string }
        rows := [3]InfoRow{
            {"Distance", fmt.tprintf("%.2f AU", b.distance_au)},
            {"Diameter", fmt.tprintf("%.0f km", b.diameter_km)},
            {"Gravity",  fmt.tprintf("%.2f g",  b.gravity_g)},
        }
        for i in 0..<3 {
            ry2 := f32(i32(vy) + 50 + i32(i)*28)
            rl.DrawText(tprint("%s", rows[i].l), i32(px)+12, i32(ry2), 14, COL_DIM)
            rl.DrawText(tprint("%s", rows[i].v), i32(px)+100, i32(ry2), 14, COL_TEXT)
        }

        section_line("EXPLORATION", f32(vy)+142)
        ExplItem :: struct { l: string, done: bool }
        expls := [4]ExplItem{
            {"Probed",   b.probed},
            {"Orbited",  b.orbited},
            {"Landed",   b.landed},
            {"Explored", b.explored},
        }
        for i in 0..<4 {
            sy := f32(i32(vy) + 152 + i32(i)*26)
            icon := expls[i].done ? "OK" : "  "
            icol := expls[i].done ? COL_GREEN : COL_DIM
            rl.DrawText(tprint("%s", icon), i32(px)+12, i32(sy), 16, icol)
            rl.DrawText(tprint("%s", expls[i].l), i32(px)+36, i32(sy)+2, 15, expls[i].done ? COL_GREEN : COL_DIM)
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FACILITIES
// ═══════════════════════════════════════════════════════════════════════════════

draw_facilities :: proc(gs: ^GameState) {
    a := &gs.agency
    label("SPACE CENTRE FACILITIES", 20, 58, 24, COL_TEXT)
    rl.DrawLine(20, 86, SCREEN_W-20, 86, COL_BORDER)

    facs := [5]FacilityDef{
        {"Launch Pads",       &a.facilities.launch_pads,    4, "Simultaneous launch capacity",      150, COL_ORANGE},
        {"Vehicle Assembly",  &a.facilities.vab_level,      5, "Larger rockets. +1% success/level", 200, COL_ACCENT},
        {"Tracking Network",  &a.facilities.tracking_level, 5, "+2% mission success per level",     120, COL_CYAN},
        {"Research Lab",      &a.facilities.lab_level,      5, "Accelerate R&D projects",           180, COL_PURPLE},
        {"Astronaut Complex", &a.facilities.hab_level,      5, "Training and morale improvement",   100, COL_GREEN},
    }

    for i in 0..<5 {
        f := facs[i]
        fy := f32(96 + i*106)
        panel(20, fy, f32(SCREEN_W)-40, 98, COL_PANEL)
        rl.DrawText(tprint("%s", f.name), 36, i32(fy)+10, 22, COL_TEXT)
        rl.DrawText(tprint("Level %d / %d", f.level^, f.max_level), 36, i32(fy)+36, 16, f.col)
        rl.DrawText(tprint("%s", f.desc), 36, i32(fy)+58, 14, COL_DIM)

        for l in 0..<f.max_level {
            lx := f32(300 + l*36)
            filled := l < f.level^
            rl.DrawRectangle(i32(lx), i32(fy)+30, 30, 20, filled ? rl.Color{f.col.r/3, f.col.g/3, f.col.b/3, 200} : COL_PANEL2)
            rl.DrawRectangleLines(i32(lx), i32(fy)+30, 30, 20, filled ? f.col : COL_BORDER)
            if filled { rl.DrawRectangle(i32(lx)+4, i32(fy)+34, 22, 12, f.col) }
        }

        at_max := f.level^ >= f.max_level
        btn_txt := at_max ? "MAX" : tprint("UPGRADE $%dM", f.upgrade_cost)
        can_up  := !at_max && a.budget >= f.upgrade_cost
        if button(btn_txt, f32(SCREEN_W)-220, fy+28, 200, 40, f.col, !can_up) {
            if can_up {
                a.budget -= f.upgrade_cost
                f.level^ += 1
                a.monthly_income += 3
                push_notification(gs, fmt.tprintf("%s upgraded to Level %d", f.name, f.level^))
            }
        }
    }
}
