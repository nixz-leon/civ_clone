package civ_clone
import r "core:math/rand"
import rl "vendor:raylib"
import "core:fmt"
import "core:slice"

get_expandable::proc(world:^[160][160]tile,qr:[2]int, curr_land,expandable:^[dynamic][2]int, num_x,num_y:int, existing_land:..[dynamic][2]int) -> ([dynamic][2]int){
    valid:[dynamic][2]int
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}}
    simple_check:int
    temp:[2]int
    
    skip: for i in 0..<6{
        fresh:bool=false
        temp = qr+neighbors[i]
        temp = warp_hex(temp, num_x)
        //fmt.println(temp)
        if((temp[1] >= num_y) && (temp[1] <0)){break skip;}
        if (!in_group(curr_land, temp) && !in_group(expandable, temp)){
            for &group in existing_land{
                fresh = fresh || in_group(&group, temp+neighbors[i])
            }
            fresh = !fresh
            if(fresh){
                append(&valid, temp)
            }
        }
        //if (in_group(expandable, temp)){break skip;}
        
    }
    return valid
}

get_expandable_coast::proc(world:^[160][160]tile,qr:[2]int, land,curr_coast,expandable:^[dynamic][2]int, num_x,num_y:int, existing_land:..[dynamic][2]int) -> ([dynamic][2]int){
    valid:[dynamic][2]int
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}}
    simple_check:int
    temp:[2]int
    
    skip: for i in 0..<6{
        fresh:bool=false
        temp = qr+neighbors[i]
        temp = warp_hex(temp, num_x)
        //fmt.println(temp)
        if((temp[1] >= num_y) && (temp[1] <0)){break skip;}
        if (!in_group(land, temp) && !in_group(expandable, temp)&&!in_group(curr_coast, temp)){
            for &group in existing_land{
                fresh = fresh || in_group(&group, temp+neighbors[i])
            }
            fresh = !fresh
            if(fresh){
                append(&valid, temp)
            }
        }
        //if (in_group(expandable, temp)){break skip;}
        
    }
    return valid
}

remove_dups::proc(group:^[dynamic][2]int){
    for a in group{
        for i in len(group)-1..=0{
            if(a == group[i]){
                ordered_remove(group, i)
            }
        }
    }
}
clean_up::proc(world:^[160][160]tile,group,land_mass:^[dynamic][2]int)->([dynamic][2]int){
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}}
    to_be_removed:[dynamic][2]int
    out:[dynamic][2]int
    defer delete(to_be_removed)
    for a in group{
        count:int=0
        count2:int=0
        for b in neighbors{
            if(in_group(group, a+b)){
                count+=1
            }
            if(in_group(land_mass, a+b)){
                count2+=1
            }
        }
        //fmt.print("tile: ", a)
        //fmt.println("count: ",count)
        if((count < 4 && count2 >0)){
            append(&to_be_removed,a)
        }
    }
    //fmt.println("TO remove ",len(to_be_removed))
    for a in group{
        if(!in_group(&to_be_removed, a)){
            append(&out, a)
        }
    }
    append_elems(land_mass, ..to_be_removed[:])
    return out
}

gen_continent::proc(world:^[160][160]tile, num_x, num_y, num_conts:int){
    conts:[dynamic][dynamic][2]int
    defer delete(conts[:])
    num_walks:int= auto_cast (f32(num_x * num_y)*(1/(12-auto_cast num_conts)))

    qr:[2]int
    cord:[2]int
    start:[2]int
    for i in 0..<num_conts{
        init:[dynamic][2]int
        defer delete(init)
        start = {r.int_max(num_x),r.int_max((num_y/2))+(num_y/4)}
        fmt.println(start)
        qr=warp_hex(start, num_x)
        fmt.println(qr)
        cord = hex_to_index_unsafe(qr)
        world[cord[0]][cord[1]].moveable = 1
        //append(&init, qr)
        gen_land_mass(world, start, num_walks/num_conts, num_x, num_y, ..(conts[:]))
        append(&conts, init)   
    }
    /*
    fmt.println("conts: ", conts)
    for i in 0..<len(conts){
        fmt.println(conts[i][0])
        temp:[2]int = conts[i][0]
        gen_land_mass(world, temp, 100, num_x, num_y, ..(conts[:]))
    }
    */


    
}

gen_land_mass::proc(world:^[160][160]tile, start:[2]int, walks,num_x, num_y:int, existing_land:..[dynamic][2]int)->([dynamic][2]int){
    expandable:[dynamic][2]int
    defer delete(expandable)
    land_mass:[dynamic][2]int
    candidates:[dynamic][2]int
    defer delete(candidates)
    curr:[2]int
    walked:int=0
    append(&expandable, start)
    for walked<walks{
        clear(&candidates)
        index:int = r.int_max(len(expandable))
        curr= expandable[index]
        append(&land_mass, curr)
        candidates = get_expandable(world, curr, &land_mass,&expandable,num_x, num_y, ..existing_land)
        append_elems(&expandable, ..candidates[:])
        unordered_remove(&expandable, index)
        walked += 1
    }
    ind:int=len(expandable)
    for i in 0..<1{
    temp:[dynamic][2]int
    for tile in expandable{
        clear(&candidates)
        candidates = get_expandable_coast(world, tile, &land_mass, &expandable, &temp, num_x, num_y, ..existing_land)
        append_elems(&temp, ..candidates[:])
    }
    append_elems(&expandable, ..temp[:])
    }

    //need to add an exapand coast function before clean up, so coast/shallow water tiles remain, and cleaning up the map 
    fmt.println(len(expandable))
    expandable = clean_up(world, &expandable, &land_mass)
    fmt.println(len(expandable))

    remove_dups(&land_mass)
    for a in land_mass{
        b:= hex_to_index(warp_hex(a, num_x), num_x, num_y)
        world[b[0]][b[1]].color = rl.LIME
        world[b[0]][b[1]].moveable = 2


    }
    for a in expandable{
        b:= hex_to_index(warp_hex(a, num_x), num_x, num_y)
            if(world[b[0]][b[1]].moveable < 1){
            world[b[0]][b[1]].color = rl.SKYBLUE
            world[b[0]][b[1]].moveable = 1
        }
        
    }
    b:= hex_to_index(warp_hex(start, num_x), num_x, num_y)
    world[b[0]][b[1]].color = rl.GOLD
    fmt.println(len(expandable))
    fmt.println(len(land_mass))
    append(&land_mass, ..expandable[:])
    return land_mass
}
