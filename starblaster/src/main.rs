#![allow(dead_code)]
extern crate rand as rand_crate;

use macroquad::prelude::*;
use rand_crate::{thread_rng, Rng};

mod types;
mod render;
mod enemy;
mod physics;
mod save;

use types::*;
use render::*;
use enemy::{director_tick, update_enemy};
use physics::*;
use save::{save_game, load_game, save_hiscore, load_hiscore};

fn new_player(sw: f32, sh: f32, high_score: i32) -> PlayerState {
    PlayerState {
        pos: SerVec2::new(sw / 2.0, sh - 80.0),
        health: PLAYER_HP, max_health: PLAYER_HP,
        heat: 0.0, overheated: false,
        score: 0, high_score, combo: 1, combo_timer: 0.0,
        ulti_energy: 0.0, shots_fired: 0, shots_hit: 0,
        shield: false, rapid_fire: false, rapid_timer: 0.0,
        double_cannon: false, double_timer: 0.0,
        invincible: 0.0, last_shot: 0.0,
    }
}

fn new_director() -> Director {
    Director {
        difficulty: 1.0, spawn_timer: 1.5, wave: 0,
        kills_in_wave: 0, wave_target: 5, boss_alive: false,
        wave_msg: None,
    }
}

fn new_stars(sw: f32, sh: f32, rng: &mut impl Rng) -> Vec<Star> {
    (0..140).map(|_| Star {
        pos: SerVec2::new(rng.gen_range(0.0..sw), rng.gen_range(0.0..sh)),
        speed: rng.gen_range(0.3..1.8),
        size: rng.gen_range(0.5..2.2),
        alpha: rng.gen_range(0.3..0.9),
    }).collect()
}

