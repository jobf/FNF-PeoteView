package data.options;

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
abstract SaveData_Internal(Int64) from Int64 to Int64
{
	var downScroll(get, set) : Bool;

	inline function get_downScroll()
	{
		return get(0);
	}

	inline function set_downScroll(value:Bool)
	{
		return set(0, value);
	}

	var hideHUD(get, set) : Bool;

	inline function get_hideHUD()
	{
		return get(1);
	}

	inline function set_hideHUD(value:Bool)
	{
		return set(1, value);
	}

	var smoothHealthbar(get, set) : Bool;

	inline function get_smoothHealthbar()
	{
		return get(2);
	}

	inline function set_smoothHealthbar(value:Bool)
	{
		return set(2, value);
	}

	var ratingPopup(get, set) : Bool;

	inline function get_ratingPopup()
	{
		return get(3);
	}

	inline function set_ratingPopup(value:Bool)
	{
		return set(3, value);
	}

	var scoreTxtBopping(get, set) : Bool;

	inline function get_scoreTxtBopping()
	{
		return get(4);
	}

	inline function set_scoreTxtBopping(value:Bool)
	{
		return set(4, value);
	}

	var cameraZooming(get, set) : Bool;

	inline function get_cameraZooming()
	{
		return get(5);
	}

	inline function set_cameraZooming(value:Bool)
	{
		return set(5, value);
	}

	var iconBopping(get, set) : Bool;

	inline function get_iconBopping()
	{
		return get(6);
	}

	inline function set_iconBopping(value:Bool)
	{
		return set(6, value);
	}

	var inputOffset(get, set) : Int;

	inline function get_inputOffset()
	{
		return getWithBits(7, 10).low;
	}

	inline function set_inputOffset(value:Int)
	{
		return setWithBits(7, 10, value).low;
	}

	var frameRate(get, set) : Int;

	inline function get_frameRate()
	{
		return getWithBits(17, 20).low;
	}

	inline function set_frameRate(value:Int)
	{
		return setWithBits(17, 20, value).low;
	}

	var mipMapping(get, set) : Bool;

	inline function get_mipMapping()
	{
		return get(37);
	}

	inline function set_mipMapping(value:Bool)
	{
		return set(37, value);
	}

	var antialiasing(get, set) : Bool;

	inline function get_antialiasing()
	{
		return get(38);
	}

	inline function set_antialiasing(value:Bool)
	{
		return set(38, value);
	}

	var msdfRendering(get, set) : Bool;

	inline function get_msdfRendering()
	{
		return get(39);
	}

	inline function set_msdfRendering(value:Bool)
	{
		return set(39, value);
	}

	var customTitleBarColor(get, set) : Int;

	inline function get_customTitleBarColor()
	{
		return getWithBits(40, 24).low;
	}

	inline function set_customTitleBarColor(value:Int)
	{
		return setWithBits(40, 24, value).low;
	}

	inline function get(bitVal:Int)
	{
		return (this >> bitVal) & 0x1 == 1;
	}

	inline function set(bitVal:Int, value:Bool)
	{
		var gotten = get(bitVal);
		return gotten != value ? (this ^= Int64.ofInt(1) << bitVal) == 1 : gotten;
	}

	inline function getWithBits(bitVal:Int, bits:Int) : Int64
	{
		return (this >> bitVal) & ((Int64.ofInt(1) << bits) - 1);
	}

	inline function setWithBits(bitVal:Int, bits:Int, value:Int64)
	{
		var mask : Int64 = ((Int64.ofInt(1) << bits) - 1) << bitVal;
		var cleared : Int64 = this & ~mask;
		return this = cleared | ((value & ((1 << bits) - 1)) << bitVal);
	}
}

@:publicFields
class SaveData
{
	// https://try.haxe.org/#a208401B
	static var EMPTY_SAVE(default, null) : SaveData_Internal = Int64.parseString("-71776943694937992");

	private static var datas = new Vector<SaveData_Internal>(16, EMPTY_SAVE);
	static var slot : cpp.UInt8 = 0;

	static var state(get, never) : SaveData_Internal;

	inline static function get_state()
	{
		return datas[slot];
	}

	static function init()
	{
		var window = lime.app.Application.current.window;
		window.onClose.add(write);

		if (!FileSystem.exists('.dat')) {
			write();
		}

		var bytes : Bytes = File.getBytes('.dat');

		for (i in 0...datas.length)
		{
			datas[i] = bytes.getInt64(8 * i);
		}
	}

	static function write()
	{
		var bytes = Bytes.alloc(8 * datas.length);

		for (i in 0...datas.length)
		{
			bytes.setInt64(i * 8, datas[i]);
		}

		var output : FileOutput = File.write('.dat');
		output.write(bytes);
		output.close();
	}
}