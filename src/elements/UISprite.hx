// Note to self: I did a stress test on that sprites by rendering 4000 and it turns out the bigger the texture dimensions are the slower it runs

package elements;

@:publicFields
class UISprite implements Element {
	// position in pixel (relative to upper left corner of Display)
	@posX var x:Float = 0.0;
	@posY var y:Float = 0.0;

	// size in pixel
	@sizeX var w:Int = 200;
	@sizeY var h:Int = 200;

	// extra tex attributes for clipping
	@texX var clipX:Int = 0;
	@texY var clipY:Int = 0;
	@texW var clipWidth:Int = 200;
	@texH var clipHeight:Int = 200;

	// extra tex attributes to adjust texture within the clip
	@texPosX  var clipPosX:Int = 0;
	@texPosY  var clipPosY:Int = 0;
	@texSizeX var clipSizeX:Int = 200;
	@texSizeY var clipSizeY:Int = 200;

	@color var c1:Color = 0xFFFFFFFF;
	@color var c2:Color = 0xFFFFFFFF;
	@color var c3:Color = 0xFFFFFFFF;
	@color var c4:Color = 0xFFFFFFFF;
	@color var c5:Color = 0xFFFFFFFF;
	@color var c6:Color = 0xFFFFFFFF;

	static var healthBarDimensions:Array<Int> = [];

	var c(get, set):Color;

	inline function get_c() {
		return c1;
	}

	inline function set_c(value:Color) {
		return c1 = c2 = c3 = c4 = c5 = c6 = value;
	}

	var a(get, set):Float;

	inline function get_a() {
		return c.aF;
	}

	inline function set_a(value:Float) {
		c1.aF = value;
		c2.aF = value;
		c3.aF = value;
		c4.aF = value;
		c5.aF = value;
		c6.aF = value;
		return value;
	}

	@varying @custom var gradientMode:Float = 0.0;
	@varying @custom var flip:Float = 0.0;

	var type:UISpriteType = NONE;

    var isNone(get, never):Bool;

	inline function get_isNone() {
		return type == NONE;
	}

    var isRatingPopup(get, never):Bool;

	inline function get_isRatingPopup() {
		return type == RATING_POPUP;
	}

    var isComboNumber(get, never):Bool;

	inline function get_isComboNumber() {
		return type == COMBO_NUMBER;
	}

    var isHealthBar(get, never):Bool;

	inline function get_isHealthBar() {
		return type == HEALTH_BAR;
	}

    var isHealthIcon(get, never):Bool;

	inline function get_isHealthIcon() {
		return type == HEALTH_ICON;
	}

	var OPTIONS = { texRepeatX: false, texRepeatY: false, blend: true };

	static function init(program:Program, name:String, texture:Texture) {
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true);
		program.blendEnabled = true;

		program.injectIntoFragmentShader('
			vec4 gradient( int textureID, float gradientMode, float flip, vec4 c1, vec4 c2, vec4 c3, vec4 c4, vec4 c5, vec4 c6 )
			{
				vec2 coord = vTexCoord;

				float t = coord.y * 2.0;
				vec4 gradientColor = mix(
				mix(
					mix(
						mix(
							mix(c1, c2, t),
							c3, t - 0.333333),
						c4, t - 0.666666),
					c5, t - 1.0),
				c6, t - 1.333333);

				if (flip != 0.0) {
					coord.x = 1.0 - coord.x;
				}

				vec4 texColor = c1 * getTextureColor( textureID, coord );

				// if the mix factor (gradientMode) is 1.0 then it will be fully gradientColor or if its 0.0 then it will be fully texColor
				return mix(texColor, gradientColor, gradientMode ); 
			}
		');

		program.setColorFormula('gradient(${name}_ID, gradientMode, flip, c1, c2, c3, c4, c5, c6)');
	}

	function new() {}

    inline function changeID(id:Int) {
		var wValue = 300;
		var hValue = 150;
		var xValue = 0;
		var yValue = 0;

        if (isComboNumber) {
			wValue = 60;
			hValue = 72;
			yValue = 150;
			id %= 10;
		}

		if (isHealthBar) {
			wValue = healthBarDimensions[0];
			hValue = healthBarDimensions[1];
			yValue = 222;
			id = 0;
		}

		if (isHealthIcon) {
			wValue = hValue = 150;
			yValue = 300 + (150 * (id >> 3));
			id &= 0x7;
		}

		if ((w != wValue && clipWidth != wValue && clipSizeX != wValue) && (h != hValue && clipHeight != hValue && clipHeight != hValue)) {
			w = clipWidth = clipSizeX = wValue;
			h = clipHeight = clipSizeY = hValue;
		}

		clipX = xValue + (id * clipWidth);
		clipY = yValue;
    }
}

enum abstract UISpriteType(cpp.UInt8) {
	var NONE;
	var RATING_POPUP;
	var COMBO_NUMBER;
	var HEALTH_BAR;
	var HEALTH_ICON;
}