package elements.receptor;

class Note implements Element {
	@texTile private var frame(default, null):Int;

	// position in pixel (relative to upper left corner of Display)
	@posX @formula("x + px") public var x:Int;
	@posY @formula("y + py") public var y:Int;
	
	// size in pixel
	@varying @sizeX public var w:Int;
	@varying @sizeY public var h:Int;

	@rotation public var r:Float;

	@pivotX @formula("(w * 0.5)") public var px:Int;
	@pivotY @formula("(h * 0.5)") public var py:Int;

    public function new() {}
}