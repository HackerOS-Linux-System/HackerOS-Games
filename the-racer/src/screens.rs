use macroquad::prelude::*;
use rand_crate::thread_rng;
use crate::types::*;
use crate::ui::*;
use crate::data::*;
use crate::simulation::simulate_race;
use crate::save::{save_game, load_game};

// ── Main Menu ─────────────────────────────────────────────────────────────────

pub fn draw_main_menu(gs: &mut AppState) {
    clear_background(C_BG);
    let title = "THE RACER";
    let sub   = "MOTORSPORT MANAGEMENT SIMULATOR";
    let tw = measure_text(title, None, 72, 1.0).width;
    let sw2 = measure_text(sub, None, 18, 1.0).width;
    draw_text(title, sw() / 2.0 - tw / 2.0, sh() * 0.28, 72.0, C_ACCENT);
    draw_text(sub, sw() / 2.0 - sw2 / 2.0, sh() * 0.28 + 60.0, 18.0, C_TEXT_DIM);
    draw_line(sw() / 2.0 - 200.0, sh() * 0.38, sw() / 2.0 + 200.0, sh() * 0.38, 1.0, C_BORDER);

    let bw = 260.0; let bh = 46.0; let bx = sw() / 2.0 - bw / 2.0;
    if button("NEW SEASON", bx, sh() * 0.42, bw, bh, C_ACCENT) { gs.screen = Screen::SeriesSelect; }
    if button("CONTINUE",   bx, sh() * 0.42 + 58.0, bw, bh, C_BLUE) {
        if !load_game(gs, &generate_opponents) { gs.show_msg("No save file found."); }
    }
    if button("EXIT", bx, sh() * 0.42 + 116.0, bw, bh, C_TEXT_DIM) { std::process::exit(0); }

    draw_text("v1.1.0", sw() - 60.0, sh() - 10.0, 14.0, C_TEXT_DIM);
    if let Some((ref msg, _)) = gs.msg.clone() {
        let mw = measure_text(msg, None, 18, 1.0).width;
        draw_text(msg, sw() / 2.0 - mw / 2.0, sh() - 40.0, 18.0, C_ACCENT);
    }
}

// ── Series Select ─────────────────────────────────────────────────────────────

pub fn draw_series_select(gs: &mut AppState) {
    clear_background(C_BG);
    label("SELECT CHAMPIONSHIP", 30.0, 50.0, 28.0, C_TEXT);
    draw_line(30.0, 60.0, sw() - 30.0, 60.0, 1.0, C_BORDER);

    let series_list = [
        (Series::Formula1, "Formula 1 — 2026 Season",   "24 rounds, hybrid power, 2026 tech regs"),
        (Series::IndyCar,  "IndyCar Series",             "17 rounds incl. Indy 500, oval + road"),
        (Series::FormulaE, "ABB Formula E",              "16 rounds, pure electric, no tyre pits"),
        (Series::WEC,      "FIA World Endurance Champ.", "8 rounds incl. 24h Le Mans"),
        (Series::GT3,      "GT3 European Series",        "12 rounds, production GT cars"),
    ];
    for (i, (series, name, desc)) in series_list.iter().enumerate() {
        let y = 96.0 + i as f32 * 90.0;
        let col = series.color();
        let selected = gs.selected_series.as_ref() == Some(series);
        draw_rectangle(30.0, y, sw() - 60.0, 80.0,
            if selected { Color::new(col.r, col.g, col.b, 0.10) } else { C_PANEL });
        draw_rectangle_lines(30.0, y, sw() - 60.0, 80.0, 1.5, if selected { col } else { C_BORDER });
        draw_rectangle(30.0, y, 78.0, 80.0, Color::new(col.r, col.g, col.b, 0.15));
        let bw = measure_text(series.short(), None, 18, 1.0).width;
        draw_text(series.short(), 30.0 + (78.0 - bw) / 2.0, y + 48.0, 18.0, col);
        draw_text(name, 124.0, y + 28.0, 20.0, C_TEXT);
        draw_text(desc, 124.0, y + 52.0, 14.0, C_TEXT_DIM);
        draw_text(&format!("{} rounds", series.rounds()), sw() - 110.0, y + 28.0, 15.0, C_TEXT_DIM);
        if series.pit_stops_required() { draw_text("PIT STOPS",  sw() - 110.0, y + 48.0, 12.0, C_GOLD); }
        if series.has_endurance()      { draw_text("ENDURANCE",  sw() - 110.0, y + 62.0, 12.0, C_BLUE); }

        let (mx, my) = mouse_position();
        if mx >= 30.0 && mx <= sw() - 30.0 && my >= y && my <= y + 80.0 && is_mouse_button_pressed(MouseButton::Left) {
            gs.selected_series = Some(series.clone());
        }
    }
    if gs.selected_series.is_some() {
        if button("SELECT & SETUP TEAM  →", sw() / 2.0 - 150.0, sh() - 68.0, 300.0, 46.0, C_ACCENT) {
            gs.screen = Screen::TeamSetup;
            gs.setup_step = 0;
            gs.input_buf.clear();
        }
    }
    if button("← BACK", 30.0, sh() - 68.0, 120.0, 40.0, C_TEXT_DIM) { gs.screen = Screen::MainMenu; }
}

