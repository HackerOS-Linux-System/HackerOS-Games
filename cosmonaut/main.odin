package cosmonaut

import "core:math"
import rl "vendor:raylib"

main :: proc() {
    rl.InitWindow(SCREEN_W, SCREEN_H, "Cosmonaut — Space Agency Management")
    rl.SetTargetFPS(TARGET_FPS)
    defer rl.CloseWindow()

    gs := GameState{screen = .MainMenu, selected = -1, selected2 = -1}
    default_bodies(&gs)
    init_stars()

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        gs.star_anim += dt * 0.8
        if gs.notif_timer > 0 { gs.notif_timer -= dt }

        rl.BeginDrawing()
        rl.ClearBackground(COL_BG)

        draw_stars(gs.star_anim)

        #partial switch gs.screen {
        case .MainMenu:
            draw_main_menu(&gs)
        case .NewGame:
            draw_new_game(&gs)
        case .Dashboard:
            draw_topbar(&gs)
            draw_bottom_nav(&gs)
            draw_dashboard(&gs)
        case .Rockets:
            draw_topbar(&gs)
            draw_bottom_nav(&gs)
            draw_rockets(&gs)
        case .RocketDesign:
            draw_topbar(&gs)
            draw_rocket_design(&gs)
        case .Astronauts:
            draw_topbar(&gs)
            draw_bottom_nav(&gs)
            draw_astronauts(&gs)
        case .Missions:
            draw_topbar(&gs)
            draw_bottom_nav(&gs)
            draw_missions(&gs)
        case .MissionPlan:
            draw_topbar(&gs)
            draw_mission_plan(&gs)
        case .MissionLog:
            draw_topbar(&gs)
            draw_mission_log(&gs)
        case .Research:
            draw_topbar(&gs)
            draw_bottom_nav(&gs)
            draw_research(&gs)
        case .StarMap:
            draw_topbar(&gs)
            draw_bottom_nav(&gs)
            draw_star_map(&gs)
        case .Facilities:
            draw_topbar(&gs)
            draw_bottom_nav(&gs)
            draw_facilities(&gs)
        }

        draw_notification(&gs)

        if rl.IsKeyPressed(.ESCAPE) {
            #partial switch gs.screen {
            case .MainMenu, .Dashboard: // stay
            case .NewGame, .RocketDesign, .MissionPlan, .MissionLog:
                gs.screen = .Dashboard
                gs.selected = -1; gs.selected2 = -1; gs.input_len = 0
            case:
                gs.screen = .Dashboard
            }
        }

        rl.EndDrawing()
    }
}
