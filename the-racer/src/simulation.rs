use rand_crate::Rng;
use crate::types::*;

pub fn simulate_race(
    team: &mut Team,
    opponents: &mut Vec<OpponentTeam>,
    rs: &RaceWeekendState,
    circuits: &[Circuit],
    rng: &mut impl Rng,
) -> RaceResult {
    let circuit = &circuits[team.current_round];
    let wet = rs.wet;

    let p1 = team.driver1.race_performance(wet, rng);
    let p2 = team.driver2.race_performance(wet, rng);
    let car_perf = team.car.performance() as f32;

    // Aero balance bonus: high_speed circuits reward high aero cars
    let aero_bonus = if circuit.high_speed {
        (team.car.aero_balance as f32 - 50.0) * 0.05
    } else {
        (50.0 - team.car.aero_balance as f32) * 0.03
    };

    // Tire strategy
    let tire1_bonus = wet_or_dry_tire_bonus(rs.strategy1, wet);
    let tire2_bonus = wet_or_dry_tire_bonus(rs.strategy2, wet);

    // Pit timing (only for pit-stop series)
    let pit1_timing = pit_timing_delta(rs.pit_lap1, circuit, &team.series);
    let pit2_timing = pit_timing_delta(rs.pit_lap2, circuit, &team.series);

    // Tire degradation factor
    let deg_factor1 = 1.0 - (rs.strategy1.deg_rate() * circuit.tire_stress / 99.0);
    let deg_factor2 = 1.0 - (rs.strategy2.deg_rate() * circuit.tire_stress / 99.0);
    let tire_mgmt_bonus = team.car.tire_deg as f32 * 0.04;

    let total1 = (p1 + car_perf * 0.5 + tire1_bonus + pit1_timing + aero_bonus
        + deg_factor1 * 5.0 + tire_mgmt_bonus).clamp(0.0, 130.0);
    let total2 = (p2 + car_perf * 0.5 + tire2_bonus + pit2_timing + aero_bonus
        + deg_factor2 * 5.0 + tire_mgmt_bonus).clamp(0.0, 130.0);

    // DNF
    let dnf_chance = (100 - team.car.reliability) as f32 / 200.0;
    let dnf1 = rng.gen::<f32>() < dnf_chance;
    let dnf2 = rng.gen::<f32>() < dnf_chance;
    let dnf_driver = if dnf1 { Some(1) } else if dnf2 { Some(2) } else { None };

    // Build grid
    let mut grid: Vec<(String, f32)> = Vec::new();
    grid.push((team.driver1.name.clone(), if dnf1 { -99.0 } else { total1 }));
    grid.push((team.driver2.name.clone(), if dnf2 { -99.0 } else { total2 }));
    for opp in opponents.iter() {
        let b1 = opp.strength as f32 + rng.gen_range(-14.0..14.0);
        let b2 = opp.strength as f32 * 0.92 + rng.gen_range(-14.0..14.0);
        grid.push((opp.name.clone(), b1));
        grid.push((format!("{} #2", opp.name), b2));
    }
    grid.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());

    let pos1 = grid.iter().position(|(n, _)| n == &team.driver1.name).unwrap_or(20) as u8 + 1;
    let pos2 = grid.iter().position(|(n, _)| n == &team.driver2.name).unwrap_or(20) as u8 + 1;
    let pts1 = if dnf1 { 0 } else { points_for_pos(pos1) };
    let pts2 = if dnf2 { 0 } else { points_for_pos(pos2) };
    let fl = pos1 == 1 || pos2 == 1;

    // Update opponents
    for opp in opponents.iter_mut() {
        opp.points += rng.gen_range(0..22u32);
    }

    // Budget
    let prize = (pts1 as u32 + pts2 as u32) * 220 + 2000;
    team.budget = team.budget.saturating_add(prize).saturating_sub(team.weekly_costs());

    // R&D tick
    for proj in team.rd_projects.iter_mut() {
        if proj.duration > 0 { proj.duration -= 1; }
    }
    let completed: Vec<_> = team.rd_projects.iter()
        .filter(|p| p.duration == 0)
        .map(|p| (p.target.clone(), p.boost))
        .collect();
    for (target, boost) in completed {
        match target.as_str() {
            "chassis"      => team.car.chassis      = (team.car.chassis + boost).min(99),
            "engine"       => team.car.engine       = (team.car.engine + boost).min(99),
            "reliability"  => team.car.reliability  = (team.car.reliability + boost).min(99),
            "tire_deg"     => team.car.tire_deg     = (team.car.tire_deg + boost).min(99),
            "pit_speed"    => team.car.pit_speed    = (team.car.pit_speed + boost).min(99),
            "aero_balance" => team.car.aero_balance = (team.car.aero_balance as i32 + boost as i32).clamp(0, 100) as u8,
            _ => {}
        }
    }
    team.rd_projects.retain(|p| p.duration > 0);

    // Morale
    let morale_delta1: i8 = if pos1 <= 3 { 15 } else if pos1 <= 8 { 5 } else { -8 };
    let morale_delta2: i8 = if pos2 <= 3 { 15 } else if pos2 <= 8 { 5 } else { -8 };
    team.driver1.morale = (team.driver1.morale + morale_delta1).clamp(-100, 100);
    team.driver2.morale = (team.driver2.morale + morale_delta2).clamp(-100, 100);

    // Driver stats
    team.driver1.races += 1;
    team.driver2.races += 1;
    if pos1 == 1 { team.driver1.career_wins += 1; }
    if pos2 == 1 { team.driver2.career_wins += 1; }
    // Experience grows slowly
    if team.driver1.experience < 99 { team.driver1.experience += 1; }
    if team.driver2.experience < 99 { team.driver2.experience += 1; }

    let mut pit_log = Vec::new();
    if team.series.pit_stops_required() {
        pit_log.push(format!("Lap {:2} — {} pits → {}", rs.pit_lap1, team.driver1.name, rs.strategy1.name()));
        pit_log.push(format!("Lap {:2} — {} pits → {}", rs.pit_lap2, team.driver2.name, rs.strategy2.name()));
        if wet { pit_log.push("Wet conditions — intermediate tires critical".into()); }
    }

    team.standings_points += pts1 as u32 + pts2 as u32;
    team.current_round += 1;

    RaceResult {
        round: team.current_round,
        circuit: circuit.name.clone(),
        driver1_pos: pos1, driver2_pos: pos2,
        driver1_points: pts1, driver2_points: pts2,
        fastest_lap: fl, dnf_driver, wet_race: wet,
        pit_stops: pit_log,
    }
}

fn wet_or_dry_tire_bonus(compound: TireCompound, wet: bool) -> f32 {
    if wet {
        if matches!(compound, TireCompound::Inter | TireCompound::Wet) { 10.0 } else { -16.0 }
    } else {
        compound.pace_bonus()
    }
}

fn pit_timing_delta(pit_lap: u16, circuit: &Circuit, series: &Series) -> f32 {
    if !series.pit_stops_required() { return 0.0; }
    let ideal = circuit.laps / 2;
    let delta = (pit_lap as i16 - ideal as i16).unsigned_abs() as f32;
    -(delta * 0.3)
}
