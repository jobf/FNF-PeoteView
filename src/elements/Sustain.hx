package elements;

class Sustain implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @formula("-27 + x + px") public var x:Int;
	@posY @formula("-27 + y + py") public var y:Int;

	// size in pixel
	@varying @sizeX public var w:Int;
	@varying @sizeY public var h:Int;

	// at what x position it have to slice (width of the tail in texturedata pixels) (WARNING: COUNT X POSITION FROM PNG BACKWARDS)
	@varying @custom public var tailPoint:Int = 31;

	@rotation public var r:Float;

	@pivotX @formula("w * 0.5") public var px:Int;
	@pivotY @formula("h * 0.5") public var py:Int;

	@color public var c:Color = 0xFFFFFFFF;

	@texTile private var tile:Int;

	@varying @custom public var isSustain:Int;

	// --------------------------------------------------------------------------

	static public function init(display:Display, program:Program, name:String, texture:Texture)
	{
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true );
		program.blendEnabled = true;

		var tW:String = Std.string(Math.floor(texture.width / texture.slotsX));
		var tH:String = Std.string(Math.floor(texture.height / texture.slotsY));

		program.injectIntoFragmentShader(
		'
			vec4 slice( int textureID, float tailPoint, int isSustain )
			{
				vec2 coord = vTexCoord;

				if (isSustain < 1)
				{
					float slicePositionX = 1.0 - (tailPoint/$tH.0 * vSize.y) / vSize.x;

					if (coord.x < slicePositionX)
					{
						coord.x = mix(
						1.0 - tailPoint/$tW.0,
						0.0,
						mod(
							(1.0-coord.x/slicePositionX) *
							(vSize.x/vSize.y * $tH.0 - tailPoint) /
							($tW.0 - tailPoint), 1.0
						)
						);
					}
					else
					{
						coord.x = mix(1.0 - tailPoint/$tW.0, 1.0, (coord.x - slicePositionX) / (1.0 - slicePositionX) );
					}
				}

				return getTextureColor( textureID, coord );
			}
		');

		// instead of using normal "name" identifier to fetch the texture-color,
		// the postfix "_ID" gives access to use getTextureColor(textureID, ...) or getTextureResolution(textureID)
		program.setColorFormula( 'slice(${name}_ID, tailPoint, isSustain)' );

		display.addProgram(program);
	}

	inline public function new(x:Int, y:Int, w:Int, h:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}
}