// ── Team Setup ────────────────────────────────────────────────────────────────

pub fn draw_team_setup(gs: &mut AppState) {
    clear_background(C_BG);
    label("TEAM SETUP", 30.0, 50.0, 28.0, C_TEXT);
    draw_line(30.0, 60.0, sw() - 30.0, 60.0, 1.0, C_BORDER);

    let prompts = ["Team Name:", "Driver 1 Name:", "Driver 2 Name:"];
    let step = gs.setup_step;

    for (i, prompt) in prompts.iter().enumerate() {
        let y = 130.0 + i as f32 * 90.0;
        let done   = i < step;
        let active = i == step;
        let val = match i { 0 => &gs.setup_name, 1 => &gs.setup_driver1, _ => &gs.setup_driver2 };
        draw_text(prompt, 100.0, y, 20.0, if active { C_TEXT } else { C_TEXT_DIM });
        draw_rectangle(100.0, y + 10.0, 400.0, 36.0, if active { C_PANEL2 } else { C_PANEL });
        draw_rectangle_lines(100.0, y + 10.0, 400.0, 36.0, 1.5, if active { C_ACCENT } else { C_BORDER });
        let display = if active { format!("{}|", gs.input_buf) } else { val.clone() };
        draw_text(&display, 108.0, y + 33.0, 20.0, if done { C_GREEN } else { C_TEXT });
    }

    if step < 3 {
        while let Some(c) = get_char_pressed() {
            if c == '\r' || c == '\n' {
                if !gs.input_buf.trim().is_empty() {
                    let val = gs.input_buf.trim().to_string();
                    match step { 0 => gs.setup_name = val, 1 => gs.setup_driver1 = val, _ => gs.setup_driver2 = val }
                    gs.input_buf.clear();
                    gs.setup_step += 1;
                }
            } else if c == '\x08' { gs.input_buf.pop(); }
            else if (c.is_ascii_graphic() || c == ' ') && gs.input_buf.len() < 24 { gs.input_buf.push(c); }
        }
    }

    if gs.setup_step >= 3 {
        draw_text("✓ All set! Ready to start season.", 100.0, 400.0, 20.0, C_GREEN);
        if button("START SEASON  →", sw() / 2.0 - 130.0, sh() - 80.0, 260.0, 46.0, C_ACCENT) {
            let series = gs.selected_series.clone().unwrap_or(Series::Formula1);
            let team = new_team(gs.setup_name.clone(), gs.setup_driver1.clone(), gs.setup_driver2.clone(), series.clone());
            gs.opponents = generate_opponents(&series);
            gs.team = Some(team);
            gs.screen = Screen::Dashboard;
            gs.tab = 0;
        }
    }
    if button("← BACK", 30.0, sh() - 80.0, 120.0, 40.0, C_TEXT_DIM) { gs.screen = Screen::SeriesSelect; }
}

// ── Dashboard ─────────────────────────────────────────────────────────────────

