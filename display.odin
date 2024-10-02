package civ_clone

import "core:fmt"
import m "core:math"
import l "core:math/linalg"
import r "core:math/rand"
import rl "vendor:raylib"
import s "core:strings"
import sc "core:strconv"



disp_tile::proc(world:^World_Space,item:^tile){
    scale:= (((world.size*1.9)))/(1025)
    r:f32 = auto_cast item.r
    q:f32 = auto_cast item.q
    x_pos:= world.size * ((Root_Three*q)+((Root_Three*0.5)*r))
    y_pos:= world.size * (1.5*r)
    x_offset:f32 = auto_cast (world.curr_x) - auto_cast(world.warp_range)/2
    disp_x:f32= x_pos+x_offset//relative to center
    disp_y:f32= y_pos+ (auto_cast (world.curr_y-(world.y_range/2)))
    
    disp_x = warp_x(disp_x, world.warp_range)

    disp_x = (disp_x + (auto_cast (world.start_x - world.warp_range/2 )))
    disp_y = (disp_y + (auto_cast world.start_y) )
    rl.DrawPoly({disp_x,disp_y}, 6, world.size-1, 30, item.color)
    rl.DrawPolyLines({disp_x,disp_y}, 6, world.size, 30, item.border)


    if(DEBUG){
        buf: [4]byte
        str:string =  sc.itoa(buf[:],item.q)
        cstr:cstring = s.clone_to_cstring(str)
        str2:string = sc.itoa(buf[:],item.r)
        cstr2:cstring = s.clone_to_cstring(str2)
        str3:string = sc.itoa(buf[:], item.moveable)
        cstr3:cstring = s.clone_to_cstring(str3)
        rl.DrawText(cstr, auto_cast disp_x-8, auto_cast disp_y-8, 2, rl.BLACK)
        rl.DrawText(cstr2, auto_cast disp_x+8, auto_cast disp_y+2, 2, rl.BLACK)
        rl.DrawText(cstr3, auto_cast disp_x-8, auto_cast disp_y+5, 2, rl.WHITE)
        delete(cstr)
        delete(cstr2)
        delete(cstr3)
    }
}



disp_tiles::proc(world:^World_Space,tiles:[dynamic][2]int, color:rl.Color){
    temp:[2]int
    for i in 0..<len(tiles){
        temp = warp_hex(tiles[i], world.num_x)
        item:tile = get_tile_qr(world, temp)
        scale:= (((world.size*1.9)))/(1025)
        r:f32 = auto_cast item.r
        q:f32 = auto_cast item.q
        x_pos:= world.size * ((Root_Three*q)+((Root_Three*0.5)*r))
        y_pos:= world.size * (1.5*r)
        x_offset:f32 = auto_cast (world.curr_x) - auto_cast(world.warp_range)/2
        disp_x:f32= x_pos+x_offset//relative to center
        disp_y:f32= y_pos+ (auto_cast (world.curr_y-(world.y_range/2)))
        
        disp_x = warp_x(disp_x, world.warp_range)

    disp_x = (disp_x + (auto_cast (world.start_x - world.warp_range/2 )))
    disp_y = (disp_y + (auto_cast world.start_y) )
    rl.DrawPoly({disp_x,disp_y}, 6, world.size-1, 30, color)
    rl.DrawPolyLines({disp_x,disp_y}, 6, world.size, 30, item.border)
    //rl.DrawCylinder({disp_x, -1, disp_y}, 1, 1, 4, 6, item.color)
    //rl.DrawCylinderWires({disp_x, -0.99, disp_y}, 1, 1, 4, 6, item.border)
        
        if(DEBUG){
            buf: [4]byte
            str:string =  sc.itoa(buf[:],item.q)
            cstr:cstring = s.clone_to_cstring(str)
            str2:string = sc.itoa(buf[:],item.r)
            cstr2:cstring = s.clone_to_cstring(str2)
            str3:string = sc.itoa(buf[:], item.moveable)
            cstr3:cstring = s.clone_to_cstring(str3)
            rl.DrawText(cstr, auto_cast disp_x-8, auto_cast disp_y-8, 2, rl.BLACK)
            rl.DrawText(cstr2, auto_cast disp_x+8, auto_cast disp_y+2, 2, rl.BLACK)
            rl.DrawText(cstr3, auto_cast disp_x-8, auto_cast disp_y+5, 2, rl.WHITE)
            delete(cstr)
            delete(cstr2)
            delete(cstr3)
        }
        
    }
}



disp_button::proc(b:Button){
    rl.DrawTexture(b.texture, b.pos[0], b.pos[1], rl.WHITE)
}


//For the display section I want to work on getting the orthographic 3d perspective to work, this will involve an extensive
//rework for the world_state struct mostly likely to account for the camera. and the like
//also proper bounds for scrolling would be cool, and it would start to look nice ish
//I don't know if this is something that could be set in settings, like a button to go from 3d mode to 2d mode
//even then for this I would need to get a tile texture to work properly, this might be very hard to do