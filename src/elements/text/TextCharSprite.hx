package elements.text;

/**
	The underlying text character element.
**/
@:publicFields
class TextCharSprite implements Element {
	@posX  var x:Float;
	@posY  var y:Float;
	@sizeX var w:Float;
	@sizeY var h:Float;

	// extra tex attributes for clipping
	@texX var clipX:Int = 0;
	@texY var clipY:Int = 0;
	@texW var clipWidth:Int  = 1;
	@texH var clipHeight:Int = 1;

	// extra tex attributes to adjust texture within the clip
	@texPosX  var clipPosX:Int = 0;
	@texPosY  var clipPosY:Int = 0;
	@texSizeX var clipSizeX:Int = 1;
	@texSizeY var clipSizeY:Int = 1;

	@color var c:Color = 0xFFFFFFFF;

	function new() {}
}