pub fn draw_dashboard(gs: &mut AppState, circuits: &[Circuit]) {
    let team = gs.team.as_ref().unwrap();
    clear_background(C_BG);
    topbar(team, circuits);

    let next = if team.current_round < circuits.len() { Some(&circuits[team.current_round]) } else { None };
    let cy = 66.0;
    if let Some(c) = next {
        panel(16.0, cy, sw() - 32.0, 106.0, C_PANEL);
        draw_text("NEXT RACE", 30.0, cy + 22.0, 13.0, C_TEXT_DIM);
        draw_text(&c.name, 30.0, cy + 54.0, 30.0, C_TEXT);
        draw_text(&c.country, 30.0 + measure_text(&c.name, None, 30, 1.0).width + 10.0, cy + 54.0, 18.0, C_TEXT_DIM);
        draw_text(&format!("{} laps", c.laps), 30.0, cy + 80.0, 14.0, C_TEXT_DIM);
        let wx = sw() - 200.0;
        let weather = if c.wet_chance > 0.35 { ("LIKELY RAIN", C_BLUE) } else if c.wet_chance > 0.15 { ("POSSIBLE RAIN", C_GOLD) } else { ("DRY", C_GREEN) };
        draw_text("WEATHER", wx, cy + 22.0, 13.0, C_TEXT_DIM);
        draw_text(weather.0, wx, cy + 54.0, 20.0, weather.1);
        draw_text(&format!("{:.0}% rain", c.wet_chance * 100.0), wx, cy + 78.0, 13.0, C_TEXT_DIM);
        if c.high_speed { draw_text("HIGH-SPEED CIRCUIT", sw() / 2.0 - 80.0, cy + 54.0, 14.0, C_BLUE); }
        if team.series.pit_stops_required() {
            draw_text(&format!("Pit delta: {:.0}s", c.pit_delta), sw() / 2.0 - 60.0, cy + 78.0, 13.0, C_GOLD);
        }
    } else {
        panel(16.0, cy, sw() - 32.0, 106.0, C_PANEL);
        draw_text("SEASON COMPLETE — Champions crowned!", 30.0, cy + 58.0, 26.0, C_GOLD);
    }

    // Driver cards
    let dy = cy + 124.0;
    section_header("DRIVERS", dy);
    for (i, driver) in [&team.driver1, &team.driver2].iter().enumerate() {
        let dx = 16.0 + i as f32 * (sw() / 2.0 - 20.0);
        let dw = sw() / 2.0 - 24.0;
        panel(dx, dy + 14.0, dw, 140.0, C_PANEL);
        draw_text(&driver.name, dx + 12.0, dy + 40.0, 20.0, C_TEXT);
        draw_text(&format!("OVR {}", driver.overall()), dx + dw - 70.0, dy + 40.0, 19.0, C_ACCENT);
        draw_text(&format!("Age {} • {} • {} career wins", driver.age, driver.nationality, driver.career_wins), dx + 12.0, dy + 58.0, 12.0, C_TEXT_DIM);
        stat_bar("PACE",  driver.pace,        dx + 12.0, dy + 72.0, dw - 24.0, C_ACCENT);
        stat_bar("CONSS", driver.consistency, dx + 12.0, dy + 90.0, dw - 24.0, C_BLUE);
        stat_bar("WET",   driver.wet_skill,   dx + 12.0, dy + 108.0, dw - 24.0, Color::new(0.3, 0.7, 1.0, 1.0));
        let mc = if driver.morale > 20 { C_GREEN } else if driver.morale > -20 { C_GOLD } else { C_ACCENT };
        draw_text(&format!("Morale {} • {} races", driver.morale, driver.races), dx + 12.0, dy + 136.0, 12.0, mc);
    }

    // Car
    let cary = dy + 172.0;
    section_header("CAR PERFORMANCE", cary);
    panel(16.0, cary + 14.0, sw() - 32.0, 80.0, C_PANEL);
    let cw = (sw() - 32.0) / 5.0;
    let car = &team.car;
    for (i, (name, val, col)) in [
        ("CHASSIS", car.chassis, C_ACCENT), ("ENGINE", car.engine, C_GOLD),
        ("RELIABILITY", car.reliability, C_GREEN), ("TIRE DEG", car.tire_deg, C_BLUE),
        ("PIT SPEED", car.pit_speed, C_SILVER),
    ].iter().enumerate() {
        stat_bar(name, *val, 16.0 + i as f32 * cw + 4.0, cary + 28.0, cw - 8.0, *col);
    }
    draw_text(&format!("Car Overall: {}  •  Aero Balance: {}/100", car.performance(), car.aero_balance),
        30.0, cary + 80.0, 14.0, C_TEXT_DIM);

    // Recent results
    let ry = cary + 108.0;
    section_header("RECENT RESULTS", ry);
    for (i, r) in team.race_results.iter().rev().take(3).enumerate() {
        let rwy = ry + 20.0 + i as f32 * 42.0;
        panel(16.0, rwy, sw() - 32.0, 36.0, C_PANEL);
        draw_text(&format!("R{} {}", r.round, r.circuit), 28.0, rwy + 22.0, 15.0, C_TEXT_DIM);
        position_badge(r.driver1_pos, 200.0, rwy + 7.0);
        position_badge(r.driver2_pos, 244.0, rwy + 7.0);
        draw_text(&format!("+{} pts", r.driver1_points + r.driver2_points), 296.0, rwy + 22.0, 15.0, C_GOLD);
        if r.wet_race    { draw_text("WET", sw() - 80.0, rwy + 22.0, 13.0, C_BLUE); }
        if r.fastest_lap { draw_text("FL",  sw() - 48.0, rwy + 22.0, 13.0, Color::new(0.6, 0.2, 0.9, 1.0)); }
    }
}

// ── Roster ────────────────────────────────────────────────────────────────────

