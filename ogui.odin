package ogui

import "base:runtime"
import "vendor:wgpu"
import "vendor:glfw"
import glg "vendor:wgpu/glfwglue"

Window_Handle :: glfw.WindowHandle

Vec2 :: [2]f32

Rect :: struct {
    width: f32,
    height: f32,
    x: f32,
    y: f32
}

Ogui_Error :: enum {
    Window_Creation_Failed,
    Glfw_Init_Failed
}

// resizeable etc
Window_Options :: struct {
}


// TODO: track current font 
// load_font() and unload_font
// draw_rect
// draw_line
// draw_rect_rounded
// draw_text, draw_text_ex
// button()
// mouse_check_collision(rect, mouse_pos)
// get_mouse_pos() -> Vec2
@(private = "package")
State :: struct {
    ctx: runtime.Context,

    instance: wgpu.Instance,
    surface: wgpu.Surface,
    texture: wgpu.Texture,
    adapter: wgpu.Adapter,
    device: wgpu.Device,

    window_handle: Window_Handle
}

@(private = "file")
g_state: ^State

//init :: glfw.Init
//create_window :: glfw.CreateWindow
//window_should_close :: glfw.WindowShouldClose
//poll_events :: glfw.PollEvents

@(require_results)
init :: proc(
    window_width: i32,
    window_height: i32,
    window_title: cstring,
    options: Window_Options = {}
) -> Ogui_Error {
    g_state.ctx = context

    if !bool(glfw.Init()) {
        //glfw.GetError()
        return .Glfw_Init_Failed
    }

    g_state.window_handle = glfw.CreateWindow(window_width, window_height, window_title, nil, nil)
    if g_state.window_handle == nil {
        // fmt.eprintln("failed to create the window")
        return .Window_Creation_Failed
    }
    g_state.instance = wgpu.CreateInstance(nil)
    g_state.surface = glg.GetSurface(g_state.instance, g_state.window_handle)

    wgpu.InstanceRequestAdapter(
        g_state.instance,
        &{ compatibleSurface = g_state.surface },
        { callback = on_adapter }
    )

    return nil
}

update :: proc() -> bool {
    should_close := bool(glfw.WindowShouldClose(g_state.window_handle))
    if !should_close {
        // TODO: do some stuff
    }

    // if should_close is true then exit the update
    return !should_close
}

shutdown :: proc() {
    glfw.Terminate()
    glfw.DestroyWindow(g_state.window_handle)
}

// glfw.PollEvents()
// if there is nothing specific to do here then just do poll_events :: glfw.PollEvents()
poll_events :: proc() {
}

get_window_size :: proc() -> (width, heigth: i32) {
    assert(g_state.window_handle != nil, "Make sure ogui.init is called before")
    return glfw.GetWindowSize(g_state.window_handle)
}


@(private = "file")
on_adapter :: proc "c" (
    status: wgpu.RequestAdapterStatus,
    adapter: wgpu.Adapter,
    message: string,
    userdata1: rawptr,
    userdata2: rawptr
) {
    // TODO
}

