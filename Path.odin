package civ_clone

import "core:fmt"
import rl "vendor:raylib"
import m "core:math"
import l "core:math/linalg"

//need to account of the line drawing around the warping
/*
dist::proc(qr1,qr2:[2]int)->(f32){ //this one work
    temp:[2]int=qr1-qr2
    temp2:[3]f32
    temp2[0] = cast(f32)temp[0]
    temp2[1] = cast(f32)temp[1]
    temp2[2] = -1*temp2[0] - temp2[1]
    return (m.abs(temp2[0]) + m.abs(temp2[1]) + m.abs(temp2[2]))/2
}
alt_dist::proc(qr1,qr2:[2]int) -> (f32){
    a:int = abs(qr1[0]-qr2[0])
    b:int = abs(qr1[1]-qr2[1])
    c:int = abs((-qr1[0]-qr1[1]) - (-qr2[0]-qr2[1]))
    if(a > b && a > c){
        return auto_cast a
    }else if (b > a && b > c){
        return auto_cast b
    }else{
        return auto_cast c
    }
}
alt_dist2::proc(qr1,qr2:[2]int) -> (f32){
    temp:[2]int=qr1-qr2
    temp2:[3]f32
    temp2[0] = cast(f32)temp[0]
    temp2[1] = cast(f32)temp[1]
    temp2[2] = -1*temp2[0] - temp2[1]
    return l.dot(temp2, temp2)
}
man_distance::proc(qr1,qr2:[2]int) ->(f32){
    a:f32 = auto_cast abs(qr1[0]-qr2[0])
    b:f32 = auto_cast abs(qr1[1]-qr2[1])
    c:f32 = auto_cast abs((-qr1[0]-qr1[1]) - (-qr2[0]-qr2[1]))
    return (a + b + c)/2
}

lerp::proc(a,b:f32,t:f32) ->(f32){
    return cast(f32)(a) + cast(f32)((b-a)) * t
}

lerp_axial::proc(qr1,qr2:[2]int, t:f32) -> ([2]int){
    out:[2]int
    budgex:f32 = 0.01
    budgey:f32 = -0.01
    if(t > 0){
        budgex *= -1
        budgey *= -1
    }
    out[0] = round(lerp(auto_cast (qr1[0]), auto_cast qr2[0], t)+budgex)
    out[1] = round(lerp(auto_cast qr1[1],auto_cast qr2[1], t)+budgey)
    return out   
}
/*
axial_line_draw::proc(world:^[160][160]tile,qr1,qr2:[2]int,num_x:int){
    n:f32 = dist(qr1, qr2)
    fmt.println(n)
    res:[dynamic][2]int
    for i in 0..<auto_cast(n){
        append(&res, lerp_axial(qr1, qr2, (1.0/n) * auto_cast(i)))
    }
    append(&res, qr2)
    cord:[2]int
    for i in 0..<len(res){
        cord = warp_hex(res[i],num_x)
        cord = hex_to_index_unsafe(cord)
        world[cord[0]][cord[1]].color = rl.PINK
    }
}
*/

get_movability::proc(world:^World_Space, qr:[2]int)->(int){
    cord:[2]int = hex_to_index_unsafe(warp_hex(qr, world.num_x))
    if(cord[1]<0 || cord[1] >=world.num_y){
        return -1
    }
    return get_tile(world, cord).moveable
}

get_next_straight::proc(qr1, qr2:[2]int)->([2]int){
    n:f32 = dist(qr1, qr2)
    return lerp_axial(qr1, qr2, (1.0/n))
}

rotate_60_around::proc(qr1,qr2:[2]int, clockwise:bool) -> ([2]int){
    delta:[2]int = qr2-qr1
    delta = rotate_60(delta, clockwise)
    new:[2]int = qr1 + delta
    return new
}
rotate_60::proc(qr:[2]int,clockwise:bool) -> ([2]int){
    // [ q  r  s] //for counter clockwise 60 degree rotation
    // [-s -q -r]
    // [q r] => [q r s] 
    // [q r] => [q r (-q -r)]
    // since i am working in axial space, i just drop the 3d compent from cube cords
    // [ q  r] =>
    // [-s  q] where s = (-q -r) 

    //for counter clockwise
    // [ q  r  s]
    // [-r -s  q]
    //which goes to
    // [ q  r]
    // [-r -s] where s = (-q -r)
    out:[2]int
    s:int = (-1*qr[0]) - (qr[1])
    if(clockwise){
        out[0] = -1*qr[1]
        out[1] = -1*s 
    }else{
        out[0] = -1*s
        out[1] = -1*qr[0]
    }
    return out
}

/*
so in terms of fixes, i need to add a check to see where the next selected tile has aviable moves
if the next tile does not have any avaible moves then i add that tile to a a no move list
this no move list is a parallel list to new_path, where in all the tiles from new path are also included 
in the no move list. the other items that are added are the prior mentioned next selected tile which has no moves



*/

is_valid::proc(world:^[160][160]tile, qr:[2]int, num_x,num_y:int)->(bool){\
    if(get_movability(world, qr, num_x, num_y) == 0){
        return false;
    }
    neighbors:[7][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1},{0,0}};
    valid:bool = false
    count:int=0
    cord:[2]int
    for i in 0..<7{
        //valid = !(in_group(path, qr+neighbors[i]))
        valid = valid ||  (get_movability(world, qr+neighbors[i], num_x, num_y) > 0)
        // need to change this on a per unit basis, 
    }
    return valid
}

