package music;

import cpp.Float64;

// Windows OS
#if cpp
class Timestamp {
    inline public static function get():Float64 {
        var stamp:Float64 = untyped __global__.__time_stamp();
        return stamp;
    }
}
// Unsupported OS
#else
class Timestamp {
    inline public static function get():Float {
        return 0.0; // Not supported
    }
}
#end