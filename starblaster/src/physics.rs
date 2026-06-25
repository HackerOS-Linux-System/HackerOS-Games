use crate::types::*;

/// Returns (killed, graze_gained)
pub fn check_player_bullets_vs_enemies(
    bullets: &mut Vec<Bullet>,
    enemies: &mut Vec<EnemyData>,
    particles: &mut Vec<Particle>,
    player: &mut PlayerState,
) -> (u32, bool) {
    let mut kills = 0u32;
    let mut graze = false;

    for b in bullets.iter_mut().filter(|b| b.alive && b.is_player) {
        for e in enemies.iter_mut() {
            if b.pos.distance(e.pos) < BULLET_RADIUS + ENEMY_RADIUS * e_radius_mult(e.enemy_type) {
                e.health -= b.damage;
                b.alive = false;
                player.shots_hit += 1;
                spawn_hit_particles(particles, b.pos, 6);
                if e.health <= 0 {
                    e.state = EnemyState::Retreating;
                    kills += 1;
                    spawn_explosion(particles, e.pos, e.enemy_type);
                }
                break;
            }
        }
    }

    // Graze: player bullets that pass within GRAZE_DISTANCE of living enemies
    for b in bullets.iter_mut().filter(|b| b.alive && b.is_player && !b.grazed) {
        for e in enemies.iter().filter(|e| e.health > 0) {
            let dist = b.pos.distance(e.pos);
            if dist < GRAZE_DISTANCE && dist > BULLET_RADIUS + ENEMY_RADIUS * e_radius_mult(e.enemy_type) {
                b.grazed = true;
                graze = true;
            }
        }
    }

    (kills, graze)
}

/// Returns true if player was hit.
pub fn check_enemy_bullets_vs_player(
    bullets: &mut Vec<Bullet>,
    player: &mut PlayerState,
    particles: &mut Vec<Particle>,
) -> bool {
    if player.invincible > 0.0 { return false; }
    for b in bullets.iter_mut().filter(|b| b.alive && !b.is_player) {
        if b.pos.distance(player.pos) < BULLET_RADIUS + PLAYER_RADIUS {
            b.alive = false;
            if player.shield {
                player.shield = false;
                spawn_hit_particles(particles, player.pos, 14);
            } else {
                player.health -= b.damage;
                player.invincible = 1.2;
                spawn_hit_particles(particles, player.pos, 10);
                return true;
            }
        }
    }
    false
}

/// Returns true if player was hit by enemy body contact.
pub fn check_enemies_vs_player(
    enemies: &mut Vec<EnemyData>,
    player: &mut PlayerState,
    particles: &mut Vec<Particle>,
) -> bool {
    if player.invincible > 0.0 { return false; }
    for e in enemies.iter_mut().filter(|e| e.health > 0) {
        if e.pos.distance(player.pos) < PLAYER_RADIUS + ENEMY_RADIUS * e_radius_mult(e.enemy_type) {
            e.health -= 2;
            player.health -= 1;
            player.invincible = 1.5;
            spawn_hit_particles(particles, player.pos, 12);
            return true;
        }
    }
    false
}

pub fn check_powerup_pickup(powerups: &mut Vec<PowerUp>, player: &mut PlayerState) -> Option<PowerUpType> {
    for p in powerups.iter_mut().filter(|p| p.alive) {
        if p.pos.distance(player.pos) < PLAYER_RADIUS + 14.0 {
            p.alive = false;
            apply_powerup(p.kind, player);
            return Some(p.kind);
        }
    }
    None
}

fn apply_powerup(kind: PowerUpType, player: &mut PlayerState) {
    match kind {
        PowerUpType::Shield       => { player.shield = true; }
        PowerUpType::RapidFire    => { player.rapid_fire = true; player.rapid_timer = 8.0; }
        PowerUpType::DoubleCannon => { player.double_cannon = true; player.double_timer = 10.0; }
        PowerUpType::NovaBomb     => { player.ulti_energy = 100.0; }
        PowerUpType::Heal         => { player.health = (player.health + 2).min(player.max_health); }
    }
}

