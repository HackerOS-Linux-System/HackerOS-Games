use macroquad::prelude::*;
use crate::types::*;

pub fn sw() -> f32 { screen_width() }
pub fn sh() -> f32 { screen_height() }

pub fn panel(x: f32, y: f32, w: f32, h: f32, col: Color) {
    draw_rectangle(x, y, w, h, col);
    draw_rectangle_lines(x, y, w, h, 1.0, C_BORDER);
}

pub fn label(text: &str, x: f32, y: f32, size: f32, col: Color) {
    draw_text(text, x, y, size, col);
}

pub fn button(text: &str, x: f32, y: f32, w: f32, h: f32, col: Color) -> bool {
    let (mx, my) = mouse_position();
    let hover = mx >= x && mx <= x + w && my >= y && my <= y + h;
    let bg = Color::new(col.r, col.g, col.b, if hover { 0.28 } else { 0.10 });
    draw_rectangle(x, y, w, h, bg);
    draw_rectangle_lines(x, y, w, h, 1.5, if hover { col } else { C_BORDER });
    let tw = measure_text(text, None, 18, 1.0).width;
    draw_text(text, x + (w - tw) / 2.0, y + h / 2.0 + 6.0, 18.0, if hover { col } else { C_TEXT });
    hover && is_mouse_button_pressed(MouseButton::Left)
}

pub fn icon_button(text: &str, x: f32, y: f32, w: f32, h: f32, col: Color, enabled: bool) -> bool {
    if !enabled {
        draw_rectangle(x, y, w, h, Color::new(0.1, 0.1, 0.1, 0.5));
        draw_rectangle_lines(x, y, w, h, 1.0, C_BORDER);
        let tw = measure_text(text, None, 15, 1.0).width;
        draw_text(text, x + (w - tw) / 2.0, y + h / 2.0 + 5.0, 15.0, C_TEXT_DIM);
        return false;
    }
    button(text, x, y, w, h, col)
}

pub fn stat_bar(label_txt: &str, val: u8, x: f32, y: f32, w: f32, col: Color) {
    draw_text(label_txt, x, y + 12.0, 13.0, C_TEXT_DIM);
    let bar_x = x + 100.0;
    let bar_w = w - 110.0;
    draw_rectangle(bar_x, y, bar_w, 14.0, C_PANEL2);
    draw_rectangle(bar_x, y, bar_w * val as f32 / 99.0, 14.0, col);
    draw_rectangle_lines(bar_x, y, bar_w, 14.0, 1.0, C_BORDER);
    draw_text(&format!("{}", val), bar_x + bar_w + 6.0, y + 12.0, 14.0, C_TEXT);
}

pub fn position_badge(pos: u8, x: f32, y: f32) {
    let col = match pos { 1 => C_GOLD, 2 => C_SILVER, 3 => C_BRONZE, _ => C_TEXT_DIM };
    draw_rectangle(x, y, 36.0, 24.0, Color::new(col.r, col.g, col.b, 0.15));
    draw_rectangle_lines(x, y, 36.0, 24.0, 1.0, col);
    let txt = format!("P{}", pos);
    let tw = measure_text(&txt, None, 16, 1.0).width;
    draw_text(&txt, x + (36.0 - tw) / 2.0, y + 17.0, 16.0, col);
}

pub fn tire_badge(compound: TireCompound, x: f32, y: f32) {
    let col = compound.color();
    draw_rectangle(x, y, 52.0, 20.0, Color::new(col.r, col.g, col.b, 0.2));
    draw_rectangle_lines(x, y, 52.0, 20.0, 1.0, col);
    let tw = measure_text(compound.name(), None, 13, 1.0).width;
    draw_text(compound.name(), x + (52.0 - tw) / 2.0, y + 14.0, 13.0, col);
}

pub fn section_header(title: &str, y: f32) {
    draw_line(20.0, y, sw() - 20.0, y, 1.0, C_BORDER);
    let tw = measure_text(title, None, 18, 1.0).width;
    draw_rectangle(sw() / 2.0 - tw / 2.0 - 10.0, y - 12.0, tw + 20.0, 22.0, C_BG);
    draw_text(title, sw() / 2.0 - tw / 2.0, y + 6.0, 18.0, C_TEXT_DIM);
}

pub fn topbar(team: &Team, circuits: &[Circuit]) {
    draw_rectangle(0.0, 0.0, sw(), 46.0, Color::new(0.05, 0.05, 0.09, 0.98));
    draw_line(0.0, 46.0, sw(), 46.0, 1.0, C_BORDER);
    draw_text(&team.name, 16.0, 30.0, 22.0, C_ACCENT);
    let sc = team.series.color();
    draw_text(team.series.short(), 16.0 + measure_text(&team.name, None, 22, 1.0).width + 10.0, 30.0, 18.0, sc);

    let budget_str = format!("${:.1}M", team.budget as f32 / 1000.0);
    let pts_str = format!("{} PTS", team.standings_points);
    let round_str = if !circuits.is_empty() && team.current_round < circuits.len() {
        format!("R{}/{} — {}", team.current_round + 1, circuits.len(), circuits[team.current_round].name)
    } else if circuits.is_empty() { String::new() }
    else { "Season Complete".into() };

    let bw = measure_text(&budget_str, None, 18, 1.0).width;
    draw_text(&budget_str, sw() - bw - 220.0, 30.0, 18.0, C_GREEN);
    draw_text(&pts_str, sw() - 150.0, 30.0, 18.0, C_GOLD);
    if !round_str.is_empty() {
        draw_text(&round_str, sw() / 2.0 - measure_text(&round_str, None, 16, 1.0).width / 2.0, 30.0, 16.0, C_TEXT_DIM);
    }
}

pub fn bottom_nav(gs: &mut AppState, circuits: &[Circuit]) -> bool {
    let bh = 44.0;
    let by = sh() - bh;
    draw_rectangle(0.0, by, sw(), bh, Color::new(0.05, 0.05, 0.09, 0.98));
    draw_line(0.0, by, sw(), by, 1.0, C_BORDER);

    let tabs = ["DASHBOARD", "ROSTER", "CAR DEV", "STANDINGS", "CONTRACTS", "NEXT RACE"];
    let tw = sw() / tabs.len() as f32;
    let mut go_race = false;

    for (i, tab) in tabs.iter().enumerate() {
        let tx = i as f32 * tw;
        let active = gs.tab == i;
        if active {
            draw_rectangle(tx, by, tw, bh, Color::new(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 0.12));
            draw_line(tx, by, tx + tw, by, 2.0, C_ACCENT);
        }
        let lw = measure_text(tab, None, 14, 1.0).width;
        let col = if active { C_ACCENT } else if i == 5 { C_GREEN } else { C_TEXT_DIM };
        draw_text(tab, tx + (tw - lw) / 2.0, by + 28.0, 14.0, col);

        let (mx, my) = mouse_position();
        let hover = mx >= tx && mx <= tx + tw && my >= by && my <= by + bh;
        if hover && is_mouse_button_pressed(MouseButton::Left) {
            if i == 5 {
                if let Some(ref t) = gs.team {
                    if t.current_round < circuits.len() { go_race = true; }
                }
            } else if i == 4 {
                gs.screen = Screen::ContractMarket;
            } else {
                gs.tab = i;
            }
        }
    }
    go_race
}
