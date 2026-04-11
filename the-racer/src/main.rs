#![allow(dead_code)]
#![allow(unused_parens)]
extern crate rand as rand_crate;
use macroquad::prelude::*;
use serde::{Deserialize, Serialize};
use std::fs;
use rand_crate::Rng;
use rand_crate::thread_rng;


// ═══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════

const SAVE_FILE: &str = "the-racer-save.json";
const BG: Color       = Color::new(0.04, 0.04, 0.08, 1.0);
const PANEL: Color    = Color::new(0.08, 0.08, 0.14, 1.0);
const PANEL2: Color   = Color::new(0.11, 0.11, 0.19, 1.0);
const ACCENT: Color   = Color::new(0.95, 0.15, 0.10, 1.0);   // F1 red
const GOLD: Color     = Color::new(1.00, 0.80, 0.00, 1.0);
const SILVER: Color   = Color::new(0.75, 0.75, 0.80, 1.0);
const BRONZE: Color   = Color::new(0.80, 0.50, 0.20, 1.0);
const GREEN: Color    = Color::new(0.10, 0.90, 0.30, 1.0);
const BLUE: Color     = Color::new(0.20, 0.60, 1.00, 1.0);
const TEXT: Color     = Color::new(0.90, 0.90, 0.95, 1.0);
const TEXT_DIM: Color = Color::new(0.45, 0.50, 0.58, 1.0);
const BORDER: Color   = Color::new(0.18, 0.20, 0.28, 1.0);

// ═══════════════════════════════════════════════════════════════════════════════
// DATA TYPES
// ═══════════════════════════════════════════════════════════════════════════════

#[derive(Clone, Serialize, Deserialize, PartialEq)]
enum Series {
    Formula1,
    IndyCar,
    FormulaE,
    WEC,
    GT3,
}

impl Series {
    fn name(&self) -> &str {
        match self {
            Series::Formula1  => "Formula 1 — 2026 Season",
            Series::IndyCar   => "IndyCar Series",
            Series::FormulaE  => "Formula E",
            Series::WEC       => "FIA World Endurance Championship",
            Series::GT3       => "GT3 European Series",
        }
    }
    fn short(&self) -> &str {
        match self {
            Series::Formula1 => "F1",
            Series::IndyCar  => "IndyCar",
            Series::FormulaE => "FE",
            Series::WEC      => "WEC",
            Series::GT3      => "GT3",
        }
    }
    fn color(&self) -> Color {
        match self {
            Series::Formula1  => ACCENT,
            Series::IndyCar   => Color::new(0.2, 0.7, 1.0, 1.0),
            Series::FormulaE  => Color::new(0.1, 0.9, 0.5, 1.0),
            Series::WEC       => Color::new(0.9, 0.6, 0.1, 1.0),
            Series::GT3       => Color::new(0.7, 0.2, 0.9, 1.0),
        }
    }
    fn rounds(&self) -> usize {
        match self {
            Series::Formula1  => 24,
            Series::IndyCar   => 17,
            Series::FormulaE  => 16,
            Series::WEC       => 8,
            Series::GT3       => 12,
        }
    }
    fn pit_stops_required(&self) -> bool {
        !matches!(self, Series::FormulaE)
    }
    fn has_endurance(&self) -> bool {
        matches!(self, Series::WEC)
    }
}

#[derive(Clone, Serialize, Deserialize)]
struct Driver {
    name: String,
    nationality: String,
    age: u8,
    pace: u8,        // 1-99
    consistency: u8, // 1-99
    wet_skill: u8,   // 1-99
    tire_mgmt: u8,   // 1-99
    experience: u8,  // 1-99
    salary: u32,     // per season, in thousands
    morale: i8,      // -100 to 100
    contract_years: u8,
}

impl Driver {
    fn overall(&self) -> u8 {
        ((self.pace as u32 + self.consistency as u32 + self.wet_skill as u32
            + self.tire_mgmt as u32 + self.experience as u32) / 5) as u8
    }

    fn race_performance(&self, wet: bool, rng: &mut impl Rng) -> f32 {
        let base = if wet {
            self.pace as f32 * 0.4 + self.wet_skill as f32 * 0.6
        } else {
            self.pace as f32 * 0.6 + self.consistency as f32 * 0.4
        };
        let variance = rng.gen_range(-8.0..8.0);
        let morale_bonus = self.morale as f32 * 0.05;
        (base + variance + morale_bonus).clamp(0.0, 99.0)
    }
}

#[derive(Clone, Serialize, Deserialize)]
struct Car {
    chassis: u8,     // aero / downforce
    engine: u8,      // power
    reliability: u8, // 1-99, affects DNF chance
    tire_deg: u8,    // tyre degradation management (higher = less deg)
    pit_speed: u8,   // pit stop speed
}

impl Car {
    fn performance(&self) -> u8 {
        ((self.chassis as u32 + self.engine as u32 + self.reliability as u32) / 3) as u8
    }
}

#[derive(Clone, Serialize, Deserialize)]
struct RdProject {
    name: String,
    target: String, // which car stat
    cost: u32,
    duration: u8,   // races remaining
    boost: u8,
}

#[derive(Clone, Serialize, Deserialize)]
struct PitStrategy {
    compound: TireCompound,
    laps_on: u8,
    pit_lap: u8,
}

#[derive(Clone, Copy, Serialize, Deserialize, PartialEq)]
enum TireCompound {
    Soft,
    Medium,
    Hard,
    Inter,
    Wet,
}

impl TireCompound {
    fn name(&self) -> &str {
        match self {
            TireCompound::Soft   => "SOFT",
            TireCompound::Medium => "MEDIUM",
            TireCompound::Hard   => "HARD",
            TireCompound::Inter  => "INTER",
            TireCompound::Wet    => "WET",
        }
    }
    fn color(&self) -> Color {
        match self {
            TireCompound::Soft   => Color::new(0.9, 0.1, 0.1, 1.0),
            TireCompound::Medium => Color::new(0.9, 0.8, 0.1, 1.0),
            TireCompound::Hard   => Color::new(0.85, 0.85, 0.85, 1.0),
            TireCompound::Inter  => Color::new(0.1, 0.7, 0.1, 1.0),
            TireCompound::Wet    => Color::new(0.1, 0.4, 0.9, 1.0),
        }
    }
    fn deg_rate(&self) -> f32 {
        match self {
            TireCompound::Soft   => 3.5,
            TireCompound::Medium => 2.0,
            TireCompound::Hard   => 1.0,
            TireCompound::Inter  => 1.5,
            TireCompound::Wet    => 1.2,
        }
    }
    fn pace_bonus(&self) -> f32 {
        match self {
            TireCompound::Soft   => 8.0,
            TireCompound::Medium => 4.0,
            TireCompound::Hard   => 0.0,
            TireCompound::Inter  => 3.0,
            TireCompound::Wet    => 1.0,
        }
    }
}

#[derive(Clone, Serialize, Deserialize)]
struct Circuit {
    name: String,
    country: String,
    laps: u16,
    pit_delta: f32,  // seconds lost in pit
    wet_chance: f32, // 0.0-1.0
    overtake_diff: f32, // 1.0 = normal
    tire_stress: f32,   // 1.0 = normal
}

#[derive(Clone, Serialize, Deserialize)]
struct RaceResult {
    round: usize,
    circuit: String,
    driver1_pos: u8,
    driver2_pos: u8,
    driver1_points: u8,
    driver2_points: u8,
    fastest_lap: bool,
    dnf_driver: Option<u8>, // 1 or 2
    wet_race: bool,
    pit_stops: Vec<String>,
}

#[derive(Clone, Serialize, Deserialize)]
struct Team {
    name: String,
    budget: u32,          // thousands
    driver1: Driver,
    driver2: Driver,
    car: Car,
    rd_projects: Vec<RdProject>,
    standings_points: u32,
    race_results: Vec<RaceResult>,
    series: Series,
    current_round: usize,
}

impl Team {
    fn weekly_costs(&self) -> u32 {
        (self.driver1.salary + self.driver2.salary) / 24
            + 500 // base ops cost per race weekend
    }
}

#[derive(Clone, Serialize, Deserialize)]
struct OpponentTeam {
    name: String,
    strength: u8,
    points: u32,
    color_r: f32,
    color_g: f32,
    color_b: f32,
}

impl OpponentTeam {
    fn color(&self) -> Color {
        Color::new(self.color_r, self.color_g, self.color_b, 1.0)
    }
}

