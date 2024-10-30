package utils;

import sys.io.File;

@:publicFields
class Tools {
    static function parseFrameOffsets(path:String) {
        var finalData:Array<Int> = [];

        var data = File.read('$path/frameOffsets.txt');

        while (!data.eof()) {
            var line = data.readLine();
            var split = line.split(", ");
            if (split.length != 6) throw "ARGUMENTS ARE NOT EQUAL TO SIX!";

            var x = Std.parseInt(split[0].split(" ")[1]);
            var y = Std.parseInt(split[1].split(" ")[1]);
            var w = Std.parseInt(split[2].split(" ")[1]);
            var h = Std.parseInt(split[3].split(" ")[1]);
            var ox = Std.parseInt(split[4].split(" ")[1]);
            var oy = Std.parseInt(split[5].split(" ")[1]);

            finalData.push(x);
            finalData.push(y);
            finalData.push(w);
            finalData.push(h);
            finalData.push(ox);
            finalData.push(oy);
        }

        return finalData;
    }

    static function parseHealthBarConfig(path:String) {
        var finalData:Array<Int> = [];

        var line = File.getContent('$path/healthBarConfig.txt');

        var split = line.split(", ");
        if (split.length != 4) throw "ARGUMENTS ARE NOT EQUAL TO FOUR!";

        var w = Std.parseInt(split[0].split(" ")[1]);
        var h = Std.parseInt(split[1].split(" ")[1]);
        var ws = Std.parseInt(split[2].split(" ")[1]);
        var hs = Std.parseInt(split[3].split(" ")[1]);

        finalData.push(w);
        finalData.push(h);
        finalData.push(ws);
        finalData.push(hs);

        return finalData;
    }

    /**
		An optimized version of `haxe.Int64.fromFloat`. Only works on certain targets such as cpp, js, or eval.
	**/
	inline static function betterInt64FromFloat(value:Float):Int64 {
		var high:Int = Math.floor(value / 4294967296);
		var low:Int = Math.floor(value);
        return Int64.make(high, low);
    }
}