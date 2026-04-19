package cosmonaut

import "core:fmt"
import "core:math"
import "core:strings"
import rl "vendor:raylib"

draw_topbar :: proc(gs: ^GameState) {
    a := &gs.agency
    rl.DrawRectangle(0, 0, SCREEN_W, 44, rl.Color{5, 8, 18, 245})
    rl.DrawLine(0, 44, SCREEN_W, 44, COL_BORDER)

    name_cs := strings.clone_to_cstring(a.name)
    defer delete(name_cs)
    rl.DrawText(name_cs, 14, 12, 20, COL_ACCENT)

    date_str := fmt.tprintf("%s %d", month_name(a.month), a.year)
    rl.DrawText(tprint("%s %d", month_name(a.month), a.year), SCREEN_W/2 - 40, 12, 18, COL_DIM)

    budget_str := tprint("$%dM", a.budget)
    bw := rl.MeasureText(budget_str, 18)
    bcol := a.budget > 50 ? COL_GREEN : COL_RED
    rl.DrawText(budget_str, SCREEN_W - bw - 200, 13, 18, bcol)

    rl.DrawText(tprint("* %d", a.prestige),    SCREEN_W - 150, 13, 18, COL_GOLD)
    rl.DrawText(tprint("S %d", a.science_pts), SCREEN_W -  65, 13, 18, COL_CYAN)

    _ = date_str
}

draw_bottom_nav :: proc(gs: ^GameState) {
    by := i32(SCREEN_H - 42)
    rl.DrawRectangle(0, by, SCREEN_W, 42, rl.Color{5, 8, 18, 245})
    rl.DrawLine(0, by, SCREEN_W, by, COL_BORDER)

    tw := SCREEN_W / i32(len(nav_tabs))
    for i in 0..<len(nav_tabs) {
        tab := nav_tabs[i]
        tx := i32(i) * tw
        active := gs.screen == tab.screen
        col := tab.col
        if active {
            rl.DrawRectangle(tx, by, tw, 42, rl.Color{col.r/6, col.g/6, col.b/6, 200})
            rl.DrawLine(tx, by, tx+tw, by, col)
        }
        lw := rl.MeasureText(tab.label, 14)
        lx := tx + (tw - lw) / 2
        tcol := active ? col : COL_DIM
        rl.DrawText(tab.label, lx, by+14, 14, tcol)

        mx := i32(rl.GetMouseX())
        my := i32(rl.GetMouseY())
        if mx >= tx && mx < tx+tw && my >= by && my < by+42 && rl.IsMouseButtonPressed(.LEFT) {
            gs.screen = tab.screen
            gs.tab = 0
        }
    }
}

draw_notification :: proc(gs: ^GameState) {
    if gs.notif_timer <= 0 { return }
    alpha := u8(math.clamp(gs.notif_timer / 0.5, f32(0), f32(1)) * 220)
    text := string(gs.notification[:gs.notif_len])
    cs := strings.clone_to_cstring(text)
    defer delete(cs)
    tw := rl.MeasureText(cs, 16)
    nx := SCREEN_W/2 - tw/2 - 16
    rl.DrawRectangle(nx, SCREEN_H-72, tw+32, 28, rl.Color{10, 20, 40, alpha})
    rl.DrawRectangleLines(nx, SCREEN_H-72, tw+32, 28, rl.Color{COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b, alpha})
    rl.DrawText(cs, nx+16, SCREEN_H-64, 16, rl.Color{COL_TEXT.r, COL_TEXT.g, COL_TEXT.b, alpha})
}
