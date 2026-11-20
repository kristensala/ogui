package ogui

import "core:fmt"
import sdl "vendor:sdl3"

@(private = "file") Draw_Proc :: proc()
@(private = "file") Update_Proc :: proc()

Rect :: sdl.Rect
FRect :: sdl.FRect
Color :: sdl.Color

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

window_should_close :: proc() -> bool {
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

    return !state.running
}

shutdown :: proc() {
    sdl.Quit()
    sdl.DestroyWindow(state.window)
    sdl.DestroyRenderer(state.renderer)

    free(state)
}

draw_frect_ex :: proc(rect: ^FRect, color: Color) {
    ok := sdl.SetRenderDrawColor(state.renderer, color.r, color.g, color.b, color.a)
	if !ok {
		fmt.eprintln("Could not set the rect color: ", sdl.GetError())
	}

	sdl.RenderFillRect(state.renderer, rect)
}

draw_frect :: proc(x, y, w, h: f32, color: Color) -> FRect {
    ok := sdl.SetRenderDrawColor(state.renderer, color.r, color.g, color.b, color.a)
	if !ok {
		fmt.eprintln("Could not set the rect color: ", sdl.GetError())
	}

	rect: FRect = {x, y, w, h}
	sdl.RenderFillRect(state.renderer, &rect)
	return rect
}

set_background_color :: proc(color: Color) {
    state.background_color = color
}