pub fn draw_roster(gs: &mut AppState) {
    let team = gs.team.as_ref().unwrap();
    clear_background(C_BG);
    topbar(team, &[]);
    label("DRIVER ROSTER", 30.0, 80.0, 24.0, C_TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, C_BORDER);

    for (i, driver) in [&team.driver1, &team.driver2].iter().enumerate() {
        let dy = 110.0 + i as f32 * 245.0;
        panel(16.0, dy, sw() - 32.0, 230.0, C_PANEL);
        draw_text(&format!("DRIVER {}", i + 1), 30.0, dy + 22.0, 13.0, C_TEXT_DIM);
        draw_text(&driver.name, 30.0, dy + 52.0, 26.0, C_TEXT);
        draw_text(&format!("{} • Age {} • {} career wins • {} races",
            driver.nationality, driver.age, driver.career_wins, driver.races),
            30.0, dy + 74.0, 13.0, C_TEXT_DIM);

        let hw = (sw() - 64.0) / 2.0;
        stat_bar("PACE",        driver.pace,        30.0, dy + 92.0,  hw, C_ACCENT);
        stat_bar("CONSISTENCY", driver.consistency, 30.0, dy + 112.0, hw, C_BLUE);
        stat_bar("WET SKILL",   driver.wet_skill,   30.0, dy + 132.0, hw, Color::new(0.3, 0.7, 1.0, 1.0));
        stat_bar("TIRE MGMT",   driver.tire_mgmt,   sw() / 2.0, dy + 92.0,  hw, C_GOLD);
        stat_bar("EXPERIENCE",  driver.experience,  sw() / 2.0, dy + 112.0, hw, C_GREEN);

        draw_text(&format!("Overall: {}", driver.overall()), 30.0, dy + 162.0, 18.0, C_ACCENT);
        draw_text(&format!("Salary: ${:.1}M/season", driver.salary as f32 / 1000.0), 200.0, dy + 162.0, 14.0, C_TEXT_DIM);
        draw_text(&format!("Contract: {} year(s)", driver.contract_years), 400.0, dy + 162.0, 14.0, C_TEXT_DIM);
        let mc = if driver.morale > 20 { C_GREEN } else if driver.morale > -20 { C_GOLD } else { C_ACCENT };
        draw_text(&format!("Morale: {}", driver.morale), 30.0, dy + 188.0, 14.0, mc);
        draw_text(&format!("Tire Mgmt: {}", driver.tire_mgmt), 180.0, dy + 188.0, 14.0, C_TEXT_DIM);
    }
}

// ── Car Dev ───────────────────────────────────────────────────────────────────

pub fn draw_car_dev(gs: &mut AppState) {
    let team = gs.team.as_mut().unwrap();
    clear_background(C_BG);
    topbar(team, &[]);
    label("CAR DEVELOPMENT", 30.0, 80.0, 24.0, C_TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, C_BORDER);

    let car = &team.car;
    let y0 = 106.0;
    for (i, (name, val, col)) in [
        ("CHASSIS", car.chassis, C_ACCENT), ("ENGINE", car.engine, C_GOLD),
        ("RELIABILITY", car.reliability, C_GREEN), ("TIRE DEG", car.tire_deg, C_BLUE),
        ("PIT SPEED", car.pit_speed, C_SILVER),
    ].iter().enumerate() {
        stat_bar(name, *val, 30.0, y0 + i as f32 * 26.0, sw() - 60.0, *col);
    }
    draw_text(&format!("Aero Balance: {}/100  (0=understeer, 100=oversteer)", car.aero_balance),
        30.0, y0 + 140.0, 14.0, C_TEXT_DIM);

    section_header("START R&D PROJECT", y0 + 162.0);

    let projects: &[(&str, &str, &str, u32, u8, u8)] = &[
        ("Aero Package",       "chassis",      "Improved downforce",         3500, 3, 5),
        ("Engine Tokens",      "engine",       "Power unit upgrade",         5000, 4, 7),
        ("Reliability Fix",    "reliability",  "Reduce DNF risk",            2000, 2, 4),
        ("Tire Compounds",     "tire_deg",     "Softer deg curves",          2500, 3, 4),
        ("Pitstop Equipment",  "pit_speed",    "Faster wheel guns",          1500, 2, 3),
        ("Floor Revision",     "chassis",      "Underfloor ground effect",   4000, 3, 6),
        ("ERS Upgrade",        "engine",       "Harvest/deploy efficiency",  4500, 3, 5),
        ("Aero Balance Shift", "aero_balance", "Tune high/low speed bias",   2000, 2, 5),
    ];

    let team = gs.team.as_mut().unwrap();
    for (i, (name, target, desc, cost, dur, boost)) in projects.iter().enumerate() {
        let py = y0 + 178.0 + i as f32 * 52.0;
        let already = team.rd_projects.iter().any(|p| p.name == *name);
        let can_afford = team.budget >= *cost;

        panel(16.0, py, sw() - 32.0, 46.0, C_PANEL);
        draw_text(name, 30.0, py + 18.0, 16.0, C_TEXT);
        draw_text(desc, 30.0, py + 36.0, 12.0, C_TEXT_DIM);
        let stat_col = if already { C_TEXT_DIM } else if can_afford { C_GREEN } else { C_ACCENT };
        draw_text(&format!("→ {} +{}", target, boost), 320.0, py + 18.0, 14.0, stat_col);
        draw_text(&format!("{} races", dur), 460.0, py + 18.0, 14.0, C_TEXT_DIM);
        draw_text(&format!("${:.1}M", *cost as f32 / 1000.0), 540.0, py + 18.0, 14.0, if can_afford { C_GREEN } else { C_ACCENT });

        if !already {
            if icon_button("START", sw() - 100.0, py + 8.0, 80.0, 28.0, if can_afford { C_GREEN } else { C_TEXT_DIM }, can_afford) {
                team.budget -= cost;
                team.rd_projects.push(RdProject {
                    name: name.to_string(), target: target.to_string(),
                    cost: *cost, duration: *dur, boost: *boost,
                });
            }
        } else if let Some(p) = team.rd_projects.iter().find(|p| p.name == *name) {
            draw_text(&format!("{} races left", p.duration), sw() - 120.0, py + 22.0, 13.0, C_GOLD);
        }
    }
}

