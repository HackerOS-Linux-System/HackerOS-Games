use macroquad::prelude::*;
use crate::types::*;

pub fn draw_player(p: &PlayerState) {
    let x = p.pos.x;
    let y = p.pos.y;
    let r = PLAYER_RADIUS;

    // Engine glow
    let glow_a = if (get_time() * 6.0).sin() > 0.0 { 0.5 } else { 0.3 };
    draw_circle(x, y + r * 1.6, r * 0.7, Color::new(0.3, 0.6, 1.0, glow_a));

    // Shield bubble
    if p.shield {
        let t = get_time() as f32;
        let sa = 0.25 + (t * 3.0).sin().abs() * 0.15;
        draw_circle(x, y, r * 2.4, Color::new(0.2, 0.7, 1.0, sa));
        draw_circle_lines(x, y, r * 2.4, 2.0, Color::new(0.3, 0.8, 1.0, 0.8));
    }

    // Invincibility flash
    if p.invincible > 0.0 && ((get_time() * 12.0) as i32 % 2 == 0) { return; }

    // Main hull — triangle pointing up
    let top = Vec2::new(x, y - r * 1.6);
    let bl  = Vec2::new(x - r * 1.1, y + r * 1.1);
    let br  = Vec2::new(x + r * 1.1, y + r * 1.1);
    draw_triangle(top, bl, br, Color::new(0.2, 0.7, 1.0, 1.0));

    // Wing accents
    draw_line(x - r, y + r * 0.6, x - r * 1.6, y + r * 1.4, 2.0, Color::new(0.6, 0.9, 1.0, 0.9));
    draw_line(x + r, y + r * 0.6, x + r * 1.6, y + r * 1.4, 2.0, Color::new(0.6, 0.9, 1.0, 0.9));

    // Cockpit
    draw_circle(x, y - r * 0.3, r * 0.4, Color::new(0.8, 0.95, 1.0, 0.9));

    // Rapid fire indicator
    if p.rapid_fire {
        draw_circle_lines(x, y, r * 1.3, 1.5, Color::new(1.0, 0.8, 0.0, 0.7));
    }
    // Double cannon indicator
    if p.double_cannon {
        draw_circle_lines(x, y, r * 1.7, 1.5, Color::new(1.0, 0.4, 0.0, 0.7));
    }
}

