use serde::{Deserialize, Serialize};

// ── Constants ─────────────────────────────────────────────────────────────────
pub const PLAYER_SPEED:   f32 = 350.0;
pub const MAX_HEAT:       f32 = 100.0;
pub const HEAT_PER_SHOT:  f32 = 12.0;
pub const COOLING_RATE:   f32 = 38.0;
pub const GRAZE_DISTANCE: f32 = 32.0;
pub const COMBO_DECAY:    f32 = 2.5;
pub const SCREEN_PADDING: f32 = 22.0;
pub const FIRE_RATE:      f64 = 0.10; // seconds between shots
pub const PLAYER_HP:      i32 = 5;
pub const PLAYER_RADIUS:  f32 = 12.0;
pub const BULLET_RADIUS:  f32 = 5.0;
pub const ENEMY_RADIUS:   f32 = 18.0;

// ── Vec2 serializable wrapper ─────────────────────────────────────────────────
#[derive(Serialize, Deserialize, Copy, Clone, Default)]
pub struct SerVec2 { pub x: f32, pub y: f32 }

impl SerVec2 {
    pub fn new(x: f32, y: f32) -> Self { Self { x, y } }
    pub fn distance(self, other: SerVec2) -> f32 {
        ((self.x - other.x).powi(2) + (self.y - other.y).powi(2)).sqrt()
    }
    pub fn length(self) -> f32 { (self.x * self.x + self.y * self.y).sqrt() }
    pub fn normalize(self) -> Self {
        let l = self.length();
        if l < 0.001 { Self::default() } else { Self::new(self.x / l, self.y / l) }
    }
    pub fn add(self, other: Self) -> Self { Self::new(self.x + other.x, self.y + other.y) }
    pub fn scale(self, s: f32) -> Self { Self::new(self.x * s, self.y * s) }
    pub fn sub(self, other: Self) -> Self { Self::new(self.x - other.x, self.y - other.y) }
    pub fn dot(self, other: Self) -> f32 { self.x * other.x + self.y * other.y }
}

// ── Enums ─────────────────────────────────────────────────────────────────────

#[derive(Serialize, Deserialize, Clone, PartialEq, Debug)]
pub enum EnemyState { Spawn, Cruising, Attacking, Retreating }

#[derive(Serialize, Deserialize, Clone, Copy, PartialEq, Debug)]
pub enum EnemyType { Basic, Fast, Tank, Shooter, Kamikaze, Asteroid, Boss }

#[derive(PartialEq, Clone)]
pub enum GameState { Menu, Playing, Paused, GameOver, Victory }

#[derive(Serialize, Deserialize, Clone, Copy, PartialEq)]
pub enum PowerUpType { Shield, RapidFire, DoubleCannon, NovaBomb, Heal }

// ── Structs ───────────────────────────────────────────────────────────────────

#[derive(Serialize, Deserialize, Clone)]
pub struct EnemyData {
    pub pos:              SerVec2,
    pub vel:              SerVec2,
    pub enemy_type:       EnemyType,
    pub state:            EnemyState,
    pub health:           i32,
    pub max_health:       i32,
    pub last_action_time: f64,
    /// Rotation angle for visual only
    pub angle:            f32,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Bullet {
    pub pos:       SerVec2,
    pub vel:       SerVec2,
    pub alive:     bool,
    pub is_player: bool,
    pub damage:    i32,
    pub grazed:    bool,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct PowerUp {
    pub pos:      SerVec2,
    pub kind:     PowerUpType,
    pub alive:    bool,
    pub lifetime: f32,
}

#[derive(Serialize, Deserialize, Clone, Copy)]
pub struct PlayerState {
    pub pos:          SerVec2,
    pub health:       i32,
    pub max_health:   i32,
    pub heat:         f32,
    pub overheated:   bool,
    pub score:        i32,
    pub high_score:   i32,
    pub combo:        i32,
    pub combo_timer:  f32,
    pub ulti_energy:  f32,
    pub shots_fired:  u32,
    pub shots_hit:    u32,
    pub shield:       bool,
    pub rapid_fire:   bool,
    pub rapid_timer:  f32,
    pub double_cannon:bool,
    pub double_timer: f32,
    pub invincible:   f32, // seconds of invincibility after hit
    pub last_shot:    f64,
}

pub struct Particle {
    pub pos:      SerVec2,
    pub vel:      SerVec2,
    pub lifetime: f32,
    pub max_life: f32,
    pub size:     f32,
    pub r: f32, pub g: f32, pub b: f32,
}

pub struct Star {
    pub pos:   SerVec2,
    pub speed: f32,
    pub size:  f32,
    pub alpha: f32,
}

pub struct Director {
    pub difficulty:     f32,
    pub spawn_timer:    f32,
    pub wave:           u32,
    pub kills_in_wave:  u32,
    pub wave_target:    u32,
    pub boss_alive:     bool,
    pub wave_msg:       Option<(String, f32)>,
}

#[derive(Serialize, Deserialize)]
pub struct GameSave {
    pub player:     PlayerState,
    pub enemies:    Vec<EnemyData>,
    pub bullets:    Vec<Bullet>,
    pub difficulty: f32,
    pub wave:       u32,
}
