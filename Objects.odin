package civ_clone
import rl "vendor:raylib"
import "core:fmt"
import "core:encoding/cbor"
import "base:intrinsics"
import "core:reflect"
import "core:io"

Root_Three:: 1.7320508075688772935274463415059

//need to add the cbor tags for save file stuff
World_Space::struct{
    num_x:int,
    num_y:int,
    window_height:int,
    window_width:int,
    warp_range:int,
    y_range:int,
    start_x:int,
    start_y:int,
    curr_x:int,
    curr_y:int,
    size:f32,
    world:[dynamic]tile `cbor:"toarray"`
}

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
sail::enum{
    no = 0,
    shallow = 1,
    deep = 1,
}

terrain::enum{
    mountain = 8,
    jungle = 7,
    hill = 6,
    forest = 5,
    plains = 4,
    desert = 3,
    coastal = 2,
    shallow_water = 1,
    deep_water = 0,
}
unit::struct{
    can_walk:bool,
    can_swim:sail,
    health:int,
    move_dist:int
}

tile::struct{
    q,r:int`cbor_tag:"raw"`,
    color:rl.Color`cbor_tag:"raw"`,
    border:rl.Color`cbor_tag:"raw"`,
    moveable:int`cbor_tag:"raw"`,
    terrain:terrain`cbor_tag:"raw"`
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

neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}}


round::proc(a:f32)->(int){
    if (a < 0){
        return cast(int)(a-0.5)
    }else{
        return cast(int)(a+0.5)
    }
}
round_qr::proc(a:[2]f32) ->([2]int){
    return {round(a[0]),round(a[1])}
}

get_tile::proc(space:^World_Space, qr:[2]int)->(tile){
    qr:=warp_hex(qr, space.num_x)
    return space.world[qr[0] + qr[1]*space.num_x]
}
set_tile_color_mouse::proc(space:^World_Space, qr:[2]int,color:rl.Color){
    space.world[qr[0] + qr[1]*space.num_x].color = color
}
set_tile_color::proc(space:^World_Space, qr:[2]int,color:rl.Color){
    temp:[2]int = hex_to_index(warp_hex(qr, space.num_x), space.num_x, space.num_y)
    space.world[temp[0] + temp[1]*space.num_x].color = color
}
set_tile_terrain_s::proc(space:^World_Space, qr:[2]int,moveability:int,type:terrain){
    temp:[2]int = hex_to_index_unsafe(warp_hex(qr, space.num_x))
    space.world[temp[0] + temp[1]*space.num_x].moveable = moveability
    space.world[temp[0] + temp[1]*space.num_x].terrain = type
}
get_tile_mouse::proc(space:^World_Space, qr:[2]int)->(tile){
    return space.world[qr[0] + qr[1]*space.num_x]
}
get_qr_mouse::proc(space:^World_Space)->([2]int){
    mouse_Pos:[2]f32 = rl.GetMousePosition()
    mouse_Pos[0] -= auto_cast (space.start_x - (space.warp_range/2)+space.curr_x) 
    mouse_Pos[1] = mouse_Pos[1] - auto_cast (space.start_y - (space.y_range/2) + space.curr_y )
    return pix_index((pix_hex(mouse_Pos, space.size)),space.num_x)

}

init_World_space::proc(space:^World_Space, num_x,num_y:int){
    resize_dynamic_array(&space.world, num_x*num_y)
    space.num_x = num_x
    space.num_y = num_y
    space.window_height = auto_cast rl.GetScreenHeight()
    space.window_width = auto_cast rl.GetScreenWidth()
    space.start_x = space.window_width/2
    space.start_y = space.window_height/2
    space.size = 40
    update_range(space)

    start_q:int
    for i in 0..<space.num_y{
        for j in 0..<space.num_x{
            temp:tile
            temp.border=rl.BLACK
            temp.color=rl.BLUE
            temp.q = start_q +j
            temp.r = i
            space.world[j + (i*space.num_x)] = temp
        }
        if((i%2)==0){
            start_q-=1
        }
    }
}

window_update::proc(space:^World_Space){
    space.window_height = auto_cast rl.GetScreenHeight()
    space.window_width = auto_cast rl.GetScreenWidth()
    space.start_x = (auto_cast space.window_height)/2
    space.start_y = (auto_cast space.window_width)/2
}
update_world_pos::proc(space:^World_Space){
    delta:[2]f32 = rl.GetMouseDelta()
    space.curr_x += round(delta[0])
    if(space.curr_x > space.warp_range){
        space.curr_x -= space.warp_range
    }else if(space.curr_x < (0-space.warp_range)){
        space.curr_x = space.warp_range - space.curr_x
    }
    if(((0-space.y_range/3) < (space.curr_y + auto_cast(delta[1])+ 4))   &&   (space.curr_y + auto_cast(delta[1]) < space.y_range/3)){
        space.curr_y += auto_cast(delta[1])
    }
}
update_range::proc(space:^World_Space){
    space.warp_range = auto_cast (space.size*Root_Three* auto_cast(space.num_x))+1
    space.y_range= auto_cast (space.size*1.5*auto_cast(space.num_y))+1 
}

in_group::proc(tiles:^[dynamic][2]int, qr:[2]int) -> (bool){
    in_c:bool=false
    for i in 0..<len(tiles^){
        if(tiles[i] == qr){
            in_c = in_c||true
        }
    }
    return in_c
}

get_neighbors::proc(world:^World_Space, qr:[2]int)->([dynamic][2]int){
    out:[dynamic][2]int
    next: for shift in neighbors{
        temp:[2]int
        temp = qr + shift
        if(temp[1] < 0 || temp[1]>=world.num_y){break next}
        append(&out, warp_hex(temp, world.num_x)) 
    }
    return out
}