pub fn draw_enemy(e: &EnemyData) {
    let x = e.pos.x;
    let y = e.pos.y;
    let hp_ratio = e.health as f32 / e.max_health as f32;

    // Spawn animation
    let scale = if e.state == EnemyState::Spawn {
        let t = ((get_time() * 3.0).sin().abs() as f32).min(1.0);
        t
    } else { 1.0 };

    match e.enemy_type {
        EnemyType::Basic => {
            let r = ENEMY_RADIUS * scale;
            draw_poly(x, y, 6, r, e.angle, RED);
            draw_poly_lines(x, y, 6, r + 2.0, e.angle, 1.5, Color::new(1.0, 0.4, 0.4, 0.8));
            draw_circle(x, y, r * 0.35, Color::new(1.0, 0.9, 0.2, 0.9));
        }
        EnemyType::Fast => {
            let r = ENEMY_RADIUS * 0.7 * scale;
            let top = Vec2::new(x, y - r * 2.0);
            let bl  = Vec2::new(x - r * 1.2, y + r * 0.8);
            let br  = Vec2::new(x + r * 1.2, y + r * 0.8);
            draw_triangle(top, bl, br, Color::new(1.0, 0.6, 0.0, 1.0));
            draw_circle(x, y - r * 0.3, r * 0.3, WHITE);
        }
        EnemyType::Tank => {
            let r = ENEMY_RADIUS * 1.5 * scale;
            draw_circle(x, y, r, Color::new(0.5, 0.0, 0.8, 1.0));
            draw_circle_lines(x, y, r + 3.0, 2.5, Color::new(0.8, 0.4, 1.0, 0.7));
            draw_circle(x, y, r * 0.45, Color::new(0.9, 0.7, 1.0, 0.9));
            // Health ring
            draw_arc(x, y, r + 5.0, hp_ratio, Color::new(0.8, 0.4, 1.0, 0.9));
        }
        EnemyType::Shooter => {
            let r = ENEMY_RADIUS * scale;
            draw_poly(x, y, 4, r, e.angle, Color::new(0.2, 0.9, 0.9, 1.0));
            draw_poly_lines(x, y, 4, r + 2.0, e.angle + 45.0, 1.5, Color::new(0.4, 1.0, 1.0, 0.7));
            draw_circle(x, y, r * 0.3, Color::new(1.0, 0.5, 0.0, 1.0));
        }
        EnemyType::Kamikaze => {
            let r = ENEMY_RADIUS * 0.9 * scale;
            let t = (get_time() * 8.0).sin() as f32 * 0.5 + 0.5;
            let col = Color::new(1.0, 0.2 + t * 0.5, 0.0, 1.0);
            draw_poly(x, y, 8, r, e.angle, col);
            draw_circle(x, y, r * 0.4, Color::new(1.0, 1.0, 0.0, 1.0));
        }
        EnemyType::Asteroid => {
            let r = ENEMY_RADIUS * 1.2 * scale;
            draw_poly(x, y, 7, r, e.angle, Color::new(0.5, 0.45, 0.4, 1.0));
            draw_poly_lines(x, y, 7, r + 1.0, e.angle + 25.0, 1.0, Color::new(0.7, 0.65, 0.6, 0.5));
        }
        EnemyType::Boss => {
            let r = ENEMY_RADIUS * 3.0 * scale;
            let t = get_time() as f32;
            draw_circle(x, y, r, Color::new(0.7, 0.0, 0.2, 1.0));
            draw_circle_lines(x, y, r + 4.0, 3.0, Color::new(1.0, 0.1, 0.3, 0.9));
            draw_circle_lines(x, y, r + 10.0, 1.5, Color::new(1.0, 0.4, 0.1, 0.4 + (t * 2.0).sin().abs() * 0.3));
            draw_circle(x, y, r * 0.38, Color::new(1.0, 0.7, 0.0, 0.95));
            // 4 rotating cannons
            for i in 0..4 {
                let a = e.angle + i as f32 * 90.0;
                let arm_x = x + a.to_radians().cos() * r * 0.75;
                let arm_y = y + a.to_radians().sin() * r * 0.75;
                draw_circle(arm_x, arm_y, 7.0, Color::new(1.0, 0.3, 0.0, 0.9));
            }
            // HP bar
            draw_arc(x, y, r + 12.0, hp_ratio, Color::new(1.0, 0.1, 0.2, 0.9));
        }
    }

    // Damage flash
    if hp_ratio < 0.35 {
        let a = ((get_time() * 10.0).sin().abs() * 0.4) as f32;
        draw_circle(x, y, ENEMY_RADIUS * 1.2, Color::new(1.0, 0.0, 0.0, a));
    }
}

fn draw_arc(cx: f32, cy: f32, r: f32, frac: f32, col: Color) {
    let steps = (frac * 40.0) as i32;
    for i in 0..steps {
        let a1 = (-90.0 + i as f32 * 9.0 * frac).to_radians();
        let a2 = (-90.0 + (i + 1) as f32 * 9.0 * frac).to_radians();
        draw_line(
            cx + a1.cos() * r, cy + a1.sin() * r,
            cx + a2.cos() * r, cy + a2.sin() * r,
            2.5, col,
        );
    }
}

pub fn draw_bullet(b: &Bullet) {
    if b.is_player {
        let col = if b.damage > 1 { Color::new(1.0, 0.5, 0.0, 0.95) } else { Color::new(0.3, 0.9, 1.0, 0.95) };
        draw_circle(b.pos.x, b.pos.y, BULLET_RADIUS + 1.0, col);
        draw_circle(b.pos.x, b.pos.y, BULLET_RADIUS * 0.5, WHITE);
    } else {
        draw_circle(b.pos.x, b.pos.y, BULLET_RADIUS + 0.5, Color::new(1.0, 0.15, 0.15, 0.95));
        draw_circle(b.pos.x, b.pos.y, BULLET_RADIUS * 0.4, Color::new(1.0, 0.7, 0.7, 0.85));
    }
}

