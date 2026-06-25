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
const ADDONS_DIR: &str = "/usr/share/HackerOS/Scripts/HackerOS-Games/addons";

/// Raw GitHub URL of the addon pack installer script.
const ADDONS_HL_URL: &str =
    "https://raw.githubusercontent.com/HackerOS-Linux-System/HackerOS-Games/main/addons.hl";

/// Location the addon installer script is downloaded to before running.
const ADDONS_TMP_FILE: &str = "/tmp/addons.hl";

/// Directory for community store game installs.
const STORE_GAMES_DIR: &str = "/usr/share/HackerOS/Scripts/HackerOS-Games/community";

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
    #[serde(default)]
    minimize_on_close: bool,
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

/// Info about a community game install.
#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
struct CommunityGameInstall {
    game_id: String,
    title: String,
    install_type: String, // "binary", "python", "love", "archive"
    install_path: String,
    installed_at: u64,
}

struct AppStateWrapper(Mutex<AppStateInner>);

struct AppStateInner {
    playtime: HashMap<String, GamePlaytime>,
    game_settings: HashMap<String, GameSettings>,
    app_settings: AppSettings,
    community_installs: HashMap<String, CommunityGameInstall>,
}

/// Maps a built-in game id → (command, args).
///
/// Launch table (updated):
///   the-racer     → binary
///   cosmonaut     → love /usr/share/.../cosmonaut.love
///   starblaster   → binary
///   bark-squadron → binary  (was AppImage, now native binary)
///   bit-jump      → love /usr/share/.../bit-jump.love
fn get_game_path(game_id: &str) -> Option<(String, Vec<String>)> {
    match game_id {
        "the-racer"     => Some((format!("{}/the-racer", GAMES_BASE), vec![])),
        "cosmonaut"     => Some(("love".to_string(), vec![format!("{}/cosmonaut.love", GAMES_BASE)])),
        "starblaster"   => Some((format!("{}/starblaster", GAMES_BASE), vec![])),
        "bark-squadron" => Some((format!("{}/bark-squadron", GAMES_BASE), vec![])),
        "bit-jump"      => Some(("love".to_string(), vec![format!("{}/bit-jump.love", GAMES_BASE)])),
        _               => None,
    }
}

/// Maps an addon game id → (command, args).
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

