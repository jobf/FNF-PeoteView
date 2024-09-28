package tests;

/**
	The receptor sprite.
	Inside of it is notes and sustains that are layered onto the receptor.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Receptor extends Sprite {
	/**
		What the receptor should display as.
    **/
    var skin:String;

	/**
		Constructs an alphabet text sprite.
		@param text The alphabet's text.
		@param x The sprite's x.
		@param y The sprite's y.
		@param z The sprite's z index.
	**/
	function new(skin:String = "normal", x:Float = 0, y:Float = 0, z:Int = 0) {
		super(x, y, z);
        this.skin = skin;
	}
}