pub fn draw_powerup(p: &PowerUp) {
    let (col, symbol) = match p.kind {
        PowerUpType::Shield      => (Color::new(0.2, 0.6, 1.0, 1.0), "S"),
        PowerUpType::RapidFire   => (Color::new(1.0, 0.8, 0.0, 1.0), "R"),
        PowerUpType::DoubleCannon=> (Color::new(1.0, 0.4, 0.0, 1.0), "D"),
        PowerUpType::NovaBomb    => (Color::new(0.8, 0.0, 1.0, 1.0), "N"),
        PowerUpType::Heal        => (Color::new(0.0, 1.0, 0.4, 1.0), "+"),
    };
    let t = get_time() as f32;
    let bob = (t * 3.0).sin() * 4.0;
    let spin = t * 80.0;
    draw_poly(p.pos.x, p.pos.y + bob, 5, 14.0, spin, Color::new(col.r, col.g, col.b, 0.15 + (t * 2.0).sin().abs() * 0.1));
    draw_poly_lines(p.pos.x, p.pos.y + bob, 5, 14.0, spin, 2.0, col);
    let m = measure_text(symbol, None, 18, 1.0);
    draw_text(symbol, p.pos.x - m.width / 2.0, p.pos.y + bob + 6.0, 18.0, col);
}

pub fn draw_particles(particles: &[Particle]) {
    for p in particles {
        let a = (p.lifetime / p.max_life).clamp(0.0, 1.0);
        draw_circle(p.pos.x, p.pos.y, p.size * a, Color::new(p.r, p.g, p.b, a));
    }
}

pub fn draw_starfield(stars: &[Star], dt: f32, mut scroll_y: f32) -> f32 {
    scroll_y += 40.0 * dt;
    for s in stars {
        let sy = (s.pos.y + scroll_y * s.speed) % screen_height();
        draw_circle(s.pos.x, sy, s.size, Color::new(0.8, 0.85, 1.0, s.alpha));
    }
    scroll_y
}