fn save_community_installs(data: &HashMap<String, CommunityGameInstall>) {
    if let Ok(json) = serde_json::to_string(data) {
        fs::write(data_dir().join("community_installs.json"), json).ok();
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

fn load_community_installs() -> HashMap<String, CommunityGameInstall> {
    fs::read_to_string(data_dir().join("community_installs.json"))
        .ok().and_then(|s| serde_json::from_str(&s).ok()).unwrap_or_default()
}

/// Detect what kind of file/project was cloned/downloaded.
/// Returns: "binary", "python", "ruby", "love", "zip", "tar", "unknown"
fn detect_install_type(path: &str) -> String {
    let p = Path::new(path);
    if p.is_file() {
        if let Ok(meta) = fs::metadata(p) {
            let perms = meta.permissions().mode();
            if perms & 0o111 != 0 {
                return "binary".to_string();
            }
        }
        let name = p.file_name().unwrap_or_default().to_string_lossy().to_lowercase();
        if name.ends_with(".love")   { return "love".to_string(); }
        if name.ends_with(".zip")    { return "zip".to_string(); }
        if name.ends_with(".tar.gz") || name.ends_with(".tgz") || name.ends_with(".tar") {
            return "tar".to_string();
        }
        if name.ends_with(".py")     { return "python".to_string(); }
        if name.ends_with(".rb")     { return "ruby".to_string(); }
        if name.ends_with(".exe")    { return "exe".to_string(); }
    } else if p.is_dir() {
        // Check for python entrypoints
        for entry in &["main.py", "game.py", "run.py", "__main__.py"] {
            if p.join(entry).exists() { return "python".to_string(); }
        }
        // Ruby
        for entry in &["main.rb", "game.rb"] {
            if p.join(entry).exists() { return "ruby".to_string(); }
        }
        // love2d
        if p.join("main.lua").exists() { return "love".to_string(); }
        // Generic binary named after dir
        let dir_name = p.file_name().unwrap_or_default().to_string_lossy();
        if p.join(dir_name.as_ref()).exists() { return "binary".to_string(); }
    }
    "unknown".to_string()
}

/// Build sandbox command wrapping the actual game process.
/// Uses bubblewrap (bwrap) for lightweight + performant isolation:
///   - Read-only bind of /usr, /lib, /lib64, /bin, /etc
///   - Proc and dev mounts for functionality
///   - Private /tmp
///   - Home directory is mounted read-write only for save files
///   - No network access by default
///   - New user namespace (unprivileged)
fn build_sandbox_cmd(game_cmd: &str, game_args: &[String]) -> Command {
    // Try bwrap first (bubblewrap — lightweight, kernel namespaces only)
    if Path::new("/usr/bin/bwrap").exists() || Path::new("/bin/bwrap").exists() {
        let bwrap = if Path::new("/usr/bin/bwrap").exists() { "/usr/bin/bwrap" } else { "/bin/bwrap" };
        let mut c = Command::new(bwrap);
        c.args([
            "--ro-bind", "/usr", "/usr",
            "--ro-bind", "/bin", "/bin",
            "--ro-bind", "/lib", "/lib",
        ]);
        // /lib64 may not exist on all distros
        if Path::new("/lib64").exists() {
            c.args(["--ro-bind", "/lib64", "/lib64"]);
        }
        c.args([
            "--ro-bind", "/etc", "/etc",
            "--proc", "/proc",
            "--dev", "/dev",
            "--tmpfs", "/tmp",
            // mount the games directory read-only
            "--ro-bind", GAMES_BASE, GAMES_BASE,
            // give write access to user's save dir only
            "--bind", &data_dir().to_string_lossy().to_string(), &data_dir().to_string_lossy().to_string(),
            // unshare network — games don't need it
            "--unshare-net",
            "--unshare-pid",
            "--unshare-uts",
            "--new-session",
            // game binary / interpreter
            "--",
            game_cmd,
        ]);
        for arg in game_args {
            c.arg(arg);
        }
        return c;
    }

    // Fallback: firejail if available
    if Path::new("/usr/bin/firejail").exists() {
        let mut c = Command::new("/usr/bin/firejail");
        c.args([
            "--quiet",
            "--net=none",
            "--private-tmp",
            "--read-only=/usr/share",
            game_cmd,
        ]);
        for arg in game_args {
            c.arg(arg);
        }
        return c;
    }

    // Ultimate fallback: run directly (no sandbox available)
    let mut c = Command::new(game_cmd);
    for arg in game_args {
        c.arg(arg);
    }
    c
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

    // Ensure binary is executable
    if cmd != "love" {
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

    let mut c = build_sandbox_cmd(&cmd, &args);
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

#[tauri::command]
fn check_addons_installed() -> bool {
    Path::new(ADDONS_DIR).is_dir()
}

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

#[tauri::command]
fn launch_addon_game(addon_id: String) -> Result<bool, String> {
    let (cmd, args) = get_addon_game_path(&addon_id)
        .ok_or_else(|| format!("Unknown addon game: {}", addon_id))?;

    let mut c = build_sandbox_cmd(&cmd, &args);
    c.stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null());
    c.spawn().map_err(|e| format!("Failed to launch {}: {}", addon_id, e))?;
    Ok(true)
}

#[tauri::command]
fn install_addons() -> Result<(), String> {
    let download = Command::new("curl")
        .args(["-fsSL", "-o", ADDONS_TMP_FILE, ADDONS_HL_URL])
        .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::piped())
        .output()
        .map_err(|e| format!("Failed to start curl: {}", e))?;

    if !download.status.success() {
        let stderr = String::from_utf8_lossy(&download.stderr);
        return Err(format!("Failed to download addons.hl: {}", stderr.trim()));
    }

    if let Ok(meta) = fs::metadata(ADDONS_TMP_FILE) {
        let mut perms = meta.permissions();
        perms.set_mode(0o755);
        fs::set_permissions(ADDONS_TMP_FILE, perms).ok();
    }

    let run = Command::new("/usr/bin/hl")
        .args(["run", ADDONS_TMP_FILE])
        .stdin(Stdio::null()).stdout(Stdio::piped()).stderr(Stdio::piped())
        .output()
        .map_err(|e| format!("Failed to start /usr/bin/hl: {}", e))?;

    if !run.status.success() {
        let stderr = String::from_utf8_lossy(&run.stderr);
        return Err(format!("Addon installer failed: {}", stderr.trim()));
    }

    if !Path::new(ADDONS_DIR).is_dir() {
        return Err("Installer finished but the addons directory was not created".to_string());
    }

    Ok(())
}

// ─────────────────────────────────────────────────────────────────────────────
// Community Store: install / launch / uninstall
// ─────────────────────────────────────────────────────────────────────────────

/// Install a community game from a git repo or direct download URL.
/// Strategy:
///   - URL ends with .git  → git clone into STORE_GAMES_DIR/<game_id>
///   - URL ends with .zip  → wget + unzip into STORE_GAMES_DIR/<game_id>
///   - URL ends with .tar.gz/.tgz → wget + tar into STORE_GAMES_DIR/<game_id>
///   - URL is a plain binary (no extension, or .exe) → wget into STORE_GAMES_DIR/<game_id>/<name>
///
/// After placing files, detect install_type and record in community_installs.
#[tauri::command]
fn install_community_game(
    game_id: String,
    title: String,
    install_url: String,
    state: State<'_, AppStateWrapper>,
) -> Result<CommunityGameInstall, String> {
    fs::create_dir_all(STORE_GAMES_DIR)
        .map_err(|e| format!("Cannot create store dir: {}", e))?;

    let dest_dir = format!("{}/{}", STORE_GAMES_DIR, game_id);
    fs::create_dir_all(&dest_dir)
        .map_err(|e| format!("Cannot create game dir: {}", e))?;

    let url_lower = install_url.to_lowercase();

    if url_lower.ends_with(".git") {
        // git clone
        let status = Command::new("git")
            .args(["clone", "--depth=1", &install_url, &dest_dir])
            .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::piped())
            .status()
            .map_err(|e| format!("git not found: {}", e))?;
        if !status.success() {
            return Err(format!("git clone failed for {}", install_url));
        }
    } else if url_lower.ends_with(".zip") {
        let tmp = format!("/tmp/hg-store-{}.zip", game_id);
        wget_download(&install_url, &tmp)?;
        Command::new("unzip")
            .args(["-o", &tmp, "-d", &dest_dir])
            .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null())
            .status()
            .map_err(|e| format!("unzip failed: {}", e))?;
        fs::remove_file(&tmp).ok();
    } else if url_lower.ends_with(".tar.gz") || url_lower.ends_with(".tgz") || url_lower.ends_with(".tar") {
        let tmp = format!("/tmp/hg-store-{}.tar.gz", game_id);
        wget_download(&install_url, &tmp)?;
        Command::new("tar")
            .args(["-xf", &tmp, "-C", &dest_dir, "--strip-components=1"])
            .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null())
            .status()
            .map_err(|e| format!("tar failed: {}", e))?;
        fs::remove_file(&tmp).ok();
    } else {
        // direct binary / unknown — download to dest_dir/<game_id>
        let out_path = format!("{}/{}", dest_dir, game_id);
        wget_download(&install_url, &out_path)?;
        // make executable
        if let Ok(meta) = fs::metadata(&out_path) {
            let mut perms = meta.permissions();
            perms.set_mode(0o755);
            fs::set_permissions(&out_path, perms).ok();
        }
    }

    let install_type = detect_install_type(&dest_dir);

    let install_info = CommunityGameInstall {
        game_id: game_id.clone(),
        title,
        install_type,
        install_path: dest_dir,
        installed_at: now_secs(),
    };

    {
        let mut inner = state.0.lock().unwrap();
        inner.community_installs.insert(game_id, install_info.clone());
        save_community_installs(&inner.community_installs);
    }

    Ok(install_info)
}

