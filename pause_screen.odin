package civ_clone 
import rl "vendor:raylib"


pause_screen::proc(world:^World_Space, state:^game_state){
    exit:bool=false
    /*image:rl.Image = rl.LoadImage("resources/Return_to_menu.png")
    rl.ImageColorTint(&image, rl.WHITE)
    texture:rl.Texture2D = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)
    temp_b:Button = {{200,100}, {100,100},texture, .main_menu}
    */
    Buttons:[dynamic]Button
    temp_b:Button
    init_button(&temp_b, {200,200}, "resources/Return_to_menu.png", .main_menu)
    append(&Buttons, temp_b)
    init_button(&temp_b, {200, 305}, "resources/Save_game.png", .save_game)
    append(&Buttons, temp_b)

    mouse_pos:[2]int
    curr_act:action = .nothing
    buff_act:action = .nothing
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
        
        for b in Buttons{
            disp_button(b)
            if(is_button_clicked(b, mouse_pos)){
                buff_act = b.act
            }
        }

        if(rl.IsMouseButtonReleased(.LEFT)){
            curr_act = buff_act
        }

        

        if(curr_act == .main_menu){
            exit = true
            state^=.start_menu
            clear(&world.world)
        }else if(curr_act == .save_game){
            curr_act = .nothing
            save_game(world, "test.sav")
            
        }


        rl.EndDrawing()

    }



}