pub fn draw_hud(p: &PlayerState, wave: u32, director_diff: f32) {
    let sw = screen_width();
    let sh = screen_height();

    // Top bar bg
    draw_rectangle(0.0, 0.0, sw, 44.0, Color::new(0.0, 0.0, 0.05, 0.85));

    // HP pips
    for i in 0..p.max_health {
        let col = if i < p.health { Color::new(0.2, 1.0, 0.4, 1.0) } else { Color::new(0.2, 0.2, 0.2, 0.6) };
        draw_circle(18.0 + i as f32 * 22.0, 22.0, 8.0, col);
        draw_circle_lines(18.0 + i as f32 * 22.0, 22.0, 9.0, 1.0, Color::new(0.3, 0.3, 0.3, 0.5));
    }

    // Heat bar
    let heat_x = 180.0;
    let heat_w = 120.0;
    draw_rectangle(heat_x, 12.0, heat_w, 12.0, Color::new(0.15, 0.0, 0.0, 0.9));
    let heat_frac = (p.heat / MAX_HEAT).clamp(0.0, 1.0);
    let hcol = if p.overheated { Color::new(1.0, 0.0, 0.0, 1.0) } else if heat_frac > 0.7 { Color::new(1.0, 0.4, 0.0, 1.0) } else { Color::new(0.0, 0.8, 0.2, 1.0) };
    draw_rectangle(heat_x, 12.0, heat_w * heat_frac, 12.0, hcol);
    draw_rectangle_lines(heat_x, 12.0, heat_w, 12.0, 1.0, Color::new(0.3, 0.3, 0.3, 0.6));
    if p.overheated {
        draw_text("OVERHEAT", heat_x + 18.0, 28.0, 10.0, Color::new(1.0, 0.3, 0.3, 1.0));
    } else {
        draw_text(&format!("HEAT {:.0}%", heat_frac * 100.0), heat_x + 10.0, 28.0, 10.0, Color::new(0.5, 0.5, 0.5, 0.8));
    }

    // Combo
    if p.combo > 1 {
        let cc = Color::new(1.0, 0.8, 0.0, 1.0);
        draw_text(&format!("×{}", p.combo), 320.0, 30.0, 26.0, cc);
        // Combo decay bar
        draw_rectangle(318.0, 34.0, 60.0 * (p.combo_timer / COMBO_DECAY).clamp(0.0, 1.0), 3.0, cc);
    }

    // Score
    let score_str = format!("{:08}", p.score);
    let sw2 = measure_text(&score_str, None, 28, 1.0).width;
    draw_text(&score_str, sw / 2.0 - sw2 / 2.0, 32.0, 28.0, WHITE);

    // Wave
    let wave_str = format!("WAVE {}", wave);
    draw_text(&wave_str, sw - 120.0, 20.0, 18.0, Color::new(0.7, 0.7, 0.9, 1.0));
    draw_text(&format!("DIF {:.1}", director_diff), sw - 120.0, 38.0, 12.0, Color::new(0.5, 0.5, 0.7, 0.7));

    // High score
    if p.score == p.high_score && p.score > 0 {
        let hs = "★ NEW HIGH SCORE";
        let hw = measure_text(hs, None, 16, 1.0).width;
        draw_text(hs, sw / 2.0 - hw / 2.0, sh - 10.0, 16.0, Color::new(1.0, 0.8, 0.0, 1.0));
    } else {
        draw_text(&format!("BEST: {:08}", p.high_score), sw - 160.0, sh - 10.0, 14.0, Color::new(0.5, 0.5, 0.5, 0.7));
    }

    // Graze info
    let acc = if p.shots_fired > 0 { p.shots_hit * 100 / p.shots_fired } else { 0 };
    draw_text(&format!("ACC {}%", acc), 16.0, sh - 10.0, 12.0, Color::new(0.5, 0.6, 0.5, 0.7));

    // Ulti energy
    let ulti_x = sw - 80.0;
    let ulti_y = 52.0;
    draw_rectangle(ulti_x, ulti_y, 64.0, 8.0, Color::new(0.1, 0.0, 0.2, 0.8));
    draw_rectangle(ulti_x, ulti_y, 64.0 * (p.ulti_energy / 100.0).clamp(0.0, 1.0), 8.0, Color::new(0.7, 0.2, 1.0, 0.9));
    draw_rectangle_lines(ulti_x, ulti_y, 64.0, 8.0, 1.0, Color::new(0.5, 0.3, 0.6, 0.4));
    draw_text("NOVA", ulti_x + 18.0, ulti_y + 20.0, 10.0, Color::new(0.8, 0.5, 1.0, 0.8));

    // Active buffs
    let mut bx = 16.0;
    let by = sh - 32.0;
    if p.shield {
        draw_text("SHIELD", bx, by, 13.0, Color::new(0.3, 0.7, 1.0, 0.9));
        bx += 60.0;
    }
    if p.rapid_fire {
        draw_text(&format!("RAPID {:.1}s", p.rapid_timer), bx, by, 13.0, Color::new(1.0, 0.8, 0.0, 0.9));
        bx += 90.0;
    }
    if p.double_cannon {
        draw_text(&format!("DOUBLE {:.1}s", p.double_timer), bx, by, 13.0, Color::new(1.0, 0.4, 0.0, 0.9));
    }
}

pub fn draw_wave_msg(msg: &str, alpha: f32) {
    let sw = screen_width();
    let sh = screen_height();
    let m = measure_text(msg, None, 42, 1.0);
    draw_text(msg, sw / 2.0 - m.width / 2.0, sh / 2.0 - 80.0, 42.0, Color::new(1.0, 0.8, 0.2, alpha));
}

