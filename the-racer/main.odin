package main

import "core:fmt"
import "core:os"
import "core:math"
import "core:strings"
import "core:bufio"
import "core:time"
import "core:sys/posix"
import "core:sys/unix"

Key :: enum {
    None,
    Left,
    Right,
    Quit,
}

TrackConfig :: struct {
    center_amp:     f32,
    center_freq:    f32,
    width_amp:      f32,
    width_freq:     f32,
    base_width:     f32,
    speed:          f32,
    handling:       f32,
    name:           string,
}

Series :: enum {
    F1,
    Formula_E,
    WEC,
}

Game :: struct {
    series:     Series,
    config:     TrackConfig,
    pos_x:      f32,
    road_offset: f32,
    time:       f32,
    score:      i64,
    width:      i32,
    height:     i32,
    running:    bool,
}

CLEAR_SCREEN :: "\x1b[2J\x1b[H\x1b[?25l"
SHOW_CURSOR :: "\x1b[?25h"

configs: [Series]TrackConfig = {
    .F1 = {center_amp = 25, center_freq = 0.015, width_amp = 3, width_freq = 0.03, base_width = 20, speed = 3.0, handling = 4.0, name = "F1"},
    .Formula_E = {center_amp = 20, center_freq = 0.012, width_amp = 4, width_freq = 0.025, base_width = 22, speed = 2.8, handling = 3.5, name = "Formula E"},
    .WEC = {center_amp = 35, center_freq = 0.01, width_amp = 5, width_freq = 0.02, base_width = 25, speed = 2.2, handling = 2.5, name = "WEC"},
}

enable_raw_mode :: proc(orig: ^posix.termios) -> bool {
    term: posix.termios
    if posix.tcgetattr(0, &term) != 0 {
        return false
    }
    orig^ = term

    term.c_iflag &= ~u32(posix.IGNBRK | posix.BRKINT | posix.PARMRK | posix.ISTRIP | posix.INLCR | posix.IGNCR | posix.ICRNL | posix.IXON)
    term.c_oflag &= ~u32(posix.OPOST)
    term.c_lflag &= ~u32(posix.ECHO | posix.ECHONL | posix.ICANON | posix.ISIG | posix.IEXTEN)
    term.c_cflag &= ~u32(posix.CSIZE)
    term.c_cflag |= u32(posix.CS8)
    term.c_cc[posix.VMIN]  = 0
    term.c_cc[posix.VTIME] = 0

    return posix.tcsetattr(0, posix.TCSANOW, &term) == 0
}

disable_raw_mode :: proc(orig: ^posix.termios) {
    posix.tcsetattr(0, posix.TCSADRAIN, orig)
}

get_term_size :: proc() -> (height, width: i32) {
    ws: unix.winsize
    err := unix.ioctl(1, unix.TIOCGWINSZ, &ws)
    if err == 0 {
        height = i32(ws.ws_row) - 3
        width  = i32(ws.ws_col)
        if height < 15 do height = 15
            if width  < 60 do width  = 60
                return
    }
    return 20, 80
}

get_key :: proc() -> Key {
    buf: [4]u8
    n, _ := os.read(os.stdin, buf[:])
    if n <= 0 do return .None

        ch := buf[0]
        switch ch {
            case 'a', 'A': return .Left
            case 'd', 'D': return .Right
            case 'q', 'Q': return .Quit
            case 27: // ESC
                if n >= 3 && buf[1] == '[' {
                    switch buf[2] {
                        case 'D': return .Left
                        case 'C': return .Right
                    }
                }
        }
        return .None
}

compute_road :: proc(g: ^Game, row: i32) -> (left_x, right_x: i32) {
    t := g.road_offset * g.config.center_freq + f32(row) * 0.15
    center_curve := g.config.center_amp * math.sin_f32(t)
    t = g.road_offset * g.config.width_freq + f32(row) * 0.12
    width_curve := g.config.base_width + g.config.width_amp * math.sin_f32(t)
    center_x := f32(g.width) / 2 + center_curve
    left_x = i32(center_x - width_curve / 2)
    right_x = i32(center_x + width_curve / 2)
    return
}

