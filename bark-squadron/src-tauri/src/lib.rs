use serde::{Deserialize, Serialize};
use std::fs;
use std::sync::Mutex;
use tauri::State;

#[derive(Debug, Serialize, Deserialize, Clone, Default)]
#[serde(rename_all = "camelCase")]
pub struct HighScore {
    pub score: u32,
    pub wave: u32,
    pub kills: u32,
    pub difficulty: String,
    pub timestamp: u64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct GamePrefs {
    #[serde(default = "default_difficulty")]
    pub difficulty: String,
    #[serde(default = "default_true")]
    pub particles: bool,
    #[serde(default = "default_true")]
    pub high_quality: bool,
    #[serde(default = "default_sensitivity")]
    pub sensitivity: f32,
    #[serde(default)]
    pub show_hitboxes: bool,
    #[serde(default = "default_volume")]
    pub volume: u8,
}

fn default_difficulty() -> String { "normal".to_string() }
fn default_true() -> bool { true }
fn default_sensitivity() -> f32 { 1.0 }
fn default_volume() -> u8 { 80 }

impl Default for GamePrefs {
    fn default() -> Self {
        GamePrefs {
            difficulty: default_difficulty(),
            particles: true,
            high_quality: true,
            sensitivity: 1.0,
            show_hitboxes: false,
            volume: 80,
        }
    }
}

pub struct AppState(Mutex<Inner>);

struct Inner {
    scores: Vec<HighScore>,
    prefs: GamePrefs,
}

fn data_dir() -> std::path::PathBuf {
    // Follow XDG spec: ~/.config/bark-squadron/
    let dir = std::env::var("XDG_CONFIG_HOME")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|_| {
            std::env::var("HOME")
                .map(std::path::PathBuf::from)
                .unwrap_or_else(|_| std::path::PathBuf::from("/tmp"))
                .join(".config")
        })
        .join("bark-squadron");
    fs::create_dir_all(&dir).ok();
    dir
}

fn load_scores() -> Vec<HighScore> {
    fs::read_to_string(data_dir().join("scores.json"))
        .ok().and_then(|s| serde_json::from_str(&s).ok()).unwrap_or_default()
}

fn load_prefs() -> GamePrefs {
    fs::read_to_string(data_dir().join("prefs.json"))
        .ok().and_then(|s| serde_json::from_str(&s).ok()).unwrap_or_default()
}

fn save_scores(scores: &[HighScore]) {
    if let Ok(json) = serde_json::to_string(scores) {
        fs::write(data_dir().join("scores.json"), json).ok();
    }
}

fn save_prefs(prefs: &GamePrefs) {
    if let Ok(json) = serde_json::to_string(prefs) {
        fs::write(data_dir().join("prefs.json"), json).ok();
    }
}

#[tauri::command]
fn submit_score(score: HighScore, state: State<'_, AppState>) -> Result<Vec<HighScore>, String> {
    let mut inner = state.0.lock().unwrap();
    inner.scores.push(score);
    // Keep top 10 per difficulty, sort descending by score
    inner.scores.sort_by(|a, b| b.score.cmp(&a.score));
    inner.scores.truncate(50);
    save_scores(&inner.scores);
    Ok(inner.scores.clone())
}

#[tauri::command]
fn get_scores(state: State<'_, AppState>) -> Vec<HighScore> {
    state.0.lock().unwrap().scores.clone()
}

#[tauri::command]
fn get_top_scores(difficulty: String, limit: usize, state: State<'_, AppState>) -> Vec<HighScore> {
    state.0.lock().unwrap().scores.iter()
        .filter(|s| s.difficulty == difficulty)
        .take(limit)
        .cloned()
        .collect()
}

#[tauri::command]
fn get_prefs(state: State<'_, AppState>) -> GamePrefs {
    state.0.lock().unwrap().prefs.clone()
}

#[tauri::command]
fn save_prefs_cmd(prefs: GamePrefs, state: State<'_, AppState>) -> Result<(), String> {
    let mut inner = state.0.lock().unwrap();
    save_prefs(&prefs);
    inner.prefs = prefs;
    Ok(())
}

#[tauri::command]
fn clear_scores(state: State<'_, AppState>) -> Result<(), String> {
    let mut inner = state.0.lock().unwrap();
    inner.scores.clear();
    save_scores(&inner.scores);
    Ok(())
}

pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .manage(AppState(Mutex::new(Inner {
            scores: load_scores(),
            prefs: load_prefs(),
        })))
        .invoke_handler(tauri::generate_handler![
            submit_score,
            get_scores,
            get_top_scores,
            get_prefs,
            save_prefs_cmd,
            clear_scores,
        ])
        .run(tauri::generate_context!())
        .expect("error while running Bark Squadron");
}
