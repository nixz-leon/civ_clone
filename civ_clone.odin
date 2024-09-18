package civ_clone

import "core:fmt"
import m "core:math"
import l "core:math/linalg"
import r "core:math/rand"
import rl "vendor:raylib"
import s "core:strings"
import sc "core:strconv"



hex_size :: 5
DEBUG::false
Root_Three:: 1.7320508075688772935274463415059


info::struct{
    name:string,
    quantity:int
};

resources::struct{
    rock:info,
    soil:info,
    plant:info,
    tree:info,
    water:info
}

tile::struct{//I want to change this to axial cordinates 
    q:int,
    r:int,
    color:rl.Color,
    border:rl.Color,
    moveable:int // 0 == can not move on it, 1 = normal move, 2= 1 move penality, 3 = 2 move penality 
}
tile_group::struct{
    indicies:[dynamic][2]int   
}

names:[5]string={
    "Stone",
    "Soil",
    "Wheat",
    "Oak",
    "Water"   
}
features:[5][6]f16={
    {1.0  ,1.0  ,1.0  ,0.0  ,0.0  ,0.0},//strength, hardness, weight 
    {1.0  ,1.0  ,0.0  ,0.0  ,0.0  ,0.0},//firmness, water absorbtion (water quantity handed to water info on the tile),  
    {0.25 ,0.5  ,1.0  ,0.0  ,0.0  ,0.0},//water_demand, size, food production
    {0.2  ,0.8  ,1.0  ,0.8  ,0.8  ,0.5},//food_pro, hardness, size, strength, flamibility, water_demand
    {0.0  ,0.0  ,0.0  ,0.0  ,0.0  ,0.0} //this is water, its just water, nothing to see yet 
}