fn wget_download(url: &str, dest: &str) -> Result<(), String> {
    // Try curl first, then wget
    let curl_status = Command::new("curl")
        .args(["-fsSL", "-o", dest, url])
        .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null())
        .status();
    if let Ok(s) = curl_status {
        if s.success() { return Ok(()); }
    }
    let wget_status = Command::new("wget")
        .args(["-q", "-O", dest, url])
        .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null())
        .status()
        .map_err(|e| format!("wget/curl not available: {}", e))?;
    if !wget_status.success() {
        return Err(format!("Failed to download {}", url));
    }
    Ok(())
}

/// Launch a previously-installed community game in a sandbox.
/// Determines launch method from install_type:
///   binary → sandbox + execute
///   python → sandbox + python3 main.py
///   ruby   → sandbox + ruby main.rb
///   love   → sandbox + love <path>
///   (zip/tar extracted → detect again from install path)
#[tauri::command]
fn launch_community_game(
    game_id: String,
    state: State<'_, AppStateWrapper>,
) -> Result<bool, String> {
    let install = {
        let inner = state.0.lock().unwrap();
        inner.community_installs.get(&game_id).cloned()
            .ok_or_else(|| format!("Game {} not installed", game_id))?
    };

    let (cmd, args): (String, Vec<String>) = match install.install_type.as_str() {
        "binary" => {
            let bin = if Path::new(&install.install_path).is_dir() {
                format!("{}/{}", install.install_path, install.game_id)
            } else {
                install.install_path.clone()
            };
            if let Ok(meta) = fs::metadata(&bin) {
                let mut perms = meta.permissions();
                perms.set_mode(0o755);
                fs::set_permissions(&bin, perms).ok();
            }
            (bin, vec![])
        }
        "python" => {
            let entry = find_entry(&install.install_path, &["main.py", "game.py", "run.py", "__main__.py"]);
            ("python3".to_string(), vec![entry])
        }
        "ruby" => {
            let entry = find_entry(&install.install_path, &["main.rb", "game.rb"]);
            ("ruby".to_string(), vec![entry])
        }
        "love" => {
            if install.install_path.ends_with(".love") {
                ("love".to_string(), vec![install.install_path.clone()])
            } else {
                ("love".to_string(), vec![install.install_path.clone()])
            }
        }
        _ => return Err(format!("Cannot launch game type '{}'", install.install_type)),
    };

    let mut c = build_sandbox_cmd(&cmd, &args);
    c.stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null());
    c.spawn().map_err(|e| format!("Failed to launch {}: {}", game_id, e))?;
    Ok(true)
}

