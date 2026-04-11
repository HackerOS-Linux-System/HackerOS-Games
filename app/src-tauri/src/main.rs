#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::collections::HashMap;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::process::{Command, Stdio};
use std::sync::Mutex;
use std::time::{SystemTime, UNIX_EPOCH};
use serde::{Deserialize, Serialize};
use tauri::State;

#[derive(Debug, Serialize, Deserialize, Clone)]
struct GamePlaytime {
    game_id: String,
    total_seconds: u64,
    last_played: u64,
    sessions: u32,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct GameSettings {
    fullscreen: bool,
    resolution: String,
    volume: u8,
}

struct AppStateWrapper(Mutex<AppStateInner>);

struct AppStateInner {
    playtime: HashMap<String, GamePlaytime>,
    game_settings: HashMap<String, GameSettings>,
}

fn get_game_path(game_id: &str) -> Option<(String, Vec<String>)> {
    let base = "/usr/share/HackerOS/Scripts/HackerOS-Games";
    match game_id {
        "starblaster"   => Some((format!("{}/starblaster", base), vec![])),
        "bit-jump"      => Some(("love".to_string(), vec![format!("{}/bit-jump.love", base)])),
        "the-racer"     => Some((format!("{}/the-racer", base), vec![])),
        "bark-squadron" => Some((format!("{}/bark-squadron.AppImage", base), vec![])),
        "cosmonaut"     => Some((format!("{}/cosmonaut", base), vec![])),
        _               => None,
    }
}

fn data_dir() -> std::path::PathBuf {
    let dir = std::env::var("HOME")
        .map(std::path::PathBuf::from)
        .unwrap_or_else(|_| std::path::PathBuf::from("/tmp"))
        .join(".hackeros-games");
    fs::create_dir_all(&dir).ok();
    dir
}

fn now_secs() -> u64 {
    SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_secs()
}

fn save_playtime(data: &HashMap<String, GamePlaytime>) {
    if let Ok(json) = serde_json::to_string(data) {
        fs::write(data_dir().join("playtime.json"), json).ok();
    }
}

fn save_settings(data: &HashMap<String, GameSettings>) {
    if let Ok(json) = serde_json::to_string(data) {
        fs::write(data_dir().join("settings.json"), json).ok();
    }
}

fn load_playtime() -> HashMap<String, GamePlaytime> {
    fs::read_to_string(data_dir().join("playtime.json"))
        .ok().and_then(|s| serde_json::from_str(&s).ok()).unwrap_or_default()
}

fn load_settings() -> HashMap<String, GameSettings> {
    fs::read_to_string(data_dir().join("settings.json"))
        .ok().and_then(|s| serde_json::from_str(&s).ok()).unwrap_or_default()
}

#[tauri::command]
fn check_game_exists(game_id: String) -> bool {
    match get_game_path(&game_id) {
        Some((path, args)) => {
            if path == "love" {
                args.first().map(|p| fs::metadata(p).is_ok()).unwrap_or(false)
            } else {
                fs::metadata(&path).is_ok()
            }
        }
        None => false,
    }
}

#[tauri::command]
fn launch_game(game_id: String, state: State<'_, AppStateWrapper>) -> Result<bool, String> {
    let (cmd, args) = get_game_path(&game_id)
        .ok_or_else(|| format!("Unknown game: {}", game_id))?;

    if cmd.ends_with(".AppImage") {
        if let Ok(meta) = fs::metadata(&cmd) {
            let mut perms = meta.permissions();
            perms.set_mode(0o755);
            fs::set_permissions(&cmd, perms).ok();
        }
    }

    let fullscreen = {
        let inner = state.0.lock().unwrap();
        inner.game_settings.get(&game_id).map(|s| s.fullscreen).unwrap_or(false)
    };

    let mut c = Command::new(&cmd);
    for arg in &args { c.arg(arg); }
    if fullscreen { c.arg("--fullscreen"); }
    c.stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null());
    c.spawn().map_err(|e| format!("Failed to launch {}: {}", game_id, e))?;

    {
        let mut inner = state.0.lock().unwrap();
        let now = now_secs();
        let entry = inner.playtime.entry(game_id.clone()).or_insert(GamePlaytime {
            game_id: game_id.clone(), total_seconds: 0, last_played: now, sessions: 0,
        });
        entry.sessions += 1;
        entry.last_played = now;
        save_playtime(&inner.playtime);
    }
    Ok(true)
}

#[tauri::command]
fn record_playtime(game_id: String, seconds: u64, state: State<'_, AppStateWrapper>) -> Result<(), String> {
    let mut inner = state.0.lock().unwrap();
    let now = now_secs();
    let entry = inner.playtime.entry(game_id.clone()).or_insert(GamePlaytime {
        game_id: game_id.clone(), total_seconds: 0, last_played: now, sessions: 0,
    });
    entry.total_seconds += seconds;
    save_playtime(&inner.playtime);
    Ok(())
}

#[tauri::command]
fn get_all_playtime(state: State<'_, AppStateWrapper>) -> HashMap<String, GamePlaytime> {
    state.0.lock().unwrap().playtime.clone()
}

#[tauri::command]
fn save_game_settings(game_id: String, settings: GameSettings, state: State<'_, AppStateWrapper>) -> Result<(), String> {
    let mut inner = state.0.lock().unwrap();
    inner.game_settings.insert(game_id, settings);
    save_settings(&inner.game_settings);
    Ok(())
}

#[tauri::command]
fn get_all_game_settings(state: State<'_, AppStateWrapper>) -> HashMap<String, GameSettings> {
    state.0.lock().unwrap().game_settings.clone()
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .manage(AppStateWrapper(Mutex::new(AppStateInner {
            playtime: load_playtime(),
            game_settings: load_settings(),
        })))
        .invoke_handler(tauri::generate_handler![
            check_game_exists,
            launch_game,
            record_playtime,
            get_all_playtime,
            save_game_settings,
            get_all_game_settings,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
