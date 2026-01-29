use macroquad::prelude::*;
use serde::{Deserialize, Serialize};
use std::fs;

// ==========================================
// CONSTANTS & CONFIG
// ==========================================
const PLAYER_SPEED: f32 = 350.0;
const MAX_HEAT: f32 = 100.0;
const HEAT_PER_SHOT: f32 = 15.0;
const COOLING_RATE: f32 = 40.0;
const GRAZE_DISTANCE: f32 = 30.0;
const COMBO_DECAY: f32 = 2.0; // Seconds before combo resets
const SCREEN_PADDING: f32 = 20.0;

// Explicitly define colors to avoid scope issues
const CYAN: Color = Color::new(0.0, 1.0, 1.0, 1.0);
const PINK: Color = Color::new(1.0, 0.75, 0.8, 1.0);

// ==========================================
// DATA STRUCTURES (SERIALIZABLE)
// ==========================================

// Global struct for Stars so it can be used in function signatures
struct Star {
    pos: Vec2,
    speed: f32,
    size: f32,
}

#[derive(Serialize, Deserialize, Copy, Clone)]
struct SerVec2 {
    x: f32,
    y: f32,
}

impl From<Vec2> for SerVec2 {
    fn from(v: Vec2) -> Self {
        SerVec2 { x: v.x, y: v.y }
    }
}
impl From<SerVec2> for Vec2 {
    fn from(v: SerVec2) -> Self {
        vec2(v.x, v.y)
    }
}

#[derive(Serialize, Deserialize, Clone, PartialEq, Debug)]
enum EnemyState {
    Spawn,
    Cruising,
    Attacking,
    Retreating,
}

#[derive(Serialize, Deserialize, Clone, Copy, PartialEq)]
enum EnemyType {
    Basic,
    Fast,
    Tank,
    Shooter,
    Kamikaze,
    Asteroid,
}

#[derive(Serialize, Deserialize, Clone)]
struct EnemyData {
    pos: SerVec2,
    vel: SerVec2, // Velocity for physics
    enemy_type: EnemyType,
    state: EnemyState,
    health: i32,
    max_health: i32,
    last_action_time: f64,
}

// Wrapper for Enemy that includes Logic (Trait Object)
struct Enemy {
    data: EnemyData,
    ai: Box<dyn EnemyAi>,
}

#[derive(Serialize, Deserialize, Clone)]
struct Bullet {
    pos: SerVec2,
    vel: SerVec2,
    alive: bool,
    is_player: bool,
    damage: i32,
    grazed: bool, // To prevent double grazing points
}

#[derive(Serialize, Deserialize, Clone, Copy)]
struct PlayerState {
    pos: SerVec2,
    health: i32,
    heat: f32,
    overheated: bool,
    score: i32,
    high_score: i32,
    combo: i32,
    combo_timer: f32,
    ulti_energy: f32, // 0.0 to 100.0
    shots_fired: u32,
    shots_hit: u32,
}

#[derive(Serialize, Deserialize)]
struct GameSave {
    player: PlayerState,
    enemies: Vec<EnemyData>, // Save only data, recreate AI on load
    bullets: Vec<Bullet>,
    difficulty: f32,
    level: u32,
}

struct Director {
    difficulty_multiplier: f32,
    spawn_timer: f32,
    wave_active: bool,
    last_accuracy_check: f64,
}

// ==========================================
// AI TRAIT SYSTEM
// ==========================================

trait EnemyAi {
    fn update(&mut self, data: &mut EnemyData, player_pos: Vec2, dt: f32, bullets: &mut Vec<Bullet>);
}

// --- Implementations ---

struct BasicAi;
impl EnemyAi for BasicAi {
    fn update(&mut self, data: &mut EnemyData, _player_pos: Vec2, dt: f32, _bullets: &mut Vec<Bullet>) {
        // Simple fallback movement
        let pos = Vec2::from(data.pos);
        let new_pos = pos + vec2(0.0, 100.0) * dt;
        data.pos = new_pos.into();
    }
}

