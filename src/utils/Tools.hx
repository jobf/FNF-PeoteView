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
		var finalData:Array<Float> = [];

		var line = File.getContent('$path/healthBarConfig.txt');

		var split = line.split(", ");
		if (split.length != 6) throw "ARGUMENTS ARE NOT EQUAL TO SIX!";

		var w = Std.parseFloat(split[0].split(" ")[1]);
		var h = Std.parseFloat(split[1].split(" ")[1]);
		var ws = Std.parseFloat(split[2].split(" ")[1]);
		var hs = Std.parseFloat(split[3].split(" ")[1]);
		var xa = Std.parseFloat(split[4].split(" ")[1]);
		var ya = Std.parseFloat(split[5].split(" ")[1]);

		finalData.push(w);
		finalData.push(h);
		finalData.push(ws);
		finalData.push(hs);
		finalData.push(xa);
		finalData.push(ya);

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

	inline static function profileFrame() {
		#if FV_PROFILE
		cpp.vm.tracy.TracyProfiler.frameMark();
		#end
	}

	static function formatTime(ms:Float, showMS:Bool = false):String
	{
		var milliseconds:Int = Math.floor(ms * 0.1) % 100;
		var seconds:Int = Math.floor(ms * 0.001);
		var hours:Int = Math.floor(seconds / 3600);
		seconds %= 3600;
		var minutes:Int = Math.floor((seconds + 1) / 60); // Add one to the `seconds` to correct the minute display
		seconds %= 60;

		var t = ':';
		var c = '.';

		var time:String = '';

		if (!Math.isNaN(ms)) {
			if (hours > 0) time += '$hours$t';
			if (minutes < 10 && hours > 0) time += '0$minutes$t';
			else time += '$minutes$t';
			if (seconds < 10) time += '0';
			time += seconds;
		} else {
			time = 'null';
		}

		if (showMS) {
			if (milliseconds < 10) {
				time += '${c}0$milliseconds';
			} else {
				time += '${c}$milliseconds';
			}
		}

		return time;
	}

	inline static function lerp(a:Float, b:Float, ratio:Float):Float {
		return a + ratio * (b - a);
	}
}