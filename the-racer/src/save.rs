use serde::{Deserialize, Serialize};
use std::fs;
use crate::types::*;

const SAVE_FILE: &str = "the-racer-save.json";

#[derive(Serialize, Deserialize)]
pub struct SaveData {
    pub team: Team,
    pub opponent_points: Vec<u32>,
}

pub fn save_game(gs: &AppState) {
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

pub fn load_game(gs: &mut AppState, generate_opponents: &dyn Fn(&Series) -> Vec<OpponentTeam>) -> bool {
    if let Ok(json) = fs::read_to_string(SAVE_FILE) {
        if let Ok(data) = serde_json::from_str::<SaveData>(&json) {
            let series = data.team.series.clone();
            gs.opponents = generate_opponents(&series);
            for (i, pts) in data.opponent_points.iter().enumerate() {
                if let Some(opp) = gs.opponents.get_mut(i) { opp.points = *pts; }
            }
            gs.team = Some(data.team);
            gs.screen = Screen::Dashboard;
            return true;
        }
    }
    false
}
