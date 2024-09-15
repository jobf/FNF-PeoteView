package system;

/**
 * Basic sprite to be used for pure colored elements
 */
@:publicFields
class BasicSprite implements Element
{
	/**
	 * The sprite's x position.
	 */
	@posX var x:Int = 0;

	/**
	 * The sprite's y position.
	 */
	@posY var y:Int = 0;

	/**
	 * The sprite's z position.
	 */
	@zIndex var z:Int = 0;

	/**
	 * The sprite's width.
	 */
	@sizeX var w:Int = 100;

	/**
	 * The sprite's height.
	 */
	@sizeY var h:Int = 100;

	/**
	 * The rotation around pivot point of the sprite.
	 */
	@rotation var r:Float;

	/**
	 * The pivot x of the sprite.
	 */
	@pivotX var px:Int = 0;

	/**
	 * The pivot y of the sprite.
	 */
	@pivotY var py:Int = 0;

	/**
	 * The color (in RGBA format) of the sprite.
	 */
	@color var c:Color;

	/**
	 * The alpha of the sprite.
	 */
	var a(default, set):Float = 1;

	/**
	 * The setter for the sprite's alpha.
	 * @param value 
	 * @return Float
	 */
	inline function set_a(value:Float):Float {
		a = value;
		return value;
	}

	/**
	 * The sprite's texture slot.
	 */
	@texSlot public var slot:Int = 0;

	/**
	 * Constructs a sprite.
	 */
	function new(color:Color) {
		this.c = color;
	}
	
}
