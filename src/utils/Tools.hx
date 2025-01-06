package utils;

import sys.io.File;
using StringTools;

@:publicFields
class Tools {
	static function parseNoteskinData(path:String) {
		cpp.NativeArray.zero(Note.offsetAndSizeFrames);
		cpp.NativeArray.zero(Sustain.offsets);
		cpp.NativeArray.zero(Sustain.tailPoints);

		var contents = File.getContent('$path/noteData.xml');
		var xml = Xml.parse(contents);
		var root = xml.firstElement();

		for (element in root.elementsNamed("SubTexture")) {
			var name = element.get("name");
			var x = Std.parseInt(element.get("x"));
			var y = Std.parseInt(element.get("y"));
			var width = Std.parseInt(element.get("width"));
			var height = Std.parseInt(element.get("height"));
			var frameX = element.exists("frameX") ? Std.parseInt(element.get("frameX")) : 0;
			var frameY = element.exists("frameY") ? Std.parseInt(element.get("frameY")) : 0;

			Note.offsetAndSizeFrames.push(x);
			Note.offsetAndSizeFrames.push(y);
			Note.offsetAndSizeFrames.push(width);
			Note.offsetAndSizeFrames.push(height);
			Note.offsetAndSizeFrames.push(frameX);
			Note.offsetAndSizeFrames.push(frameY);
		}

		var data = File.read('$path/sustainProperties.txt');

		TextureSystem.disposeTexture("sustainTex");
		TextureSystem.createTiledTexture("sustainTex", '$path/sustainSheet.png', 1, Std.parseInt(data.readLine()));

		var w = TextureSystem.getTexture("sustainTex").width;

		while (!data.eof()) {
			var line = data.readLine();
			var split = line.split(", ");
			if (split.length != 3) throw "ARGUMENTS ARE NOT EQUAL TO THREE!";

			var x = Std.parseInt(split[0]);
			var y = Std.parseInt(split[1]);
			var t = Std.parseInt(split[2]);

			Sustain.offsets.push([x, y]);
			Sustain.tailPoints.push(w - t);
		}
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

	static function parseTimeBarConfig(path:String) {
		var finalData:Array<Float> = [];

		var line = File.getContent('$path/timeBarConfig.txt');

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

	static function parseFont(name:String):Array<elements.text.TextCharData> {
		var path = 'assets/fonts/$name/data.json';
		var data = haxe.Json.parse(sys.io.File.getContent(path));
		TextureSystem.createTexture(name + "Font", path.replace('data.json', data.atlas.imagePath));
		return data.sprites;
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