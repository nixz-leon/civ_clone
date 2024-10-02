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
    size:[2]i32,
    pos:[2]i32,
    texture:rl.Texture2D,
    act:action

}
is_button_clicked::proc(b:Button, mouse_pos:[2]int)->(bool){
    if(rl.IsMouseButtonPressed(.LEFT)){
        min_x,min_y,max_x,max_y:int
        min_x = auto_cast (b.pos[0])
        max_x = auto_cast (b.pos[0] + b.size[0])
        min_y = auto_cast (b.pos[1])
        max_y = auto_cast (b.pos[1] + b.size[1])
        //fmt.println(min_x, max_x, min_y, max_y)
        //fmt.println(mouse_pos)
        if ((min_y < mouse_pos[1]) && (mouse_pos[1]  <max_y) && (min_x < mouse_pos[0])&& (mouse_pos[0]<max_x)){
            fmt.println("hit")
            fmt.println(b.act)
            return true
        }
        
    }
    return false
}

init_button::proc(b:^Button, pos:[2]i32 ,file_name:cstring, act:action){
    image:rl.Image = rl.LoadImage(file_name)
    b.size[0] = image.width
    b.size[1] = image.height
    b.texture = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)
    b.pos = pos
    b.act=act
}


start_screen::proc(world:^World_Space,state:^game_state){
    mouse_pos:[2]int
    exit:bool=false
    Buttons:[dynamic]Button 
    /*image:rl.Image = rl.LoadImage("resources/start.png")
    rl.ImageColorTint(&image, rl.WHITE)
    texture:rl.Texture2D = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)
    temp_b:Button = {{200,100}, {100,100},texture, .new_game}*/
    temp_b:Button
    init_button(&temp_b, {200,200}, "resources/start.png", .new_game)
    append(&Buttons, temp_b)
    init_button(&temp_b, {200,305}, "resources/resume_game.png", .resume_game)
    append(&Buttons, temp_b)


    curr_act:action = .nothing
    
    for !exit{
        
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        mouse_pos[0] = auto_cast rl.GetMouseX()
        mouse_pos[1] = auto_cast rl.GetMouseY()
 
        
        for b in Buttons{
            disp_button(b)
            if(is_button_clicked(b, mouse_pos)){
                curr_act = b.act
            }
        }

        if(curr_act == .new_game){//should bring to another subMenu this can probably be done relatively seemlessly by loading in via cbor, different menus
            init_World_space(world, 106, 66)
            //gen_continent(world, 5)
            //gen_land_mass(world, {53,33}, 20)
            exit=true
            state^=.game_loop
        }else if(curr_act == .resume_game){
            exit=true
            state^=.game_loop
            load_game(world, "test.sav")
        }
        if(rl.WindowShouldClose()){
            exit = true
            state^=.close
        }

        rl.EndDrawing()
    }
   
}