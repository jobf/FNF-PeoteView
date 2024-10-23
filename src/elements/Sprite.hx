package elements;

/**
	The element with centered rotation and support for global rotation via camera rotation.
**/
@:publicFields
class Sprite implements Element
{
	/**
		The sprite's x position.
	**/
	@posX @formula("x + px") var x:Int;

	/**
		The sprite's y position.
	**/
	@posY @formula("y + py") var y:Int;

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
	@pivotX @formula("w * 0.5") var px:Int;

	/**
		The pivot y of the sprite.
	**/
	@pivotY @formula("h * 0.5") var py:Int;

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
		The texture tile of this sprite.
		This is used for texture tiling, which in case WILL performs better.
	**/
	@texTile var tile:Int;

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
	function new(x:Int = 0, y:Int = 0, z:Int = 0) {
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
				x = (Screen.view.width - Math.floor(w / widthDiv)) >> 1;
			case Y:
				y = (Screen.view.height - Math.floor(h / heightDiv)) >> 1;
			default:
				x = (Screen.view.width - Math.floor(w / widthDiv)) >> 1;
				y = (Screen.view.height - Math.floor(h / heightDiv)) >> 1;
		}
	}

	/**
		Sets the sprite's size to the texture's size at a specific axis.
		This is useful for multitexture.
		@param texture The texture you want to set the sprite's size to.
		@param axis The axis you want to rescale the sprite in.
	**/
	function setSizeToTexture(texture:Texture, axis:Axis = XY) {
		if (texture == null) {
			return;
		}

		var tW = texture.slotsX != 1 ? texture.slotWidth : Math.floor(texture.width / texture.tilesX);
		var tH = texture.slotsY != 1 ? texture.slotHeight : Math.floor(texture.height / texture.tilesY);

		switch (axis) {
			case X:
				w = tW;
			case Y:
				h = tH;
			default:
				w = tW;
				h = tH;
		}
	}

	/**
		Disposes this sprite.
	**/
	function dispose() {}
}
