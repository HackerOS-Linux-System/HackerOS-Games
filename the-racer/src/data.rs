use rand_crate::{thread_rng, Rng};
use crate::types::*;

pub fn default_driver(name: &str, nationality: &str, pace: u8, salary: u32) -> Driver {
    let mut rng = thread_rng();
    Driver {
        name: name.to_string(),
        nationality: nationality.to_string(),
        age: rng.gen_range(20..38),
        pace,
        consistency: rng.gen_range(60..92),
        wet_skill: rng.gen_range(55..92),
        tire_mgmt: rng.gen_range(55..88),
        experience: rng.gen_range(30..85),
        salary,
        morale: 50,
        contract_years: rng.gen_range(1..4),
        career_wins: rng.gen_range(0..20),
        races: rng.gen_range(30..200),
    }
}

pub fn new_team(name: String, d1: String, d2: String, series: Series) -> Team {
    Team {
        name,
        budget: 50_000,
        driver1: default_driver(&d1, "PL", 72, 800),
        driver2: default_driver(&d2, "PL", 68, 600),
        car: Car { chassis: 60, engine: 62, reliability: 65, tire_deg: 60, pit_speed: 65, aero_balance: 50 },
        rd_projects: Vec::new(),
        standings_points: 0,
        race_results: Vec::new(),
        series,
        current_round: 0,
    }
}

pub fn generate_opponents(series: &Series) -> Vec<OpponentTeam> {
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
            ("Penske",       90, 1.0, 0.1, 0.1),
            ("Ganassi",      88, 0.1, 0.4, 0.9),
            ("Andretti",     85, 0.2, 0.6, 0.8),
            ("Arrow McLaren",82, 1.0, 0.5, 0.0),
            ("Rahal",        78, 0.3, 0.6, 0.9),
            ("AJ Foyt",      72, 0.9, 0.4, 0.1),
        ],
        Series::FormulaE => &[
            ("Porsche",    88, 0.8, 0.1, 0.1),
            ("Jaguar",     85, 0.0, 0.6, 0.3),
            ("Nissan",     82, 0.8, 0.1, 0.5),
            ("DS Penske",  80, 0.2, 0.2, 0.8),
            ("Maserati",   78, 0.7, 0.1, 0.1),
            ("Envision",   74, 0.0, 0.5, 0.8),
        ],
        Series::WEC => &[
            ("Toyota Gazoo",  93, 0.9, 0.1, 0.1),
            ("Ferrari AF",    88, 0.9, 0.1, 0.1),
            ("Peugeot",       84, 0.0, 0.3, 0.7),
            ("Porsche LMDh",  86, 0.8, 0.1, 0.1),
            ("BMW M Team",    80, 0.0, 0.2, 0.8),
        ],
        Series::GT3 => &[
            ("Ferrari GT3",    85, 0.9, 0.1, 0.1),
            ("Porsche GT3",    84, 0.8, 0.1, 0.1),
            ("BMW M4 GT3",     82, 0.0, 0.2, 0.8),
            ("Aston Vantage",  80, 0.0, 0.6, 0.3),
            ("McLaren GT3",    79, 1.0, 0.5, 0.0),
            ("Lamborghini GT3",78, 0.9, 0.5, 0.0),
        ],
    };
    data.iter().map(|(name, str, r, g, b)| OpponentTeam {
        name: name.to_string(), strength: *str, points: 0,
        color_r: *r, color_g: *g, color_b: *b,
    }).collect()
}

