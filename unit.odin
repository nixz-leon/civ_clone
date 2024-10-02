package civ_clone


unit::struct{
    can_walk:bool,
    can_swim:sail,
    health:int,
    move_dist:int,
    path:[dynamic][2]int
}

units::enum{
    settler, 
    outpost_founder,
    trader, 



}

//
init_unit::proc(kind:units, start_loc_qr:[2]int)->(unit){
    temp:unit

    return temp
}

//I will need to rework the path function from path.odin to adhere to per unit movement restrictions.
//the hueristic should be optimized for turn time rather than abject shortest physical distance
//this means first doing a check for if it is water or land, and from there checking if a thing can move on that or not
//from there keep a running total of what turn the unit would be on, and then choose the tile that maximizes movement per turn
//I might also want to rework everything to move withing view distance, this 
find_path::proc(world:World_Space, unit:^unit)