// ── Standings ─────────────────────────────────────────────────────────────────

pub fn draw_standings(gs: &mut AppState, circuits: &[Circuit]) {
    let team = gs.team.as_ref().unwrap();
    clear_background(C_BG);
    topbar(team, circuits);
    label("CONSTRUCTORS STANDINGS", 30.0, 80.0, 24.0, C_TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, C_BORDER);

    let mut all: Vec<(String, u32, Color)> = Vec::new();
    all.push((team.name.clone(), team.standings_points, C_ACCENT));
    for opp in &gs.opponents { all.push((opp.name.clone(), opp.points, opp.color())); }
    all.sort_by(|a, b| b.1.cmp(&a.1));

    for (i, (name, pts, col)) in all.iter().enumerate() {
        let y = 106.0 + i as f32 * 44.0;
        let is_player = name == &team.name;
        draw_rectangle(16.0, y, sw() - 32.0, 38.0,
            if is_player { Color::new(col.r, col.g, col.b, 0.08) } else { C_PANEL });
        draw_rectangle_lines(16.0, y, sw() - 32.0, 38.0, 1.0, if is_player { *col } else { C_BORDER });

        let pos_col = match i { 0 => C_GOLD, 1 => C_SILVER, 2 => C_BRONZE, _ => C_TEXT_DIM };
        draw_text(&format!("{}", i + 1), 28.0, y + 25.0, 18.0, pos_col);
        draw_rectangle(52.0, y + 6.0, 4.0, 26.0, *col);
        draw_text(name, 64.0, y + 25.0, 17.0, if is_player { C_TEXT } else { C_TEXT_DIM });
        if is_player { draw_text("◄ YOU", 64.0 + measure_text(name, None, 17, 1.0).width + 8.0, y + 25.0, 12.0, *col); }

        let max_pts = all.first().map(|a| a.1).unwrap_or(1).max(1);
        let bar_w = (sw() - 310.0) * (*pts as f32 / max_pts as f32);
        draw_rectangle(200.0, y + 10.0, bar_w, 18.0, Color::new(col.r, col.g, col.b, 0.3));
        draw_text(&format!("{} pts", pts), sw() - 90.0, y + 25.0, 17.0, if is_player { C_GOLD } else { C_TEXT_DIM });
    }
}

// ── Contract Market ───────────────────────────────────────────────────────────

pub fn draw_contract_market(gs: &mut AppState) {
    clear_background(C_BG);
    if let Some(ref t) = gs.team { topbar(t, &[]); }
    label("CONTRACT MARKET", 30.0, 80.0, 24.0, C_TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, C_BORDER);
    draw_text("Sign a free agent to replace your current drivers.", 30.0, 112.0, 14.0, C_TEXT_DIM);

    if let Some(ref msg) = gs.contract_msg.clone() {
        let mw = measure_text(msg, None, 18, 1.0).width;
        draw_text(msg, sw() / 2.0 - mw / 2.0, 134.0, 18.0, C_GREEN);
    }

    let agents = free_agents();
    for (i, agent) in agents.iter().enumerate() {
        let y = 150.0 + i as f32 * 58.0;
        panel(16.0, y, sw() - 32.0, 52.0, C_PANEL);
        draw_text(&agent.name, 30.0, y + 20.0, 16.0, C_TEXT);
        draw_text(&format!("{} • Age {} • OVR {}", agent.nationality, agent.age, agent.overall()),
            30.0, y + 38.0, 13.0, C_TEXT_DIM);
        stat_bar("PACE", agent.pace, 220.0, y + 14.0, 280.0, C_ACCENT);
        draw_text(&format!("${:.1}M/yr", agent.salary as f32 / 1000.0), sw() - 200.0, y + 22.0, 14.0, C_GREEN);

        let team = gs.team.as_ref().unwrap();
        let can_afford = team.budget >= agent.salary;
        if icon_button("SIGN D1", sw() - 160.0, y + 8.0, 70.0, 26.0, C_BLUE, can_afford) {
            let new_driver = agents[i].clone();
            let team = gs.team.as_mut().unwrap();
            team.budget -= agent.salary;
            team.driver1 = new_driver;
            gs.contract_msg = Some(format!("✓ {} signed as Driver 1!", agents[i].name));
        }
        if icon_button("SIGN D2", sw() - 84.0, y + 8.0, 70.0, 26.0, C_GOLD, can_afford) {
            let new_driver = agents[i].clone();
            let team = gs.team.as_mut().unwrap();
            team.budget -= agent.salary;
            team.driver2 = new_driver;
            gs.contract_msg = Some(format!("✓ {} signed as Driver 2!", agents[i].name));
        }
    }
    if button("← BACK", 30.0, sh() - 60.0, 120.0, 40.0, C_TEXT_DIM) {
        gs.screen = Screen::Dashboard;
        gs.tab = 0;
        gs.contract_msg = None;
    }
}

