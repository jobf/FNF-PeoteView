package;

import peote.view.Element;
import peote.view.Color;

class Sprite implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @formula("x + (w / 2)") public var x:Int=0;
	@posY @formula("y + (h / 2)") public var y:Int=0;

	// size in pixel
	@sizeX public var w:Int=100;
	@sizeY public var h:Int=100;

	// rotation around pivot point
	@rotation public var r:Float;

	// pivot x (rotation offset)
	@pivotX @formula("w / 2") public var px:Int = 0;

	// pivot y (rotation offset)
	@pivotY @formula("h / 2") public var py:Int = 0;

	// color (RGBA)
	@color public var c:Color = 0xffffffFF;

	// z-index
	@zIndex public var z:Int = 0;

	@texTile public var tileIndex:Int = 0;

	var OPTIONS = { blend: true };

	public function new() {}
}
