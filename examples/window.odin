package examples

import og "../"

import "core:fmt"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 1200

State :: struct {
    button_one: og.Button
}
s: ^State

main :: proc() {
    s = new(State)
    s.button_one = og.Button{
        bounds = og.F_Rect{0, 500, 100, 100},
        style = og.Element_Style{
            color = og.Color{0,0,0,255}
        },
        on_click = on_click
    }

    og.init(
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        "OGUI: a wrapper for SDL3 to build native desktop applications",
        on_draw,
        on_update
    )
    og.set_background_color(og.Color{20, 250, 250, 255})

    // this is blocking
    og.run()

    fmt.println("Shutdown...")
    og.shutdown()
}

on_draw :: proc() {
    og.draw_frect(0, 10, 100, 100, og.Color{0, 0, 0, 255})
    og.button(&s.button_one)
}

on_click :: proc() {
    fmt.println("clicked")
}

on_update :: proc() {
    /*s, pos := og.get_mouse_state()
    fmt.println(s, pos.x, pos.y)*/

}