draw :: proc(g: ^Game) {
    fmt.print(CLEAR_SCREEN)

    // Status
    fmt.printf("=== The Racer - %s ===\n", g.config.name)
    fmt.printf("Speed: %.1f | Time: %.1fs | Score: %d | A/D / <- -> : sterowanie | Q: wyjście\n\n", g.config.speed, g.time, g.score)

    // Road
    for row in 0..<g.height {
        left_x, right_x := compute_road(g, row)

        if row == g.height - 1 {
            // Car row
            car_pos := i32(g.pos_x)
            fmt.printf("%*s", int(left_x), strings.repeat("#", int(left_x)))
            if car_pos >= left_x && car_pos < right_x {
                fmt.printf("%*s@", int(car_pos - left_x), strings.repeat(" ", int(car_pos - left_x)))
                fmt.printf("%*s", int(right_x - car_pos - 1), strings.repeat(" ", int(right_x - car_pos - 1)))
            } else {
                fmt.printf("%*s", int(right_x - left_x), strings.repeat(" ", int(right_x - left_x)))
            }
            fmt.printf("%*s\n", int(g.width - right_x), strings.repeat("#", int(g.width - right_x)))
        } else {
            fmt.printf("%*s%*s%*s\n", int(left_x), strings.repeat("#", int(left_x)), int(right_x - left_x), strings.repeat(" ", int(right_x - left_x)), int(g.width - right_x), strings.repeat("#", int(g.width - right_x)))
        }
    }
}

update :: proc(g: ^Game, dt: f32, key: Key) {
    // Input
    #partial switch key {
                        case .Left:  g.pos_x -= g.config.handling * dt * 200
                        case .Right: g.pos_x += g.config.handling * dt * 200
    }

    // Update
    g.road_offset += g.config.speed * dt * 60
    g.time += dt
    g.score = i64(g.road_offset)

    // Clamp position
    g.pos_x = math.clamp(g.pos_x, 0, f32(g.width - 1))

    // Collision check
    left_b, right_b := compute_road(g, g.height - 1)
    if g.pos_x < f32(left_b) || g.pos_x >= f32(right_b) {
        g.running = false
    }
}

main :: proc() {
    fmt.println("The Racer - Witaj!")
    fmt.println()
    fmt.println("1. F1")
    fmt.println("2. Formula E")
    fmt.println("3. WEC")
    fmt.println()
    fmt.print("Wybierz serie (1-3): ")

    r: bufio.Reader
    bufio.reader_init(&r, os.stream_from_handle(os.stdin))
    line, _ := bufio.reader_read_string(&r, '\n')
    trimmed := strings.trim_space(line)

    series: Series = .F1
    switch {
        case strings.has_prefix(trimmed, "1"): series = .F1
        case strings.has_prefix(trimmed, "2"): series = .Formula_E
        case strings.has_prefix(trimmed, "3"): series = .WEC
    }

    h, w := get_term_size()

    orig: posix.termios
    if !enable_raw_mode(&orig) {
        fmt.eprintln("Błąd ustawienia raw mode!")
        return
    }
    defer disable_raw_mode(&orig)
    defer fmt.print(SHOW_CURSOR)

    g: Game
    g.series = series
    g.config = configs[series]
    g.width = w
    g.height = h
    g.pos_x = f32(w) / 2
    g.road_offset = 0
    g.running = true

    prev_time := time.now()
    for g.running {
        curr_time := time.now()
        dt := time.duration_seconds(time.diff(curr_time, prev_time))
        prev_time = curr_time

        key := get_key()
        if key == .Quit {
            g.running = false
            continue
        }

        update(&g, f32(dt), key)
        draw(&g)

        // ~60 FPS
        time.sleep(16 * time.Millisecond)
    }

    fmt.print(CLEAR_SCREEN)
    fmt.print(SHOW_CURSOR)
    fmt.printf("\nKONIEC! Twój wynik: %d\nNaciśnij Enter aby wyjść...", g.score)
    ignore: [1]u8
    os.read(os.stdin, ignore[:])
}