struct KamikazeAi;
impl EnemyAi for KamikazeAi {
    fn update(&mut self, data: &mut EnemyData, player_pos: Vec2, dt: f32, _bullets: &mut Vec<Bullet>) {
        let mut pos = Vec2::from(data.pos);
        
        match data.state {
            EnemyState::Cruising => {
                pos.y += 80.0 * dt;
                // If close enough specifically in Y axis, switch to Attack
                if (pos.y - player_pos.y).abs() < 300.0 && pos.y < player_pos.y {
                    data.state = EnemyState::Attacking;
                    // Calculate vector to player
                    let dir = (player_pos - pos).normalize();
                    data.vel = (dir * 400.0).into(); // Fast speed
                }
            },
            EnemyState::Attacking => {
                let vel = Vec2::from(data.vel);
                pos += vel * dt;
            },
            _ => {}
        }
        data.pos = pos.into();
    }
}

struct ShooterAi;
impl EnemyAi for ShooterAi {
    fn update(&mut self, data: &mut EnemyData, player_pos: Vec2, dt: f32, bullets: &mut Vec<Bullet>) {
        let mut pos = Vec2::from(data.pos);
        let time = get_time();

        match data.state {
            EnemyState::Cruising => {
                pos.y += 60.0 * dt;
                // Hover behavior
                pos.x += (time * 2.0 + data.pos.y as f64).sin() as f32 * 50.0 * dt;

                if time - data.last_action_time > 2.0 {
                    data.state = EnemyState::Attacking;
                    data.last_action_time = time;
                }
            },
            EnemyState::Attacking => {
                // Shoot
                let dir = (player_pos - pos).normalize();
                bullets.push(Bullet {
                    pos: pos.into(),
                    vel: (dir * 250.0).into(),
                    alive: true,
                    is_player: false,
                    damage: 1,
                    grazed: false,
                });
                data.state = EnemyState::Retreating;
                data.last_action_time = time;
            },
            EnemyState::Retreating => {
                // Move up or away quickly for a second
                pos.y -= 30.0 * dt;
                if time - data.last_action_time > 1.0 {
                     data.state = EnemyState::Cruising;
                }
            }
            _ => {}
        }
        data.pos = pos.into();
    }
}

struct AsteroidAi;
impl EnemyAi for AsteroidAi {
    fn update(&mut self, data: &mut EnemyData, _player_pos: Vec2, dt: f32, _bullets: &mut Vec<Bullet>) {
        let mut pos = Vec2::from(data.pos);
        pos.y += 150.0 * dt; // Fast falling debris
        // Rotate logic could go here if we had rotation in data
        data.pos = pos.into();
    }
}

// Factory to restore AI from Enum
fn create_ai(e_type: EnemyType) -> Box<dyn EnemyAi> {
    match e_type {
        EnemyType::Kamikaze => Box::new(KamikazeAi),
        EnemyType::Shooter => Box::new(ShooterAi),
        EnemyType::Asteroid => Box::new(AsteroidAi),
        _ => Box::new(BasicAi),
    }
}

// ==========================================
// GAME ENGINE
// ==========================================

