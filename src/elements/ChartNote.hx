package elements;

import haxe.Int64;
import cpp.UInt16;
import cpp.UInt8;

/**
 * The internal chart note.
 * This is a helper abstract for the bytes of the chart, which wraps Int64.
*/
#if !debug
@:noDebug
#end
@:publicFields
abstract ChartNote(Int64) from Int64 to Int64 {
	/**
	* The note position.
	*/
	var position(get, never):Int64;

	/**
	* The getter for the note position.
	*/
	inline function get_position():Int64 {
		return this & ((Int64.ofInt(2) << 40) - 1);
	}

	/**
	* The note duration.
	*/
	var duration(get, never):UInt16;

	/**
	* The getter for the note duration.
	*/
	inline function get_duration():UInt16 {
		return Int64.toInt(this >> 40) & 0xFFFF;
	}

	/**
	* The note index.
	*/
	var index(get, never):UInt8;

	/**
	* The getter for the note index.
	*/
	inline function get_index():UInt8 {
		return Int64.toInt(this >> 56) & 0xF;
	}

	/**
	* The note type.
	*/
	var type(get, never):UInt8;

	/**
	* The getter for the note type.
	*/
	inline function get_type():UInt8 {
		return Int64.toInt(this >> 60) & 0xF;
	}

	/**
	* The note lane.
	*/
	var lane(get, never):UInt8;

	/**
	* The getter for the note lane.
	*/
	inline function get_lane():UInt8 {
		return Int64.toInt(this >> 62) & 0x3;
	}

	inline function new(position:Int64, duration:UInt16, index:UInt8, type:UInt8, lane:UInt8) {
		this = position |
			(duration << 40) |
			(index << 56) |
			(type << 60) |
		(lane << 62);
	}
}