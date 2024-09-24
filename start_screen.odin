package civ_clone

import rl "vendor:raylib"
import "core:fmt"


action::enum{
    nothing=0,
    new_game=1,
    load_game=2,
    resume_game=3,
    save_game=4,
    main_menu=5
}
Button::struct{//I may want to replace cstring and rl.color with textures at some later point
    text:cstring,
    size:[2]i32,
    pos:[2]i32,
    text_pos:[2]i32,
    text_size:i32,
    color:rl.Color,
    act:action

}
is_button_clicked::proc(b:Button, mouse_pos:[2]int)->(bool){
    if(rl.IsMouseButtonDown(.LEFT)){
        min_x,min_y,max_x,max_y:int
        min_x = auto_cast (b.pos[0])
        max_x = auto_cast (b.pos[0] + b.size[0])
        min_y = auto_cast (b.pos[1])
        max_y = auto_cast (b.pos[1] + b.size[1])
        if ((min_y < mouse_pos[1]) && (mouse_pos[1]  <max_y) && (min_x < mouse_pos[0])&& (mouse_pos[0]<max_x)){
            return true
        }
        
    }
    return false
}


start_screen::proc(world:^World_Space,state:^game_state){
    mouse_pos:[2]int
    exit:bool=false
    Buttons:[dynamic]Button 
    temp_b:Button = {"start", {100,50}, {100,100}, {105,105},20, rl.BLUE, .new_game}
    curr_action:action = .nothing
    append(&Buttons, temp_b)
    for !exit{
        
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        mouse_pos[0] = auto_cast rl.GetMouseX()
        mouse_pos[1] = auto_cast rl.GetMouseY()
 
        
        for b in Buttons{
            disp_button(b)
            if(is_button_clicked(b, mouse_pos)){
                curr_action = b.act
            }
        }

        if(curr_action == .new_game){//should bring to another subMenu this can probably be done relatively seemlessly by loading in via cbor, different menus
            init_World_space(world, 160, 66)
            exit=true
            state^=.game_loop
        }


        if(rl.WindowShouldClose()){
            exit = true
            state^=.close
        }

        rl.EndDrawing()
    }
}