#[macroquad::main("StarBlaster v2")]
async fn main() {
    let mut rng = ::rand::thread_rng();
    
    // -- Init State --
    let mut state = GameState::Menu;
    let mut player = PlayerState {
        pos: vec2(screen_width() / 2.0, screen_height() - 100.0).into(),
        health: 5,
        heat: 0.0,
        overheated: false,
        score: 0,
        high_score: load_high_score(),
        combo: 0,
        combo_timer: 0.0,
        ulti_energy: 0.0,
        shots_fired: 0,
        shots_hit: 0,
    };

    let mut enemies: Vec<Enemy> = Vec::new();
    let mut bullets: Vec<Bullet> = Vec::new();
    let mut director = Director {
        difficulty_multiplier: 1.0,
        spawn_timer: 0.0,
        wave_active: false,
        last_accuracy_check: get_time(),
    };

    // Stars background
    let mut stars: Vec<Star> = (0..100).map(|_| Star {
        pos: vec2(::rand::Rng::gen_range(&mut rng, 0.0..screen_width()), ::rand::Rng::gen_range(&mut rng, 0.0..screen_height())),
        speed: ::rand::Rng::gen_range(&mut rng, 20.0..100.0),
        size: ::rand::Rng::gen_range(&mut rng, 0.5..2.0),
    }).collect();

    loop {
        let dt = get_frame_time();
        let time = get_time();

        match state {
            GameState::Menu => {
                clear_background(BLACK);
                draw_stars(&mut stars, dt);
                draw_ui_text_centered("STAR BLASTER", -50.0, 60.0, GOLD);
                draw_ui_text_centered("Press SPACE to Start", 20.0, 30.0, WHITE);
                draw_ui_text_centered("Press L to Load Game", 60.0, 20.0, LIGHTGRAY);
                
                if is_key_pressed(KeyCode::Space) {
                    reset_game(&mut player, &mut enemies, &mut bullets, &mut director);
                    state = GameState::Playing;
                }
                if is_key_pressed(KeyCode::L) {
                    if let Some(save) = load_game() {
                        player = save.player;
                        bullets = save.bullets;
                        director.difficulty_multiplier = save.difficulty;
                        // Reconstruct AI
                        enemies = save.enemies.into_iter().map(|d| Enemy {
                            ai: create_ai(d.enemy_type),
                            data: d,
                        }).collect();
                        state = GameState::Playing;
                    }
                }
            },
            GameState::Playing => {
                clear_background(Color::new(0.05, 0.05, 0.1, 1.0));
                
                // --- Input & Player ---
                if is_key_pressed(KeyCode::P) { state = GameState::Paused; }
                
                // Movement
                let mut p_pos = Vec2::from(player.pos);
                if is_key_down(KeyCode::Left) { p_pos.x -= PLAYER_SPEED * dt; }
                if is_key_down(KeyCode::Right) { p_pos.x += PLAYER_SPEED * dt; }
                if is_key_down(KeyCode::Up) { p_pos.y -= PLAYER_SPEED * dt; }
                if is_key_down(KeyCode::Down) { p_pos.y += PLAYER_SPEED * dt; }
                p_pos.x = p_pos.x.clamp(SCREEN_PADDING, screen_width() - SCREEN_PADDING);
                p_pos.y = p_pos.y.clamp(SCREEN_PADDING, screen_height() - SCREEN_PADDING);
                player.pos = p_pos.into();

                // Combat
                // Cooling
                if player.overheated {
                    player.heat -= COOLING_RATE * 1.5 * dt;
                    if player.heat <= 0.0 {
                        player.heat = 0.0;
                        player.overheated = false;
                    }
                } else {
                    player.heat -= COOLING_RATE * dt;
                    if player.heat < 0.0 { player.heat = 0.0; }
                }

                // Shooting
                if is_key_down(KeyCode::Space) && !player.overheated {
                    // Simple fire rate limiter via frame check or timer could be added
                    // For now, let's assume rapid fire but limited by heat
                    if player.heat + HEAT_PER_SHOT < MAX_HEAT {
                        if get_frame_time() > 0.0 { // Just to ensure we don't spam in one frame logic
                            // Basic fire rate limiter
                             if (time * 10.0) as i32 % 2 == 0 {
                                bullets.push(Bullet {
                                    pos: p_pos.into(),
                                    vel: vec2(0.0, -600.0).into(),
                                    alive: true,
                                    is_player: true,
                                    damage: 1,
                                    grazed: false,
                                });
                                player.heat += HEAT_PER_SHOT;
                                player.shots_fired += 1;
                             }
                        }
                    } else {
                        player.overheated = true;
                        // Play overheat sound?
                    }
                }

                // ULT
                if is_key_pressed(KeyCode::LeftShift) && player.ulti_energy >= 100.0 {
                    player.ulti_energy = 0.0;
                    // Screen clear logic
                    for e in &mut enemies {
                        e.data.health -= 10; // Massive damage
                    }
                    bullets.retain(|b| b.is_player); // Clear enemy bullets
                    // Visual effect placeholder
                    draw_circle(screen_width()/2.0, screen_height()/2.0, 500.0, Color::new(1.0, 1.0, 1.0, 0.5));
                }

                // --- Updates ---
                draw_stars(&mut stars, dt);

                // Director AI Update
                update_director(&mut director, &mut enemies, &player, dt);

                // Bullets
                for b in &mut bullets {
                    let b_pos = Vec2::from(b.pos);
                    let b_vel = Vec2::from(b.vel);
                    b.pos = (b_pos + b_vel * dt).into();
                    
                    if b_pos.y < -50.0 || b_pos.y > screen_height() + 50.0 {
                        b.alive = false;
                    }
                }

                // Enemies
                for e in &mut enemies {
                    e.ai.update(&mut e.data, p_pos, dt, &mut bullets);
                }

                // --- Collisions & Logic ---
                
                // Player Bullets vs Enemies
                for b in &mut bullets {
                    if !b.alive || !b.is_player { continue; }
                    let b_pos = Vec2::from(b.pos);
                    
                    for e in &mut enemies {
                        let e_pos = Vec2::from(e.data.pos);
                        if e.data.health > 0 && b_pos.distance(e_pos) < 25.0 {
                            e.data.health -= b.damage;
                            b.alive = false;
                            player.shots_hit += 1;
                            
                            if e.data.health <= 0 {
                                // Kill logic
                                player.combo += 1;
                                player.combo_timer = COMBO_DECAY;
                                let multiplier = 1.0 + (player.combo as f32 * 0.1);
                                player.score += (100.0 * multiplier) as i32;
                                player.ulti_energy = (player.ulti_energy + 5.0).min(100.0);
                            }
                            break; 
                        }
                    }
                }

                // Enemy Bullets vs Player (Hit & Graze)
                for b in &mut bullets {
                    if !b.alive || b.is_player { continue; }
                    let b_pos = Vec2::from(b.pos);
                    let dist = b_pos.distance(p_pos);

                    if dist < 10.0 {
                        // HIT
                        player.health -= 1;
                        b.alive = false;
                        player.combo = 0;
                        player.heat = (player.heat - 50.0).max(0.0); // Cool down on hit?
                        if player.health <= 0 {
                            save_high_score(player.score.max(player.high_score));
                            state = GameState::GameOver;
                        }
                    } else if dist < GRAZE_DISTANCE && !b.grazed {
                        // GRAZE
                        b.grazed = true;
                        player.score += 50;
                        player.ulti_energy = (player.ulti_energy + 1.0).min(100.0);
                        // Optional visual for graze
                        draw_circle_lines(p_pos.x, p_pos.y, GRAZE_DISTANCE, 1.0, GOLD);
                    }
                }

                // Enemy Body vs Player
                for e in &mut enemies {
                    let e_pos = Vec2::from(e.data.pos);
                    if e.data.health > 0 && e_pos.distance(p_pos) < 30.0 {
                        player.health -= 1;
                        e.data.health = 0; // Kamikaze impact kills enemy
                        player.combo = 0;
                        if player.health <= 0 {
                            save_high_score(player.score.max(player.high_score));
                            state = GameState::GameOver;
                        }
                    }
                }

                // Combo Decay
                if player.combo > 0 {
                    player.combo_timer -= dt;
                    if player.combo_timer <= 0.0 {
                        player.combo = 0;
                    }
                }

                // Cleanup
                bullets.retain(|b| b.alive);
                enemies.retain(|e| e.data.health > 0 && Vec2::from(e.data.pos).y < screen_height() + 100.0);

                // --- Drawing ---
                // Player
                draw_poly(p_pos.x, p_pos.y, 3, 20.0, 0.0, if player.overheated { RED } else { GREEN });
                // Heat bar
                draw_rect_bar(p_pos.x - 20.0, p_pos.y + 25.0, 40.0, 5.0, player.heat / MAX_HEAT, ORANGE);

                // Enemies
                for e in &enemies {
                    let pos = Vec2::from(e.data.pos);
                    let color = match e.data.enemy_type {
                        EnemyType::Kamikaze => RED,
                        EnemyType::Shooter => PURPLE,
                        EnemyType::Asteroid => GRAY,
                        _ => YELLOW,
                    };
                    draw_poly(pos.x, pos.y, 4, 15.0, 45.0, color);
                }

                // Bullets
                for b in &bullets {
                    let pos = Vec2::from(b.pos);
                    draw_circle(pos.x, pos.y, 4.0, if b.is_player { CYAN } else { PINK });
                }

                // UI
                draw_hud(&player, &director);

            },
            GameState::Paused => {
                draw_ui_text_centered("PAUSED", 0.0, 60.0, WHITE);
                draw_ui_text_centered("Press P to Resume", 40.0, 30.0, GRAY);
                draw_ui_text_centered("Press S to Save & Exit", 80.0, 30.0, GRAY);

                if is_key_pressed(KeyCode::P) { state = GameState::Playing; }
                if is_key_pressed(KeyCode::S) {
                    save_game(&GameSave {
                        player: player, // player is consumed here if not Copy, but struct fields are simple
                        // Manual copy needed due to structure complexity with serialization vs runtime
                        // Actually, Serde structs match.
                        enemies: enemies.iter().map(|e| e.data.clone()).collect(),
                        bullets: bullets.clone(),
                        difficulty: director.difficulty_multiplier,
                        level: 1,
                    });
                    state = GameState::Menu;
                }
            },
            GameState::GameOver => {
                draw_ui_text_centered("GAME OVER", -20.0, 60.0, RED);
                draw_ui_text_centered(&format!("Final Score: {}", player.score), 40.0, 40.0, WHITE);
                draw_ui_text_centered("Press SPACE for Menu", 80.0, 20.0, GRAY);

                if is_key_pressed(KeyCode::Space) { state = GameState::Menu; }
            }
        }
        next_frame().await;
    }
}

