package utils;

import sys.io.File;

@:publicFields
class Int64Tools {
    /**
		An optimized version of `haxe.Int64.fromFloat`. Only works on certain targets such as cpp, js, or eval.
	**/
	inline static function betterInt64FromFloat(value:Float):Int64 {
		var high:Int = Math.floor(value / 4294967296);
		var low:Int = Math.floor(value);
        return Int64.make(high, low);
    }
}