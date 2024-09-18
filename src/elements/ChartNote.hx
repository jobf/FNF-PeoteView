package elements;

import haxe.Int64;

/**
	The internal chart note.
	Written by SomeGuyWhoLikesFnf, fixed and tweaked by chris (Dimensionscape)
**/
#if !debug
@:noDebug
#end
@:publicFields
abstract ChartNote(Int64) from Int64 {
	/**
		The position's bit mask.
	**/
	static var POSITION_MASK:Int64 = Int64.sub(Int64.shl(Int64.make(0, 1), 41), Int64.make(0, 1));

	/**
		Construct a chart note.
	**/
	inline function new(position:Int64, duration:Int, index:Int, type:Int, lane:Int) {
		this = (position << 23) | (duration << 10) | (index << 6) | (type << 2) | lane;
	}

	/**
		The position. 41 bits so it fits the 100 microsecond granularity.
	**/
	var position(get, never):Int64;

	/**
		The duration. 13 bits. 3.2ms granularity.
	**/
	var duration(get, never):Int;

	/**
		The index. 4 bits.
	**/
	var index(get, never):Int;

	/**
		The type. 4 bits.
	**/
	var type(get, never):Int;

	/**
		The lane. 2 bits.
	**/
	var lane(get, never):Int;

	/**
		Get the position.
	**/
	inline function get_position():Int64 {
		return (this >> 23) & POSITION_MASK; // Mask 41 bits
	}

	/**
		Get the duration.
	**/
	inline function get_duration():Int {
		return ((this.low:Int) >> 10) & 0x1FFF; // Mask 13 bits
	}

	/**
		Get the index.
	**/
	inline function get_index():Int {
		return ((this.low:Int) >> 6) & 0xF; // Mask 4 bits
	}

	/**
		Get the type.
	**/
	inline function get_type():Int {
		return ((this.low:Int) >> 2) & 0xF; // Mask 4 bits
	}

	/**
		Get the lane.
	**/
	inline function get_lane():Int {
		return (this.low:Int) & 0x3; // Get the last 2 bits for lane
	}
}