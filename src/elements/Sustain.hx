package elements;

/**
	The sustain note of the note sprite.
**/
class Sustain implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @formula("x") public var x : Int;
	@posY @formula("y + py") public var y : Int;

	// size in pixel
	@varying @sizeX @formula("w * speed") public var w : Int;
	@varying @sizeY @formula("h * scale") public var h : Int;

	// at what x position it have to slice (width of the tail in texturedata pixels) (WARNING: COUNT X POSITION FROM PNG BACKWARDS)
	@varying @custom public var tailPoint = 43;

	@rotation public var r : Float;

	@pivotY @const @formula("h * 0.5") public var py : Int;

	@color public var c : Color = 0xFFFFFFFF;

	@varying @custom public var speed : Float = 1.0;

	@varying @custom public var scale : Float = 1.0;

	static public var defaultAlpha : Float = 0.6;
	static public var defaultMissAlpha : Float = 0.3;

	public var length : Int;

	// Custom despawn distance dedicated to the sustain note.
	private var despawnDist : Int;

	public var held : Bool;

	@texTile var tile = 0;

	/**
		The parent of this note sprite.
	**/
	public var parent : Note;

	static public var offsets : Array<Array<Int>> = [];
	static public var tailPoints : Array<Int> = [];

	static public function init(program:Program, name:String, texture:Texture)
	{
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true);
		program.blendEnabled = true;

		var tW : String = Util.toFloatString(texture.width / texture.tilesX);
		var tH : String = Util.toFloatString(texture.height / texture.tilesY);

		program.injectIntoFragmentShader(
		'
			vec4 slice(int textureID, float tailPoint)
			{
				vec2 coord = vTexCoord;

				tailPoint = $tW - tailPoint;

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

				return getTextureColor(textureID, coord);
			}
		');

		// instead of using normal "name" identifier to fetch the texture-color,
		// the postfix "_ID" gives access to use getTextureColor(textureID, ...) or getTextureResolution(textureID)
		program.setColorFormula('c * slice(${name}_ID, tailPoint)' );
	}

	inline public function new(x:Int, y:Int, w:Int, h:Int, id=0)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	inline public function changeID(id:Int)
	{
		tile = id;
		tailPoint = tailPoints[id];
	}

	inline public function followNote(note:Note)
	{
		var offset = offsets[note.id];
		x = note.x + (Math.floor(offset[0] * scale) >> 1);
		y = note.y + (Math.floor(offset[1] * scale) >> 1);
	}
}