// ── Race Weekend ──────────────────────────────────────────────────────────────

pub fn draw_race_weekend(gs: &mut AppState, circuits: &[Circuit]) {
    let team = gs.team.as_ref().unwrap();
    let circuit = &circuits[team.current_round.min(circuits.len() - 1)];
    clear_background(C_BG);
    topbar(team, circuits);
    label(&format!("RACE WEEKEND — {}", circuit.name), 30.0, 80.0, 24.0, C_TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, C_BORDER);

    let wet_label = if gs.race_state.wet { ("WET RACE", C_BLUE) } else { ("DRY RACE", C_GREEN) };
    draw_text("CONDITIONS:", 30.0, 114.0, 14.0, C_TEXT_DIM);
    draw_text(wet_label.0, 130.0, 114.0, 16.0, wet_label.1);

    // Practice
    panel(16.0, 128.0, sw() - 32.0, 72.0, C_PANEL);
    draw_text("PRACTICE SESSION", 30.0, 148.0, 16.0, C_TEXT);
    if !gs.race_state.practice_done {
        draw_text("Run practice to gather tyre data and baseline lap times.", 30.0, 170.0, 13.0, C_TEXT_DIM);
        if button("RUN PRACTICE", sw() - 198.0, 138.0, 170.0, 32.0, C_BLUE) {
            gs.race_state.practice_done = true;
            let mut rng = thread_rng();
            gs.race_state.wet = rand_crate::Rng::gen::<f32>(&mut rng) < circuit.wet_chance;
        }
    } else {
        draw_text("✓ Practice complete", 30.0, 170.0, 14.0, C_GREEN);
        draw_text(if gs.race_state.wet { "Conditions: WET" } else { "Conditions: DRY" },
            220.0, 170.0, 14.0, if gs.race_state.wet { C_BLUE } else { C_TEXT_DIM });
    }

    // Qualifying
    panel(16.0, 212.0, sw() - 32.0, 72.0, C_PANEL);
    draw_text("QUALIFYING", 30.0, 232.0, 16.0, C_TEXT);
    if !gs.race_state.qualifying_done {
        let avail = gs.race_state.practice_done;
        draw_text(if avail { "Set your fastest lap to determine grid position." }
            else { "Complete practice first." }, 30.0, 252.0, 13.0, C_TEXT_DIM);
        if icon_button("RUN QUALIFYING", sw() - 198.0, 222.0, 170.0, 32.0, C_GOLD, avail) {
            gs.race_state.qualifying_done = true;
            let mut rng = thread_rng();
            let team = gs.team.as_ref().unwrap();
            let q1 = (team.driver1.pace as f32 + rand_crate::Rng::gen_range(&mut rng, -8.0..8.0) + team.car.performance() as f32 * 0.3) as i32;
            let q2 = (team.driver2.pace as f32 + rand_crate::Rng::gen_range(&mut rng, -8.0..8.0) + team.car.performance() as f32 * 0.3) as i32;
            gs.race_state.qualifying_pos1 = (20 - (q1 - 30).clamp(0, 19) as u8).max(1);
            gs.race_state.qualifying_pos2 = (20 - (q2 - 28).clamp(0, 19) as u8).max(1);
        }
    } else {
        let team = gs.team.as_ref().unwrap();
        draw_text(&format!("P{} — {}", gs.race_state.qualifying_pos1, team.driver1.name), 30.0, 248.0, 14.0, C_TEXT);
        draw_text(&format!("P{} — {}", gs.race_state.qualifying_pos2, team.driver2.name), 30.0, 266.0, 14.0, C_TEXT);
    }

    // Strategy (only for pit-stop series)
    let team = gs.team.as_ref().unwrap();
    if gs.race_state.qualifying_done && team.series.pit_stops_required() {
        panel(16.0, 296.0, sw() - 32.0, 132.0, C_PANEL);
        draw_text("PIT STRATEGY", 30.0, 316.0, 16.0, C_TEXT);

        let compounds: Vec<TireCompound> = if gs.race_state.wet {
            vec![TireCompound::Inter, TireCompound::Wet]
        } else {
            vec![TireCompound::Soft, TireCompound::Medium, TireCompound::Hard]
        };

        for (driver_idx, y_off) in [(0usize, 330.0f32), (1usize, 388.0f32)] {
            let driver_name = if driver_idx == 0 { team.driver1.name.clone() } else { team.driver2.name.clone() };
            draw_text(&format!("{}:", driver_name), 30.0, y_off - 2.0, 13.0, C_TEXT_DIM);
            let mut cx = 160.0;
            for c in &compounds {
                let selected = if driver_idx == 0 { gs.race_state.strategy1 == *c } else { gs.race_state.strategy2 == *c };
                let col = c.color();
                draw_rectangle(cx, y_off - 14.0, 60.0, 22.0,
                    if selected { Color::new(col.r, col.g, col.b, 0.3) } else { C_PANEL2 });
                draw_rectangle_lines(cx, y_off - 14.0, 60.0, 22.0, 1.0,
                    if selected { col } else { C_BORDER });
                let tw = measure_text(c.name(), None, 12, 1.0).width;
                draw_text(c.name(), cx + (60.0 - tw) / 2.0, y_off + 4.0, 12.0, col);
                let (mx, my) = mouse_position();
                if mx >= cx && mx <= cx + 60.0 && my >= y_off - 14.0 && my <= y_off + 8.0
                    && is_mouse_button_pressed(MouseButton::Left) {
                    if driver_idx == 0 { gs.race_state.strategy1 = *c; } else { gs.race_state.strategy2 = *c; }
                }
                cx += 66.0;
            }
            // Pit lap
            let lap_txt = if driver_idx == 0 { format!("Lap {}", gs.race_state.pit_lap1) }
                else { format!("Lap {}", gs.race_state.pit_lap2) };
            draw_text("Pit lap:", 30.0, y_off + 26.0, 13.0, C_TEXT_DIM);
            draw_text(&lap_txt, 100.0, y_off + 26.0, 14.0, C_GOLD);
            if button("-", 152.0, y_off + 12.0, 24.0, 20.0, C_TEXT_DIM) {
                if driver_idx == 0 && gs.race_state.pit_lap1 > 5 { gs.race_state.pit_lap1 -= 1; }
                else if driver_idx == 1 && gs.race_state.pit_lap2 > 5 { gs.race_state.pit_lap2 -= 1; }
            }
            if button("+", 180.0, y_off + 12.0, 24.0, 20.0, C_TEXT_DIM) {
                let max_lap = circuit.laps.saturating_sub(5);
                if driver_idx == 0 && gs.race_state.pit_lap1 < max_lap { gs.race_state.pit_lap1 += 1; }
                else if driver_idx == 1 && gs.race_state.pit_lap2 < max_lap { gs.race_state.pit_lap2 += 1; }
            }
        }
    }

    let ry = if team.series.pit_stops_required() { sh() - 70.0 } else { 460.0 };
    if gs.race_state.qualifying_done {
        if button("⚑  START RACE", sw() / 2.0 - 140.0, ry, 280.0, 50.0, C_ACCENT) {
            gs.screen = Screen::RaceSimulation;
            gs.race_state.sim_progress = 0.0;
            gs.race_state.sim_done = false;
            gs.race_state.log.clear();
        }
    } else {
        draw_text("Complete qualifying to unlock race start.", sw() / 2.0 - 180.0, ry + 20.0, 14.0, C_TEXT_DIM);
    }
}

