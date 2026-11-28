package examples

import og "../"
import sdl "vendor:sdl3"
import ttf "vendor:sdl3/ttf"
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
    ^sdl.FRect
}

Panel :: struct {
    texture: ^sdl.Texture,
    bounds: sdl.FRect,
}

Gui_Elements :: struct {
    button_one: og.Button,
    input_field: og.Input_Field,
    command_palette: og.Modal,

    elements: [dynamic]Element, // or maybe a map

    panel: Panel
}

Viewport :: enum {
    Main,
    Settings
}

State :: struct {
    active_viewport: Viewport,

    font_data: ^og.Font_Data,
    fonts: map[f32]^og.Font_Data,
    gui: Gui_Elements
}

s: ^State

main :: proc() {
    s = new(State)
    s.active_viewport = .Main

    ok := og.init(
        WINDOW_WIDTH,
        WINDOW_HEIGHT,
        "OGUI: a wrapper for SDL3 to build native desktop applications",
        sdl.WINDOW_RESIZABLE)

    ensure(ok)

    sdl.SetRenderDrawBlendMode(og.renderer(), sdl.BLENDMODE_BLEND);
    og.set_background_color(og.SOLID_WHITE)

    ok = sdl.StartTextInput(og.window())
    ensure(ok)

    og.use_vsync()

    if !og.init_text_engine() {
        fmt.eprintln("Failed to init font")
        return
    }
    defer og.destroy_text_engine()

    s.fonts[15] = og.load_font("./assets/JetBrainsMono-Regular.ttf", 15)
    s.fonts[20] = og.load_font("./assets/JetBrainsMono-Regular.ttf", 20)
    s.fonts[30] = og.load_font("./assets/JetBrainsMono-Regular.ttf", 30)

    register_gui()

    // this is blocking
    og.run(on_event, on_draw, on_update)

    destroy_state()
    fmt.println("Shutdown...")
}

register_gui :: proc() {
    button := og.new_button(
        sdl.FRect{0, 500, 200, 50},
        "Button",
        { bg_color = og.RED, text_color = og.BLACK },
        s.fonts[20])

    append(&s.gui.elements, &button)

    s.gui.input_field = og.new_input_field(
        sdl.FRect{10, 75, 200, 20},
        nil,
        "Search",
        {},
        s.fonts[15])

    s.gui.command_palette = og.Modal{
        is_open = false,
        show_backdrop = true,
        height = 1000,
        width = 500,
        draw_content = draw_command_palette_content,
        style = {
            border = 3,
            border_color = og.BLACK,
            border_radius = 10,
            bg_color = og.RED,
            margin = { top = 50 }
        }
    }

    s.gui.panel = Panel{
        bounds = {500, 500, 200, 50}
    }
    s.gui.panel.texture = og.bake_rounded_rect_to_texture(s.gui.panel.bounds.w, s.gui.panel.bounds.h, 2, 15, og.BLACK)
}

on_event :: proc() {
    event : sdl.Event
    for sdl.PollEvent(&event) {
        #partial switch event.type {
        case .QUIT:
            og.quit()
            break
        case .TEXT_INPUT:
            if s.active_viewport == .Main {
                // :: update input_field input ::
                input := strings.clone_from_cstring(event.text.text)
                defer delete(input)

                builder := strings.builder_make()
                copy := strings.clone_from_cstring(s.gui.input_field.input)
                defer delete(copy)

                strings.write_string(&builder, copy)
                strings.write_string(&builder, input)

                s.gui.input_field.input = strings.clone_to_cstring(strings.to_string(builder))
                strings.builder_destroy(&builder)
            }
            break
        case .KEY_DOWN:
            keycode := event.key.scancode
            if keycode == .BACKSPACE {
                if s.active_viewport == .Main {
                    // ::handle input field on backspace::
                    if len(s.gui.input_field.input) > 0 {
                        f := strings.clone_from_cstring(s.gui.input_field.input)
                        defer delete(f)

                        f = f[:len(f)-1]
                        s.gui.input_field.input = strings.clone_to_cstring(f)
                    }
                }
            }

            // TODO: ctrl+p to open
            if keycode == .RETURN {
                if !s.gui.command_palette.is_open {
                    s.gui.command_palette.is_open = true
                }
            }

            if keycode == .ESCAPE {
                if s.gui.command_palette.is_open {
                    s.gui.command_palette.is_open = false
                }
            }

            // toggle between viewports example
            if keycode == .TAB {
                if s.active_viewport == .Main {
                    s.active_viewport = .Settings
                } else {
                    s.active_viewport = .Main
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
    if s.active_viewport == .Main {
        og.draw_text(s.fonts[30].text_buffer, "Main viewport", {10, 10})
        /*for &element in s.gui.elements {
            #partial switch v in element {
            case ^og.Button:
                og.draw_button(v)
                }
            }*/
        og.draw_input_field(&s.gui.input_field)

        og.draw_text(s.fonts[30].text_buffer, "Geometry", {10, 120})
        og.draw_frect(10, 170, 50, 50, og.BLACK)
        og.draw_frect_rounded(80, 170, 50, 50, 10, og.BLACK)
        og.draw_frect_lines(150, 170, 50, 50, 2, og.BLACK)

        og.draw_line_vertical(220, 170, 300, 10, og.BLACK)
        og.draw_line_horizontal(170, 290, 520, 2.5, og.BLACK)
        //og.draw_frect_rounded_top(500, 500, 500, 500, 90, og.BLACK)
        //og.texture_rect_text(&sdl.FRect{500, 500, 500, 500}, 2, 90, og.BLACK)

        og.draw_modal(&s.gui.command_palette)

        // anti-alias rounder corners
        sdl.RenderTexture(og.renderer(), s.gui.panel.texture, nil, &s.gui.panel.bounds)

        // no AA rounded cornerns
        og.draw_frect_rounded_top(710, 500, 200, 50, 15, og.BLACK)


    }

    if s.active_viewport == .Settings {
        og.draw_text(s.fonts[30].text_buffer, "Settings viewport", {10, 10})
    }
}

draw_command_palette_content :: proc(m: ^og.Modal) {
    bounds := m.content_bounds

    vec := og.Vec2{bounds.x + 10, bounds.y + 10}
    og.draw_text(s.fonts[20].text_buffer, "This is modal content", vec)
}


on_click :: proc() {
    fmt.println("clicked")
}

destroy_state :: proc() {
    delete(s.gui.elements)
    sdl.DestroyTexture(s.gui.panel.texture)

    for _, value in s.fonts {
        ttf.DestroyText(value.text_buffer)
        ttf.CloseFont(value.font)
        free(value)
    }

    if s.gui.input_field.input != nil {
        delete(s.gui.input_field.input)
    }

    free(s)
}