// ==========================================
// DIRECTOR & LOGIC
// ==========================================

fn update_director(director: &mut Director, enemies: &mut Vec<Enemy>, player: &PlayerState, dt: f32) {
    let time = get_time();
    
    // Dynamic Difficulty Check (every 5 seconds)
    if time - director.last_accuracy_check > 5.0 {
        director.last_accuracy_check = time;
        let accuracy = if player.shots_fired > 0 { player.shots_hit as f32 / player.shots_fired as f32 } else { 0.0 };
        
        // If playing well (high hp, high accuracy), increase difficulty
        if player.health > 3 && accuracy > 0.4 {
            director.difficulty_multiplier += 0.1;
        } else if player.health < 2 {
            director.difficulty_multiplier = (director.difficulty_multiplier - 0.1).max(0.5);
        }
    }

    // Spawning Logic
    director.spawn_timer -= dt;
    if director.spawn_timer <= 0.0 {
        let rng_val = ::rand::random::<f32>();
        
        if rng_val < 0.1 * director.difficulty_multiplier {
            // Event: Asteroid Field
            spawn_formation(enemies, EnemyType::Asteroid, 5);
            director.spawn_timer = 4.0;
        } else if rng_val < 0.4 {
            // Formation V
            spawn_formation(enemies, EnemyType::Basic, 3);
            director.spawn_timer = 2.0 / director.difficulty_multiplier;
        } else if rng_val < 0.6 {
            // Shooters
             spawn_enemy(enemies, EnemyType::Shooter, vec2(::rand::random::<f32>() * screen_width(), -50.0));
             director.spawn_timer = 1.5 / director.difficulty_multiplier;
        } else {
            // Kamikaze
            spawn_enemy(enemies, EnemyType::Kamikaze, vec2(::rand::random::<f32>() * screen_width(), -50.0));
            director.spawn_timer = 1.0 / director.difficulty_multiplier;
        }
    }
}

