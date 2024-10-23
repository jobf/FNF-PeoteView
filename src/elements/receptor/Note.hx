package elements.receptor;

class Note implements Element {
	@varying @custom public var scale:Float = 1.0;

	// position in pixel (relative to upper left corner of Display)
	@posX @formula("x + px") public var x:Int;
	@posY @formula("y + py") public var y:Int;
	
	// size in pixel
	@varying @sizeX @formula("w * scale") public var w:Int;
	@varying @sizeY @formula("h * scale") public var h:Int;

	@rotation public var r:Float;

	@pivotX @formula("w * 0.5") public var px:Int;
	@pivotY @formula("h * 0.5") public var py:Int;

	@color public var c:Color = 0xFFFFFFFF;

    inline public function new(x:Int, y:Int, w:Int, h:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}