pub fn circuits_for(series: &Series) -> Vec<Circuit> {
    match series {
        Series::Formula1 => vec![
            Circuit { name: "Bahrain".into(),     country: "BHR".into(), laps: 57,  pit_delta: 22.0, wet_chance: 0.05, overtake_diff: 1.1, tire_stress: 1.2, high_speed: false },
            Circuit { name: "Saudi Arabia".into(), country: "KSA".into(),laps: 50,  pit_delta: 20.0, wet_chance: 0.03, overtake_diff: 0.7, tire_stress: 1.1, high_speed: true  },
            Circuit { name: "Australia".into(),   country: "AUS".into(), laps: 58,  pit_delta: 23.0, wet_chance: 0.25, overtake_diff: 0.9, tire_stress: 1.0, high_speed: false },
            Circuit { name: "Japan".into(),       country: "JPN".into(), laps: 53,  pit_delta: 21.0, wet_chance: 0.35, overtake_diff: 0.8, tire_stress: 1.3, high_speed: true  },
            Circuit { name: "China".into(),       country: "CHN".into(), laps: 56,  pit_delta: 22.0, wet_chance: 0.20, overtake_diff: 1.0, tire_stress: 1.1, high_speed: false },
            Circuit { name: "Miami".into(),       country: "USA".into(), laps: 57,  pit_delta: 21.0, wet_chance: 0.15, overtake_diff: 1.2, tire_stress: 1.2, high_speed: false },
            Circuit { name: "Imola".into(),       country: "ITA".into(), laps: 63,  pit_delta: 24.0, wet_chance: 0.30, overtake_diff: 0.6, tire_stress: 1.0, high_speed: false },
            Circuit { name: "Monaco".into(),      country: "MCO".into(), laps: 78,  pit_delta: 26.0, wet_chance: 0.25, overtake_diff: 0.3, tire_stress: 0.7, high_speed: false },
            Circuit { name: "Canada".into(),      country: "CAN".into(), laps: 70,  pit_delta: 22.0, wet_chance: 0.30, overtake_diff: 1.3, tire_stress: 1.0, high_speed: false },
            Circuit { name: "Spain".into(),       country: "ESP".into(), laps: 66,  pit_delta: 21.0, wet_chance: 0.10, overtake_diff: 0.8, tire_stress: 1.3, high_speed: true  },
            Circuit { name: "Austria".into(),     country: "AUT".into(), laps: 71,  pit_delta: 20.0, wet_chance: 0.30, overtake_diff: 1.2, tire_stress: 1.1, high_speed: true  },
            Circuit { name: "Silverstone".into(), country: "GBR".into(), laps: 52,  pit_delta: 21.0, wet_chance: 0.40, overtake_diff: 1.1, tire_stress: 1.2, high_speed: true  },
            Circuit { name: "Hungary".into(),     country: "HUN".into(), laps: 70,  pit_delta: 22.0, wet_chance: 0.20, overtake_diff: 0.7, tire_stress: 1.1, high_speed: false },
            Circuit { name: "Belgium".into(),     country: "BEL".into(), laps: 44,  pit_delta: 21.0, wet_chance: 0.45, overtake_diff: 1.0, tire_stress: 1.2, high_speed: true  },
            Circuit { name: "Netherlands".into(), country: "NLD".into(), laps: 72,  pit_delta: 22.0, wet_chance: 0.25, overtake_diff: 0.7, tire_stress: 1.2, high_speed: false },
            Circuit { name: "Monza".into(),       country: "ITA".into(), laps: 53,  pit_delta: 22.0, wet_chance: 0.20, overtake_diff: 1.4, tire_stress: 0.8, high_speed: true  },
            Circuit { name: "Azerbaijan".into(),  country: "AZE".into(), laps: 51,  pit_delta: 20.0, wet_chance: 0.08, overtake_diff: 1.3, tire_stress: 0.9, high_speed: true  },
            Circuit { name: "Singapore".into(),   country: "SGP".into(), laps: 61,  pit_delta: 24.0, wet_chance: 0.35, overtake_diff: 0.6, tire_stress: 1.0, high_speed: false },
            Circuit { name: "Austin".into(),      country: "USA".into(), laps: 56,  pit_delta: 22.0, wet_chance: 0.20, overtake_diff: 1.1, tire_stress: 1.2, high_speed: false },
            Circuit { name: "Mexico City".into(), country: "MEX".into(), laps: 71,  pit_delta: 22.0, wet_chance: 0.10, overtake_diff: 1.0, tire_stress: 0.9, high_speed: true  },
            Circuit { name: "São Paulo".into(),   country: "BRA".into(), laps: 71,  pit_delta: 22.0, wet_chance: 0.40, overtake_diff: 1.1, tire_stress: 1.0, high_speed: false },
            Circuit { name: "Las Vegas".into(),   country: "USA".into(), laps: 50,  pit_delta: 20.0, wet_chance: 0.05, overtake_diff: 1.3, tire_stress: 1.0, high_speed: true  },
            Circuit { name: "Qatar".into(),       country: "QAT".into(), laps: 57,  pit_delta: 21.0, wet_chance: 0.02, overtake_diff: 0.9, tire_stress: 1.5, high_speed: true  },
            Circuit { name: "Abu Dhabi".into(),   country: "UAE".into(), laps: 58,  pit_delta: 22.0, wet_chance: 0.02, overtake_diff: 0.8, tire_stress: 1.0, high_speed: false },
        ],
        Series::IndyCar => (0..17).map(|i| Circuit {
            name: format!("Round {}", i + 1), country: "USA".into(),
            laps: 200, pit_delta: 12.0, wet_chance: 0.20,
            overtake_diff: 1.5, tire_stress: 1.0, high_speed: true,
        }).collect(),
        Series::FormulaE => (0..16).map(|i| Circuit {
            name: format!("E-Prix R{}", i + 1), country: "INT".into(),
            laps: 30, pit_delta: 0.0, wet_chance: 0.25,
            overtake_diff: 1.1, tire_stress: 0.5, high_speed: false,
        }).collect(),
        Series::WEC => vec![
            Circuit { name: "Sebring".into(),   country: "USA".into(), laps: 350, pit_delta: 60.0, wet_chance: 0.25, overtake_diff: 1.2, tire_stress: 1.4, high_speed: false },
            Circuit { name: "Portimão".into(),  country: "PRT".into(), laps: 280, pit_delta: 55.0, wet_chance: 0.30, overtake_diff: 1.0, tire_stress: 1.2, high_speed: false },
            Circuit { name: "Spa".into(),       country: "BEL".into(), laps: 210, pit_delta: 55.0, wet_chance: 0.45, overtake_diff: 1.1, tire_stress: 1.2, high_speed: true  },
            Circuit { name: "Le Mans".into(),   country: "FRA".into(), laps: 380, pit_delta: 70.0, wet_chance: 0.30, overtake_diff: 1.3, tire_stress: 1.0, high_speed: true  },
            Circuit { name: "Monza".into(),     country: "ITA".into(), laps: 300, pit_delta: 50.0, wet_chance: 0.20, overtake_diff: 1.4, tire_stress: 0.8, high_speed: true  },
            Circuit { name: "Fuji".into(),      country: "JPN".into(), laps: 260, pit_delta: 55.0, wet_chance: 0.40, overtake_diff: 1.0, tire_stress: 1.1, high_speed: false },
            Circuit { name: "Bahrain".into(),   country: "BHR".into(), laps: 300, pit_delta: 55.0, wet_chance: 0.05, overtake_diff: 1.1, tire_stress: 1.2, high_speed: false },
            Circuit { name: "Qatar".into(),     country: "QAT".into(), laps: 320, pit_delta: 55.0, wet_chance: 0.02, overtake_diff: 0.9, tire_stress: 1.3, high_speed: true  },
        ],
        Series::GT3 => (0..12).map(|i| Circuit {
            name: format!("Round {}", i + 1), country: "EUR".into(),
            laps: 100, pit_delta: 30.0, wet_chance: 0.30,
            overtake_diff: 1.1, tire_stress: 1.0, high_speed: false,
        }).collect(),
    }
}

/// Free agent drivers available for signing in the contract market.
pub fn free_agents() -> Vec<Driver> {
    vec![
        default_driver("Lucas Bauer",    "DEU", 80, 1200),
        default_driver("Takumi Sato",    "JPN", 78, 1000),
        default_driver("Carlos Vega",    "MEX", 76, 900),
        default_driver("Elise Moreau",   "FRA", 74, 850),
        default_driver("Jack Harrington","GBR", 82, 1400),
        default_driver("Andrei Volkov",  "RUS", 73, 800),
        default_driver("Priya Sharma",   "IND", 77, 950),
        default_driver("Björn Lindqvist","SWE", 75, 875),
        default_driver("Omar Al-Rashid", "KSA", 71, 750),
        default_driver("Yuki Matsuda",   "JPN", 84, 1600),
    ]
}
