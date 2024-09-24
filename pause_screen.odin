package civ_clone 
import rl "vendor:raylib"


pause_screen::proc(world:^World_Space, state:^game_state){
    exit:bool=false
    temp_b:Button = {"Main Menu", {100,50}, {100,100}, {105,105},15, rl.GRAY, .main_menu}
    mouse_pos:[2]int
    curr_action:action = .nothing
    for (!exit){
        rl.BeginDrawing()
        mouse_pos[0] = auto_cast rl.GetMouseX()
        mouse_pos[1] = auto_cast rl.GetMouseY()
        if(rl.IsKeyPressed(.ESCAPE)){
            exit = true
            state^=.game_loop
        }else if(rl.WindowShouldClose()){
            exit = true
            state^=.close
        }


        disp_button(temp_b)
        if(is_button_clicked(temp_b, mouse_pos)){
            curr_action = temp_b.act
        }

        if(curr_action == .main_menu){
            if(rl.IsMouseButtonReleased(.LEFT)){
            exit = true
            state^=.start_menu
            clear(&world.world)
            }
        }


        rl.EndDrawing()

    }



}