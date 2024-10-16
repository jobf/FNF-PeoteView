package elements.sustains;

import peote.view.*;

class HSliceRepeat implements Element
{
	// position in pixel (relative to upper left corner of Display)
	@posX @formula("x") public var x:Int;
	@posY @formula("y + py") public var y:Int;
	
	// size in pixel
	@varying @sizeX public var w:Int;
	@varying @sizeY public var h:Int;

	// at what x position it have to slice (width of the tail in texturedata pixels) (WARNING: COUNT X POSITION FROM PNG BACKWARDS)
	@varying @custom public var tailPoint:Int = 31;

	@rotation public var r:Float;

	@pivotY @formula("(h * 0.5)") public var py:Int;

	@color public var c:Color = 0xFFFFFFFF;

	// --------------------------------------------------------------------------
	
	static public var buffer:Buffer<HSliceRepeat>;
	static public var program:Program;
	
	static public function init(display:Display, name:String, texture:Texture)
	{
		buffer = new Buffer<HSliceRepeat>(1, 1024, true);
		program = new Program(buffer);
		program.blendEnabled = true;
		
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true );
		
		program.injectIntoFragmentShader(
		'		
			vec4 slice( int textureID, float tailPoint )
			{				
				float slicePositionX = 1.0 - (tailPoint/${texture.slotHeight}.0 * vSize.y) / vSize.x;

				vec2 coord = vTexCoord;
				if (coord.x < slicePositionX)
				{
					coord.x = mix(
					1.0 - tailPoint/${texture.slotWidth}.0,
					0.0,
					mod(
						(1.0-coord.x/slicePositionX) * 
						(vSize.x/vSize.y * ${texture.slotHeight}.0 - tailPoint) /
						(${texture.slotWidth}.0 - tailPoint), 1.0
					)
					);
				}
				else
				{
					coord.x = mix(1.0 - tailPoint/${texture.slotWidth}.0, 1.0, (coord.x - slicePositionX) / (1.0 - slicePositionX) );
				}

				return getTextureColor( textureID, coord );
			}			
		');
		
		// instead of using normal "name" identifier to fetch the texture-color,
		// the postfix "_ID" gives access to use getTextureColor(textureID, ...) or getTextureResolution(textureID)		
		program.setColorFormula( 'slice(${name}_ID, tailPoint)' );
				
		display.addProgram(program);
	}
	
	public function new(x:Int, y:Int, w:Int, h:Int) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		buffer.addElement(this);
	}

}
