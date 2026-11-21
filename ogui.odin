package ogui

import "core:fmt"
import sdl "vendor:sdl3"
//import ttf "vendor:sdl3/ttf"

@(private = "file") Draw_Proc :: proc()
@(private = "file") Update_Proc :: proc()
@(private = "file") Event_Proc :: proc()
@(private = "file") On_Button_Click_Proc :: proc()

Vec2 :: [2]f32
Rect :: sdl.Rect
F_Rect :: sdl.FRect
Color :: sdl.Color
Window_Flags :: sdl.WindowFlags
Renderer :: sdl.Renderer
Mouse_Button_Flags :: sdl.MouseButtonFlags

// TODO: Define some common Colors
BLACK :: Color{0, 0, 0, sdl.ALPHA_OPAQUE}
WHITE :: Color{}

Padding :: struct {
    top, bottom, left, right: i32
}

Margin :: struct {
    top, bottom, left, right: i32
}

Element_Style :: struct {
    border_radius: f32,
    color: Color,
    text_color: Color,
    font_size: i32,
    padding: Padding,
    margin: Margin
}

Element_Props :: struct {
    bounds: F_Rect,
    parent_bounds: ^F_Rect,
    style: Element_Style,
}

Text :: struct {
    //text: ttf.Text,
    color: Color,
    font_size: f32,
}

Button :: struct {
    using element: Element_Props,

    label: Text,
    clicked: bool,
    on_click: On_Button_Click_Proc,
}


@(private = "file")
State :: struct {
    running: bool,

    window: ^sdl.Window,
    renderer: ^sdl.Renderer,
    //text_engine: ^ttf.TextEngine,

    background_color: sdl.Color,

    //default_font: ^ttf.Font,
    default_font_size: f32,
    fps: i32,
}


@(private = "file")
state: ^State

init :: proc(
    width: i32,
    height: i32,
    title: cstring,
) {
    state = new(State)
    state.background_color = BLACK

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
}

// Let the monitor set the rate
use_vsync :: proc() {
    set_vsync := sdl.SetRenderVSync(state.renderer, 1)
    if !set_vsync {
        fmt.eprintln("Failed to set renderer VSync!")

        set_vsync_adaptive := sdl.SetRenderVSync(state.renderer, sdl.RENDERER_VSYNC_ADAPTIVE)
        if !set_vsync_adaptive {
            fmt.eprintln("Failed to set renderer VSync as adaptive!")
        }
    }
}

/*load_font :: proc(font_path: cstring, font_size: f32) {
    if !ttf.Init() {
        fmt.eprintln(sdl.GetError())
        return
    }

    state.default_font = ttf.OpenFont(font_path, font_size)
    if state.default_font == nil {
        fmt.eprintln("Failed to open font")
        return
    }

    state.text_engine = ttf.CreateRendererTextEngine(state.renderer)
    if state.text_engine == nil {
        fmt.eprintln("Failed to create renderer text engine")
        return
    }
}*/


run :: proc(
    on_event: Event_Proc,
    on_draw: Draw_Proc,
    on_update: Update_Proc
) {
    state.running = true

    for state.running {
        on_event()
        on_update()

        sdl.SetRenderDrawColor(state.renderer,
            state.background_color.r,
            state.background_color.g,
            state.background_color.b,
            state.background_color.a)

        sdl.RenderClear(state.renderer)
        // Drawing should be done between RenderClear and RenderPresent
        on_draw()

        sdl.RenderPresent(state.renderer)
    }

    shutdown()

}

quit :: proc() {
    state.running = false
}

@(private = "file")
shutdown :: proc() {
    sdl.Quit()
    sdl.DestroyWindow(state.window)
    sdl.DestroyRenderer(state.renderer)

    /*ttf.DestroyRendererTextEngine(state.text_engine)
    ttf.CloseFont(state.default_font)
    ttf.Quit()*/

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

draw_frect_rounded :: proc(x, y, w, h: f32, color: Color) -> F_Rect {
    // TODO
    return {}
}

draw_line_vertical :: proc(x, start_y, end_y: f32, thickness: f32, color: Color) -> F_Rect {
    return draw_frect(x, start_y, thickness, end_y - start_y, color)
}

draw_line_horizontal :: proc(y, start_x, end_x: f32, thickness: f32, color: Color) -> F_Rect {
    return draw_frect(y, start_x, end_x - start_x, thickness, color)
}

check_collision_point :: proc(p: Vec2, rect: F_Rect) -> bool {
    pp: sdl.FPoint = {p.x, p.y}
    return sdl.PointInRectFloat(pp, rect)
}

// @todo: draw text
draw_button :: proc(b: ^Button) {
    draw_frect_ex(&b.bounds, b.style.color)

    /*buttons, p := get_mouse_state()
    if check_collision_point(p, b.rect) {
        if sdl.MouseButtonFlag.LEFT in buttons {
            on_click()
            return
        }
    }*/

}
