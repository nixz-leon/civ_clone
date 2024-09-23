package civ_clone

import "core:fmt"
import m "core:math"
import l "core:math/linalg"
import r "core:math/rand"
import rl "vendor:raylib"
import s "core:strings"
import sc "core:strconv"



DEBUG::false



paint_neighbor::proc(obs:^[160][160]tile,QR:[2]int, num_x, num_y:int, color:rl.Color){
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}};
    temp:[2]int
    for i in 0..<6{
        neighbors[i] = neighbors[i] + QR
        temp = warp_hex(neighbors[i], num_x)
        temp = hex_to_index_unsafe(temp)
        if(temp[1] >=0 && temp[1] < num_y){
            obs[temp[0]][temp[1]].color = color
        }
    }
}



main::proc(){ 
    window_width:int=1500
    window_height:int=800
    rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
    rl.InitWindow((auto_cast window_width), (auto_cast window_height), "Bloop")
    rl.SetTargetFPS(200)
    rl.SetWindowMinSize(20, 20)


    world:World_Space
    init_World_space(&world, 160, 66)


    mouse_cord:[2]int
    tile_pos:[2]f32
    index:[2]int
    
    path:[dynamic][2]int
    path2:[dynamic][2]int

    /*
    image:rl.Image = rl.LoadImage("hex_tex.png")
    rl.ImageColorTint(&image, rl.WHITE)
    texture:rl.Texture2D = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)
    scale:= (((size*3))-1)/(1025)
    */
    selected_tiles:[dynamic][2]int
    game_loop: for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        for i in 0..<(world.num_x*world.num_y){
            disp_tile(&world, &world.world[i])
        }

        mouse_cord = get_qr_mouse(&world)
        
/*
        if(rl.IsMouseButtonPressed(.RIGHT)){
            append(&selected_tiles, mouse_cord)
        }
        if(rl.IsMouseButtonDown(.RIGHT)){
            clear(&path)
            path = path_finder(&tiles, selected_tiles[0], mouse_cord, num_x, num_y)
        }
        if(rl.IsMouseButtonReleased(.RIGHT)){
            clear(&path)
            path = path_finder(&tiles, selected_tiles[0], mouse_cord, num_x, num_y)
            clear(&selected_tiles)
        }
        if(len(path) >0){
            //disp_tiles(&tiles, selected_tiles, size, num_x, warp_range, y_range, start_x, start_y, curr_x, curr_y, rl.PINK, texture)
            disp_tiles(&world, path, rl.PINK)
        }
        if(rl.IsKeyPressed(.C)){
            clear(&path)
        }*/
        if(rl.IsMouseButtonPressed(.LEFT)){
            set_tile_color_mouse(&world, mouse_cord, rl.RED)            
        }
        if(rl.IsMouseButtonDown(.MIDDLE)){
            update_world_pos(&world)

        }
        if (rl.IsKeyPressed(.F)){rl.MaximizeWindow()}
        if(rl.IsWindowResized()){
            window_update(&world) 
        }
        
        if(rl.IsKeyPressed(.R)){
            for i in 0..<world.num_x*world.num_y{
                world.world[i].color = rl.BLUE
                world.world[i].moveable =0
            }
            gen_continent(&world, 4)
            //gen_land_mass(&world, {104, 47}, 630)
        }
        
        if(rl.IsKeyPressed(.UP)){
            world.size+=10
            update_range(&world)
        }else if (rl.IsKeyPressed(.DOWN)){
            world.size-=10
            update_range(&world)
        }
        rl.GetMouseWheelMove()
        rl.DrawFPS(30,50)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
