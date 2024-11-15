package music.chart;

import cpp.UInt8;

/**
	The song's difficulty.
	This is an abstract over a `UInt8`.
**/
enum abstract Difficulty(UInt8) from UInt8 {
	/**
		Easy difficulty level.
	**/
	var EASY;

	/**
		Normal difficulty level.
	**/
	var NORMAL;

	/**
		Hard difficulty level.
	**/
	var HARD;

	/**
		Expert difficulty level.
	**/
	var EXPERT;

	/**
		Insane difficulty level.
	**/
	var INSANE;

	/**
		Blasphemous difficulty level.
	**/
	var BLASPHEMOUS;

	/**
		Echo difficulty level.
	**/
	var ECHO;

	/**
		Custom difficulty level.
	**/
	var CUSTOM;
}