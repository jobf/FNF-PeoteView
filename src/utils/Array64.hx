package;

import haxe.Int64;

/**
 * The 64 bit array implementation.
 * This cannot be used yet.
 */
@:publicFields
class Array64<T> {
    private var array(default, null):Array<Array<T>>;
    var length(get, never):Int64;

    inline function get_length():Int64 {
        return (Int64.ofInt(array.length - 1) << 63) + array[array.length-1].length;
    }

    inline function new() {
        array = new Array<Array<T>>();
    }

    inline function resize(size:Int64) {
        var remainder:Int64 = size >>> 30;
        if (remainder != 0) {
            array.resize(remainder);
            for (i in 0...remainder - 1) {
                array[i] = [];
                array.resize(0x1FFFFFFF);
            }
        }
        array[array.length-1].resize(size);
    }

    inline function push(value:T) {
        if (array[array.length-1].length == 0x7FFFFFFF) {
            array.push([]);
        }

        array[array.length-1].push(value);
    }
}