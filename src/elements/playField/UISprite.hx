// Note to self: I did a stress test on that sprites by rendering 4000 and it turns out the bigger the texture dimensions are the slower it runs

package elements.playField;

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

	var type:UISpriteType = NONE;

    var isNone(get, never):Bool;

	inline function get_isNone() {
		return type == NONE;
	}

    var isRatingPopup(get, never):Bool;

	inline function get_isRatingPopup() {
		return type == RATING;
	}

    var isComboPopup(get, never):Bool;

	inline function get_isComboPopup() {
		return type == COMBO;
	}

    var isHealthBar(get, never):Bool;

	inline function get_isHealthBar() {
		return type == HEALTH_BAR;
	}

    var isIcon(get, never):Bool;

	inline function get_isIcon() {
		return type == ICON;
	}

	var OPTIONS = { texRepeatX: false, texRepeatY: false, blend: true };

	static function init() {
		
	}

	function new() {}

    inline function changeID(id:Int) {
		var wValue = 300;
		var hValue = 150;
		var xValue = 0;
		var yValue = 0;

        if (isComboPopup) {
			wValue = 60;
			hValue = 72;
			yValue = 150;
		}

		if (isHealthBar) {
			wValue = 600;
			hValue = 19;
			yValue = 222;
			id = 0;
		}

		if (isIcon) {
			wValue = hValue = 150;
			yValue = 300;
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
	var RATING;
	var COMBO;
	var HEALTH_BAR;
	var ICON;
}