// ── Race Simulation ───────────────────────────────────────────────────────────

pub fn draw_race_simulation(gs: &mut AppState, circuits: &[Circuit]) {
    clear_background(C_BG);
    draw_text("RACE IN PROGRESS", 30.0, 50.0, 26.0, C_ACCENT);
    draw_line(30.0, 62.0, sw() - 30.0, 62.0, 1.0, C_BORDER);

    let (circuit_name, total_laps) = {
        let team = gs.team.as_ref().unwrap();
        let c = &circuits[team.current_round.min(circuits.len() - 1)];
        (c.name.clone(), c.laps as f32)
    };
    draw_text(&circuit_name, 30.0, 88.0, 18.0, C_TEXT_DIM);

    draw_rectangle(30.0, 106.0, sw() - 60.0, 16.0, C_PANEL2);
    draw_rectangle(30.0, 106.0, (sw() - 60.0) * gs.race_state.sim_progress, 16.0, C_ACCENT);
    draw_rectangle_lines(30.0, 106.0, sw() - 60.0, 16.0, 1.0, C_BORDER);
    draw_text(&format!("{:.0}%", gs.race_state.sim_progress * 100.0),
        sw() / 2.0 - 16.0, 120.0, 13.0, C_TEXT);

    if !gs.race_state.sim_done {
        gs.race_state.sim_progress += get_frame_time() * 0.45;
        if gs.race_state.sim_progress >= 1.0 {
            gs.race_state.sim_progress = 1.0;
            gs.race_state.sim_done = true;
            let mut rng = thread_rng();
            let rs = gs.race_state.clone();
            let circuits_c = circuits.to_vec();
            let result = {
                let team = gs.team.as_mut().unwrap();
                simulate_race(team, &mut gs.opponents, &rs, &circuits_c, &mut rng)
            };
            let team = gs.team.as_ref().unwrap();
            gs.race_state.log.push(format!("RACE OVER — {}", circuit_name));
            gs.race_state.log.push(format!("{} finished P{} (+{} pts)", team.driver1.name, result.driver1_pos, result.driver1_points));
            gs.race_state.log.push(format!("{} finished P{} (+{} pts)", team.driver2.name, result.driver2_pos, result.driver2_points));
            for pit in &result.pit_stops { gs.race_state.log.push(pit.clone()); }
            if let Some(dnf) = result.dnf_driver {
                let n = if dnf == 1 { &team.driver1.name } else { &team.driver2.name };
                gs.race_state.log.push(format!("⚠ DNF — {} retired", n));
            }
            if result.fastest_lap { gs.race_state.log.push("★ Fastest lap bonus point".into()); }
            gs.race_state.result = Some(result.clone());
            let team = gs.team.as_mut().unwrap();
            team.race_results.push(result);
            save_game(gs);
        }

        let cur_lap = (gs.race_state.sim_progress * total_laps) as u32;
        draw_text(&format!("LAP {} / {}", cur_lap, total_laps as u32), sw() / 2.0 - 40.0, 156.0, 20.0, C_GOLD);
        if (cur_lap as u16) == gs.race_state.pit_lap1 { draw_text("⬛ DRIVER 1 IN THE PITS", 30.0, 184.0, 16.0, C_GOLD); }
        if (cur_lap as u16) == gs.race_state.pit_lap2 { draw_text("⬛ DRIVER 2 IN THE PITS", 30.0, 206.0, 16.0, C_GOLD); }
    } else {
        for (i, line) in gs.race_state.log.iter().enumerate() {
            let col = if i == 0 { C_GOLD } else if line.starts_with("⚠") { C_ACCENT }
                else if line.starts_with("★") { Color::new(0.7, 0.3, 0.9, 1.0) } else { C_TEXT };
            draw_text(line, 30.0, 156.0 + i as f32 * 28.0, 17.0, col);
        }
        if button("VIEW RESULTS  →", sw() / 2.0 - 130.0, sh() - 80.0, 260.0, 50.0, C_ACCENT) {
            gs.screen = Screen::Results;
        }
    }
}