fn find_entry(dir: &str, candidates: &[&str]) -> String {
    for c in candidates {
        let p = format!("{}/{}", dir, c);
        if Path::new(&p).exists() { return p; }
    }
    dir.to_string()
}

/// Uninstall a community game — removes its directory.
#[tauri::command]
fn uninstall_community_game(
    game_id: String,
    state: State<'_, AppStateWrapper>,
) -> Result<(), String> {
    let path = {
        let inner = state.0.lock().unwrap();
        inner.community_installs.get(&game_id)
            .map(|i| i.install_path.clone())
    };

    if let Some(p) = path {
        fs::remove_dir_all(&p).map_err(|e| format!("Failed to remove {}: {}", p, e))?;
    }

    let mut inner = state.0.lock().unwrap();
    inner.community_installs.remove(&game_id);
    save_community_installs(&inner.community_installs);
    Ok(())
}

#[tauri::command]
fn get_community_installs(state: State<'_, AppStateWrapper>) -> HashMap<String, CommunityGameInstall> {
    state.0.lock().unwrap().community_installs.clone()
}

#[tauri::command]
fn check_community_game_installed(game_id: String, state: State<'_, AppStateWrapper>) -> bool {
    let inner = state.0.lock().unwrap();
    if let Some(install) = inner.community_installs.get(&game_id) {
        Path::new(&install.install_path).exists()
    } else {
        false
    }
}

/// Opens an http(s) URL in the system's default browser via xdg-open.
#[tauri::command]
fn open_url(url: String) -> Result<(), String> {
    if !(url.starts_with("http://") || url.starts_with("https://")) {
        return Err("Refusing to open a non-http(s) URL".to_string());
    }
    Command::new("xdg-open")
        .arg(&url)
        .stdin(Stdio::null()).stdout(Stdio::null()).stderr(Stdio::null())
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
            community_installs: load_community_installs(),
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
            install_community_game,
            launch_community_game,
            uninstall_community_game,
            get_community_installs,
            check_community_game_installed,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
