package civ_clone
import rl "vendor:raylib"



game_screen::proc(world:^World_Space, state:^game_state){
    exit:bool=false

    mouse_cord:[2]int
    tile_pos:[2]f32
    index:[2]int
    
    path:[dynamic][2]int
    path2:[dynamic][2]int

    for !exit{
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
    
        for i in 0..<(world.num_x*world.num_y){
            disp_tile(world, &world.world[i])
        }

        mouse_cord = get_qr_mouse(world)
        
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
            set_tile_color_mouse(world, mouse_cord, rl.RED)            
        }
        if(rl.IsMouseButtonDown(.MIDDLE)){
            update_world_pos(world)

        }
        if (rl.IsKeyPressed(.F)){rl.MaximizeWindow()}
        if(rl.IsWindowResized()){
            window_update(world) 
        }
        
        if(rl.IsKeyPressed(.R)){
            for i in 0..<world.num_x*world.num_y{
                world.world[i].color = rl.BLUE
                world.world[i].moveable =0
            }
            //gen_continent(world, 4)
            //gen_land_mass(&world, {104, 47}, 630)
            gen_land_mass(world, {53,33}, 200)
        }
        
        if(rl.IsKeyPressed(.UP)){
            world.size+=10
            update_range(world)
        }else if (rl.IsKeyPressed(.DOWN)){
            world.size-=10
            update_range(world)
        }

        if(rl.IsKeyPressed(.ESCAPE)){
            exit=true
            state^= .pause_menu
        }else if(rl.WindowShouldClose()){
            exit = true
            state^=.close
        }
        rl.GetMouseWheelMove()
        rl.DrawFPS(30,50)
        rl.EndDrawing()
    }
}


