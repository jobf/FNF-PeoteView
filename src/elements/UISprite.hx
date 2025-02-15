// Note to self: 2 months into funkin view development, I did a stress test on this by rendering 4000 and it turns out the bigger the texture dimensions the slower it runs
// You're rendering more pixels

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

	@color var c:Color = 0xFFFFFFFF;
	@color var c1:Color = 0xFFFFFFFF;
	@color var c2:Color = 0xFFFFFFFF;
	@color var c3:Color = 0xFFFFFFFF;
	@color var c4:Color = 0xFFFFFFFF;
	@color var c5:Color = 0xFFFFFFFF;
	@color var c6:Color = 0xFFFFFFFF;

	inline function setAllColors(colors:Array<Color>) {
		c1 = colors[0];
		c2 = colors[1];
		c3 = colors[2];
		c4 = colors[3];
		c5 = colors[4];
		c6 = colors[5];
	}

	static var healthBarDimensions:Array<Int> = [];

	@varying @custom var flip:Float = 0.0;
	@varying @custom var gradientMode:Float = 0.0;

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

    var isHealthBarPart(get, never):Bool;

	inline function get_isHealthBarPart() {
		return type == HEALTH_BAR_PART;
	}

    var isHealthIcon(get, never):Bool;

	inline function get_isHealthIcon() {
		return type == HEALTH_ICON;
	}

    var isCountdownPopup(get, never):Bool;

	inline function get_isCountdownPopup() {
		return type == COUNTDOWN_POPUP;
	}

    var isPauseOption(get, never):Bool;

	inline function get_isPauseOption() {
		return type == PAUSE_OPTION;
	}

	var curID(default, null):Int;

	var OPTIONS = { texRepeatX: false, texRepeatY: false, blend: true };

	// This makes it so we don't have create a separate spritesheet for it and leave it in the ui spritesheet.
	private static var hardcoded_pause_option_values(default, null):Array<Array<Int>> = [
		[0, 600, 300, 75],
		[0, 675, 300, 75],
		[300, 600, 300, 150]
	];

	static function init(program:Program, name:String, texture:Texture) {
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true);
		program.blendEnabled = true;

		program.injectIntoFragmentShader('
			vec4 flipTexWithGrad( int textureID, float flip, float gradientMode, vec4 c, vec4 c1, vec4 c2, vec4 c3, vec4 c4, vec4 c5, vec4 c6 )
			{
				vec2 coord = vTexCoord;

				if (gradientMode == 0.0) {
					if (flip != 0.0) {
						coord.x = 1.0 - coord.x;
					}
					return getTextureColor( textureID, coord ) * c;
				}

				// Source: https://www.shadertoy.com/view/dsy3RV (Old code)

				float y = coord.y;

				float step1 = 0.0;
				float step2 = 0.19666666666666666666666;
				float step3 = 0.36333333333333333333333;
				float step4 = 0.59;
				float step5 = 0.8133333333333333333333;
				float step6 = 1.0;

				vec4 color = c1;

				// this is reverse order from visual order
				color = mix(color, c2, smoothstep(step1, step2, y));
				color = mix(color, c3, smoothstep(step2, step3, y));
				color = mix(color, c4, smoothstep(step3, step4, y));
				color = mix(color, c5, smoothstep(step4, step5, y));
				color = mix(color, c6, smoothstep(step5, step6, y));

				return color;
			}
		');

		program.setColorFormula('flipTexWithGrad(${name}_ID, flip, gradientMode, c, c1, c2, c3, c4, c5, c6)');
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
			yValue = 750 + (150 * (id >> 3));
			id &= 0x7;
		}

		if (isHealthBarPart) {
			xValue = 602 + (id << 1);
			yValue = 600;
			wValue = 0;
			hValue = 6;
			id = 0;
		}

		if (isCountdownPopup) {
			wValue = 600;
			hValue = 300;
			yValue = 150 + (150 * id);

			switch (id) {
				case 0:
					xValue = 600;
				case 1:
					xValue = -600;
				case 2:
					xValue = 606;
					wValue = 294;
					id = 0;
			}
		}

		if (!isPauseOption) {
			xValue += id * wValue;
		} else {
			var option:Array<Int> = hardcoded_pause_option_values[id];
			xValue = option[0];
			yValue = option[1];
			wValue = option[2];
			hValue = option[3];
		}

		if ((w != wValue && clipWidth != wValue && clipSizeX != wValue) && (h != hValue && clipHeight != hValue && clipHeight != hValue)) {
			w = clipWidth = clipSizeX = wValue;
			h = clipHeight = clipSizeY = hValue;
		}

		clipX = xValue;
		clipY = yValue;

		curID = id;
    }
}

enum abstract UISpriteType(cpp.UInt8) {
	var NONE;
	var RATING_POPUP;
	var COMBO_NUMBER;
	var HEALTH_BAR;
	var HEALTH_ICON;
	var HEALTH_BAR_PART;
	var COUNTDOWN_POPUP;
	var PAUSE_OPTION;
}