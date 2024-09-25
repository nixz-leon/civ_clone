package civ_clone

import rl "vendor:raylib"
import "core:fmt"
import "core:encoding/cbor"
import "base:intrinsics"
import "core:reflect"
import "core:os"
import "core:strings"
//import "core:c/libc"

save_game::proc(world:^World_Space){
    
    RAW_TAG_NR :: 200
    cbor.tag_register_number({
            marshal = proc(_: ^cbor.Tag_Implementation, e: cbor.Encoder, v: any) -> cbor.Marshal_Error {
                cbor._encode_u8(e.writer, RAW_TAG_NR, .Tag) or_return
                return cbor.err_conv(cbor._encode_bytes(e, reflect.as_bytes(v)))
            },
            unmarshal = proc(_: ^cbor.Tag_Implementation, d: cbor.Decoder, _: cbor.Tag_Number, v: any) -> (cbor.Unmarshal_Error) {
                hdr := cbor._decode_header(d.reader) or_return
                maj, add := cbor._header_split(hdr)
                if maj != .Bytes {
                    return .Bad_Tag_Value
                }

                bytes := cbor.err_conv(cbor._decode_bytes(d, add, maj)) or_return
                intrinsics.mem_copy_non_overlapping(v.data, raw_data(bytes), len(bytes))
                return nil
            },
    }, RAW_TAG_NR, "raw")

    binary,err := cbor.marshal(world^, cbor.ENCODE_FULLY_DETERMINISTIC);
    fmt.println(len(binary))
    clear(&(world.world))
    resize_dynamic_array(&(world.world), 625 )
    cbor.unmarshal(string(binary), world)
    fmt.println(len(world.world))
    fd,err1:=os.open("test.sav", 0x00001)
    os.write(fd, binary)
    os.close(fd)

    /*
    fw:^libc.FILE
    fw = libc.fopen("test.sav", "w") //want to change this to be time based 
    libc.fwrite(&binary, 1, size_of([]byte), fw)
    libc.fclose(fw)
    */
}


load_game::proc(world:^World_Space, file_name:cstring){
    
    RAW_TAG_NR :: 200
    cbor.tag_register_number({
            marshal = proc(_: ^cbor.Tag_Implementation, e: cbor.Encoder, v: any) -> cbor.Marshal_Error {
                cbor._encode_u8(e.writer, RAW_TAG_NR, .Tag) or_return
                return cbor.err_conv(cbor._encode_bytes(e, reflect.as_bytes(v)))
            },
            unmarshal = proc(_: ^cbor.Tag_Implementation, d: cbor.Decoder, _: cbor.Tag_Number, v: any) -> (cbor.Unmarshal_Error) {
                hdr := cbor._decode_header(d.reader) or_return
                maj, add := cbor._header_split(hdr)
                if maj != .Bytes {
                    return .Bad_Tag_Value
                }

                bytes := cbor.err_conv(cbor._decode_bytes(d, add, maj)) or_return
                intrinsics.mem_copy_non_overlapping(v.data, raw_data(bytes), len(bytes))
                return nil
            },
    }, RAW_TAG_NR, "raw")
    

    fd,err1:=os.open(string(file_name))
    temp,err:=os.read_entire_file(fd)
    os.close(fd)

    fmt.println("loaded file")
    fmt.println(err)

    temperr:=cbor.unmarshal(string(temp), world)
    fmt.println(temperr)
    
    fmt.println(int(world.num_x))
    fmt.println("created temp world")
    
}