gen_tiles::proc(x:int, y:int, tiles: ^[160][160]tile){  
    start_q:int
    start_r:int
    for i in 0..<y{
        for j in 0..<x{
            tiles[j][i].color=rl.BLUE
            tiles[j][i].border = rl.BLACK
            tiles[j][i].q = start_q + j;
            tiles[j][i].r = i;
        }
        if((i%2)==0){
            start_q -=1
        }
    }
}



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
    //rl.SetWindowMaxSize(2560, 1600)
    tiles:[160][160]tile;
    size:f32 = 40
    num_x:int= 106 //80
    num_y:int = 66 //will 
    start_x:int=(1500)/2
    start_y:int=(800)/2
    mouse_Pos:[2]f32
    mouse_cord:[2]int
    tile_pos:[2]f32
    index:[2]int
    dist:[2]f32
    curr_x:int = 0 //describes camera position relative to center
    curr_y:int = 0
    warp_range:int= auto_cast (size*Root_Three* auto_cast(num_x))+1
    y_range:int = auto_cast (size*1.5*auto_cast(num_y))+1 
    image:rl.Image = rl.LoadImage("hex_tex.png")
    rl.ImageColorTint(&image, rl.WHITE)
    texture:rl.Texture2D = rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)
    scale:= (((size*3))-1)/(1025)


    gen_tiles(num_x, num_y, &tiles)
    //gen_continent(&tiles, 120, num_x, num_y)
    path:[dynamic][2]int
    defer delete(path)

    selected_tiles:[dynamic][2]int
    game_loop: for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        for i in 0..<num_x{
            for j in 0..<num_y{
                disp_tile(tiles[i][j], size, warp_range,y_range ,start_x, start_y, curr_x, curr_y, texture)
            }
        }
        
        if(rl.IsMouseButtonPressed(.RIGHT)){
            mouse_Pos = rl.GetMousePosition()
            mouse_Pos[0] = mouse_Pos[0] - auto_cast (start_x - (warp_range/2) +curr_x)
            mouse_Pos[1] = mouse_Pos[1] - auto_cast (start_y - (y_range/2) + curr_y )
            mouse_cord = pix_hex(mouse_Pos,size)
            append(&selected_tiles, mouse_cord)
            //if(len(selected_tiles) == 2){
            //    clear(&path)
            //    path = path_finder_full(&tiles, selected_tiles[0], selected_tiles[1], num_x, num_y)
            //    clear(&selected_tiles)
            //}
        }
        if(rl.IsMouseButtonDown(.RIGHT)){
            mouse_Pos = rl.GetMousePosition()
            mouse_Pos[0] = mouse_Pos[0] - auto_cast (start_x - (warp_range/2) +curr_x)
            mouse_Pos[1] = mouse_Pos[1] - auto_cast (start_y - (y_range/2) + curr_y )
            mouse_cord = pix_hex(mouse_Pos,size)
            clear(&path)
            path = path_finder(&tiles, selected_tiles[0], mouse_cord, num_x, num_y)
        }
        if(rl.IsMouseButtonReleased(.RIGHT)){
            mouse_Pos = rl.GetMousePosition()
            mouse_Pos[0] = mouse_Pos[0] - auto_cast (start_x - (warp_range/2) +curr_x)
            mouse_Pos[1] = mouse_Pos[1] - auto_cast (start_y - (y_range/2) + curr_y )
            mouse_cord = pix_hex(mouse_Pos,size)
            clear(&path)
            path = path_finder(&tiles, selected_tiles[0], mouse_cord, num_x, num_y)
            clear(&selected_tiles)
        }
        if(len(path) >0){
            disp_tiles(&tiles, selected_tiles, size, num_x, warp_range, y_range, start_x, start_y, curr_x, curr_y, rl.PINK, texture)
            disp_tiles(&tiles, path, size, num_x, warp_range, y_range, start_x, start_y, curr_x, curr_y, rl.PINK, texture)
        }
        if(rl.IsKeyPressed(.C)){
            clear(&path)
        }
        if(rl.IsMouseButtonPressed(.LEFT)){
            mouse_Pos = rl.GetMousePosition()
            mouse_Pos[0] = mouse_Pos[0] - auto_cast (start_x - (warp_range/2) +curr_x)
            mouse_Pos[1] = mouse_Pos[1] - auto_cast (start_y - (y_range/2) + curr_y )
            mouse_cord = pix_hex(mouse_Pos,size)
            mouse_cord = hex_to_index_unsafe(warp_hex(mouse_cord, num_x))
            tiles[mouse_cord[0]][mouse_cord[1]].color=rl.RED
        }

        if(rl.IsMouseButtonDown(.MIDDLE)){
            dist = rl.GetMouseDelta()
            curr_x += auto_cast dist[0]
            //curr_y += auto_cast dist[1]
            if(curr_x > warp_range){
                curr_x = curr_x- warp_range
            }else if(curr_x < (-1*warp_range) ){
                curr_x = warp_range - curr_y
            }
            if((-1*y_range/3) < curr_y + auto_cast(dist[1])+4 &&  curr_y + auto_cast(dist[1]) < y_range/3){
                curr_y = curr_y + auto_cast(dist[1])
            }
        }
        
        if (rl.IsKeyPressed(.F)){rl.MaximizeWindow()}
        if(rl.IsWindowResized()){
            window_width = auto_cast rl.GetScreenWidth()
            window_height = auto_cast rl.GetScreenHeight()
            start_x = (auto_cast window_width)/2
            start_y = (auto_cast window_height)/2  
        }
        if(rl.IsKeyPressed(.R)){
            for i in 0..<num_x{
                for j in 0..<num_y{
                    tiles[i][j].color = rl.BLUE
                    tiles[i][j].moveable= 0
                }
            }
            gen_continent_alt(&tiles, 5, num_x, num_y)
            gen_continent_alt(&tiles, 5, num_x, num_y)
            gen_continent_alt(&tiles, 5, num_x, num_y)
        }
        if(rl.IsKeyPressed(.ONE)){
            size = 10
            warp_range= auto_cast (size*Root_Three* auto_cast(num_x))+1
            y_range = auto_cast (size*1.5*auto_cast(num_y))+1 
        }
        if(rl.IsKeyPressed(.TWO)){
            size = 30
            warp_range= auto_cast (size*Root_Three* auto_cast(num_x))+1
            y_range = auto_cast (size*1.5*auto_cast(num_y))+1 
        }
        if(rl.IsKeyPressed(.THREE)){
            size = 50
            warp_range= auto_cast (size*Root_Three* auto_cast(num_x))+1
            y_range= auto_cast (size*1.5*auto_cast(num_y))+1 
        }
        if(rl.IsKeyPressed(.FOUR)){
            size = 70
            warp_range= auto_cast (size*Root_Three* auto_cast(num_x))+1
            y_range= auto_cast (size*1.5*auto_cast(num_y))+1 
        }
        if(rl.IsKeyPressed(.FIVE)){
            size = 90
            warp_range= auto_cast (size*Root_Three* auto_cast(num_x))+1
            y_range= auto_cast (size*1.5*auto_cast(num_y))+1 
        }
        if(rl.IsKeyPressed(.SIX)){
            size = 110
            warp_range= auto_cast (size*Root_Three* auto_cast(num_x))+1
            y_range= auto_cast (size*1.5*auto_cast(num_y))+1 
        }


        

        rl.DrawFPS(30,50)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