fn spawn_enemy(enemies: &mut Vec<Enemy>, e_type: EnemyType, pos: Vec2) {
    let health = match e_type {
        EnemyType::Asteroid => 999,
        EnemyType::Tank => 5,
        _ => 2,
    };
    
    enemies.push(Enemy {
        ai: create_ai(e_type),
        data: EnemyData {
            pos: pos.into(),
            vel: vec2(0.0, 0.0).into(),
            enemy_type: e_type,
            state: EnemyState::Cruising,
            health,
            max_health: health,
            last_action_time: get_time(),
        }
    });
}

fn spawn_formation(enemies: &mut Vec<Enemy>, e_type: EnemyType, count: i32) {
    let center_x = ::rand::random::<f32>() * (screen_width() - 100.0) + 50.0;
    for i in 0..count {
        let offset_x = (i as f32 - (count as f32 / 2.0)) * 40.0;
        let offset_y = offset_x.abs(); // V-Shape
        spawn_enemy(enemies, e_type, vec2(center_x + offset_x, -50.0 - offset_y));
    }
}

// ==========================================
// HELPERS & UI
// ==========================================

enum GameState { Menu, Playing, Paused, GameOver }

fn draw_stars(stars: &mut Vec<Star>, dt: f32) {
    for star in stars {
        star.pos.y += star.speed * dt;
        if star.pos.y > screen_height() {
            star.pos.y = 0.0;
            star.pos.x = ::rand::random::<f32>() * screen_width();
        }
        draw_circle(star.pos.x, star.pos.y, star.size, WHITE);
    }
}

