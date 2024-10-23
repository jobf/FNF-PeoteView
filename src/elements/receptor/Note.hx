package elements.receptor;

class Note implements Element {
	@varying @custom @formula("ox * scale") private var ox(default, null):Int;
	@varying @custom @formula("oy * scale") private var oy(default, null):Int;

	@texTile private var frame(default, null):Int;
	@varying @custom public var scale:Float;

	// position in pixel (relative to upper left corner of Display)
	@posX @formula("ox + x + px") public var x:Int;
	@posY @formula("oy + y + py") public var y:Int;
	
	// size in pixel
	@varying @sizeX @formula("w * scale") public var w:Int;
	@varying @sizeY @formula("h * scale") public var h:Int;

	@rotation public var r:Float;

	@pivotX @formula("w * 0.5") public var px:Int;
	@pivotY @formula("h * 0.5") public var py:Int;

	@color public var c:Color = 0xFFFFFFFF;

    public function new(x:Int, y:Int, w:Int, y:Int, ox:Int = 0, oy:Int = 0) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.y = h;
		this.ox = ox;
		this.oy = oy;
	}
}