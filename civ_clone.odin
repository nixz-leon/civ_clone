package civ_clone

import "core:fmt"
import m "core:math"
import l "core:math/linalg"
import r "core:math/rand"
import rl "vendor:raylib"
import s "core:strings"
import sc "core:strconv"



DEBUG::false
game_state::enum{
    start_menu,
    pause_menu,
    game_loop,
    close

}


main::proc(){ 
    window_width:int=1500
    window_height:int=800
    rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
    rl.InitWindow((auto_cast window_width), (auto_cast window_height), "Bloop")
    rl.SetWindowState({.WINDOW_MAXIMIZED})
    rl.SetTargetFPS(200)
    rl.SetWindowMinSize(20, 20)


    world:World_Space

    /*
    image:rl.Image = rl.LoadImage("hex_tex.png")
    rl.ImageColorTint(&image, rl.WHITE)
    texture:rl.Texture2D = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)
    scale:= (((size*3))-1)/(1025)
    */

    
    state:game_state = .start_menu
    game_loop: for (!rl.WindowShouldClose()) {
        fmt.println(state)
        if(state == .start_menu){
            start_screen(&world, &state)
        }else if(state == .game_loop){
            game_screen(&world, &state)
        }else if (state == .pause_menu){
            pause_screen(&world, &state)
        }else if(state == .close){
            break
        }
    }
    rl.CloseWindow()
}