fn draw_hud(player: &PlayerState, director: &Director) {
    // Top Left: Score & Multiplier
    draw_text(&format!("SCORE: {:06}", player.score), 20.0, 30.0, 30.0, WHITE);
    if player.combo > 1 {
        let scale = 1.0 + (player.combo as f32 * 0.1).min(1.0);
        draw_text(&format!("x{} COMBO!", player.combo), 20.0, 60.0, 20.0 * scale, GOLD);
        draw_rect_bar(20.0, 70.0, 100.0, 5.0, player.combo_timer / COMBO_DECAY, GOLD);
    }

    // Top Right: Health
    let hp_text = format!("HP: {}", player.health);
    let text_w = measure_text(&hp_text, None, 30, 1.0).width;
    draw_text(&hp_text, screen_width() - text_w - 20.0, 30.0, 30.0, if player.health < 2 { RED } else { GREEN });

    // Bottom Left: Ulti
    draw_text("ULTIMATE", 20.0, screen_height() - 40.0, 20.0, if player.ulti_energy >= 100.0 { CYAN } else { GRAY });
    draw_rect_bar(20.0, screen_height() - 30.0, 200.0, 10.0, player.ulti_energy / 100.0, CYAN);

    // Bottom Right: Difficulty
    draw_text(&format!("DANGER: {:.1}", director.difficulty_multiplier), screen_width() - 150.0, screen_height() - 20.0, 20.0, RED);
}

fn draw_rect_bar(x: f32, y: f32, w: f32, h: f32, pct: f32, color: Color) {
    draw_rectangle(x, y, w, h, DARKGRAY);
    draw_rectangle(x, y, w * pct.clamp(0.0, 1.0), h, color);
}

fn draw_ui_text_centered(text: &str, y_offset: f32, size: f32, color: Color) {
    let dims = measure_text(text, None, size as u16, 1.0);
    draw_text(text, screen_width() / 2.0 - dims.width / 2.0, screen_height() / 2.0 + y_offset, size, color);
}

fn reset_game(p: &mut PlayerState, e: &mut Vec<Enemy>, b: &mut Vec<Bullet>, d: &mut Director) {
    *p = PlayerState {
        pos: vec2(screen_width() / 2.0, screen_height() - 100.0).into(),
        health: 5,
        heat: 0.0,
        overheated: false,
        score: 0,
        high_score: load_high_score(),
        combo: 0,
        combo_timer: 0.0,
        ulti_energy: 0.0,
        shots_fired: 0,
        shots_hit: 0,
    };
    e.clear();
    b.clear();
    d.difficulty_multiplier = 1.0;
    d.spawn_timer = 0.0;
}

// ==========================================
// PERSISTENCE
// ==========================================

fn save_game(save: &GameSave) {
    if let Ok(json) = serde_json::to_string(save) {
        let _ = fs::write("savegame.json", json);
    }
}

fn load_game() -> Option<GameSave> {
    if let Ok(data) = fs::read_to_string("savegame.json") {
        serde_json::from_str(&data).ok()
    } else {
        None
    }
}

fn save_high_score(score: i32) {
    let _ = fs::write("highscore.txt", score.to_string());
}

fn load_high_score() -> i32 {
    fs::read_to_string("highscore.txt").unwrap_or("0".to_string()).parse().unwrap_or(0)
}
