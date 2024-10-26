package elements;

class Note implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@varying @custom @formula("ox * scale") public var ox:Int = -27;
	@varying @custom @formula("oy * scale") public var oy:Int = -27;
	@varying @custom public var scale:Float = 1.0;
	@posX @formula("x + px + ox") public var x:Int;
	@posY @formula("y + py + oy") public var y:Int;

	// size in pixel
	@varying @sizeX @formula("w * scale") public var w:Int;
	@varying @sizeY @formula("h * scale") public var h:Int;

	@rotation public var r:Float;

	@pivotX @const @formula("w * 0.5") public var px:Int;
	@pivotY @const @formula("h * 0.5") public var py:Int;

	@color public var c:Color = 0xFFFFFFFF;

	@texTile private var tile(default, null):Int;

	/**
		The data of this note sprite.
	**/
	public var data:ChartNote;

	/**
		The child of this note sprite.
	**/
	public var child:Sustain;

	inline public function new(x:Int, y:Int, w:Int, h:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	// Command functions

	inline public function reset() {
		tile = 0;
	}

	inline public function press() {
		tile = 1;
	}

	inline public function confirm() {
		tile = 2;
	}

	inline public function toNote() {
		tile = 3;
	}

	// Checking functions

	inline public function idle() {
		return tile == 0;
	}

	inline public function pressed() {
		return tile == 1;
	}

	inline public function confirmed() {
		return tile == 2;
	}

	inline public function isNote() {
		return tile == 3;
	}
}
