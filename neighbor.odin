package civ_clone
import "core:fmt"
import rl "vendor:raylib"

get_neighbor::proc(qr:[2]int, num_x,num_y:int)->([dynamic][2]int){
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}};
    ns:[dynamic][2]int
    qr_n:[2]int
    n: for i in 0..<6{
        qr_n = warp_hex((qr+neighbors[i]), num_x)
        if (qr_n[1] >= num_y || qr_n[1] < 0){
            break n
        }
        append(&ns, qr_n)
    }
    return ns
}

is_surrounded::proc(world:^[160][160]tile,qr:[2]int ,num_x, num_y:int) -> (bool){
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}};
    cord:[2]int
    num_green:int=0
    n: for i in 0..<6{
        cord = warp_hex((qr+neighbors[i]), num_x)
        if(cord[1] < 0){
            break n
        }else if (cord[1] >= num_y){
            break n
        }
        cord = hex_to_index_unsafe(cord)
        if(world[cord[0]][cord[1]].color == rl.LIME){
            num_green +=1
        }
    }
    cord = warp_hex(qr, num_x)
    cord = hex_to_index_unsafe(qr)
    if(num_green == 6 && world[cord[0]][cord[1]].color == rl.LIME){
        return true
    }
    return false
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

get_valid::proc(world:^[160][160]tile, tiles:[dynamic][2]int ,qr:[2]int, num_x, num_y:int) -> ([dynamic][2]int){
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}};
    cord:[2]int
    valid_tiles:[dynamic][2]int
    n: for i in 0..<6{
        qr := warp_hex((qr+neighbors[i]), num_x)
        if(qr[1] >= num_y || qr[1] < 0){
            break n
        }
        cord = hex_to_index(qr,num_x, num_y)
        if(world[cord[0]][cord[1]].color != rl.LIME ){ //&& !(in_group(tiles, qr))
            append(&valid_tiles, qr)
        }
    }
    return valid_tiles
}
remove_surrounded::proc(world:^[160][160]tile, tiles:[dynamic][2]int, num_x,num_y:int) -> ([dynamic][2]int){
    to_remove:[dynamic][2]int
    copy:[dynamic][2]int = tiles
    defer delete(to_remove)
    for i in 0..<len(tiles){
        to_remove = surrounded_neighbors(world,tiles[i], num_x, num_y )
        if(len(to_remove) > 0){
            for o in 0..<len(to_remove){
                for j in 0..<len(copy){
                    if(copy[j] == to_remove[o]){
                        ordered_remove(&copy, j)
                    }
                }
            }
        } 
    }
    return copy
}

surrounded_neighbors::proc(world:^[160][160]tile, qr:[2]int, num_x,num_y:int) -> ([dynamic][2]int){
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}};
    qr_n:[2]int
    surrounded:[dynamic][2]int
    n: for i in 0..<6{
        qr_n = warp_hex((qr+neighbors[i]), num_x)
        //fmt.println(qr_n)
        if(is_surrounded(world, qr_n, num_x, num_y)){
            append(&surrounded, qr_n)
        }
    }
    return surrounded
}