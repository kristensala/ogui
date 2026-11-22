package examples

import og "../"
import sdl "vendor:sdl3"

import "core:fmt"

WINDOW_WIDTH :: 1000
WINDOW_HEIGHT :: 1200

// TODO: idea
UI :: enum {
    Side_Bar,
    Command_Palette
}

Element :: union {
    ^og.Button,
    ^og.F_Rect
}

State :: struct {
    button_one: og.Button,
    elements: [dynamic]Element, // or maybe a map
    //ui: map[UI]Element
}

s: ^State

main :: proc() {
    s = new(State)

    og.init(
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        "OGUI: a wrapper for SDL3 to build native desktop applications"
    )
    og.use_vsync()
    og.init_font("./assets/JetBrainsMono-Regular.ttf", 30)

    //og.load_font("path to font", 20)
    og.set_background_color(og.Color{20, 250, 250, 255})

    // create ui elements
    {
        button := og.Button{
            bounds = og.F_Rect{0, 500, 100, 100},
            style = og.Element_Style{
                color = og.BLACK
            },
            on_click = on_click
        }

        append(&s.elements, &button)
    }

    // this is blocking
    og.run(on_event, on_draw, on_update)

    destroy_state()
    fmt.println("Shutdown...")
}

on_event :: proc() {
    event : sdl.Event
    for sdl.PollEvent(&event) {
        #partial switch event.type {
        case .QUIT:
            og.quit()
            break
        }
    }
}

on_update :: proc() {
    /*s, pos := og.get_mouse_state()
    fmt.println(s, pos.x, pos.y)*/

}

on_draw :: proc() {
    for &element in s.elements {
        #partial switch v in element {
        case ^og.Button:
            og.draw_button(v)
        }
    }
    og.draw_frect(0, 10, 100, 100, og.BLACK)

    og.draw_line_vertical(500, 100, 500, 2.5, og.BLACK)
    og.draw_line_horizontal(10, 50, 500, 2.5, og.BLACK)

    og.draw_text("ÄÄööää", {500, 500})
    og.draw_text("another text", {500, 550})
}

on_click :: proc() {
    fmt.println("clicked")
}

destroy_state :: proc() {
    delete(s.elements)
    free(s)
}

