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
            append(&valid, temp)
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
        if((temp[1] >= world.num_y) && (temp[1] <0)){break skip;}
        if (!in_group(land, temp) && !in_group(expandable, temp)&&!in_group(curr_coast, temp)){
            append(&valid, temp)
        }
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
        if((count < 5 && count2 >0)){
            append(&to_be_removed,a)
        }
    }
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




exclude_tile_from_group::proc(group:^[dynamic][2]int, qr:[2]int){
    temp:= group^
    start:int = len(temp)
    for a in 0..<start{
        if(qr == temp[a]){ordered_remove(&temp, a);break}
    }
    group^= temp
}



group_union::proc(inital_group:^[dynamic][2]int, groups:..[dynamic][2]int){
    temp:[dynamic][2]int
    for group in groups{
        valid:bool=false
        for i in group{
            if(!in_group(inital_group, i )){
                append(&temp, i)
            }
        }
    }
    append(inital_group, ..temp[:])
}

group_intersection::proc(inital_group:^[dynamic][2]int, groups:..[dynamic][2]int){
    temp:[dynamic][2]int
    for i in inital_group{
        valid:bool=false
        for &group in groups{//this implies already that i is in the intial group 
            valid = valid || in_group(&group, i)
        }
        if(valid){
            append(&temp, i)
        }
    }
    inital_group^ = temp
}

group_difference::proc(inital_group:^[dynamic][2]int, groups:..[dynamic][2]int){
    temp:[dynamic][2]int
    for i in inital_group{
        valid:bool=false
        for &group in groups{
            valid = valid || in_group(&group, i)
        }
        valid = !valid // invert valid, exlucision from inital group would be the compliment in respect to inital group as intersection
        if(valid){
            append(&temp, i)
        }
    }
    inital_group^ = temp
}


//time for a new_land mass gen function
gen_land_mass::proc(world:^World_Space, start:[2]int, walks:int, existing_land:..[dynamic][2]int)->([dynamic][2]int){
    land_mass,expandable,candidate,mountains:[dynamic][2]int
    defer delete(land_mass);defer delete(expandable);defer delete(candidate);defer delete(mountains)
    append_elems(&land_mass, ..(get_neighbors(world, start))[:])
    group_difference(&land_mass, ..existing_land[:])
    append(&land_mass, start)

    for a in land_mass{
        clear(&candidate)
        candidate = get_neighbors(world, a)
        group_difference(&candidate, land_mass,expandable)
        group_difference(&candidate, ..existing_land[:])
        append_elems(&expandable, ..candidate[:])
    }

    for i in 0..<walks{
        clear(&candidate)
        if(len(expandable)!= 0){
        index:int = r.int_max(len(expandable))
        tile:[2]int = expandable[index]
        candidate=get_neighbors(world, tile)
        group_difference(&candidate, land_mass,expandable)
        temp:=candidate
        group_intersection(&temp, ..existing_land[:])
        group_difference(&candidate, ..existing_land[:])
        append_elems(&expandable, ..candidate[:])
        exclude_tile_from_group(&expandable, tile)
        append(&land_mass, tile)
        append(&mountains, ..temp[:])
        }else{
            break
        }

    }
    expandable = clean_up(world, &expandable, &land_mass)
    for a in land_mass{
        clear(&candidate)
        candidate = get_neighbors(world, a)
        group_difference(&candidate, land_mass,expandable)
        temp:=candidate
        group_intersection(&temp, ..existing_land[:])
        group_difference(&candidate, ..existing_land[:])
        append_elems(&expandable, ..candidate[:])
        append(&mountains, ..temp[:])
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
    for a in mountains{
        set_tile_color(world, a, rl.BROWN)
        set_tile_terrain_s(world, a, 1, .mountain)
    }
    return land_mass
}

gen_continent::proc(world:^World_Space,  num_conts:int){
    conts:[dynamic][dynamic][2]int
    num_walks:int= auto_cast (f32(world.num_x * world.num_y)*0.02)
    qr:[2]int
    for i in 0..<num_conts{
        init:[dynamic][2]int
        qr = {r.int_max(world.num_x),r.int_max((world.num_y/2))+(world.num_y/4)}
        qr = warp_hex(index_to_hex(qr), world.num_x)
        init = gen_land_mass(world,qr,num_walks, ..(conts[:]))
        append_elems(&conts, init)   
    }
}

gen_continent_test::proc(world:^World_Space){
    start_loc:[dynamic][2]int={{30,30},{30,40},{40,40},{40,30}}
    conts:[dynamic][dynamic][2]int
    for a in start_loc{
        init:[dynamic][2]int
        init = gen_land_mass(world, a, 100,..(conts[:]))
        append_elems(&conts, init)
        set_tile_color(world, a, rl.GOLD)

    }
}


//I have two paths for continent generation, I either try and do a plates based approach where I place like 5 spawn
//points in closish proximity, and then when expandable hits another land mass, it gets added to a potential mountian list
//from this mountain list it can do a random expansion, it won't account for rivers though
//for rivers i set the spawn point to be a mountain tile, and then check for the closest river, get a generalized vector
// and do a semi random walk in the direction of that vector
//then it gets tricky with biome, but that is a latter question


//Alternatively I could start looking into using perlin noise, and doing it that way. have issues with out they look
//but might be easier in the long run 