pub fn maybe_spawn_powerup(
    pos: SerVec2,
    powerups: &mut Vec<PowerUp>,
    rng: &mut impl rand_crate::Rng,
) {
    if rng.gen::<f32>() > 0.18 { return; }
    let kind = match (rng.gen::<f32>() * 5.0) as u32 {
        0 => PowerUpType::Shield,
        1 => PowerUpType::RapidFire,
        2 => PowerUpType::DoubleCannon,
        3 => PowerUpType::NovaBomb,
        _ => PowerUpType::Heal,
    };
    powerups.push(PowerUp { pos, kind, alive: true, lifetime: 9.0 });
}

pub fn nova_bomb(enemies: &mut Vec<EnemyData>, particles: &mut Vec<Particle>) -> u32 {
    let mut kills = 0;
    for e in enemies.iter_mut() {
        let dmg = if e.enemy_type == EnemyType::Boss { 20 } else { 999 };
        e.health = (e.health - dmg).max(-1);
        if e.health <= 0 {
            spawn_explosion(particles, e.pos, e.enemy_type);
            kills += 1;
        }
    }
    kills
}

fn e_radius_mult(kind: EnemyType) -> f32 {
    match kind { EnemyType::Tank => 1.5, EnemyType::Boss => 3.0, EnemyType::Fast => 0.7, _ => 1.0 }
}

// ── Particle helpers ──────────────────────────────────────────────────────────

pub fn spawn_hit_particles(particles: &mut Vec<Particle>, pos: SerVec2, count: u32) {
    use rand_crate::Rng;
    let mut rng = rand_crate::thread_rng();
    for _ in 0..count {
        let angle: f32 = rng.gen::<f32>() * std::f32::consts::TAU;
        let speed: f32 = rng.gen_range(40.0..130.0);
        particles.push(Particle {
            pos,
            vel: SerVec2::new(angle.cos() * speed, angle.sin() * speed),
            lifetime: rng.gen_range(0.2..0.6),
            max_life: 0.6,
            size: rng.gen_range(2.0..5.0),
            r: 1.0, g: 0.5, b: 0.2,
        });
    }
}

pub fn spawn_explosion(particles: &mut Vec<Particle>, pos: SerVec2, kind: EnemyType) {
    use rand_crate::Rng;
    let mut rng = rand_crate::thread_rng();
    let count = match kind { EnemyType::Boss => 60, EnemyType::Tank => 30, _ => 18 };
    let (r, g, b) = match kind {
        EnemyType::Fast     => (1.0f32, 0.5, 0.0),
        EnemyType::Tank     => (0.7, 0.2, 1.0),
        EnemyType::Shooter  => (0.2, 0.9, 0.9),
        EnemyType::Boss     => (1.0, 0.1, 0.1),
        _                   => (1.0, 0.6, 0.1),
    };
    for _ in 0..count {
        let angle: f32 = rng.gen::<f32>() * std::f32::consts::TAU;
        let speed: f32 = rng.gen_range(60.0..220.0);
        particles.push(Particle {
            pos,
            vel: SerVec2::new(angle.cos() * speed, angle.sin() * speed),
            lifetime: rng.gen_range(0.4..1.4),
            max_life: 1.4,
            size: rng.gen_range(3.0..9.0),
            r, g, b,
        });
    }
}

pub fn spawn_graze_particles(particles: &mut Vec<Particle>, pos: SerVec2) {
    use rand_crate::Rng;
    let mut rng = rand_crate::thread_rng();
    for _ in 0..4 {
        let angle: f32 = rng.gen::<f32>() * std::f32::consts::TAU;
        particles.push(Particle {
            pos,
            vel: SerVec2::new(angle.cos() * 50.0, angle.sin() * 50.0),
            lifetime: 0.25,
            max_life: 0.25,
            size: 3.0,
            r: 1.0, g: 0.9, b: 0.0,
        });
    }
}
