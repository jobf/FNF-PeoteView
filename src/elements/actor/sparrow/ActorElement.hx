package elements.actor.sparrow;

/**
	Basic sparrow actor element.
**/
@:publicFields
class ActorElement implements Element
{
	@texX var clipX = 0;
	@texY var clipY = 0;
	@texW var clipWidth(default, set) = 1;
	@texH var clipHeight(default, set) = 1;

	inline function set_clipWidth(value:Int)
	{
		clipWidth = value;
		clipSizeX = value;
		return value;
	}

	inline function set_clipHeight(value:Int)
	{
		clipHeight = value;
		clipSizeY = value;
		return value;
	}

	@texSizeX private var clipSizeX = 1;
	@texSizeY private var clipSizeY = 1;

	@varying @custom @formula("_mirror == 1 ? (_flipX == 0 ? 1 : 0) : _flipX") var _flipX = 0;
	@varying @custom var _flipY = 0;
	@varying @custom var _mirror = 0;

	var flipX(default, set) : Bool;

	inline function set_flipX(value:Bool) : Bool
	{
		_flipX = value ? 1 : 0;
		return flipX = value;
	}

	var flipY(default, set) : Bool;

	inline function set_flipY(value:Bool) : Bool
	{
		_flipY = value ? 1 : 0;
		return flipY = value;
	}

	var mirror(default, set) : Bool;

	inline function set_mirror(value:Bool) : Bool
	{
		_mirror = value ? 1 : 0;
		return mirror = value;
	}

	@posX @formula("x + off_x + px + adjust_x + (w * (_mirror == 1 ? _flipX : -_flipX))") var x : Float;
	@posY @formula("y + off_y + py + adjust_y + (h * _flipY)") var y : Float;
	@sizeX @formula("(w * scale) * (_flipX == 1 ? -1 : 1)") var w : Float;
	@sizeY @formula("(h * scale) * (_flipY == 1 ? -1 : 1)") var h : Float;

	@pivotX @formula("(w < 0 ? -w : w) * 0.5") var px : Float;
	@pivotY @formula("(h < 0 ? -h : h) * 0.5") var py : Float;

	@rotation var r : Float;

	@varying @custom @formula("off_x * scale") var off_x : Float;
	@varying @custom @formula("off_y * scale") var off_y : Float;
	@varying @custom var adjust_x : Float;
	@varying @custom var adjust_y : Float;
	@varying @custom var scale : Float = 1.0;

	@color var c : Color = 0xFFFFFFFF;

	function new(x=0, y:Float = 0)
	{
		this.x = x;
		this.y = y;
	}
}