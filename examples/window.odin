package examples

import og "../"

import "core:fmt"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 1200

main :: proc() {
    og.init(
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        "title",
        on_draw,
        on_update
    )
    og.set_background_color(og.Color{20, 250, 250, 255})

    // main loop
    for !og.window_should_close() {}

    fmt.println("Shutdown...")
    og.shutdown()
}

on_draw :: proc() {
    og.draw_frect(0, 10, 100, 100, og.Color{0, 0, 0, 255})
}

on_update :: proc() {

}
