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

	@color var c:Color = 0xFFFFFFFF;

	static var healthBarDimensions:Array<Int> = [];

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

	// This makes it so we don't have create a separate submenu for it and leave it in the top of the playfield (where all the ui is).
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
			vec4 flipTex( int textureID, float flip )
			{
				vec2 coord = vTexCoord;

				if (flip != 0.0) {
					coord.x = 1.0 - coord.x;
				}

				return getTextureColor( textureID, coord );
			}
		');

		program.setColorFormula('c * flipTex(${name}_ID, flip)');
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

	static var data:TextureData;
	static function setPixelThenUpdateTex(tex:Texture, row:Int, id:Int, c:Color) {
		id &= 0x1;

		var rowY = 450 + row;
		switch (id) {
			case 0:
				data.setColor_RGBA(600, rowY, c);
				data.setColor_RGBA(601, rowY, c);
				data.setColor_RGBA(602, rowY, c);
			case 1:
				data.setColor_RGBA(603, rowY, c);
				data.setColor_RGBA(604, rowY, c);
				data.setColor_RGBA(605, rowY, c);
		}

		tex.setData(data);
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