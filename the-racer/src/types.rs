use macroquad::prelude::*;
use serde::{Deserialize, Serialize};
use rand_crate::Rng;

// ── Colors ────────────────────────────────────────────────────────────────────
pub const C_BG:       Color = Color::new(0.04, 0.04, 0.08, 1.0);
pub const C_PANEL:    Color = Color::new(0.08, 0.08, 0.14, 1.0);
pub const C_PANEL2:   Color = Color::new(0.11, 0.11, 0.19, 1.0);
pub const C_ACCENT:   Color = Color::new(0.95, 0.15, 0.10, 1.0);
pub const C_GOLD:     Color = Color::new(1.00, 0.80, 0.00, 1.0);
pub const C_SILVER:   Color = Color::new(0.75, 0.75, 0.80, 1.0);
pub const C_BRONZE:   Color = Color::new(0.80, 0.50, 0.20, 1.0);
pub const C_GREEN:    Color = Color::new(0.10, 0.90, 0.30, 1.0);
pub const C_BLUE:     Color = Color::new(0.20, 0.60, 1.00, 1.0);
pub const C_TEXT:     Color = Color::new(0.90, 0.90, 0.95, 1.0);
pub const C_TEXT_DIM: Color = Color::new(0.45, 0.50, 0.58, 1.0);
pub const C_BORDER:   Color = Color::new(0.18, 0.20, 0.28, 1.0);

// ── Enums ─────────────────────────────────────────────────────────────────────

#[derive(Clone, Serialize, Deserialize, PartialEq)]
pub enum Series {
    Formula1,
    IndyCar,
    FormulaE,
    WEC,
    GT3,
}

impl Series {
    pub fn name(&self) -> &str {
        match self {
            Series::Formula1  => "Formula 1 — 2026 Season",
            Series::IndyCar   => "IndyCar Series",
            Series::FormulaE  => "ABB Formula E",
            Series::WEC       => "FIA World Endurance Championship",
            Series::GT3       => "GT3 European Series",
        }
    }
    pub fn short(&self) -> &str {
        match self {
            Series::Formula1 => "F1",
            Series::IndyCar  => "IndyCar",
            Series::FormulaE => "FE",
            Series::WEC      => "WEC",
            Series::GT3      => "GT3",
        }
    }
    pub fn color(&self) -> Color {
        match self {
            Series::Formula1  => C_ACCENT,
            Series::IndyCar   => Color::new(0.2, 0.7, 1.0, 1.0),
            Series::FormulaE  => Color::new(0.1, 0.9, 0.5, 1.0),
            Series::WEC       => Color::new(0.9, 0.6, 0.1, 1.0),
            Series::GT3       => Color::new(0.7, 0.2, 0.9, 1.0),
        }
    }
    pub fn rounds(&self) -> usize {
        match self {
            Series::Formula1  => 24,
            Series::IndyCar   => 17,
            Series::FormulaE  => 16,
            Series::WEC       => 8,
            Series::GT3       => 12,
        }
    }
    pub fn pit_stops_required(&self) -> bool { !matches!(self, Series::FormulaE) }
    pub fn has_endurance(&self) -> bool { matches!(self, Series::WEC) }
}

#[derive(Clone, Copy, Serialize, Deserialize, PartialEq)]
pub enum TireCompound { Soft, Medium, Hard, Inter, Wet }

impl TireCompound {
    pub fn name(&self) -> &str {
        match self {
            TireCompound::Soft   => "SOFT",
            TireCompound::Medium => "MEDIUM",
            TireCompound::Hard   => "HARD",
            TireCompound::Inter  => "INTER",
            TireCompound::Wet    => "WET",
        }
    }
    pub fn color(&self) -> Color {
        match self {
            TireCompound::Soft   => Color::new(0.9, 0.1, 0.1, 1.0),
            TireCompound::Medium => Color::new(0.9, 0.8, 0.1, 1.0),
            TireCompound::Hard   => Color::new(0.85, 0.85, 0.85, 1.0),
            TireCompound::Inter  => Color::new(0.1, 0.7, 0.1, 1.0),
            TireCompound::Wet    => Color::new(0.1, 0.4, 0.9, 1.0),
        }
    }
    pub fn deg_rate(&self) -> f32 {
        match self {
            TireCompound::Soft => 3.5, TireCompound::Medium => 2.0,
            TireCompound::Hard => 1.0, TireCompound::Inter  => 1.5, TireCompound::Wet => 1.2,
        }
    }
    pub fn pace_bonus(&self) -> f32 {
        match self {
            TireCompound::Soft => 8.0, TireCompound::Medium => 4.0,
            TireCompound::Hard => 0.0, TireCompound::Inter  => 3.0, TireCompound::Wet => 1.0,
        }
    }
}

// ── Data Structs ──────────────────────────────────────────────────────────────

#[derive(Clone, Serialize, Deserialize)]
pub struct Driver {
    pub name: String,
    pub nationality: String,
    pub age: u8,
    pub pace: u8,
    pub consistency: u8,
    pub wet_skill: u8,
    pub tire_mgmt: u8,
    pub experience: u8,
    pub salary: u32,
    pub morale: i8,
    pub contract_years: u8,
    /// Championship wins
    pub career_wins: u32,
    /// Number of races completed
    pub races: u32,
}

