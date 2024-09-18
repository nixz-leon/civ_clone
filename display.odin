package civ_clone

import "core:fmt"
import m "core:math"
import l "core:math/linalg"
import r "core:math/rand"
import rl "vendor:raylib"
import s "core:strings"
import sc "core:strconv"



disp_tile::proc(item:tile, size:f32, warp_range,y_range,start_x,start_y,curr_x,curr_y:int, texture:rl.Texture2D){
    //fmt.println(curr_x, start_x, warp_range)
    scale:= (((size*1.9)))/(1025)
    r:f32 = auto_cast item.r
    q:f32 = auto_cast item.q
    x_pos:= size * ((Root_Three*q)+((Root_Three*0.5)*r))
    y_pos:= size * (1.5*r)
    x_offset:f32 = auto_cast (curr_x) - auto_cast(warp_range)/2
    disp_x:f32= x_pos+x_offset//relative to center
    disp_y:f32= y_pos+ (auto_cast (curr_y-(y_range/2)))
    
    disp_x = warp_x(disp_x, warp_range)

    disp_x = (disp_x + (auto_cast (start_x - warp_range/2 )))/size
    disp_y = (disp_y + (auto_cast start_y) )/size
    //rl.DrawPoly({disp_x,disp_y}, 6, size-1, 30, item.color)
    //rl.DrawPolyLines({disp_x,disp_y}, 6, size, 30, item.border)
    rl.DrawCylinder({disp_x, -1, disp_y}, 1, 1, 4, 6, item.color)
    rl.DrawCylinderWires({disp_x, -0.99, disp_y}, 1, 1, 4, 6, item.border)
    //rl.DrawTextureEx(texture, {disp_x, disp_y}, 0, scale, item.color)
    /* 
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
    */
    
}

disp_tiles::proc(world:^[160][160]tile,tiles:[dynamic][2]int, size:f32, num_x, warp_range,y_range,start_x,start_y,curr_x,curr_y:int, color:rl.Color,texture:rl.Texture2D){
    temp:[2]int
    for i in 0..<len(tiles){
        temp = hex_to_index_unsafe(warp_hex(tiles[i], num_x))
        item:tile = world[temp[0]][temp[1]]
        scale:= (((size*1.9)))/(1025)
        r:f32 = auto_cast item.r
        q:f32 = auto_cast item.q
        x_pos:= size * ((Root_Three*q)+((Root_Three*0.5)*r))
        y_pos:= size * (1.5*r)
        x_offset:f32 = auto_cast (curr_x) - auto_cast(warp_range)/2
        disp_x:f32= x_pos+x_offset//relative to center
        disp_y:f32= y_pos+ (auto_cast (curr_y-(y_range/2)))
        
        disp_x = warp_x(disp_x, warp_range)

        disp_x = (disp_x + (auto_cast (start_x - warp_range/2 )))/size
    disp_y = (disp_y + (auto_cast start_y) )/size
    //rl.DrawPoly({disp_x,disp_y}, 6, size-1, 30, item.color)
    //rl.DrawPolyLines({disp_x,disp_y}, 6, size, 30, item.border)
    rl.DrawCylinder({disp_x, -1, disp_y}, 1, 1, 4, 6, item.color)
    rl.DrawCylinderWires({disp_x, -0.99, disp_y}, 1, 1, 4, 6, item.border)
        /*
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
        */
    }
}