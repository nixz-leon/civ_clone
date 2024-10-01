package civ_clone
import r "core:math/rand"
import rl "vendor:raylib"
import "core:fmt"
import "core:slice"

get_expandable::proc(world:^World_Space,curr_land,expandable:^[dynamic][2]int, qr:[2]int, existing_land:..[dynamic][2]int) -> ([dynamic][2]int){
    valid:[dynamic][2]int
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}}
    temp:[2]int
    skip: for i in 0..<6{
        fresh:bool=false
        temp = qr+neighbors[i]
        temp = warp_hex(temp, world.num_x)
        if((temp[1] >= world.num_y) && (temp[1] <0)){break skip;}
        if (!in_group(curr_land, temp) && !in_group(expandable, temp)){
            for &group in existing_land{
                fresh = fresh || in_group(&group, temp+neighbors[i])
            }
            fresh = !fresh
            if(fresh){
                append(&valid, temp)
            }
        }      
    }
    return valid
}

get_expandable_coast::proc(world:^World_Space, land,curr_coast,expandable:^[dynamic][2]int,qr:[2]int, existing_land:..[dynamic][2]int) -> ([dynamic][2]int){
    valid:[dynamic][2]int
    neighbors:[6][2]int = {{1,0},{1,-1},{0,1},{-1,1},{-1,0},{0,-1}}
    simple_check:int
    temp:[2]int
    
    skip: for i in 0..<6{
        fresh:bool=false
        temp = qr+neighbors[i]
        temp = warp_hex(temp, world.num_x)
        //fmt.println(temp)
        if((temp[1] >= world.num_y) && (temp[1] <0)){break skip;}
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
clean_up::proc(world:^World_Space,group,land_mass:^[dynamic][2]int)->([dynamic][2]int){
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
    temp:=land_mass^
    append_elems(&temp, ..to_be_removed[:])
    land_mass^=temp
    return out
}

gen_continent::proc(world:^World_Space,  num_conts:int){
    conts:[dynamic][dynamic][2]int
    num_walks:int= auto_cast (f32(world.num_x * world.num_y)*0.02)
    qr:[2]int
    cord:[2]int
    start:[2]int
    for i in 0..<num_conts{
        fmt.println(i)
        init:[dynamic][2]int
        start = {r.int_max(world.num_x),r.int_max((world.num_y/2))+(world.num_y/4)}
        qr = warp_hex(index_to_hex(start), world.num_x)
        fmt.println("start loc: ", qr)
        init = gen_land_mass(world, start,num_walks, ..(conts[:]))   
    }
}


exclude_from_groups::proc(inital_group:^[dynamic][2]int, groups:..[dynamic][2]int){
    temp:[dynamic][2]int
    start:int = len(temp)
    for i in inital_group{
        valid:bool=false
        for &group in groups{
            valid = valid || in_group(&group, i)
        }
        valid = !valid
        if(valid){
            append(&temp, i)
        }
    }
    inital_group^ = temp
}
exclude_tile_from_group::proc(group:^[dynamic][2]int, qr:[2]int){
    temp:= group^
    start:int = len(temp)
    //fmt.println("start")
    for a in 0..<start{
        if(qr == temp[a]){ordered_remove(&temp, a);break}
    }
    group^= temp
}


//time for a new_land mass gen function
gen_land_mass::proc(world:^World_Space, start:[2]int, walks:int, existing_land:..[dynamic][2]int)->([dynamic][2]int){
    land_mass,expandable,candidate:[dynamic][2]int
    defer delete(land_mass);defer delete(expandable);defer delete(candidate)
    append_elems(&land_mass, ..(get_neighbors(world, start))[:])
    exclude_from_groups(&land_mass, ..existing_land[:])
    append(&land_mass, start)

    for a in land_mass{
        clear(&candidate)
        candidate = get_neighbors(world, a)
        exclude_from_groups(&candidate, land_mass,expandable)
        exclude_from_groups(&candidate, ..existing_land[:])
        append_elems(&expandable, ..candidate[:])
    }
    for i in 0..<walks{
        clear(&candidate)
        index:int = r.int_max(len(expandable))
        tile:[2]int = expandable[index]
        candidate=get_neighbors(world, tile)
        exclude_from_groups(&candidate, land_mass,expandable)
        exclude_from_groups(&candidate, ..existing_land[:])
        append_elems(&expandable, ..candidate[:])
        exclude_tile_from_group(&expandable, tile)
        append(&land_mass, tile)

    }
    expandable = clean_up(world, &expandable, &land_mass)
    for a in land_mass{
        clear(&candidate)
        candidate = get_neighbors(world, a)
        exclude_from_groups(&candidate, land_mass,expandable)
        exclude_from_groups(&candidate, ..existing_land[:])
        append_elems(&expandable, ..candidate[:])
    }
    for a in land_mass{
        set_tile_color(world, a, rl.LIME)
        set_tile_terrain_s(world, a, 2, .plains)
    }
    for a in expandable{
        if(get_movability(world, a) < 2){
            set_tile_color(world, a, rl.SKYBLUE)
            set_tile_terrain_s(world, a, 1, .coastal)
        }
    }
    fmt.println(land_mass)
    fmt.println(expandable)

    return land_mass
}

