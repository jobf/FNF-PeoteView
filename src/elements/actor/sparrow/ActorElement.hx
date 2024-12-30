package elements.actor.sparrow;

/**
	Basic sparrow actor element.
**/
@:publicFields
class ActorElement implements Element {
	@texX var clipX:Int = 0;
	@texY var clipY:Int = 0;
	@texW var clipWidth(default, set):Int = 1;
	@texH var clipHeight(default, set):Int = 1;

	inline function set_clipWidth(value:Int) {
		clipWidth = value;
		clipSizeX = value;
		return value;
	}

	inline function set_clipHeight(value:Int) {
		clipHeight = value;
		clipSizeY = value;
		return value;
	}

	@texSizeX private var clipSizeX:Int = 1;
	@texSizeY private var clipSizeY:Int = 1;

	@varying @custom @formula("_mirror == 1 ? (_flipX == 0 ? 1 : 0) : _flipX") var _flipX:Int = 0;
	@varying @custom var _flipY:Int = 0;
	@varying @custom var _mirror:Int = 0;

	var flipX(default, set):Bool;

	inline function set_flipX(value:Bool):Bool {
		_flipX = value ? 1 : 0;
		return flipX = value;
	}

	var flipY(default, set):Bool;

	inline function set_flipY(value:Bool):Bool {
		_flipY = value ? 1 : 0;
		return flipY = value;
	}

	var mirror(default, set):Bool;

	inline function set_mirror(value:Bool):Bool {
		_mirror = value ? 1 : 0;
		return mirror = value;
	}

	@posX @formula("x + off_x + px + adjust_x + (w * (_mirror == 1 ? _flipX : -_flipX))") var x:Int;
	@posY @formula("y + off_y + py + adjust_y + (h * _flipY)") var y:Int;
	@sizeX @formula("(w * scale) * (_flipX == 1 ? -1 : 1)") var w:Int;
	@sizeY @formula("(h * scale) * (_flipY == 1 ? -1 : 1)") var h:Int;

	@pivotX @formula("(w < 0 ? -w : w) * 0.5") var px:Int;
	@pivotY @formula("(h < 0 ? -h : h) * 0.5") var py:Int;

	@rotation var r:Float;

	@varying @custom @formula("off_x * scale") var off_x:Int;
	@varying @custom @formula("off_y * scale") var off_y:Int;
	@varying @custom var adjust_x:Int;
	@varying @custom var adjust_y:Int;
	@varying @custom var scale:Float = 1.0;

	@color var c:Color = 0xFFFFFFFF;

	function new(x:Int = 0, y:Int = 0) {
		this.x = x;
		this.y = y;
	}
}