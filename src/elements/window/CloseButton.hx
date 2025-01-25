package elements.window;

/**
	Just a short and quick class similar to `Elem` that adds the texture tile field.
**/
class CloseButton implements Element {
	@posX public var x:Int;
	@posY public var y:Int;
	@sizeX public var w:Int;
	@sizeY public var h:Int;
	@color public var c:Color = 0xFFFFFFFF;
	@texTile public var tile:Int;

	public function new(x:Int, y:Int, w:Int, h:Int, tile:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.tile = tile;
	}
}