package cosmonaut

import rl "vendor:raylib"

SCREEN_W  :: i32(1280)
SCREEN_H  :: i32(800)
TARGET_FPS :: i32(60)

COL_BG     :: rl.Color{4,   6,  14, 255}
COL_PANEL  :: rl.Color{10,  14,  26, 255}
COL_PANEL2 :: rl.Color{16,  22,  40, 255}
COL_BORDER :: rl.Color{28,  38,  62, 255}
COL_TEXT   :: rl.Color{210, 220, 240, 255}
COL_DIM    :: rl.Color{90,  105, 130, 255}
COL_ACCENT :: rl.Color{50,  150, 255, 255}
COL_GREEN  :: rl.Color{40,  220, 100, 255}
COL_RED    :: rl.Color{255,  60,  60, 255}
COL_GOLD   :: rl.Color{255, 200,  30, 255}
COL_ORANGE :: rl.Color{255, 130,  30, 255}
COL_PURPLE :: rl.Color{160,  80, 220, 255}
COL_CYAN   :: rl.Color{ 30, 220, 220, 255}
COL_WHITE  :: rl.Color{255, 255, 255, 255}

nav_tabs := []NavTab{
    {"CONTROL", .Dashboard,  COL_ACCENT},
    {"ROCKETS",  .Rockets,   COL_ORANGE},
    {"CREW",     .Astronauts,COL_GREEN},
    {"MISSIONS", .Missions,  COL_GOLD},
    {"RESEARCH", .Research,  COL_PURPLE},
    {"STAR MAP", .StarMap,   COL_CYAN},
    {"BASE",     .Facilities,COL_DIM},
}
