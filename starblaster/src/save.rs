use std::fs;
use crate::types::*;

const SAVE_PATH: &str = "starblaster-save.json";
const HISCORE_PATH: &str = "starblaster-hiscore.json";

pub fn save_game(player: &PlayerState, enemies: &[EnemyData], bullets: &[Bullet], director: &Director) {
    let data = GameSave {
        player: *player,
        enemies: enemies.to_vec(),
        bullets: bullets.to_vec(),
        difficulty: director.difficulty,
        wave: director.wave,
    };
    if let Ok(json) = serde_json::to_string(&data) { fs::write(SAVE_PATH, json).ok(); }
}

pub fn load_game() -> Option<GameSave> {
    fs::read_to_string(SAVE_PATH).ok().and_then(|s| serde_json::from_str(&s).ok())
}

pub fn save_hiscore(score: i32) {
    fs::write(HISCORE_PATH, score.to_string()).ok();
}

pub fn load_hiscore() -> i32 {
    fs::read_to_string(HISCORE_PATH).ok()
        .and_then(|s| s.trim().parse().ok())
        .unwrap_or(0)
}
