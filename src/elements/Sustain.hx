package elements;

class Sustain implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @formula("x") public var x:Int;
	@posY @formula("y + py") public var y:Int;

	// size in pixel
	@varying @sizeX @formula("w * speed") public var w:Int;
	@varying @sizeY public var h:Int;

	// at what x position it have to slice (width of the tail in texturedata pixels) (WARNING: COUNT X POSITION FROM PNG BACKWARDS)
	@varying @custom public var tailPoint:Int = 40;

	@rotation public var r:Float;

	@pivotY @const @formula("h * 0.5") public var py:Int;

	@color public var c:Color = 0xFFFFFFFF;

	@varying @custom public var speed:Float = 1.0;

	public var length(get, set):Int;

	inline function get_length() {
		return w - initW;
	}

	inline function set_length(value:Int) {
		return w = value + initW;
	}

	public var initW(default, null):Int;
	public var initH(default, null):Int;

	/**
		The parent of this sustain sprite.
	**/

	// --------------------------------------------------------------------------

	static public function init(program:Program, name:String, texture:Texture)
	{
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true );
		program.blendEnabled = program.blendSeparate = true;

		var tW:String = Util.toFloatString(texture.width);
		var tH:String = Util.toFloatString(texture.height);

		program.injectIntoFragmentShader(
		'
			vec4 slice( int textureID, float tailPoint )
			{
				vec2 coord = vTexCoord;

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
		this.w = initW = w;
		this.h = initH = h;
	}

	inline public function followNote(note:Note) {
		x = note.x + ((note.w + (note.ox << 1)) >> 1);
		y = note.y + (((note.h + (note.oy << 1)) - initH) >> 1);
	}
}