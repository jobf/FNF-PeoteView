package elements.receptor;

@:publicFields
abstract ReceptorProperties(cpp.UInt8) {
    var index(get, set):Int;

    inline function get_index():Int {
        return (this >> 6) & 0x7;
    }

    inline function set_index(value:Int) {
        return this = (this & 0xC7) | ((value & 0x7) << 6);
    }

    var lane(get, set):Int;

    inline function get_lane():Int {
        return this & 0x3;
    }

    inline function set_lane(value:Int) {
        return this = (this & 0xFC) | (value & 0x3);
    }

    var type(get, set):Int;

    inline function get_type():Int {
        return (this >> 3) & 0x7;
    }

    inline function set_type(value:Int) {
        return this = (this & 0xC7) | ((value & 0x7) << 3);
    }

    inline function new(indexVal:Int, laneVal:Int, typeVal:Int) {
        this = 0;
        index = indexVal;
        lane = laneVal;
        type = typeVal;
    }
}