#[macroquad::main("Starblaster")]
async fn main() {
    let sw = screen_width();
    let sh = screen_height();
    let mut rng = thread_rng();

    let high_score = load_hiscore();

    let mut game_state = GameState::Menu;
    let mut player     = new_player(sw, sh, high_score);
    let mut enemies:   Vec<EnemyData> = Vec::new();
    let mut bullets:   Vec<Bullet>    = Vec::new();
    let mut powerups:  Vec<PowerUp>   = Vec::new();
    let mut particles: Vec<Particle>  = Vec::new();
    let mut director   = new_director();
    let mut stars      = new_stars(sw, sh, &mut rng);
    let mut star_scroll: f32 = 0.0;

    loop {
        let dt = get_frame_time().min(0.05);
        let now = get_time();

        match game_state {
            GameState::Menu => {
                clear_background(Color::new(0.0, 0.0, 0.06, 1.0));
                star_scroll = draw_starfield(&stars, dt, star_scroll);
                draw_menu(player.high_score);
                if is_key_pressed(KeyCode::Space) || is_key_pressed(KeyCode::Enter) {
                    player = new_player(sw, sh, player.high_score);
                    enemies.clear(); bullets.clear(); powerups.clear(); particles.clear();
                    director = new_director();
                    game_state = GameState::Playing;
                }
                if is_key_pressed(KeyCode::F9) {
                    if let Some(gs) = load_game() {
                        player = gs.player;
                        enemies = gs.enemies;
                        bullets = gs.bullets;
                        director.difficulty = gs.difficulty;
                        director.wave = gs.wave;
                        game_state = GameState::Playing;
                    }
                }
            }

            GameState::Playing => {
                // ── Input ──────────────────────────────────────────────────────
                let spd = PLAYER_SPEED * dt;
                if is_key_down(KeyCode::Left)  || is_key_down(KeyCode::A) { player.pos.x -= spd; }
                if is_key_down(KeyCode::Right) || is_key_down(KeyCode::D) { player.pos.x += spd; }
                if is_key_down(KeyCode::Up)    || is_key_down(KeyCode::W) { player.pos.y -= spd; }
                if is_key_down(KeyCode::Down)  || is_key_down(KeyCode::S) { player.pos.y += spd; }
                player.pos.x = player.pos.x.clamp(SCREEN_PADDING + PLAYER_RADIUS, sw - SCREEN_PADDING - PLAYER_RADIUS);
                player.pos.y = player.pos.y.clamp(50.0, sh - SCREEN_PADDING - PLAYER_RADIUS);

                // Shoot
                let fire_rate = if player.rapid_fire { FIRE_RATE * 0.4 } else { FIRE_RATE };
                let shooting = is_key_down(KeyCode::Space) || is_key_down(KeyCode::Z);
                if shooting && !player.overheated && now - player.last_shot >= fire_rate {
                    if !player.overheated {
                        player.heat += HEAT_PER_SHOT;
                        player.shots_fired += 1;
                        player.last_shot = now;
                        let spd_b = 680.0;
                        let dmg = if player.rapid_fire { 2 } else { 1 };
                        bullets.push(Bullet { pos: player.pos, vel: SerVec2::new(0.0, -spd_b), alive: true, is_player: true, damage: dmg, grazed: false });
                        if player.double_cannon {
                            bullets.push(Bullet { pos: SerVec2::new(player.pos.x - 18.0, player.pos.y), vel: SerVec2::new(-20.0, -spd_b), alive: true, is_player: true, damage: dmg, grazed: false });
                            bullets.push(Bullet { pos: SerVec2::new(player.pos.x + 18.0, player.pos.y), vel: SerVec2::new(20.0, -spd_b), alive: true, is_player: true, damage: dmg, grazed: false });
                        }
                    }
                }

                // Heat cooling
                if !shooting || player.overheated {
                    player.heat = (player.heat - COOLING_RATE * dt).max(0.0);
                }
                if player.heat >= MAX_HEAT { player.overheated = true; }
                if player.overheated && player.heat <= 0.0 { player.overheated = false; }

                // Nova Bomb
                if (is_key_pressed(KeyCode::X) || is_key_pressed(KeyCode::LeftShift)) && player.ulti_energy >= 100.0 {
                    let kills = nova_bomb(&mut enemies, &mut particles);
                    player.ulti_energy = 0.0;
                    player.score += kills as i32 * 200 * player.combo;
                    player.combo += kills as i32;
                    player.combo_timer = COMBO_DECAY;
                }

                // Power-up timers
                if player.rapid_fire { player.rapid_timer -= dt; if player.rapid_timer <= 0.0 { player.rapid_fire = false; } }
                if player.double_cannon { player.double_timer -= dt; if player.double_timer <= 0.0 { player.double_cannon = false; } }
                if player.invincible > 0.0 { player.invincible -= dt; }

                // Combo decay
                if player.combo > 1 {
                    player.combo_timer -= dt;
                    if player.combo_timer <= 0.0 { player.combo = 1; }
                }

                // Quicksave / load
                if is_key_pressed(KeyCode::F5) { save_game(&player, &enemies, &bullets, &director); }
                if is_key_pressed(KeyCode::F9) {
                    if let Some(gs) = load_game() {
                        player = gs.player; enemies = gs.enemies; bullets = gs.bullets;
                        director.difficulty = gs.difficulty; director.wave = gs.wave;
                    }
                }

                // ── Update bullets ─────────────────────────────────────────────
                for b in &mut bullets {
                    b.pos.x += b.vel.x * dt;
                    b.pos.y += b.vel.y * dt;
                    if b.pos.y < -10.0 || b.pos.y > sh + 10.0 || b.pos.x < -20.0 || b.pos.x > sw + 20.0 {
                        b.alive = false;
                    }
                }

                // ── Enemy update ───────────────────────────────────────────────
                for e in &mut enemies {
                    update_enemy(e, player.pos, sw, sh, dt, now, &mut bullets, &mut rng);
                }

                // ── Physics ────────────────────────────────────────────────────
                let (kills, graze) = check_player_bullets_vs_enemies(&mut bullets, &mut enemies, &mut particles, &mut player);
                if kills > 0 {
                    let pts = kills as i32 * 100 * player.combo;
                    player.score += pts;
                    player.combo += kills as i32;
                    player.combo_timer = COMBO_DECAY;
                    player.ulti_energy = (player.ulti_energy + kills as f32 * 12.0).min(100.0);
                    director.kills_in_wave += kills;
                    for e in enemies.iter().filter(|e| e.health <= 0) {
                        maybe_spawn_powerup(e.pos, &mut powerups, &mut rng);
                    }
                    // Update boss flag
                    if !enemies.iter().any(|e| e.enemy_type == EnemyType::Boss && e.health > 0) {
                        director.boss_alive = false;
                    }
                }
                if graze {
                    player.score += 15 * player.combo;
                    player.ulti_energy = (player.ulti_energy + 3.0).min(100.0);
                    spawn_graze_particles(&mut particles, player.pos);
                }
                let _ = check_enemy_bullets_vs_player(&mut bullets, &mut player, &mut particles);
                let _ = check_enemies_vs_player(&mut enemies, &mut player, &mut particles);
                let _ = check_powerup_pickup(&mut powerups, &mut player);

                // Update high score
                if player.score > player.high_score { player.high_score = player.score; }

                // ── Particle update ────────────────────────────────────────────
                for p in &mut particles {
                    p.pos = p.pos.add(p.vel.scale(dt));
                    p.lifetime -= dt;
                    p.vel = p.vel.scale(0.93);
                }
                for p in &mut powerups { p.lifetime -= dt; if p.lifetime <= 0.0 { p.alive = false; } }

                // Cleanup
                enemies.retain(|e| e.health > 0 && e.pos.y < sh + 120.0);
                bullets.retain(|b| b.alive);
                particles.retain(|p| p.lifetime > 0.0);
                powerups.retain(|p| p.alive);

                // ── Director ───────────────────────────────────────────────────
                director_tick(&mut director, &mut enemies, sw, dt, &mut rng, now);
                if let Some((_, ref mut t)) = director.wave_msg { *t -= dt; }
                if director.wave_msg.as_ref().map(|(_, t)| *t <= 0.0).unwrap_or(false) { director.wave_msg = None; }

                // ── Draw ───────────────────────────────────────────────────────
                clear_background(Color::new(0.0, 0.0, 0.05, 1.0));
                star_scroll = draw_starfield(&stars, dt, star_scroll);

                for e in &enemies { draw_enemy(e); }
                for p in &powerups { draw_powerup(p); }
                for b in &bullets { draw_bullet(b); }
                draw_particles(&particles);
                draw_player(&player);
                draw_hud(&player, director.wave, director.difficulty);
                if let Some((ref msg, ref t)) = director.wave_msg {
                    draw_wave_msg(msg, (*t / 3.2).clamp(0.0, 1.0));
                }

                // ── State transitions ──────────────────────────────────────────
                if is_key_pressed(KeyCode::Escape) { game_state = GameState::Paused; }
                if player.health <= 0 {
                    save_hiscore(player.high_score);
                    game_state = GameState::GameOver;
                }
            }

            GameState::Paused => {
                clear_background(Color::new(0.0, 0.0, 0.05, 1.0));
                star_scroll = draw_starfield(&stars, dt, star_scroll);
                for e in &enemies { draw_enemy(e); }
                for b in &bullets { draw_bullet(b); }
                draw_player(&player);
                draw_hud(&player, director.wave, director.difficulty);
                draw_pause_screen();

                if is_key_pressed(KeyCode::Escape) { game_state = GameState::Playing; }
                if is_key_pressed(KeyCode::Q) {
                    save_hiscore(player.high_score);
                    game_state = GameState::Menu;
                    player = new_player(sw, sh, player.high_score);
                    enemies.clear(); bullets.clear(); powerups.clear(); particles.clear();
                    director = new_director();
                }
            }

            GameState::GameOver => {
                clear_background(Color::new(0.0, 0.0, 0.05, 1.0));
                star_scroll = draw_starfield(&stars, dt, star_scroll);
                let acc = if player.shots_fired > 0 { player.shots_hit * 100 / player.shots_fired } else { 0 };
                draw_game_over(player.score, player.high_score, director.wave, acc);

                if is_key_pressed(KeyCode::Space) || is_key_pressed(KeyCode::Enter) {
                    let hs = player.high_score;
                    player = new_player(sw, sh, hs);
                    enemies.clear(); bullets.clear(); powerups.clear(); particles.clear();
                    director = new_director();
                    game_state = GameState::Playing;
                }
                if is_key_pressed(KeyCode::Escape) {
                    game_state = GameState::Menu;
                    let hs = player.high_score;
                    player = new_player(sw, sh, hs);
                    enemies.clear(); bullets.clear(); powerups.clear(); particles.clear();
                    director = new_director();
                }
            }

            GameState::Victory => { game_state = GameState::Menu; }
        }

        next_frame().await;
    }
}
