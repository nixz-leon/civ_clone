package civ_clone

import rl "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:strings"
//import "core:c/libc"

save_game::proc(world:^World_Space, file_name:string){
    s: Serializer
    serializer_init_writer(&s)
    when ODIN_DEBUG {
        s.debug.print_scope = true
    }
    serialize(&s, world)
    fd,err1:=os.open(file_name, 0x00040)
    os.write(fd, s.data[:])
    os.close(fd)


}


load_game::proc(world:^World_Space, file_name:string){
    fd,err1:=os.open(file_name)
    data,err:=os.read_entire_file(fd)
    os.close(fd)
    s: Serializer
    serializer_init_reader(&s, data)
    serialize(&s, world) 
}






