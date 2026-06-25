#![allow(dead_code)]
#![allow(unused_parens)]
extern crate rand as rand_crate;

use macroquad::prelude::*;

mod types;
mod data;
mod simulation;
mod ui;
mod screens;
mod save;

use types::*;
use data::circuits_for;
use ui::bottom_nav;
use screens::*;

#[macroquad::main("The Racer")]
async fn main() {
    let mut gs = AppState::new();
    let mut circuits: Vec<Circuit> = Vec::new();

    loop {
        // Update message timer
        if let Some((_, ref mut t)) = gs.msg { *t -= get_frame_time(); }
        if gs.msg.as_ref().map(|(_, t)| *t <= 0.0).unwrap_or(false) { gs.msg = None; }

        // Rebuild circuits when series changes
        if let Some(ref team) = gs.team {
            if circuits.is_empty() || circuits.len() != team.series.rounds() {
                circuits = circuits_for(&team.series);
            }
        }

        match gs.screen.clone() {
            Screen::MainMenu    => draw_main_menu(&mut gs),
            Screen::SeriesSelect => draw_series_select(&mut gs),
            Screen::TeamSetup   => draw_team_setup(&mut gs),
            Screen::ContractMarket => draw_contract_market(&mut gs),
            Screen::Dashboard   => {
                let circs = circuits.clone();
                let go_race = bottom_nav(&mut gs, &circs);
                if gs.screen != Screen::ContractMarket {
                    match gs.tab {
                        0 => draw_dashboard(&mut gs, &circs),
                        1 => draw_roster(&mut gs),
                        2 => draw_car_dev(&mut gs),
                        3 => draw_standings(&mut gs, &circs),
                        _ => draw_dashboard(&mut gs, &circs),
                    }
                }
                if go_race {
                    gs.screen = Screen::RaceWeekend;
                    gs.race_state = RaceWeekendState::default();
                }
            }
            Screen::Roster      => { let c = circuits.clone(); bottom_nav(&mut gs, &c); draw_roster(&mut gs); }
            Screen::CarDev      => { let c = circuits.clone(); bottom_nav(&mut gs, &c); draw_car_dev(&mut gs); }
            Screen::Standings   => { let c = circuits.clone(); bottom_nav(&mut gs, &c); draw_standings(&mut gs, &c); }
            Screen::RaceWeekend    => { let c = circuits.clone(); draw_race_weekend(&mut gs, &c); }
            Screen::RaceSimulation => { let c = circuits.clone(); draw_race_simulation(&mut gs, &c); }
            Screen::Results        => { let c = circuits.clone(); draw_results(&mut gs, &c); }
        }

        next_frame().await;
    }
}
