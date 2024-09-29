package tests;

import cpp.UInt8;

/**
	The receptor sprite.
	Inside of it is notes and sustains that are layered onto the receptor.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Step extends Sprite {
	/**
		What the receptor should display as.
    **/
    var skin:String;

	/**
		What the receptor should act by.
    **/
    var state:StepState;

	/**
		Constructs a step.
		@param x The sprite's x.
		@param y The sprite's y.
		@param skin What the receptor should look like.
		@param z The sprite's z index.
	**/
	function new(x:Float = 0, y:Float = 0, skin:String = "normal", z:Int = 0) {
		super(x, y, z);
        this.skin = skin;
        state = IDLE;
	}
}

private enum abstract StepState(UInt8) to UInt8 {
    var IDLE = 0;
    var HIT = 1;
    var MISS = -1;
}