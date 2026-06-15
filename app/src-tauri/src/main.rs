#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::collections::HashMap;
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::{Command, Stdio};
use std::sync::Mutex;
use std::time::{SystemTime, UNIX_EPOCH};
use serde::{Deserialize, Serialize};
use tauri::State;

/// Base directory all HackerOS-native games are installed under.
const GAMES_BASE: &str = "/usr/share/HackerOS/Scripts/HackerOS-Games";

/// Directory the optional community addon pack installs games into.
/// Its presence is used as the signal that the addon pack is installed.
const ADDONS_DIR: &str = "/usr/share/HackerOS/Scripts/HackerOS-Games/addons";

/// Raw GitHub URL of the addon pack installer script.
const ADDONS_HL_URL: &str =
"https://raw.githubusercontent.com/HackerOS-Linux-System/HackerOS-Games/main/addons.hl";

/// Location the addon installer script is downloaded to before running.
const ADDONS_TMP_FILE: &str = "/tmp/addons.hl";

#[derive(Debug, Serialize, Deserialize, Clone)]
struct GamePlaytime {
    game_id: String,
    total_seconds: u64,
    last_played: u64,
    sessions: u32,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
struct GameSettings {
    fullscreen: bool,
    resolution: String,
    volume: u8,
    /// Extra command-line arguments appended verbatim when launching the game.
    #[serde(default)]
    launch_args: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
struct AppSettings {
    #[serde(default = "default_language")]
    language: String,
    #[serde(default = "default_true")]
    particles_enabled: bool,
    /// When true, the titlebar close button minimizes the window instead of quitting.
    #[serde(default)]
    minimize_on_close: bool,
    /// When true, the Addons tab re-checks installation status whenever it is opened.
    #[serde(default = "default_true")]
    auto_check_addons: bool,
    #[serde(default = "default_accent_color")]
    accent_color: String,
}

fn default_language() -> String { "en".to_string() }
fn default_true() -> bool { true }
fn default_accent_color() -> String { "#2a8fff".to_string() }

impl Default for AppSettings {
    fn default() -> Self {
        AppSettings {
            language: default_language(),
            particles_enabled: true,
            minimize_on_close: false,
            auto_check_addons: true,
            accent_color: default_accent_color(),
        }
    }
}

struct AppStateWrapper(Mutex<AppStateInner>);

struct AppStateInner {
    playtime: HashMap<String, GamePlaytime>,
    game_settings: HashMap<String, GameSettings>,
    app_settings: AppSettings,
}

fn get_game_path(game_id: &str) -> Option<(String, Vec<String>)> {
    match game_id {
        "starblaster"   => Some((format!("{}/starblaster", GAMES_BASE), vec![])),
        "bit-jump"      => Some(("love".to_string(), vec![format!("{}/bit-jump.love", GAMES_BASE)])),
        "the-racer"     => Some((format!("{}/the-racer", GAMES_BASE), vec![])),
        "bark-squadron" => Some((format!("{}/bark-squadron.AppImage", GAMES_BASE), vec![])),
        "cosmonaut"     => Some((format!("{}/cosmonaut", GAMES_BASE), vec![])),
        _               => None,
    }
}

/// Maps an addon game id to the command + args used to launch it.
/// Addon games live inside `ADDONS_DIR` once the addon pack is installed.
fn get_addon_game_path(addon_id: &str) -> Option<(String, Vec<String>)> {
    match addon_id {
        "parkour-runner" => Some(("love".to_string(), vec![format!("{}/parkour-runner.love", ADDONS_DIR)])),
        _ => None,
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

fn save_app_settings_file(data: &AppSettings) {
    if let Ok(json) = serde_json::to_string(data) {
        fs::write(data_dir().join("app_settings.json"), json).ok();
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

fn load_app_settings() -> AppSettings {
    fs::read_to_string(data_dir().join("app_settings.json"))
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

    let (fullscreen, launch_args) = {
        let inner = state.0.lock().unwrap();
        match inner.game_settings.get(&game_id) {
            Some(s) => (s.fullscreen, s.launch_args.clone()),
            None => (false, String::new()),
        }
    };

    let mut c = Command::new(&cmd);
    for arg in &args { c.arg(arg); }
    if fullscreen { c.arg("--fullscreen"); }
    for extra in launch_args.split_whitespace() {
        c.arg(extra);
    }
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

#[tauri::command]
fn get_app_settings(state: State<'_, AppStateWrapper>) -> AppSettings {
    state.0.lock().unwrap().app_settings.clone()
}

#[tauri::command]
fn save_app_settings(settings: AppSettings, state: State<'_, AppStateWrapper>) -> Result<(), String> {
    let mut inner = state.0.lock().unwrap();
    inner.app_settings = settings;
    save_app_settings_file(&inner.app_settings);
    Ok(())
}

/// Whether the community addon pack has been installed
/// (i.e. the addons directory exists under HackerOS Games).
#[tauri::command]
fn check_addons_installed() -> bool {
    Path::new(ADDONS_DIR).is_dir()
}

/// Whether a specific addon game's data file is present.
#[tauri::command]
fn check_addon_game_exists(addon_id: String) -> bool {
    match get_addon_game_path(&addon_id) {
        Some((cmd, args)) => {
            if cmd == "love" {
                args.first().map(|p| fs::metadata(p).is_ok()).unwrap_or(false)
            } else {
                fs::metadata(&cmd).is_ok()
            }
        }
        None => false,
    }
}

/// Launches an addon game (e.g. Parkour Runner via `love parkour-runner.love`).
#[tauri::command]
fn launch_addon_game(addon_id: String) -> Result<bool, String> {
    let (cmd, args) = get_addon_game_path(&addon_id)
    .ok_or_else(|| format!("Unknown addon game: {}", addon_id))?;

    let mut c = Command::new(&cmd);
    for arg in &args { c.arg(arg); }
    c.stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null());
    c.spawn().map_err(|e| format!("Failed to launch {}: {}", addon_id, e))?;
    Ok(true)
}

/// Downloads the HackerOS Games addon pack installer (addons.hl) to /tmp and
/// runs it with `/usr/bin/hl run`. On success the addons directory should
/// exist and addon games (e.g. Parkour Runner) become available.
#[tauri::command]
fn install_addons() -> Result<(), String> {
    let download = Command::new("curl")
    .args(["-fsSL", "-o", ADDONS_TMP_FILE, ADDONS_HL_URL])
    .stdin(Stdio::null())
    .stdout(Stdio::null())
    .stderr(Stdio::piped())
    .output()
    .map_err(|e| format!("Failed to start curl: {}", e))?;

    if !download.status.success() {
        let stderr = String::from_utf8_lossy(&download.stderr);
        let detail = stderr.trim();
        return Err(if detail.is_empty() {
            "Failed to download addons.hl".to_string()
        } else {
            format!("Failed to download addons.hl: {}", detail)
        });
    }

    if let Ok(meta) = fs::metadata(ADDONS_TMP_FILE) {
        let mut perms = meta.permissions();
        perms.set_mode(0o755);
        fs::set_permissions(ADDONS_TMP_FILE, perms).ok();
    }

    let run = Command::new("/usr/bin/hl")
    .args(["run", ADDONS_TMP_FILE])
    .stdin(Stdio::null())
    .stdout(Stdio::piped())
    .stderr(Stdio::piped())
    .output()
    .map_err(|e| format!("Failed to start /usr/bin/hl: {}", e))?;

    if !run.status.success() {
        let stderr = String::from_utf8_lossy(&run.stderr);
        let detail = stderr.trim();
        return Err(if detail.is_empty() {
            "Addon installer exited with an error".to_string()
        } else {
            format!("Addon installer failed: {}", detail)
        });
    }

    if !Path::new(ADDONS_DIR).is_dir() {
        return Err("Installer finished but the addons directory was not created".to_string());
    }

    Ok(())
}

/// Opens an http(s) URL in the system's default browser via `xdg-open`.
/// Used by the Store section to open repository and download links.
#[tauri::command]
fn open_url(url: String) -> Result<(), String> {
    if !(url.starts_with("http://") || url.starts_with("https://")) {
        return Err("Refusing to open a non-http(s) URL".to_string());
    }
    Command::new("xdg-open")
    .arg(&url)
    .stdin(Stdio::null())
    .stdout(Stdio::null())
    .stderr(Stdio::null())
    .spawn()
    .map_err(|e| format!("Failed to open URL: {}", e))?;
    Ok(())
}

fn main() {
    tauri::Builder::default()
    .plugin(tauri_plugin_shell::init())
    .manage(AppStateWrapper(Mutex::new(AppStateInner {
        playtime: load_playtime(),
                                       game_settings: load_settings(),
                                       app_settings: load_app_settings(),
    })))
    .invoke_handler(tauri::generate_handler![
        check_game_exists,
        launch_game,
        record_playtime,
        get_all_playtime,
        save_game_settings,
        get_all_game_settings,
        get_app_settings,
        save_app_settings,
        check_addons_installed,
        install_addons,
        check_addon_game_exists,
        launch_addon_game,
        open_url,
    ])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
}