fn points_for_pos(pos: u8) -> u8 {
    match pos {
        1  => 25,
        2  => 18,
        3  => 15,
        4  => 12,
        5  => 10,
        6  => 8,
        7  => 6,
        8  => 4,
        9  => 2,
        10 => 1,
        _  => 0,
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GAME STATE
// ═══════════════════════════════════════════════════════════════════════════════

#[derive(PartialEq, Clone)]
enum Screen {
    MainMenu,
    SeriesSelect,
    TeamSetup,
    Dashboard,
    Roster,
    CarDev,
    RaceWeekend,
    RaceStrategy,
    RaceSimulation,
    Results,
    Standings,
}

#[derive(Clone)]
struct RaceWeekendState {
    practice_done: bool,
    qualifying_done: bool,
    qualifying_pos1: u8,
    qualifying_pos2: u8,
    strategy1: TireCompound,
    strategy2: TireCompound,
    pit_lap1: u16,
    pit_lap2: u16,
    wet: bool,
    sim_progress: f32,
    sim_done: bool,
    result: Option<RaceResult>,
    log: Vec<String>,
}

impl Default for RaceWeekendState {
    fn default() -> Self {
        Self {
            practice_done: false,
            qualifying_done: false,
            qualifying_pos1: 5,
            qualifying_pos2: 8,
            strategy1: TireCompound::Soft,
            strategy2: TireCompound::Medium,
            pit_lap1: 20,
            pit_lap2: 25,
            wet: false,
            sim_progress: 0.0,
            sim_done: false,
            result: None,
            log: Vec::new(),
        }
    }
}

struct GameState {
    screen: Screen,
    team: Option<Team>,
    opponents: Vec<OpponentTeam>,
    race_state: RaceWeekendState,
    scroll: f32,
    input_buf: String,
    setup_step: usize,
    setup_name: String,
    setup_driver1: String,
    setup_driver2: String,
    msg: Option<(String, f32)>, // message + timer
    selected_series: Option<Series>,
    selected_rd: Option<usize>,
    tab: usize,
}

impl GameState {
    fn new() -> Self {
        Self {
            screen: Screen::MainMenu,
            team: None,
            opponents: Vec::new(),
            race_state: RaceWeekendState::default(),
            scroll: 0.0,
            input_buf: String::new(),
            setup_step: 0,
            setup_name: String::new(),
            setup_driver1: String::new(),
            setup_driver2: String::new(),
            msg: None,
            selected_series: None,
            selected_rd: None,
            tab: 0,
        }
    }

    fn show_msg(&mut self, msg: &str) {
        self.msg = Some((msg.to_string(), 3.0));
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA GENERATORS
// ═══════════════════════════════════════════════════════════════════════════════

fn default_driver(name: &str, nationality: &str, pace: u8, salary: u32) -> Driver {
    let mut rng = thread_rng();
    Driver {
        name: name.to_string(),
        nationality: nationality.to_string(),
        age: rng.gen_range(20..35),
        pace,
        consistency: rng.gen_range(60..90),
        wet_skill: rng.gen_range(55..90),
        tire_mgmt: rng.gen_range(55..85),
        experience: rng.gen_range(30..80),
        salary,
        morale: 50,
        contract_years: rng.gen_range(1..3),
    }
}

fn new_team(name: String, driver1_name: String, driver2_name: String, series: Series) -> Team {
    Team {
        name,
        budget: 50_000,
        driver1: default_driver(&driver1_name, "PL", 72, 800),
        driver2: default_driver(&driver2_name, "PL", 68, 600),
        car: Car { chassis: 60, engine: 62, reliability: 65, tire_deg: 60, pit_speed: 65 },
        rd_projects: Vec::new(),
        standings_points: 0,
        race_results: Vec::new(),
        series,
        current_round: 0,
    }
}

fn generate_opponents(series: &Series) -> Vec<OpponentTeam> {
    let data: &[(&str, u8, f32, f32, f32)] = match series {
        Series::Formula1 => &[
            ("Red Bull Racing", 95, 0.8, 0.1, 0.1),
            ("Ferrari",         92, 0.9, 0.1, 0.1),
            ("Mercedes",        90, 0.4, 0.4, 0.9),
            ("McLaren",         88, 1.0, 0.6, 0.0),
            ("Aston Martin",    82, 0.0, 0.7, 0.4),
            ("Alpine",          78, 0.0, 0.2, 0.8),
            ("Williams",        72, 0.0, 0.4, 0.8),
            ("Haas",            70, 0.6, 0.6, 0.6),
            ("Kick Sauber",     68, 0.1, 0.8, 0.4),
            ("RB",              71, 0.0, 0.5, 0.9),
        ],
        Series::IndyCar => &[
            ("Penske",          90, 1.0, 0.1, 0.1),
            ("Ganassi",         88, 0.1, 0.4, 0.9),
            ("Andretti",        85, 0.2, 0.6, 0.8),
            ("Arrow McLaren",   82, 1.0, 0.5, 0.0),
            ("Rahal",           78, 0.3, 0.6, 0.9),
            ("AJ Foyt",         72, 0.9, 0.4, 0.1),
        ],
        Series::FormulaE => &[
            ("Porsche",         88, 0.8, 0.1, 0.1),
            ("Jaguar",          85, 0.0, 0.6, 0.3),
            ("Nissan",          82, 0.8, 0.1, 0.5),
            ("DS Penske",       80, 0.2, 0.2, 0.8),
            ("Maserati",        78, 0.7, 0.1, 0.1),
            ("Envision",        74, 0.0, 0.5, 0.8),
        ],
        Series::WEC => &[
            ("Toyota Gazoo",    93, 0.9, 0.1, 0.1),
            ("Ferrari AF",      88, 0.9, 0.1, 0.1),
            ("Peugeot",         84, 0.0, 0.3, 0.7),
            ("Porsche LMDh",    86, 0.8, 0.1, 0.1),
            ("BMW M Team",      80, 0.0, 0.2, 0.8),
        ],
        Series::GT3 => &[
            ("Ferrari GT3",     85, 0.9, 0.1, 0.1),
            ("Porsche GT3",     84, 0.8, 0.1, 0.1),
            ("BMW M4 GT3",      82, 0.0, 0.2, 0.8),
            ("Aston Vantage",   80, 0.0, 0.6, 0.3),
            ("McLaren GT3",     79, 1.0, 0.5, 0.0),
            ("Lamborghini GT3", 78, 0.9, 0.5, 0.0),
        ],
    };

    data.iter().map(|(name, str, r, g, b)| OpponentTeam {
        name: name.to_string(),
        strength: *str,
        points: 0,
        color_r: *r,
        color_g: *g,
        color_b: *b,
    }).collect()
}

fn circuits_for(series: &Series) -> Vec<Circuit> {
    match series {
        Series::Formula1 => vec![
            Circuit { name: "Bahrain".into(),    country: "BHR".into(), laps: 57, pit_delta: 22.0, wet_chance: 0.05, overtake_diff: 1.1, tire_stress: 1.2 },
            Circuit { name: "Saudi Arabia".into(),country: "KSA".into(),laps: 50, pit_delta: 20.0, wet_chance: 0.03, overtake_diff: 0.7, tire_stress: 1.1 },
            Circuit { name: "Australia".into(),  country: "AUS".into(), laps: 58, pit_delta: 23.0, wet_chance: 0.25, overtake_diff: 0.9, tire_stress: 1.0 },
            Circuit { name: "Japan".into(),      country: "JPN".into(), laps: 53, pit_delta: 21.0, wet_chance: 0.35, overtake_diff: 0.8, tire_stress: 1.3 },
            Circuit { name: "China".into(),      country: "CHN".into(), laps: 56, pit_delta: 22.0, wet_chance: 0.20, overtake_diff: 1.0, tire_stress: 1.1 },
            Circuit { name: "Miami".into(),      country: "USA".into(), laps: 57, pit_delta: 21.0, wet_chance: 0.15, overtake_diff: 1.2, tire_stress: 1.2 },
            Circuit { name: "Imola".into(),      country: "ITA".into(), laps: 63, pit_delta: 24.0, wet_chance: 0.30, overtake_diff: 0.6, tire_stress: 1.0 },
            Circuit { name: "Monaco".into(),     country: "MCO".into(), laps: 78, pit_delta: 26.0, wet_chance: 0.25, overtake_diff: 0.3, tire_stress: 0.7 },
            Circuit { name: "Canada".into(),     country: "CAN".into(), laps: 70, pit_delta: 22.0, wet_chance: 0.30, overtake_diff: 1.3, tire_stress: 1.0 },
            Circuit { name: "Spain".into(),      country: "ESP".into(), laps: 66, pit_delta: 21.0, wet_chance: 0.10, overtake_diff: 0.8, tire_stress: 1.3 },
            Circuit { name: "Austria".into(),    country: "AUT".into(), laps: 71, pit_delta: 20.0, wet_chance: 0.30, overtake_diff: 1.2, tire_stress: 1.1 },
            Circuit { name: "Silverstone".into(),country: "GBR".into(), laps: 52, pit_delta: 21.0, wet_chance: 0.40, overtake_diff: 1.1, tire_stress: 1.2 },
            Circuit { name: "Hungary".into(),    country: "HUN".into(), laps: 70, pit_delta: 22.0, wet_chance: 0.20, overtake_diff: 0.7, tire_stress: 1.1 },
            Circuit { name: "Belgium".into(),    country: "BEL".into(), laps: 44, pit_delta: 21.0, wet_chance: 0.45, overtake_diff: 1.0, tire_stress: 1.2 },
            Circuit { name: "Netherlands".into(),country: "NLD".into(), laps: 72, pit_delta: 22.0, wet_chance: 0.25, overtake_diff: 0.7, tire_stress: 1.2 },
            Circuit { name: "Monza".into(),      country: "ITA".into(), laps: 53, pit_delta: 22.0, wet_chance: 0.20, overtake_diff: 1.4, tire_stress: 0.8 },
            Circuit { name: "Azerbaijan".into(), country: "AZE".into(), laps: 51, pit_delta: 20.0, wet_chance: 0.08, overtake_diff: 1.3, tire_stress: 0.9 },
            Circuit { name: "Singapore".into(),  country: "SGP".into(), laps: 61, pit_delta: 24.0, wet_chance: 0.35, overtake_diff: 0.6, tire_stress: 1.0 },
            Circuit { name: "Austin".into(),     country: "USA".into(), laps: 56, pit_delta: 22.0, wet_chance: 0.20, overtake_diff: 1.1, tire_stress: 1.2 },
            Circuit { name: "Mexico City".into(),country: "MEX".into(), laps: 71, pit_delta: 22.0, wet_chance: 0.10, overtake_diff: 1.0, tire_stress: 0.9 },
            Circuit { name: "São Paulo".into(),  country: "BRA".into(), laps: 71, pit_delta: 22.0, wet_chance: 0.40, overtake_diff: 1.1, tire_stress: 1.0 },
            Circuit { name: "Las Vegas".into(),  country: "USA".into(), laps: 50, pit_delta: 20.0, wet_chance: 0.05, overtake_diff: 1.3, tire_stress: 1.0 },
            Circuit { name: "Qatar".into(),      country: "QAT".into(), laps: 57, pit_delta: 21.0, wet_chance: 0.02, overtake_diff: 0.9, tire_stress: 1.5 },
            Circuit { name: "Abu Dhabi".into(),  country: "UAE".into(), laps: 58, pit_delta: 22.0, wet_chance: 0.02, overtake_diff: 0.8, tire_stress: 1.0 },
        ],
        Series::IndyCar => (0..17).map(|i| Circuit {
            name: format!("Round {}", i + 1),
            country: "USA".into(),
            laps: 200,
            pit_delta: 12.0,
            wet_chance: 0.20,
            overtake_diff: 1.5,
            tire_stress: 1.0,
        }).collect(),
        Series::FormulaE => (0..16).map(|i| Circuit {
            name: format!("E-Prix Round {}", i + 1),
            country: "INT".into(),
            laps: 30,
            pit_delta: 0.0,
            wet_chance: 0.25,
            overtake_diff: 1.1,
            tire_stress: 0.5,
        }).collect(),
        Series::WEC => vec![
            Circuit { name: "Sebring".into(),      country: "USA".into(), laps: 350, pit_delta: 60.0, wet_chance: 0.25, overtake_diff: 1.2, tire_stress: 1.4 },
            Circuit { name: "Portimão".into(),     country: "PRT".into(), laps: 280, pit_delta: 55.0, wet_chance: 0.30, overtake_diff: 1.0, tire_stress: 1.2 },
            Circuit { name: "Spa".into(),          country: "BEL".into(), laps: 210, pit_delta: 55.0, wet_chance: 0.45, overtake_diff: 1.1, tire_stress: 1.2 },
            Circuit { name: "Le Mans".into(),      country: "FRA".into(), laps: 380, pit_delta: 70.0, wet_chance: 0.30, overtake_diff: 1.3, tire_stress: 1.0 },
            Circuit { name: "Monza".into(),        country: "ITA".into(), laps: 300, pit_delta: 50.0, wet_chance: 0.20, overtake_diff: 1.4, tire_stress: 0.8 },
            Circuit { name: "Fuji".into(),         country: "JPN".into(), laps: 260, pit_delta: 55.0, wet_chance: 0.40, overtake_diff: 1.0, tire_stress: 1.1 },
            Circuit { name: "Bahrain".into(),      country: "BHR".into(), laps: 300, pit_delta: 55.0, wet_chance: 0.05, overtake_diff: 1.1, tire_stress: 1.2 },
            Circuit { name: "Qatar".into(),        country: "QAT".into(), laps: 320, pit_delta: 55.0, wet_chance: 0.02, overtake_diff: 0.9, tire_stress: 1.3 },
        ],
        Series::GT3 => (0..12).map(|i| Circuit {
            name: format!("Round {}", i + 1),
            country: "EUR".into(),
            laps: 100,
            pit_delta: 30.0,
            wet_chance: 0.30,
            overtake_diff: 1.1,
            tire_stress: 1.0,
        }).collect(),
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RACE SIMULATION
// ═══════════════════════════════════════════════════════════════════════════════

fn simulate_race(
    team: &mut Team,
    opponents: &mut Vec<OpponentTeam>,
    rs: &RaceWeekendState,
    circuits: &[Circuit],
    rng: &mut impl Rng,
) -> RaceResult {
    let circuit = &circuits[team.current_round];
    let wet = rs.wet;

    // Driver performances
    let p1 = team.driver1.race_performance(wet, rng);
    let p2 = team.driver2.race_performance(wet, rng);

    // Car contribution
    let car_perf = team.car.performance() as f32;

    // Tire strategy effect
    let tire1_bonus = if wet {
        if rs.strategy1 == TireCompound::Inter || rs.strategy1 == TireCompound::Wet { 10.0 } else { -15.0 }
    } else {
        rs.strategy1.pace_bonus()
    };
    let tire2_bonus = if wet {
        if rs.strategy2 == TireCompound::Inter || rs.strategy2 == TireCompound::Wet { 10.0 } else { -15.0 }
    } else {
        rs.strategy2.pace_bonus()
    };

    // Pit stop penalty — earlier pit = more deg saved but time lost
    let pit1_timing = if team.series.pit_stops_required() {
        let ideal = circuit.laps / 2;
        let delta = (rs.pit_lap1 as i16 - ideal as i16).abs() as f32;
        -(delta * 0.3)
    } else { 0.0 };

    let total1 = (p1 + car_perf * 0.5 + tire1_bonus + pit1_timing).clamp(0.0, 120.0);
    let total2 = (p2 + car_perf * 0.5 + tire2_bonus).clamp(0.0, 120.0);

    // DNF check
    let dnf_chance = (100 - team.car.reliability) as f32 / 200.0;
    let dnf1 = rng.gen::<f32>() < dnf_chance;
    let dnf2 = rng.gen::<f32>() < dnf_chance;
    let dnf_driver = if dnf1 { Some(1) } else if dnf2 { Some(2) } else { None };

    // Build full grid performance values
    let mut grid: Vec<(String, f32, bool)> = Vec::new(); // (name, score, is_player)
    let score1 = if dnf1 { -99.0 } else { total1 };
    let score2 = if dnf2 { -99.0 } else { total2 };
    grid.push((format!("{}", team.driver1.name), score1, true));
    grid.push((format!("{}", team.driver2.name), score2, true));

    for opp in opponents.iter() {
        let base = opp.strength as f32 + rng.gen_range(-12.0..12.0);
        grid.push((opp.name.clone(), base, false));
        // Second opponent driver
        let base2 = opp.strength as f32 * 0.92 + rng.gen_range(-12.0..12.0);
        grid.push((format!("{} #2", opp.name), base2, false));
    }

    // Sort descending
    grid.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());

    let pos1 = grid.iter().position(|(n, _, _)| n == &team.driver1.name).unwrap_or(20) as u8 + 1;
    let pos2 = grid.iter().position(|(n, _, _)| n == &team.driver2.name).unwrap_or(20) as u8 + 1;

    let pts1 = if dnf1 { 0 } else { points_for_pos(pos1) };
    let pts2 = if dnf2 { 0 } else { points_for_pos(pos2) };
    let fl = pos1 == 1 || pos2 == 1; // simplification

    // Update opponent points
    for opp in opponents.iter_mut() {
        let opp_pts: u32 = rng.gen_range(0..20);
        opp.points += opp_pts;
    }

    // Update team budget (prize money)
    let prize = (pts1 as u32 + pts2 as u32) * 200 + 2000;
    team.budget = team.budget.saturating_add(prize).saturating_sub(team.weekly_costs());

    // Update R&D projects
    for proj in team.rd_projects.iter_mut() {
        if proj.duration > 0 { proj.duration -= 1; }
    }
    // Apply completed projects
    let completed: Vec<_> = team.rd_projects.iter()
        .filter(|p| p.duration == 0)
        .map(|p| (p.target.clone(), p.boost))
        .collect();
    for (target, boost) in completed {
        match target.as_str() {
            "chassis"     => team.car.chassis     = (team.car.chassis + boost).min(99),
            "engine"      => team.car.engine      = (team.car.engine + boost).min(99),
            "reliability" => team.car.reliability = (team.car.reliability + boost).min(99),
            "tire_deg"    => team.car.tire_deg    = (team.car.tire_deg + boost).min(99),
            "pit_speed"   => team.car.pit_speed   = (team.car.pit_speed + boost).min(99),
            _ => {}
        }
    }
    team.rd_projects.retain(|p| p.duration > 0);

    // Morale updates
    if pos1 <= 5 { team.driver1.morale = (team.driver1.morale + 10).min(100); }
    else         { team.driver1.morale = (team.driver1.morale - 5).max(-100); }
    if pos2 <= 5 { team.driver2.morale = (team.driver2.morale + 10).min(100); }
    else         { team.driver2.morale = (team.driver2.morale - 5).max(-100); }

    // Build pit log
    let mut pit_log = Vec::new();
    if team.series.pit_stops_required() {
        pit_log.push(format!("Lap {:2} — {} pits → {}",
            rs.pit_lap1, team.driver1.name, rs.strategy1.name()));
        pit_log.push(format!("Lap {:2} — {} pits → {}",
            rs.pit_lap2, team.driver2.name, rs.strategy2.name()));
        if wet { pit_log.push("Wet conditions — intermediate tires critical".into()); }
    }

    team.standings_points += pts1 as u32 + pts2 as u32;
    team.current_round += 1;

    RaceResult {
        round: team.current_round,
        circuit: circuit.name.clone(),
        driver1_pos: pos1,
        driver2_pos: pos2,
        driver1_points: pts1,
        driver2_points: pts2,
        fastest_lap: fl,
        dnf_driver,
        wet_race: wet,
        pit_stops: pit_log,
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SAVE / LOAD
// ═══════════════════════════════════════════════════════════════════════════════

#[derive(Serialize, Deserialize)]
struct SaveData {
    team: Team,
    opponent_points: Vec<u32>,
}

fn save_game(gs: &GameState) {
    if let Some(ref team) = gs.team {
        let data = SaveData {
            team: team.clone(),
            opponent_points: gs.opponents.iter().map(|o| o.points).collect(),
        };
        if let Ok(json) = serde_json::to_string_pretty(&data) {
            fs::write(SAVE_FILE, json).ok();
        }
    }
}

fn load_game(gs: &mut GameState) -> bool {
    if let Ok(json) = fs::read_to_string(SAVE_FILE) {
        if let Ok(data) = serde_json::from_str::<SaveData>(&json) {
            let series = data.team.series.clone();
            gs.opponents = generate_opponents(&series);
            for (i, pts) in data.opponent_points.iter().enumerate() {
                if let Some(opp) = gs.opponents.get_mut(i) {
                    opp.points = *pts;
                }
            }
            gs.team = Some(data.team);
            gs.screen = Screen::Dashboard;
            return true;
        }
    }
    false
}

// ═══════════════════════════════════════════════════════════════════════════════
// UI HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

fn sw() -> f32 { screen_width() }
fn sh() -> f32 { screen_height() }

fn panel(x: f32, y: f32, w: f32, h: f32, col: Color) {
    draw_rectangle(x, y, w, h, col);
    draw_rectangle_lines(x, y, w, h, 1.0, BORDER);
}

fn label(text: &str, x: f32, y: f32, size: f32, col: Color) {
    draw_text(text, x, y, size, col);
}

fn button(text: &str, x: f32, y: f32, w: f32, h: f32, col: Color) -> bool {
    let mx = mouse_position().0;
    let my = mouse_position().1;
    let hover = mx >= x && mx <= x + w && my >= y && my <= y + h;
    let bg = if hover { Color::new(col.r, col.g, col.b, 0.25) } else { Color::new(col.r, col.g, col.b, 0.10) };
    draw_rectangle(x, y, w, h, bg);
    draw_rectangle_lines(x, y, w, h, 1.5, if hover { col } else { BORDER });
    let tw = measure_text(text, None, 18, 1.0).width;
    draw_text(text, x + (w - tw) / 2.0, y + h / 2.0 + 6.0, 18.0, if hover { col } else { TEXT });
    hover && is_mouse_button_pressed(MouseButton::Left)
}

fn stat_bar(label_txt: &str, val: u8, x: f32, y: f32, w: f32, col: Color) {
    draw_text(label_txt, x, y + 12.0, 14.0, TEXT_DIM);
    let bar_x = x + 100.0;
    let bar_w = w - 110.0;
    draw_rectangle(bar_x, y, bar_w, 14.0, PANEL2);
    draw_rectangle(bar_x, y, bar_w * val as f32 / 99.0, 14.0, col);
    draw_rectangle_lines(bar_x, y, bar_w, 14.0, 1.0, BORDER);
    draw_text(&format!("{}", val), bar_x + bar_w + 6.0, y + 12.0, 14.0, TEXT);
}

fn position_badge(pos: u8, x: f32, y: f32) {
    let col = match pos {
        1 => GOLD,
        2 => SILVER,
        3 => BRONZE,
        _ => TEXT_DIM,
    };
    draw_rectangle(x, y, 36.0, 24.0, Color::new(col.r, col.g, col.b, 0.15));
    draw_rectangle_lines(x, y, 36.0, 24.0, 1.0, col);
    let txt = format!("P{}", pos);
    let tw = measure_text(&txt, None, 16, 1.0).width;
    draw_text(&txt, x + (36.0 - tw) / 2.0, y + 17.0, 16.0, col);
}

fn tire_badge(compound: TireCompound, x: f32, y: f32) {
    let col = compound.color();
    draw_rectangle(x, y, 52.0, 20.0, Color::new(col.r, col.g, col.b, 0.2));
    draw_rectangle_lines(x, y, 52.0, 20.0, 1.0, col);
    let tw = measure_text(compound.name(), None, 13, 1.0).width;
    draw_text(compound.name(), x + (52.0 - tw) / 2.0, y + 14.0, 13.0, col);
}

fn section_header(title: &str, y: f32) {
    draw_line(20.0, y, sw() - 20.0, y, 1.0, BORDER);
    let tw = measure_text(title, None, 20, 1.0).width;
    draw_rectangle(sw() / 2.0 - tw / 2.0 - 10.0, y - 12.0, tw + 20.0, 22.0, BG);
    draw_text(title, sw() / 2.0 - tw / 2.0, y + 6.0, 20.0, TEXT_DIM);
}

fn topbar(team: &Team, circuits: &[Circuit]) {
    draw_rectangle(0.0, 0.0, sw(), 46.0, Color::new(0.05, 0.05, 0.09, 0.98));
    draw_line(0.0, 46.0, sw(), 46.0, 1.0, BORDER);

    draw_text(&team.name, 16.0, 30.0, 22.0, ACCENT);
    let series_col = team.series.color();
    draw_text(team.series.short(), 16.0 + measure_text(&team.name, None, 22, 1.0).width + 10.0, 30.0, 18.0, series_col);

    // Budget
    let budget_str = format!("${:.1}M", team.budget as f32 / 1000.0);
    let pts_str = format!("{} PTS", team.standings_points);
    let round_str = if team.current_round < circuits.len() {
        format!("R{}/{} — {}", team.current_round + 1, circuits.len(), circuits[team.current_round].name)
    } else {
        "Season Complete".into()
    };

    let bw = measure_text(&budget_str, None, 18, 1.0).width;
    draw_text(&budget_str, sw() - bw - 220.0, 30.0, 18.0, GREEN);
    draw_text(&pts_str, sw() - 150.0, 30.0, 18.0, GOLD);
    draw_text(&round_str, sw() / 2.0 - measure_text(&round_str, None, 16, 1.0).width / 2.0, 30.0, 16.0, TEXT_DIM);
}

fn bottom_nav(gs: &mut GameState, circuits: &[Circuit]) -> bool {
    // returns true if we should go to race weekend
    let bh = 44.0;
    let by = sh() - bh;
    draw_rectangle(0.0, by, sw(), bh, Color::new(0.05, 0.05, 0.09, 0.98));
    draw_line(0.0, by, sw(), by, 1.0, BORDER);

    let tabs = ["DASHBOARD", "ROSTER", "CAR DEV", "STANDINGS", "NEXT RACE"];
    let tw = sw() / tabs.len() as f32;
    let mut go_race = false;

    for (i, tab) in tabs.iter().enumerate() {
        let tx = i as f32 * tw;
        let active = gs.tab == i;
        if active {
            draw_rectangle(tx, by, tw, bh, Color::new(ACCENT.r, ACCENT.g, ACCENT.b, 0.12));
            draw_line(tx, by, tx + tw, by, 2.0, ACCENT);
        }
        let label_w = measure_text(tab, None, 15, 1.0).width;
        let col = if active { ACCENT } else if i == 4 { GREEN } else { TEXT_DIM };
        draw_text(tab, tx + (tw - label_w) / 2.0, by + 28.0, 15.0, col);

        let mx = mouse_position().0;
        let my = mouse_position().1;
        let hover = mx >= tx && mx <= tx + tw && my >= by && my <= by + bh;
        if hover && is_mouse_button_pressed(MouseButton::Left) {
            if i == 4 {
                if let Some(ref team) = gs.team.clone() {
                    if team.current_round < circuits.len() {
                        go_race = true;
                    }
                }
            } else {
                gs.tab = i;
            }
        }
    }
    go_race
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREENS
// ═══════════════════════════════════════════════════════════════════════════════

fn draw_main_menu(gs: &mut GameState) {
    clear_background(BG);

    // Title
    let title = "THE RACER";
    let sub   = "MOTORSPORT MANAGEMENT SIMULATOR";
    let tw = measure_text(title, None, 72, 1.0).width;
    let sw2 = measure_text(sub, None, 18, 1.0).width;
    draw_text(title, sw() / 2.0 - tw / 2.0, sh() * 0.30, 72.0, ACCENT);
    draw_text(sub, sw() / 2.0 - sw2 / 2.0, sh() * 0.30 + 56.0, 18.0, TEXT_DIM);

    // Decorative line
    draw_line(sw() / 2.0 - 200.0, sh() * 0.38, sw() / 2.0 + 200.0, sh() * 0.38, 1.0, BORDER);

    let bw = 260.0;
    let bh = 46.0;
    let bx = sw() / 2.0 - bw / 2.0;

    if button("NEW SEASON", bx, sh() * 0.44, bw, bh, ACCENT) {
        gs.screen = Screen::SeriesSelect;
    }
    if button("CONTINUE", bx, sh() * 0.44 + 60.0, bw, bh, BLUE) {
        if !load_game(gs) { gs.show_msg("No save file found."); }
    }
    if button("EXIT", bx, sh() * 0.44 + 120.0, bw, bh, TEXT_DIM) {
        std::process::exit(0);
    }

    draw_text("v1.0.0", sw() - 60.0, sh() - 10.0, 14.0, TEXT_DIM);

    if let Some((ref msg, _)) = gs.msg.clone() {
        let mw = measure_text(msg, None, 18, 1.0).width;
        draw_text(msg, sw() / 2.0 - mw / 2.0, sh() - 40.0, 18.0, ACCENT);
    }
}

fn draw_series_select(gs: &mut GameState) {
    clear_background(BG);
    label("SELECT CHAMPIONSHIP", 30.0, 50.0, 28.0, TEXT);
    draw_line(30.0, 60.0, sw() - 30.0, 60.0, 1.0, BORDER);

    let series_list = [
        (Series::Formula1, "Formula 1 — 2026 Season",  "24 rounds, hybrid power units, 2026 technical regulations"),
        (Series::IndyCar,  "IndyCar Series",            "17 rounds including the Indy 500, oval + road courses"),
        (Series::FormulaE, "ABB Formula E",             "16 rounds, pure electric, no pit stops for tires"),
        (Series::WEC,      "FIA World Endurance Champ.","8 rounds including 24h Le Mans, multi-driver stints"),
        (Series::GT3,      "GT3 European Series",       "12 rounds, production-based GT cars, pro-am grid"),
    ];

    for (i, (series, name, desc)) in series_list.iter().enumerate() {
        let y = 100.0 + i as f32 * 96.0;
        let col = series.color();
        let selected = gs.selected_series.as_ref() == Some(series);

        draw_rectangle(30.0, y, sw() - 60.0, 84.0,
            if selected { Color::new(col.r, col.g, col.b, 0.10) } else { PANEL });
        draw_rectangle_lines(30.0, y, sw() - 60.0, 84.0, 1.5,
            if selected { col } else { BORDER });

        // Series badge
        draw_rectangle(30.0, y, 80.0, 84.0, Color::new(col.r, col.g, col.b, 0.15));
        let bw = measure_text(series.short(), None, 20, 1.0).width;
        draw_text(series.short(), 30.0 + (80.0 - bw) / 2.0, y + 50.0, 20.0, col);

        draw_text(name, 126.0, y + 30.0, 22.0, TEXT);
        draw_text(desc, 126.0, y + 56.0, 15.0, TEXT_DIM);

        let rounds_txt = format!("{} rounds", series.rounds());
        draw_text(&rounds_txt, sw() - 120.0, y + 30.0, 16.0, TEXT_DIM);
        if series.pit_stops_required() {
            draw_text("PIT STOPS", sw() - 120.0, y + 52.0, 13.0, GOLD);
        }
        if series.has_endurance() {
            draw_text("ENDURANCE", sw() - 120.0, y + 68.0, 13.0, BLUE);
        }

        let mx = mouse_position().0;
        let my = mouse_position().1;
        if mx >= 30.0 && mx <= sw() - 30.0 && my >= y && my <= y + 84.0
            && is_mouse_button_pressed(MouseButton::Left) {
            gs.selected_series = Some(series.clone());
        }
    }

    if gs.selected_series.is_some() {
        if button("SELECT & SETUP TEAM  →", sw() / 2.0 - 150.0, sh() - 70.0, 300.0, 46.0, ACCENT) {
            gs.screen = Screen::TeamSetup;
            gs.setup_step = 0;
            gs.input_buf.clear();
        }
    }
    if button("← BACK", 30.0, sh() - 70.0, 120.0, 40.0, TEXT_DIM) {
        gs.screen = Screen::MainMenu;
    }
}

fn draw_team_setup(gs: &mut GameState) {
    clear_background(BG);
    label("TEAM SETUP", 30.0, 50.0, 28.0, TEXT);
    draw_line(30.0, 60.0, sw() - 30.0, 60.0, 1.0, BORDER);

    let prompts = ["Team Name:", "Driver 1 Name:", "Driver 2 Name:"];
    let step = gs.setup_step;

    for (i, prompt) in prompts.iter().enumerate() {
        let y = 130.0 + i as f32 * 90.0;
        let done = i < step;
        let active = i == step;

        let val = match i {
            0 => &gs.setup_name,
            1 => &gs.setup_driver1,
            2 => &gs.setup_driver2,
            _ => &gs.setup_name,
        };

        draw_text(prompt, 100.0, y, 20.0, if active { TEXT } else { TEXT_DIM });
        draw_rectangle(100.0, y + 10.0, 400.0, 36.0,
            if active { PANEL2 } else { PANEL });
        draw_rectangle_lines(100.0, y + 10.0, 400.0, 36.0, 1.5,
            if active { ACCENT } else { BORDER });

        let display = if active {
            format!("{}|", gs.input_buf)
        } else {
            val.clone()
        };
        draw_text(&display, 108.0, y + 33.0, 20.0, if done { GREEN } else { TEXT });
    }

    // Handle text input
    if step < 3 {
        while let Some(c) = get_char_pressed() {
            if c == '\r' || c == '\n' {
                if !gs.input_buf.trim().is_empty() {
                    let val = gs.input_buf.trim().to_string();
                    match step {
                        0 => gs.setup_name    = val,
                        1 => gs.setup_driver1 = val,
                        2 => gs.setup_driver2 = val,
                        _ => {}
                    }
                    gs.input_buf.clear();
                    gs.setup_step += 1;
                }
            } else if c == '\x08' {
                gs.input_buf.pop();
            } else if c.is_ascii_graphic() || c == ' ' {
                if gs.input_buf.len() < 24 { gs.input_buf.push(c); }
            }
        }
    }

    if gs.setup_step >= 3 {
        draw_text("✓ All set! Ready to start season.", 100.0, 400.0, 20.0, GREEN);
        if button("START SEASON  →", sw() / 2.0 - 130.0, sh() - 80.0, 260.0, 46.0, ACCENT) {
            let series = gs.selected_series.clone().unwrap_or(Series::Formula1);
            let team = new_team(gs.setup_name.clone(), gs.setup_driver1.clone(), gs.setup_driver2.clone(), series.clone());
            gs.opponents = generate_opponents(&series);
            gs.team = Some(team);
            gs.screen = Screen::Dashboard;
            gs.tab = 0;
        }
    }

    if button("← BACK", 30.0, sh() - 80.0, 120.0, 40.0, TEXT_DIM) {
        gs.screen = Screen::SeriesSelect;
    }
}

fn draw_dashboard(gs: &mut GameState, circuits: &[Circuit]) {
    let team = gs.team.as_ref().unwrap();
    clear_background(BG);
    topbar(team, circuits);

    // Next race card
    let next_circuit = if team.current_round < circuits.len() {
        Some(&circuits[team.current_round])
    } else { None };

    let card_y = 66.0;
    if let Some(c) = next_circuit {
        panel(16.0, card_y, sw() - 32.0, 110.0, PANEL);
        draw_text("NEXT RACE", 30.0, card_y + 24.0, 14.0, TEXT_DIM);
        draw_text(&c.name, 30.0, card_y + 56.0, 32.0, TEXT);
        draw_text(&c.country, 30.0 + measure_text(&c.name, None, 32, 1.0).width + 10.0, card_y + 56.0, 20.0, TEXT_DIM);
        draw_text(&format!("{} laps", c.laps), 30.0, card_y + 82.0, 16.0, TEXT_DIM);

        // Weather indicator
        let weather = if c.wet_chance > 0.35 { ("LIKELY RAIN", BLUE) }
            else if c.wet_chance > 0.15 { ("POSSIBLE RAIN", GOLD) }
            else { ("DRY", GREEN) };
        let wx = sw() - 200.0;
        draw_text("WEATHER", wx, card_y + 24.0, 14.0, TEXT_DIM);
        draw_text(weather.0, wx, card_y + 56.0, 22.0, weather.1);
        draw_text(&format!("{:.0}% chance", c.wet_chance * 100.0), wx, card_y + 80.0, 14.0, TEXT_DIM);

        // Pit stops info
        if team.series.pit_stops_required() {
            draw_text(&format!("Pit delta: {:.0}s", c.pit_delta), sw() / 2.0 - 60.0, card_y + 56.0, 16.0, GOLD);
        }
    } else {
        panel(16.0, card_y, sw() - 32.0, 110.0, PANEL);
        let end = "SEASON COMPLETE — Champions crowned!";
        draw_text(end, 30.0, card_y + 60.0, 26.0, GOLD);
    }

    // Driver cards
    let dy = card_y + 128.0;
    section_header("DRIVERS", dy);
    for (i, driver) in [&team.driver1, &team.driver2].iter().enumerate() {
        let dx = 16.0 + i as f32 * (sw() / 2.0 - 20.0);
        let dw = sw() / 2.0 - 24.0;
        panel(dx, dy + 14.0, dw, 130.0, PANEL);
        draw_text(&driver.name, dx + 12.0, dy + 40.0, 22.0, TEXT);
        draw_text(&format!("OVR {}", driver.overall()), dx + dw - 70.0, dy + 40.0, 20.0, ACCENT);
        stat_bar("PACE",  driver.pace,        dx + 12.0, dy + 58.0, dw - 24.0, ACCENT);
        stat_bar("CONSS", driver.consistency, dx + 12.0, dy + 78.0, dw - 24.0, BLUE);
        stat_bar("WET",   driver.wet_skill,   dx + 12.0, dy + 98.0, dw - 24.0, Color::new(0.3, 0.7, 1.0, 1.0));
        let morale_col = if driver.morale > 20 { GREEN } else if driver.morale > -20 { GOLD } else { ACCENT };
        draw_text(&format!("Morale {}", driver.morale), dx + 12.0, dy + 126.0, 14.0, morale_col);
    }

    // Car card
    let cy = dy + 162.0;
    section_header("CAR PERFORMANCE", cy);
    panel(16.0, cy + 14.0, sw() - 32.0, 120.0, PANEL);
    let cw = (sw() - 32.0) / 5.0;
    let car = &team.car;
    for (i, (name, val, col)) in [
        ("CHASSIS",     car.chassis,     ACCENT),
        ("ENGINE",      car.engine,      GOLD),
        ("RELIABILITY", car.reliability, GREEN),
        ("TIRE DEG",    car.tire_deg,    BLUE),
        ("PIT SPEED",   car.pit_speed,   SILVER),
    ].iter().enumerate() {
        let cx = 16.0 + i as f32 * cw;
        stat_bar(name, *val, cx + 4.0, cy + 34.0, cw - 8.0, *col);
    }
    draw_text(&format!("Car Overall: {}", car.performance()), 30.0, cy + 116.0, 16.0, TEXT_DIM);

    // Recent results
    let ry = cy + 152.0;
    section_header("RECENT RESULTS", ry);
    let results_to_show: Vec<_> = team.race_results.iter().rev().take(3).collect();
    for (i, result) in results_to_show.iter().enumerate() {
        let rx = 16.0;
        let rwy = ry + 22.0 + i as f32 * 44.0;
        panel(rx, rwy, sw() - 32.0, 38.0, PANEL);
        draw_text(&format!("R{} {}", result.round, result.circuit), rx + 12.0, rwy + 24.0, 16.0, TEXT_DIM);
        position_badge(result.driver1_pos, rx + 200.0, rwy + 8.0);
        position_badge(result.driver2_pos, rx + 244.0, rwy + 8.0);
        draw_text(&format!("+{} pts", result.driver1_points + result.driver2_points as u8), rx + 296.0, rwy + 24.0, 16.0, GOLD);
        if result.wet_race { draw_text("WET", rx + sw() - 80.0, rwy + 24.0, 14.0, BLUE); }
        if result.fastest_lap { draw_text("FL", rx + sw() - 48.0, rwy + 24.0, 14.0, Color::new(0.6, 0.2, 0.9, 1.0)); }
    }
}

fn draw_roster(gs: &mut GameState) {
    let team = gs.team.as_ref().unwrap();
    clear_background(BG);
    topbar(team, &[]);

    label("DRIVER ROSTER", 30.0, 80.0, 26.0, TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, BORDER);

    for (i, driver) in [&team.driver1, &team.driver2].iter().enumerate() {
        let dy = 110.0 + i as f32 * 240.0;
        panel(16.0, dy, sw() - 32.0, 225.0, PANEL);
        draw_text(&format!("DRIVER {}", i + 1), 30.0, dy + 24.0, 14.0, TEXT_DIM);
        draw_text(&driver.name, 30.0, dy + 54.0, 28.0, TEXT);
        draw_text(&format!("{} • Age {}", driver.nationality, driver.age), 30.0, dy + 78.0, 16.0, TEXT_DIM);

        let hw = (sw() - 64.0) / 2.0;
        stat_bar("PACE",        driver.pace,        30.0, dy + 100.0, hw, ACCENT);
        stat_bar("CONSISTENCY", driver.consistency, 30.0, dy + 120.0, hw, BLUE);
        stat_bar("WET SKILL",   driver.wet_skill,   30.0, dy + 140.0, hw, Color::new(0.3, 0.7, 1.0, 1.0));
        stat_bar("TIRE MGMT",   driver.tire_mgmt,   sw() / 2.0, dy + 100.0, hw, GOLD);
        stat_bar("EXPERIENCE",  driver.experience,  sw() / 2.0, dy + 120.0, hw, GREEN);

        draw_text(&format!("Overall: {}", driver.overall()), 30.0, dy + 168.0, 20.0, ACCENT);
        draw_text(&format!("Salary: ${:.1}M / season", driver.salary as f32 / 1000.0), 200.0, dy + 168.0, 16.0, TEXT_DIM);
        draw_text(&format!("Contract: {} year(s)", driver.contract_years), 400.0, dy + 168.0, 16.0, TEXT_DIM);

        let morale_txt = format!("Morale: {}", driver.morale);
        let mc = if driver.morale > 20 { GREEN } else if driver.morale > -20 { GOLD } else { ACCENT };
        draw_text(&morale_txt, 30.0, dy + 192.0, 16.0, mc);
    }
}

fn draw_car_dev(gs: &mut GameState) {
    let team = gs.team.as_mut().unwrap();
    clear_background(BG);
    topbar(team, &[]);

    label("CAR DEVELOPMENT", 30.0, 80.0, 26.0, TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, BORDER);

    // Current stats
    let car = &team.car;
    let y0 = 110.0;
    for (i, (name, val, col)) in [
        ("CHASSIS",      car.chassis,     ACCENT),
        ("ENGINE",       car.engine,      GOLD),
        ("RELIABILITY",  car.reliability, GREEN),
        ("TIRE DEG",     car.tire_deg,    BLUE),
        ("PIT SPEED",    car.pit_speed,   SILVER),
    ].iter().enumerate() {
        stat_bar(name, *val, 30.0, y0 + i as f32 * 28.0, sw() - 60.0, *col);
    }

    section_header("START R&D PROJECT", y0 + 160.0);

    let projects: &[(&str, &str, &str, u32, u8, u8)] = &[
        ("Aero Package",      "chassis",     "Improved downforce",         3500, 3, 5),
        ("Engine Tokens",     "engine",      "Power unit upgrade",         5000, 4, 7),
        ("Reliability Fix",   "reliability", "Reduce DNF risk",            2000, 2, 4),
        ("Tire Compounds",    "tire_deg",    "Softer deg curves",          2500, 3, 4),
        ("Pitstop Equipment", "pit_speed",   "Faster wheel gun + rig",     1500, 2, 3),
        ("Floor Revision",    "chassis",     "Underfloor ground effect",   4000, 3, 6),
        ("ERS Upgrade",       "engine",      "Harvest/deploy efficiency",  4500, 3, 5),
    ];

    for (i, (name, target, desc, cost, dur, boost)) in projects.iter().enumerate() {
        let py = y0 + 178.0 + i as f32 * 56.0;
        let already = team.rd_projects.iter().any(|p| p.name == *name);
        let can_afford = team.budget >= *cost;
        let col = if already { TEXT_DIM } else if can_afford { GREEN } else { ACCENT };

        panel(16.0, py, sw() - 32.0, 50.0, PANEL);
        draw_text(name, 30.0, py + 20.0, 18.0, TEXT);
        draw_text(desc, 30.0, py + 38.0, 13.0, TEXT_DIM);
        draw_text(&format!("→ {} +{}", target, boost), 320.0, py + 20.0, 15.0, col);
        draw_text(&format!("{} races", dur), 460.0, py + 20.0, 15.0, TEXT_DIM);
        draw_text(&format!("${:.1}M", *cost as f32 / 1000.0), 540.0, py + 20.0, 16.0, if can_afford { GREEN } else { ACCENT });

        if !already {
            if button("START", sw() - 100.0, py + 10.0, 80.0, 30.0, if can_afford { GREEN } else { TEXT_DIM }) {
                if can_afford {
                    team.budget -= cost;
                    team.rd_projects.push(RdProject {
                        name: name.to_string(),
                        target: target.to_string(),
                        cost: *cost,
                        duration: *dur,
                        boost: *boost,
                    });
                }
            }
        } else {
            let proj = team.rd_projects.iter().find(|p| p.name == *name);
            if let Some(p) = proj {
                draw_text(&format!("{} races left", p.duration), sw() - 120.0, py + 26.0, 14.0, GOLD);
            }
        }
    }
}

fn draw_standings(gs: &mut GameState, circuits: &[Circuit]) {
    let team = gs.team.as_ref().unwrap();
    clear_background(BG);
    topbar(team, circuits);

    label("CONSTRUCTORS STANDINGS", 30.0, 80.0, 26.0, TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, BORDER);

    // Build full standings
    let mut all: Vec<(String, u32, Color)> = Vec::new();
    all.push((team.name.clone(), team.standings_points, ACCENT));
    for opp in &gs.opponents {
        all.push((opp.name.clone(), opp.points, opp.color()));
    }
    all.sort_by(|a, b| b.1.cmp(&a.1));

    for (i, (name, pts, col)) in all.iter().enumerate() {
        let y = 108.0 + i as f32 * 46.0;
        let is_player = name == &team.name;
        let bg = if is_player { Color::new(col.r, col.g, col.b, 0.08) } else { PANEL };
        draw_rectangle(16.0, y, sw() - 32.0, 40.0, bg);
        draw_rectangle_lines(16.0, y, sw() - 32.0, 40.0, 1.0,
            if is_player { *col } else { BORDER });

        // Position number
        let pos_col = match i { 0 => GOLD, 1 => SILVER, 2 => BRONZE, _ => TEXT_DIM };
        draw_text(&format!("{}", i + 1), 28.0, y + 26.0, 20.0, pos_col);

        // Team color strip
        draw_rectangle(52.0, y + 6.0, 4.0, 28.0, *col);

        draw_text(name, 64.0, y + 26.0, 18.0, if is_player { TEXT } else { TEXT_DIM });
        if is_player { draw_text("◄ YOU", 64.0 + measure_text(name, None, 18, 1.0).width + 8.0, y + 26.0, 13.0, *col); }

        // Points bar
        let max_pts = all.first().map(|a| a.1).unwrap_or(1).max(1);
        let bar_w = (sw() - 300.0) * (*pts as f32 / max_pts as f32);
        draw_rectangle(200.0, y + 12.0, bar_w, 16.0, Color::new(col.r, col.g, col.b, 0.3));
        draw_text(&format!("{} pts", pts), sw() - 90.0, y + 26.0, 18.0, if is_player { GOLD } else { TEXT_DIM });
    }
}

fn draw_race_weekend(gs: &mut GameState, circuits: &[Circuit]) {
    let team = gs.team.as_ref().unwrap();
    let circuit = &circuits[team.current_round.min(circuits.len() - 1)];
    clear_background(BG);
    topbar(team, circuits);

    label(&format!("RACE WEEKEND — {}", circuit.name), 30.0, 80.0, 26.0, TEXT);
    draw_line(30.0, 90.0, sw() - 30.0, 90.0, 1.0, BORDER);

    // Weather
    let mut rng = thread_rng();
    let wet_label = if gs.race_state.wet { ("WET RACE", BLUE) } else { ("DRY RACE", GREEN) };
    draw_text("CONDITIONS:", 30.0, 116.0, 16.0, TEXT_DIM);
    draw_text(wet_label.0, 130.0, 116.0, 18.0, wet_label.1);

    // Practice
    panel(16.0, 130.0, sw() - 32.0, 80.0, PANEL);
    draw_text("PRACTICE SESSION", 30.0, 152.0, 18.0, TEXT);
    if !gs.race_state.practice_done {
        draw_text("Run practice to get baseline lap times and tire data.", 30.0, 176.0, 14.0, TEXT_DIM);
        if button("RUN PRACTICE", sw() - 200.0, 142.0, 170.0, 36.0, BLUE) {
            gs.race_state.practice_done = true;
            // Wet weather determined here
            gs.race_state.wet = rng.gen::<f32>() < circuit.wet_chance;
        }
    } else {
        draw_text("✓ Practice complete", 30.0, 176.0, 16.0, GREEN);
        draw_text(&format!("Conditions: {}", if gs.race_state.wet { "WET" } else { "DRY" }), 220.0, 176.0, 16.0, if gs.race_state.wet { BLUE } else { TEXT_DIM });
    }

    // Qualifying
    panel(16.0, 222.0, sw() - 32.0, 80.0, PANEL);
    draw_text("QUALIFYING", 30.0, 244.0, 18.0, TEXT);
    if !gs.race_state.qualifying_done {
        if gs.race_state.practice_done {
            draw_text("Set your fastest lap to determine grid position.", 30.0, 268.0, 14.0, TEXT_DIM);
            if button("RUN QUALIFYING", sw() - 200.0, 234.0, 170.0, 36.0, GOLD) {
                gs.race_state.qualifying_done = true;
                let team = gs.team.as_ref().unwrap();
                let q1 = (team.driver1.pace as f32 + rng.gen_range(-8.0..8.0) + team.car.performance() as f32 * 0.3) as i32;
                let q2 = (team.driver2.pace as f32 + rng.gen_range(-8.0..8.0) + team.car.performance() as f32 * 0.3) as i32;
                // Map qualifying score to grid position (1-20)
                gs.race_state.qualifying_pos1 = (20 - (q1 - 30).clamp(0, 19) as u8).max(1);
                gs.race_state.qualifying_pos2 = (20 - (q2 - 28).clamp(0, 19) as u8).max(1);
            }
        } else {
            draw_text("Complete practice first.", 30.0, 268.0, 14.0, TEXT_DIM);
        }
    } else {
        let team = gs.team.as_ref().unwrap();
        draw_text(&format!("P{} — {}", gs.race_state.qualifying_pos1, team.driver1.name), 30.0, 264.0, 16.0, TEXT);
        draw_text(&format!("P{} — {}", gs.race_state.qualifying_pos2, team.driver2.name), 30.0, 284.0, 16.0, TEXT);
    }

    // Strategy
    if gs.race_state.qualifying_done && team.series.pit_stops_required() {
        panel(16.0, 314.0, sw() - 32.0, 130.0, PANEL);
        draw_text("PIT STRATEGY", 30.0, 336.0, 18.0, TEXT);
        let team = gs.team.as_ref().unwrap();

        // Driver 1 strategy
        draw_text(&format!("{}:", team.driver1.name), 30.0, 362.0, 15.0, TEXT_DIM);
        let compounds = if gs.race_state.wet {
            vec![TireCompound::Inter, TireCompound::Wet]
        } else {
            vec![TireCompound::Soft, TireCompound::Medium, TireCompound::Hard]
        };
        let mut x = 160.0;
        for c in &compounds {
            let selected = gs.race_state.strategy1 == *c;
            let col = c.color();
            draw_rectangle(x, 348.0, 60.0, 24.0, if selected { Color::new(col.r, col.g, col.b, 0.3) } else { PANEL2 });
            draw_rectangle_lines(x, 348.0, 60.0, 24.0, 1.0, if selected { col } else { BORDER });
            let tw = measure_text(c.name(), None, 13, 1.0).width;
            draw_text(c.name(), x + (60.0 - tw) / 2.0, 348.0 + 16.0, 13.0, col);
            let mx = mouse_position().0;
            let my = mouse_position().1;
            if mx >= x && mx <= x + 60.0 && my >= 348.0 && my <= 372.0 && is_mouse_button_pressed(MouseButton::Left) {
                gs.race_state.strategy1 = *c;
            }
            x += 68.0;
        }

        // Pit lap slider driver 1
        draw_text("Pit lap:", 30.0, 392.0, 14.0, TEXT_DIM);
        draw_text(&format!("Lap {}", gs.race_state.pit_lap1), 100.0, 392.0, 16.0, GOLD);
        if button("-", 150.0, 378.0, 26.0, 22.0, TEXT_DIM) && gs.race_state.pit_lap1 > 5 {
            gs.race_state.pit_lap1 -= 1;
        }
        if button("+", 180.0, 378.0, 26.0, 22.0, TEXT_DIM) && gs.race_state.pit_lap1 < circuit.laps.saturating_sub(5) {
            gs.race_state.pit_lap1 += 1;
        }

        // Driver 2 strategy (same compounds)
        draw_text(&format!("{}:", team.driver2.name), 30.0, 420.0, 15.0, TEXT_DIM);
        x = 160.0;
        for c in &compounds {
            let selected = gs.race_state.strategy2 == *c;
            let col = c.color();
            draw_rectangle(x, 406.0, 60.0, 24.0, if selected { Color::new(col.r, col.g, col.b, 0.3) } else { PANEL2 });
            draw_rectangle_lines(x, 406.0, 60.0, 24.0, 1.0, if selected { col } else { BORDER });
            let tw = measure_text(c.name(), None, 13, 1.0).width;
            draw_text(c.name(), x + (60.0 - tw) / 2.0, 406.0 + 16.0, 13.0, col);
            let mx = mouse_position().0;
            let my = mouse_position().1;
            if mx >= x && mx <= x + 60.0 && my >= 406.0 && my <= 430.0 && is_mouse_button_pressed(MouseButton::Left) {
                gs.race_state.strategy2 = *c;
            }
            x += 68.0;
        }

        // Pit lap slider driver 2
        draw_text("Pit lap:", 30.0, 448.0, 14.0, TEXT_DIM);
        draw_text(&format!("Lap {}", gs.race_state.pit_lap2), 100.0, 448.0, 16.0, GOLD);
        if button("-", 150.0, 434.0, 26.0, 22.0, TEXT_DIM) && gs.race_state.pit_lap2 > 5 {
            gs.race_state.pit_lap2 -= 1;
        }
        if button("+", 180.0, 434.0, 26.0, 22.0, TEXT_DIM) && gs.race_state.pit_lap2 < circuit.laps.saturating_sub(5) {
            gs.race_state.pit_lap2 += 1;
        }
    }

    // Race button
    let ry = if team.series.pit_stops_required() { sh() - 70.0 } else { 460.0 };
    let can_race = gs.race_state.qualifying_done;
    if can_race {
        if button("⚑  START RACE", sw() / 2.0 - 140.0, ry, 280.0, 50.0, ACCENT) {
            gs.screen = Screen::RaceSimulation;
            gs.race_state.sim_progress = 0.0;
            gs.race_state.sim_done = false;
            gs.race_state.log.clear();
        }
    } else {
        draw_text("Complete qualifying to unlock race start.", sw() / 2.0 - 180.0, ry + 20.0, 16.0, TEXT_DIM);
    }
}

fn draw_race_simulation(gs: &mut GameState, circuits: &[Circuit]) {
    clear_background(BG);

    let team_name = gs.team.as_ref().unwrap().name.clone();
    draw_text("RACE IN PROGRESS", 30.0, 50.0, 28.0, ACCENT);
    draw_line(30.0, 62.0, sw() - 30.0, 62.0, 1.0, BORDER);

    let circuit_name = {
        let team = gs.team.as_ref().unwrap();
        circuits[team.current_round.min(circuits.len() - 1)].name.clone()
    };
    draw_text(&circuit_name, 30.0, 90.0, 20.0, TEXT_DIM);

    // Progress bar
    draw_rectangle(30.0, 110.0, sw() - 60.0, 18.0, PANEL2);
    draw_rectangle(30.0, 110.0, (sw() - 60.0) * gs.race_state.sim_progress, 18.0, ACCENT);
    draw_rectangle_lines(30.0, 110.0, sw() - 60.0, 18.0, 1.0, BORDER);
    draw_text(&format!("{:.0}%", gs.race_state.sim_progress * 100.0), sw() / 2.0 - 16.0, 124.0, 14.0, TEXT);

    // Advance simulation
    if !gs.race_state.sim_done {
        gs.race_state.sim_progress += get_frame_time() * 0.4;
        if gs.race_state.sim_progress >= 1.0 {
            gs.race_state.sim_progress = 1.0;
            gs.race_state.sim_done = true;

            // Run actual simulation
            let mut rng = thread_rng();
            let rs = gs.race_state.clone();
            let circuits_clone = circuits.to_vec();
            let result = {
                let team = gs.team.as_mut().unwrap();
                simulate_race(team, &mut gs.opponents, &rs, &circuits_clone, &mut rng)
            };

            // Build log
            let team = gs.team.as_ref().unwrap();
            gs.race_state.log.push(format!("RACE OVER — {}", circuit_name));
            gs.race_state.log.push(format!("{} finished P{} (+{} pts)",
                team.driver1.name, result.driver1_pos, result.driver1_points));
            gs.race_state.log.push(format!("{} finished P{} (+{} pts)",
                team.driver2.name, result.driver2_pos, result.driver2_points));
            for pit in &result.pit_stops { gs.race_state.log.push(pit.clone()); }
            if let Some(dnf) = result.dnf_driver {
                let dnf_name = if dnf == 1 { &team.driver1.name } else { &team.driver2.name };
                gs.race_state.log.push(format!("⚠ DNF — {} retired", dnf_name));
            }
            if result.fastest_lap { gs.race_state.log.push("★ Fastest lap bonus point".into()); }
            gs.race_state.result = Some(result.clone());
            let team = gs.team.as_mut().unwrap();
            team.race_results.push(result);
            save_game(gs);
        }
    }

    // Lap-by-lap log (simulated)
    let total_laps = {
        let team = gs.team.as_ref().unwrap();
        circuits[team.current_round.saturating_sub(1).min(circuits.len() - 1)].laps as f32
    };
    let cur_lap = (gs.race_state.sim_progress * total_laps) as u32;

    if !gs.race_state.sim_done {
        // Animated lap counter
        draw_text(&format!("LAP {} / {}", cur_lap, total_laps as u32), sw() / 2.0 - 40.0, 160.0, 22.0, GOLD);
        // Fake positions during sim
        let fake_p1 = ((1.0 - gs.race_state.sim_progress) * 8.0 + 1.0) as u8;
        let fake_p2 = ((1.0 - gs.race_state.sim_progress) * 10.0 + 2.0) as u8;
        draw_text(&format!("{} — P{}", team_name, fake_p1.max(1)), 30.0, 200.0, 18.0, ACCENT);
        draw_text(&format!("Driver 2 — P{}", fake_p2.max(2)), 30.0, 226.0, 18.0, TEXT_DIM);

        // Pit stop messages at appropriate laps
        if (cur_lap as u16) == gs.race_state.pit_lap1 {
            draw_text("⬛ DRIVER 1 IN THE PITS", 30.0, 260.0, 18.0, GOLD);
        }
        if (cur_lap as u16) == gs.race_state.pit_lap2 {
            draw_text("⬛ DRIVER 2 IN THE PITS", 30.0, 284.0, 18.0, GOLD);
        }
    } else {
        // Show results log
        for (i, line) in gs.race_state.log.iter().enumerate() {
            let col = if i == 0 { GOLD }
                else if line.starts_with("⚠") { ACCENT }
                else if line.starts_with("★") { Color::new(0.7, 0.3, 0.9, 1.0) }
                else { TEXT };
            draw_text(line, 30.0, 160.0 + i as f32 * 28.0, 18.0, col);
        }

        if button("VIEW RESULTS  →", sw() / 2.0 - 130.0, sh() - 80.0, 260.0, 50.0, ACCENT) {
            gs.screen = Screen::Results;
        }
    }
}

fn draw_results(gs: &mut GameState, circuits: &[Circuit]) {
    clear_background(BG);
    let team = gs.team.as_ref().unwrap();

    if let Some(ref r) = gs.race_state.result.clone() {
        draw_text(&format!("RACE RESULTS — {}", r.circuit), 30.0, 50.0, 26.0, TEXT);
        draw_line(30.0, 62.0, sw() - 30.0, 62.0, 1.0, BORDER);

        // Podium style display for team drivers
        for (i, (pos, pts, name)) in [
            (r.driver1_pos, r.driver1_points, &team.driver1.name),
            (r.driver2_pos, r.driver2_points, &team.driver2.name),
        ].iter().enumerate() {
            let dy = 80.0 + i as f32 * 90.0;
            panel(16.0, dy, sw() - 32.0, 80.0, PANEL);
            position_badge(*pos, 26.0, dy + 28.0);
            draw_text(name, 80.0, dy + 32.0, 22.0, TEXT);
            draw_text(&format!("+{} pts", pts), 80.0, dy + 58.0, 18.0, GOLD);
            if r.wet_race { tire_badge(TireCompound::Wet, 300.0, dy + 30.0); }
            if let Some(dnf) = r.dnf_driver {
                if dnf as usize == i + 1 {
                    draw_text("DNF", sw() - 80.0, dy + 44.0, 22.0, ACCENT);
                }
            }
        }

        // Pit stop log
        let py = 270.0;
        section_header("PIT STOPS", py);
        for (i, line) in r.pit_stops.iter().enumerate() {
            draw_text(line, 30.0, py + 24.0 + i as f32 * 22.0, 15.0, TEXT_DIM);
        }

        // Team summary
        let sy = 370.0;
        section_header("TEAM SUMMARY", sy);
        panel(16.0, sy + 14.0, sw() - 32.0, 90.0, PANEL);
        draw_text(&format!("Total Points: {}", team.standings_points), 30.0, sy + 40.0, 20.0, GOLD);
        draw_text(&format!("Budget: ${:.1}M", team.budget as f32 / 1000.0), 30.0, sy + 66.0, 18.0, GREEN);
        draw_text(&format!("Round: {}/{}", team.current_round, circuits.len()), 300.0, sy + 40.0, 18.0, TEXT_DIM);
    }

    let btn_label = {
        let team = gs.team.as_ref().unwrap();
        if team.current_round >= circuits.len() { "SEASON OVER — BACK TO MENU" } else { "NEXT ROUND  →" }
    };
    if button(btn_label, sw() / 2.0 - 140.0, sh() - 70.0, 280.0, 50.0, ACCENT) {
        let at_end = gs.team.as_ref().unwrap().current_round >= circuits.len();
        if at_end {
            gs.screen = Screen::MainMenu;
            gs.team = None;
        } else {
            gs.race_state = RaceWeekendState::default();
            gs.screen = Screen::Dashboard;
            gs.tab = 0;
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════════

#[macroquad::main("The Racer")]
async fn main() {
    let mut gs = GameState::new();
    let mut circuits: Vec<Circuit> = Vec::new();

    loop {
        // Update message timer
        if let Some((_, ref mut t)) = gs.msg {
            *t -= get_frame_time();
        }
        if gs.msg.as_ref().map(|(_, t)| *t <= 0.0).unwrap_or(false) {
            gs.msg = None;
        }

        // Rebuild circuits when series changes
        if let Some(ref team) = gs.team {
            if circuits.is_empty() || circuits.len() != team.series.rounds() {
                circuits = circuits_for(&team.series);
            }
        }

        match gs.screen.clone() {
            Screen::MainMenu    => draw_main_menu(&mut gs),
            Screen::SeriesSelect => draw_series_select(&mut gs),
            Screen::TeamSetup   => draw_team_setup(&mut gs),
            Screen::Dashboard   => {
                let circs = circuits.clone();
                let go_race = bottom_nav(&mut gs, &circs);
                match gs.tab {
                    0 => draw_dashboard(&mut gs, &circs),
                    1 => draw_roster(&mut gs),
                    2 => draw_car_dev(&mut gs),
                    3 => draw_standings(&mut gs, &circs),
                    _ => draw_dashboard(&mut gs, &circs),
                }
                if go_race {
                    gs.screen = Screen::RaceWeekend;
                    gs.race_state = RaceWeekendState::default();
                }
            }
            Screen::Roster      => {
                let circs = circuits.clone();
                bottom_nav(&mut gs, &circs);
                draw_roster(&mut gs);
            }
            Screen::CarDev      => {
                let circs = circuits.clone();
                bottom_nav(&mut gs, &circs);
                draw_car_dev(&mut gs);
            }
            Screen::Standings   => {
                let circs = circuits.clone();
                bottom_nav(&mut gs, &circs);
                draw_standings(&mut gs, &circs);
            }
            Screen::RaceWeekend => {
                let circs = circuits.clone();
                draw_race_weekend(&mut gs, &circs);
            }
            Screen::RaceStrategy => {}
            Screen::RaceSimulation => {
                let circs = circuits.clone();
                draw_race_simulation(&mut gs, &circs);
            }
            Screen::Results => {
                let circs = circuits.clone();
                draw_results(&mut gs, &circs);
            }
        }

        next_frame().await;
    }
}
