package civ_clone
import r "core:math/rand"
import rl "vendor:raylib"
import "core:fmt"
import "core:slice"
//need to rethink this generation method
//this generation method is great when 

gen_continent_alt::proc(world:^[160][160]tile, land_masses,num_x,num_y:int){
    //this is going to be the game of life approach 
    land_mass:tile_group
    defer delete(land_mass.indicies)
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}};
    qr:[2]int
    cord:[2]int
    start:[2]int
    for i in 0..<land_masses{
        start = {r.int_max(num_x),r.int_max((num_y/2))+(num_y/4)}
        qr=warp_hex(start, num_x)
        cord = hex_to_index_unsafe(qr)
        world[cord[0]][cord[1]].color = rl.LIME 
        world[cord[0]][cord[1]].moveable = 1
        for j in 0..<6{
            qr=warp_hex(start + neighbors[j], num_x)
            append(&land_mass.indicies, qr)
            cord = hex_to_index_unsafe(qr)
            world[cord[0]][cord[1]].color = rl.LIME 
        }
    }
    lenght:int=len(land_mass.indicies)
    length2:int
    index,i2:int
    num_walks:int= auto_cast (f32(num_x * num_y)*0.5) //this 0.5 percentage might be subject to change dependent on world type
    fmt.println(num_walks)
    tryagain:bool = true
    valid:[dynamic][2]int
    defer delete(valid)
    remove:[dynamic][2]int
    defer delete(remove)
    for i in 0..<num_walks*land_masses/2{
            index = r.int_max(lenght)
            qr = warp_hex(land_mass.indicies[index] , num_x) // the valid neighbor might be need to be reworked to 
            valid = get_valid(world, land_mass.indicies,qr, num_x, num_y)
            for (len(valid)<3){
                clear(&valid)
                index = r.int_max(lenght)
                qr = warp_hex(land_mass.indicies[index] , num_x) // the valid neighbor might be need to be reworked to 
                valid = get_valid(world,land_mass.indicies ,qr, num_x, num_y)
            }
            length2 = len(valid)

            i2 = r.int_max(length2)
            append(&land_mass.indicies, valid[i2])
            lenght=len(land_mass.indicies)
            /*
            remove = remove_surrounded(world, land_mass.indicies, num_x, num_y)
            clear(&land_mass.indicies)
            land_mass.indicies = remove
            */
            clear(&remove)
            clear(&valid)
    }
    for i in 0..<len(land_mass.indicies){
        cord = hex_to_index(land_mass.indicies[i], num_x, num_y)
        world[cord[0]][cord[1]].color = rl.LIME
        world[cord[0]][cord[1]].moveable = 1 
    }
}


