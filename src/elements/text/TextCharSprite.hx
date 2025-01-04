package elements.text;

/**
	The underlying text character element.
**/
@:publicFields
class TextCharSprite implements Element
{
	@posX @formula("x - os") var x : Float;
	@posY @formula("y - os")  var y : Float;
	@sizeX @formula("w + (os * 2.0)") var w : Float;
	@sizeY @formula("h + (os * 2.0)") var h : Float;

	// extra tex attributes for clipping
	@texX var clipX = 0;
	@texY var clipY = 0;
	@texW var clipWidth = 1;
	@texH var clipHeight = 1;

	// extra tex attributes to adjust texture within the clip
	@texPosX  var clipPosX = 0;
	@texPosY  var clipPosY = 0;
	@texSizeX var clipSizeX = 1;
	@texSizeY var clipSizeY = 1;

	@color var c : Color = 0xFFFFFFFF;

	@color private var alphaColor : Color = 0xFFFFFFFF;

	var alpha(get, set) : Float;

	inline function get_alpha()
	{
		return alphaColor.aF;
	}

	inline function set_alpha(value:Float)
	{
		return alphaColor.aF = value;
	}

	// outline implementation

	@color var oc : Color = 0x000000FF;
	@varying @custom var os : Float = 0.0;

	function new() {}
}