// ── Results ───────────────────────────────────────────────────────────────────

pub fn draw_results(gs: &mut AppState, circuits: &[Circuit]) {
    clear_background(C_BG);
    let team = gs.team.as_ref().unwrap();

    if let Some(ref r) = gs.race_state.result.clone() {
        draw_text(&format!("RACE RESULTS — {}", r.circuit), 30.0, 50.0, 24.0, C_TEXT);
        draw_line(30.0, 62.0, sw() - 30.0, 62.0, 1.0, C_BORDER);

        for (i, (pos, pts, name)) in [
            (r.driver1_pos, r.driver1_points, &team.driver1.name),
            (r.driver2_pos, r.driver2_points, &team.driver2.name),
        ].iter().enumerate() {
            let dy = 78.0 + i as f32 * 86.0;
            panel(16.0, dy, sw() - 32.0, 76.0, C_PANEL);
            position_badge(*pos, 26.0, dy + 26.0);
            draw_text(name, 76.0, dy + 30.0, 20.0, C_TEXT);
            draw_text(&format!("+{} pts", pts), 76.0, dy + 54.0, 16.0, C_GOLD);
            if r.wet_race { tire_badge(TireCompound::Wet, 300.0, dy + 28.0); }
            if let Some(dnf) = r.dnf_driver {
                if dnf as usize == i + 1 { draw_text("DNF", sw() - 80.0, dy + 42.0, 20.0, C_ACCENT); }
            }
        }

        let py = 260.0;
        section_header("PIT STOPS", py);
        for (i, line) in r.pit_stops.iter().enumerate() {
            draw_text(line, 30.0, py + 22.0 + i as f32 * 20.0, 14.0, C_TEXT_DIM);
        }

        let sy = 350.0;
        section_header("TEAM SUMMARY", sy);
        panel(16.0, sy + 14.0, sw() - 32.0, 88.0, C_PANEL);
        draw_text(&format!("Total Points: {}", team.standings_points), 30.0, sy + 38.0, 18.0, C_GOLD);
        draw_text(&format!("Budget: ${:.1}M", team.budget as f32 / 1000.0), 30.0, sy + 62.0, 16.0, C_GREEN);
        draw_text(&format!("Round: {}/{}", team.current_round, circuits.len()), 300.0, sy + 38.0, 16.0, C_TEXT_DIM);
    }

    let btn_label = if gs.team.as_ref().unwrap().current_round >= circuits.len() { "SEASON OVER — MENU" } else { "NEXT ROUND  →" };
    if button(btn_label, sw() / 2.0 - 140.0, sh() - 70.0, 280.0, 50.0, C_ACCENT) {
        let at_end = gs.team.as_ref().unwrap().current_round >= circuits.len();
        if at_end { gs.screen = Screen::MainMenu; gs.team = None; }
        else { gs.race_state = RaceWeekendState::default(); gs.screen = Screen::Dashboard; gs.tab = 0; }
    }
}