pub fn draw_menu(high_score: i32) {
    let sw = screen_width();
    let sh = screen_height();
    clear_background(Color::new(0.0, 0.0, 0.06, 1.0));

    let title = "STARBLASTER";
    let tw = measure_text(title, None, 72, 1.0).width;
    draw_text(title, sw / 2.0 - tw / 2.0, sh * 0.30, 72.0, Color::new(0.2, 0.8, 1.0, 1.0));
    let sub = "SURVIVE THE VOID";
    let sw2 = measure_text(sub, None, 20, 1.0).width;
    draw_text(sub, sw / 2.0 - sw2 / 2.0, sh * 0.30 + 52.0, 20.0, Color::new(0.5, 0.6, 0.8, 0.8));

    // Controls
    let info = [
        "ARROWS / WASD — Move",
        "SPACE / Z — Shoot",
        "X — Nova Bomb (full energy)",
        "ESC — Pause",
        "F5 — Quicksave  •  F9 — Quickload",
    ];
    for (i, line) in info.iter().enumerate() {
        let lw = measure_text(line, None, 15, 1.0).width;
        draw_text(line, sw / 2.0 - lw / 2.0, sh * 0.50 + i as f32 * 22.0, 15.0, Color::new(0.6, 0.65, 0.7, 0.85));
    }

    let s = "PRESS SPACE OR ENTER TO START";
    let sw3 = measure_text(s, None, 20, 1.0).width;
    let a = ((get_time() * 2.0).sin().abs() * 0.5 + 0.5) as f32;
    draw_text(s, sw / 2.0 - sw3 / 2.0, sh * 0.80, 20.0, Color::new(0.3, 0.9, 0.5, a));

    if high_score > 0 {
        let hs = format!("BEST: {:08}", high_score);
        let hw = measure_text(&hs, None, 18, 1.0).width;
        draw_text(&hs, sw / 2.0 - hw / 2.0, sh * 0.88, 18.0, Color::new(1.0, 0.8, 0.2, 0.9));
    }
}

pub fn draw_game_over(score: i32, high_score: i32, wave: u32, accuracy: u32) {
    let sw = screen_width();
    let sh = screen_height();
    draw_rectangle(0.0, 0.0, sw, sh, Color::new(0.0, 0.0, 0.0, 0.72));

    let title = if score == high_score && score > 0 { "★ NEW RECORD ★" } else { "GAME OVER" };
    let tc = if score == high_score && score > 0 { Color::new(1.0, 0.8, 0.0, 1.0) } else { Color::new(1.0, 0.2, 0.2, 1.0) };
    let tw = measure_text(title, None, 52, 1.0).width;
    draw_text(title, sw / 2.0 - tw / 2.0, sh * 0.32, 52.0, tc);

    let stats = [
        format!("SCORE    {:08}", score),
        format!("WAVE     {}", wave),
        format!("ACCURACY {}%", accuracy),
        format!("BEST     {:08}", high_score),
    ];
    for (i, line) in stats.iter().enumerate() {
        let lw = measure_text(line, None, 22, 1.0).width;
        draw_text(line, sw / 2.0 - lw / 2.0, sh * 0.47 + i as f32 * 32.0, 22.0, Color::new(0.85, 0.85, 0.9, 0.95));
    }

    let s = "SPACE / ENTER — Play Again   •   ESC — Menu";
    let lw = measure_text(s, None, 16, 1.0).width;
    draw_text(s, sw / 2.0 - lw / 2.0, sh * 0.78, 16.0, Color::new(0.6, 0.6, 0.7, 0.85));
}

pub fn draw_pause_screen() {
    let sw = screen_width();
    let sh = screen_height();
    draw_rectangle(0.0, 0.0, sw, sh, Color::new(0.0, 0.0, 0.0, 0.55));
    let t = "PAUSED";
    let tw = measure_text(t, None, 58, 1.0).width;
    draw_text(t, sw / 2.0 - tw / 2.0, sh / 2.0, 58.0, Color::new(0.7, 0.9, 1.0, 1.0));
    let s = "ESC — Resume   •   Q — Quit to Menu";
    let sw2 = measure_text(s, None, 18, 1.0).width;
    draw_text(s, sw / 2.0 - sw2 / 2.0, sh / 2.0 + 50.0, 18.0, Color::new(0.65, 0.65, 0.75, 0.85));
}
