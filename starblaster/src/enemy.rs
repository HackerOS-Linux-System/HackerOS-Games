use crate::types::*;

pub fn spawn_enemy(kind: EnemyType, x: f32, y: f32) -> EnemyData {
    let (hp, speed) = stats_for(kind);
    EnemyData {
        pos: SerVec2::new(x, y),
        vel: SerVec2::new(0.0, speed),
        enemy_type: kind,
        state: EnemyState::Spawn,
        health: hp,
        max_health: hp,
        last_action_time: 0.0,
        angle: 0.0,
    }
}

fn stats_for(kind: EnemyType) -> (i32, f32) {
    match kind {
        EnemyType::Basic    => (2, 80.0),
        EnemyType::Fast     => (1, 200.0),
        EnemyType::Tank     => (8, 50.0),
        EnemyType::Shooter  => (3, 60.0),
        EnemyType::Kamikaze => (1, 260.0),
        EnemyType::Asteroid => (5, 95.0),
        EnemyType::Boss     => (60, 40.0),
    }
}

pub fn update_enemy(
    e: &mut EnemyData,
    player_pos: SerVec2,
    sw: f32,
    sh: f32,
    dt: f32,
    now: f64,
    bullets: &mut Vec<Bullet>,
    rng: &mut impl rand_crate::Rng,
) {
    e.angle += dt * match e.enemy_type {
        EnemyType::Kamikaze  => 400.0,
        EnemyType::Boss      => 60.0,
        EnemyType::Asteroid  => 55.0,
        _ => 120.0,
    };

    match e.state {
        EnemyState::Spawn => {
            e.pos.y += e.vel.y * dt * 0.5;
            if e.pos.y > 60.0 { e.state = EnemyState::Cruising; }
        }
        EnemyState::Cruising => {
            e.pos.y += e.vel.y * dt;
            // Horizontal drift
            let drift = match e.enemy_type {
                EnemyType::Fast => (now as f32 * 2.5 + e.pos.x * 0.01).sin() * 160.0 * dt,
                EnemyType::Boss => (now as f32 * 0.8).sin() * 80.0 * dt,
                _               => (now as f32 * 1.2 + e.pos.x * 0.01).sin() * 60.0 * dt,
            };
            e.pos.x = (e.pos.x + drift).clamp(ENEMY_RADIUS, sw - ENEMY_RADIUS);

            // Attack transitions
            let dist = e.pos.distance(player_pos);
            if matches!(e.enemy_type, EnemyType::Kamikaze) && dist < 320.0 {
                e.state = EnemyState::Attacking;
            } else if matches!(e.enemy_type, EnemyType::Shooter | EnemyType::Boss) && dist < 380.0 && now - e.last_action_time > shoot_cooldown(e.enemy_type) {
                let dir = player_pos.sub(e.pos).normalize();
                let scatter: &[f32] = if e.enemy_type == EnemyType::Boss { &[-15.0, -7.0, 0.0, 7.0, 15.0] } else { &[-6.0, 0.0, 6.0] };
                for off in scatter {
                    let spread_x = dir.x + off.to_radians().sin();
                    let spd = if e.enemy_type == EnemyType::Boss { 260.0 } else { 200.0 };
                    bullets.push(Bullet {
                        pos: e.pos,
                        vel: SerVec2::new(spread_x * spd, dir.y * spd),
                        alive: true,
                        is_player: false,
                        damage: 1,
                        grazed: false,
                    });
                }
                e.last_action_time = now;
            }

            if e.pos.y > sh + ENEMY_RADIUS { e.pos.y = -ENEMY_RADIUS; }
        }
        EnemyState::Attacking => {
            // Kamikaze dive at player
            let dir = player_pos.sub(e.pos).normalize();
            let spd = 380.0;
            e.vel = SerVec2::new(dir.x * spd, dir.y * spd);
            e.pos = e.pos.add(e.vel.scale(dt));
        }
        EnemyState::Retreating => {
            e.pos.y -= e.vel.y * dt * 0.6;
            if e.pos.y < -ENEMY_RADIUS { e.pos.y = -ENEMY_RADIUS; e.state = EnemyState::Cruising; }
        }
    }
    let _ = rng; // may be used in future
}

fn shoot_cooldown(kind: EnemyType) -> f64 {
    match kind {
        EnemyType::Shooter => 1.4,
        EnemyType::Boss    => 0.6,
        _ => 2.0,
    }
}

// ── Director ─────────────────────────────────────────────────────────────────

pub fn director_tick(
    d: &mut Director,
    enemies: &mut Vec<EnemyData>,
    sw: f32,
    dt: f32,
    rng: &mut impl rand_crate::Rng,
    now: f64,
) {
    d.spawn_timer -= dt;
    if d.spawn_timer > 0.0 { return; }

    // Only progress wave when all enemies cleared (unless boss wave)
    if enemies.is_empty() {
        d.wave += 1;
        d.kills_in_wave = 0;
        d.wave_target = 5 + d.wave * 2;
        d.difficulty += 0.12;
        let msg = match d.wave {
            1            => "WAVE 1 — INCOMING!".into(),
            w if w % 10 == 0 => format!("WAVE {} — BOSS WAVE!", w),
            w if w % 5 == 0  => format!("WAVE {} — ELITE SQUAD!", w),
            w                => format!("WAVE {}", w),
        };
        d.wave_msg = Some((msg, 3.2));

        // Boss every 10 waves
        if d.wave % 10 == 0 && !d.boss_alive {
            enemies.push(spawn_enemy(EnemyType::Boss, sw / 2.0, -80.0));
            d.boss_alive = true;
        }
    }

    let spawn_rate = (2.5 / d.difficulty).clamp(0.35, 2.5);
    d.spawn_timer = spawn_rate;

    if d.boss_alive { return; }

    let kind = pick_enemy_type(d.wave, d.difficulty, rng);
    let x = rng.gen_range(ENEMY_RADIUS..(sw - ENEMY_RADIUS));
    enemies.push(spawn_enemy(kind, x, -ENEMY_RADIUS - 10.0));

    let _ = now;
}

fn pick_enemy_type(wave: u32, diff: f32, rng: &mut impl rand_crate::Rng) -> EnemyType {
    let roll: f32 = rng.gen();
    if wave < 3      { return EnemyType::Basic; }
    if wave < 5      { return if roll < 0.3 { EnemyType::Fast } else { EnemyType::Basic }; }
    if diff < 1.5    { return if roll < 0.4 { EnemyType::Fast } else if roll < 0.6 { EnemyType::Asteroid } else { EnemyType::Basic }; }
    if diff < 2.5 {
        return match (roll * 10.0) as u32 {
            0..=3 => EnemyType::Basic,
            4..=5 => EnemyType::Fast,
            6     => EnemyType::Tank,
            7     => EnemyType::Shooter,
            8     => EnemyType::Asteroid,
            _     => EnemyType::Kamikaze,
        };
    }
    match (roll * 10.0) as u32 {
        0..=1 => EnemyType::Basic,
        2..=3 => EnemyType::Fast,
        4     => EnemyType::Tank,
        5     => EnemyType::Shooter,
        6     => EnemyType::Kamikaze,
        7..=8 => EnemyType::Asteroid,
        _     => EnemyType::Shooter,
    }
}
