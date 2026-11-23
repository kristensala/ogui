package examples

import og "../"
import sdl "vendor:sdl3"
import "core:strings"

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

    input_field: og.Input_Field,

    font_data: ^og.Font_Data,

    fonts: map[f32]^og.Font_Data
}

s: ^State

main :: proc() {
    s = new(State)

    og.init(
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        "OGUI: a wrapper for SDL3 to build native desktop applications",
        sdl.WINDOW_RESIZABLE
    )
    og.start_text_input()
    og.use_vsync()

    if !og.init_font() {
        fmt.eprintln("Failed to init font")
        return
    }
    defer og.deinit_font()

    s.fonts[15] = og.load_font("./assets/JetBrainsMono-Regular.ttf", 15)
    s.fonts[20] = og.load_font("./assets/JetBrainsMono-Regular.ttf", 20)
    s.fonts[30] = og.load_font("./assets/JetBrainsMono-Regular.ttf", 30)

    og.set_background_color(og.SOLID_WHITE)

    // create ui elements
    {
        button := og.Button{
            bounds = og.F_Rect{0, 500, 200, 50},
            label = "Label",
            style = og.Element_Style{
                color = og.RED,
                text_color = og.BLACK
            },
            on_click = on_click
        }

        append(&s.elements, &button)

        s.input_field = og.Input_Field{
            bounds = og.F_Rect{10, 600, 100, 20},
            placeholder = "Placeholder",
            font_data = s.fonts[15],
        }
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
        case .TEXT_INPUT:
            input := strings.clone_from_cstring(event.text.text)
            defer delete(input)

            builder := strings.builder_make()
            s_input := strings.clone_from_cstring(s.input_field.input)
            defer delete(s_input)

            strings.write_string(&builder, s_input)
            strings.write_string(&builder, input)

            s.input_field.input = strings.clone_to_cstring(strings.to_string(builder))
            strings.builder_destroy(&builder)
            break
        case .KEY_DOWN:
            keycode := event.key.scancode
            if keycode == .BACKSPACE {
                // ::handle input field on backspace::
                if len(s.input_field.input) > 0 {
                    f := strings.clone_from_cstring(s.input_field.input)
                    defer delete(f)

                    f = f[:len(f)-1]
                    s.input_field.input = strings.clone_to_cstring(f)
                }
            }
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
            og.draw_button(v, s.fonts[15])
        }
    }
    og.draw_frect(0, 10, 100, 100, og.BLACK)

    og.draw_line_vertical(500, 100, 500, 2.5, og.BLACK)
    og.draw_line_horizontal(10, 50, 500, 2.5, og.BLACK)

    og.draw_text(s.fonts[20].text_buffer, "ÄÄööää", {500, 500})
    og.draw_text(s.fonts[30].text_buffer, "another text", {500, 550})
    og.draw_text(s.fonts[30].text_buffer, "Another line of text", {500, 580})

    og.draw_frect_rounded(200, 200, 100, 50, 10, og.BLACK)

    og.draw_frect_lines(300, 300, 50, 50, 2, og.BLACK)

    og.draw_input_field(&s.input_field)
}

on_click :: proc() {
    fmt.println("clicked")
}

destroy_state :: proc() {
    delete(s.elements)

    for _, value in s.fonts {
        og.destroy_text(value.text_buffer)
        og.close_font(value.font)
    }

    if s.input_field.input != nil {
        delete(s.input_field.input)
    }

    free(s)
}

