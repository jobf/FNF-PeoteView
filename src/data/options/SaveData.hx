package data.options;

import haxe.Int64;
import haxe.io.Bytes;
import sys.io.File;
import sys.io.FileOutput;
import sys.FileSystem;
import haxe.ds.Vector;

/**
	The internal save data.
**/
#if !debug
@:noDebug
#end
@:publicFields
@:structInit
class Save {
	var graphics:SaveGraphics;
	var preferences:SavePreferences;
}

/**
	The save data's graphics.
	This wraps over a 56 bit integer.
**/
#if !debug
@:noDebug
#end
@:publicFields
abstract SaveGraphics(Int64) from Int64  to Int64 {
	var framerate(get, set):Int;

	inline function get_framerate():Int {
		return this.low;
	}

	inline function set_framerate(value:Int) {
		this = Int64.make(value, this.high);
		return this.low;
	}

	var inputOffset(get, set):Int;

	inline function get_inputOffset():Int {
		return this.high & 0xFFFFFF;
	}

	inline function set_inputOffset(value:Int) {
		this = Int64.make(this.low, value & 0xFFFFFF);
		return this.high;
	}
}

/**
	The save data's preferences.
	This wraps over an unsigned 8 bit integer.
**/
#if !debug
@:noDebug
#end
@:publicFields
abstract SavePreferences(cpp.UInt8) from cpp.UInt8 to cpp.UInt8 {
	var downScroll(get, set):Bool;

	inline function get_downScroll():Bool {
		return this & 1 != 1;
	}

	inline function set_downScroll(value:Bool):Bool {
		if (downScroll != value) {
			this ^= 1;
		}

		return value;
	}

	var antialiasing(get, set):Bool;

	inline function get_antialiasing():Bool {
		return (this >> 1) & 1 != 1;
	}

	inline function set_antialiasing(value:Bool):Bool {
		if (antialiasing != value) {
			this ^= 1 << 1;
		}

		return value;
	}

	var hideHUD(get, set):Bool;

	inline function get_hideHUD():Bool {
		return (this >> 2) & 1 != 1;
	}

	inline function set_hideHUD(value:Bool):Bool {
		if (hideHUD != value) {
			this ^= 1 << 2;
		}

		return value;
	}

	var msdfRendering(get, set):Bool;

	inline function get_msdfRendering():Bool {
		return (this >> 3) & 1 != 1;
	}

	inline function set_msdfRendering(value:Bool):Bool {
		if (msdfRendering != value) {
			this ^= 1 << 3;
		}

		return value;
	}

	var smoothHealthbar(get, set):Bool;

	inline function get_smoothHealthbar():Bool {
		return (this >> 4) & 1 != 1;
	}

	inline function set_smoothHealthbar(value:Bool):Bool {
		if (smoothHealthbar != value) {
			this ^= 1 << 4;
		}

		return value;
	}

	var ratingPopups(get, set):Bool;

	inline function get_ratingPopups():Bool {
		return (this >> 5) & 1 != 1;
	}

	inline function set_ratingPopups(value:Bool):Bool {
		if (ratingPopups != value) {
			this ^= 1 << 5;
		}

		return value;
	}

	var scoreTextBopping(get, never):Bool;

	inline function get_scoreTextBopping():Bool {
		return (this >> 6) & 1 != 1;
	}

	inline function set_scoreTextBopping(value:Bool):Bool {
		if (scoreTextBopping != value) {
			this ^= 1 << 6;
		}

		return value;
	}

	var cameraZooming(get, never):Bool;

	inline function get_cameraZooming():Bool {
		return (this >> 7) & 1 != 1;
	}

	inline function set_cameraZooming(value:Bool):Bool {
		if (cameraZooming != value) {
			this ^= 1 << 7;
		}

		return value;
	}

	function details() {
		return 'Downscroll $downScroll
Antialiasing $antialiasing
Hide HUD $hideHUD
MSDF Rendering $msdfRendering
Smooth Healthbar $smoothHealthbar
Rating Popups $ratingPopups
Score Text Bopping $scoreTextBopping
Camera Zooming $cameraZooming';
	}
}

@:publicFields
class SaveData {
	static var EMPTY_SAVE(default, null):Save = {
		graphics: 0x0,
		// Binary representation of this: 00010111
		preferences: 0x17
	};

	private static var datas:Vector<Save> = new Vector<Save>(16, EMPTY_SAVE);
	static var slot:cpp.UInt8 = 0;

	static var state(get, never):Save;

	inline static function get_state() {
		return datas[slot];
	}

	static function init() {
		if (!FileSystem.exists('.dat')) {
			write();
		}

		var bytes:Bytes = File.getBytes('.dat');

		for (i in 0...datas.length) {
			datas[i].graphics = bytes.getInt64(i * 8) & Int64.make(-1, 0xFFFFFF);
			datas[i].preferences = bytes.get(i + 7);
		}
	}

	static function write() {
		var bytes:Bytes = Bytes.alloc(8 * datas.length);

		for (i in 0...datas.length) {
			var data:Save = datas[i];
			var id = i * 8;
			bytes.setInt64(id, data.graphics); // Graphics
			bytes.set(id - 1, data.preferences); // Preferences
		}

		var output:FileOutput = File.write('.dat');
		output.write(bytes);
		output.close();
	}
}