package examples

import og "../"

import "core:fmt"

main :: proc() {
    err := og.init(1000, 100, "title")
    if err != nil {
        return
    }

    // main loop
    for og.update() {

    }

    fmt.println("about to call shutdown")
    og.shutdown()
}
