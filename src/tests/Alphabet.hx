package tests;

/**
	The alphabet text sprite.
	Creates a new texture every time you reconstruct said sprite.
**/
#if !debug
@:noDebug
#end
@:publicFields
class Alphabet extends Sprite {
	/**
		How the alphabet text should display.
    **/
    var text:String;

	/**
		Constructs an alphabet text sprite.
		@param text The alphabet's text.
		@param x The sprite's x.
		@param y The sprite's y.
		@param z The sprite's z index.
	**/
	function new(text:String = "Text", x:Float = 0, y:Float = 0, z:Int = 0) {
		super(x, y, z);
        this.text = text;
        reconstructAlphabet();
	}

	/**
		Reconstructs the alphabet text display.
	**/
    function reconstructAlphabet() {
        // TODO
    }
}