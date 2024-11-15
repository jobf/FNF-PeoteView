// Note to self: I did a stress test on that sprites by rendering 4000 and it turns out the bigger the texture dimensions are the slower it runs

package elements;

@:publicFields
class PauseOption implements Element {
	// position in pixel (relative to upper left corner of Display)
	@posX var x:Int = 0;
	@posY var y:Int = 0;

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

	var c:Color;

	var curID(default, null):Int;

	var OPTIONS = { texRepeatX: false, texRepeatY: false, blend: true };

	static function init(program:Program, name:String, texture:Texture) {
		// creates a texture-layer named "name"
		program.setTexture(texture, name, true);
		program.blendEnabled = true;
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

		if (isCountdownPopup) {
			wValue = 600;
			hValue = 300;
			yValue = 150 + (150 * id);

			xValue = id == 1 ? -600 : 600;

			id &= 0x1;
		}

		if ((w != wValue && clipWidth != wValue && clipSizeX != wValue) && (h != hValue && clipHeight != hValue && clipHeight != hValue)) {
			w = clipWidth = clipSizeX = wValue;
			h = clipHeight = clipSizeY = hValue;
		}

		clipX = xValue + (id * clipWidth);
		clipY = yValue;

		curID = id;
    }
}