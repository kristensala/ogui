package ogui

import "core:fmt"
import sdl "vendor:sdl3"

@(private = "file") Draw_Proc :: proc()
@(private = "file") Update_Proc :: proc()
@(private = "file") On_Button_Click_Proc :: proc()

Vec2 :: [2]f32
Vec4 :: [4]i32
Rect :: sdl.Rect
F_Rect :: sdl.FRect
Color :: sdl.Color
Window_Flags :: sdl.WindowFlags
Renderer :: sdl.Renderer
Mouse_Button_Flags :: sdl.MouseButtonFlags

Element_Style :: struct {
    border_radius: f32,
    color: Color,
    text_color: Color
    font_size: i32,
    padding: Vec4,
    margin: Vec4
}

Button :: struct {
    bounds: F_Rect,
    label: string,

    style: Style,

    clicked: bool,
    on_click: On_Button_Click_Proc,
}

@(private = "file")
State :: struct {
    running: bool,

    window: ^sdl.Window,
    renderer: ^sdl.Renderer,

    background_color: sdl.Color,

    on_draw: Draw_Proc,
    on_update: Update_Proc,
}


@(private = "file")
state: ^State

poll_event :: sdl.PollEvent

init :: proc(
    width: i32,
    height: i32,
    title: cstring,
    on_draw: Draw_Proc,
    on_update: Update_Proc
) {
    state = new(State)
    state.background_color = sdl.Color{0, 0, 0, sdl.ALPHA_OPAQUE} // black
    state.on_draw = on_draw
    state.on_update = on_update

    if !sdl.Init({.VIDEO}) {
        fmt.eprintln("sdl.Init failed: ", sdl.GetError())
        return
    }

    state.window = sdl.CreateWindow(
        title,
        width,
        height,
        {},
    )

    if state.window == nil {
        fmt.eprintln("Failed to create the window")
        return
    }

    state.renderer = sdl.CreateRenderer(state.window, nil)
    if state.renderer == nil {
        fmt.eprintln("Could not create a renderer: ", sdl.GetError())
        return
    }

    state.running = true
}

run :: proc() {
    for state.running {
        event : sdl.Event
        for sdl.PollEvent(&event) {
            #partial switch event.type {
            case .QUIT:
                state.running = false
                break
            }
        }

        state.on_update()

        sdl.SetRenderDrawColor(state.renderer,
            state.background_color.r,
            state.background_color.g,
            state.background_color.b,
            state.background_color.a)

        sdl.RenderClear(state.renderer)
        // Drawing should be done between RenderClear and RenderPresent
        state.on_draw()

        sdl.RenderPresent(state.renderer)
    }

}

shutdown :: proc() {
    sdl.Quit()
    sdl.DestroyWindow(state.window)
    sdl.DestroyRenderer(state.renderer)

    free(state)
}

set_background_color :: proc(color: Color) {
    state.background_color = color
}

get_renderer :: proc() -> ^Renderer {
    return state.renderer
}

get_mouse_state :: proc() -> (mouse_state: Mouse_Button_Flags, pos: Vec2) {
    v: Vec2
    x := sdl.GetMouseState(&v.x, &v.y)
    return x, v
}

draw_frect_ex :: proc(rect: ^F_Rect, color: Color) {
    ok := sdl.SetRenderDrawColor(state.renderer, color.r, color.g, color.b, color.a)
	if !ok {
		fmt.eprintln("Could not set the rect color: ", sdl.GetError())
	}

	sdl.RenderFillRect(state.renderer, rect)
}

draw_frect :: proc(x, y, w, h: f32, color: Color) -> F_Rect {
    ok := sdl.SetRenderDrawColor(state.renderer, color.r, color.g, color.b, color.a)
	if !ok {
		fmt.eprintln("Could not set the rect color: ", sdl.GetError())
	}

	rect: F_Rect = {x, y, w, h}
	sdl.RenderFillRect(state.renderer, &rect)
	return rect
}

check_collision_point :: proc(p: Vec2, rect: F_Rect) -> bool {
    pp: sdl.FPoint = {p.x, p.y}
    return sdl.PointInRectFloat(pp, rect)
}

button :: proc(b: ^Button) {
    draw_frect_ex(&b.bounds, b.style.color)

    /*buttons, p := get_mouse_state()
    if check_collision_point(p, b.rect) {
        if sdl.MouseButtonFlag.LEFT in buttons {
            on_click()
            return
        }
    }*/

}
