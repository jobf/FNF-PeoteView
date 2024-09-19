package elements;

/**
	The sprite.
**/
@:publicFields
class Sprite implements Element
{
	/**
		The sprite's x position.
	**/
	@posX var x:Float;

	/**
		The sprite's y position.
	**/
	@posY var y:Float;

	/**
		The sprite's z position.
	**/
	@zIndex var z:Int;

	/**
		The sprite's width.
	**/
	@sizeX var w:Int;

	/**
		The sprite's height.
	**/
	@sizeY var h:Int;

	/**
		The rotation around pivot point of the sprite.
	**/
	@rotation var r:Float;

	/**
		The pivot x of the sprite.
	**/
	@pivotX var px:Int;

	/**
		The pivot y of the sprite.
	**/
	@pivotY var py:Int;

	/**
		The color (in RGBA format) of the sprite.
	**/
	@color var c:Color = 0xffffffff;

	/**
		The texture slot of this sprite.
		This is used for multitexture.
	**/
	@texSlot var slot:Int;

	/**
		The sprite's options.
		@param texRepeatX Whenever the texture should repeat horizontally.
		@param texRepeatY Whenever the texture should repeat vertically.
		@param blend Whenever your sprite's texture should appear with crispy edges or not.
	**/
	var OPTIONS = {texRepeatX: false, texRepeatY: false, blend: true};

	/**
		Constructs a sprite.
		@param x The sprite's x.
		@param y The sprite's y.
		@param z The sprite's z index.
	**/
	function new(x:Float = 0, y:Float = 0, z:Int = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	/**
		Screen center the sprite at a specific axis.
		@param axis The axis you want to center the sprite to.
	**/
	function screenCenter(axis:Axis = XY, widthDiv:Float = 1, heightDiv:Float = 1) {
		switch (axis) {
			case X:
				x = (Screen.view.width - (w / widthDiv)) * 0.5;
			case Y:
				y = (Screen.view.height - (h / heightDiv)) * 0.5;
			default:
				x = (Screen.view.width - (w * widthDiv)) * 0.5;
				y = (Screen.view.height - (h / heightDiv)) * 0.5;
		}
	}

	/**
		Sets the sprite's size to the texture's size at a specific axis.
		This is useful for multitexture.
		@param texture 
	**/
	function setSizeToTexture(texture:Texture, axis:Axis = XY) {
		if (texture == null) {
			return;
		}

		switch (axis) {
			case X:
				w = texture.width;
			case Y:
				h = texture.height;
			default:
				w = texture.width;
				h = texture.height;
		}
	}
}
