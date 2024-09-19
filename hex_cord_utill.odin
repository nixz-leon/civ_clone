package civ_clone
import l "core:math/linalg"

warp_x::proc(x: f32, warp_range:int) -> (n_x:f32){
    new_x:= x
    if((-1*new_x) > auto_cast(warp_range/2)){
        new_x = auto_cast ((warp_range/2) + (warp_range + cast(int)x)) -1
    }else{
        new_x = auto_cast ((warp_range/2 + (cast(int)x))%warp_range) +1
    }
    return new_x
}

pix_hex::proc(pix:[2]f32, size:f32) -> (hex:[2]int){
    mat:l.Matrix2x2f32 = {(Root_Three/3.0),(-1.0/3.0),0,(2.0/3.0)} 
    temp:[2]f32 = mat*pix
    temp = temp/size
    out:[2]int
    if(temp[0] < 0){
        out[0] = auto_cast (temp[0]-0.5)
    }else{
        out[0] = auto_cast (temp[0]+0.5)
    }
    out[1] = auto_cast (temp[1] + 0.5)
    return out
}
hex_to_index::proc(hex:[2]int, num_x,num_y:int) -> (cord:[2]int){
    cord[0] = hex[0] + ((hex[1]+(hex[1]&1))/2)
    cord[1] = hex[1] 
    if(cord[0] == num_x){ //extra bounds checking, to deal with the warping of the baord
        cord[0] = num_x -1
    }
    if(cord[0] <0 ){
        cord[0] =0
    }
    if(cord[1] == num_y){
        cord[1] = num_y -1
    }
    if(cord[1] < 0){
        cord[1] = 0
    }
    return cord
}
hex_to_index_unsafe::proc(hex:[2]int)->(cord:[2]int){
    cord[0] = hex[0] + ((hex[1]+(hex[1]&1))/2)
    cord[1] = hex[1] 
    return cord
}
index_to_hex::proc(index:[2]int) -> (hex:[2]int){
    hex[0]= index[0] - ((index[1] + (index[1]&1))/2)
    hex[1]= index[1]
    return hex
}
warp_hex::proc(hex:[2]int, num_x:int) -> (nhex:[2]int){
    index:= hex_to_index_unsafe(hex)
    if(index[0] >= num_x){
        index[0] = index[0] - num_x
    }else if (index[0] < 0){
        index[0] = num_x + index[0]
    }
    return index_to_hex(index)    
}


pix_index::proc(a:[2]int,num_x:int)->([2]int){
    return hex_to_index_unsafe(warp_hex(a, num_x))
}