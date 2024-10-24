package elements;

class Note implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @formula("-27 + x + px") public var x:Int;
	@posY @formula("-27 + y + py") public var y:Int;

	// size in pixel
	@varying @sizeX public var w:Int;
	@varying @sizeY public var h:Int;

	// at what x position it have to slice (width of the tail in texturedata pixels) (WARNING: COUNT X POSITION FROM PNG BACKWARDS)
	@varying @custom public var tailPoint:Int = -1;

	@rotation public var r:Float;

	@pivotX @formula("w * 0.5") public var px:Int;
	@pivotY @formula("h * 0.5") public var py:Int;

	@color public var c:Color = 0xFFFFFFFF;

	@texTile private var tile(default, null):Int;

	// --------------------------------------------------------------------------

	static public function init(program:Program, name:String, texture:Texture)
	{
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true );
		program.blendEnabled = true;

		var tW:String = Util.toFloatString(texture.width / texture.slotsX);
		var tH:String = Util.toFloatString(texture.height / texture.slotsY);

		program.injectIntoFragmentShader(
		'
			vec4 slice( int textureID, float tailPoint )
			{
				vec2 coord = vTexCoord;

				if (tailPoint > 0) {
					float slicePositionX = 1.0 - (tailPoint/$tH * vSize.y) / vSize.x;

					if (coord.x < slicePositionX)
					{
						coord.x = mix(
						1.0 - tailPoint/$tW,
						0.0,
						mod(
							(1.0-coord.x/slicePositionX) *
							(vSize.x/vSize.y * $tH - tailPoint) /
							($tW - tailPoint), 1.0
						)
						);
					}
					else
					{
						coord.x = mix(1.0 - tailPoint/$tW, 1.0, (coord.x - slicePositionX) / (1.0 - slicePositionX) );
					}
				}

				return getTextureColor( textureID, coord );
			}
		');

		// instead of using normal "name" identifier to fetch the texture-color,
		// the postfix "_ID" gives access to use getTextureColor(textureID, ...) or getTextureResolution(textureID)
		program.setColorFormula( 'c * slice(${name}_ID, tailPoint)' );
	}

	inline public function new(x:Int, y:Int, w:Int, h:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	inline public function reset() tile = 0;
	inline public function press() tile = 1;
	inline public function confirm() tile = 2;
	inline public function toNote() tile = 3;
	inline public function toSustain() tile = 4;
}