impl Driver {
    pub fn overall(&self) -> u8 {
        ((self.pace as u32 + self.consistency as u32 + self.wet_skill as u32
            + self.tire_mgmt as u32 + self.experience as u32) / 5) as u8
    }

    pub fn race_performance(&self, wet: bool, rng: &mut impl Rng) -> f32 {
        let base = if wet {
            self.pace as f32 * 0.4 + self.wet_skill as f32 * 0.6
        } else {
            self.pace as f32 * 0.6 + self.consistency as f32 * 0.4
        };
        let variance = rng.gen_range(-8.0..8.0);
        let morale_bonus = self.morale as f32 * 0.05;
        // Experience gives a small edge in tighter battles
        let exp_bonus = self.experience as f32 * 0.04;
        (base + variance + morale_bonus + exp_bonus).clamp(0.0, 105.0)
    }
}

#[derive(Clone, Serialize, Deserialize)]
pub struct Car {
    pub chassis: u8,
    pub engine: u8,
    pub reliability: u8,
    pub tire_deg: u8,
    pub pit_speed: u8,
    /// Aero balance (0=understeer, 100=oversteer), affects high-speed vs low-speed circuits
    pub aero_balance: u8,
}

impl Car {
    pub fn performance(&self) -> u8 {
        ((self.chassis as u32 + self.engine as u32 + self.reliability as u32) / 3) as u8
    }
}

#[derive(Clone, Serialize, Deserialize)]
pub struct RdProject {
    pub name: String,
    pub target: String,
    pub cost: u32,
    pub duration: u8,
    pub boost: u8,
}

#[derive(Clone, Serialize, Deserialize)]
pub struct Circuit {
    pub name: String,
    pub country: String,
    pub laps: u16,
    pub pit_delta: f32,
    pub wet_chance: f32,
    pub overtake_diff: f32,
    pub tire_stress: f32,
    /// High-speed biased? True = rewards high chassis, False = rewards low-speed
    pub high_speed: bool,
}

#[derive(Clone, Serialize, Deserialize)]
pub struct RaceResult {
    pub round: usize,
    pub circuit: String,
    pub driver1_pos: u8,
    pub driver2_pos: u8,
    pub driver1_points: u8,
    pub driver2_points: u8,
    pub fastest_lap: bool,
    pub dnf_driver: Option<u8>,
    pub wet_race: bool,
    pub pit_stops: Vec<String>,
}

#[derive(Clone, Serialize, Deserialize)]
pub struct Team {
    pub name: String,
    pub budget: u32,
    pub driver1: Driver,
    pub driver2: Driver,
    pub car: Car,
    pub rd_projects: Vec<RdProject>,
    pub standings_points: u32,
    pub race_results: Vec<RaceResult>,
    pub series: Series,
    pub current_round: usize,
}

impl Team {
    pub fn weekly_costs(&self) -> u32 {
        (self.driver1.salary + self.driver2.salary) / 24 + 500
    }
}

#[derive(Clone, Serialize, Deserialize)]
pub struct OpponentTeam {
    pub name: String,
    pub strength: u8,
    pub points: u32,
    pub color_r: f32,
    pub color_g: f32,
    pub color_b: f32,
}

impl OpponentTeam {
    pub fn color(&self) -> Color {
        Color::new(self.color_r, self.color_g, self.color_b, 1.0)
    }
}

// ── Game State ────────────────────────────────────────────────────────────────

#[derive(PartialEq, Clone)]
pub enum Screen {
    MainMenu,
    SeriesSelect,
    TeamSetup,
    Dashboard,
    Roster,
    CarDev,
    RaceWeekend,
    RaceSimulation,
    Results,
    Standings,
    ContractMarket,
}

#[derive(Clone)]
pub struct RaceWeekendState {
    pub practice_done: bool,
    pub qualifying_done: bool,
    pub qualifying_pos1: u8,
    pub qualifying_pos2: u8,
    pub strategy1: TireCompound,
    pub strategy2: TireCompound,
    pub pit_lap1: u16,
    pub pit_lap2: u16,
    pub wet: bool,
    pub sim_progress: f32,
    pub sim_done: bool,
    pub result: Option<RaceResult>,
    pub log: Vec<String>,
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

pub struct AppState {
    pub screen: Screen,
    pub team: Option<Team>,
    pub opponents: Vec<OpponentTeam>,
    pub race_state: RaceWeekendState,
    pub scroll: f32,
    pub input_buf: String,
    pub setup_step: usize,
    pub setup_name: String,
    pub setup_driver1: String,
    pub setup_driver2: String,
    pub msg: Option<(String, f32)>,
    pub selected_series: Option<Series>,
    pub selected_rd: Option<usize>,
    pub tab: usize,
    /// Notification after contract signed
    pub contract_msg: Option<String>,
}

impl AppState {
    pub fn new() -> Self {
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
            contract_msg: None,
        }
    }

    pub fn show_msg(&mut self, msg: &str) {
        self.msg = Some((msg.to_string(), 3.0));
    }
}

pub fn points_for_pos(pos: u8) -> u8 {
    match pos {
        1 => 25, 2 => 18, 3 => 15, 4 => 12,
        5 => 10, 6 => 8,  7 => 6,  8 => 4,
        9 => 2,  10 => 1, _ => 0,
    }
}