valid_steps::proc(world:^[160][160]tile, qr:[2]int, path,removed:^[dynamic][2]int,num_y, num_x:int)->([dynamic][2]int){
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}}
    valid_tiles:[dynamic][2]int
    for i in 0..<6{
        if(is_valid(world, qr+neighbors[i], num_x, num_y) && !in_group(path, qr+neighbors[i]) && !in_group(removed, qr+neighbors[i])){
            append(&valid_tiles, qr+neighbors[i])
        }
    }
    return valid_tiles
}
valid_back_steps::proc(world:^[160][160]tile, qr:[2]int, path,new_path,removed:^[dynamic][2]int,num_y, num_x:int)->([dynamic][2]int){
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}}
    valid_tiles:[dynamic][2]int
    for i in 0..<6{
        if((in_group(path, qr+neighbors[i])) && (!in_group(new_path, qr+neighbors[i]) && (!in_group(removed, qr + neighbors[i])))){
            append(&valid_tiles, qr+neighbors[i])
        }
    }
    return valid_tiles
}


path_finder::proc(world:^World_Space, start, finsih:[2]int) -> ([dynamic][2]int){
    empty:[dynamic][2]int
    if(get_movability(world, finsih) == 0){
        return empty
    }
    new_path,removed:[dynamic][2]int
    path_cost:[dynamic]f32
    curr:[2]int = start
    n:f32= dist(curr, finsih)
    f:[dynamic]f32
    curr_dist:f32 = 0
    append(&new_path, start)
    fmt.println("forward")
    its:int
    for (n>0) {
        candidates:[dynamic][2]int
        defer delete(candidates)
        candidates = valid_steps(world, curr,&new_path, &removed, num_y, num_x)
        if(len(candidates) == 0){//now needs to backtrack
            if(len(new_path) <=1){
                fmt.println("no path")
                return new_path
            }
            append(&removed,curr)
            curr = new_path[len(new_path)-2]
            curr_dist = curr_dist - (auto_cast get_movability(world,curr, num_x, num_y))
            pop(&new_path)
        }else{
            for i in 0..<len(candidates){
                temp:f32 = ((alt_dist(candidates[i],finsih)*1)+(dist(candidates[i], finsih)*1) + (alt_dist2(candidates[i], finsih)*1))/2   + auto_cast get_movability(world,candidates[i], num_x, num_y) + (curr_dist)
                append(&f, temp)
            }
            index:int=0
            for i in 0..<len(f){
                if (f[index] > f[i]){
                    index = i
                }
            }
            curr = candidates[index]
            clear(&candidates)
            clear(&f)
            append(&new_path, curr)
            n = dist(curr, finsih)
            curr_dist = curr_dist + (auto_cast get_movability(world,curr, num_x, num_y))
            append(&path_cost,curr_dist)
        }
        its += 1
        if(its> 10000){
            return empty
        }
    }
    clear(&removed)
    //append(&new_path, finsih)
    //return new_path
    its = 0
    final_path:[dynamic][2]int
    curr = finsih
    curr_dist = 0
    n = dist(curr, start)
    fmt.println("backwards")
    //fmt.println("curr path before Adjust: ", new_path)
    for n >0{//for back tracking if the candidate list is len > 1 then i I need to add, it to a new removed list, where that new removed list includes those
        append(&final_path, curr)
        candidates:[dynamic][2]int
        defer delete(candidates)
        candidates = valid_back_steps(world, curr,&new_path,&final_path,&removed, num_y, num_x)
        if(len(candidates) == 0){//now needs to backtrack
            if(len(final_path) == 0){return new_path}
            //fmt.println("pop goes the weasel")
            //fmt.println("final path: ", final_path)
            //fmt.println("curr path: ", new_path)
            //return new_path
            clear(&removed)
            append(&removed, curr)
            curr = new_path[len(new_path)-1]
            index:int 
            for i in 0..<len(final_path){
                if(curr == final_path[i]){
                    index = i
                }
            }
            remove_range(&final_path, index, len(final_path)-1)
        }else if (len(candidates) == 1){
            pop(&new_path)
            curr = candidates[0]
            n = dist(curr, start)
            curr_dist = curr_dist + (auto_cast get_movability(world,curr, num_x, num_y))
            append(&removed, curr)
            //fmt.println(new_path)
            
        }else{
            for i in 0..<len(candidates){
                temp:f32 = (dist(candidates[i],start)*0)+(alt_dist(candidates[i], start)*0) + (alt_dist2(candidates[i], start)*1) + auto_cast get_movability(world,candidates[i], num_x, num_y) + (curr_dist)
                append(&f, temp)
            }
            index:int=0
            for i in 0..<len(f){
                if (f[index] > f[i]){
                    index = i
                }
            }
            
            curr = candidates[index]
            append(&removed, curr)            
            n = dist(curr, start)
            curr_dist = curr_dist + (auto_cast get_movability(world,curr, num_x, num_y))
        }
        clear(&candidates)
        clear(&f)
        its += 1
        if(its> 10000){
            return empty
        }
    }
    append(&final_path, start)
    return final_path
    

}

cull_path::proc(world:^[160][160]tile, path:[dynamic][2]int)->([dynamic][2]int){
    return path 
}
*/